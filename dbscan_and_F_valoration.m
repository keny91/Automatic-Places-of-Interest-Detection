close all
clear all


%% Evaluate.m
% This method will allocate the center of the city as (0,0) and will
% positionate all other coordinates relatively to that point.

%

% PROBLEM: a way to get the city center coordinates is needed.
% Now we just insert its coordinates manually


%   Load necessary funtions 
addpath('.\src\code\');
addpath('.\src\functions\');
% addpath('.\src\geo_conversion\');



%%%%%%%%%%%%%%%%%%%%%%%     PARAMETERS  %%%%%%%%%%%%%%%%%%%%%%%
%   Load the coordinates for each picture taken
data_pictures_taken = load('datafiles/gps_berlin/gps_berlin.txt');
mean_z = mean(data_pictures_taken(:,3));

%   City: BERLIN
city_name = 'berlin';
lat0 = 52.5192;
lon0 = 13.4061;
Center_GT =[lat0,lon0,mean_z];


%   Number os samples to be taken
% n_samples = length(data_pictures_taken);
n_samples = 10000;
mean_z = mean(data_pictures_taken(:,3));
dist_limit = 10000; %  in meters, the distance that could be separated from the center of the city

% max_dist db_scan parameters
min_db_dist = 10;
max_db_dist = 150;
skip_db_dist = 5;

% min_points db_scan parameters
min_db_points = 10;
max_db_points = 500;
skip_db_points = 10;

% Pairing thresholds
% threshold =50;
% threshold =[50 300];
threshold =[50 100 200 300];


% Prepare the Analysis table size
analysis_size = (((max_db_points-min_db_points)/skip_db_points)+1)*(((max_db_dist-min_db_dist)/skip_db_dist)+1);
Length_th = length(threshold);
% The size of the matrix will be +3 columns to store min_points,max_dist
% and th
Analysis_table = zeros (analysis_size,Length_th+2);





%%

%   FIRST the user will be asked if he wants to load the previous monument database
%   o use the default given
option_selected_load=0;


%  Loop until one of the options is selected
while (option_selected_load ~=1 && option_selected_load ~= 2)
    option_selected_load = input('\nLOAD OPTIONS, select one:\n1 : Load default monument database\n2 : Load custom database\n3 : Generate a new Database\n');
    if option_selected_load == 1
        disp('Selected option 1, Loading Default Database ...');
%         load('./monument_coor')     % Run this line the first time, will createLoaded custom database   
        commandline = strcat('./',city_name,'.mat');
        load(commandline) 
        
        
    elseif (option_selected_load == 2) 
        disp('Selected option 2, Loading Custom Database ...')
        database_name = input('Enter the Name of the database\n (We will name it as the city name if your entry is empty)','s');
        
        %by default we assignate the cityname
        if (isempty(database_name)) 
            load(strcat('./databases/',city_name,'.mat'))    % After creating a 
    %        monument_coor = NEW_LIST;
        else
            load(strcat('./databases/',database_name,'.mat'))
        end

    else    
        disp('Invalid Input, Try again  ...')
    end
    
%  
end

%   MonumentGT  to XY space 
n_monuments = size(monument_coor,1);
monument_XY = zeros(n_monuments,2);
if option_selected_load ~=3 % if an empty matrix is created if creas a log (0,0,meanz)
    monument_coor(:,3) = mean_z;  % WE give the height the mean altitude from data_pictures taken
end
for i=1:1:n_monuments
    [monument_XY(i,:)] = GPS2Meter(monument_coor(i,:),Center_GT);
end



%%


fidX = fopen('./dbscan.txt','wt');
n_times = 0;

[ XYcoor_n, samples ] = createClusterXY(  data_pictures_taken ,n_samples ,dist_limit ,Center_GT);  % CAMBIO ESTA LINEA
for max_dist_analisys=min_db_dist:skip_db_dist:max_db_dist
%     min_points_analisys= min_db_points; % R
    
    for min_points_analisys=min_db_points:skip_db_points:max_db_points
        n_times = n_times + 1;
        cluster_XY_final = [];
        cluster_coor_final = [];


%         [ XYcoor_n, samples ] = createClusterXY(  data_pictures_taken ,n_samples ,dist_limit ,Center_GT);
        [db_class,db_type]=dbscan( XYcoor_n, min_points_analisys, max_dist_analisys);
        [cluster_XY, cluster_coor, cluster_size] = db_scan_fixed_range( XYcoor_n, samples, db_class, 0, dist_limit,Center_GT );

        ordered_clusters = sortrows([cluster_XY cluster_coor cluster_size],-5);
        n_clusters = size(ordered_clusters,1);


        % Print data into a log
        fprintf(fidX,'%d º Cluster: max_dist = %d min_points= %d number of Clusters = %d  \n',n_times,max_dist_analisys,min_points_analisys,n_clusters);
        

%           Data_cluster matrix
% - nº cores: número de clusters/monumentos detectados. (NC)
% - Unused cores: número de falsas alarmas, que se corresponden con clusters no asignados. (UC)
% - Número de monumentos (112): es el número de monumentos del Ground Truth. (NM)
% - Unpaired monuments: Monumentos no detectados (las no detecciones). (UM)



    % We will run X analysis uing the diferent Thresholds values set
        n_TH = size(threshold(:),1);
        F = zeros(1,n_TH);
        pairing_matrix = zeros(n_clusters,6); 
        
        unused_monuments=[];
        input_matrix = [ordered_clusters(:,1) ordered_clusters(:,2) ordered_clusters(:,3)];
% 
%         fid = fopen('./paired_monuments.txt','wt'); 
%         fprintf(fid,'%2s %6s   %8s  %8s  %8s  \n','num','Corelat','Corelon','Monulat','Monulon');
%         
        ix=0;
        iy=0;
        
        for th=1:1:n_TH
            unused_clusters=[]; % reset clusters
            unused_monuments_coor = monument_coor;
            unused_monuments_XY = monument_XY;
            
            for i=1:n_clusters
                [ position, distance_final ] = pair_monu2core( unused_monuments_XY , input_matrix(i,:), threshold(th));

                % If the cluster is associated
                if (position ~= -1 && distance_final ~= -1) 
                    pairing_matrix(i,1) = ordered_clusters(i,1); 
                    pairing_matrix(i,2) = ordered_clusters(i,2);
                    pairing_matrix(i,3) = unused_monuments_XY(position,1);
                    pairing_matrix(i,4) = unused_monuments_XY(position,2);
                    pairing_matrix(i,5) = distance_final;
                    pairing_matrix(i,6) = ordered_clusters(i,5);
                    pairing_matrix(i,7) = 1;    % 1 means paired 

                    unused_monuments_XY(position,:) = []; % we extract that monument from the list
                    unused_monuments_coor(position,:) = [];
                    % If NOT associated
                else 
                    pairing_matrix(i,1) = ordered_clusters(i,1); 
                    pairing_matrix(i,2) = ordered_clusters(i,2);
                    pairing_matrix(i,3) = -1;
                    pairing_matrix(i,4) = -1;
                    pairing_matrix(i,5) = -1;
                    pairing_matrix(i,6) = ordered_clusters(i,5);
                    pairing_matrix(i,7) = 0;   % 0 means unpaired
                    unused_clusters = vertcat(unused_clusters,ordered_clusters(i,:));  % THIS COULD BE WRONG
            %         pairing_matrix(i) = [order_cores_XY(i,1) order_cores_XY(i,2) position position distance_final order_cores_XY(i,3)];

                end



            end   % DONE generating the pairing database

            % F value parameters for this particular TH
%                 NC = size(pairing_matrix(:,1),1);
%                 UC = size(unused_clusters(:,1),1);
%                 NM = n_monuments;
%                 UM = size(unused_monuments_XY(:,1),1);

                    NC = length(pairing_matrix);
                    UC = length(unused_clusters);
                    NM = n_monuments;
                    UM = length(unused_monuments_XY);

%             Get the F value of every TH
            [ F(th) ] = F_value( NC, UC, NM , UM );
    %         Generate a matrix to create a mesh
            F_matrix(max_dist_analisys,min_points_analisys,th) = F(th);
            
    
    
        end % Done diferent TH value calculationg
        Analysis_table(n_times,:) = [F min_points_analisys max_dist_analisys];
        fprintf('Progress at %d/100  completion...\n',round((n_times/analysis_size)*100));
        

    end    % END FOR MIN_POINTS
    
    
    
end

fclose(fidX);

% [X,Y] = meshgrid(10:10:500,10:10:150);
[X,Y] = meshgrid(min_db_dist:skip_db_dist:max_db_dist,min_db_points:skip_db_points:max_db_points);
% mesh(X,Y,F_matrix(:,:,1));

xi=1;
times=0;
for n=1:length(Analysis_table);
%     for xi =1:size(Analysis_table,2)-2
    times = times +1
    Z(xi,times)= Analysis_table(n,3);
    if Analysis_table(n,5)== max_db_points
         xi=xi+1;
         times=0;
    end
    

end

figure(1)
title('TH = 50');
xlabel('Min Points 500');
ylabel('Max dist 150');
mesh(Z)
% 
% figure(1)
% title('TH = 50');
% xlabel('Min Points 500');
% ylabel('Max dist 150');
% mesh(F_matrix(:,:,1))

figure(2)
title('TH = 100');
xlabel('Min Points 500');
ylabel('Max dist 150');
mesh(F_matrix(:,:,2))

figure(3)
title('TH = 200');
xlabel('Min Points 500');
ylabel('Max dist 150');
mesh(F_matrix(:,:,3))

figure(4)
title('TH = 300');
xlabel('Min Points 500');
ylabel('Max dist 150');
mesh(F_matrix(:,:,4))


[ parameters_meanF, parameters_thF] = Find_Best_Parameter( Analysis_table , 3); % The relevant parameter is the column 3
[db_class,db_type]=dbscan( XYcoor_n, parameters_meanF(1), parameters_meanF(2));
[cluster_XY, cluster_coor, cluster_size] = db_scan_fixed_range( XYcoor_n, samples, db_class, 0, dist_limit,Center_GT );
ordered_clusters = sortrows([cluster_XY cluster_coor cluster_size],-5);

parameters_meanF
parameters_thF

% [ XYcoor_n, samples ] = createClusterXY(  data_pictures_taken ,30000 ,10000 ,Center_GT);
% [db_class,db_type]=dbscan( XYcoor_n, parameters_meanF(1), parameters_meanF(2));
% [cluster_XY, cluster_coor, cluster_size] = db_scan_fixed_range( XYcoor_n, samples, db_class, 0, 10000,Center_GT );
% ordered_clusters = sortrows([cluster_XY cluster_coor cluster_size],-5);


n_size= size(ordered_clusters,1);
% print
fid = fopen('./Final_cluster.txt','wt');
for i=1:n_size
fprintf(fid,'%f,%f\n',ordered_clusters(i,3),ordered_clusters(i,4));
end
fclose(fid);