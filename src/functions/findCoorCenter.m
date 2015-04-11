function [ center_out_XY, center_out_coor , distance] = findCoorCenter( cluster_coor, center )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% Simple K-means method:
% [IDX,C,sumd] = kmeans(X,k) where k is the number of clusters

center_out_XY = zeros(1,2);
center_out_coor = zeros(1,2);

[IDX,C,sumd] = kmeans(cluster_coor,1);



center_out_XY(1) = C(1);
center_out_XY(2) = C(2);

distance = sumd;

%  Longitude/ latitude conversion by diferential lat/long
%  WANRING: this could be a bad estimation, when the distance between
%  points is larger than 50km 
%  WANRING: this could be a bad estimation, when the points in processing
%  are close to one of the Earth poles (North or South)

%  We are assuming that the Earth´s roundness does not affect our
%  opperations since the distance between points is relatively small


%  THIS COOR METHOD IS UNUSED -> MUST BE REMOVED

%  Since the center is (0,0) in polar coordinates
dx = center_out_XY(1);
dy = center_out_XY(2);


% NOTE: might need a calibration
dlongitude = dx/(111320*cos(center(1)));
dlatitude = dy/110540; 

center_out_coor(1)=dlatitude + center(1);
center_out_coor(2)=dlongitude + center(2);




end

