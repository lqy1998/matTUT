function [shifts_ind_sel] = feature_spa(X, shift_initial_ind, num_sel)
% Successive Projections Algorithm

% input:
%     X = samples * shifts
%     shift_initial = initial shift you specify
%     num_selected = total number of selected shifts
% output:
%     shift_selected = the shifts you finally selected

[m, n] = size(X);
set_not_sel_index = 1:n;
S = X;      % S be the set of shifts which have not been selected yet
shifts_ind_sel = ones(1, num_sel);  % the set of shifts index which will be selected
shifts_ind_sel(1) = shift_initial_ind;
shift_new_sel = X(:, shift_initial_ind);  % the newest shift have been selected

for n = 1:num_sel-1      % 1: initial shift //choose num-1 times
    
    set_sel_ind = shifts_ind_sel(1:n);
    x_not_sel_ind = setdiff(set_not_sel_index, set_sel_ind);  % index in (not sel) & not in (sel)
    
    Proj = zeros(m, n);    % project matrix
    Proj2norm = zeros(1, length(x_not_sel_ind));  % matrix of 2norm project 
    norm_ind = 1;
    
    for j = x_not_sel_ind
        % the projection of xj on the subspace orthogonal to shift_new_sel
        Proj(:, j) = S(:, j) - (S(:, j)'*shift_new_sel)*shift_new_sel*(shift_new_sel'*shift_new_sel)^(-1);   
        Proj2norm(norm_ind) = norm(Proj(:,j));
        norm_ind = norm_ind+1;
    end
    
    shifts_ind_sel(n+1) = x_not_sel_ind(Proj2norm==max(Proj2norm));
    shift_new_sel = X(:,shifts_ind_sel(n+1));
    S = Proj;    % update S
    
end
end