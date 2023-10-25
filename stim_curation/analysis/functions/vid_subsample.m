function [results] = vid_subsample(categories,categories_idx, models, modelnames, videolabels, nstim, niter, balanced)

rng(10)

%d = load(loadfile,'categories*');

ncat = length(categories);
nstim_orig = sum(cellfun(@length,categories_idx));

sub_idx = nan(niter,nstim);

for it = 1:niter

    idx = cell(1,ncat);

    for ic = 1:ncat

        nstim_categ = balanced(ic);

        catidx = categories_idx{ic}';
        catidx = catidx(randperm(length(catidx)));
        idx{ic} = catidx(1:nstim_categ);
    end

    idx = [idx{:}];
    sub_idx(it,:) = idx(:);
end

nmod = size(models,2);
sqmodels = nan(nstim_orig,nstim_orig,nmod);

for im = 1:nmod
    sqmodels(:,:,im) = squareform(squeeze(models(:,im)));
end

sub_mcorrs_sq = nan(nmod,nmod,niter);
sub_mcorrs_vc = nan(nmod*(nmod-1)/2,niter);

for it = 1:niter

    sub_sqmodels = sqmodels(sub_idx(it,:),sub_idx(it,:),:);
    sub_models = nan(nstim*(nstim-1)/2,nmod);
    for im = 1:nmod
        sub_models(:,im) = squareform(squeeze(sub_sqmodels(:,:,im)));
    end

    cidx = [1 2 3 8 9 11 12];
    for ic = 1:7

        col = cidx(ic);

        tdata = table2cell(videolabels(:,col));
        tdata = tdata(sub_idx(it,:));
        nvid = numel(tdata);
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

            for c = 1:length(categories)
                yidx = categories_idx{c};
                nidx = 1:nvid; nidx(yidx) = [];
                categ(yidx, nidx) = 1;
                categ(nidx, yidx) = 1;
            end

        end

        sub_models(:,ic) = categ(tril(true(size(categ)),-1));

    end

    sub_mcorrs = corr(sub_models,'type','Spearman','rows','pairwise');
    sub_mcorrs_sq(:,:,it) = sub_mcorrs;
    sub_mcorrs_vc(:,it) = sub_mcorrs(tril(true(size(sub_mcorrs)),-1));

end

[mincorr, idx_mincorr] = min(mean(sub_mcorrs_vc,1));

fprintf('\nMinimum overall correlation of %f in subset %d', mincorr, idx_mincorr);

%get models for subset with lowest overall correlation
suball = sub_idx(idx_mincorr,:)';
suballmodels = sqmodels(suball,suball,:);
sub_models = nan(nstim*(nstim-1)/2,nmod);
for im = 1:nmod
    sub_models(:,im) = squareform(squeeze(suballmodels(:,:,im)));
end

results.subset_idx = sub_idx;
results.models = sub_models;
results.mcorrs = sub_mcorrs_sq;
results.modelnames = modelnames;
results.idx_mincorr = idx_mincorr;




end