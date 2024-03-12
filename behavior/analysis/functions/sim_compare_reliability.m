function [rel] = sim_compare_reliability(file1, file2)
%calculate, compare and plot reliability across modalities

nsamp = 16; %keep N consistent (subsampling)
nperm = 1000; 

% load rdms
vid_rdm = load(file1); vid_rdm = vid_rdm.rdm;
sen_rdm = load(file2); sen_rdm = sen_rdm.rdm;
rdm_array = {vid_rdm,sen_rdm};

% unimodal reliability
for f = 1:2

    sh = nan(nperm,1); 
    shr = nan(nperm,1);
    rdm = rdm_array{f};
    nsubj = size(rdm,1);

    for p = 1:nperm

        idx = randperm(nsubj,nsamp);
        
        rdm1 = rdm(idx,:); 
        rdm1 = squeeze(nanmean(rdm1,1));
        
        rdm2 = rdm; rdm2(idx,:) = [];

        %remove some extra participants if there are more than 16 remaining
        if numel(rdm2,1)>16, idx = randperm(numel(rdm2,1)-16); rdm2(idx,:) = []; end
        rdm2 = squeeze(nanmean(rdm2,1));
        
        sh(p) = spearman_rho_a(rdm1(:),rdm2(:));

        % compute chance reliability
        shr(p) = spearman_rho_a(rdm1(:),rdm2(randperm(size(rdm2,2)))');

    end

    if f==1, rel_vid = sh; baseline_vid = shr; else, rel_sen = sh; baseline_sen = shr; end
end

% cross-modal reliability
rel_cm = nan(nperm,1);
baseline_cm = nan(nperm,1);
for p = 1:nperm
    idx1 = randperm(size(vid_rdm,1),nsamp);
    idx2 = randperm(size(sen_rdm,1),nsamp);

    rdm1 = vid_rdm(idx1,:);
    rdm1 = squeeze(nanmean(rdm1,1));

    rdm2 = sen_rdm(idx2,:);
    rdm2 = squeeze(nanmean(rdm2,1));

    rel_cm(p) = spearman_rho_a(rdm1(:),rdm2(:));

    baseline_cm(p) = spearman_rho_a(rdm1(:),rdm2(randperm(size(rdm2,2)))');
end

% get stats
[p(1),~,stats{1}] = signrank(rel_vid,rel_sen);
[p(2),~,stats{2}] = signrank(rel_cm,rel_sen);
[p(3),~,stats{3}] = signrank(rel_cm,rel_vid);

%check that each is over 0
%(same result if checking against empirical baseline)
[pzero(1),~,szero(1)] = signrank(rel_vid);
[pzero(2),~,szero(2)] = signrank(rel_sen);
[pzero(3),~,szero(3)] = signrank(rel_cm);

rel.vid = rel_vid;
rel.sen = rel_sen;
rel.cm = rel_cm;
rel.pval = p;
rel.stats = stats;
rel.baseline.vid = baseline_vid;
rel.baseline.sen = baseline_sen;
rel.baseline.cm = baseline_cm;
rel.baseline.pval = pzero;
rel.baseline.stats = szero;
save(fullfile(fileparts(fileparts(file1)),'reliability.mat'),'rel')

% plot reliability

figure
d{1,1} = rel_vid; d{1,2} = rel_sen; d{1,3} = rel_cm;
labels = {'Video','Sentence','Cross-modal'};
colours = [0.6 0.5 0.7; 0.4 0.7 0.7;[0.6 0.8 0.4]];

h = rm_raincloud(d,colours);

set(gca,'FontSize',20)
set(gca,'ytick',[])
legend([h.p{1,1}, h.p{1,2},h.p{1,3}],labels)
legend box off
xticks(0.2:0.1:0.5)
xlim([0.2 0.5])
ax = get(gca);
ax.YAxis.Visible = 'off';







end