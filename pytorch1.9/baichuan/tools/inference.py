from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
import torch_mlu
torch.set_grad_enabled(False)
tokenizer = AutoTokenizer.from_pretrained("./baichuan-7B", trust_remote_code=True)
model = AutoModelForCausalLM.from_pretrained("./baichuan-7B", torch_dtype=torch.float16, trust_remote_code=True).to('mlu')

text = input('User：')
while(True):
    inputs = tokenizer(text, return_tensors='pt')
    #inputs = tokenizer('登鹳雀楼->王之涣\n夜雨寄北->', return_tensors='pt')
    inputs = inputs.to('mlu')
    pred = model.generate(**inputs, max_new_tokens=256,repetition_penalty=1.1)
    print(tokenizer.decode(pred.cpu()[0], skip_special_tokens=True))
    text = input('User：')