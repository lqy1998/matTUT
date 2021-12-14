function Pre = pretreatment_nir(seed_variety, file_name)
% PRETREATMENT: a function to pretreat raw & hdr format hyperspectral data 
% input:
%       seed_variety: seed variety like zd958/jd20/nh816/jh5/zd958nc
%       file_name: file name like 25/50/75/100
%
% output:
%       P.avedata: single seed average data = 25 * effbands
%       P.avedata_sg: single seed average data after sg-filter = 25 * effbands
%       P.avedata_sg_air: single seed average data after sg-filter & airPLS = 25 * effbands
%       P.avedata_background: single seed background average data after airPLS = 25 * effbands
%       P.avedata_sg_air_snv: single seed average data after sg-filter & airPLS & snv = 25 * effbands
%
% author:
%       Liu Qingyun    contact: liuqingyun98@gmail.com

%% inside paras

root_path = 'D:\files\spectral_analysis\mat_demo\data\correctedNIR\';
file_name = num2str(file_name);

%% get datacube

% file path
hdr_path_name = strcat(root_path, seed_variety, file_name, '_RT.hdr');
raw_path_name = strcat(root_path, seed_variety, file_name, '_RT.raw');

% get dimensions and waves
info = get_info(hdr_path_name);
[samples, lines, bands, wavelengths] = get_dimensions(info);

% get datacube
rawdata = get_rawdata(raw_path_name);
rawcube0 = reshape(rawdata, [samples, bands, lines]);
rawcube = permute(rawcube0, [3, 1, 2]);

% effective raman shift 
[~, p1] = min(abs(wavelengths - 400));
[~, p2] = min(abs(wavelengths - 1000));
effwavelengths = wavelengths(p1:p2);

% define effcube
effcube = rawcube(130:1109, 70:829, p1:p2);
efflines = size(effcube, 1);
effsamples = size(effcube, 2);
effbands = size(effcube, 3);

%% mask and roi

% effective band for mask
[~, b] = min(abs(effwavelengths - 880.3));

% mask 
[bw, ~, ~] = get_mask(effcube, b);

% morphology
se1 = strel('disk', 8);
se2 = strel('disk', 4);
bw_final = imopen(imclose(bw, se2), se1);
bw_final = bwareaopen(bw_final, 1000, 8);     

% roi average data 
[avedata, ~] = get_ave_spec(effcube, bw_final);

% %% preprocessing ------ sgfilter
% 
% % sgfilter for noise
% cube_sgfilter = zeros(efflines, effsamples, effbands);
% 
% for i = 1:efflines
%     X = zeros(effsamples, effbands);
%     X(:, :) = effcube(i, :, :);
%     X_sgfilter = pre_sgfilter(X);
%     cube_sgfilter(i, :, : ) = X_sgfilter(:, :);
% end
% 
% % roi data 
% avedata_sgfilter = get_ave_spec(cube_sgfilter, bw_final);
% 
% %% preprocessing ------ airpls
% 
% % airpls for background and baseline
% cube_sg_airpls = zeros(efflines, effsamples, effbands);
% cube_background = zeros(efflines, effsamples, effbands);
% 
% for i = 1:efflines
%     X = zeros(effsamples, effbands);
%     X(:, :) = cube_sgfilter(i, :, :);
%     
%     [X_airpls, Z_airpls] = pre_airpls(X);
%     
%     cube_sg_airpls(i, :, : ) = X_airpls(:, :);
%     cube_background(i, :, : ) = Z_airpls(:, :);
% end
% 
% % roi data 
% avedata_sg_airpls = get_ave_spec(cube_sg_airpls, bw_final);
% 
% % roi background 
% avedata_background = get_ave_spec(cube_background, bw_final);
% 
% %% preprocessing ------ snv
% 
% % snv for normalization
% cube_sg_air_snv = zeros(efflines, effsamples, effbands);
% for i = 1:efflines
%     X = zeros(effsamples, effbands);
%     X(:, :) = cube_sg_airpls(i, :, :);
%     X_sg_air_snv = pre_snv(X);
%     cube_sg_air_snv(i, :, : ) = X_sg_air_snv(:, :);
% end
% 
% % roi data
% avedata_sg_air_snv = get_ave_spec(cube_sg_air_snv, bw_final);

%% output
Pre.avedata = avedata;
% Pre.avedata_sg = avedata_sgfilter;
% Pre.avedata_sg_air = avedata_sg_airpls;
% Pre.avedata_background = avedata_background;
% Pre.avedata_sg_air_snv = avedata_sg_air_snv;
Pre.effwavelengths = effwavelengths;

end

