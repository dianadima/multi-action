function [rdm, rdmsq] = sim_getrdm(data)
% place individual subjects' data into the full stimulus set RDM
% input: data (struct) and stimlist (cell array of all stimulus names, in order)

%get stimulus order
stimorig = {data.stimuli(:).name};
stimlist = sort(stimorig);
nstim = numel(stimlist);

% assign NaNs if necessary
if iscell(data.rdm)
    rdm = nan(numel(data.rdm),1);
    for i = 1:numel(data.rdm)
        if ~isstruct(data.rdm{i})
            rdm(i) = data.rdm{i};
        end
    end
else
    rdm = data.rdm;
end

%normalize rdm
rdm = (rdm - min(rdm))./(max(rdm)-min(rdm)); 

%reorder rdm
rdm = squareform(rdm);
rdmsq = nan(nstim,nstim);

idx = nan(nstim,1);
for i = 1:nstim
    idx(i) = find(contains(stimlist,stimorig{i}));
end

rdmsq(idx,idx) = rdm;    %save square rdm
rdm = squareform(rdmsq); %save rdm vector




end