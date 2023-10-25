function [feat,featrdm] = sen_embeddings(stimpath)
%get semantic embeddings using FastText

slist = readtable(fullfile(stimpath,'sentences.csv'),'readvariablenames',0, 'Delimiter','none');
nsen = size(slist,1);

mdl = fastTextWordEmbedding;
featmat = nan(nsen,12,300);

% also save num of words and chars per sentence
numwords = nan(nsen,1);
numchars = zeros(nsen,1);

for s = 1:nsen

    sentence = table2array(slist(s,:));
    sentence = split(sentence{1}, ' '); %split into words
    numwords(s) = numel(sentence); %save number of words

    for w = 1:numel(sentence)

        word = sentence{w};

        numchars(s) = numchars(s) + length(word);

        %remove trailing dots, possessives, & backslashes
        word = strrep(word,'.',' ');
        word = strrep(word,'''s',' ');
        word = strrep(word,'\', ' ');
        word = strip(word);

        wordvec = word2vec(mdl,word,'IgnoreCase',true);

        if ~isnan(wordvec(1))
            featmat(s,w,:) = wordvec;
        else
            fprintf('\nNo embedding found for %s in sentence %d\n',word,s);
        end

    end

end

%get rdm
featavg = squeeze(nanmean(featmat,2));
featrdm = pdist(featavg);
featrdm = (featrdm - min(featrdm))/(max(featrdm)-min(featrdm));

%get features
feat.featmat = featmat;
feat.numwords = numwords;
feat.numchars = numchars;

% %plot rdm
% figure; imagesc(squareform(featrdm))
% colormap("bone"); axis off
% title('Semantic embedding RDM','FontWeight','normal','FontSize',18)

