function [varpart] = sim_varpartcross(rdmv,rdms,model1,model2,model3)
% cross-validated variance partitioning analysis across modalities
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

sz = 20; %subsample 20 subjects from each modality
nit = 100; %number of iterations

truecorrsq = nan(nit,1);

%combine predictors for hierarchical regression
comb{1} = [model1 model2 model3];
comb{2} = [model1 model2];
comb{3} = [model2 model3];
comb{4} = [model1 model3];
comb{5} = model1; 
comb{6} = model2; 
comb{7} = model3;

ncomb = length(comb);
vif = nan(nit,size(comb{1},2));
big_rsq_mat = nan(2,ncomb,nit); %two prediction directions
var_mat = nan(2,ncomb,nit);
comb_labels = {'abc','ab','bc','ac','a','b','c'};

%loop
for it = 1:nit

    idx1 = randperm(size(rdmv,1),sz);
    idx2 = randperm(size(rdms,1),sz);

    rdm1 = nanmean(rdmv(idx1,:),1)'; %#ok<*NANMEAN> 
    rdm2 = nanmean(rdms(idx2,:),1)';
    
    if any(isnan(rdm1)) || any(isnan(rdm2))
        warning('Missing values')
    end

    truecorrsq(it) = (spearman_rho_a(rdm1,rdm2))^2;

    for icomb = 1:ncomb

        pred = comb{icomb};

        %train on videos, test on sentences
        lm = fitlm(pred,rdm1);
        rpred = predict(lm,pred); %get predicted responses
        big_rsq_mat(1,icomb,it) = (spearman_rho_a(rpred,rdm2))^2; %save rho-a squared

        %train on sentences, test on videos
        lm = fitlm(pred,rdm2);
        rpred = predict(lm,pred); %get predicted responses
        big_rsq_mat(2,icomb,it) = (spearman_rho_a(rpred,rdm1))^2; %save rho-a squared

        %variance inflation factor
        if icomb==1
            R0 = corrcoef(pred);
            vif(it,:) = diag(inv(R0))';
        end


    end
end

for dir = 1:2

    rsq_mat = squeeze(big_rsq_mat(dir,:,:));

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
varpart.total = squeeze(big_rsq_mat(:,1,:));
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
