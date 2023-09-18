function IRS = IRSArchitecture(fc,antennaLength,rho,d_user)
    % IRS assisted ET architecture.
    % Arguments: 
    %   fc ->
    %   
    
    % wavelength & IRS elements separation
    lambda = physconst('LightSpeed')/fc;
    dxy = lambda/5;

    % size & number of IRS passive elements
    M = floor(antennaLength/dxy + 1);

    % position of the feeder
    feederCord = [0 0 4*antennaLength/sqrt(pi)]';

    dcorr = (antennaLength-(M-1)*dxy)/2;

    % position of the IRS' elements
    pAnt = zeros(3,M^2);
    for nn = 1:M^2
        pAnt(1,nn) = -antennaLength/2 + mod(nn-1,M)*dxy + dcorr;          % x coordinate
        pAnt(2,nn) = antennaLength/2 - floor((nn-1)/M)*dxy - dcorr;       % y coordinate
        pAnt(3,nn) = 0;                                                   % z coordinate
    end

    % wireless channel between the active antenna and the IRS
    t = zeros(M^2,1);
    for nn = 1:M^2
        r = norm(feederCord - pAnt(:,nn));

        % IRS-to-feeder (passive antenna gain)
        theta_irs_feeder = acos(feederCord(3)/r);
        boresight_gain = 5;
        gIRS = (theta_irs_feeder>=0 & theta_irs_feeder<=pi/2)*2*(boresight_gain+1)*cos(theta_irs_feeder)^boresight_gain;

        % feeder-to-IRS (active antenna gain)
        theta_feeder_irs = acos(feederCord(3)/r);
        boresight_gain = 2;
        gFeeder = (theta_feeder_irs>=0 & theta_feeder_irs<=pi/2)*2*(boresight_gain+1)*cos(theta_feeder_irs)^boresight_gain;

        % channel feeder - IRS
        t(nn) = lambda*sqrt(rho*gIRS*gFeeder)*exp(-1i*2*pi*r/lambda)/(4*pi*r);
    end

    % channel vector IRS ET to ER
    devPos = [0 0 d_user]';

    h = zeros(M^2,1);
    boresight_gain = 5;
    for ii = 1:M^2
        r = norm(devPos - pAnt(:,ii));
        theta = acos(devPos(3)/r);
        F = (theta>=0 & theta<=pi/2)*2*(boresight_gain+1)*cos(theta)^boresight_gain;
        A = sqrt(F)*lambda/(4*pi*r);
        h(ii) = A*exp(-1i*2*pi*r/lambda);
    end

    %% ouput structure with the IRS-aided architecture
    IRS.M = M^2;
    IRS.pAnt = pAnt;
    IRS.lambda = lambda;
    IRS.t = t;
    IRS.h = h;
end

