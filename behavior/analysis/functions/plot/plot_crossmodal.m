function [] = plot_crossmodal(predfile)

pred = load(predfile);
nmod = 13; %all features except modality-specific ones

nc = pred.truecorr;
modelnames = pred.modelnames;
modelnames(contains(modelnames,'OpenAI')) = {'GPT'};
pval = pred.pvalcorr(1:nmod);

figure
hold on
rectangle('Position',[0.52 mean(nc)-std(nc) nmod+3+0.5 2*std(nc)],'FaceColor',[0.95 0.95 0.95], 'EdgeColor','none')
line([0 20], [0 0], 'color', 'k', 'LineWidth',2)

avgtot = mean(mean(pred.total,3),1);

% assign colours
c1 = [0.9 0.6 0.6]; %semantic
c2 = [0.8 0.8 0.5]; %contextual
c3 = [0.4 0.7 0.6]; %computational

colour = cell(1,nmod); 
colour(1:4) = {deal(c1)}; 
colour(5:7) = {deal(c2)}; 
colour(8:13) = {deal(c3)};

cfg = []; 
cfg.scatter = 0; 
cfg.ylabel = {'Prediction accuracy','Spearman''s \rho_A'}; 
cfg.color = colour; 
cfg.mrksize = 60;
cfg.axis = [1:4 6:8 10:15];

try
    p = mean(pred.predrho,3);
catch
    p = mean(pred.unique,3);
end
boxplot_jitter_groups(p(:,1:nmod)',modelnames(1:nmod),cfg) 
set(gca,'FontSize',18)
for m = 1:nmod
    if pval(m)<0.005
        if nmod>8
            text(cfg.axis(m)-0.15, 0.15, '*' ,'FontSize',14)
        else
            text(cfg.axis(m)-0.15, 0.14, '*' ,'FontSize',14) %note: text position is hard-coded
        end
    end
end

try
    %plot total variance
    for i = 1:nmod
        m = avgtot(i);
        ax = [cfg.axis(i)-0.4 cfg.axis(i)+0.4];
        line(ax,[m m],'color',colour{i},'linewidth',3);
    end
catch
end

box off
xlim([0.5 cfg.axis(end)+0.5])
ylim([-0.02 0.15])
yticks(0:0.02:0.15)

%% plot each direction of training & testing

figure

for i = 1:2
    subplot(1,2,i)
    hold on
    rectangle('Position',[0.52 mean(nc)-std(nc) nmod+3+0.5 2*std(nc)],'FaceColor',[0.95 0.95 0.95], 'EdgeColor','none')
    line([0 20], [0 0], 'color', 'k', 'LineWidth',2)

    try
        p = pred.predrho(:,:,i);
    catch
        p = pred.unique(:,:,i);
        avgtot = squeeze(mean(pred.total,1));
    end

    pval = pred.dir.pvalcorr(i,1:nmod);

    boxplot_jitter_groups(p(:,1:nmod)',modelnames(1:nmod),cfg)
    set(gca,'FontSize',18)
    for m = 1:nmod
        if pval(m)<0.005
            if nmod>8
                text(cfg.axis(m)-0.15, 0.16, '*' ,'FontSize',14)
            else
                text(cfg.axis(m)-0.15, 0.14, '*' ,'FontSize',14) %note: text position is hard-coded
            end
        end
    end

    box off
    xlim([0.5 cfg.axis(end)+0.5])
    ylim([-0.04 0.16])
    yticks(0:0.02:0.16)

    try
        %plot total variance
        for m = 1:nmod
            mt = avgtot(m,i);
            ax = [cfg.axis(m)-0.4 cfg.axis(m)+0.4];
            line(ax,[mt mt],'color',colour{m},'linewidth',3);
        end
    catch
    end

end













end