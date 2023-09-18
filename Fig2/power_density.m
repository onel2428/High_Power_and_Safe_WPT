function Pdk = power_density(V, Hint, rk)
%%Input
%V:         covariance precoding matrix
%rk:        radio of the sphere centered at the UE position over which the power density will be computed
%Hint:      average covariance matrix of the LOS channels between the UE and the transmit antenna elements
%%Output
%Pdk:       power density at a distance rk from the UE

%Eq. (38) in [REF]
Pdk = real(trace(V.'*Hint))/(4*pi*rk^2);

%[REF] O. L. A. López, D. Kumar, R. D. Souza, P. Popovski, A. Tölli and M. Latva-Aho, "Massive MIMO With Radio Stripes for Indoor Wireless
% Energy Transfer," in IEEE Transactions on Wireless Communications, vol. 21, no. 9, pp. 7088-7104, Sept. 2022, doi: 10.1109/TWC.2022.3154428.