function [x_sg] = pre_sgfilter(x, width_input, order_input, deriv_input)
% Savitzky-Golay smoothing and differentiation

% input:
% x (samples x variables) data to preprocess
% width (1 x 1)           number of points (optional, default=15)
% order (1 x 1)           polynomial order (optional, default=2)
% deriv (1 x 1)           derivative order (optional, default=0)

% output:
% x_sg (samples x variables) preprocessed data

% author:
% By Cleiton A. Nunes
% UFLA,MG,Brazil

%% variable num
[~, n] = size(x);
%% not enough inputs
if nargin < 4
    deriv_input = 0;
    if nargin < 3
        order_input = 2; 
        if nargin < 2
            width_input = min(15, floor(n/2)); % filter width
            if nargin < 1
                error('pre_sgfilter:NotEnoughInputs','Not enough input arguments. See fuction defination.');
            end
        end
    end
end

%% body
% width, order, deriv must satisfy conditions
width = max(3, 1+2*round((width_input-1)/2));
order = min([max(0, round(order_input)), 5, width-1]); % order <= width
deriv = min(max(0, round(deriv_input)), order);    

p = (width-1)/2;       % the start and end regions can't be filtered well

xc = ((-p:p)'*ones(1, 1+order)).^(ones(size(1:width))'*(0:order));
we = xc\eye(width);
b = prod(ones(deriv,1)*[1:order+1-deriv]+[0:deriv-1]'*ones(1,order+1-deriv, 1), 1);

di = spdiags(ones(n,1)*we(deriv+1, :)*b(1), p:-1:-p, n, n);
w1 = diag(b)*we(deriv+1:order+1, :);
di(1:width, 1:p+1)=[xc(1:p+1, 1:1+order-deriv)*w1]'; 
di(n-width+1:n, n-p:n)=[xc(p+1:width, 1:1+order-deriv)*w1]';

x_sg = x*di;

end
