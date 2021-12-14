function [Xc, Z]= pre_airpls(X, lambda, order, w, p, iternum)
%  Baseline correction using adaptive iteratively reweighted Penalized Least Squares;
%  Input 
%         X:row matrix of spectra or chromatogram (size m*n, m is sample and n is variable)
%         lambda: lambda is an adjustable parameter, it can be adjusted by user. The larger lambda is, the smoother z will be 
%         order: an integer indicating the order of the difference of penalties
%         w: weight exception proportion at both the start and end
%         p: asymmetry parameter for the start and end
%         itermax: maximum iteration times
%  Output
%         Xc: the corrected spectra or chromatogram vector (size m*n)
%         Z: the fitted vector (size m*n)
%  Examples:
%         Xc=pre_airpls(X);
%         [Xc,Z]=pre_airpls(X,10e9,2,0.1,0.5,20);
%  Reference:
%         (1) Eilers, P. H. C., A perfect smoother. Analytical Chemistry 75 (14), 3631 (2003).
%         (2) Eilers, P. H. C., Baseline Correction with Asymmetric Least Squares Smoothing, http://www.science.uva.nl/~hboelens/publications/draftpub/Eilers_2005.pdf
%         (3) Gan, Feng, Ruan, Guihua, and Mo, Jinyuan, Baseline correction by improved iterative polynomial fitting with automatic threshold. Chemometrics and Intelligent Laboratory Systems 82 (1-2), 59 (2006).
%  Author:
%          zhimin zhang @ central south university on Mar 30,2011
 
%% not enough inputs
if nargin < 6
    iternum = 20;  % 
    if nargin < 5
        p = 0.05;     % 
        if nargin < 4
            w = 0.1;      % 
            if nargin < 3
                order = 2;       % default: the second differences penalties
                if nargin < 2
                    lambda = 10e5;  % the parameter of penalties item, lager and smoother
                    if nargin < 1
                        error('pre_airpls:NotEnoughInputs','Not enough input arguments. See function defination.');
                    end
                end
            end
        end
    end
end

%% body
[s, b] = size(X);   
wi = [1: ceil(b*w), floor(b - b*w): b];
D = diff(speye(b), order);    % a b*b sparse matrix
DD = lambda*(D'*D);

for i = 1:s
    
    w = ones(b, 1);
    x = X(i, :);
    
    for j = 1:iternum
        W = spdiags(w, 0, b, b);  %通过获取 w 的列并沿 0 指定的对角线放置，创建一个 b×b 稀疏矩阵 W。
        C = chol(W + DD);         %将对称正定矩阵 W + DD 分解成满足 A = R'*R 的上三角 C
        z = (C\(C'\(w .*x')))';
        
        d = x - z;
        dssn = abs(sum(d(d < 0)));
       %% when the terminative criterion is reached
        if(dssn < 0.001*sum(abs(x))) 
            break;
        end
       %% w for next iteration
        w(d >= 0) = 0;
        w(wi) = p;
        w(d < 0) = j*exp(abs(d(d < 0))/dssn);
    end
    Z(i,:) = z;
end

Xc = X-Z;

end
