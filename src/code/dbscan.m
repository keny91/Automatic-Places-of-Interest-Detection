function [class,type]=dbscan(X,K,d)
% [class,type]=dbscan(X,K,d)
% X: matrix
% K: minimal points
% d: maximal distance
% class: assignments
% type: core: 1, border: 0, outlier: -1
if nargin<3
   d=epsilon(X,K);
end
m=size(X, 1);
class=zeros(m,1);
type=zeros(m,1);
touched=zeros(m,1);
c=1;
for i=1:m
    if touched(i), continue; end
    indices=find(distances(X(i,:),X)<=d);
    k=length(indices);
    if k==1
       type(i)=-1;
       class(i)=-1;  
       touched(i)=1;
    elseif k<=K
       type(i)=0;
       class(i)=0;
    else
       type(i)=1;
       class(indices)=c;
       while ~isempty(indices)
           index=indices(1);
           touched(index)=1;
           I=find(distances(X(index,:),X)<=d);
           if length(I)>1
               class(I)=c;
               if length(I)<=K;
                  type(index)=0;
               else
                  type(index)=1;
               end
               for i=1:length(I)
                   if touched(I(i)), continue; end
                   touched(I(i))=1;
                   indices(end+1)=I(i);
                   class(I(i))=c;
               end
           end
           indices=indices(2:end);
       end
       c=c+1;
    end
end
I=find(class==0);
class(I)=-1;
type(I)=-1;

function d=epsilon(x,k)
[m,n]=size(x);
d=((prod(max(x)-min(x))*k*gamma(.5*n+1))/(m*sqrt(pi.^n))).^(1/n);

function D=distances(x,X)
D=sqrt(sum((ones(size(X, 1),1)*x-X).^2, 2));
