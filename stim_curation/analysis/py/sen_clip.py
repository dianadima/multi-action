#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr 11 17:58:14 2023

@author: dianadima
"""

from transformers import CLIPTokenizerFast, CLIPProcessor, CLIPModel
import torch
from scipy.io import savemat
from pandas import read_csv
import numpy as np
from parse_sentences import parse_sentences

device = "cpu" 
model_id = "openai/clip-vit-base-patch32"

# initialize tokenizer and model
tokenizer = CLIPTokenizerFast.from_pretrained(model_id)
model = CLIPModel.from_pretrained(model_id).to(device)

sentences = read_csv("./sentences.csv",header=None)
s_list = parse_sentences(sentences)

emb_clip = []

for s in s_list:

    # create transformer-readable tokens
    inputs = tokenizer(s, return_tensors="pt")

    # use CLIP to encode tokens into a meaningful embedding
    text_emb = model.get_text_features(**inputs)
    torch.squeeze(text_emb)
    emb_clip.append(text_emb.detach().numpy())
    
clip = np.array(emb_clip)
clip = np.squeeze(emb)
savemat('./clip.mat',{'clip':clip})

