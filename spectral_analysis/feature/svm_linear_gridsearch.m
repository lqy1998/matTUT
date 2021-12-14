function [bestacc,bestc,bestg] = svm_gridsearch(train_label,train,cmin,cmax,v,cstep,accstep)
% SVMcg cross validation by faruto
% by faruto
% Email:patrick.lee@foxmail.com 
% QQ:516667408 
% http://blog.sina.com.cn/faruto
% last modified 2011.06.08
%
% 若转载请注明：
% faruto and liyang , LIBSVM-farutoUltimateVersion 
% a toolbox with implements for support vector machines based on libsvm, 2011. 
% Software available at http://www.matlabsky.com
% 
% Chih-Chung Chang and Chih-Jen Lin, LIBSVM : a library for
% support vector machines, 2001. Software available at
% http://www.csie.ntu.edu.tw/~cjlin/libsvm

%% about the parameters of SVMcg 
if nargin < 7
    accstep = 4.5;
end
if nargin < 6
    cstep = 0.1;
end
if nargin < 5
    v = 5;
end
if nargin < 4
    cmax = 5;
    cmin = -5;
end
%% X:c Y:g cg:CVaccuracy
X = cmin:cstep:cmax;
m = length(X);
cc = zeros(1,m);
eps = 0.05;
%% record acc with different c & g,and find the bestacc with the smallest c
s = 0;
t = 2;
bestc = 1;
bestacc = 0;
basenum = 2;
for i = 1:m
   cmd = [' -s ',num2str(s),' -t ',num2str(t),' -v ',num2str(v),' -c ',num2str( basenum^X(i) )];
   cc(i) = libsvmtrain(train_label, train, cmd);
        
   if cc(i) <= 70
      continue;  
   end
        
   if (abs(cc(i) - bestacc) <= eps && basenum^X(i) < bestc) || (cc(i) > bestacc + eps)
      bestacc = cc(i);
      bestc = basenum^X(i);
   end        
      
end
%% to draw the acc with different c
figure;
plot(X, cc)
xlabel('log2c','FontSize',12);
ylabel('acc','FontSize',12); 
line = ['Best c=',num2str(bestc),' CVAccuracy=',num2str(bestacc),'%'];
title(line,'Fontsize',12);
