function [] = plot_varpart_stacked(vpfile_array)
% plot variance partitioning results as stacked bar plots

num_vp = numel(vpfile_array); %number of files to load
v = cell(num_vp,1);
for i = 1:num_vp
    v{i} = load(vpfile_array{i});
end

%plotting order & colors
order_idx = [1 3 4 2 5 6 7]; %abc bc ac ab a b c
[colors, legendstr] = plot_colorscheme(vpfile_array{1});
col = colors(order_idx,:);

%load and combine files for easy plotting
for i = 1:num_vp

    %get explained variance (averaged across directions for cross-modal anayses)
    varpart = v{i}.varpart;
    vp = varpart.pred;
    if size(vp,1)==2
        vp = squeeze(mean(vp,1));
    end

    %get range of noise ceiling
    vp = vp(order_idx,:);
    nc1(i) = min(varpart.true); %#ok<*AGROW>
    nc2(i) = max(varpart.true);

    %get mean and SD
    vp_avg(:,i) = mean(vp,2);
    vp_std(:,i) = std(vp,[],2);

end

%figure
hold on
for i = 1:num_vp
    rectangle('Position',[i-0.25 nc1(i) 0.5 nc2(i)-nc1(i)],'FaceColor',[0.85 0.85 0.85], 'EdgeColor','none')
end

b = bar(vp_avg',0.3,'stacked','FaceColor','flat');
ylim([0 0.25])
xlim([0.4 3.5])

for c = 1:7
    b(c).LineWidth = 1.2;
    b(c).CData = col(c,:);
end

%place errorbars correctly on top of the stacked portions
vsum = vp_avg; vsum(vsum<0) = 0;
vsum = cumsum(vsum);

for i = 1:num_vp
    for ii = 1:7
        e = errorbar(i,vsum(ii,i),vp_std(ii,i),'k','LineWidth',1.2);
        e.CapSize = 0;
    end
end

box off
set(gca,'FontSize',18)
set(gca,'TickLength',[0.0001 0.0001])
set(gca,'XTick',[1 2 3])
set(gca,'XTickLabel',{'Video','Sentence','Cross-modal'})
ylabel({'Variance explained','(Spearman''s {\rho}_A^2)'})
legend(legendstr); legend boxoff

end
