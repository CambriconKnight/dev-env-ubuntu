#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <string>
#include <vector>
#include "cnrt.h"
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>

#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>

using namespace std;
using namespace cv;

double GetTickCount()
{
        struct timespec ts;
        clock_gettime(CLOCK_MONOTONIC, &ts);
        return (ts.tv_sec * 1000000 + ts.tv_nsec / 1000) / 1000.0;
}

void writeVisualizeBBox(const vector<cv::Mat> &images, vector<vector<vector<float>>> &detections, int input_dim, const int from, const int to, const char *output_fileame)
{

        int font_face = cv::FONT_HERSHEY_COMPLEX;
        double font_scale = 0.4;
        int thickness = 0.4;
        int baseline;
        // Retrieve detections.
        for (int i = from; i < to; ++i)
        {
                cv::Mat image = images[i];
                vector<vector<float>> result = detections[i];
                for (int j = 0; j < result.size(); j++)
                {
                        result[j][0] = result[j][0] * image.cols;
                        result[j][2] = result[j][2] * image.cols;
                        result[j][1] = result[j][1] * image.rows;
                        result[j][3] = result[j][3] * image.rows;
                }

                for (int j = 0; j < result.size(); j++)
                {
                        result[j][0] = result[j][0] < 0 ? 0 : result[j][0];
                        result[j][2] = result[j][2] < 0 ? 0 : result[j][2];
                        result[j][1] = result[j][1] < 0 ? 0 : result[j][1];
                        result[j][3] = result[j][3] < 0 ? 0 : result[j][3];
                        result[j][0] = result[j][0] > image.cols ? image.cols : result[j][0];
                        result[j][2] = result[j][2] > image.cols ? image.cols : result[j][2];
                        result[j][1] = result[j][1] > image.rows ? image.rows : result[j][1];
                        result[j][3] = result[j][3] > image.rows ? image.rows : result[j][3];
                }
                for (int j = 0; j < result.size(); j++)
                {
                        int x0 = static_cast<int>(result[j][0]);
                        int y0 = static_cast<int>(result[j][1]);
                        int x1 = static_cast<int>(result[j][2]);
                        int y1 = static_cast<int>(result[j][3]);

                        int cls = static_cast<int>(result[j][5]);

                        cv::Point p1(x0, y0);
                        cv::Point p2(x1, y1);
                        printf("%d %d %d %d\n", x0, y0, x1, y1);
                        cv::rectangle(image, p1, p2, cv::Scalar(0, 255, 0), 1);
                        cv::putText(image, "obj", p1, font_face, font_scale, cv::Scalar(0, 0, 255), thickness, 0.4, 0);
                }

                stringstream ss;
                string outFile;
                ss << "cnrt_output_" << i << ".jpg";
                ss >> outFile;
                cv::imwrite(output_fileame, image);
                break;
        }
}

