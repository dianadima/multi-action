#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 19 13:30:48 2023

@author: dianadima
"""

def parse_sentence_parts(sentences):
    
    s_list = sentences.values.tolist() #convert dataframe to a list

    #make sentence array
    l_agent = []
    l_action = []
    l_context = []
    
    for x in s_list:    
        a = str(x)
        a = a.lower()
        
        a = a.split('\\ ')
        
        #remove excess characters       
        a = [i.replace('.', '') for i in a]
        a = [i.replace('"', '') for i in a]
        a = [i.replace('[', '') for i in a]
        a = [i.replace(']', '') for i in a]
        a = [i.replace('\\', '') for i in a]
        
        l_agent.append(a[0])
        l_action.append(a[1])
        l_context.append(a[2])
        
    
    
    return l_agent, l_action, l_context