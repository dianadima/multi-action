function [rdm] = sim_readdata(datapath)
% read and save Meadows multiple arrangement data from json files
% datapath: data directory
% savefile: data file to be saved
% DC Dima 2022 (diana.c.dima@gmail.com)

nstim = 95; %hard-coded

%indices of the tasks
t_pinfo = 2;
t_catch = 7;
t_trial = 6;
t_main = 8;
t_feed = 9;

%find the datafile in the directory
files = dir(datapath);
files = {files(:).name};
files = files{contains(files, '.json')};

data = jsondecode(fileread(fullfile(datapath,files)));

%remove test participation
if isfield(data,'sharp_treefrog')
    data = rmfield(data, 'sharp_treefrog');
end

%save all data as a .mat file
save(fullfile(datapath,'data.mat'),'data')

subnames = fieldnames(data);
nsub = numel(subnames);

exclude_idx = false(nsub,1); %mark participants excluded after QC

rdm = nan(nsub,nstim*(nstim-1)/2);
rdm_qc = nan(nsub,3); %3 stimuli per training

catch_answers = cell(nsub,3);
feedback = cell(nsub,1);
%mturk_id = cell(nsub,1);

gender = cell(nsub,1);
age = nan(nsub,1);

for isub = 1:nsub

    datasub = data.(subnames{isub});

    %get age and gender
    pinfo = datasub.tasks{t_pinfo};
    gender{isub} = pinfo.gender;
    age(isub) = str2double(pinfo.age);

    %display catch trials and select participants based on them
    ct = datasub.tasks{t_catch};
    catch_answers{isub,1} = ct.Video1;
    catch_answers{isub,2} = ct.Video2;
    catch_answers{isub,3} = ct.Video3;
    feedback{isub} = datasub.tasks{t_feed}.Feedback;

    fprintf('Catch answers for sub %d\n, %s\n,%s\n,%s\n', isub, ct.Video1, ct.Video2, ct.Video3);
    fprintf('\nFeedback: %s\n', feedback{isub})
    x = input('Exclude? Y/N: ', 's');

    %no point extracting data for excluded subjects
    if strcmp(x,'Y')

        exclude_idx(isub) = 1;

    else

        %training matrix
        qc = datasub.tasks{t_trial};
        rdm_qc(isub,:) = sim_getrdm(qc);

        %full matrix
        df = datasub.tasks{t_main};
        rdm(isub,:) = sim_getrdm(df);


    end

end
  
%remove participants who were excluded
if sum(exclude_idx>0)
    rdm_qc(exclude_idx,:) = [];
    rdm(exclude_idx,:) = [];
    age(exclude_idx) = [];
    gender(exclude_idx) = [];
end

%save
save(fullfile(datapath,'data_preproc.mat'), 'rdm','rdm_qc', 'exclude_idx', 'age','gender','catch_answers', 'feedback')
save(fullfile(datapath,'rdm_orig.mat'), 'rdm','rdm_qc','age','gender')




















end