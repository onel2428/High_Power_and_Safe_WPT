function x = mappingVars(x,psResolution)
    % Maps optimization variables onto the discrete phase shiftings set
    % Arguments:
    %   x -> integer optimization variables
    %   psResolution -> phase shifter resolution [bits]
    % Ouputs:
    %   x -> mapped optimzation variable

    % define the phase shiftings set
    psAngleSet = linspace(0,2*pi,2^psResolution+1);
    psAngleSet(end) = [];
    psAngleSet(psAngleSet>pi) = psAngleSet(psAngleSet>pi) - 2*pi;

    % perform the mapping
    x = psAngleSet(x);
end