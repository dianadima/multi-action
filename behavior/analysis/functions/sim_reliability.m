function [rel] = sim_reliability(rdm, fpath, ftitle, color)
% get and plot RDM reliability: leave-one-out/split half with different metrics
% adapted for RDM where different subjects saw different subsets of stimuli
% inputs: rdm (Nsub x Npairs OR NSub x NStim x NStim)
%         fpath, figure path
%         ftitle, figure title
%         color, raincloud plot color
% DC Dima 2022 (diana.c.dima@gmail.com)

nsub = size(rdm,1);
if ndims(rdm)==3
    rdmvec = nan(nsub,(size(rdm,2)*(size(rdm,2)-1))/2);
    for isub = 1:nsub
        r = squeeze(rdm(isub,:,:));
        rdmvec(isub,:) = r(tril(true(size(r)),-1));
    end
else
    rdmvec = rdm;
end

%initialize
looS = nan(nsub,1); looSa = nan(nsub,1); %lower bound of noise ceiling (Spearman, Spearman rho-A)
uppS = nan(nsub,1); uppSa = nan(nsub,1); %upper bound of noise ceiling (Spearman, Spearman rho-A)
looRsqOrd = nan(nsub,1); uppRsqOrd = nan(nsub,1); %upper bound of noise ceiling (R-squared)
looRsqAdj = nan(nsub,1); uppRsqAdj = nan(nsub,1); %lower bound of noise ceiling (R-squared)

for isub = 1:nsub
    
    %select real-valued pairs
    subrdm = rdmvec(isub,:);
    idx = ~isnan(subrdm);
    subrdm = subrdm(idx);
    
    %select the same pairs & average all participants
    loordm = rdmvec(:,idx);
    allrdm = nanmean(loordm,1);

    %leave out participant and average the rest
    loordm(isub,:) = [];
    loordm = nanmean(loordm,1);
    
    %Spearman
    looS(isub) = corr(subrdm(:),loordm(:),'type','Spearman','rows','pairwise');
    uppS(isub) = corr(subrdm(:),allrdm(:),'type','Spearman','rows','pairwise');

    %Spearman's rho_A
    looSa(isub) = spearman_rho_a(subrdm(:),loordm(:));
    uppSa(isub) = spearman_rho_a(subrdm(:),allrdm(:));
    
    %R-squared
    lm = fitlm(loordm(:),subrdm(:));
    looRsqAdj(isub) = lm.Rsquared.Adjusted;
    looRsqOrd(isub) = lm.Rsquared.Ordinary;
    
    lm = fitlm(allrdm(:),subrdm(:));
    uppRsqAdj(isub) = lm.Rsquared.Adjusted;
    uppRsqOrd(isub) = lm.Rsquared.Ordinary;
    
end

%plot leave-one-out correlations
vec = [looS looSa];
lbl = {'Spearman''s rho', 'Spearman''s rho_A'};

if isempty(color), color = [0.5 0.7 0.8]; end

for l = 1:2
    
    figure
    raincloud_plot(vec(:,l),'color', color,'box_on',1)
    set(gca,'FontSize',18)
    xlabel(lbl{l})
    yticks([])
    box off
    if ~isempty(ftitle), title(ftitle,'FontWeight','normal');end
    
    print(gcf,'-dpng','-r300', fullfile(fpath,strrep(['reliability_loo_' lbl{l}(1:9-l) '_' ftitle],' ', '_')))
end

%get split-half reliability
nperm = 1000;
splithalfS = nan(nperm,1);
splithalfSa = nan(nperm,1);
nsamp = floor(nsub/2);
for p = 1:nperm
    
    idx = randperm(nsub,nsamp);
    
    rdm1 = rdmvec(idx,:);
    rdm1 = squeeze(nanmean(rdm1,1));
    
    rdm2 = rdmvec; rdm2(idx,:) = [];
    rdm2 = squeeze(nanmean(rdm2,1));
    
    splithalfS(p) = corr(rdm1(:),rdm2(:),'type','Spearman','rows','pairwise');
    splithalfSa(p) = spearman_rho_a(rdm1(:),rdm2(:));
end

%plot split-half reliability
vec = [splithalfS splithalfSa];
try
    for l = 1:2

        figure
        raincloud_plot(vec(:,l),'color', color,'box_on',1)
        set(gca,'FontSize',18)
        xlabel(lbl{l})
        yticks([])
        box off
        if ~isempty(ftitle), title(ftitle,'FontWeight','normal');end

        print(gcf,'-dpng','-r300', fullfile(fpath,strrep(['reliability_splithalf_' lbl{l}(1:9-l) '_' ftitle],' ', '_')))
    end
catch
end


rel.looS = looS;
rel.looSa = looSa;
rel.uppS = uppS;
rel.uppSa = uppSa;
rel.splithalfS = splithalfS;
rel.splithalfSa = splithalfSa;
rel.looRsqAdj = looRsqAdj;
rel.looRsqOrd = looRsqOrd;
rel.uppRsqAdj = uppRsqAdj;
rel.uppRsqOrd = uppRsqOrd;



end

