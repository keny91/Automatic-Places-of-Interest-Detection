function [ citypics] = CityPics( pics_map , max_dist)
%CityPics:  Finds the points close to the center of a map
%   Detailed explanation goes here

     citypics=[0,0];

n_data = size(pics_map,1);

for j=1:1:n_data 
    dist2center = sqrt(pics_map(j,1).^2 +pics_map(j,2).^2);
    
if (dist2center < max_dist)
    citypics = vertcat(citypics,[pics_map(j,1),pics_map(j,2)]);
%     citycspics = [citypics ,pics_map(j,:)];
end

end

end

