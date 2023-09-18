function [IRSOptConf,IRSPowConsumpt] = IRSMRTSol(IRS,rfRequirement,paEff,IRSPassElemCtrlPow,fixIRSCtrlBoard)
    % Computes the passive precoder, transmision power, and consumed power
    % of the IRS ET using MRT.
    % Arguments: 
    %   IRS -> IRS ET architecture structure (see IRSArchitecture.m file)
    %   rfRequirement -> required RF power by ER [W]
    % Outputs:
    %   IRSOptConf -> [transmission power passPrecoder] column vector
    %   IRSPowConsumpt -> overall power consumption of the IRS ET
    
    % compute phase shifter configuration (inf. resolution)
    passPrecoder = exp(1i*(angle(IRS.h)-angle(IRS.t)));
    
    % received power at the ER
    pRF = abs(IRS.h'*(passPrecoder.*IRS.t))^2;
    
    % required transmission power
    txPow = rfRequirement/pRF;
    
    % overall power consumption, 
    IRSPowConsumpt = txPow/paEff + IRS.M*IRSPassElemCtrlPow + fixIRSCtrlBoard;
    IRSOptConf = [txPow; passPrecoder];
end