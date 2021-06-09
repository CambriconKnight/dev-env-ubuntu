/*
All modification made by Cambricon Corporation: © 2018--2019 Cambricon Corporation
All rights reserved.
All other contributions:
Copyright (c) 2014--2018, the respective contributors
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#if defined(USE_MLU) && defined(USE_OPENCV)
#include <algorithm>
#include <condition_variable>  // NOLINT
#include <iomanip>
#include <iosfwd>
#include <map>
#include <memory>
#include <queue>
#include <string>
#include <thread>  // NOLINT
#include <utility>
#include <vector>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include "blocking_queue.hpp"
#include "cnrt.h"  // NOLINT
#include "common_functions.hpp"
#include "command_option.hpp"
#include "simple_interface.hpp"
#include "threadPool.h"

using std::map;
using std::pair;
using std::queue;
using std::string;
using std::stringstream;
using std::thread;
using std::vector;

std::condition_variable condition;
std::mutex condition_m;
static int start;

DEFINE_int32(dump, 1, "0 or 1, dump output images or not.");
DEFINE_string(outputdir, ".", "The directoy used to save output images");

static void WriteVisualizeBBox_offline(
    const vector<cv::Mat>& images,
    const vector<vector<vector<float>>> detections,
    const vector<string>& labelToDisplayName,
    const vector<string>& imageNames,
    int input_dim,
    const int from,
    const int to) {
  // Retrieve detections.
  for (int i = from; i < to; ++i) {
    if (imageNames[i] == "null") continue;
    cv::Mat image;
    image = images[i];
    vector<vector<float>> result = detections[i];
    std::string name = imageNames[i];
    int positionMap = imageNames[i].rfind("/");
    if (positionMap > 0 && positionMap < imageNames[i].size()) {
      name = name.substr(positionMap + 1);
    }
    positionMap = name.find(".");
    if (positionMap > 0 && positionMap < name.size()) {
      name = name.substr(0, positionMap);
    }
    string filename = name + ".txt";
    std::ofstream fileMap(FLAGS_outputdir + "/" + filename);

	for (int j=0; j < result.size(); j++) {
		//auto x0 = static_cast<int>(result[j][0]);
		//auto y0 = static_cast<int>(result[j][1]);
		//auto x1 = static_cast<int>(result[j][2]);
		//auto y1 = static_cast<int>(result[j][3]);
		float x0 = static_cast<float>(result[j][0]);
		float y0 = static_cast<float>(result[j][1]);
		float x1 = static_cast<float>(result[j][2]);
		float y1 = static_cast<float>(result[j][3]);

		x0 = x0*image.cols;
		x1 = x1*image.cols;
		y0 = y0*image.rows;
		y1 = y1*image.rows;

		cv::Point p1(x0, y0);
		cv::Point p2(x1, y1);
		cv::rectangle(image, p1, p2, cv::Scalar(0, 255, 0), 2);
		std::stringstream ss;
		ss << round(result[j][4] * 1000) / 1000;
		std::string str = labelToDisplayName[static_cast<int>(result[j][5])] + ":" + ss.str();
		cv::Point p5(x0, y0 + 10);
		cv::putText(image, str, p5, cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(255, 0, 0), 0.5);
		fileMap << labelToDisplayName[static_cast<int>(result[j][5])] << " "
				<< ss.str() << " "
				<< static_cast<float>(result[j][0]) << " "
				<< static_cast<float>(result[j][1]) << " "
				<< static_cast<float>(result[j][2]) << " "
				<< static_cast<float>(result[j][3]) << " "
				<< image.cols << " " << image.rows << std::endl;
	}
	fileMap.close();

    stringstream ss;
    string outFile;
    ss << FLAGS_outputdir << "/yolov4_offline_" << name << ".jpg";
    ss >> outFile;
    cv::imwrite((outFile.c_str()), image);
  }
}

void setDeviceId(int dev_id) {
  unsigned devNum;
  CNRT_CHECK(cnrtGetDeviceCount(&devNum));
  if (dev_id >= 0) {
    CHECK_NE(devNum, 0) << "No device found";
    CHECK_LT(dev_id, devNum) << "Valid device count: " << devNum;
  } else {
    LOG(FATAL) << "Invalid device number";
  }
  cnrtDev_t dev;
  LOG(INFO) << "Using MLU device " << dev_id;
  CNRT_CHECK(cnrtGetDeviceHandle(&dev, dev_id));
  CNRT_CHECK(cnrtSetCurrentDevice(dev));
}

class PostProcessor;

class Inferencer {
  public:
  Inferencer(const string& offlinemodel, const int& parallel,
             const int& deviceId, const int& devicesize);
  Inferencer(const cnrtRuntimeContext_t rt_ctx, const int& id);
  ~Inferencer();
  int n() { return inNum_; }
  int c() { return inChannel_; }
  int h() { return inHeight_; }
  int w() { return inWidth_; }
  bool simpleFlag() {return simple_flag_;}
  vector<vector<int>> outputshape() { return outputShape_; }
  void pushValidInputData(void** data);
  void pushFreeInputData(void** data);
  void** popValidInputData();
  void** popFreeInputData();
  void pushValidAsyncCopyQueue(cnrtQueue_t queue);
  void pushFreeAsyncCopyQueue(cnrtQueue_t queue);
  cnrtQueue_t popValidAsyncCopyQueue();
  cnrtQueue_t popFreeAsyncCopyQueue();
  void pushValidOutputData(void** data);
  void pushFreeOutputData(void** data);
  void** popValidOutputData();
  void** popFreeOutputData();
  void pushValidInputNames(vector<pair<string, cv::Mat>> rawImages);
  void pushValidInputDataAndNames(void** data, const vector<pair<string, cv::Mat>>& images);
  void pushValidInputDataAndNames(void** data,
                                  const vector<pair<string,
                                  cv::Mat>>& images,
                                  cnrtQueue_t queue);
  void pushFreeInputTimeTraceData(InferenceTimeTrace* data) {
    freeInputTimetraceFifo_.push(data);
  }
  void pushValidInputTimeTraceData(InferenceTimeTrace* data) {
    validInputTimetraceFifo_.push(data);
  }
  void pushValidOutputTimeTraceData(InferenceTimeTrace* data) {
    validOutputTimetraceFifo_.push(data);
  }
  InferenceTimeTrace* popValidInputTimeTraceData() { return validInputTimetraceFifo_.pop(); }
  InferenceTimeTrace* popValidOutputTimeTraceData() { return validOutputTimetraceFifo_.pop(); }
  InferenceTimeTrace* popFreeInputTimeTraceData() { return freeInputTimetraceFifo_.pop(); }
  vector<pair<string, cv::Mat>> popValidInputNames();
  void simpleRun();
  inline int inBlobNum() { return inBlobNum_; }
  inline int outBlobNum() { return outBlobNum_; }
  inline int threadId() { return threadId_; }
  inline int deviceId() { return deviceId_; }
  inline int deviceSize() { return deviceSize_; }
  inline float inferencingTime() { return inferencingTime_; }
  inline void setThreadId(int id) { threadId_ = id; }
  inline void setPostProcessor(PostProcessor* p) { postProcessor_ = p; }
  inline vector<int> outCount() {
    vector<int> storage;
    for (int i = 0; i < outBlobNum_; i++) storage.emplace_back(outCount_[i]);
    return storage;
  }
  inline cnrtFunction_t function() { return function_; }

  private:
  void getIODataDesc();

  private:
  BlockingQueue<void**> validInputFifo_;
  BlockingQueue<void**> freeInputFifo_;
  BlockingQueue<cnrtQueue_t> validAsyncCopyQueueFifo_;
  BlockingQueue<cnrtQueue_t> freeAsyncCopyQueueFifo_;
  BlockingQueue<void**> validOutputFifo_;
  BlockingQueue<void**> freeOutputFifo_;
  BlockingQueue<vector<pair<string, cv::Mat>>> imagesFifo_;
  BlockingQueue<InferenceTimeTrace*> freeInputTimetraceFifo_;
  BlockingQueue<InferenceTimeTrace*> validInputTimetraceFifo_;
  BlockingQueue<InferenceTimeTrace*> validOutputTimetraceFifo_;

  cnrtModel_t model_;
  cnrtQueue_t queue_;
  cnrtFunction_t function_;
  cnrtRuntimeContext_t rt_ctx_;
  cnrtDim3_t dim_;

  bool simple_flag_;
  int inBlobNum_, outBlobNum_;
  unsigned int inNum_, inChannel_, inHeight_, inWidth_;
  unsigned int outNum_[2], outChannel_[2], outHeight_[2], outWidth_[2];
  vector<vector<int>> outputShape_;
  int outCount_[2];
  int threadId_;
  int deviceId_;
  int deviceSize_;
  int parallel_ = 1;
  float inferencingTime_;
  PostProcessor* postProcessor_;
  std::mutex infr_mutex_;
};

class PostProcessor {
  public:
  explicit PostProcessor(const int& deviceId)
      : threadId_(0), deviceId_(deviceId) {
  }
  virtual ~PostProcessor() {}
  void run();
  inline void setThreadId(int id) { threadId_ = id; }
  inline void setInferencer(Inferencer* p) { inferencer_ = p; }
  inline int top1() { return top1_; }
  inline int top5() { return top5_; }
  void appendTimeTrace(InferenceTimeTrace t) { timeTraces_.emplace_back(t); }
  virtual std::vector<InferenceTimeTrace> timeTraces() { return timeTraces_; }

  private:
  Inferencer* inferencer_;
  int threadId_;
  int deviceId_;
  int top1_;
  int top5_;
  std::vector<InferenceTimeTrace> timeTraces_;
  static std::mutex post_mutex_;
};
std::mutex PostProcessor::post_mutex_;

class DataProvider {
  public:
  DataProvider(const string& meanValue,
               const int& deviceId, const queue<string>& images)
      : threadId_(0), deviceId_(deviceId), imageList(images) {}
  ~DataProvider() {
    delete[] reinterpret_cast<float*>(cpuData_[0]);
    delete cpuData_;
    delete[] reinterpret_cast<char*>(cpuTempData_[0]);
    delete cpuTempData_;
    delete[] reinterpret_cast<float*>(cpuTrans_[0]);
    delete cpuTrans_;
    delete[] reinterpret_cast<char*>(firstConvData_[0]);
    delete firstConvData_;
    for (auto ptr : inPtrVector_) {
      if (ptr) {
        for (int i=0; i < inferencer_->inBlobNum(); i++) {
          cnrtFree(ptr[i]);
        }
        free(ptr);
      }
    }
    if (FLAGS_async_copy) {
      for (auto queue : asyncCopyQueueVector_) {
        cnrtDestroyQueue(queue);
      }
    }
    for (auto ptr : outPtrVector_) {
      if (ptr) {
        for (int i=0; i < inferencer_->outBlobNum(); i++) {
          cnrtFree(ptr[i]);
        }
        free(ptr);
      }
    }
    for (auto ptr : inPtrTempVector_) {
      if (ptr) {
        for (int i=0; i < inferencer_->inBlobNum(); i++) {
          free(ptr[i]);
        }
        free(ptr);
      }
    }
    for (auto ptr : outPtrTempVector_) {
      if (ptr) {
        for (int i=0; i < inferencer_->outBlobNum(); i++) {
          free(ptr[i]);
        }
        free(ptr);
      }
    }
    for (auto ptr : timetracePtrVector_) {
      if (ptr) {
        free(ptr);
      }
    }
  }
  void allocateMemory();
  void init();
  void run();
  void readInputData();
  void prepareInput();
  void transData();
  void SetMean(const string&);
  void WrapInputLayer(vector<vector<cv::Mat>>* wrappedImages);
  void Preprocess(const vector<cv::Mat>& srcImages,
                  vector<vector<cv::Mat>>* dstImages);
  inline void setThreadId(int id) { threadId_ = id; }
  inline void setInferencer(Inferencer* p) {
    inferencer_ = p;
    inNum_ = p->n();  // make preRead happy
  }
  inline void pushInPtrVector(void** data) { inPtrVector_.emplace_back(data); }
  inline void pushAsyncCopyQueueVector(cnrtQueue_t queue) {
      asyncCopyQueueVector_.emplace_back(queue);
  }
  inline void pushOutPtrVector(void** data) { outPtrVector_.emplace_back(data); }
  inline void pushTimeTracePtrVector(InferenceTimeTrace* data) {
    timetracePtrVector_.emplace_back(data);
  }

  private:
  int inBlobNum_, outBlobNum_;
  int inNum_, inChannel_, inHeight_, inWidth_;
  int threadId_;
  int deviceId_;
  cv::Mat mean_;
  queue<string> imageList;
  Inferencer* inferencer_;
  cv::Size inGeometry_;
  void** cpuData_;
  void** cpuTempData_;
  void** cpuTrans_;
  void** firstConvData_;
  vector<vector<cv::Mat>> inImages_;
  vector<vector<string>> imageName_;
  vector<vector<pair<string, cv::Mat>>> ImageAndName_;
  vector<void**> inPtrVector_;
  vector<cnrtQueue_t> asyncCopyQueueVector_;
  vector<void**> outPtrVector_;
  vector<void**> inPtrTempVector_;
  vector<void**> outPtrTempVector_;
  vector<InferenceTimeTrace*> timetracePtrVector_;
  cnrtDataType_t* input_data_type;
  int dim_order[4];
  int dim_shape[4];
  int inputDimValue[4];
  int inputDimStride[4];
  int input_count;
  std::vector<void *> temp_ptrs;
  vector<cv::Mat> rawImages;
  int64_t *inputSizeS, *outputSizeS;
  vector<pair<string, cv::Mat>> ImageAndName;
};

void DataProvider::allocateMemory() {
  cnrtGetInputDataSize(&inputSizeS, &inBlobNum_, inferencer_->function());
  cnrtGetOutputDataSize(&outputSizeS, &outBlobNum_, inferencer_->function());
  for (int i = 0; i < FLAGS_fifosize; i++) {
    void **inputMluPtrS, **outputMluPtrS;

    // this queue is for async copy
    cnrtQueue_t queue;
    if (FLAGS_async_copy) {
      CHECK(cnrtCreateQueue(&queue) == CNRT_RET_SUCCESS)
          << "CNRT create queue for async copy failed, thread_id"
          << inferencer_->threadId();
    }

    inputMluPtrS =
         reinterpret_cast<void**>(malloc(sizeof(void*) * inBlobNum_));
    outputMluPtrS =
         reinterpret_cast<void**>(malloc(sizeof(void*) * outBlobNum_));

    for (int i=0; i < inBlobNum_; i++) {
      cnrtMalloc(&(inputMluPtrS[i]), inputSizeS[i]);
    }
    for (int i=0; i < outBlobNum_; i++) {
      cnrtMalloc(&(outputMluPtrS[i]), outputSizeS[i]);
    }

    inferencer_->pushFreeInputData(inputMluPtrS);
    if (FLAGS_async_copy) {
      inferencer_->pushFreeAsyncCopyQueue(queue);
    }
    inferencer_->pushFreeOutputData(outputMluPtrS);
    // push ptrs to vectors for destruction
    pushInPtrVector(inputMluPtrS);
    if (FLAGS_async_copy) {
      pushAsyncCopyQueueVector(queue);
    }
    pushOutPtrVector(outputMluPtrS);
    // malloc timeStamp
    InferenceTimeTrace* timestamp =
      reinterpret_cast<InferenceTimeTrace*>(malloc(sizeof(InferenceTimeTrace)));
    inferencer_->pushFreeInputTimeTraceData(timestamp);
    pushTimeTracePtrVector(timestamp);
  }

  cpuData_ = new (void*);
  cpuData_[0] = new float[inNum_ * inChannel_ * inHeight_ * inWidth_];
  cpuTempData_ = new (void*);
  cpuTempData_[0] = new char[inputSizeS[0]];
  cpuTrans_ = new (void*);
  cpuTrans_[0] = new float[inNum_ * inChannel_ * inHeight_ * inWidth_];
  firstConvData_ = new (void*);
  firstConvData_[0] = new char[inNum_ * inChannel_ * inHeight_ * inWidth_];
}

void DataProvider::init() {
  setDeviceId(deviceId_);
  inBlobNum_ = inferencer_->inBlobNum();
  outBlobNum_ = inferencer_->outBlobNum();
  inNum_ = inferencer_->n();
  inChannel_ = inferencer_->c();
  inHeight_ = inferencer_->h();
  inWidth_ = inferencer_->w();
  inGeometry_ = cv::Size(inWidth_, inHeight_);
  SetMean(FLAGS_meanvalue);

  // get input data type
  cnrtGetInputDataType(&input_data_type, &inBlobNum_, inferencer_->function());
  // set input data shape
  dim_order[0] = 0;
  dim_order[1] = 2;
  dim_order[2] = 3;
  dim_order[3] = 1;

  dim_shape[0] = inferencer_->n();
  dim_shape[1] = inferencer_->c();
  dim_shape[2] = inferencer_->h();
  dim_shape[3] = inferencer_->w();
  inputDimValue[0] = inferencer_->n();
  inputDimValue[1] = inferencer_->h();
  inputDimValue[2] = inferencer_->w();
  inputDimValue[3] = inferencer_->c();

  inputDimStride[0] = 0;
  inputDimStride[1] = 0;
  inputDimStride[2] = 0;
  inputDimStride[3] = 1;

  input_count = inferencer_->n() * inferencer_->c() *
                    inferencer_->h() * inferencer_->w();

  allocateMemory();
  std::unique_lock<std::mutex> lk(condition_m);
  LOG(INFO) << "Waiting ...";
  condition.wait(lk, [] { return start; });
  lk.unlock();
}

void DataProvider::readInputData() {
  rawImages.clear();
  ImageAndName.clear();
  int imageLeft = imageList.size();
  string file = imageList.front();
  cv::Size imgsize = cv::Size(inferencer_->w(), inferencer_->h());

  if (FLAGS_perf_mode) {
    if (file.find(" ") != string::npos)
      file = file.substr(0, file.find(" "));
    cv::Mat img = readImage(file, imgsize, FLAGS_yuv);
    for (int i = 0; i < inNum_; i++) {
      rawImages.emplace_back(img);
      ImageAndName.emplace_back(pair<string, cv::Mat>(file, img));
    }
    return;
  }
  for (int i = 0; i < inNum_; i++) {
    if (i < imageLeft) {
      file = imageList.front();
      imageList.pop();
      if (file.find(" ") != string::npos)
        file = file.substr(0, file.find(" "));
      cv::Mat img = readImage(file, imgsize, FLAGS_yuv);
      rawImages.emplace_back(img);
      ImageAndName.emplace_back(pair<string, cv::Mat>(file, img));
    } else {
      cv::Mat img = readImage(file, imgsize, FLAGS_yuv);
      rawImages.emplace_back(img);
      ImageAndName.emplace_back(pair<string, cv::Mat>(file, img));
    }
  }
}

void DataProvider::prepareInput() {
  Timer prepareInput;
  vector<vector<cv::Mat>> preprocessedImages;
  WrapInputLayer(&preprocessedImages);
  Preprocess(rawImages, &preprocessedImages);
  prepareInput.log("prepare input data ...");
}

void DataProvider::transData() {
  temp_ptrs.clear();
  void** cpuTempData = cpuTempData_;
  for (int i=0; i < inBlobNum_; i++) {
    cnrtTransDataOrder(cpuData_[i], CNRT_FLOAT32, cpuTrans_[i],
                      4, dim_shape, dim_order);
    void* temp_ptr = nullptr;
    if (input_data_type[i] != CNRT_FLOAT32) {
      cnrtCastDataType(cpuTrans_[i],
                      CNRT_FLOAT32,
                      (input_data_type[i] == CNRT_UINT8) ? firstConvData_[i] :
                                                            cpuTempData[i],
                      input_data_type[i],
                      input_count,
                      nullptr);

      if (input_data_type[i] == CNRT_UINT8) {
        if (FLAGS_input_format == 0) {
          cnrtAddDataStride(firstConvData_[i], CNRT_UINT8, cpuTempData[i], 4,
                            inputDimValue, inputDimStride);
        } else if (FLAGS_input_format == 1 || FLAGS_input_format == 3) {
          // input data is in rgba(bgra) format
          // input_format=1 represents weight is in argb(abgr) order
          uint8_t* tmp = new uint8_t[input_count];
          tmp[0] = 0;
          memcpy(tmp + 1, firstConvData_[i], input_count - 1);
          memcpy(cpuTempData[i], tmp, input_count);
          delete [] tmp;
        } else if (FLAGS_input_format == 2) {
          // input data is in bgra format
          // input_format=2 represents weight is in bgra order
          memcpy(cpuTempData[i], firstConvData_[i], input_count);
        }
      }
      temp_ptr = cpuTempData[i];
    } else {
      temp_ptr = cpuTrans_[i];
    }
    temp_ptrs.emplace_back(temp_ptr);
  }
}

void DataProvider::run() {
  init();
  if (FLAGS_perf_mode) {
    int leftNumBatch = FLAGS_perf_mode_img_num / this->inNum_;
    readInputData();
    prepareInput();
    transData();
    while (leftNumBatch--) {
      void** mluData = inferencer_->popFreeInputData();
      // this queue is for async copy
      cnrtQueue_t queue;
      if (FLAGS_async_copy) {
        queue = inferencer_->popFreeAsyncCopyQueue();
      }
      Timer copyin;
      TimePoint t1 = std::chrono::high_resolution_clock::now();
      for (int i=0; i < inBlobNum_; i++) {
        if (FLAGS_async_copy) {
          cnrtMemcpyAsync(mluData[i],
                     temp_ptrs[i],
                     inputSizeS[i],
                     queue,
                     CNRT_MEM_TRANS_DIR_HOST2DEV);
        } else {
          cnrtMemcpy(mluData[i],
                     temp_ptrs[i],
                     inputSizeS[i],
                     CNRT_MEM_TRANS_DIR_HOST2DEV);
        }
      }
      TimePoint t2 = std::chrono::high_resolution_clock::now();
      auto timetrace = inferencer_->popFreeInputTimeTraceData();
      timetrace->in_start = t1;
      timetrace->in_end = t2;
      inferencer_->pushValidInputTimeTraceData(timetrace);

      copyin.log("copyin time ...");
      if (FLAGS_async_copy) {
        inferencer_->pushValidInputDataAndNames(mluData, ImageAndName, queue);
      } else {
        inferencer_->pushValidInputDataAndNames(mluData, ImageAndName);
      }
    }
  } else {
    while (imageList.size()) {
      readInputData();
      prepareInput();
      void** mluData = inferencer_->popFreeInputData();
      // this queue is for async copy
      cnrtQueue_t queue;
      if (FLAGS_async_copy) {
        queue = inferencer_->popFreeAsyncCopyQueue();
      }
      Timer copyin;
      TimePoint t1 = std::chrono::high_resolution_clock::now();
      transData();
      if (temp_ptrs.size() == 0) break;
      for (int i=0; i < inBlobNum_; i++) {
        if (FLAGS_async_copy) {
          cnrtMemcpyAsync(mluData[i],
                    temp_ptrs[i],
                    inputSizeS[i],
                    queue,
                    CNRT_MEM_TRANS_DIR_HOST2DEV);
        } else {
          cnrtMemcpy(mluData[i],
                    temp_ptrs[i],
                    inputSizeS[i],
                    CNRT_MEM_TRANS_DIR_HOST2DEV);
        }
      }
      TimePoint t2 = std::chrono::high_resolution_clock::now();
      auto timetrace = inferencer_->popFreeInputTimeTraceData();
      timetrace->in_start = t1;
      timetrace->in_end = t2;
      inferencer_->pushValidInputTimeTraceData(timetrace);

      copyin.log("copyin time ...");
      if (FLAGS_async_copy) {
        inferencer_->pushValidInputDataAndNames(mluData, ImageAndName, queue);
      } else {
        inferencer_->pushValidInputDataAndNames(mluData, ImageAndName);
      }
    }
  }

  LOG(INFO) << "DataProvider: no data ...";
  // tell inferencer there is no more images to process
}

void DataProvider::WrapInputLayer(vector<vector<cv::Mat>>* wrappedImages) {
  //  Parameter images is a vector [ ----   ] <-- images[in_n]
  //                                |
  //                                |-> [ --- ] <-- channels[3]
  // This method creates Mat objects, and places them at the
  // right offset of input stream
  int width = inferencer_->w();
  int height = inferencer_->h();
  int channels = FLAGS_yuv? 1: inferencer_->c();
  float* data = reinterpret_cast<float*>(cpuData_[0]);

  for (int i = 0; i < inferencer_->n(); ++i) {
    wrappedImages->emplace_back(vector<cv::Mat>());
    for (int j = 0; j < channels; ++j) {
      if (FLAGS_yuv) {
        cv::Mat channel(height, width, CV_8UC1, reinterpret_cast<char*>(data));
        (*wrappedImages)[i].emplace_back(channel);
        data += width * height / 4;
      } else {
        cv::Mat channel(height, width, CV_32FC1, data);
        (*wrappedImages)[i].emplace_back(channel);
        data += width * height;
      }
    }
  }
}

void DataProvider::Preprocess(const vector<cv::Mat>& sourceImages,
                              vector<vector<cv::Mat>>* destImages) {
  // Convert the input image to the input image format of the network.
  CHECK(sourceImages.size() == destImages->size())
      << "Size of sourceImages and destImages doesn't match";
  for (int i = 0; i < sourceImages.size(); ++i) {
    if (FLAGS_yuv) {
      cv::Mat sample_yuv;
      sourceImages[i].convertTo(sample_yuv, CV_8UC1);
      cv::split(sample_yuv, (*destImages)[i]);
      continue;
    }
    cv::Mat sample;
    int num_channels_ = inferencer_->c();
    if (sourceImages[i].channels() == 3 && inChannel_ == 1)
      cv::cvtColor(sourceImages[i], sample, cv::COLOR_BGR2GRAY);
    else if (sourceImages[i].channels() == 4 && inChannel_ == 1)
      cv::cvtColor(sourceImages[i], sample, cv::COLOR_BGRA2GRAY);
    else if (sourceImages[i].channels() == 4 && inChannel_ == 3)
      cv::cvtColor(sourceImages[i], sample, cv::COLOR_BGRA2BGR);
    else if (sourceImages[i].channels() == 1 && inChannel_ == 3)
      cv::cvtColor(sourceImages[i], sample, cv::COLOR_GRAY2BGR);
    else if (sourceImages[i].channels() == 3 && inChannel_ == 4)
      cv::cvtColor(sourceImages[i], sample, cv::COLOR_BGR2RGBA);
    else if (sourceImages[i].channels() == 1 && inChannel_ == 4)
      cv::cvtColor(sourceImages[i], sample, cv::COLOR_GRAY2RGBA);
    else
      sample = sourceImages[i];

    // 2.resize the image
    cv::Mat sample_temp, sample_new, sample_resized;
    // int input_dim = inferencer_->h();
    // cv::Mat sample_resized(input_dim, input_dim, CV_8UC3,
    //                        cv::Scalar(128, 128, 128));
    if (FLAGS_input_format > 0) {
      cv::cvtColor(sample_resized, sample_new, cv::COLOR_BGR2RGBA);
      sample_new.copyTo(sample_resized);
    }
    if (sample.size() != inGeometry_) {
      cv::resize(sample, sample_resized, cv::Size(inferencer_->w(), inferencer_->h()));
    } else {
      sample_resized = sample;
    }
    // 3.BGR->RGB
    cv::Mat sample_rgb;
    // 4.convert to float
    cv::Mat sample_float;
    if (num_channels_ == 3) {
      cv::cvtColor(sample_resized, sample_rgb, cv::COLOR_BGR2RGB);
      sample_rgb.convertTo(sample_float, CV_32FC3, 1);
    } else if (num_channels_ == 1) {
      sample_resized.convertTo(sample_float, CV_32FC1, 1);
    } else if (num_channels_ == 4) {
      if (FLAGS_input_format == 1) {
        sample_resized.convertTo(sample_float, CV_32FC4);
      } else if (FLAGS_input_format == 2 || FLAGS_input_format == 3) {
        cv::Mat sample_bgra;
        cv::cvtColor(sample_resized, sample_bgra, cv::COLOR_RGBA2BGRA);
        sample_bgra.convertTo(sample_float, CV_32FC4);
      }
    }
    // This operation will write the separate BGR planes directly to the
    // input layer of the network because it is wrapped by the cv::Mat
    // objects in input_channels. */
    cv::Mat sampleNormalized;
    sampleNormalized = sample_float;

    cv::split(sampleNormalized, (*destImages)[i]);
  }
}

