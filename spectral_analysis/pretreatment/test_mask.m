function [] = test_mask(seed_variety, file_name)
% PRETREATMENT: a function to pretreat raw & hdr format hyperspectral data 
% input:
%       seed_variety: seed variety like zd958/jd20/nh816/jh5/zd958nc
%       file_name: file name like 25/50/75/100
%
% output:
%       figure1: 477 nm-1 
%       figure2: original histogram
%       figure3: smooth histogram and threshold
%       figure4: original mask
%       figure5: morphological mask
%
% author:
%       Liu Qingyun    contact: liuqingyun98@gmail.com

%% inside paras

root_path = 'D:\files\spectral_analysis\mat_demo\data\';
file_name = num2str(file_name);

%% get datacube

% file path
hdr_path_name = strcat(root_path, seed_variety, '\', file_name, '.hdr');
raw_path_name = strcat(root_path, seed_variety, '\', file_name, '.raw');

% get dimensions and waves
info = get_info(hdr_path_name);
[samples, lines, bands, wavelengths] = get_dimensions(info);

% raman shift
raman_shift = 10^7/785 - 10^7./wavelengths;

% get datacube
rawdata = get_rawdata(raw_path_name);
rawcube0 = reshape(rawdata, [samples, bands, lines]);
rawcube = permute(rawcube0, [3, 1, 2]);

% effective raman shift 
[~, p1] = min(abs(raman_shift - 400));
[~, p2] = min(abs(raman_shift - 1800));
effshift = raman_shift(p1:p2);

% define effcube
effcube = rawcube(:, 385:875, p1:p2);
efflines = size(effcube, 1);
effsamples = size(effcube, 2);
effbands = size(effcube, 3);

%% mask

% effective band for mask
[~, b] = min(abs(effshift - 477));

% mask 
data_name = strcat(seed_variety, '_', num2str(file_name));

img = imadjust(effcube(:, :, b));
figure; imshow(img); title(data_name)

[bw, t, hist] = get_mask(effcube, b);

figure; imhist(img); title(data_name, 'original histogram')
figure; bar([0:255]*256, hist); hold on; xline(t); title(data_name, 'threshold')
figure; imshow(bw); title(data_name, 'original mask')


% morphology
se1 = strel('disk', 8);
se2 = strel('disk', 2);

bw_final = imopen(imclose(bw, se1), se2);
bw_final = bwareaopen(bw_final, 1000, 8);   
figure; imshow(bw_final); title(data_name, 'morphological mask')




end

