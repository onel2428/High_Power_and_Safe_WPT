function initPoint = IRSInitSol(IRS,psResolution)
    % Computes an initial solution point of the Genetic algorithm solver.
    % Arguments: 
    %   IRS -> IRS ET architecture structure (see IRSArchitecture.m file)
    %   psResolution -> phase shifter resolution [bits]
    % Output:
    %   initPoint -> initial (integer) solution point for Genetic algorithm   

    % compute phase shifters configuration
    psAngleMRT = angle(IRS.h)-angle(IRS.t);
    psAngleMRT(psAngleMRT<0) = psAngleMRT(psAngleMRT<0) + 2*pi;

    % feasible discrete phase shifting configuration set
    psAngleSet = linspace(0,2*pi,2^psResolution+1);
    psAngleSet(end) = [];
    psAngleIdx = 1:2^psResolution;

    % map the MRT solution into the integer domain optimization variables
    initPoint = zeros(1,IRS.M);
    for mm = 1:IRS.M
        [~,idx] = min(abs(psAngleSet - psAngleMRT(mm)));
        initPoint(mm) = psAngleIdx(idx);
    end
end