int main(int argc, char *argv[])
{
        unsigned int dev_num = 0;
        CNRT_CHECK(cnrtInit(0));
        CNRT_CHECK(cnrtGetDeviceCount(&dev_num));
        if (dev_num == 0)
                return -1;

        const char *model_path = argv[1];          //????????????
        const char *function_name = "subnet0"; //??????????????????Function Name
        unsigned dev_id = 0;                               //?????????MLU ??????ID
        int dev_channel = 0;                               //??????MLU?????????????????? -1 ???????????????
        const char *image_path = argv[2];          //?????????????????????
        const char *output_path = argv[3];         //?????????????????????

        int input_width;  //?????????????????????
        int input_height; //?????????????????????
        int batch_size;   //?????????batch

        int64_t *inputSizeS;  //????????????????????????,??????????????????
        int64_t *outputSizeS; //???????????????????????????,??????????????????

        cnrtDataType_t *inputTypeS;      //???????????????????????????
        cnrtDataType_t *outputTypeS; //???????????????????????????

        vector<int> output_count;

        cnrtQueue_t queue; //cnrt queue

        cnrtModel_t model;                //????????????
        cnrtFunction_t function;  //??????????????????Function
        cnrtDev_t dev;                    //MLU????????????
        cnrtRuntimeContext_t ctx; //???????????????

        int *dimValues; //????????????shape
        int dimNum;             //??????????????????

        int inputNum;  //??????????????????
        int outputNum; //??????????????????

        void **param;                     //???????????????,mlu????????????????????????
        void **inputCpuPtrS;      //???????????????CPU??????
        void **inputCpuPtrFp32S;  //???????????????CPU??????
        void **outputCpuPtrS;     //???????????????CPU??????
        void **outputCpuNchwPtrS; //????????????transpose??????NCHW??????

        void **inputMluPtrS;  //???????????????MLU??????
        void **outputMluPtrS; //???????????????MLU??????

        cnrtNotifier_t notifier_start; //????????????????????????
        cnrtNotifier_t notifier_end;
        unsigned int affinity = 1 << dev_channel; //?????????????????????,???????????????MLU cluster?????????
        cnrtInvokeParam_t invokeParam;                    //invoke??????

        int output_channel;
        //???????????????????????????
        CNRT_CHECK(cnrtGetDeviceHandle(&dev, dev_id));

        //???????????????????????????,????????????????????????
        CNRT_CHECK(cnrtSetCurrentDevice(dev));

        //??????????????????
        CNRT_CHECK(cnrtLoadModel(&model, model_path));

        //??????function
        CNRT_CHECK(cnrtCreateFunction(&function));

        //?????????????????????????????????function,??????????????????????????????function
        CNRT_CHECK(cnrtExtractFunction(&function, model, function_name));

        //??????cnrtSetCurrentChannel?????? CNRT ??????????????????????????????MLU??????,?????????????????????????????????
        if (dev_channel >= 0)
                CNRT_CHECK(cnrtSetCurrentChannel((cnrtChannelType_t)dev_channel));
		
        //???????????????
        CNRT_CHECK(cnrtCreateRuntimeContext(&ctx, function, NULL));

        //??????????????????????????????ID
        CNRT_CHECK(cnrtSetRuntimeContextDeviceId(ctx, dev_id));

        //??????????????????
        CNRT_CHECK(cnrtInitRuntimeContext(ctx, NULL));

        //????????????
        CNRT_CHECK(cnrtRuntimeContextCreateQueue(ctx, &queue));

        //??????????????????/?????? ??????????????????????????????
        CNRT_CHECK(cnrtGetInputDataSize(&inputSizeS, &inputNum, function));
        CNRT_CHECK(cnrtGetOutputDataSize(&outputSizeS, &outputNum, function));

        //??????????????????/?????? ???????????????
        CNRT_CHECK(cnrtGetInputDataType(&inputTypeS, &inputNum, function));
        CNRT_CHECK(cnrtGetOutputDataType(&outputTypeS, &outputNum, function));

        //?????? ??????CPU?????????/??????????????? ????????????
        inputCpuPtrS = (void **)malloc(sizeof(void *) * inputNum);
        inputCpuPtrFp32S = (void **)malloc(sizeof(void *) * inputNum);
        outputCpuPtrS = (void **)malloc(sizeof(void *) * outputNum);
        outputCpuNchwPtrS = (void **)malloc(sizeof(void *) * outputNum);

        //?????? ??????MLU?????????/??????????????? ????????????
        outputMluPtrS = (void **)malloc(sizeof(void *) * outputNum);
        inputMluPtrS = (void **)malloc(sizeof(void *) * inputNum);

        //??????????????? ??????CPU/MLU??????
        for (int i = 0; i < inputNum; i++)
        {
                CNRT_CHECK(cnrtMalloc(&inputMluPtrS[i], inputSizeS[i])); //??????MLU?????????
                inputCpuPtrS[i] = (void *)malloc(inputSizeS[i]);                 //??????CPU????????????
                inputCpuPtrFp32S[i] = (void *)malloc(inputSizeS[i] * 2); //??????CPU????????????

                //??????????????????????????? NHWC
                CNRT_CHECK(cnrtGetInputDataShape(&dimValues, &dimNum, i, function));
                //printf("input shape:\n");
                for (int y = 0; y < dimNum; y++)
                {
                        //printf("%d ", dimValues[y]);
                }
                //printf("\n");

                input_width = dimValues[2];
                input_height = dimValues[1];
                batch_size = dimValues[0];
                free(dimValues);
        }

        //??????????????? ??????CPU/MLU??????
        for (int i = 0; i < outputNum; i++)
        {
                CNRT_CHECK(cnrtMalloc(&outputMluPtrS[i], outputSizeS[i])); //??????MLU?????????
                outputCpuPtrS[i] = (void *)malloc(outputSizeS[i]);                 //??????CPU????????????

                //??????????????????????????? NHWC
                CNRT_CHECK(cnrtGetOutputDataShape(&dimValues, &dimNum, i, function));
                int count = 1;
                //printf("output shape:\n");
                for (int y = 0; y < dimNum; y++)
                {
                        //printf("%d ", dimValues[y]);
                        count = count * dimValues[y];
                }
                output_channel = dimValues[3];

                //printf("\n");
                outputCpuNchwPtrS[i] = (void *)malloc(count * sizeof(float)); //???????????????float32??????,?????????????????????
                output_count.push_back(count);
                free(dimValues);
        }

        //????????????
        CNRT_CHECK(cnrtRuntimeContextCreateNotifier(ctx, &notifier_start));
        CNRT_CHECK(cnrtRuntimeContextCreateNotifier(ctx, &notifier_end));

        //??????MLU??????/?????? ???????????????
        param = (void **)malloc(sizeof(void *) * (inputNum + outputNum));
        for (int i = 0; i < inputNum; i++)
        {
                param[i] = inputMluPtrS[i];
        }
        for (int i = 0; i < outputNum; i++)
        {
                param[i + inputNum] = outputMluPtrS[i];
        }

        //??????invoke?????????
        invokeParam.invoke_param_type = CNRT_INVOKE_PARAM_TYPE_0;
        invokeParam.cluster_affinity.affinity = &affinity;

        //????????????/??????????????? ??????
        int input_idx = 0;
        int output_idx = 0;

        unsigned char *ptr = (unsigned char *)inputCpuPtrS[input_idx];
        int is_rgb = 1;

        vector<cv::Mat> images;

        for (int i = 0; i < batch_size; i++)
        {
                cv::Mat input_image = cv::imread(image_path);
                cv::Mat input_image_resized;

                cv::resize(input_image, input_image_resized, cv::Size(input_width, input_height));
                images.push_back(input_image);

                cv::Mat image_rgb;
                cv::cvtColor(input_image_resized, image_rgb, CV_BGR2RGB);
                cv::Mat norm;
                image_rgb.convertTo(norm, CV_32F, 1.f / 255.f, 0);
                CNRT_CHECK(cnrtCastDataType(reinterpret_cast<void *>(norm.data),
                                                                        CNRT_FLOAT32,
                                                                        reinterpret_cast<void *>(ptr),
                                                                        inputTypeS[input_idx],
                                                                        inputSizeS[input_idx] / batch_size/2, nullptr));
                ptr += (input_height * input_width * 3 * 2);
        }

        //?????????????????????MLU??????
        auto t0 = GetTickCount();

        CNRT_CHECK(cnrtMemcpy(inputMluPtrS[input_idx], inputCpuPtrS[input_idx], inputSizeS[input_idx], CNRT_MEM_TRANS_DIR_HOST2DEV));

        CNRT_CHECK(cnrtPlaceNotifier(notifier_start, queue));
        CNRT_CHECK(cnrtInvokeRuntimeContext(ctx, param, queue, &invokeParam));
        CNRT_CHECK(cnrtPlaceNotifier(notifier_end, queue));
        CNRT_CHECK(cnrtSyncQueue(queue));

        //??????MLU?????????CPU??????
        CNRT_CHECK(cnrtMemcpy(outputCpuPtrS[output_idx], outputMluPtrS[output_idx], outputSizeS[output_idx], CNRT_MEM_TRANS_DIR_DEV2HOST));
        auto t1 = GetTickCount();

        float hwtime;
        CNRT_CHECK(cnrtNotifierDuration(notifier_start, notifier_end, &hwtime));
        //printf("HardwareTime:%f(ms) E2ETime:%f(ms)\n", hwtime / 1000.0, t1 - t0);

        CNRT_CHECK(cnrtCastDataType(reinterpret_cast<void *>(outputCpuPtrS[output_idx]),
                                                                outputTypeS[output_idx],
                                                                reinterpret_cast<void *>(outputCpuNchwPtrS[output_idx]),
                                                                CNRT_FLOAT32,
                                                                outputSizeS[output_idx] / 2, nullptr));

        //??????????????????
        float *outputData = (float *)outputCpuNchwPtrS[output_idx];
        vector<vector<vector<float>>> detections;

        float max_limit_w = 640;
        float max_limit_h = 512;
        float min_limit = 0;
        int count = output_channel;
        int keep_num = 1024;

        cv::Mat input_image = cv::imread(image_path);
        printf("---------\n");
        printf("%d %d\n", input_image.cols, input_image.rows);

        int num_boxes_final = outputData[0];
        for (int idx = 0; idx < batch_size; idx++)
        {
                int index = (64 + keep_num * 7) * idx;
                int num_boxes = static_cast<int>(outputData[index]);
                std::vector<std::vector<float>> batch_box;
                for (int i = 0; i < num_boxes; i++)
                {
                        if (idx == int(outputData[index + 64 + i * 7 + 0]))
                        {
                                int index = (64 + keep_num * 7) * idx;

                                std::vector<float> single_box;
                                float x1 = (std::max(min_limit, std::min(max_limit_w, outputData[index + 64 + i * 7 + 3])) / max_limit_w) ; 
                                float y1 = (std::max(min_limit, std::min(max_limit_h, outputData[index + 64 + i * 7 + 4])) / max_limit_h) ; 
                                float x2 = (std::max(min_limit, std::min(max_limit_w, outputData[index + 64 + i * 7 + 5])) / max_limit_w) ; 
                                float y2 = (std::max(min_limit, std::min(max_limit_h, outputData[index + 64 + i * 7 + 6])) / max_limit_h) ; 
                                
                                single_box.push_back(x1);
                                single_box.push_back(y1);
                                single_box.push_back(x2);
                                single_box.push_back(y2);

                                float score = outputData[index + 64 + i * 7 + 2];

                                single_box.push_back(score);
                                single_box.push_back(outputData[index + 64 + i * 7 + 1]);

                                //printf("bs:%d %f %f %f %f score:%f\n", idx, bl, bt, br, bb, score);
                                //if (score>0.5)
                                {
                                        //if ((br - bl) > 0 && (bb - bt) > 0)
                                        {
                                                batch_box.push_back(single_box);
                                        }
                                }
                        }
                }
                //printf("batch_box:%d\n", batch_box.size());
                detections.push_back(batch_box);
        }

        writeVisualizeBBox(images, detections, input_width, 0, images.size(), output_path);

        CNRT_CHECK(cnrtSetCurrentDevice(dev));
        CNRT_CHECK(cnrtDestroyQueue(queue));
        CNRT_CHECK(cnrtDestroyFunction(function));
        CNRT_CHECK(cnrtUnloadModel(model));

        cnrtDestroyNotifier(&notifier_start);
        cnrtDestroyNotifier(&notifier_end);

        for (int i = 0; i < inputNum; i++)
        {
                free(inputCpuPtrS[i]);
                cnrtFree(inputMluPtrS[i]);
        }
        for (int i = 0; i < outputNum; i++)
        {
                free(outputCpuPtrS[i]);
                free(outputCpuNchwPtrS[i]);
                cnrtFree(outputMluPtrS[i]);
        }

        free(param);
        free(inputCpuPtrS);
        free(outputCpuPtrS);
        cnrtDestroyRuntimeContext(ctx);

        return 0;
}
