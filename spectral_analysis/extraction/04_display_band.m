function [] = display_band(rawcube, b)

sample_band = imadjust(rawcube(:, :, b));
figure;
imhist(sample_band);
title('sample band adjusted histogram');
figure;
imshow(sample_band);
title('sample band adjusted');

end

