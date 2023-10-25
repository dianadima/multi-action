function [] = text2image(text_string,fig_name,cfg)

if ~isfield(cfg, 'img_size'), img_size = [400 600]; else, img_size = cfg.size; end
if ~isfield(cfg, 'font_size'), font_size = 12; else, font_size = cfg.font_size; end

figure('Color','w')
hold on

%write text
axis([0 img_size(2) 0 img_size(1)]);
text(img_size(2)/2-20, img_size(1)/2, text_string,...% 'Position', [img_size(2)/2 img_size(1)/2],...
    'FontName','Arial','FontSize',font_size,'FontWeight','normal','HorizontalAlignment','center');
axis off

%add outline around figure
annotation('line',[0,0],[0,1],'Color','k','LineWidth',1);
annotation('line',[1,1],[0,1],'Color','k','LineWidth',1);
annotation('line',[0,1],[0,0],'Color','k','LineWidth',1);
annotation('line',[1,0],[1,1],'Color','k','LineWidth',1);

%set correct dimensions for exporting
set(gcf,'Position',[0 0 img_size(2) img_size(1)])
set(gcf,'PaperUnits','inches')
set(gcf,'PaperPosition',[0 0 img_size(2)/300 img_size(1)/300])

%export
print(gcf,fig_name,'-dpng','-r300')
close

end
