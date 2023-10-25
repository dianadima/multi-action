function [colors, legendstring] = plot_colorscheme(vpfile)
% helper function selecting colors for stacked variance plots
% that match venn diagrams (where colors were manually chosen)
% also assigns correct legend for each analysis

%start with some baseline colors that recur
c1 = [246,195,89]/255; %abc: shared x3
c5 = [199,114,131]/255; %a: target
c6 = [255,226,211]/255; %b: class
c2 = [233,169,161]/255; %ab: shared target-class

%check type of analysis and assign colors
if contains(vpfile,'openai_parts') 
    c5=[184,209,145]/255;
    c6=[147,209,209]/255;
    c7=[145,154,209]/255;
    c2=[117,191,166]/255;
    c3=[102,136,191]/255;
    c4=[118,136,166]/255;
    c1=[91,129,174]/255;
    legendstring = {'','','','','Agent','Action','Context'}; %unique variance colors labeled

elseif contains(vpfile,'openai')
    c3 = [125,167,161]/255; %bc: shared class-comp
    c4 = [102,122,129]/255; %ac: shared target-comp
    c7 = [125,179,179]/255; %c: comp
    c1 = [117,144,141]/255; %abc
    legendstring = {'','','','Target','Class','GPT'};

elseif contains(vpfile,'grouped')
    c1 = [97,161,139]/255; %abc
    c2 = [0.77 0.58 0.7]; %ab: sem-soc
    c3 = [0.7 0.77 0.6]; %bc: soc-perc
    c4 = [0.77 0.77 0.52]; %ac: sem-perc
    c5 = [0.96 0.69 0.65]; %a: sem
    c6 = [0.79 0.7 0.84]; %b: soc
    c7 = [0.78 0.89 0.66]; %c: perc
    legendstring = {'','','','','Semantic','Social','Perceptual'};   

else %all semantic - use warm colors 
    c3 = [255,218,108]/255; %bc
    c4 = [0.7 0.7 0.7]; %ac
    c7 = [255,229,127]/255; %c
    legendstring = {'','','','','Target','Class','Activity'};

end

colors = [c1;c2;c3;c4;c5;c6;c7];



end