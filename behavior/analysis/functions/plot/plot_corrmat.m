function [] = plot_corrmat(modfile)
% plot model intercorrelation matrix

load(modfile,'mcorrSa','modelnames')
modelnames(contains(modelnames,'OpenAI')) = {'GPT'};

figure
plot_rdm(mcorrSa,modelnames,[],0,1)

ax = gca;

% change label colours
for i = 1:4
    ax.XTickLabel{i} = ['\color[rgb]{0.9, 0.6, 0.6}' ax.XTickLabel{i}];
    ax.YTickLabel{i} = ['\color[rgb]{0.9, 0.6, 0.6}' ax.YTickLabel{i}];
end
for i = 5:7
    ax.XTickLabel{i} = ['\color[rgb]{0.8, 0.8, 0.5}' ax.XTickLabel{i}];
    ax.YTickLabel{i} = ['\color[rgb]{0.8, 0.8, 0.5}' ax.YTickLabel{i}];
end
for i = 8:13
    ax.XTickLabel{i} = ['\color[rgb]{0.4, 0.7, 0.6}' ax.XTickLabel{i}];
    ax.YTickLabel{i} = ['\color[rgb]{0.4, 0.7, 0.6}' ax.YTickLabel{i}];
end
for i = 14:18
    ax.XTickLabel{i} = ['\color[rgb]{0.6, 0.6, 0.8}' ax.XTickLabel{i}];
    ax.YTickLabel{i} = ['\color[rgb]{0.6, 0.6, 0.8}' ax.YTickLabel{i}];
end

colormap(flipud(bone))
