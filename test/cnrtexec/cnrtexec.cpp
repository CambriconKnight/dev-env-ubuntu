#include "cnrtexec.h"

#undef CNRT_CHECK

#define CNRT_CHECK(condition)                        \
    do                                               \
    {                                                \
        cnrtRet_t status = condition;                \
        if (status != CNRT_RET_SUCCESS)              \
            printf("%s %d %s\n", __FUNCTION__,__LINE__,cnrtGetErrorStr(status)); \
    } while (0)

double GetTickCount()
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (ts.tv_sec * 1000000 + ts.tv_nsec / 1000);
}

MLUInfer::MLUInfer():total_output_count(0)
{

}

MLUInfer::~MLUInfer()
{
    CNRT_CHECK(cnrtSetCurrentDevice(dev));
    CNRT_CHECK(cnrtDestroyQueue(queue));
    CNRT_CHECK(cnrtDestroyFunction(function));
    CNRT_CHECK(cnrtUnloadModel(model));

	cnrtDestroyNotifier(&notifier_start);
	cnrtDestroyNotifier(&notifier_end);

    for (int i = 0; i < inputNum; i++) {
        free(inputCpuPtrS[i]);
		cnrtFree(inputMluPtrS[i]);
    }
    for (int i = 0; i < outputNum; i++) {
        free(outputCpuPtrS[i]);
        free(outputCpuNchwPtrS[i]);
		cnrtFree(outputMluPtrS[i]);
    }
	
    free(param);
    free(inputCpuPtrS);
    free(outputCpuPtrS);
	cnrtDestroyRuntimeContext(ctx);
}

int MLUInfer::Open(string model_path,string function_name,int channel,int id)
{    
	dev_id=id;	
	m_channel=channel;
			
    CNRT_CHECK(cnrtGetDeviceHandle(&dev, dev_id));
    CNRT_CHECK(cnrtSetCurrentDevice(dev));
	
	CNRT_CHECK(cnrtLoadModel(&model, model_path.c_str()));
    CNRT_CHECK(cnrtCreateFunction(&function));
    CNRT_CHECK(cnrtExtractFunction(&function,model,function_name.c_str()));
	CNRT_CHECK(cnrtCreateRuntimeContext(&ctx,function,NULL));

	uint64_t local_mem_size;
	uint64_t stack_size;

	CNRT_CHECK(cnrtQueryModelStackSize(model,&stack_size));
	CNRT_CHECK(cnrtQueryModelLocalMemSize(model,&local_mem_size));

	unsigned int Localsize;
	CNRT_CHECK(cnrtGetLocalMem(&Localsize));
	
	//指定了亲和性
	if(m_channel>=0)
	{
		affinity=(1<<m_channel);
		CNRT_CHECK(cnrtSetCurrentChannel((cnrtChannelType_t)m_channel));
		CNRT_CHECK(cnrtSetRuntimeContextChannel(ctx,(cnrtChannelType_t)m_channel));		
		priv_param.invoke_param_type=CNRT_INVOKE_PARAM_TYPE_0;
		priv_param.cluster_affinity.affinity=&affinity;
	}
    
    CNRT_CHECK(cnrtSetRuntimeContextDeviceId(ctx,id));
    CNRT_CHECK(cnrtInitRuntimeContext(ctx,NULL));

	CNRT_CHECK(cnrtRuntimeContextCreateQueue(ctx,&queue));
    
	CNRT_CHECK(cnrtGetInputDataSize(&inputSizeS,&inputNum,function));
	CNRT_CHECK(cnrtGetOutputDataSize(&outputSizeS,&outputNum,function));
	
	CNRT_CHECK(cnrtGetInputDataType(&inputTypeS,&inputNum,function));
	CNRT_CHECK(cnrtGetOutputDataType(&outputTypeS,&outputNum,function));
	
    inputCpuPtrS = (void **)malloc(sizeof(void *) * inputNum);
    outputCpuPtrS = (void **)malloc(sizeof(void *) * outputNum);
	outputCpuNchwPtrS = (void **)malloc(sizeof(void *) * outputNum);

    outputMluPtrS = (void **)malloc(sizeof(void *) * outputNum);
    inputMluPtrS = (void **)malloc(sizeof(void *) * inputNum);

	for (int i = 0; i < inputNum; i++) 
	{	
		CNRT_CHECK(cnrtMalloc(&inputMluPtrS[i],inputSizeS[i]));		
        inputCpuPtrS[i] = (void *)malloc(inputSizeS[i]);
		CNRT_CHECK(cnrtGetInputDataShape(&dimValues,&dimNum,i,function));	
						 
		//printf("input shape:\n");
		for(int y=0;y<dimNum;y++)
		{
			//printf("%d ",dimValues[y]);
		}
		input_width=dimValues[2];
		input_height=dimValues[1];
		batch_size=dimValues[0];
		//printf("\n");
                free(dimValues);
    }
	
	
    for (int i = 0; i < outputNum; i++) {
		CNRT_CHECK(cnrtMalloc(&outputMluPtrS[i],outputSizeS[i]));		
        outputCpuPtrS[i] = (void *)malloc(outputSizeS[i]);
		CNRT_CHECK(cnrtGetOutputDataShape(&dimValues,&dimNum,i,function));		
		//printf("outputSizeS[%d] :%ld output shape:\n",i,outputSizeS[i]);
		
		int count=1;
		for(int y=0;y<dimNum;y++)
		{
			//printf("%d ",dimValues[y]);
			count=count*dimValues[y];
		}
		total_output_count+=count;
		
		output_count.push_back(count);
		
		outputCpuNchwPtrS[i] = (void *)malloc(count*sizeof(float));
		//printf("\n");		
                free(dimValues);
    }

    CNRT_CHECK(cnrtRuntimeContextCreateNotifier(ctx,&notifier_start));
    CNRT_CHECK(cnrtRuntimeContextCreateNotifier(ctx,&notifier_end));

    param = (void **)malloc(sizeof(void *) * (inputNum + outputNum));
    for (int i = 0; i < inputNum; i++) {
        param[i] = inputMluPtrS[i];
    }
	
    for (int i = 0; i < outputNum; i++) {
        param[i + inputNum] = outputMluPtrS[i];
    }
	
	//warm up
	for(int i=0;i<3;i++)
	{		
		if(m_channel>=0)
			CNRT_CHECK(cnrtInvokeRuntimeContext(ctx,param,queue,&priv_param));
		else
			CNRT_CHECK(cnrtInvokeRuntimeContext(ctx,param,queue,nullptr));		
		CNRT_CHECK(cnrtSyncQueue(queue));		
	}
	return 0;
}

