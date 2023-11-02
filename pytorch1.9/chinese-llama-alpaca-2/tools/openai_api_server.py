import argparse
import os
from fastapi import FastAPI
import uvicorn
import time

#os.environ["MLU_VISIBLE_DEVICES"] = "0,1,2,3,4,5,6,7"
parser = argparse.ArgumentParser()
parser.add_argument('--base_model', default=None, type=str, required=True)
parser.add_argument('--lora_model', default=None, type=str,help="If None, perform inference on the base model")
parser.add_argument('--tokenizer_path',default=None,type=str)
parser.add_argument('--gpus', default="0", type=str)
parser.add_argument('--load_in_8bit',action='store_true', help='Load the model in 8bit mode')
parser.add_argument('--load_in_4bit',action='store_true', help='Load the model in 4bit mode')
parser.add_argument('--only_cpu',action='store_true',help='Only use CPU for inference')
parser.add_argument('--alpha',type=str,default="1.0", help="The scaling factor of NTK method, can be a float or 'auto'. ")
args = parser.parse_args()
if args.only_cpu is True:
    args.gpus = ""
    if args.load_in_8bit or args.load_in_4bit:
        raise ValueError("Quantization is unavailable on CPU.")
if args.load_in_8bit and args.load_in_4bit:
    raise ValueError("Only one quantization method can be chosen for inference. Please check your arguments")
#os.environ["CUDA_VISIBLE_DEVICES"] = args.gpus
os.environ["MLU_VISIBLE_DEVICES"] = args.gpus
import torch
import torch_mlu
import torch.nn.functional as F
from transformers import LlamaForCausalLM, LlamaTokenizer, GenerationConfig, BitsAndBytesConfig
from peft import PeftModel

import sys
parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(parent_dir)
from attn_and_long_ctx_patches import apply_attention_patch, apply_ntk_scaling_patch
apply_attention_patch(use_memory_efficient_attention=True)
apply_ntk_scaling_patch(args.alpha)

from openai_api_protocol import (
    ChatCompletionRequest,
    ChatCompletionResponse,
    ChatMessage,
    ChatCompletionResponseChoice,
    CompletionRequest,
    CompletionResponse,
    CompletionResponseChoice,
    EmbeddingsRequest,
    EmbeddingsResponse,
)

load_type = torch.float16
if torch.mlu.is_available():
    device = torch.device(0)
else:
    device = torch.device('cpu')
if args.tokenizer_path is None:
    args.tokenizer_path = args.lora_model
    if args.lora_model is None:
        args.tokenizer_path = args.base_model
tokenizer = LlamaTokenizer.from_pretrained(args.tokenizer_path, legacy=True)

base_model = LlamaForCausalLM.from_pretrained(
    args.base_model,
    torch_dtype=load_type,
    low_cpu_mem_usage=True,
    device_map='auto' if not args.only_cpu else None,
    quantization_config=BitsAndBytesConfig(
        load_in_4bit=args.load_in_4bit,
        load_in_8bit=args.load_in_8bit,
        bnb_4bit_compute_dtype=load_type
    )
    )

model_vocab_size = base_model.get_input_embeddings().weight.size(0)
tokenizer_vocab_size = len(tokenizer)
print(f"Vocab of the base model: {model_vocab_size}")
print(f"Vocab of the tokenizer: {tokenizer_vocab_size}")
if model_vocab_size!=tokenizer_vocab_size:
    print("Resize model embeddings to fit tokenizer")
    base_model.resize_token_embeddings(tokenizer_vocab_size)
if args.lora_model is not None:
    print("loading peft model")
    model = PeftModel.from_pretrained(base_model, args.lora_model,torch_dtype=load_type,device_map='auto',)
else:
    model = base_model

if device==torch.device('cpu'):
    model.float()

model.eval()

DEFAULT_SYSTEM_PROMPT = """You are a helpful assistant. 你是一个乐于助人的助手。"""

TEMPLATE_WITH_SYSTEM_PROMPT = (
    "[INST] <<SYS>>\n"
    "{system_prompt}\n"
    "<</SYS>>\n\n"
    "{instruction} [/INST]"
)

TEMPLATE_WITHOUT_SYSTEM_PROMPT = "[INST] {instruction} [/INST]"

def generate_prompt(instruction, response="", with_system_prompt=True, system_prompt=None):
    if with_system_prompt is True:
        if system_prompt is None:
            system_prompt = DEFAULT_SYSTEM_PROMPT
        prompt = TEMPLATE_WITH_SYSTEM_PROMPT.format_map({'instruction': instruction,'system_prompt': system_prompt})
    else:
        prompt = TEMPLATE_WITHOUT_SYSTEM_PROMPT.format_map({'instruction': instruction})
    if len(response)>0:
        prompt += " " + response
    return prompt

def generate_completion_prompt(instruction: str):
    """Generate prompt for completion"""
    return generate_prompt(instruction, response="", with_system_prompt=True)


