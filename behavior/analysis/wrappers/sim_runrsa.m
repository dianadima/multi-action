function [results] = sim_runrsa(rdmpath,modfile,rsafile)
% Run RSA analysis
% Inputs: rdmpath, path to behavioral RDM and noise ceiling
%         modfile, file with RSA models
%         rsafile, results file to be saved
% DC Dima 2022 (diana.c.dima@gmail.com)

load(fullfile(rdmpath,'rdm.mat'), 'rdm','rel')
load(modfile,'models','modelnames')   

%get path to save figures
[fpath,~,~] = fileparts(rsafile);
figpath = fullfile(fpath,'figures');

%% run subject-wise RSA

results = sim_rsa(rdm,models);

%plot results
ncSa = [mean(rel.looSa) mean(rel.uppSa)]; 
figure; sim_plotrsa(results.rsacorr,results.pvalcorr,results.avgcorr,ncSa,modelnames,'Spearman''s rho_A',[]);
print(gcf,'-r300','-dtiff',fullfile(figpath,'rsa_results'))

results.modelnames = modelnames;
results.noise_ceiling = ncSa;

save(rsafile,'-struct','results')



    function [] = sim_plotrsa(rsacorr,pval,fixedcorr,nc,modelnames,corrtype,color)
    %plot RSA results

    alpha = 0.005; %threshold p-values
    nmod = numel(modelnames);

    hold on
    line([0.5 nmod+0.5], [nc(1) nc(1)],'LineWidth',2,'color',[0.85 0.85 0.85]);
    rectangle('Position',[0.5 nc(1) nmod+1 nc(2)-nc(1)],'FaceColor',[0.85 0.85 0.85], 'EdgeColor','none')
    line([0 nmod+1], [0 0], 'color', 'k', 'LineWidth',2)

    cfg = [];
    cfg.scatter = 0;
    cfg.ylabel = corrtype;
    if ~isempty(color), cfg.color = color; else, cfg.color = [0.5 0.5 0.5]; end
    cfg.mrksize = 40;

    boxplot_jitter_groups(rsacorr',modelnames,cfg)
    if ~isempty(fixedcorr)
        plot(1:nmod,fixedcorr,'o','LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor',[0.9 0.9 0.9],'MarkerSize',10)
    end
    set(gca,'FontSize',18)
    for m = 1:nmod
        if pval(m)<alpha
            text(m-0.05, 0.38, '*' ,'FontSize',14) %note: text position is hard-coded
        end
    end

    box off
    xlim([0.5 nmod+0.5])



    end


end

