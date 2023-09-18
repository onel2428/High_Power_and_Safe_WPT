function [x, y, sep] = antenna_elements_position(dim_xy, M, frequency, D)
%% Input:
% dim_xy:   2-element vector with the x,y size dimensions of the antenna array
% M:        number of antenna elements
%frequency: frequency of operation
%D:         diameter of the antenna array
%% Output:
%x:         M-vector of the x-locations of the antenna elements
%y:         M-vector of the y-locations of the antenna elements
%sep:       separation between adjacent antenna elements

c = 3e8;              %light speed
lambda = c/frequency; %wavelength

%Center of the antenna array [xc,yc]
xc = dim_xy(1)/2;
yc = dim_xy(2)/2;

%number of antennas in the x and y axis, respectively
xantenna = floor(sqrt(M));
yantenna = floor(sqrt(M));

sep = max([D/(sqrt(2)*(xantenna-1)) lambda/2]); % separation between adjacent antenna elements (never smaller than \lambda/2)

%Computation of the x/y-locations of the antenna elements
if mod(xantenna,2)==0
    x = xc -sep/2 - sep*(0:(xantenna/2-1));
    x = [x xc + sep/2 + sep*(0:(xantenna/2-1))];
else
    x = xc - sep*(0:((xantenna-1)/2));
    x = [x xc + sep*(1:((xantenna-1)/2))];
end
x = repelem(x,yantenna);

if mod(yantenna,2)==0
    y = yc -sep/2 - sep*(0:(yantenna/2-1));
    y = [y yc + sep/2 + sep*(0:(yantenna/2-1))];
else
    y = yc - sep*(0:((yantenna-1)/2));
    y = [y yc + sep*(1:((yantenna-1)/2))];
end
y = repmat(y,1,xantenna);