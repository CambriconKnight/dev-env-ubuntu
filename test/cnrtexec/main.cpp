#include <atomic>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <list>
#include <cmath>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <algorithm>
#include <queue>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>
#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>
#include "cnrtexec.h"

using namespace std;

class SpinMutex
{
private:
    atomic_flag flag = ATOMIC_FLAG_INIT;
public:
    void lock();
    void unlock();
};

void SpinMutex::lock()
{
    while (flag.test_and_set(memory_order_acquire));
}

void SpinMutex::unlock()
{
    flag.clear(std::memory_order_release);
}

template <typename  T>
class SharedQueue
{
public:
    SharedQueue(int max=32);
    void clear();
    T* pop();
    bool empty() const;
    int size() const;
    bool push(T* item);
private:
    mutable SpinMutex mtx;
    std::queue<T* > que;
    int maxsz;
};

template <typename  T>
SharedQueue<T>::SharedQueue(int max):maxsz(max)
{

}

template <typename  T>
void SharedQueue<T>::clear()
{
    std::lock_guard<SpinMutex> lk(mtx);
    while (que.size() > 0) que.pop();
}

template <typename  T>
T* SharedQueue<T>::pop()
{
    std::lock_guard<SpinMutex> lk(mtx);
    if (que.empty())
        return nullptr;
    T *item = que.front();
    que.pop();
    return item;
}

template <typename  T>
bool SharedQueue<T>::empty() const
{
    std::lock_guard<SpinMutex> lk(mtx);
    return que.empty();
}

template <typename  T>
int SharedQueue<T>::size() const
{
    std::lock_guard<SpinMutex> lk(mtx);
    return que.size();
}

template <typename  T>
bool SharedQueue<T>::push(T* item)
{
    std::lock_guard<SpinMutex> lk(mtx);
    if (maxsz > 0 && que.size() >= maxsz) return false;
    que.push(item);
    return true;
}

struct BatchData
{
	float* data;
	vector<int>labels;
};

template class SharedQueue<BatchData>;
static SharedQueue<BatchData> input_queue(1000000);
static SpinMutex g_spin_mtx;

static mutex g_mtx;
static bool bRunning=false;
static bool bStart=false;
static int nTaskCount=8;
static unsigned int gTaskCount=0;
static float correct=0;
static float total=0;
static float hwtime=0;

static void IncCorrect()
{
	std::lock_guard<SpinMutex> lk(g_spin_mtx);
	correct++;
}

static void wait()
{
    g_mtx.lock();
    gTaskCount++;
    g_mtx.unlock();
    while(!bStart){usleep(10);}
}

int dev_id;

static double GetTickCount()
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (ts.tv_sec * 1000000 + ts.tv_nsec / 1000)/1000000.0;
}

static void PredictTask(int channel,string offline_model,string function_name)
{
	MLUInfer infer;
	infer.Open(offline_model,function_name,channel,dev_id);
	int h=infer.input_width;
	int w=infer.input_height;	
	int n=infer.batch_size;
	
	int output_count=infer.total_output_count;
	int feature_size=output_count/n;
	
	float *output=new float[output_count];
	
	wait();	
	
    while(bRunning)
    {
        BatchData* block=input_queue.pop();
        if(!block)
        {
            break;
        }		
		infer.Detect(block->data,output,hwtime,output_count*sizeof(float));
		//delete []block->data;
    }
	delete []output;
}

int main(int argc,char *argv[])
{
	if(argc<6)
	{
		printf("Usage:%s offline_model dev_id sample_count nTaskCount affinity\n",argv[0]);
		return -1;
	}
	
	if(access(argv[1],F_OK))
	{
		printf("offline_model invalid\n");
		return -1;
	}

	unsigned int dev_num=0;
	CNRT_CHECK(cnrtInit(0));  
	CNRT_CHECK(cnrtGetDeviceCount(&dev_num));
    if (dev_num == 0)
        return -1;
	
	string offline_model=argv[1];
	string function_name="subnet0";
	dev_id=atoi(argv[2]);
	int sample_count=atoi(argv[3]);
	nTaskCount=atoi(argv[4]);	
	int affinity=atoi(argv[5]);	
	
	if(argc==7)
	{
		function_name=argv[6];
	}
	int n,h,w,c;
	
	{
		MLUInfer infer;
		infer.Open(offline_model,function_name,0,dev_id);
		h=infer.input_width;
		w=infer.input_height;
		n=infer.batch_size;
	}	
	
	std::vector<std::thread*> inferTasks;
	
	for(int j=0;j<nTaskCount;j++)
    {		
        inferTasks.push_back(new std::thread(PredictTask,(affinity>0)?(j%4):-1,offline_model,function_name));
    }

	for(int j=0;j<sample_count;j++)
	{		
		BatchData *block = new BatchData();
		//block->data=new float[n*h*w*4];
		input_queue.push(block); 
		total+=n;
	}	

	while(gTaskCount!=nTaskCount){usleep(10);}

	auto t0=GetTickCount();
	bRunning=true;
	bStart=true;
	
	for(auto task:inferTasks)
	{
		task->join();
		delete task;
	}
	auto t1=GetTickCount();
	
	printf("Model:%s Batch:%d HwTime:%f(ms) FPS:%f [ samples:%f usetime:%f(s) ]\n",offline_model.c_str(),n,hwtime/1000,total/(t1-t0),total,t1-t0);
	return 0;

}


