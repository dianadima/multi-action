#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 13 11:43:10 2022

@author: sugijanarthanan
"""

import numpy as np
import thingsvision.core.rsa as t
from sklearn import preprocessing as p

def normalize (features):
    min_max_scaler = p.MinMaxScaler()
    normalized_features = min_max_scaler.fit_transform(features)
    return normalized_features
       
def plot_eucrdm (normalized_features, out_path, model):
    t.plot_rdm(
        out_path,
        normalized_features,
        method='euclidean',
        format='.png', 
        colormap='cividis',
        show_plot=True,
    )
   
def compute_rdm (features):
    rdm_dnn = t.compute_rdm(features, 'euclidean')  
    triu_inds = np.triu_indices(len(rdm_dnn), k=1) #take the upper triangular part to convert into vector
    rdm_vector = rdm_dnn[triu_inds]
    return rdm_vector



