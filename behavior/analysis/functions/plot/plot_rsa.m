function [] = plot_rsa(rsafile)
% plot RSA results (feature-behavior correlations)

results = load(rsafile);

%set colors
c1 = [0.9 0.6 0.6]; %semantic
c2 = [0.8 0.8 0.5]; %contextual
c3 = [0.4 0.7 0.6]; %computational
c4 = [0.6 0.6 0.8]; %modality-specific

%threshold p-values
alpha = 0.005; 

nmod = numel(results.modelnames);
results.modelnames(contains(results.modelnames,'OpenAI')) = {'GPT'};
nc = results.noise_ceiling;
pval = results.pvalcorr;

% make a colour cell array for all feature RDMs
colour = cell(1,nmod);
colour(1:4) = {deal(c1)};
colour(5:7) = {deal(c2)};
colour(8:13) = {deal(c3)};
colour(14:18) = {deal(c4)};

%select modality-specific models
if contains(rsafile,'vid')
    midx = 1:16; label = 'Video';
else
    midx = [1:13 17:18]; label = 'Sentence';
end

%grouping of models on x-axis (to get spacing between groups)
x_axis = [1:4 6:8 10:12 13.5:15.5 17.5:21.5];

hold on
rectangle('Position',[0.5 nc(1) x_axis(end)+1 nc(2)-nc(1)],'FaceColor',[0.9 0.9 0.9], 'EdgeColor','none')
line([0 x_axis(end)+1], [0 0], 'color', 'k', 'LineWidth',2)

cfg = []; 
cfg.scatter = 0; 
cfg.axis = x_axis(1:numel(midx));
cfg.ylabel = {'Feature - behavior correlation','(Spearman''s \rho_A)'}; 
cfg.color = colour(midx); 
cfg.mrksize = 60;

boxplot_jitter_groups(results.rsacorr(:,midx)',results.modelnames(midx),cfg) 
set(gca,'FontSize',18)

pval = pval(midx);
for m = 1:numel(midx)
    if pval(m)<alpha
        text(x_axis(m)-0.05, 0.33, '*' ,'FontSize',14) %text position is hard-coded
    end
end

box off
xlim([0.5 cfg.axis(end)+0.5])
ylim([-0.05 0.35])
yticks(0:0.1:0.3)

title(label,'FontWeight','normal')




end