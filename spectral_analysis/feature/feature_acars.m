function F = feature_acars(X, y, num_pc, num_cvfold, method_pretreat, num_mciter) 
%% Competitive Adaptive Reweighted Sampling method for variable selection.
% input:
%    X: The data matrix of size m x p
%    y: The reponse vector of size m x 1
%    num_pc: the maximal principle to extract.
%    num_cvfold: the group number for cross validation.
%    num_mciter: the  number of Monte Carlo Sampling runs.
%    method_pretreat: pretreatment method.
%  
% Author:  
%    Hongdong Li, Yizeng Liang, Qingsong Xu, Dongsheng Cao, Key
%    wavelengths screening using competitive adaptive reweighted sampling method for multivariate calibration, Anal Chim Acta 2009, 648(1):77-84

%% initial settings

if nargin < 6
    num_mciter = 50;
    if nargin < 5
        method_pretreat = 'center';
        if nargin < 4
            num_cvfold = 5;
            if nargin < 3
                num_pc = 2;
            end
        end
    end
end

%% inside paras

[m, p] = size(X);
num_pc = min([m, p, num_pc]);

Vsel = 1:p;                           % selected_variable's subscript list in PLS model

ratio = 0.9;
Q = floor(m*ratio);                   % MC sampling ratio

W = zeros(p, num_mciter);             % weight matrix of variable 

Ratio = zeros(1, num_mciter);         % ratio matrix of retained variables of EDF

%% Parameter a & k of EDF 

r1 = 1;
rN = 2/p; 
k = log(r1/rN) / (num_mciter-1);  
a = r1 * exp(k);
%% anova

pvalues = zeros(1, size(X, 2));
     
     for column = 1:size(X, 2)
         data = X(:, column);
         pvalue = anova1(data, y, "off");
         pvalues(column) = pvalue;
     end

     [~, pvalues_ind] = sort(pvalues);  
     
%% Loop of MC-Sampling, EDF, ARS

for iter = 1:num_mciter
    
     %+++ Monte-Carlo Sampling.
     perm = randperm(m);                      % random rank
     Xcal = X(perm(1:Q), :); 
     ycal = y(perm(1:Q));   
     
     %+++ PLS model
     PLS = pls(Xcal(:, Vsel), ycal, num_pc, method_pretreat);               %% function warning!!!!!!!!!!!
     w = zeros(p, 1);                         % pls weight vector in one iteration
     coef = PLS.coef_origin(1:end-1, end);
     w(Vsel) = coef;
     W(:, iter) = w; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

     %+++ sort weights
     w = abs(w);      
     [~, indexw] = sort(-w);                     
    
     %+++ Ratio of retained variables.
     ratio = a * exp(-k * (iter+1));                      
     Ratio(iter) = ratio;
      
     %+++ Eliminate some variables with small coefficients.
     num_retained = round(p*ratio); 
     w(indexw(num_retained+1: end)) = 0;                        
     
     %+++ Anova analysis shared ratio with EDF      
     w(pvalues_ind(num_retained+1:end)) = 0;   %%delete large p values
     
     %+++ Reweighted Sampling from the pool of retained variables. 
     Vsel = weightsampling(w);                                              %% function warning!!!!!!!!!!!                    
     Vsel = unique(Vsel);   
     
     %+++ Screen output.
     if mod(iter, 10) == 0
         fprintf('The %dth variable sampling finished.\n', iter);
     end
     
 end

%%  Cross-Validation to choose an optimal subset;

RMSECV = zeros(1, num_mciter);
Rsquare = zeros(1, num_mciter);            %Q2 = SSR/SST
optPC_num = zeros(1, num_mciter);

for i = 1:num_mciter
    
   vsel = W(:, i) ~= 0;
 
   CV = plscvfold(X(:, vsel), y, num_pc, num_cvfold, method_pretreat, 0);   %% function warning!!!!!!!!!!! 
   
   RMSECV(i) = CV.RMSE_min;
   Rsquare(i) = CV.Rsquare_max;     
   optPC_num(i) = CV.optPC_num;
   
   if mod(i, 10) == 0
       fprintf('The %dth subset finished.\n',i);
   end
   
end

[minRMSECV, iter_optimal] = min(RMSECV);
maxRsquare = max(Rsquare);

%% output
F.W = W;
F.RMSEPCV = RMSECV;
F.minRMSECV = minRMSECV;
F.optITER = iter_optimal;
F.optPC_num = optPC_num(iter_optimal);
F.maxRsquare = maxRsquare;
F.EDF_ratio = Ratio;
F.vsel = find(W(:, iter_optimal) ~= 0)';

end



