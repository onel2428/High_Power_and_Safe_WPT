function [channel_vec, DMA_element_loc, H,...
    RFC_num, passive_num, user_loc] = DMA_deploy(f, d_user, antenna_length, boresight_gain)

%% Initial Parameters

c0 = physconst('LightSpeed'); % light speed
lambda = c0/f; % wavelength 
antenna_length_vec = [antenna_length antenna_length]; % antenna dimensions
RFC_num = floor(antenna_length_vec(1) / (0.5*lambda));  %% Number of RF Chains
passive_num = floor(antenna_length_vec(2) / (0.2*lambda)); % number of passive elements on each waveguide

%% Deploy the DMA and Calculate element Loss 

DMA_WG_dist = lambda/2; % inter-waveguide (inter-RF chain) distance
DMA_element_dist = lambda/5; %  inter-element distance

H = zeros(passive_num*RFC_num, passive_num*RFC_num); % DMA propgation matrix 
for i = 1:RFC_num
    for l = 1:passive_num
        H((i-1)*passive_num + l, (i-1)*passive_num + l) = H_DMA(f(1), ...
            antenna_length_vec, (l-1)*DMA_element_dist); % calculate propagation charachteristics of each element 
    end
end

x_min = 0; x_max = 5; y_min = 0; y_max = 5;

DMA_loc = [(x_min + x_max)/2 - floor(passive_num/2)*DMA_element_dist ...
    (y_min + y_max)/2 - floor(RFC_num/2)*DMA_WG_dist 0];

% set the user location in d_user distance 

user_loc = [(x_min + x_max)/2 (y_min + y_max)/2 d_user];

% define the location of each element in DMA 

DMA_element_loc = zeros(RFC_num*passive_num, 3);

for i = 1:RFC_num
    for j = 1:passive_num
        DMA_element_loc((i-1)*passive_num + j, :) = [DMA_loc(1) + (j - 1)*DMA_element_dist ...
            DMA_loc(2) + (i - 1)*DMA_WG_dist, DMA_loc(3)];
    end
end

DMA_element_loc = reshape(DMA_element_loc, [RFC_num, passive_num, 3]);


%% Caluclate The Channel Coefficients for near-field channel model !

channel_vec = zeros(RFC_num, passive_num);

for i = 1:RFC_num
    for l = 1:passive_num
        dz = norm(DMA_element_loc(i, l, 3) - user_loc(3));
        d3D  = sqrt(sum((reshape(DMA_element_loc(i, l, :), [1, 3]) - user_loc) .^ 2));
        channel_rad = 2*(boresight_gain+1)*...
            ((dz/d3D)^boresight_gain);
        A_channel = sqrt(channel_rad) * (lambda/(4*pi*d3D));
        phase_channel = d3D/lambda;
        channel_vec(i, l) = A_channel*exp(-1i*2*pi*phase_channel);
    end
end

end