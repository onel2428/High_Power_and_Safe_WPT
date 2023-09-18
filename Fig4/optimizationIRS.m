%% Power consumption minimization of the IRS-assisted ET
% The code comprises the following sections: I) Simulation settings, in
% which the main simulation parameters are defined; II) Optimization loop,
% in which the problem is solved via maximum ratio transmission (MRT) and
% Genetic algorithm for infinite and finite resolution phase shifters,
% respectively; III) Save results, in which the results are saved into
% a .mat file containing both the power consumption and transmission
% power+passive precoder for each operating frequency and phase shifters'
% resolution value; and IV) References. 

clear; clc

%% I. Simulation settings
dUser = 3;                                      % distance between user and the center of IRS [m]
rfRequirement = 1;                              % required RF power by ER [W]
freqVec = [1 2.5:2.5:20]*1e9;                   % operating frequency [Hz]
antennaLength = 0.5;                            % antenna aperture [m]
psResolution = [0 1 2];                         % Phase shifter resolution [bits] (0 -> Inf. resulution)
rho = 0.36;                                     % power efficiency factor (see [R1])
paEff = 0.35;                                   % power amplifier efficiency
IRSPassElemCtrlPow = 5e-3;                      % control power per passive element [W]
fixIRSCtrlBoard = 1;                            % fixed power consumption of the control board [W]

%% II. Optimization loop

% Memory allocation
IRSPowConsumptVec = zeros(numel(psResolution),numel(freqVec));
IRSOptConf = cell(numel(psResolution),numel(freqVec));

for ff = 1:numel(freqVec)
    % IRS ET architecture 
    IRS = IRSArchitecture(freqVec(ff),antennaLength,rho,dUser);

    for bb = 1:numel(psResolution)        
        disp([num2str(bb) '/' num2str(ff)])

        if psResolution(bb) == 0
            %% II.A Maximum ratio transmission (MRT) -based solution
            [IRSOptConf{bb,ff}, IRSPowConsumptVec(bb,ff)] = IRSMRTSol(IRS,rfRequirement,paEff,IRSPassElemCtrlPow,fixIRSCtrlBoard);
        else
            %% II.B Genetic algorithm -based solution
            % The optimization problem consists in maximizing the received
            % power at the ER. Then, the corresponding transmission power
            % and consumed power are computed based on the RF power
            % requirements at the ER.

            % Constraints
            nvars = IRS.M;                              % number of optimization variables
            lb = ones(1,nvars);                         % lower bounds
            ub = 2^psResolution(bb)*ones(1,nvars);      % upper bounds
            intcon = 1:nvars;                           % integer constraints
            
            % Objective function
            FitnessFunction = @(x)objFuncIRS(x,IRS,psResolution(bb));
            
            % Inital point based on MRT
            initPoint = IRSInitSol(IRS,psResolution(bb));
            
            % We recomend enabling the option 'UseParallel'
            options = optimoptions('ga','PopulationSize',1000,'FunctionTolerance',1e-8,...
                'InitialPopulationMatrix',initPoint);
            
            % Reproducible results
            rng default
            [xVal,fval] = ga(FitnessFunction,nvars,[],[],[],[],lb,ub,[],intcon,options);

            % Power consumption: power amplifier + IRS control circuit
            IRSPowConsumptVec(bb,ff) = rfRequirement/(-fval*paEff) + IRS.M*IRSPassElemCtrlPow + fixIRSCtrlBoard;
            
            % Transmission power & passive precoder solution
            phaseShift = mappingVars(xVal,psResolution(bb));
            passPrecoder = exp(1i*phaseShift');

            IRSOptConf{bb,ff} = [rfRequirement/(-fval); passPrecoder];
        end
    end
end

%% III Save results
save('data/resultsIRS.mat',"IRSPowConsumptVec","IRSOptConf")

%% IV References
% [R1] V. Jamali, et al., "Intelligent Surface-Aided Transmitter Architectures for Millimeter-Wave Ultra Massive MIMO Systems,"
% in OJ-COMS, vol. 2, pp. 144-167, 2021, doi: 10.1109/OJCOMS.2020.3048063.