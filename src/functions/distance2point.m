function [dist2center] = distance2point( point2 , point1)
%distance2point:  Measures de distance between 2 points

dist2center = sqrt((point1(1)-point2(1)).^2 +(point1(2)-point2(2)).^2);

end


