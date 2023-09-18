function PowConsump = IRSPowConsumption(x,IRS,psResolution,RF_requirement)
    % This function computes the power consumption of the IRS-aided
    % architecture for a given RF power requirement at the IoT device

    %% IRS-assisted Tx configuration (loading structure)
    M = IRS.M;                              % number of IRS passive elements
    t = IRS.t;                              % wireless channel between the active antenna and the IRS
    h = IRS.h;                              % wireless channel between the IRS and the user
    
    %% project the ps. conf. into the finite feasible set
    psAngleSet = linspace(0,2*pi,2^psResolution+1);
    psConfFinite = interp1(psAngleSet,psAngleSet,x(2:end),"nearest");
    psConfFinite(psConfFinite>pi) = psConfFinite(psConfFinite>pi) - 2*pi;

    %% received power @ IoT device
    passiveBeamf = exp(1i*psConfFinite');
    pRF = x(1)*abs(h'*(passiveBeamf.*t))^2;

    %% penalty (to consider the rf power constraint)
    if pRF >= RF_requirement
        PowConsump = x(1)/.35;
    else 
        PowConsump = 1e4;
    end
end