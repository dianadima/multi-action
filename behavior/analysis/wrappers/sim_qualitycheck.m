function [] = sim_qualitycheck(datapath,rdmpath)
% excludes participants with low reliability on training RDM
% plots & saves reliability using different metrics
% input: file with rdm and training data
% output: none (saves updated input file)
% DC Dima 2020 (diana.dima@gmail.com)

%load data
load(fullfile(datapath,'rdm_orig.mat'),'rdm','rdm_qc','age','gender')

%get path to save figures
fpath = fullfile(rdmpath,'figures');
if ~exist(fpath,'dir'), mkdir(fpath); end

%if the script is being rerun take the full rdm
if exist('orig_rdm','var')
    rdm = orig_rdm; %#ok<NODEF> 
else
    %save the data prior to exclusions
    orig_rdm = rdm;
end

%first check number of NaNs in full rdm
sumnan = sum(isnan(rdm),2);
thresh = 0.5*size(rdm,2); %threshold of 50%
nan_idx = sumnan>thresh;

fprintf('\nRemoving %d participants with missing values...\n', sum(nan_idx));

rdm(nan_idx,:) = [];
rdm_qc(nan_idx,:) = [];
age(nan_idx) = [];
gender(nan_idx) = [];

%first check reliability of training data -
qc_nc = sim_reliability(rdm_qc, fpath, 'Training RDM before exclusions',[]);
qc_looSa = qc_nc.looSa;

%get participants with too low reliability on training data
threshold = mean(qc_looSa)-2*std(qc_looSa);
unreliable_idx = qc_looSa<=threshold;

fprintf('\nRemoving %d participants below threshold...\n', sum(unreliable_idx));
rdm(unreliable_idx,:) = [];
age(unreliable_idx) = [];
gender(unreliable_idx) = [];

%get final age and gender stats
demog.age = [mean(age) std(age)];
f = sum(contains(gender,'female'));
n = sum(contains(gender,'non-binary'));
m = numel(gender) - (f+n);
demog.gender = table(f,n,m,'VariableNames',{'f','nb','m'});

%final reliability plots for training data & full data
close all
rel = sim_reliability(rdm, fpath, 'Full RDM' , []);

%save original and final rdm
save(fullfile(datapath,'rdm_preproc.mat'),'rdm','rdm_qc','orig_rdm','rel','nan_idx','unreliable_idx','age','gender')
save(fullfile(datapath,'demog.mat'),'-struct','demog')
save(fullfile(rdmpath,'rdm.mat'),'rdm','rel')


end