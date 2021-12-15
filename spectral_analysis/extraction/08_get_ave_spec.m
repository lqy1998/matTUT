function [data, label] = get_ave_spec(rawcube, bw)

[label, num] = bwlabel(bw); 

lines = size(rawcube, 1);
samples = size(rawcube, 2);
bands = size(rawcube, 3);

data = zeros(bands, num);

for n = 1:num
    
    mask = (label == n);
    roi = zeros(lines, samples, bands);

    for i = 1:lines
        for j = 1:samples
            if mask(i, j) == 1
                roi(i, j, :) = rawcube(i, j, :);        
            end
        end
    end  
    
    roi(roi == 0) = NaN;
    
    for k = 1:bands
        rois = reshape(roi(:, :, k), 1, lines*samples);
        data(k, n) = mean(rois, 'omitnan');
    end

end

data = data';

end

