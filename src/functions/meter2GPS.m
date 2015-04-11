function [ point_COOR ] = meter2gps( point_XY, center_COOR, Dlat, Dlon, z )
% Since is very hard to reverse the result caused by the function gps2meter
% we are using gps2meter to find the exact point comparing results
% 
% 
% NOTE:  this analysis will slow the process and it´s only used to create a
% monument database. It is advizable to discard it whenever possible
%   We are aproximating the altitude 
% REMEMBER TO TRY GIVEN Z = 0

Xo = point_XY(1);
Yo = point_XY(2);

found = 0;

% We will search for the point with complete precision
for i= center_COOR(1)-Dlat:0.0001:center_COOR(1)+Dlat
    for j=center_COOR(2)-Dlon:0.0001:center_COOR(2)+Dlon
        coor =[i j z];
        [XY] = GPS2Meter(coor,center_COOR);
        x = XY(1);
        y = XY(2);
        if (x == Xo && y == Yo)
            % THIS SHOULD BE THE NORMAL WAY TO EXIT THE FUNCTION
            point_COOR = [coor(1) coor(2)];
            found=1;


            break;
        end
    end
    
    if found==1
        break;
        
    end
    
end
i
j
found
end