void DataProvider::SetMean(const string& meanValue) {
  if (FLAGS_yuv) return;
  if (FLAGS_meanvalue.empty()) return;
  cv::Scalar channel_mean;
  if (!meanValue.empty()) {
    stringstream ss(meanValue);
    vector<float> values;
    string item;
    while (getline(ss, item, ',')) {
      float value = std::atof(item.c_str());
      values.emplace_back(value);
    }
    CHECK(values.size() == 1 || values.size() == inChannel_)
        << "Specify either one mean value or as many as channels: "
        << inChannel_;
    vector<cv::Mat> channels;
    for (int i = 0; i < inChannel_; ++i) {
      /* Extract an individual channel. */
      cv::Mat channel(inGeometry_.height, inGeometry_.width, CV_32FC1,
                      cv::Scalar(values[i]));
      channels.emplace_back(channel);
    }
    cv::merge(channels, mean_);
  } else {
    LOG(WARNING) << "Cannot support mean file";
  }
}

Inferencer::Inferencer(const cnrtRuntimeContext_t rt_ctx,
            const int& id) : simple_flag_(true) {
  this->rt_ctx_ = rt_ctx;
  this->threadId_ = id;
  this->inferencingTime_ = 0;

  cnrtGetRuntimeContextInfo(rt_ctx, CNRT_RT_CTX_FUNCTION,
          reinterpret_cast<void **>(&this->function_));
  cnrtGetRuntimeContextInfo(rt_ctx, CNRT_RT_CTX_MODEL_PARALLEL,
          reinterpret_cast<void **>(&this->parallel_));
  cnrtGetRuntimeContextInfo(rt_ctx, CNRT_RT_CTX_DEV_ORDINAL,
          reinterpret_cast<void **>(&this->deviceId_));

  getIODataDesc();
}

