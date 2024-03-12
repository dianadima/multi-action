function [varpart] = sim_varpartcv(rdm,model1,model2,model3)
% cross-validated variance partitioning analysis
% runs cross-validation across action stimuli (leave-one-out)
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


%must subsample stimuli, not participants
nvid = 95; %num actions
ncomb = 7; %num regressions to run
nit = 100; %100 iterations of LOO-CV with different data splits

%sample about half
nsub = size(rdm,1);
sz = floor(nsub/2);

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
rsq_mat = nan(ncomb,nvid,nit);

for it = 1:nit

    idx = randperm(nsub,sz);
    rdm1 = nanmean(rdm(idx,:),1)'; %#ok<*NANMEAN>
    rdm2 = rdm; rdm2(idx,:) = [];
    rdm2 = nanmean(rdm2,1)';

    truecorrsq(it) = (spearman_rho_a(rdm1,rdm2))^2;

    rdm1 = squareform(rdm1);
    rdm2 = squareform(rdm2);

    %loop
    for v = 1:nvid


        rdmtrain = rdm1; rdmtrain(v,:) = []; rdmtrain(:,v) = []; rdmtrain = squareform(rdmtrain);
        rdmtest = rdm2(v,:); rdmtest(v) = []; %remove diagonal


        for icomb = 1:ncomb

            pred = comb{icomb};
            predtrain = []; predtest = [];

            for n = 1:size(pred,2) %for each model - select

                tmp = pred(:,n);
                tmp = squareform(tmp);
                tmptrain = tmp; tmptrain(v,:) = []; tmptrain(:,v) = [];
                tmptest = tmp(v,:); tmptest(v) = [];
                predtrain(:,n) = squareform(tmptrain); %#ok<*AGROW> 
                predtest(:,n) = tmptest;
            end

            %train and test
            lm = fitlm(predtrain,rdmtrain(:));
            rpred = predict(lm,predtest); %get predicted responses
            rsq_mat(icomb,v,it) = (spearman_rho_a(rpred,rdmtest(:)))^2; %save rho-a squared

            %variance inflation factor
            if icomb==1
                R0 = corrcoef(predtrain);
                vif(it,v,:) = diag(inv(R0))';
            end

        end
    end

end

%average across videos
rsq_mat = mean(rsq_mat,2);

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







