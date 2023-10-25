function [] = sen_makeimg(stimpath,sentpath)
% make images displaying the sentences

slist = readtable(fullfile(stimpath,'sentences.csv'),'readvariablenames',0);

for s = 1:size(slist,1)

    img_name = sprintf('%.3d',s);
    text_string = table2array(slist(s,:));
    text_string = text_string{1};

    %split sentences into three blocks
    blocks = strsplit(text_string,'\');

    %remove trailing spaces
    for i = 1:3
        blocks{i} = strip(blocks{i});
    end
    
    text_string = sprintf(strcat(blocks{1}, '\n', blocks{2}, '\n', blocks{3}));
    
    text2image(text_string,fullfile(sentpath,img_name),[])



end