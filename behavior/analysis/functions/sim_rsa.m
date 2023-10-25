function [results] = sim_rsa(rdm,models)

%initialize variables
nsub = size(rdm,1);      %number of subjects
nmod = size(models,2);      %number of models

rsacorrSa = nan(nsub,nmod);  %Spearman's rho_A
rsaAdRsq = nan(nsub,1);     %var explained by all models - adjusted R^2
rsaOdRsq = nan(nsub,1);     %var explained by all models - ordinary R^2

%subject-wise RSA
for isub = 1:nsub
    
    %remove any stimulus pairs missing
    rsub = rdm(isub,:);
    idx = ~isnan(rsub);
    rsub = rsub(idx);
    msub = models(idx,:);
    
    %Spearman
    cmatSa = corr([rsub(:) msub]);
    rsacorrSa(isub,:) = cmatSa(1,2:end);

    %regression
    lm = fitlm(msub, rsub(:));
    rsaAdRsq(isub) = lm.Rsquared.Adjusted;
    rsaOdRsq(isub) = lm.Rsquared.Ordinary;
    
end

%stats
[pvalSa,~,~,pval_corrSa] = randomize_rho(rsacorrSa,'num_iterations',5000);

%fixed-effects RSA using whole average RDM
avgrdm = nanmean(rdm,1); %#ok<*NANMEAN> 
avgcorrSa = spearman_rho_a([avgrdm(:) models]);
avgcorrSa = avgcorrSa(1,2:end);

lm = fitlm(models,avgrdm(:));
avgAdRsq = lm.Rsquared.Adjusted; 
avgOdRsq = lm.Rsquared.Ordinary;

results.rsacorr = rsacorrSa;
results.pvalraw = pvalSa;
results.pvalcorr = pval_corrSa;
results.avgcorr = avgcorrSa;

results.regr.ind_rsqadj = rsaAdRsq;
results.regr.avg_rsqadj = avgAdRsq;
results.regr.ind_rsqord = rsaOdRsq;
results.regr.avg_rsqord = avgOdRsq;

end