// getfunction's I/O DataDesc,
// allocate I/O data space on CPU memory and prepare Input data;
void Inferencer::getIODataDesc() {
  cnrtDataType_t* input_data_type = nullptr;
  CNRT_CHECK(cnrtGetInputDataType(&input_data_type, &inBlobNum_, function_));
  cnrtDataType_t* output_data_type = nullptr;
  CNRT_CHECK(cnrtGetOutputDataType(&output_data_type, &outBlobNum_, function_));

  LOG(INFO) << "input blob num is " << inBlobNum_;
  auto shape = std::make_shared<int *>();
  int dimNum = 4;
  for (int i = 0; i < inBlobNum_; i++) {
    cnrtGetInputDataShape(shape.get(), &dimNum, i, function_);  // NHWC
    if (i == 0) {
      inNum_ = shape.get()[0][0];
      inChannel_ = (input_data_type[i] == CNRT_UINT8) ?
                   (FLAGS_input_format > 0 ? shape.get()[0][3] : (shape.get()[0][3] - 1)) :
                   shape.get()[0][3];
      inWidth_ = shape.get()[0][1];
      inHeight_ = shape.get()[0][2];
    }
    LOG(INFO) << "shape " << shape.get()[0][0];
    LOG(INFO) << "shape " << inChannel_;
    LOG(INFO) << "shape " << shape.get()[0][1];
    LOG(INFO) << "shape " << shape.get()[0][2];
    free(shape.get()[0]);  // cnrtGetInputDataShape malloc for shape which need free outside.
  }

  for (int i = 0; i < outBlobNum_; i++) {
    cnrtGetOutputDataShape(shape.get(), &dimNum, i, function_);  // NHWC
    outNum_[i] = shape.get()[0][0];
    outChannel_[i] = shape.get()[0][3];
    outHeight_[i] = shape.get()[0][1];
    outWidth_[i] = shape.get()[0][2];
    outCount_[i] = shape.get()[0][0] * shape.get()[0][1] * shape.get()[0][2] * shape.get()[0][3];
    free(shape.get()[0]);  // cnrtGetOutputDataShape malloc for shape which need free outside.
    std::vector<int> out_shape;
    out_shape.emplace_back(outNum_[i]);
    out_shape.emplace_back(outChannel_[i]);
    out_shape.emplace_back(outHeight_[i]);
    out_shape.emplace_back(outWidth_[i]);
    outputShape_.emplace_back(out_shape);
    LOG(INFO) << "output shape " << outNum_[i];
    LOG(INFO) << "output shape " << outChannel_[i];
    LOG(INFO) << "output shape " << outHeight_[i];
    LOG(INFO) << "output shape " << outWidth_[i];
  }
}

