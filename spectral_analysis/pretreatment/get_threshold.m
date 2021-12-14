function [t, hist_smooth] = get_threshold(band_ad)
%GET_THRESHOLD: the vally between 0-12000

img = band_ad;
hist_ori = imhist(img);
hist_smooth = hist_ori;
region = floor(10000/256);
hist_region = hist_ori(1:region);
hist_new = hist_region;

%% smooth the non-bi-peaks histogram

for i = 1:10

        % 3 adjacent points smooth
        hist_new(1) = (hist_region(1)*2 + hist_region(2))/3;       
        for j = 2:region-1
            hist_new(j) = (hist_region(j-1) + hist_region(j) + hist_region(j+1))/3;
        end        
        hist_new(region) = (hist_region(region-1) + hist_region(region)*2)/3;
        hist_region = hist_new;    
   
end

%% find the valley
hist_smooth(1:region) = hist_region;

[~, position] = min(hist_region);
threshold = position;

t = 256 * threshold;

end
