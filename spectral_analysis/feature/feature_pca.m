function [PC_score, PC_coeff, rates, cum_rates] = feature_pca(x, num)

% input:
%    x: samples * variables
%    num: pc num

   [coeff, score, latent] = pca(x);
   
%    contribution = latent./sum(latent);
%    cum_contribution = cumsum(latent)./sum(latent);   
%    p = find(cum_contribution > percentage, 1);  
%    
%    PC_score = score(:, 1:p);
%    PC_coeff = coeff(:, 1:p);
%    rates = contribution(1:p);
%    cum_rates = cum_contribution(1:p);
   
   contribution = latent./sum(latent);
   cum_contribution = cumsum(latent)./sum(latent);
   
   PC_score = score(:, 1:num);
   PC_coeff = coeff(:, 1:num);
   rates = contribution(1:num);
   cum_rates = cum_contribution(1:num);
   
end