function [varpart] = sim_varpartcross(rdmv,rdms,model1,model2,model3)
% cross-validated variance partitioning analysis across modalities
% runs cross-validation across action stimuli (leave-one-out)
% uses Spearman's rho-A squared as prediction metric
% 
% inputs: RDMs: rdmv, rdms (vectorized, Nsub x Npairs)
%         models: model1, model2, model3: predictors (Nmodel x Npairs)
%
% output: varpart, structure containing
%                rsq_adj, adjusted R-squared for each combination of models
%                comb_labels, order of model combinations (i.e. abc, ab, bc, ac, a, b, c)
%                total_rsq, total variance explained by the models (adjusted R-squared)
%                noiseceil, upper and lower bounds of noise ceiling (cf. Nili et al 2014)
%
% DC Dima 2022 (diana.c.dima@gmail.com)

%must subsample stimuli, not participants
nvid = 95; %num actions
ncomb = 7; %num regressions to run
nit = 100; %num iterations of LOO-CV with different data splits

%split-half reliability as noise ceiling
sz = 20; % use N = 20 for all subsamples here

%combine predictors for hierarchical regression
comb{1} = [model1 model2 model3];
comb{2} = [model1 model2];
comb{3} = [model2 model3];
comb{4} = [model1 model3];
comb{5} = model1; 
comb{6} = model2; 
comb{7} = model3;

comb_labels = {'abc','ab','bc','ac','a','b','c'};
vif = nan(nit,nvid, size(comb{1},2));
big_rsq_mat = nan(2,ncomb,nvid,nit);

for it = 1:nit

    %we are testing cross-modally: draw N=20 from each dataset
    idx = randperm(size(rdmv,1),sz);
    rdmv1 = nanmean(rdmv(idx,:),1)'; %#ok<*NANMEAN>

    idx = randperm(size(rdms,1),sz);
    rdms1 = nanmean(rdms(idx,:),1)';

    truecorrsq(it) = (spearman_rho_a(rdmv1,rdms1))^2;

    %make the RDMs square for ease of indexing
    rdmv1 = squareform(rdmv1);
    rdms1 = squareform(rdms1);

    %loop across actions
    for v = 1:nvid

        %leave out all pairs corresponding to one video & vectorize
        rdmvtrain = rdmv1; rdmvtrain(v,:) = []; rdmvtrain(:,v) = []; rdmvtrain = squareform(rdmvtrain);
        rdmvtest = rdmv1(v,:); rdmvtest(v) = []; %remove diagonal

        rdmstrain = rdms1; rdmstrain(v,:) = []; rdmstrain(:,v) = []; rdmstrain = squareform(rdmstrain);
        rdmstest = rdms1(v,:); rdmstest(v) = []; %remove diagonal

        %hierarchical regression loop
        for icomb = 1:ncomb

            pred = comb{icomb};
            predtrain = []; predtest = [];

            for n = 1:size(pred,2) %for each model - split into training & test set

                tmp = pred(:,n);
                tmp = squareform(tmp);
                tmptrain = tmp; tmptrain(v,:) = []; tmptrain(:,v) = [];
                tmptest = tmp(v,:); tmptest(v) = [];
                predtrain(:,n) = squareform(tmptrain); %#ok<*AGROW> 
                predtest(:,n) = tmptest;
            end

            %train on videos, test on sentences
            lm = fitlm(predtrain,rdmvtrain(:));
            rpred = predict(lm,predtest); %get predicted responses
            big_rsq_mat(1,icomb,v,it) = (spearman_rho_a(rpred,rdmstest(:)))^2; %compare across modalities

            %train on sentences, test on videos
            lm = fitlm(predtrain,rdmstrain);
            rpred = predict(lm,predtest); %get predicted responses
            big_rsq_mat(2,icomb,v,it) = (spearman_rho_a(rpred,rdmvtest(:)))^2; %compare across modalities

            %variance inflation factor
            if icomb==1
                R0 = corrcoef(predtrain);
                vif(it,v,:) = diag(inv(R0))';
            end


        end
    end

end

for dir = 1:2

    rsq_mat = mean(squeeze(big_rsq_mat(dir,:,:,:)),2);

    %unique variance
    a = rsq_mat(1,:) - rsq_mat(3,:);
    b = rsq_mat(1,:) - rsq_mat(4,:);
    c = rsq_mat(1,:) - rsq_mat(2,:);

    %shared variance (pairs)
    bc = rsq_mat(2,:) - rsq_mat(5,:) - b;
    ab = rsq_mat(4,:) - rsq_mat(7,:) - a;
    ac = rsq_mat(3,:) - rsq_mat(6,:) - c;

    %shared variance (abc)
    abc = rsq_mat(1,:) - (a+b+c) - (ab+ac+bc);

    var_mat(dir,:,:) = [abc;ab;bc;ac;a;b;c]; %7

end


varpart.pred = var_mat;
varpart.total = mean(squeeze(big_rsq_mat(:,1,:,:)),2);
varpart.comb_labels = comb_labels;
varpart.true = truecorrsq;
varpart.vif = vif;

%average across directions for stat testing
var_mat = squeeze(mean(var_mat,1));

%test against chance
[~,~,~,pcorr] = randomize_rho(var_mat');

%test differences between amounts of unique variance
uv = var_mat([5 6 7],:);
[p(1),~,stats(1)] = signrank(uv(1,:),uv(2,:));
[p(2),~,stats(2)] = signrank(uv(2,:),uv(3,:));
[p(3),~,stats(3)] = signrank(uv(1,:),uv(3,:));

varpart.stats.wilc_pval = p;
varpart.stats.wilc_stat = stats;
varpart.stats.rand_pval = pcorr;



end
