function [] = display_pixel(cube, shift, line, sample)

bandnum = size(cube, 3);
sample_pixel = cube(line, sample, :);
sample_pixel = reshape(sample_pixel, 1, bandnum);
figure;
plot(shift, sample_pixel);
title('sample pixel')
xlabel('Ramanshift(cm-1)')
ylabel('intensity(au)')

end

