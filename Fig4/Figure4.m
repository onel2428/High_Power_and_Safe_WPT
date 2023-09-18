%% Power consumption figure & average incident power density data for both IRS- and DMA-based architectures 
% Sections: 
% I. Load data: optimal values/points from IRS and DMA optimization.
% II. Figure settings & plot: define figure visual settings and plot.
% III. Simulation settings: for the average power density computation.
% IV. RF probes' positions: uniformly distributed on the sphere's surface with radius r.
% V. Average power density computation: via Monte Carlo integration (see [R1] for more details).
% VI. References.

clear; clc;

%% I. Load data
load("data/resultsIRS.mat");                % IRS optimum values/points
load("data/resultsDMA.mat")                 % DMA optimum values/points

%% II. Figure settings & plot
figure
set(gcf, 'Units', 'centimeters'); % set units 
LineWidth = 1.5;
axesFontSize = 14;
legendFontSize = 14;
afFigurePosition = [2 7 16 12]; 
set(gcf, 'Position', afFigurePosition,'PaperSize',[16 12],'PaperPositionMode','auto'); % [left bottom width height], setting printing properties

% plots 1 to 3 => IRS, last => DMA
plot(freqVec/1e9,10*log10(IRSPowConsumptVec(1,:)),'-pk','MarkerSize',7,'MarkerFaceColor','k','LineWidth',LineWidth); hold on
plot(freqVec/1e9,10*log10(IRSPowConsumptVec(2,:)),'-xk','MarkerSize',13,'MarkerFaceColor','k','LineWidth',LineWidth)
plot(freqVec/1e9,10*log10(IRSPowConsumptVec(3,:)),'->k','MarkerSize',7,'MarkerFaceColor','k','LineWidth',LineWidth)
plot(freqVec/1e9,10*log10(cons_vec),'-o','MarkerSize',7,'MarkerFaceColor',[0.9290 0.6940 0.1250],'Color',[0.9290 0.6940 0.1250],'LineWidth',LineWidth); 

% legend & axis labels
hold off
box on
grid on
ylim([17 28])
ylabel('power consumption (dB)','FontSize',axesFontSize,'Interpreter','latex')
xlabel('operating frequency (GHz)','FontSize',axesFontSize,'Interpreter','latex')
legend('$\infty$ resolution IRS','$1$-bit resolution IRS','$2$-bits resolution IRS',...
    'DMA','FontSize',legendFontSize,'Location','northwest','Interpreter','latex');

%% III. Simulation settings
dUser = 3;                                      % distance between user and the center of DMA or IRS [m]
freqVec = [1 2.5:2.5:20]*1e9;                   % operating frequency [Hz]
antennaLength = 0.5*sqrt(2);                    % antenna aperture [m]
psResolution = [0 1 2];                         % Phase shifter resolution [bits]
N = 1e3;                                        % Number of power probes

%% IV. RF probes' positions
theta = rand(N,1)*2*pi;                         % azimuth angle
x = rand(N,1);                                  % auxiliary variable
phi = acos(2*x-1);                              % elevation angle
r = .15;                                        % sphere' radius
devPos = [r*sin(phi).*cos(theta) ...            % x coordinate
    r*sin(phi).*sin(theta) ...                  % y coordinate
    r*cos(phi)+dUser];                          % z coordinate

%% V. Average power density computation

% Memory allocation
powDensity = zeros(numel(psResolution),numel(freqVec));

for ff = 1:F
    % IRS ET architeture
    IRS = IRSArchitecture(freqVec(ff),antennaLength,.36,dUser);
    
    % probes' channels
    h = irs2usrCh(IRS,devPos,freqVec(ff));
    for bb = 1:B
        disp([num2str(bb) '/' num2str(ff)])

        % precoder vector (from the results file)
        precod = sqrt(IRSOptConf{bb,ff}(1))*IRSOptConf{bb,ff}(2:end);
        
        % average power density computation
        for ii = 1:N
            powDensity(bb,ff) = powDensity(bb,ff) + pi/(2*r^2*N)*abs(h(:,ii)'*(precod.*IRS.t))^2;
        end
    end
end

%% VI. References
% [R1] O. L. A. López, et al., "Massive MIMO With Radio Stripes for Indoor % Wireless Energy Transfer," 
% in IEEE Trans. Wirel. Commun., vol. 21, no. 9, pp. 7088-7104, Sept. 2022, doi: 10.1109/TWC.2022.3154428.