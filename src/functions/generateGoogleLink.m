function [ GMAPS_URL ] = generateGoogleLink( Xpoints, zoom , dataGT,n_point, compensation)
%findXcloseGTPoints Finds and returns a matrix with the closer points to the point
% dataGT(n_point) where n_point is the position in the matrix dataGT 
%   Detailed explanation goes here


% Get the oint we are searching
point_searched = dataGT(n_point,:);

% Eliminate it from the matrix so we wont asignate it to itself
dataGT(n_point,:)=[];


n_size = size(dataGT,1);


% Generate another column in the matrix 
for i=1:n_size
    d_point =[dataGT(i,5) dataGT(i,6)];
    dataGT(i,8)= distance2point([point_searched(5) point_searched(6)] , d_point);
    
    
end

% order the matrix
    ordered_core_cores_XY = sortrows(dataGT ,8);
    
    closer_points = zeros(Xpoints,3); 
    
%     set GT coordinates
    for j=1:Xpoints
        closer_points(j,1)= ordered_core_cores_XY(j,1); %get GT coor
        closer_points(j,2)= ordered_core_cores_XY(j,2);
        closer_points(j,3)= ordered_core_cores_XY(j,7); % get label 
        closer_points(j,4)= ordered_core_cores_XY(j,8);  % checking
        
    end
    
% GMAPS_URL = 'https://maps.googleapis.com/maps/api/staticmap?size=600x400&sensor=false&zoom=';
%  map-type = terrain
GMAPS_URL = 'https://maps.googleapis.com/maps/api/staticmap?size=600x400&sensor=false&maptype=terrain&zoom='; 

GMAPS_URL =strcat(GMAPS_URL,num2str(zoom,12));

node_str_undefined ='&markers=color:red';
node_str_accepted = '&markers=color:green';
node_str_rejected ='&markers=color:blue';



for n=1:3 %to max laberl 
% STRUCT &markers=color:red%7Clabel:G%7C40.711614,-74.012318
% POSIBLE TO USE THE JOIN REGULAR EXPRESSION?
    if n==1
        node_str = node_str_undefined;
    elseif n==2
        node_str = node_str_accepted;
    elseif n==3
        node_str = node_str_rejected;
    else
        node_str='ERROR';
    end

    str_lat_lon ='';
    for i=1:Xpoints % We search in all the points
        
       
       if  closer_points(i,3)==n 
%            if isempty(str_lat_lon)==0 % if is not empty 
               str_lat_lon=strcat(str_lat_lon,'|');
%            end

           lat_str = num2str(closer_points(i,1),12);
           lon_str = num2str(closer_points(i,2),12);
           str_lat_lon=strcat(str_lat_lon,lat_str,',',lon_str);

       end
    end
    
    if isempty(str_lat_lon)==0 % if is not empty 
        string_reg = strcat(node_str,str_lat_lon);  % contatenate the node string
        GMAPS_URL = strcat(GMAPS_URL,string_reg);
    end
        
end
    

%  Set the center coordinates
%  It will be centered at the compensated point

%     The original point will be displayed with yellow color
if (compensation(1) ~= 0 || compensation(2) ~= 0)
    node_str_compensated='&markers=color:yellow|';
    lat_str = num2str(point_searched(1),12);
    lon_str = num2str(point_searched(2),12);
    center_lat_lon=strcat(node_str_compensated,lat_str,',',lon_str);
    GMAPS_URL =strcat(GMAPS_URL,center_lat_lon);
end


%  Add and center to compensated position
    node_str_center='&markers=color:black|';
    lat_str = num2str(point_searched(1)+ compensation(1),12);
    lon_str = num2str(point_searched(2)+ compensation(2),12);
    
    center_lat_lon=strcat(node_str_center,lat_str,',',lon_str,'&center=',lat_str,',',lon_str);
    GMAPS_URL =strcat(GMAPS_URL,center_lat_lon);

%     GMAPS_URL = strcat(GMAPS_URL,'&center=',num2str(point_searched(1),12),',',num2str(point_searched(2),12));

    
    
    
end