function [data_resorted, data, label_positions, label] = get_ave_spec(rawcube, bw)
%%
[label, num] = bwlabel(bw); 
%BWLABEL Label connected components in 2-D binary image.
%   L:    matrix L, of the same size as BW, containing labels for the connected components in BW. 
%         The pixels labeled 0 are the background.  
%         The pixels labeled 1 make up one object, the pixels labeled 2 make up a second object, and so on.
%   NUM:  returns in NUM the number of connected objects found in BW.
%
%   BW:   can be logical or numeric, and it must be real, 2-D, and nonsparse.
%   mode: can have a value of either 4 or 8, where 4 specifies 4-connected objects and 8 specifies 8-connected objects; 
%         it defaults to 8.

  
lines = size(rawcube, 1);
samples = size(rawcube, 2);
bands = size(rawcube, 3);

%%
row_num = 5;
col_num = 5;
label_positions = zeros(row_num, col_num);
 for col = 1:col_num
     position_vec = zeros(row_num, 1);
     for count = row_num*(col-1)+1 : row_num*col
         mask_tem = (label == count);
         [xlabels, ~] = find(mask_tem);
         position_vec(count - row_num*(col-1)) = mean(xlabels);        
     end
     [~, ind] = sort(position_vec);
     label_positions(:, col) = ind + row_num*(col-1); 
 end
 
 final_labelvec = reshape(label_positions, row_num*col_num, 1);
% label_positions
% imshow((datalabel-20)*0.2)
% final_labelvec

%% 
data = zeros(num, bands);
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
        data(n, k) = mean(rois, 'omitnan');
    end

end

data_resorted = data(final_labelvec, :);
end