Inferencer::~Inferencer() {
  setDeviceId(deviceId_);
}

void** Inferencer::popFreeInputData() { return freeInputFifo_.pop(); }
void** Inferencer::popValidInputData() { return validInputFifo_.pop(); }
void Inferencer::pushFreeInputData(void** data) { freeInputFifo_.push(data); }
void Inferencer::pushValidInputData(void** data) { validInputFifo_.push(data); }
cnrtQueue_t Inferencer::popValidAsyncCopyQueue() { return validAsyncCopyQueueFifo_.pop(); }
cnrtQueue_t Inferencer::popFreeAsyncCopyQueue() { return freeAsyncCopyQueueFifo_.pop(); }
void Inferencer::pushValidAsyncCopyQueue(cnrtQueue_t queue) {
    validAsyncCopyQueueFifo_.push(queue);
}
void Inferencer::pushFreeAsyncCopyQueue(cnrtQueue_t queue) { freeAsyncCopyQueueFifo_.push(queue); }
void** Inferencer::popFreeOutputData() { return freeOutputFifo_.pop(); }
void** Inferencer::popValidOutputData() { return validOutputFifo_.pop(); }
void Inferencer::pushFreeOutputData(void** data) { freeOutputFifo_.push(data); }
void Inferencer::pushValidOutputData(void** data) { validOutputFifo_.push(data);}

