function [ XYcoor_n ,samples_n] = createClusterXY( parameter_list, n_samples_generated, dist_limit,Center_Coor  )
%createClusterXY : Creates both a XY coordinates matrix and a GPS matrix
%with only those samples wich are close enough to the center


%       First the method generates a new GPS matrix with randomly selected
%   samples from the original list of data, refered as "parameter_list".
%   Those selected will be transformed into XY coordinates with
%   "Center_Coor" as (0,0) meters. 
%       Then the function will discard those points which are far away from
%   the center of the city, the distance threshold is given by the
%   parameter "dist_limit" related to "Center_Coor".
%   Since both GPS and XY matrixes are usefull, both will be returned.

% Get the number of possible samples
n_data = size(parameter_list,1); 
XYcoor = zeros(n_samples_generated,2);

% Creates a matrix from random samples 
sample_index = ceil(n_data*rand(n_samples_generated,1));
samples = parameter_list(sample_index,:);

% Instanciate empty matrixes which wil
samples_n=[];
XYcoor_n=[]; 
for i=1:1:n_samples_generated 
    [XYcoor(i,:)] = GPS2Meter(samples(i,:),Center_Coor);

%We discard samples that are far away from the origin    
    dist2center = sqrt(XYcoor(i,1).^2 +XYcoor(i,2).^2);
    if (dist2center < dist_limit)
        XYcoor_n = vertcat(XYcoor_n,[XYcoor(i,1),XYcoor(i,2)]);
        samples_n = vertcat(samples_n,[samples(i,1),samples(i,2),samples(i,3)]);
    end
end



% Set default values for the axis so image will fit in the background
% This is optimized for Berlin
% scatter(XYcoor_n(:,1),XYcoor_n(:,2))
% set(gca,'xlim',[-10000 8000], 'ylim',[-6000 6000]);
% 
% % a = axes('Position',[0 0 1 1],'Units','Normalized');
% % imshow('berlin_map.png','Parent',a);
% hold on;


end



