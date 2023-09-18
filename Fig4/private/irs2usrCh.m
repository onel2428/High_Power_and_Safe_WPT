function h = irs2usrCh(IRS,devPos,fc)
    %IRS2USRCH Summary of this function goes here
    % Input args.:
    % IRS
    % devPos
    % fc
    % boresight_gain

    %% load structure & vars.
    M = IRS.M;
    pAnt = IRS.pAnt;
    N = size(devPos,1);
    boresight_gain = 5;

    %% wavelength
    lambda = physconst('LightSpeed')/fc;
     
    %% near-field channel
    h = zeros(M,N);
    for jj = 1:N
        for ii = 1:M
            r = norm(devPos(jj,:)' - pAnt(:,ii));
            theta = acos(devPos(jj,3)/r);
            F = (theta>=0 & theta<=pi/2)*2*(boresight_gain+1)*cos(theta)^boresight_gain;
            A = sqrt(F)*lambda/(4*pi*r);
            h(ii,jj) = A*exp(-1i*2*pi*r/lambda);
        end
    end
end

