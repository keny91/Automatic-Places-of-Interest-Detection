

%   Load necessary funtions 
addpath('.\src\code\');
addpath('.\src\functions\');
% addpath('.\src\geo_conversion\');


%%%%%%%%%%%%%%%%%%%%%%%     PARAMETERS  %%%%%%%%%%%%%%%%%%%%%%%
%   Load the coordinates for each picture taken
data_pictures_taken = load('datafiles/gps_berlin/gps_berlin.txt');
mean_z = mean(data_pictures_taken(:,3));

%   City: BERLIN
city_name = 'Berlin';
lat0 = 52.5192;
lon0 = 13.4061;
Center_GT =[lat0,lon0,mean_z];


% 	Generated Databases
inner_radious=2000;  % Distance that will make the first analysis (0-2000)
outter_radious=10000;  % Distance to the second analysis
n_databases = 20; % Number of databases


%   Number os samples to be taken
n_samples = 30000;
mean_z = mean(data_pictures_taken(:,3));
dist_limit = 10000; %  in meters, the distance that could be separated from the center of the city

%  Variables for dB_scan
% min_points = 80;
% max_dist = 50;

min_points_analisys_1 = 120;
max_dist_analisys_1 =40;

min_points_analisys_2 = 120;
max_dist_analisys_2 = 60;

min_points_cores = 3;
max_dist_cores = 100;

% % VARIABLES, EVALUATION
% threshold = 100; %threshold < suboptimal_threshold
% suboptimal_threshold = 240;
% penalty = 0;    % If a core is not associated, it applies a negative penalty

threshold =[50 100 200 300];
n_TH = size(threshold(:),1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% STEP 0    ---   LOAD THE DATABASES       %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%   FIRST the user will be asked if he wants to load the previous monument database
%   o use the default given
option_selected_load=0;

%  Loop until one of the options is selected
while (option_selected_load ~=1 && option_selected_load ~= 2 && option_selected_load ~= 3 )
    option_selected_load = input('\nLOAD OPTIONS, select one:\n1 : Load default monument database\n2 : Load custom database\n3 : Generate a new Database\n');
    if option_selected_load == 1
        disp('Selected option 1, Loading Default Database ...');
%         load('./monument_coor')     % Run this line the first time, will createLoaded custom database   
        load('./berlin.mat') 
        
        
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
        
        
    elseif (option_selected_load == 3) 
        disp('Selected option 3, Generating a new database ...')
        monument_coor = [];
        %Check if the database exists
    

    else    
        disp('Invalid Input, Try again  ...')
    end
    
%     if (exist('monument_coor','var')~=1)
%         disp('Error database not found ...')
%         option_selected_load =0;
%         
%     end    

end



n_monuments = size(monument_coor,1);
monument_XY = zeros(n_monuments,2);
if option_selected_load ~=3 % if an empty matrix is created if creas a log (0,0,meanz)
    monument_coor(:,3) = mean_z;  % WE give the height the mean altitude from data_pictures taken
end
for i=1:1:n_monuments
    [monument_XY(i,:)] = GPS2Meter(monument_coor(i,:),Center_GT);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% STEP 1    ---   MULTIPLE DATABASES       %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  initialise a pair of values
cores_XY_final = [];
cores_coor_final = [];

for n=1:n_databases
   % XYcoor_n->XY and cluster -> GPS inside the boundry
    [ XYcoor_n, samples ] = createClusterXY(  data_pictures_taken ,n_samples ,dist_limit ,Center_GT);
    
    
    % We need to do 2 diferent db_scans
    [db_class,db_type]=dbscan( XYcoor_n, min_points_analisys_1, max_dist_analisys_1);
    [cores_XY_d1, cores_coor_d1, cluster_size_d1] = db_scan_fixed_range( XYcoor_n, samples, db_class, 0, inner_radious,Center_GT );
    
    [db_class,db_type]=dbscan( XYcoor_n, min_points_analisys_2, max_dist_analisys_2);
    [cores_XY_d2, cores_coor_d2, cluster_size_d2] = db_scan_fixed_range( XYcoor_n, samples, db_class, inner_radious, outter_radious,Center_GT );
    
    %   Concatenate both
    
    cores_XY = vertcat([cores_XY_d1 cluster_size_d1],[cores_XY_d2 cluster_size_d2]);
    cores_GT = vertcat(cores_coor_d1,cores_coor_d2);
    
    %   Concatenate both to generate a bigger matrix
    cores_XY_final = vertcat(cores_XY_final , cores_XY);
    cores_coor_final = vertcat(cores_coor_final, cores_GT);

%     eval(sprintf('Data%d = cores_XY', n)); % Create separated databases
 
%   sprintf('A%d',i) = 1;
    
end

%   Just to not chnge many things
cores_XY = cores_XY_final;
cores_GT = cores_coor_final;

% Clear uneussefull variables
clearvars cluster_size_d1 cluster_size_d2 cores_coor_d1 cores_coor_d2 cores_XY_d1 cores_XY_d2 cores_coor_final cores_XY_final core;

%   We do another dbscan to select which cores form another cluster
[db_class_datas,db_type]=dbscan( cores_XY, min_points_cores, max_dist_cores);
[core_cores_XY, core_cores_coor, core_cores_size] = db_scan_fixed_range( cores_XY, samples, db_class_datas, 0, dist_limit,Center_GT );

% ORDERED MATRIX
order_core_cores_XY = sortrows([core_cores_XY core_cores_size],-3);

% figure(4)
% title('Core Cores');
% xlabel('X-AXIS');
% ylabel('Y-AXIS');
% set(gca,'xlim',[-10000 10000], 'ylim',[-10000 10000]); 
% hold on;
% scatter(0, 0, 'rx');
% hold on;
% scatter(0, 0, 'ro');
% hold on;
% scatter(core_cores_XY(:,1),core_cores_XY(:,2));
% hold on;
% scatter(0, 0, 'rx');
% % color_map = hsv(n_clusters); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% STEP 1 --- CONVERSION_TO_2D_COORDINATES  %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [ XYcoor_n, samples ] = createClusterXY(  data_pictures_taken ,n_samples ,dist_limit ,Center_GT);


figure(1)
subplot(2,2,1)
scatter(XYcoor_n(:,1),XYcoor_n(:,2))
set(gca,'xlim',[-10000 10000], 'ylim',[-10000 10000]);
hold on;
scatter(0, 0, 'rx');
hold on;


%CLEAN non-useful variables to free memory
clearvars XYcoor dist2center dist_limit lon0 lat0;



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% STEP 2 --- CLUSTER SEARCH  %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  WARNING: this could be a bad estimation, when the distance between
%  points is larger than 50km 
%  WANRING: this could be a bad estimation, when the points in process
%  are close to one of the Earth poles (North or South)


% the number of clusters has changed, we discarded those who where outside
% of the radious
n_clusters = size(core_cores_XY,1); 
n_clusters_CoreCores = size(order_core_cores_XY,1);
ordered_clusters = order_core_cores_XY;


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
                    pairing_matrix(i,6) = ordered_clusters(i,3);
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
                    pairing_matrix(i,6) = ordered_clusters(i,3);
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
%             F_matrix(max_dist_analisys,min_points_analisys,th) = F(th);
            
           
    
        end % Done diferent TH value calculationg
      
 F
