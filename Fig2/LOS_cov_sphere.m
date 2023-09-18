function Hint = LOS_cov_sphere(rk, posUE, PosA, M, frequency, S)
%%Input
%rk:        radio of the sphere centered at the UE position over which the power density will be computed
%posUE:     3D spatial position of the UE
%PosA:      Mx3 matrix collecting the 3D positions (in each row) of the M transmit antenna elements
%M:         number of transmit antenna elements
%frequency: frequency of operation
%S:         number of Monte Carlo samples for the power density computation
%%Output
%Hint:      average covariance matrix of the LOS channels between the UE and the transmit antenna elements

%Function to create the LOS channel between the transmit antenna elements and the receive point over the rk-sphere
% at the UE in angular position (v,w). Angle v is measured in the x-y plane, while angle w is measured in the z plane
hlos = @(v,w) LOS_channel(posUE+[rk*sin(w).*cos(v) rk*sin(w).*sin(v) rk*cos(w)], PosA, M, frequency);

%Random generation (v,w) that correspond to uniformly distributed points in the rk-sphere
v = 2*pi*rand(1,S);  % Define the x-points
w = acos(2*rand(1,S)-1);    % Define the y-points

%Numerical computation of the average covariance matrix of the LOS channels between the UE and the transmit antenna elements based on Monte Carlo
F = zeros(M,M); 
for i=1:S    
    h = hlos(v(i),w(i));
    F = F + h.'*conj(h);
end
Hint = 2*pi*pi*F/S; %The analytical expression to compute this is given in [REF] (after (eq.38)), but the Monte carlo Alternative here is more computational affordable

%[REF] O. L. A. López, D. Kumar, R. D. Souza, P. Popovski, A. Tölli and M. Latva-Aho, "Massive MIMO With Radio Stripes for Indoor Wireless
% Energy Transfer," in IEEE Transactions on Wireless Communications, vol. 21, no. 9, pp. 7088-7104, Sept. 2022, doi: 10.1109/TWC.2022.3154428.