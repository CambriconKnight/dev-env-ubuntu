import os
import platform
import signal
from transformers import AutoTokenizer, AutoModel
import readline
import time

tokenizer = AutoTokenizer.from_pretrained("../chatglm-6b", trust_remote_code=True)
model = AutoModel.from_pretrained("../chatglm-6b", trust_remote_code=True).half().mlu()
model = model.eval()

response, history = model.chat(tokenizer, "Hi...", history=[])
print(response)

for question in [
    "ChatGLM-6B 是啥?",
    "ChatGPT 是啥?",
    "ChatGLM-6B 与 ChatGPT 有什么区别?"
]:

    time_start = time.time()
    response, history = model.chat(tokenizer, question, history=history)
    time_end = time.time()
    print("==================================================")
    print("question: ", question)
    print("response: ", response)
    print("len(response): ", len(response))
    print("time_end-time_start: ", (time_end-time_start))
    print("token: ", len(response) / (time_end-time_start))
    print("==================================================")
