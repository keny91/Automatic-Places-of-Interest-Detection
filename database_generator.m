close all
clear all


%% Database_Generator.m
% This method will allocate the center of the city as (0,0) and will
% positionate all other coordinates relatively to that point.

% You are able to s

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
city_name = 'Berlin';
lat0 = 52.5192;
lon0 = 13.4061;
Center_GT =[lat0,lon0,mean_z];


% 	Generated Databases
inner_radious=2000;  % Distance that will make the first analysis (0-2000)
outter_radious=10000;  % Distance to the second analysis
n_databases = 20; % Number of databases


%   Number os samples to be taken
n_samples = 20000;
mean_z = mean(data_pictures_taken(:,3));
dist_limit = 10000; %  in meters, the distance that could be separated from the center of the city

%  Variables for dB_scan
% min_points = 80;
% max_dist = 50;

min_points_analisys_1 = 100;
max_dist_analisys_1 =40;

min_points_analisys_2 = 70;
max_dist_analisys_2 = 70;

min_points_cores = 3;
max_dist_cores = 100;

% VARIABLES, EVALUATION
threshold = 100; %threshold < suboptimal_threshold
suboptimal_threshold = 240;
penalty = 0;    % If a core is not associated, it applies a negative penalty





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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% STEP 1    ---   MULTIPLE DATABASES       %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  initialise a pair of values
cores_XY_final = [];
cores_GT_final = [];

for n=1:n_databases
   % XYcoor_n->XY and cluster -> GPS inside the boundry
    [ XYcoor_n, samples ] = createClusterXY(  data_pictures_taken ,n_samples ,dist_limit ,Center_GT);
    
    
    % We need to do 2 diferent db_scans
    [db_class,db_type]=dbscan( XYcoor_n, min_points_analisys_1, max_dist_analisys_1);
    [cores_XY_d1, cores_GT_d1, cluster_size_d1] = db_scan_fixed_range( XYcoor_n, samples, db_class, 0, inner_radious,Center_GT );
    
    [db_class,db_type]=dbscan( XYcoor_n, min_points_analisys_2, max_dist_analisys_2);
    [cores_XY_d2, cores_GT_d2, cluster_size_d2] = db_scan_fixed_range( XYcoor_n, samples, db_class, inner_radious, outter_radious,Center_GT );
    
    %   Concatenate both
    
    cores_XY = vertcat([cores_XY_d1 cluster_size_d1],[cores_XY_d2 cluster_size_d2]);
    cores_GT = vertcat(cores_GT_d1,cores_GT_d2);
    
    %   Concatenate both to generate a bigger matrix
    cores_XY_final = vertcat(cores_XY_final , cores_XY);
    cores_GT_final = vertcat(cores_GT_final, cores_GT);

%     eval(sprintf('Data%d = cores_XY', n)); % Create separated databases
 
%   sprintf('A%d',i) = 1;
    
end

%   Just to not chnge many things
cores_XY = cores_XY_final;
cores_GT = cores_GT_final;

% Clear uneussefull variables
clearvars cluster_size_d1 cluster_size_d2 cores_GT_d1 cores_GT_d2 cores_XY_d1 cores_XY_d2 cores_GT_final cores_XY_final core;

%   We do another dbscan to select which cores form another cluster
[db_class_datas,db_type]=dbscan( cores_XY, min_points_cores, max_dist_cores);
[core_cores_XY, core_cores_GT, core_cores_size] = db_scan_fixed_range( cores_XY, samples, db_class_datas, 0, dist_limit,Center_GT );

% ORDERED MATRIX
order_core_cores_XY = sortrows([core_cores_XY core_cores_size],-3);

figure(4)
title('Core Cores');
xlabel('X-AXIS');
ylabel('Y-AXIS');
set(gca,'xlim',[-10000 10000], 'ylim',[-10000 10000]); 
hold on;
scatter(0, 0, 'rx');
hold on;
scatter(0, 0, 'ro');
hold on;
scatter(core_cores_XY(:,1),core_cores_XY(:,2));
hold on;
scatter(0, 0, 'rx');
% color_map = hsv(n_clusters); 


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
n_clusters = size(cores_XY,1); 
n_clusters_CoreCores = size(order_core_cores_XY,1);



% Print a txt file with the lat/lon coordinates 
% NOTE: this loop could be allocated inside the previous loop to increase
% speed

fid = fopen('./cores.txt','wt'); 
fprintf(fid,'%2s %6s %8s %8s\n','num','lat','lon','muber of cores');
for i = 1:n_clusters_CoreCores
    fprintf(fid,'%d :   %f %f   %d\n',i,core_cores_GT(i,:),core_cores_size(i));
    % fprintf(fid,'%f\n',cores_GT(i,2));  % The format string is applied to each element of a

end
fclose(fid);


% SET THE (0,0) in the Core Plot
figure (1)
subplot(2,2,4)
title('Core Positions');
xlabel('X-AXIS');
ylabel('Y-AXIS');
set(gca,'xlim',[-10000 10000], 'ylim',[-10000 10000]); 
hold on;
scatter(0, 0, 'rx');
hold on;
scatter(0, 0, 'ro');
hold on;
scatter(cores_XY(:,1),cores_XY(:,2));
hold on;
scatter(0, 0, 'rx');
hold on;

