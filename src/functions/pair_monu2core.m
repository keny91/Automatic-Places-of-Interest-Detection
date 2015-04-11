function [ position, distance_final ] = pair_monu2core( monuments_XY , core_XY, threshold )
    %PAIR_MONU2CORE: known a list of monuments we will compare the proximity of
    % a given core and associated the closest monument to the core
    



n_monuments = size(monuments_XY(:,1),1);  % number of interest points in the city:

% min_dist_core2monu = threshold;
distance = zeros(n_monuments,1);  % value outside the threshold
  % This Variable will be -1 if the method does not find a 
position = -1;
distance_final = -1;
%%%%%%%%%%%%%%%%%% Creating a Matrix to ease the evaluation  %%%%%%%%%%%%%%%%%%


% Generate a matrix with the distances
for i = 1:n_monuments % evalueate all monuments
   
    distance(i)= distance2point(monuments_XY(i,:) ,core_XY);
end


% find the position of the min distance
min_dist_core2monu = threshold;   
for i = 1:n_monuments % evalueate all monuments
   if ((distance(i) < min_dist_core2monu) && (distance(i) < threshold))
    position = i;
    min_dist_core2monu = distance(i);
    distance_final = distance(i);
   end
end
    
    

end