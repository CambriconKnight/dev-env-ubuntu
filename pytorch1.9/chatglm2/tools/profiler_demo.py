from transformers import AutoTokenizer, AutoModel
import torch
import torch_mlu

tokenizer = AutoTokenizer.from_pretrained("/workspace/chatglm2/models/chatglm2-6b", trust_remote_code=True)
model = AutoModel.from_pretrained("/workspace/chatglm2/models/chatglm2-6b", trust_remote_code=True).half().mlu()
model = model.eval()
with torch.profiler.profile(
    activities=[torch.profiler.ProfilerActivity.CPU, torch.profiler.ProfilerActivity.MLU],
    schedule=torch.profiler.schedule(wait=0, warmup=0, active=1),
    record_shapes=True,
    with_stack=False,
    with_flops=True,
    on_trace_ready=torch.profiler.tensorboard_trace_handler("mlu_log")
) as prof:
    response, history = model.chat(tokenizer, "你好", history=[])
    prof.step()
    print(response)
