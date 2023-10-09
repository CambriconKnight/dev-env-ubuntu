from transformers import AutoTokenizer, AutoModel
import torch
import torch_mlu

tokenizer = AutoTokenizer.from_pretrained("../chatglm2-6b", trust_remote_code=True)
model = AutoModel.from_pretrained("../chatglm2-6b", trust_remote_code=True).half().mlu()
model = model.eval()
response, history = model.chat(tokenizer, "你好", history=[])
print(response)

response, history = model.chat(tokenizer, "晚上睡不着应该怎么办？", history=history)
print(response)

response, history = model.chat(tokenizer, "中国的首都是哪里？", history=history)
print(response)