void Inferencer::pushValidInputNames(vector<pair<string, cv::Mat>> images) {
  imagesFifo_.push(images);
}

vector<pair<string, cv::Mat>> Inferencer::popValidInputNames() { return imagesFifo_.pop(); }

void Inferencer::pushValidInputDataAndNames(void** data,
                                            const vector<pair<string,
                                            cv::Mat>>& images) {
  std::lock_guard<std::mutex> lk(infr_mutex_);
  pushValidInputData(data);
  pushValidInputNames(images);
}

void Inferencer::pushValidInputDataAndNames(void** data,
                                            const vector<pair<string, cv::Mat>>& images,
                                            cnrtQueue_t queue) {
  std::lock_guard<std::mutex> lk(infr_mutex_);
  pushValidInputData(data);
  pushValidInputNames(images);
  pushValidAsyncCopyQueue(queue);
}

void Inferencer::simpleRun() {
// #define PINGPONG
#ifdef PINGPONG
#define RES_SIZE 2
#else
#define RES_SIZE 1
#endif

  // set device to runtime context binded device
  cnrtSetCurrentContextDevice(rt_ctx_);

  cnrtQueue_t queue[RES_SIZE];
  cnrtNotifier_t notifierBeginning[RES_SIZE];
  cnrtNotifier_t notifierEnd[RES_SIZE];

  for (int i = 0; i < RES_SIZE; i++) {
    // this queue is for sync copy, not for async copy
    if (!FLAGS_async_copy) {
    CHECK(cnrtCreateQueue(&queue[i]) == CNRT_RET_SUCCESS)
          << "CNRT create queue error, thread_id " << threadId();
    }
    cnrtCreateNotifier(&notifierBeginning[i]);
    cnrtCreateNotifier(&notifierEnd[i]);
  }
  float eventInterval[RES_SIZE] = {0};
  void** mluInData[RES_SIZE];
  void** mluOutData[RES_SIZE];
  TimePoint timepoints[RES_SIZE];

  auto do_pop = [&](int index, void **param) {
    mluInData[index] = popValidInputData();
    // this queue is for async copy, created in data provider
    if (FLAGS_async_copy) {
      queue[index] = popValidAsyncCopyQueue();
    }

    if ( mluInData[index] == nullptr )
      return false;
    mluOutData[index] = popFreeOutputData();
    for (int i = 0; i < inBlobNum(); i++) {
      param[i] = mluInData[index][i];
    }
    for (int i = 0; i < outBlobNum(); i++) {
      param[inBlobNum() + i] = mluOutData[index][i];
    }

    return true;
  };

  auto do_invoke = [&](int index, void** param) {
    cnrtPlaceNotifier(notifierBeginning[index], queue[index]);
    CNRT_CHECK(cnrtInvokeRuntimeContext(rt_ctx_, param, queue[index], nullptr));
    timepoints[index] = std::chrono::high_resolution_clock::now();
  };

  auto do_sync = [&](int index) {
    cnrtPlaceNotifier(notifierEnd[index], queue[index]);
    if (cnrtSyncQueue(queue[index]) == CNRT_RET_SUCCESS) {
      cnrtNotifierDuration(notifierBeginning[index],
             notifierEnd[index], &eventInterval[index]);
      inferencingTime_ += eventInterval[index];
      printfMluTime(eventInterval[index]);
    } else {
      LOG(ERROR) << " SyncQueue error";
    }
    pushValidOutputData(mluOutData[index]);
    pushFreeInputData(mluInData[index]);
    // this queue is for async copy
    if (FLAGS_async_copy) {
      pushFreeAsyncCopyQueue(queue[index]);
    }

    TimePoint t2 = std::chrono::high_resolution_clock::now();
    auto timetrace = popValidInputTimeTraceData();
    timetrace->compute_start = timepoints[index];
    timetrace->compute_end = t2;
    pushValidOutputTimeTraceData(timetrace);
  };

#ifdef PINGPONG
  bool pong_valid = false;
  while (true) {
    void* param[inBlobNum() + outBlobNum()];

    // pop - ping
    if (do_pop(0, static_cast<void **>(param)) == false) {
      if (pong_valid)
        do_sync(1);
      break;
    }
    // invoke - ping
    do_invoke(0, static_cast<void **>(param));

    // sync - pong
    if (pong_valid)
      do_sync(1);

    // pop - pong
    if (do_pop(1, static_cast<void **>(param)) == false) {
      do_sync(0);
      break;
    }

    // invoke - pong
    do_invoke(1, static_cast<void **>(param));
    pong_valid = true;

    // sync - ping
    do_sync(0);
  }
#else
  while (true) {
    void* param[inBlobNum() + outBlobNum()];
    // pop - ping
    if (do_pop(0, static_cast<void **>(param)) == false) {
      break;
    }
    // invoke - ping
    do_invoke(0, static_cast<void **>(param));

    // sync - ping
    do_sync(0);
  }
#endif

  for (int i = 0; i < RES_SIZE; i++) {
    cnrtDestroyNotifier(&notifierBeginning[i]);
    cnrtDestroyNotifier(&notifierEnd[i]);
    // this queue is for sync copy, not for async copy
    if (!FLAGS_async_copy) {
      cnrtDestroyQueue(queue[i]);
    }
  }

  // tell postprocessor to exit
}


