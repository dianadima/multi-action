%% script for plotting results for video & sentence datasets together

clear; clc; close all
set(0,'DefaultAxesFontName','Arial')

dtypes = {'vid','sen'};

%set paths
basepath = fileparts(fileparts(matlab.desktop.editor.getActiveFilename));    %parent directory
addpath(genpath(fileparts(basepath)))                                        %add code to path

datapath = fullfile(basepath, 'data');                                       %raw data
savepath = fullfile(basepath, 'results');                                    %results to save

%% plot model correlation matrix

figure
plot_corrmat(fullfile(datapath,'models.mat'))

%% test and plot reliability across datasets (keeping N constant)

sim_compare_reliability(fullfile(savepath,dtypes{1},'rdm.mat'),fullfile(savepath,dtypes{2},'rdm.mat'))

%% plot rsa results

figure
for i = 1:2
    subplot(1,2,i)
    rsafile = fullfile(savepath,dtypes{i},'rsa.mat');
    plot_rsa(rsafile)
    if i==2, set(gca,'ylabel',[]);end
end

%% plot cross-modal prediction results

plot_crossmodal(fullfile(savepath,'crossmodal_prediction.mat'))

%% plot variance partitioning results for each analysis: video, sentence & cross-modal
filesuff = {'','_grouped','_openai','_openai_parts'};

for f = 1:numel(filesuff)

    %get filenames in correct order
    vfile = cell(3,1);
    for i = 1:2, vfile{i} = fullfile(savepath,dtypes{i},['rsa_varpart' filesuff{f}  '.mat']); end
    vfile{3} = fullfile(savepath,['crossmodal_varpart' filesuff{f} '.mat']);

    %plot venn diagrams
    plot_varpart_venn(vfile)

    %plot stacked plot
    plot_varpart_stacked(vfile)

end

