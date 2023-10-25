%% analysis pipeline for Meadows behavioural similarity data
% action categorization task using natural videos and sentences
% DC Dima 2023 (diana.c.dima@gmail.com)

%% setup

clear; clc; close all 
set(0,'DefaultAxesFontName','Arial')

%specify dataset type: video or sentence
d = input('Select dataset: 1 = videos, 2 = sentences: ');
if d==1, dtype = 'vid'; else, dtype = 'sen'; end

%set paths
basepath = fileparts(fileparts(matlab.desktop.editor.getActiveFilename));    %parent directory
addpath(genpath(fileparts(basepath)))                                        %add code to path

datapath = fullfile(basepath, 'data', dtype);                                %where to find data
savepath = fullfile(basepath, 'results', dtype);                             %where to save results

%result filenames for RSA analysis
rsafile = fullfile(savepath,'rsa.mat');                                      %RSA results
vptfile = fullfile(savepath,'rsa_varpart.mat');                             %variance partitioning results
modfile = fullfile(fileparts(datapath),'models.mat');                        %RSA models

%% run data processing

%read and clean data
sim_readdata(datapath);    

% check reliability, further exclusions
sim_qualitycheck(datapath,savepath);

%% run standard rsa

sim_runrsa(savepath,modfile,rsafile)

%% run cross-modal prediction

sim_crossmodal(modfile,fileparts(savepath))

%% run unimodal variance partitioning

% unimodal variance partitioning with semantic vs social vs perceptual
if strcmp(dtype,'vid')
    models = {{'Action target','Action class', 'Everyday activity','Action verb'};{'Number of agents', 'Agent gender'};{'Scene setting', 'AlexNet FC8', 'Motion energy', 'Tool use','Effectors'}};
    sim_varpart(savepath,modfile,strrep(vptfile,'.mat','_grouped.mat'),models,{'Semantic';'Social';'Perceptual'})
else
    models = {{'Action target','Action class', 'Everyday activity','Action verb'};{'Number of agents', 'Agent gender'};{'Scene setting','Number of words'}};
    sim_varpart(savepath,modfile,strrep(vptfile,'.mat','_grouped.mat'),models,{'Semantic';'Social';'Perceptual'})
end

% unimodal variance partitioning with semantic features
models = {'Action target';'Action class';'Everyday activity'};
sim_varpart(savepath,modfile,vptfile,models)

% unimodal variance partitioning with OpenAI
models = {'Action target';'Action class';'OpenAI'};
sim_varpart(savepath,modfile,strrep(vptfile,'.mat','_openai.mat'),models)

% unimodal variance partitioning with OpenAI on individual sentence components
models = {'Agent';'Action';'Context'};
sim_varpart(savepath,strrep(modfile,'.mat','_parts.mat'),strrep(vptfile,'.mat','_openai_parts.mat'),models)

%% run cross-modal variance partitioning

% cross-modal variance partitioning pitting semantic vs social vs perceptual features
models = {{'Action target','Action class', 'Everyday activity','Action verb'};{'Number of agents', 'Agent gender'};{'Scene setting'}};
sim_varpart(fileparts(savepath),fileparts(datapath),fullfile(fileparts(savepath),'crossmodal_varpart_grouped.mat'),models,{'Semantic';'Social';'Perceptual'})

% cross-modal variance partitioning with semantic features
models = {'Action target';'Action class';'Activity'};
sim_varpart(fileparts(savepath),fileparts(datapath),fullfile(fileparts(savepath),'crossmodal_varpart.mat'),models)

% cross-modal variance partitioning with OpenAI
models = {'Action target';'Action class';'OpenAI'};
sim_varpart(fileparts(savepath),fileparts(datapath),fullfile(fileparts(savepath),'crossmodal_varpart_openai.mat'),models)

% cross-modal variance partitioning with OpenAI on individual sentence components
models = {'Agent';'Action';'Context'};
sim_varpart(fileparts(savepath),strrep(modfile,'.mat','_parts.mat'),fullfile(fileparts(savepath),'crossmodal_varpart_openai_parts.mat'),models)