void PostProcessor::run() {
  setDeviceId(deviceId_);
  Inferencer* infr = inferencer_;  // avoid line wrap

  vector<string> labelNameMap;
  if (!FLAGS_labels.empty()) {
    std::ifstream labels(FLAGS_labels);
    string line;
    while (std::getline(labels, line)) {
      labelNameMap.emplace_back(line);
    }
    labels.close();
  }

  int64_t *outputSizeS = nullptr;
  int outputNum = infr->outBlobNum();
  cnrtGetOutputDataSize(&outputSizeS, &outputNum, infr->function());
  cnrtDataType_t* output_data_type = nullptr;
  cnrtGetOutputDataType(&output_data_type, &outputNum, infr->function());
  vector<vector<int>> output_shapes = infr->outputshape();
  int dim_order[4] = {0, 3, 1, 2};

  int outCount_ = infr->outCount()[0];
  void** outCpuPtrs = new(void*);
  outCpuPtrs[0] = new float[outCount_];
  void** outTrans = new(void*);
  outTrans[0] = new float[outCount_];
  void** cpuOutTempData = new(void*);
  if (output_data_type[0] == CNRT_FLOAT16) {
    cpuOutTempData[0] = new char[outCount_ * 2];
  } else {
    cpuOutTempData[0] = new char[outCount_ * 4];
  }


  int TASK_NUM = SimpleInterface::thread_num;
  zl::ThreadPool tp(SimpleInterface::thread_num);
  while (true) {
    Timer postProcess;
    std::unique_lock<std::mutex> lock(post_mutex_);
    void** mluOutData = infr->popValidOutputData();
    if (nullptr == mluOutData) {
      lock.unlock();
      break;  // no more data to process
    }
    auto&& origin_img = infr->popValidInputNames();
    lock.unlock();
    TimePoint t1 = std::chrono::high_resolution_clock::now();
    for (int i=0; i < outputNum; i++) {
      cnrtMemcpy(cpuOutTempData[i],
                 mluOutData[i],
                 outputSizeS[i],
                 CNRT_MEM_TRANS_DIR_DEV2HOST);
      if (output_data_type[i] != CNRT_FLOAT32) {
        int output_count = infr->outCount()[i];
        cnrtCastDataType(cpuOutTempData[i],
                         output_data_type[i],
                         outTrans[i],
                         CNRT_FLOAT32,
                         output_count,
                         nullptr);
      } else {
        memcpy(outTrans[i], cpuOutTempData[i], outputSizeS[i]);
      }

      int dim_shape[4] = {output_shapes[i][0], output_shapes[i][2],
                          output_shapes[i][3], output_shapes[i][1]};
      cnrtTransDataOrder(outTrans[i], CNRT_FLOAT32, outCpuPtrs[i],
                         4, dim_shape, dim_order);
    }
    infr->pushFreeOutputData(mluOutData);
    TimePoint t2 = std::chrono::high_resolution_clock::now();
    auto timetrace = infr->popValidOutputTimeTraceData();
    timetrace->out_start = t1;
    timetrace->out_end = t2;
    this->appendTimeTrace(*timetrace);
    infr->pushFreeInputTimeTraceData(timetrace);

    vector<vector<vector<float>>> final_boxes(infr->n());
    vector<vector<int>> outShapeVec = infr->outputshape();
    int outShape = outShapeVec[0][0];
    int sBatchsize = infr->outCount()[0] / infr->n();
    int batchSize = outShape;
    // output data
    float* outputData = reinterpret_cast<float*>(outCpuPtrs[0]);
    int numBoxFinal = 0;
    float max_limit = 1;
    float min_limit = 0;

    for (int i = 0; i < batchSize; i++) {
      numBoxFinal = (int)outputData[i*sBatchsize];
      for (int k = 0; k < numBoxFinal ;  k++) {
        vector<float> single_box;
        int batchNum = outputData[i * sBatchsize + 64 + k * 7];
        if ((batchNum < 0) || (batchNum >= batchSize)) {
          continue;
        }
        float bl = std::max(min_limit,
                            std::min(max_limit,
                                     outputData[i * sBatchsize + 64 + k * 7 + 3]));
        float bt = std::max(min_limit,
                            std::min(max_limit,
                                     outputData[i * sBatchsize + 64 + k * 7 + 4]));
        float br = std::max(min_limit,
                            std::min(max_limit,
                                     outputData[i * sBatchsize + 64 + k * 7 + 5]));
        float bb = std::max(min_limit,
                            std::min(max_limit,
                                     outputData[i * sBatchsize + 64 + k * 7 + 6]));
        single_box.emplace_back(bl);
        single_box.emplace_back(bt);
        single_box.emplace_back(br);
        single_box.emplace_back(bb);
        single_box.emplace_back(outputData[i * sBatchsize + 64 + k * 7 + 2]);
        single_box.emplace_back(outputData[i * sBatchsize + 64 + k * 7 + 1]);
        if ((br - bl) > 0 && (bb - bt) > 0) {
          final_boxes[batchNum].emplace_back(single_box);
        }
      }
    }
    vector<cv::Mat> imgs;
    vector<string> img_names;
    Timer dumpTimer;
    if (FLAGS_dump && !FLAGS_perf_mode) {
      for (auto img_name : origin_img) {
        if (img_name.first != "null") {
          cv::Mat img;
          if (FLAGS_yuv) {
            cv::Size size = cv::Size(infr->w(), infr->h());
            img = yuv420sp2Bgr24(convertYuv2Mat(img_name.first, size));
          } else {
            img = img_name.second;;
          }
          imgs.emplace_back(img);
          img_names.emplace_back(img_name.first);
        }
      }
      int input_dim = FLAGS_yuv? 416: infr->h();

      const int size = imgs.size();
      if (TASK_NUM > size) {
          TASK_NUM = size;
      }
      const int delta = size / TASK_NUM;
      int from = 0;
      int to = delta;
      for (int i = 0; i < TASK_NUM; i++) {
        from = delta * i;
        if (i == TASK_NUM - 1) {
            to = size;
        } else {
            to = delta * (i + 1);
        }
        tp.add([](const vector<cv::Mat>& imgs,
                    const vector<vector<vector<float>>>& final_boxes,
                    const vector<string>& labelNameMap,
                    const vector<string>& img_names,
                    const int input_dim, const int& from, const int& to) {
                WriteVisualizeBBox_offline(imgs, final_boxes,
                        labelNameMap, img_names, input_dim, from, to);
                }, imgs, final_boxes, labelNameMap, img_names, input_dim, from, to);
      }
    }
    dumpTimer.log("dump out time ...");
    postProcess.log("post process time ...");
  }
  delete[] static_cast<float*>(outCpuPtrs[0]);
  delete outCpuPtrs;
  delete[] static_cast<float*>(outTrans[0]);
  delete outTrans;
  delete[] static_cast<char*>(cpuOutTempData[0]);
  delete cpuOutTempData;
}

