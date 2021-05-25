#ifndef CNRT_EXEC_H
#define CNRT_EXEC_H

#include <pthread.h>
#include <sys/time.h>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <thread>
#include <iostream>
#include <string.h>
#include <fstream>
#include <vector>
#include <iomanip>
#include <algorithm>
#include <iosfwd>
#include <memory>
#include <utility>
#include <mutex>
#include <semaphore.h>
#include <iomanip>
#include <iosfwd>
#include <memory>
#include <string>
#include <map>
#include <utility>
#include <vector>
#include <fstream>
#include "cnrt.h"

using namespace std;

class MLUInfer
{
public:
    MLUInfer();
    ~MLUInfer();
	
    int Open(string model_path,string function_name,int channel,int id);
	float* Detect(void *data,float* res, float &hwtime,int size = 0);
	
	int input_width;
	int input_height;
	int64_t *inputSizeS,*outputSizeS;	
	cnrtDataType_t *inputTypeS,*outputTypeS;
	int         batch_size;
	int         total_output_count;
private:
    unsigned    dev_num;
    unsigned    dev_id;
	int         m_channel;
	unsigned int affinity=-1;
	
	cnrtInvokeParam_t priv_param;
    bool        b_use_first_conv;    

    cnrtQueue_t queue;
	
    cnrtModel_t model;
    cnrtFunction_t function;
    cnrtDev_t dev;
	cnrtRuntimeContext_t ctx;

	int *dimValues;
	int dimNum;
	
    int inputNum;
    int outputNum;

    void **param;
    void **inputCpuPtrS;
    void **outputCpuPtrS;
	void **outputCpuNchwPtrS;

    void **inputMluPtrS;
    void **outputMluPtrS;
	
	vector<int> output_count;
	cnrtNotifier_t notifier_start, notifier_end;
};

#endif
