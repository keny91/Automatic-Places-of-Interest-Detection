function [cores_XY, cores_COOR, cluster_size] = db_scan_fixed_range( XYcoor_n, samples, db_class, inner_radious, outter_radious,Center_Coor )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here




n_clusters = max(db_class);      % number of clusters
color_map = hsv(n_clusters);        % Creates a set of colors from the HSV colormap
cores_XY =zeros(n_clusters,2);      % matrix to store x/y polar coordinates for the core of each cluster
cores_COOR = zeros(n_clusters,2); % matrix to store lat,lon coordinates for the core of each cluster
mean_z = Center_Coor(3);
cluster_size = zeros(n_clusters,1);
% n_clusters
% size(cluster_size)

% This FOR plots the differnt clusters 
for i = 1:n_clusters   
  
  [r] = find(db_class==i);  
  cluster = zeros(size(r,1),2);
  cluster_coor = zeros(size(r,1),3);
  is_cluster = false;
      % Get all the points that belong to the cluster
      for j=1:1:size(r,1)
        cluster(j,1) = XYcoor_n(r(j),1);
        cluster(j,2) = XYcoor_n(r(j),2);

        cluster_coor (j,1) = samples(r(j),1);
        cluster_coor (j,2) = samples(r(j),2);
        cluster_coor (j,3) = samples(r(j),3);
        
        % If ONE or more points in the cluster are in the radious threshold
        %
        center = [0,0];
        distance = distance2point(center, cluster(j,:));
        if ((distance < outter_radious) && (distance > inner_radious))
            is_cluster = true;
        end

      end
      
%       size(r,1)
      
      if is_cluster
          
%      figure(1)
%         subplot(2,2,2)
%         title('Cluster Plot');
%         xlabel('X-AXIS');
%         ylabel('Y-AXIS');
%         hold on;
%         plot(cluster(:,1), cluster(:,2), '-s','Color', color_map(i,:));  %# Plot each column with a
%         set(gca,'xlim',[-10000 10000], 'ylim',[-10000 10000]);
%         hold on;
%         scatter(0, 0, 'rx');

        
        [center_out_XY, center_out_COOR , distance] = findCoorCenter( cluster , Center_Coor);
        
%         compute AP
        modulus = zeros(size(cluster,1),1);
        label = zeros(size(cluster,1),1);
        for j=1:size(cluster,1)
        modulus(j) = distance2point(center_out_XY,cluster(j,:));
        label(j) = i; 
        end
   
        %AP_modulus = computeAP(label, modulus) 
        
        cores_XY(i,1) = center_out_XY(1);
        cores_XY(i,2) = center_out_XY(2);
        cluster_size(i,:) = size(r,1);
       
 
        
        
        %  It return both lat/lon and XY coordinates, and they are aligned

        %%%%%finding_core LOng/latitude
        %     tic  % mean of 0.08 secs when 9 sectors search
        % It takes exatcly 1077 loops to get it right -> 1077*9 = 9693
        % operations

        search_radious=5;
        loops_done = 0;
        point_relative=Center_Coor;
        while (search_radious ~= 0)
            [ point_closer ] = FindGTCoor( cores_XY(i,:), point_relative, search_radious , mean_z ,Center_Coor);
            search_radious = search_radious/2; % reduce the radious
            point_relative = point_closer; %the next search will be around the closest point
            loops_done = loops_done+1;
        end
        % loops_done %debugg info

        
        cores_COOR(i,1) = point_closer(1);
        cores_COOR(i,2) = point_closer(2);

      end
      


%  toc

%  eliminate registers which are 0



%  Plot the cores
% % figure(4)
% subplot(2,2,4)
% hold on;
% scatter(cores_XY(i,1),cores_XY(i,2));
% hold on;
% scatter(0, 0, 'rx');

%   
end

% We have to wait until we create the whole matrix and go through the
% matrix in a descending way so when we eliminate a register we won´t
% confuse the next reg.
for i = n_clusters:-1:1   
    if (cores_XY(i,1) == 0) &&  (cores_XY(i,2) == 0 && cluster_size(i)==0)
        cores_XY(i,:)=[];
        cores_COOR(i,:)=[];
        cluster_size(i,:)=[];

    end
end

end