def generate_chat_prompt(messages: list):
    """Generate prompt for chat completion"""

    system_msg = None
    for msg in messages:
        if msg.role == 'system':
            system_msg = msg.content
    prompt = ""
    is_first_user_content = True
    for msg in messages:
        if msg.role == 'system':
            continue
        if msg.role == 'user':
            if is_first_user_content is True:
                prompt += generate_prompt(msg.content, with_system_prompt=True, system_prompt=system_msg)
                is_first_user_content = False
            else:
                prompt += '<s>'+generate_prompt(msg.content, with_system_prompt=False)
        if msg.role == 'assistant':
                prompt += f" {msg.content}"+"</s>"
    return prompt

def predict(
    input,
    max_new_tokens=128,
    top_p=0.9,
    temperature=0.2,
    top_k=40,
    num_beams=1,
    repetition_penalty=1.1,
    do_sample=True,
    **kwargs,
):
    """
    Main inference method
    type(input) == str -> /v1/completions
    type(input) == list -> /v1/chat/completions
    """
    if isinstance(input, str):
        prompt = generate_completion_prompt(input)
    else:
        prompt = generate_chat_prompt(input)
    inputs = tokenizer(prompt, return_tensors="pt")
    input_ids = inputs["input_ids"].to(device)
    generation_config = GenerationConfig(
        temperature=temperature,
        top_p=top_p,
        top_k=top_k,
        num_beams=num_beams,
        do_sample=do_sample,
        **kwargs,
    )
    generation_config.return_dict_in_generate = True
    generation_config.output_scores = False
    generation_config.max_new_tokens = max_new_tokens
    generation_config.repetition_penalty=float(repetition_penalty)
    start_time=time.time()
    with torch.no_grad():
        generation_output = model.generate(
            input_ids=input_ids,
            generation_config=generation_config,
        )
    s = generation_output.sequences[0]
    end_time = time.time()
    elapsed_time = end_time - start_time
    print("#"*20,len(s))
    tokens_per_second = len(s) / elapsed_time
    print(f"\n\n生成速度：{tokens_per_second:.2f} tokens/s","tokens 的数量：",len(s),"推理耗时：",elapsed_time)
    print("#"*20)
    output = tokenizer.decode(s, skip_special_tokens=True)
    output = output.split("[/INST]")[-1].strip()
    return output

def get_embedding(input):
    """Get embedding main function"""
    with torch.no_grad():
        encoding = tokenizer(
            input, padding=True, return_tensors="pt"
        )
        input_ids = encoding["input_ids"].to(device)
        attention_mask = encoding["attention_mask"].to(device)
        model_output = model(
            input_ids, attention_mask, output_hidden_states=True
        )
        data = model_output.hidden_states[-1]
        mask = attention_mask.unsqueeze(-1).expand(data.size()).float()
        masked_embeddings = data * mask
        sum_embeddings = torch.sum(masked_embeddings, dim=1)
        seq_length = torch.sum(mask, dim=1)
        embedding = sum_embeddings / seq_length
        normalized_embeddings = F.normalize(embedding, p=2, dim=1)
        ret = normalized_embeddings.squeeze(0).tolist()
    return ret

app = FastAPI()

@app.post("/v1/chat/completions")
async def create_chat_completion(request: ChatCompletionRequest):
    """Creates a completion for the chat message"""
    msgs = request.messages
    if isinstance(msgs, str):
        msgs = [ChatMessage(role='user',content=msgs)]
    else:
        msgs = [ChatMessage(role=x['role'],content=x['message']) for x in msgs]
    output = predict(
        input=msgs,
        max_new_tokens=request.max_tokens,
        top_p=request.top_p,
        top_k=request.top_k,
        temperature=request.temperature,
        num_beams=request.num_beams,
        repetition_penalty=request.repetition_penalty,
        do_sample=request.do_sample,
    )
    choices = [ChatCompletionResponseChoice(index = i, message = msg) for i, msg in enumerate(msgs)]
    choices += [ChatCompletionResponseChoice(index = len(choices), message = ChatMessage(role='assistant',content=output))]
    return ChatCompletionResponse(choices = choices)

@app.post("/v1/completions")
async def create_completion(request: CompletionRequest):
    """Creates a completion"""
    output = predict(
        input=request.prompt,
        max_new_tokens=request.max_tokens,
        top_p=request.top_p,
        top_k=request.top_k,
        temperature=request.temperature,
        num_beams=request.num_beams,
        repetition_penalty=request.repetition_penalty,
        do_sample=request.do_sample,
    )
    choices = [CompletionResponseChoice(index = 0, text = output)]
    return CompletionResponse(choices = choices)

@app.post("/v1/embeddings")
async def create_embeddings(request: EmbeddingsRequest):
    """Creates text embedding"""
    embedding = get_embedding(request.input)
    data = [{
        "object": "embedding",
        "embedding": embedding,
        "index": 0
    }]
    return EmbeddingsResponse(data=data)


if __name__ == "__main__":
    log_config = uvicorn.config.LOGGING_CONFIG
    log_config["formatters"]["access"]["fmt"] = "%(asctime)s - %(levelname)s - %(message)s"
    log_config["formatters"]["default"]["fmt"] = "%(asctime)s - %(levelname)s - %(message)s"
    uvicorn.run(app, host='0.0.0.0', port=19327, workers=1, log_config=log_config)
