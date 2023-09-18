function rxPow = objFuncIRS(x,IRS,psResolution)
    % Objective function for the Genetic algorithm solver.
    % Arguments: 
    %   x -> optimization variable (1xM)
    %   IRS -> IRS ET architecture structure (see IRSArchitecture.m file)
    %   psResolution -> phase shifter resolution [bits]
    % Ouput: 
    %   rxPow -> received power at the ER when transmitting with 1W

    % map optimization variables onto the discrete phase shiftings set
    x = mappingVars(x,psResolution);
    
    % passive precoder
    passPrecoder = exp(1i*x');

    % received RF power at the ER
    rxPow = -abs(IRS.h'*(passPrecoder.*IRS.t))^2;
end

