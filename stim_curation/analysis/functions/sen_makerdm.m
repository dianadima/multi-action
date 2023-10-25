function [mod] = sen_makerdm(stimpath,datapath,rsltpath)
% make sentence-specific feature models

m = load(fullfile(rsltpath,'vid_models.mat'),'models','modelnames');

models = m.models(:,1:8);
modelnames = m.modelnames(1:8);

[feat,embrdm] = sen_embeddings(stimpath);

models(:,9) = embrdm;
models(:,10) = pdist(feat.numwords);
models(:,11) = pdist(feat.numchars);
modelnames(9:11) = {'Embeddings', 'Num words', 'Num chars'};

%load new embeddings and add them
load(fullfile(datapath,'feat_sen','clip.mat'),'clip');
load(fullfile(datapath,'feat_sen','bert.mat'),'bert');
load(fullfile(datapath,'feat_sen','gpt_ada.mat'),'emb_ada');

models(:,12:14) = [pdist(clip)' pdist(bert)' pdist(emb_ada)'];
modelnames(12:14) = {'CLIP','BERT','OpenAI'};

%normalize new model RDMs
for m = 9:14
    models(:,m) = (models(:,m)-min(models(:,m)))/(max(models(:,m))-min(models(:,m)));
end

nmod = size(models,2);

%get inter-model correlations
mcorrS = corr(models,'type','Spearman','rows','pairwise');
mcorrSa = spearman_rho_a(models);
mcorrK = nan(nmod,nmod);
for i = 1:nmod
    mcorrK(i,i) = 1;
    for j = i+1:nmod
        mcorrK(i,j) = rankCorr_Kendall_taua(models(:,i),models(:,j));
        mcorrK(j,i) = mcorrK(i,j);
    end
end

%plot correlation matrices
labels = {'Spearman''s \rho', 'Spearman''s \rho_A', 'Kendall''s \tau_A'};
data = {mcorrS, mcorrSa, mcorrK};

for fig = 1:3
    figure
    plot_rdm(data{fig},modelnames,[],0,1)
    c = colorbar;
    c.Label.String = labels{fig};
end

mod.models = models;
mod.modelnames = modelnames;
mod.mcorrS = mcorrS;
mod.mcorrSa = mcorrSa;
mod.mcorrK = mcorrK;









end