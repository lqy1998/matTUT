function sel=weightsampling(w)
%Bootstrap sampling
%2007.9.6,H.D. Li.

w=w/sum(w);
N1=length(w);
min_sec(1)=0; max_sec(1)=w(1);
for j=2:N1
   max_sec(j)=sum(w(1:j));
   min_sec(j)=sum(w(1:j-1));
end
% figure;plot(max_sec,'r');hold on;plot(min_sec);
      
for i=1:N1
  bb=rand(1);
  ii=1;
  while (min_sec(ii)>=bb | bb>max_sec(ii)) & ii<N1;
    ii=ii+1;
  end
    sel(i)=ii;
end      % w is related to the bootstrap chance

end

%+++ subfunction:  booststrap sampling
% function sel=bootstrap_in(w);
% V=find(w>0);
% L=length(V);
% interval=linspace(0,1,L+1);
% for i=1:L;
%     rn=rand(1);
%     k=find(interval<rn);
%     sel(i)=V(k(end));    
% end

