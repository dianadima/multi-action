#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb  2 13:15:33 2023

@author: sugijanarthanan
"""

#import necessary packages
import torch
from transformers import BertTokenizer, BertModel
from pandas import read_csv
import numpy
from scipy.io import savemat
from parse_sentences import parse_sentences

#define tokenizer
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')

#load in csv file of sentence stimulus set
sentences = read_csv('./sentences.csv', header=None)
s_list = parse_sentences(sentences)

#add special tokens to sentences so BERT can recognize beginning and ending of sentences
marked = []
for x in s_list:
    marked_text = "[CLS] " + str(x) + " [SEP]"
    marked.append(marked_text)

#run each sentence through BERT
n = 0
maxv = 95
wordvec_con = []
wordvec_sum = []
sentencevec_sum = []

while n<maxv:
    
    #tokenize the entire sentence
    tokenized_text = tokenizer.tokenize(marked[n])
    
    #convert sentence from list of strings to list of vocabulary indeces
    indexed_tokens = tokenizer.convert_tokens_to_ids(tokenized_text)
    
    #add segment ID to tell BERT that all words come from the same sentence
    segments_ids = [1] * len(tokenized_text)
    
    #convert input from Python lists to Pytorch tensors 
    tokens_tensor = torch.tensor([indexed_tokens])
    segments_tensors = torch.tensor([segments_ids])
    
    #load pre-trained BERT model   
    model = BertModel.from_pretrained('bert-base-uncased', output_hidden_states = True,)
    model.eval() #puts model in feed-forward operation
    
    # Run the text through BERT and collect all of the hidden states produced from all 12 layers
    with torch.no_grad():
        outputs = model(tokens_tensor, segments_tensors)
        hidden_states = outputs[2]
    
    #switch dimensions from [# layers, # batches, # tokens, # features] to [# tokens, # layers, # features]
    token_embeddings = torch.stack(hidden_states, dim=0) # Concatenate the tensors for all layers
    token_embeddings = torch.squeeze(token_embeddings, dim=1) # Remove dimension 1, the "batches"
    token_embeddings = token_embeddings.permute(1,0,2) # Swap dimensions 0 and 1
    token_embeddings.size()
    
    token_vecs_cat = []
    for token in token_embeddings:
        cat_vec = torch.cat((token[-1], token[-2], token[-3], token[-4]), dim=0) # Concatenate the vectors from the last four layers.
        token_vecs_cat.append(cat_vec) # Use `cat_vec` to represent `token`.
        word_vectorc = numpy.empty((len(token_vecs_cat[0]), 1))
        for c in token_vecs_cat:
            a = token_vecs_cat[0].numpy()
            word_vectorc = numpy.column_stack((word_vectorc, a))
    word_vectorc = numpy.delete(word_vectorc, 0, 1)
    wordvec_con.append(word_vectorc)

    #word vector - summing together the last four layers
    token_vecs_sum = []
    for token in token_embeddings:
        sum_vec = torch.sum(token[-4:], dim=0) # Sum the vectors from the last four layers.
        token_vecs_sum.append(sum_vec) # Use `sum_vec` to represent `token`.
        word_vector = numpy.empty((len(token_vecs_sum[0]), 1))
        for c in token_vecs_sum:
            a = token_vecs_sum[0].numpy()
            word_vector = numpy.column_stack((word_vector, a))
    word_vector = numpy.delete(word_vector, 0, 1)
    wordvec_sum.append(word_vector)
    
    #sentence vector
    token_vecs = hidden_states[-2][0]
    sentence_embedding = torch.mean(token_vecs, dim=0)
    sentence_vector = sentence_embedding.numpy()
    sentencevec_sum.append(sentence_vector)
    
    n=n+1

#convert list of arrays into one array and save to .mat
bert = numpy.vstack(sentencevec_sum)
savemat('./bert.mat',{'bert':bert})




