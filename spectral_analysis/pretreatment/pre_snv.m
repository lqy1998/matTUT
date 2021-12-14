function [x_snv] = pre_snv(x)
% Standard Normal Variate
% input:
% x (samples x variables) data to preprocess
%
% output:
% x_snv (samples x variables) preprocessed data

n = size(x, 2);
meanx = mean(x, 2);
stdx = std(x, 0, 2);  % 0: n-1 2:every row cross col
x_snv = (x - repmat(meanx, 1, n))./repmat(stdx,1,n);

end
