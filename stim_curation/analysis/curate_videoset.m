% script for preprocessing videos and sentences into final stimuli

%% set paths
basepath = fileparts(fileparts(matlab.desktop.editor.getActiveFilename));
addpath(genpath(fileparts(basepath)))

datapath = fullfile(basepath,'data');
rsltpath = fullfile(basepath,'results');

stimpath = fullfile(fileparts(basepath),'stimuli');
stimpath_orig = fullfile(stimpath,'videos_full');               %original video stimuli
stimpath_edit = fullfile(stimpath,'videos_full_preprocessed');  %processed and renamed
stimpath_save = fullfile(stimpath,'videos');                    %subsampled - final
catchpath = fullfile(stimpath,'catch');                         %catch stimuli

%save first frame
mkdir(fullfile(stimpath_edit,'frames'))

%set font for all plots
set(0,'DefaultAxesFontName','Arial')

%% edit videos
% parameters
nframes = 20*2; %2 second videos at 20 fps
tgsize = [400 600]; %400 x 600 px

% load video list
load(fullfile(datapath,'videolist.mat'));
nvid = numel(videolist);

% save parameters
coord = cell(nvid,1);
startframe = nan(nvid,1);

% loop and edit
for i = 1:nvid

    origvideo = fullfile(stimpath_orig,char(videolist{i}));
    savevideo = fullfile(stimpath_edit,[sprintf('%.3d',i) '.mp4']);

    [coord{i}, startframe(i),firstframe] = vid_preprocess(origvideo,savevideo,nframes,tgsize);
    imwrite(firstframe,fullfile(stimpath_edit, 'frames', [sprintf('%.3d',i) '.png']));

end

save(fullfile(rsltpath,'video_proc_param.mat'),'coord','startframe')

%% edit catch videos in the same way

% get catch video list
catchvidlist = {dir(fullfile(catchpath,'videos_orig')).name};
catchvidlist(1:2) = [];
ncvid = numel(catchvidlist);

% loop and edit
for i = 1:ncvid

    origvideo = fullfile(catchpath,'videos_orig',catchvidlist{i});
    savevideo = fullfile(catchpath,'videos',catchvidlist{i});

    vid_preprocess(origvideo,savevideo,nframes,tgsize);

end


%% get initial video features and RDMs 
% get alexnet features: Conv1 + FC8 - using first frame of each video
[feat,~,~] = extract_cnn_features('alexnet',fullfile(stimpath_edit,'frames'),{'pool1','fc8'});
save(fullfile(datapath,'feat_vid','alexnet_features249.mat'),'feat')

%get feature RDMs for full videoset
mod = vid_makerdm(datapath,1:nvid);
save(fullfile(datapath,'models249.mat'),'-struct','mod')

%% subsample videos
load(fullfile(datapath,'repertoire_categories249.mat'),'categories','categories_idx')
load(fullfile(datapath,'models249.mat'),'models','modelnames')

nstim = 100; 
niter = 10000;
balanced = [10 10 20 20 10 10 10 10];

results = vid_subsample(categories,categories_idx,models,modelnames,videolabels,nstim,niter,balanced);

save(fullfile(rsltpath,'subsampling100.mat'),'results')

% manually adjust video subsampling index (changes to ensure video quality & variation)
sidx = vid_updateidx(results);
save(fullfile(rsltpath,'subsampling100.mat'),'-append','sidx')

%copy first frame of selected stimuli to their own directory
for v = 1:numel(sidx)
    copyfile(fullfile(stimpath_edit, 'frames', [sprintf('%.3d',sidx(v)) '.png']),fullfile(stimpath,'videos_frames',[sprintf('%.3d',v) '.png']))
end

%% create new dataset directory
sidx = results.subset_idx(results.idx_mincorr,:);
stimpath = fullfile(basepath,'stimuli100');

for i = 1:numel(sidx)

    vname = [sprintf('%.3d',sidx(i)) '.mp4'];
    nname = [sprintf('%.3d',i) '.mp4'];
    copyfile(fullfile(stimpath_edit,vname), fullfile(stimpath_save, nname))

end

%% create and plot final dataset RDMs & semantic composition
mod = vid_makerdm(datapath,sidx);
save(fullfile(rsltpath,'vid_models'),'-struct','mod')

semantic = vid_distribution(datapath,sidx);
save(fullfile(rsltpath,'semantic_distribution.mat'),'-struct','semantic')

%% create images of the sentences to use in multiple arrangement
sentpath = fullfile(stimpath,'sentences'); mkdir(sentpath)
sen_makeimg(stimpath,sentpath)

%% create and plot sentence RDMs
mod = sen_makerdm(stimpath,datapath,rsltpath);
save(fullfile(rsltpath,'sen_models.mat'),'-struct','mod');

%% create images of the catch sentences for neuro experiments
catchsentpath = fullfile(catchpath,'sentences'); mkdir(catchsentpath)
sen_makeimg(catchpath,catchsentpath)



