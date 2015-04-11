function [ output_args ] = ExtractDBSCAN( OrderedPoints ,ei, MinPoints)
%UNTITLED Summary of this function goes here
%   ei: is the separation distance, less will be considered as another

Noise = -1; % -1 is considered as noise, the cluster wont be selected
clusterID = Noise; % Initialy
n_clusters = length(OrderedPoints);
reachability = ???; %RD
core_distance = ???; %CD
id = 0;
for i =1:n_clusters

    
    
%             If the reachability-distance of the current object is smaller than ei,
%           we can simply assign this object to the current cluster because
%           then it is density-reachable with respect to e’ and MinPts from
%           a preceding core object in the cluster-ordering.
    
if (i == 1)    % if is the first cluster


else
    if OrderedPoints(i,RD_col) > ei  % 
        if (OrderedPoints(i,CD_col) <= ei) % We found a new cluster IDONTUNDERSTAND
            


%             % next cluster
            id = id+1; 
            OrderedPoints(i,ID_col) = id; 
            
        else % the point is not considered as part of the cluster
            
            OrderedPoints(i,ID_col) = Noise; 
        end
        
        
    else  %else RD, if it is smaller then is part of the cluster
        OrderedPoints(i,ID_col) = id;
        
    end
    
    
end  
    
    
end


%  We are returning the same matrix but with and added row






