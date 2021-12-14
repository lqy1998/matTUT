function CV = plscvfold(X, y, num_pc, K, method, PROCESS, order)
%+++ K-fold Cross-validation for PLS
%+++ Input:  
%            X: m x n  (Sample matrix)
%            y: m x 1  (measured property)
%            num_pc: The maximal number of latent variables for cross-validation
%            K: fold. when K=m, it is leave-one-out CV
%            method: pretreatment method. Contains: autoscaling, pareto, minmax, center or none.
%            PROCESS: =1 : print process.
%                     =0 : don't print process.      ----default
%            Order:   =1  sorted, default. For CV partition.
%                     =0  random. 
%+++ Output: 
%            Structural data: CV
%+++ Author:
%            Hongdong Li, Oct. 16, 2008.

%% initialization

if nargin < 7
    order = 1;
    if nargin < 6
        PROCESS = 1;
        if nargin < 5
            method = 'center';
            if nargin < 4
                K = 10;
                if nargin < 3
                    num_pc = 3;
                end
            end
        end
    end
end

%% randomly rank samples

check = 0;                       %% (???????????????????????????????????)

if order == 1
  [y, index_y] = sort(y);
  X = X(index_y, :);
else
  index_y = randperm(length(y));
  X = X(index_y, :);
  y = y(index_y);                        
end

%% inside paras

[m, p] = size(X);
num_pc = min([m, p, num_pc]);

y_truth = nan(m, 1);               % y_val ground truth value (just as same as y??????????)
y_pred = nan(m, num_pc);           % y_val_prediction: m * num_pc (no NaN finally exists cause all data will be in a validation set)

groups = 1 + rem(0:m-1, K);    % give every sample a groupnum, group = 1 * m

%% main loop
for group = 1:K
    
    indexlist_val = find(groups == group);           % validation sample index list
    indexlist_train = find(groups ~= group);         % train sample index list 
    X_train = X(indexlist_train, :);
    y_train = y(indexlist_train);
    X_val = X(indexlist_val, :);
    y_val = y(indexlist_val);
    
    % data pretreatment
    [Xs, xpara1, xpara2] = pretreat(X_train, method);                          %% function warning!!!!!!!!!!!!!!!!!!!!!!!!
    [ys, ypara1, ypara2] = pretreat(y_train, method);   
    
    [~, W, ~, ~, Q] = pls_nipals(Xs, ys, num_pc, 0);                           %% function warning!!!!!!!!!!!!!!!!!!!!!!!!
    % 0: no pretreatment cause data has been pretreated just now
    % W = X-weights (p x num_pc)
    % Q = Y-loadings (num_pc x 1)
    
    y_val_pred = [];
    
    for j = 1:num_pc
        
        %+++ calculate the coefficient linking X_train and y_train       
        B = W(:, 1:j) * Q(1:j);           % p * 1
        C = ypara2 * B ./ xpara2';        % central: ypara2 = 1,      xpara2 = ones(1, p)         C = B
        coef = [C; ypara1-xpara1*C];      %          ypara1 = mean_y = 1 * 1, xpara1 = mean_x = 1*p       coef = (p+1) * 1          
             
        %+++ add intercept to X_val
        m_val = size(X_val,1);
        X_val_intercept = [X_val, ones(m_val, 1)];   % [m_val*p, m_val*1] = [m_val, p+1]
        
        %+++ predict 
        ypred = X_val_intercept * coef;    % m_val * 1
        y_val_pred = [y_val_pred, ypred];  % y_val_prediction after one fold validation: m_val * pc_num
        
    end      
    
    y_pred(indexlist_val, :) = y_val_pred;
    y_truth(indexlist_val, :) = y_val;
    
    %+++ process visualization (default)
    if PROCESS==1 
        fprintf('The %dth group finished.\n',group)
    end
    
end

%% retrn the original order!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

y_truth(index_y) = y_truth;                % m * 1
y_pred(index_y, :) = y_pred;               % m * pc_num

%% output  

if check == 0 
    
  Error = y_pred - repmat(y_truth, 1, num_pc);         % m * num_pc
  rmse_pc = sqrt(sum(Error.^2)/m);                      % 1 * num_pc
  [optimal_rmse, optimal_pc_index] = min(rmse_pc);

  SST = sumsqr(y_truth - mean(y_truth));
  Rsquare = [];
  
  for i = 1:num_pc
    SSE = sumsqr(y_pred(:, i) - y_truth);
    rsquare = 1 - SSE/SST;
    Rsquare = [Rsquare, rsquare];
  end
  
  CV.pretreat = method;
  CV.check = 0;
  CV.RMSE_min = optimal_rmse;
  CV.Rsquare_all = Rsquare;
  CV.Rsquare_max = Rsquare(optimal_pc_index);
  CV.Ypred = y_pred;
  CV.RMSE = rmse_pc;
  CV.optPC_num = optimal_pc_index;
  
elseif check == 1
    
  CV.method = method;
  CV.check = 1;   
  
end

end