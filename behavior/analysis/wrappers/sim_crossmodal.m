function [] = sim_crossmodal(modfile,datapath)
% use feature models for cross-modality prediction
% in a leave-one-out analysis to calculate the unique variance predicted by each model

load(modfile,'models','modelnames')
load(fullfile(datapath,'vid','rdm.mat'),'rdm'); rdm1 = rdm;
load(fullfile(datapath,'sen','rdm.mat'),'rdm'); rdm2 = rdm; clear rdm

%% run subsampling analysis: 100 iterations of 20 samples from each RDM

nperm = 100; %100 iterations
nsubs = 20; %number of samples to get from each RDM
nmod = size(models,2);

truecorr = nan(nperm,1); %true predicted correlation at each iteration
unicorr = nan(nperm,nmod,2);
totcorr = nan(nperm,nmod,2);

for i = 1:nperm

    idx1 = randperm(size(rdm1,1),nsubs);
    idx2 = randperm(size(rdm2,1),nsubs);

    r1 = rdm1(idx1,:); r1 = nanmean(r1,1)';
    r2 = rdm2(idx2,:); r2 = nanmean(r2,1)';

    truecorr(i) = spearman_rho_a(r1,r2)^2;

    p = nan(nmod,2);

    for m = 1:nmod

        % for semantic & contextual models, compare with the whole set (7 models)
        % for computational models, compare with the semantic + contextual + each computational model (8 models)
        mset = models(:,1:7);
        midx = m;
        if m>7
            mset = [mset models(:,m)];
            midx = 8;
        end

        %%%%%first direction of testing
        %predict RDM based on model set
        lm = fitlm(mset,r1); %predict 2 from 1
        rpred = predict(lm,mset); %get predicted responses
        pt = (spearman_rho_a(rpred,r2))^2;

        %predict RDM based on model set without model of interest
        mset_loo = mset; mset_loo(:,midx) = [];
        lm = fitlm(mset_loo,r1);
        rpred = predict(lm,mset_loo); %get predicted responses
        pl = (spearman_rho_a(rpred,r2))^2;

        %total and unique variance
        t(m,1) = pt; %total variance
        p(m,1) = pt - pl; %unique variance

        %%%%%second direction of testing
        %predict RDM based on model set
        lm = fitlm(mset,r2); %predict 2 from 1
        rpred = predict(lm,mset); %get predicted responses
        pt = (spearman_rho_a(rpred,r1))^2;

        %predict RDM based on model set without model of interest
        mset_loo = mset; mset_loo(:,midx) = [];
        lm = fitlm(mset_loo,r2);
        rpred = predict(lm,mset_loo); %get predicted responses
        pl = (spearman_rho_a(rpred,r1))^2;

        %total and unique variance
        t(m,2) = pt; %total variance
        p(m,2) = pt - pl; %unique variance


    end

    unicorr(i,:,:) = p;
    totcorr(i,:,:) = t;

end

%run stats on the average of the two prediction directions
unicorrmean = mean(unicorr,3);
[pvalSa,~,~,pval_corrSa] = randomize_rho(unicorrmean,'num_iterations',5000);

%also run stats on each direction separately
dir = struct; dir.pval = nan(2,nmod); dir.pvalcorr = nan(2,nmod);
for i = 1:2
    p = unicorr(:,:,i);
    [dir.pval(i,:),~,~,dir.pvalcorr(i,:)] = randomize_rho(p,'num_iterations',5000);
end

%check VIF
R0 = corrcoef(models);
vif = diag(inv(R0))';

%save results
pred.truecorr = truecorr;
pred.unique = unicorr;
pred.total = totcorr;
pred.modelnames = modelnames;
pred.pval = pvalSa;
pred.pvalcorr = pval_corrSa;
pred.vif = vif;
pred.dir = dir;

%% run prediction across average RDMs

rdm1avg = nanmean(rdm1,1)'; %#ok<*NANMEAN> 
rdm2avg = nanmean(rdm2,1)';
corravg= (spearman_rho_a(rdm1avg,rdm2avg))^2;


p = nan(nmod,2); %unique variance
t = nan(nmod,2); %total variance
for m = 1:nmod

   mset = models(:,1:7);
   midx = m;
   if m>7
        mset = [mset models(:,m)];
        midx = 8;
   end

   lm = fitlm(mset,rdm1avg); %predict 2 from 1
   rpred = predict(lm,mset); %get predicted responses
   pt = (spearman_rho_a(rpred,rdm2avg))^2;

   mset_loo = mset; mset_loo(:,midx) = [];
   lm = fitlm(mset_loo,rdm1avg);
   rpred = predict(lm,mset_loo); %get predicted responses
   pl = (spearman_rho_a(rpred,rdm2avg))^2;

   t(m,1) = pt;
   p(m,1) = pt - pl;

   lm = fitlm(mset,rdm2avg); %predict 2 from 1
   rpred = predict(lm,mset); %get predicted responses
   pt = (spearman_rho_a(rpred,rdm1avg))^2;

   mset_loo = mset; mset_loo(:,midx) = [];
   lm = fitlm(mset_loo,rdm2avg);
   rpred = predict(lm,mset_loo); %get predicted responses
   pl = (spearman_rho_a(rpred,rdm1avg))^2;

   t(m,2) = pt;
   p(m,2) = pt - pl;

end

pred.avg.truecorr = corravg;
pred.avg.unique = p;
pred.avg.total = t;

save(fullfile(datapath,'crossmodal_prediction_loo.mat'),'-struct','pred')





end