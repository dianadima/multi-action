function [] = sim_varpart(rdmpath,modfile,vpfile,mnames,varargin)
% Variance partitioning analysis
% Inputs: rdmpath, path to behavioral RDM and noise ceiling
%         modfile, file with RSA models
%         vpfile, results file to be saved
%         mnames, models to use (bins x models)
%         bin labels (optional; 3x1 cell)
% DC Dima 2021 (diana.c.dima@gmail.com)

%load files & get vectorized RDM

%if single modality, load single rdm
if contains(rdmpath,'vid')||contains(rdmpath,'sen')
    load(fullfile(rdmpath,'rdm.mat'), 'rdm')
    load(modfile,'models','modelnames')
else
    try
        load(modfile,'models','modelnames')
    catch
        load(fullfile(modfile,'models.mat'),'models','modelnames')
    end
    load(fullfile(rdmpath,'vid','rdm.mat'),'rdm'); rdmv = rdm;
    load(fullfile(rdmpath,'sen','rdm.mat'),'rdm'); rdms = rdm; clear rdm
end

%group models and select
mod1 = mnames(1,:);
mod2 = mnames(2,:);
mod3 = mnames(3,:);
mod = {mod1,mod2,mod3};
sel_mod = sim_prepmodels(mod,models,modelnames);

%run cross-validated variance partitioning (unimodal or crossmodal)
if exist('rdm','var')
    varpart = sim_varpartcv(rdm,sel_mod{1},sel_mod{2},sel_mod{3});
else
    varpart = sim_varpartcross(rdmv,rdms,sel_mod{1},sel_mod{2},sel_mod{3});
end

if numel(mnames)==3 && (~iscell(mnames{1}) || numel(mnames{1})==1)
    varpart.modelnames = mnames;
else
    varpart.modelnames = varargin{1};
end

save(vpfile,'varpart');

% select the models/sets of models for variance partitioning
    function [sel_mod] = sim_prepmodels(mod,models,modelnames)
        
        nmod = numel(mod);
        sel_mod = cell(nmod,1);
        
        for i = 1:nmod
            
            mtmp = mod{i}; if iscell(mtmp)&&iscell(mtmp{1})&&numel(mtmp{1})>1, mtmp = mtmp{1}; end
            midx = nan(numel(mtmp),1);
            for ii = 1:numel(mtmp)
                midx(ii) = find(cellfun(@(x) strcmp(mtmp{ii},x), modelnames));
            end
            sel_mod{i} = models(:,midx);
        end
        
    end

end