color_map = hsv(n_clusters); 

 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% STEP 3 ---   EVALUATION    %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This step is used for both create a monument matrix of a city and
% evaluate how precise are our results.





% Convert GPS to meters

monument_XY = zeros(n_monuments,2);
if option_selected_load ~=3 % if an empty matrix is created if creas a log (0,0,meanz)
    monument_coor(:,3) = mean_z;  % WE give the height the mean altitude from data_pictures taken
end
for i=1:1:n_monuments
    [monument_XY(i,:)] = GPS2Meter(monument_coor(i,:),Center_GT);
end
 figure(1)
subplot(2,2,3)
    title('Monuments Location');
    set(gca,'xlim',[-10000 10000], 'ylim',[-10000 10000]); 
    xlabel('X-AXIS');
    ylabel('Y-AXIS');
    hold on;
    scatter(monument_XY(:,1), monument_XY(:,2), 'bx');
    hold on;


% Valoration and finding new cores

[ valoration , unused_cores,pairing_matrixn_asignated,n_asignated ] = result_valoration( monument_XY , order_core_cores_XY, threshold, suboptimal_threshold, penalty );
monument_coor = [monument_coor n_asignated];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% STEP 4 --- (OPTIONAL)  IMPROVEMENT   %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we will do the inverse process to try to find the latitude/longitude
% of the un paired cores.



% [unused_COOR] = meter2gps( unused_cores(1,:), Center_GT, 1, 1, mean_z) 


% STEP TO FIND THE LARGEST RADIOUS  -> max(samples(:,2)) = 103.92 ->
% Innecesary when most points are at 13.4
% [ point_closer ] = FindGTCoor( point_searched_XY,point_relative_coor, radious , z ,center)



NEW_DATABASE=monument_coor;

% NEW_LIST=monument_coor;

for i=1:size(unused_cores,1)
search_radious=5;
loops_done = 0;
point_relative=Center_GT;
% -1 indicates that this is a core that has been recently added to the monument list
 
while (search_radious ~= 0)
    [ point_closer ] = FindGTCoor( unused_cores(i,:), point_relative, search_radious , mean_z ,Center_GT);
    search_radious = search_radious/2; % reduce the radious
    point_relative = point_closer; %the next search will be around the closest point
    loops_done = loops_done+1;
end
% loops_done %debugg info
point_relative(4)= -1; 
point_relative(3)=mean_z;
% NEW_LIST = vertcat(NEW_LIST,point_relative);
NEW_DATABASE = vertcat(NEW_DATABASE,point_relative);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% STEP 4   ---   SAVE THE DATABASES       %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% STEP 4   ---   SAVE THE DATABASES       %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

option_selected_saved = 0;
while (option_selected_saved ~=1 && option_selected_saved ~= 2 && option_selected_saved ~= 3 && option_selected_saved ~= 4 )
    option_selected_saved = input('\nSAVE OPTIONS, select one:\n1 : Save new monument database\n2 : Save as\n3 : Exit and dont save\n4 : Manually Select Point-by-Point\n');
    if option_selected_saved == 1
        disp('Selected option 1, Database was saved ...');
        save('./newlistmo.mat','NEW_LIST');
    
    elseif (option_selected_saved == 2) 
        disp('Selected option 2, Enter the database name (cityname by default)...')
        database_name = input('Enter the Name of the database\n (We will name it as the city name if your entry is empty)','s');
        
        monument_coor = NEW_DATABASE;
        %by default we assignate the cityname
        if (isempty(database_name)) 
            save(strcat('./databases/',city_name,'.mat'),'monument_coor')
%             save(strcat('./databases/',city_name,'.mat'))    % After creating a 
    %        monument_coor = NEW_LIST;
            
        else
%             save('./newlistmo.mat','NEW_LIST');
            save(strcat('./databases/',database_name,'.mat'),'monument_coor')
        end
        

        
    elseif (option_selected_saved == 3) 
        disp('Selected option 3, Exiting without saving ...')
        
        
    elseif (option_selected_saved == 4) 
        disp('Selected option 4')
        
        
   
        
        
    

% % % % % % % % %         EXPERIMENTAL
% Concatenate All monument data in a single matrix
% COLUMN_CONTENT:
%    1_LAT  2_ LON 3_ALT(mean) 4_Number of assignated cores
%    5_Distance X 6_Distance Y 7_ asignated
% 7_ Assignated has 3 labels: 
%         1: not processed point
%         2: accepted point
%         3: rejected point

% We initialise COL 7 as zeros 
%  CAREFULL IF WE WANT TO IMPORT PREVIOUS LABELS


asigned_value = ones(n_monuments,1); %undefined value is 1
monument_data = [monument_coor monument_XY asigned_value];

list_size = 10;
zoom = 13;
% for i=1:n_monuments
    
%     
%     [ googleLink ] = generateGoogleLink( list_size,zoom, monument_data, i);
% %     googleLink
%     [img,index] = imread(googleLink);
%     figure(5);
%     imshow(img,index)

    gui2(monument_data)


%     input_label = input('Save point?  (1:yes / 2:no))','s');
%     if (input_label==1)
    % INSERT LABEL SETTING METHOD HERE
%     
% %     1_ Get chosen option
% %     end
% end

        
% % % % % % % % %        end - EXP 
     

    else    
        disp('Invalid Input, Try again  ...')
    end

end