class Pipeline {
  public:
  Pipeline(const string& offlinemodel,
           const string& meanValue, const int& id,
           const int& deviceId, const int& devicesize,
           queue<string> images);
  Pipeline(const string& offlinemodel,
           const string& meanValue, const int& id,
           const int& deviceId, const int& devicesize,
           const vector<queue<string>> &images);
  ~Pipeline();
  void run();
  inline DataProvider* dataProvider() { return data_provider_; }
  inline Inferencer* inferencer() { return inferencer_; }
  inline PostProcessor* postProcessor() { return postProcessor_; }
  inline vector<PostProcessor*> postProcessors() { return postProcessors_; }

  private:
  vector<DataProvider*> data_providers_;
  DataProvider* data_provider_;
  Inferencer* inferencer_;
  PostProcessor* postProcessor_;
  vector<PostProcessor*> postProcessors_;
};

Pipeline::Pipeline(const string& offlinemodel,
                   const string& meanValue, const int& id,
                   const int& deviceId, const int& devicesize,
                   queue<string> images) {
  auto& simpleInterface = SimpleInterface::getInstance();
  auto dev_runtime_contexts = simpleInterface.get_runtime_contexts();
  inferencer_ = new Inferencer(dev_runtime_contexts[deviceId][id / devicesize], id);
  data_provider_ = new DataProvider(meanValue, deviceId, images);
  postProcessor_ = new PostProcessor(deviceId);

  data_provider_->setInferencer(inferencer_);
  postProcessor_->setInferencer(inferencer_);
  inferencer_->setPostProcessor(postProcessor_);

  data_provider_->setThreadId(id);
  postProcessor_->setThreadId(id);
  inferencer_->setThreadId(id);
}

Pipeline::Pipeline(const string& offlinemodel,
                   const string& meanValue, const int& id,
                   const int& deviceId, const int& devicesize,
                   const vector<queue<string>> &images)
                   : data_providers_(SimpleInterface::data_provider_num_),
                     data_provider_(nullptr),
                     inferencer_(nullptr),
                     postProcessors_(SimpleInterface::postProcessor_num_) {
  auto& simpleInterface = SimpleInterface::getInstance();
  auto dev_runtime_contexts = simpleInterface.get_runtime_contexts();
  inferencer_ = new Inferencer(dev_runtime_contexts[id % devicesize][id / devicesize], id);
  inferencer_->setThreadId(id);

  int data_provider_num = SimpleInterface::data_provider_num_;
  int postProcessor_num = SimpleInterface::postProcessor_num_;
  for (int i = 0; i < data_provider_num ; i++) {
    data_providers_[i] = new DataProvider(meanValue, deviceId,
                                          images[data_provider_num * id + i]);
    data_providers_[i]->setInferencer(inferencer_);
    data_providers_[i]->setThreadId(id);
  }

  for (int i = 0; i < postProcessor_num; i++) {
    postProcessors_[i] = new PostProcessor(deviceId);
    postProcessors_[i]->setInferencer(inferencer_);
    postProcessors_[i]->setThreadId(id);
  }
}
Pipeline::~Pipeline() {
  for (auto data_provider : data_providers_) {
    delete data_provider;
  }

  for (auto postProcessor : postProcessors_) {
    delete postProcessor;
  }

  if (inferencer_) {
    delete inferencer_;
  }
}

