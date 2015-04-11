function [ point_closer ] = FindGTCoor( point_searched_XY, point_relative_coor, radious , z ,center)
%UNTITLED Summary of this function goes here
%   When it`s the first analysis point_relative_coor = center

% Cuadrants: lat0,lon0 ->cuadrant 5
% |------|------|------|
% |   7  |   8  |   9  |
% |------|------|------|
% |   4  |   5  |   6  |
% |------|------|------|
% |   1  |   2  |   3  |
% |------|------|------|

lat0=point_relative_coor(1);
lon0=point_relative_coor(2);
cuadrant=0;
minimun_diference=10000000;  % to be sure it is more than the previous
point_closer = [0 0];
% We analise which of the 9 cuadrants
for i=lat0-radious:radious:lat0+radious
    for j=lon0-radious:radious:lon0+radious
        
        coor = [i j z];
        cuadrant=cuadrant+1;
        [XY] = GPS2Meter(coor,center);
        x = XY(1);
        y = XY(2);     
        dx= point_searched_XY(1) - x;
        dy= point_searched_XY(2) - y;
        diference = sqrt(dx.^2 +dy.^2);
        if (diference < minimun_diference)
            minimun_diference=diference;
            point_closer = [i j];
            chosen_cuadrant = cuadrant;
        end
    
    
    end   
end
% Debbug info
% chosen_cuadrant
% point_close


end

