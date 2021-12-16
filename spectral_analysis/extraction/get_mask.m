function [bw, band_ad, t, hist_smooth] = get_mask(effcube, b)

band_ad = imadjust(effcube(:, :, b));
[t, hist_smooth] = get_threshold(band_ad);
bw = imbinarize(band_ad, t/(2^16));
bw = bwareaopen(bw, 150, 8);    

end

