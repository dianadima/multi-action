function [] = plot_varpart_venn(vpfile_array)
% plot variance partitioning results as venn diagrams

num_vp = numel(vpfile_array); %number of files to load
v = cell(num_vp,1);
for i = 1:num_vp
    v{i} = load(vpfile_array{i});
end

%reorder for venn plotting
comb_idx = [5 6 7 2 4 3 1];

for i = 1:num_vp

    vpred = v{i}.pred;
    if size(vpred,1)==2
        vp = squeeze(mean(vpred,1));
    end

    %reorder, scale, and set negatives to 0
    vp = mean(vp(comb_idx,:),2)*100;
    vp(vp<0) = 0;

    figure
    venn(vp,'ErrMinMode','ChowRodgers')
    axis off

  
end