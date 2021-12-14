function [bestacc,bestc,bestg] = svm_gridsearch(train_label,train,cmin,cmax,gmin,gmax,v,cstep,gstep,accstep)
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
if nargin < 10
    accstep = 4.5;
end
if nargin < 8
    cstep = 1;
    gstep = 1;
end
if nargin < 7
    v = 5;
end
if nargin < 5
    gmax = 5;
    gmin = -5;
end
if nargin < 3
    cmax = 5;
    cmin = -5;
end
%% X:c Y:g cg:CVaccuracy
[X,Y] = meshgrid(cmin:cstep:cmax,gmin:gstep:gmax);
[m,n] = size(X);
cg = zeros(m,n);
eps = 0.1;
%% record acc with different c & g,and find the bestacc with the smallest c
s = 0;
t = 2;
bestc = 1;
bestg = 0.5;
bestacc = 0;
basenum = 2;
for i = 1:m
    for j = 1:n
        cmd = [' -s ',num2str(s),' -t ',num2str(t),' -v ',num2str(v),' -c ',num2str( basenum^X(i,j) ),' -g ',num2str( basenum^Y(i,j) )];
        cg(i,j) = libsvmtrain(train_label, train, cmd);
        
        if cg(i,j) <= 70
            continue;  
        end
        
        if ( bestacc - cg(i,j) <= eps && basenum^X(i,j) < bestc) || ( cg(i,j) > bestacc )
            bestacc = cg(i,j);
            bestc = basenum^X(i,j);
            bestg = basenum^Y(i,j);
        end        
        
    end
end
%% to draw the acc with different c & g
figure;
[C,h] = contour(X,Y,cg,70:accstep:100);
clabel(C,h,'Color','r');
hold on;
scatter(log2(bestc), log2(bestg));
xlabel('log2c','FontSize',12);
ylabel('log2g','FontSize',12);
firstline = 'SVC参数选择结果图(等高线图)[GridSearchMethod]'; 
secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg), ...
    ' CVAccuracy=',num2str(bestacc),'%'];
title({firstline;secondline},'Fontsize',12);
grid on; 

figure;
meshc(X,Y,cg);
% mesh(X,Y,cg);
% surf(X,Y,cg);
axis([cmin,cmax,gmin,gmax,70,100]);
xlabel('log2c','FontSize',12);
ylabel('log2g','FontSize',12);
zlabel('Accuracy(%)','FontSize',12);
firstline = 'SVC参数选择结果图(3D视图)[GridSearchMethod]'; 
secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg), ...
    ' CVAccuracy=',num2str(bestacc),'%'];
title({firstline;secondline},'Fontsize',12);