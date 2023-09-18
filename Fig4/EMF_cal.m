clear; clc

% first you need to load the obtaine Q matrices for all
% frequencies (obtained in the file 'Optimization_script.m'

load('PSO_Results.mat')

%% Simulation settings
boresight_gain = 20;                            % boresight gain of the antenna for near-field model !
d_user = 3;                                     % distance between user and the center of DMA or IRS [m]
RF_requirement = 1;                             % required RF power by user (Vector) [W]
antenna_length = 0.5;                          % antenna aperture
HPA_eff = 0.35; % HPA efficiency
c0 = physconst('LightSpeed'); % light speed
f_vec = [1 2.5 5 7.5 10 12.5 15 17.5 20].*1e9; % frequencies for EMF calculation  

r_sp_vec = 0.01:0.005:0.2; % radius range for EMF

N_samp = 1e5; % number of samples for EMF calculation 

EMF_VEC = zeros(length(f_vec), length(r_sp_vec)); % initialize EMF radiation results vec
CONS_VEC = zeros(length(f_vec), 1); % initialize power consumption results vec
channels = cell(length(f_vec), 1);

for ff = 1:length(f_vec) % go over frequencies
    [channel_vec, DMA_element_loc, H,...
        RFC_num, passive_num, user_loc] = DMA_deploy(f_vec(ff), d_user, antenna_length, boresight_gain);
    Q = Q_opt_vec{ff}; % Q_opt_vec is the cell array that you have obtained previously (when doing optimization)
    lambda = c0/f_vec(ff);
    a = reshape(channel_vec, [RFC_num*passive_num, 1]);
    channels{ff} = a;
    aH = a'*H;
    w = ones(RFC_num, 1);
    YY = reshape(DMA_element_loc, [RFC_num*passive_num, 3]);
    P_in = (RFC_num)/((norm(aH*Q*w))^2);
    P_t = (P_in/RFC_num)*((norm(H*Q*w))^2);
    CONS_VEC(ff) = P_t/HPA_eff % Calculate power consumption once again
    for rr = 1:length(r_sp_vec) % go over different radius values
        r_sp = r_sp_vec(rr); 
        coef = (1/(4*pi*r_sp^2))*((2*(pi^2))/N_samp); % EMF radiation coefficient
        emf_rad = 0;
        cordvec = zeros(N_samp, 1);
        for i=1:N_samp % go over the number of samples and generate new samples on a sphere with the predefined radius
            theta = randsample(linspace(0,2*pi),1);
            phi = randsample(linspace(0,pi),1);
            Px = user_loc(1)+r_sp*cos(theta)*sin(phi) ;
            Py = user_loc(2)+r_sp*sin(theta)*sin(phi) ;
            Pz = user_loc(3)+r_sp*cos(phi) ;
            cordvec(i,:) = [Px, Py, Pz];
            a = Do_Channels(YY, cordvec(i,:), boresight_gain, lambda);
            emf_rad = emf_rad + coef*((P_in/RFC_num).*((norm(a'*H*Q*w))^2)); % add the obtained value to your EMF average 
        end
        EMF_VEC(ff, rr) = emf_rad % store the EMF radiation result
    end
end