float* MLUInfer::Detect(void *data,float* res,float &hwtime, int size)
{
	int input_idx=0;
	
	CNRT_CHECK(cnrtSetCurrentDevice(dev));
	
#if 1
	CNRT_CHECK(cnrtMemcpy(inputMluPtrS[input_idx],inputCpuPtrS[input_idx] ,inputSizeS[input_idx],CNRT_MEM_TRANS_DIR_HOST2DEV));
#endif

	auto t0=GetTickCount();
    CNRT_CHECK(cnrtPlaceNotifier(notifier_start, queue));
	if(m_channel>=0)
		CNRT_CHECK(cnrtInvokeRuntimeContext(ctx,param,queue,&priv_param));
	else
		CNRT_CHECK(cnrtInvokeRuntimeContext(ctx,param,queue,nullptr));
    CNRT_CHECK(cnrtPlaceNotifier(notifier_end, queue));

    CNRT_CHECK(cnrtSyncQueue(queue));
	auto t1=GetTickCount();
    CNRT_CHECK(cnrtNotifierDuration(notifier_start, notifier_end, &hwtime));
#if 1
	
	float* output_ptr=res;
	for(int output_idx=0;output_idx<outputNum;output_idx++)
	{
		int dim_order[4] = {0, 3, 1, 2};
		CNRT_CHECK(cnrtGetOutputDataShape(&dimValues,&dimNum,output_idx,function));	
		if(dimNum==4)
		{
			CNRT_CHECK(cnrtMemcpy(outputCpuPtrS[output_idx],outputMluPtrS[output_idx],outputSizeS[output_idx],CNRT_MEM_TRANS_DIR_DEV2HOST));

			CNRT_CHECK(cnrtTransOrderAndCast(reinterpret_cast<void*>(outputCpuPtrS[output_idx]), outputTypeS[output_idx],
											 reinterpret_cast<void*>(outputCpuNchwPtrS[output_idx]), CNRT_FLOAT32,
											 nullptr, dimNum, dimValues, dim_order));
			memcpy(output_ptr,outputCpuNchwPtrS[output_idx],output_count[output_idx]*sizeof(float));								 
		}
		else
		{
			CNRT_CHECK(cnrtMemcpy(output_ptr,outputMluPtrS[output_idx],outputSizeS[output_idx],CNRT_MEM_TRANS_DIR_DEV2HOST));
		}
		output_ptr+=output_count[output_idx];
                free(dimValues);
	}
#endif
    return res;
}
