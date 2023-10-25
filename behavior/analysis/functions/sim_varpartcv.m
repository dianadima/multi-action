function [varpart] = sim_varpartcv(rdm,model1,model2,model3)
% cross-validated variance partitioning analysis
% runs split-half cross-validation
% uses Spearman's rho-A squared as prediction metric
% 
% inputs: rdm (vectorized, Nsub x Npairs)
%         model1, model2, model3: predictors (Nmodel x Npairs)
%
% output: varpart, structure containing
%                rsq_adj, adjusted R-squared for each combination of models
%                comb_labels, order of model combinations (i.e. abc, ab, bc, ac, a, b, c)
%                total_rsq, total variance explained by the models (adjusted R-squared)
%                noiseceil, upper and lower bounds of noise ceiling (cf. Nili et al 2014)
%
% DC Dima 2022 (diana.c.dima@gmail.com)

nsub = size(rdm,1);
sz = floor(nsub/2);
nit = 100;

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

%loop
rsq_mat = nan(ncomb,nit);
comb_labels = {'abc','ab','bc','ac','a','b','c'};

for it = 1:nit


    idx = randperm(nsub,sz);
    rdm1 = nanmean(rdm(idx,:),1)'; %#ok<*NANMEAN> 
    
    rdm2 = rdm;
    rdm2(idx,:) = [];
    rdm2 = nanmean(rdm2,1)';
    
    if any(isnan(rdm1)) || any(isnan(rdm2))
        warning('Missing values')
    end


    truecorrsq(it) = (spearman_rho_a(rdm1,rdm2))^2;

    for icomb = 1:ncomb

        pred = comb{icomb};

        lm = fitlm(pred,rdm1);
        rpred = predict(lm,pred); %get predicted responses

        rsq_mat(icomb,it) = (spearman_rho_a(rpred,rdm2))^2; %save rho-a squared

        %variance inflation factor
        if icomb==1
            R0 = corrcoef(pred);
            vif(it,:) = diag(inv(R0))';
        end


    end
end

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

var_mat = [abc;ab;bc;ac;a;b;c]; %7

varpart.pred = var_mat;
varpart.total = rsq_mat(1,:);
varpart.comb_labels = comb_labels;
varpart.true = truecorrsq;
varpart.vif = vif;

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

