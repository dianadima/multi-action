function [] = plot_tsne(rdm, categories, text_array)
% plot RDM as a tsne colour-coded and verb-labeled plot

if isvector(rdm), rdm = squareform(rdm); end
Y = tsne(rdm,'Algorithm','exact','Distance','euclidean');

nvid = size(rdm,1);
ncat = numel(unique(categories));

%make color matrix
colors = zeros(nvid,3);
c = lines(ncat+1); 
for i = 1:ncat
    idx = categories==i;
    colors(idx,:) = repmat(c(i,:),sum(idx),1);
end


figure
hold on
ts = textscatter(Y,text_array,'ColorData',colors,'TextDensityPercentage',60);
ts.FontSize = 14;
ts.MarkerSize = 20;
set(gca,'FontSize',20)
box off
yticks([])
xticks([])
set(gca,'XColor','none')
set(gca,'YColor','none')