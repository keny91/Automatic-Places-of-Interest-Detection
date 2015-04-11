function ap=computeAP(data,gtLabels)

[sdata idx]=sort(data,'descend');

tp=gtLabels(idx)>0;
fp=1-tp;
tpc=cumsum(tp)+eps;
fpc=cumsum(fp)+eps;
numPos=sum(tp);
ap=0;
for i=1:1:length(idx)
    prec=tpc(i)/(fpc(i)+tpc(i)+eps);
	ap=ap+prec*tp(i);
end
ap=ap/numPos;
