function [mod] = vid_makerdm(datapath, sidx)
% make video feature models

%load features and video labels
dnnet = load(fullfile(datapath,'feat_vid','alexnet_features249.mat'),'feat');
moten = load(fullfile(datapath,'feat_vid','motion_energy249.mat'),'feat');
load(fullfile(datapath,'videolabels.mat'),'videolabels');

headers = videolabels.Properties.VariableNames;

videolabels = videolabels(sidx,:);
nvid = size(videolabels,1);

models = nan(nvid*(nvid-1)/2,8);
modelnames = cell(8,1);

figure
colcount = 0;

for col = 1:12

    %categorical models
    if ismember(col,[1 2 3 8 9 11 12])

        colcount = colcount+1;

        %get indices of each value in each column
        tdata = table2cell(videolabels(:,col));
        for i = 1:nvid, tdata{i} = char(tdata{i});end
        categories = unique(tdata);
        categories_idx = cell(numel(categories),1);
        for i = 1:numel(categories)
            idx = find(contains(tdata,categories{i}));
            categories_idx{i} = idx;
        end

        %make rdm
        categ = zeros(nvid,nvid);

        %gender - we have a middle category
        if col==8
            categ(categories_idx{1},categories_idx{2}) = 0.5;
            categ(categories_idx{2},categories_idx{1}) = 0.5;

            categ(categories_idx{1},categories_idx{3}) = 0.5;
            categ(categories_idx{3},categories_idx{1}) = 0.5;

            categ(categories_idx{1},categories_idx{4}) = 0.5;
            categ(categories_idx{4},categories_idx{1}) = 0.5;

            categ(categories_idx{2},categories_idx{3}) = 1;
            categ(categories_idx{3},categories_idx{2}) = 1;
        
        else
            
            %binary models
            for c = 1:length(categories)
                yidx = categories_idx{c};
                nidx = 1:nvid; nidx(yidx) = [];
                categ(yidx, nidx) = 1;
                categ(nidx, yidx) = 1;
            end

        end

        %plot
        subplot(2,4,colcount) 
        imagesc(categ)
        colormap("bone")
        xticks(); xticklabels(' ')
        yticks(); yticklabels(' ')
        title(headers{col},'FontWeight','normal','FontSize',18)

        models(:,colcount) = categ(tril(true(size(categ)),-1));
        modelnames{colcount} = headers{col};
        if col==11, modelnames{colcount} = 'Tool use'; end

    %number of agents    
    elseif col==7

        tdata = table2array(videolabels(:,col));
        models(:,8) = pdist(tdata);
        modelnames{8} = 'Number of agents';

        p = pdist(tdata);
        p = (p-min(p))/(max(p)-min(p));
        subplot(2,4,8)
        imagesc(squareform(p))
        colormap("bone")
        xticks(); xticklabels(' ')
        yticks(); yticklabels(' ')
        title(headers{col},'FontWeight','normal','FontSize',18)


    end

end

%alexnet features
for il = 1:2
    f = dnnet.feat{il};
    f = f(sidx,:);
    models(:,8+il) = pdist(f);
end

modelnames{9} = 'Conv1';
modelnames{10} = 'FC8';

%motion energy
feat = squeeze(nanmean(moten.feat,2)); %#ok<NANMEAN> 
models(:,11) = pdist(feat(sidx,:));
modelnames{11} = 'Motion energy';

if numel(sidx) == 95
    load(fullfile(datapath,'feat_vid','effector_rdm.mat'),'effector_rdm')
    load(fullfile(datapath,'feat_vid','clip_rdm.mat'),'clip')
    models(:,12) = effector_rdm;
    models(:,13) = clip;
    modelnames(12:13) = {'Effectors','CLIP'};
end

%normalize model RDMs
nmod = size(models,2);
for m = 1:nmod
    models(:,m) = (models(:,m)-min(models(:,m)))/(max(models(:,m))-min(models(:,m)));
end

%get inter-model correlations
mcorrS = corr(models,'type','Spearman','rows','pairwise');
mcorrSa = spearman_rho_a(models);
mcorrK = nan(nmod,nmod);
for i = 1:nmod
    mcorrK(i,i) = 1;
    for j = i+1:nmod
        mcorrK(i,j) = rankCorr_Kendall_taua(models(:,i),models(:,j));
        mcorrK(j,i) = mcorrK(i,j);
    end
end

%plot correlation matrices
labels = {'Spearman''s \rho', 'Spearman''s \rho_A', 'Kendall''s \tau_A'};
data = {mcorrS, mcorrSa, mcorrK};

for fig = 1:3
    figure
    plot_rdm(data{fig},modelnames,[],0,1)
    c = colorbar;
    c.Label.String = labels{fig};
end

mod.models = models;
mod.modelnames = modelnames;
mod.mcorrS = mcorrS;
mod.mcorrSa = mcorrSa;
mod.mcorrK = mcorrK;



        
%     {'Repertoire'    }1
%     {'Activity'      }2
%     {'Verb'          }3
%     {'Number'        }4
%     {'VideoName'     }5
%     {'Sentence'      }6
%     {'NumberOfAgents'}7 --> this is the only numerically meaningful one
%     {'Gender'        }8 %F,M,Both,Unclear
%     {'Setting'       }9 %I,O,Unclear
%     {'Setting_word'  }10
%     {'Tool'          }11%0,1
%     {'Target'        }12%Object,Person,Self
  