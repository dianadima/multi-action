#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 13 12:52:23 2022

@author: sugijanarthanan
"""

#import necessary packages
import torch
from thingsvision import Extractor
from thingsvision.utils.data import ImageDataset, DataLoader
import process_features as feat
import numpy as np
from scipy.io import savemat

def clip ():
    
    root='./frames' 
    model_name = 'clip'
    module_name = 'visual'
    source = 'custom'
    batch_size = 64
    class_names = None  # optional list of class names for class dataset
    file_names = None # optional list of file names according to which features should be sorted
    out_path = './feat_vid'

    device = 'cuda' if torch.cuda.is_available() else 'cpu'

    # initialize extractor module
    extractor = Extractor(
      model_name=model_name, 
      pretrained=True, 
      model_path=None, 
      device=device, 
      source=source, 
      model_parameters={'variant': 'ViT-B/32'},
    )
    
    dataset = ImageDataset(
      root=root,
      out_path= out_path,
      backend=extractor.backend,
      transforms=extractor.get_transformations(),
      class_names=class_names,
      file_names=file_names,
    )
    
    batches = DataLoader(
      dataset=dataset, 
      batch_size=batch_size, 
      backend=extractor.backend,
    )
    
    features = extractor.extract_features(
      batches=batches,
      module_name=module_name,
      flatten_acts=False,
      clip=True,
    )
    #normalize features using Min-Max normalization
    normalized_features = feat.normalize(features)
    
    #plot & save RDM array
    rdm = feat.compute_rdm(features)
    rdm = np.reshape(rdm, (-1, 1))
    rdm = feat.normalize(rdm)

    #plot & save RDM matrix
    feat.plot_eucrdm(normalized_features, './RDM_plots', 'clip')
    
    return rdm
    
rdm = clip()
savemat('./clip_rdm.mat',{'clip':rdm})
    
    