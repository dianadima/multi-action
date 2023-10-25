function [sidx] = vid_updateidx(results)

sidx = results.subset_idx(results.idx_mincorr,:);

idx_orig = [11 15 20 29 37 38 49 53 55 60 64 69 73 81 84 90 26 23 33 36 51 80]; %last 5 added in 2nd pass
idx_repl = [51 24 22 89 64 94 151 133 125 140 176 193 205 225 228 219 75 76 91 106 151 199]; %indices of videos to use as replacements
idx_clear = [5 6 7 99 100]; %repetitive videos to remove

sidx(idx_orig) = idx_repl; 
sidx(idx_clear) = [];




end