function [t, hist] = get_bimodel_threshold(band_ad)
%GET_THRESHOLD: the vally between two peak

img = band_ad;
hist = imhist(img);
hist_new = hist;

%% smooth the non-bi-peaks histogram

for i = 1:1000
    
    [is, ~] = Bimodal(hist);
    
    if is == 0 
        
        % 3 adjacent points smooth
        hist_new(1) = (hist(1)*2 + hist(2))/3;       
        for j = 2:255
            hist_new(j) = (hist(j-1) + hist(j) + hist(j+1))/3;
        end        
        hist_new(256) = (hist(255) + hist(256)*2)/3;
        hist = hist_new;    
           
    else
        break;   
    end
    
end

%% find the valley between 2 peaks

[~, peaks] = Bimodal(hist);
[~, position] = min(hist(peaks(1): peaks(2)));
threshold = position + peaks(1);

t = 256 * threshold;

end


function [is, peaks] = Bimodal(histgram)       
% to judge if the histgram has exactly two peaks and where they are.
% output:
%        is = 0 or 1
%        peak = [  ] = all peaks' positions

    count = 0;
    peaks = [];
    for j = 2:255
        if histgram(j-1) < histgram(j) && histgram(j+1) < histgram(j) 
            count = count+1;
            peaks(count) = j;
        end
        if count > 2
            break
        end
    end
    
    if count==2
        is=1;
    else
        is=0;
    end
    
end