void Pipeline::run() {
  int data_provider_num = 4;
  int postProcessor_num = 1;
  data_provider_num = data_providers_.size();
  postProcessor_num = postProcessors_.size();
  vector<thread*> threads(data_provider_num + postProcessor_num + 1, nullptr);

  for (int i = 0; i < data_provider_num; i++) {
    threads[i] = new thread(&DataProvider::run, data_providers_[i]);
  }
  threads[data_provider_num] = new thread(&Inferencer::simpleRun, inferencer_);

  for (int i = 0; i < postProcessor_num; i++) {
    threads[data_provider_num + 1 + i] = new thread(&PostProcessor::run, postProcessors_[i]);
  }

  for (int i = 0; i < data_provider_num; i++) {
    threads[i]->join();
    delete threads[i];
  }

  // push a nullptr for simple compile when the thread of data provider finished tasks
  inferencer_->pushValidInputData(nullptr);
  if (FLAGS_async_copy) {
    inferencer_->pushValidAsyncCopyQueue(nullptr);
  }

  threads[data_provider_num]->join();
  delete threads[data_provider_num];

  for (int i = 0; i < postProcessor_num; i++)
    inferencer_->pushValidOutputData(nullptr);

  for (int i = 0; i < postProcessor_num; i++) {
    threads[data_provider_num + 1 + i]->join();
    delete threads[data_provider_num + 1 + i];
  }
}

int main(int argc, char* argv[]) {
  {
    const char* env = getenv("log_prefix");
    if (!env || strcmp(env, "true") != 0) FLAGS_log_prefix = false;
  }
  ::google::InitGoogleLogging(argv[0]);
#ifndef GFLAGS_GFLAGS_H_
  namespace gflags = google;
#endif
  gflags::SetUsageMessage(
      "Do detection using yolov4 mode.\n"
      "Usage:\n"
      "    yolov4_offline_multicore [FLAGS] model_file list_file\n");
  gflags::ParseCommandLineFlags(&argc, &argv, true);
  if (argc == 0) {
    gflags::ShowUsageWithFlagsRestrict(
        argv[0], "examples/yolo_v4/yolov4_offline_multicore");
    return 1;
  }

  auto& simpleInterface = SimpleInterface::getInstance();
  int provider_num = 1;
  simpleInterface.setFlag(true);
  provider_num = SimpleInterface::data_provider_num_;

  if (FLAGS_logdir != "") {
    FLAGS_log_dir = FLAGS_logdir;
  } else {
    //  log to terminal's stderr if no log path specified
    FLAGS_alsologtostderr = 1;
  }

  std::ifstream files_tmp(FLAGS_images.c_str(), std::ios::in);
  // get device ids
  std::stringstream sdevice(FLAGS_mludevice);
  vector<int> deviceIds_;
  std::string item;
  while (getline(sdevice, item, ',')) {
    int device = std::atoi(item.c_str());
    deviceIds_.emplace_back(device);
  }
  int totalThreads = FLAGS_threads * deviceIds_.size();
  int imageNum = 0;
  vector<string> files;
  std::string line_tmp;
  vector<queue<string>> imageList(totalThreads * provider_num);
  if (files_tmp.fail()) {
    LOG(ERROR) << "open " << FLAGS_images << " file fail!";
    return 1;
  } else {
    while (getline(files_tmp, line_tmp)) {
      line_tmp = FLAGS_dataset_path + '/' + line_tmp;
      imageList[imageNum % (totalThreads * provider_num)].push(line_tmp);
      imageNum++;
    }
  }
  files_tmp.close();

  if (FLAGS_perf_mode) {
    // calculate number of fake image per thread
    FLAGS_perf_mode_img_num = FLAGS_perf_mode_img_num / (totalThreads * provider_num);
  }

  LOG(INFO) << "there are " << imageNum << " figures in " << FLAGS_images;

  cnrtInit(0);
  simpleInterface.loadOfflinemodel(FLAGS_offlinemodel,
                                   deviceIds_,
                                   FLAGS_channel_dup,
                                   FLAGS_threads);

  vector<thread*> stageThreads;
  vector<Pipeline*> pipelineVector;
  for (int i = 0; i < totalThreads; i++) {
    Pipeline* pipeline;
    if (imageList.size()) {
      pipeline = new Pipeline(
          FLAGS_offlinemodel, FLAGS_meanvalue, i,
          deviceIds_[i % deviceIds_.size()], deviceIds_.size(),
          imageList);
    }


    stageThreads.emplace_back(new thread(&Pipeline::run, pipeline));
    pipelineVector.emplace_back(pipeline);
  }

  float execTime;
  struct timeval tpend, tpstart;
  gettimeofday(&tpstart, NULL);
  {
    std::lock_guard<std::mutex> lk(condition_m);
    LOG(INFO) << "Notify to start ...";
  }
  start = 1;
  condition.notify_all();
  for (int i = 0; i < stageThreads.size(); i++) {
    stageThreads[i]->join();
    delete stageThreads[i];
  }
  gettimeofday(&tpend, NULL);
  execTime = 1000000 * (tpend.tv_sec - tpstart.tv_sec) + tpend.tv_usec -
             tpstart.tv_usec;
  LOG(INFO) << "yolov4_detection() execution time: " << execTime << " us";
  float mluTime = 0;
  for (int i = 0; i < pipelineVector.size(); i++) {
    mluTime += pipelineVector[i]->inferencer()->inferencingTime();
  }

  int batch_size = pipelineVector[0]->inferencer()->n();

  std::vector<InferenceTimeTrace> timetraces;
  for (auto iter : pipelineVector) {
    for (auto pP : iter->postProcessors()) {
      for (auto tc : pP->timeTraces()) {
        timetraces.emplace_back(tc);
      }
    }
  }
  printPerfTimeTraces(timetraces, batch_size, mluTime);
  saveResultTimeTrace(timetraces, (-1), (-1), (-1), imageNum, batch_size, mluTime);

  for (auto iter : pipelineVector)
    delete iter;

  simpleInterface.destroyRuntimeContext();
  cnrtDestroy();
}

#else
#include "caffe/common.hpp"
int main(int argc, char* argv[]) {
  LOG(FATAL) << "This program should be compiled with the defintion"
             << " of both USE_MLU and USE_OPENCV!";
  return 0;
}
#endif  // USE_MLU
