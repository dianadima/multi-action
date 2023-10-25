function [semantic] = vid_distribution(datapath,sidx)
% plot histograms to visualize how semantic features are distributed in
% stimulus set

load(fullfile(datapath,'videolabels.mat'),'videolabels')
videolabels = videolabels(sidx,:);

semantic_categ = {};
semantic_categ_idx = {};
semantic_categ_sum = {};


colors = parula(4);
figure

for col = 1:3

    tdata = table2cell(videolabels(:,col));
    for i = 1:numel(tdata), tdata{i} = char(tdata{i});end

    categories = unique(tdata);
    categories_idx = cell(numel(categories),1);
    catsum = nan(numel(categories),1);
    for i = 1:numel(categories)
        idx = find(contains(tdata,categories{i}));
        categories_idx{i} = idx;
        catsum(i) = numel(idx);
    end
    categories = cellfun(@(x) strrep(x,'_', ' '), categories, 'UniformOutput',false);

    semantic_categ{col} = categories;
    semantic_categ_idx{col} = categories_idx;
    semantic_categ_sum{col} = catsum;

    subplot(3,1,col)
    h = histogram('BinEdges',-(numel(catsum)/2):numel(catsum)/2, 'BinCounts',catsum);
    h.FaceColor = colors(col,:);
    h.EdgeColor = 'k';
    set(gca,'xtick',-(numel(catsum)/2)+0.5:numel(catsum)/2+0.5-1)
    set(gca,'xticklabels',categories);
    set(gca,'XTickLabelRotation',90)
    ylabel('Number of videos')
    %set(gca,'FontSize',18)
    clear h
    set(gca,'ticklength',[0.001 0.001])
    box off


end

semantic.categ = semantic_categ;
semantic.idx = semantic_categ_idx;
semantic.freq = semantic_categ_sum;

end

