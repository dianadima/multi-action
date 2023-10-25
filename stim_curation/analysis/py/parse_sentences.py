#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 17 17:42:27 2023

@author: dianadima
"""

def parse_sentences(sentences):
    
    s_list = sentences.values.tolist() #convert dataframe to a list

    #make sentence array
    l_sentences = []
    for x in s_list:    
        a = str(x)
        a = a.lower()
        l_sentences.append(a)
    
    #remove excess characters
    s_list = [i.replace('\\', '') for i in l_sentences]
    s_list = [i.replace('.', '') for i in s_list]
    s_list = [i.replace('"', '') for i in s_list]
    s_list = [i.replace('[', '') for i in s_list]
    s_list = [i.replace(']', '') for i in s_list]
    
    return s_list