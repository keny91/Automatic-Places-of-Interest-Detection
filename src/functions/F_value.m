function [ F ] = F_value( NC, UC, NM , UM )
%F_value  is a function designed to calculate the F value given the
%requiered parameters: Number of Clusters (NC), Unused Clusters (UC),Number
%of Monuments (NM) and Unused Monumets (UM).


% Recall calculation
recall = (NM-UM)/(UM+(NM-UM))

%Precision
precision = (NM-UM)/(UC+(NM-UM))

% F-value
F = (2*recall*precision)/(recall+precision);



end

