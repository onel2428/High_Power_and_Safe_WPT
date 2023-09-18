%% This script generates the power density plot as a function of the distance from the user rk
freq = 5e9;        %frequency of operation
lambd = 3e8/freq;  %wavelength      
M = 100;           %number of transmit antenna elements
d = 8;             %distance between the transmit antenna array and the UE
ue(3) = d;         %z-position of the UE
S = 1e3;           %number of Monte Carlo samples for the power density estimation

%Computation of the dimensions of the transmit antenna array as a function
%of lambda and d' (defined in the discussions around Fig. 2 in [REF1])
Df = @(l,coef) sqrt(coef*l/2); %here coef=d', which is set to 5 in the next line
D = Df(lambd,5);               
dim_xy = [D/sqrt(2) D/sqrt(2)];

%Computation of the position of the transmit antenna elements 
[x, y, ~] = antenna_elements_position(dim_xy, M, freq, D);

%Herein, we place the UE in the boresight direction of the transmit antenna array
ue(1) = mean(x);
ue(2) = mean(y);

%Computation of the LOS channels between the transmit antenna elements and the UE
hlos = LOS_channel(ue, [x' y' zeros(M,1)], M, freq);

%Computation of the normalized MRT precoder
normalz = sqrt(sum(abs(hlos).^2,2));
w = hlos./repmat(normalz,1,M);

%Computation of the power density for each rk in R (Check [REF2], around eq. 38)
R = 0.0025:0.0025:0.2;
for j=1:length(R) 
    %Computation of the average covariance matrix of the LOS channels between the UE and the transmit antenna elements
    Hint = LOS_cov_sphere(R(j), ue, [x' y' zeros(M,1)], M, freq, 1e3);

    %Computation of the covariance precoding matrix
    V = w.'*conj(w);

    %Power density at the distance R(j) from the UE 
    Pdk(j) = power_density(V, squeeze(Hint), R(j));   
end

figure
set(gcf, 'Units', 'centimeters'); % set units 
LineWidth = 2;
axesFontSize = 14;
legendFontSize = 14;
% setting size & position
afFigurePosition = [2 7 16 12]; % [pos_x pos_y width_x width_y] 
set(gcf, 'Position', afFigurePosition,'PaperSize',[16 12],'PaperPositionMode','auto'); % [left bottom width height], setting printing properties 

pow = norm(hlos)^2;  %for normalization
plot(100*R,10*log10(Pdk/pow),'-ok','MarkerIndices', 1:4:80, 'MarkerSize', 7, 'MarkerFaceColor','k','LineWidth',1.5); hold on


xlabel('$r$ (cm)','Interpreter','latex','FontSize',axesFontSize)
ylabel('(local) incident power density (dB/m$^2$)','Interpreter','latex','FontSize',axesFontSize)

set(gca,'FontSize',axesFontSize)


%[REF1] O. López et al., "High-Power and Safe RF Wireless Charging: Cautious
%Deployment and Operation", in IEEE Wireless Communications (submitted)

%[REF2] O. L. A. López, D. Kumar, R. D. Souza, P. Popovski, A. Tölli and M. Latva-Aho,
% "Massive MIMO With Radio Stripes for Indoor Wireless Energy Transfer," in IEEE Transactions
% on Wireless Communications, vol. 21, no. 9, pp. 7088-7104, Sept. 2022, doi: 10.1109/TWC.2022.3154428.