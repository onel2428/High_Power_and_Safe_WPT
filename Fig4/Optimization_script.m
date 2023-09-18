clear; clc

% optimization includes two stages, first: all elements togeteher are
% optimized. Then, the waveguides are splitted into different groups with
% 'pp'members and the optimization is done separately for them.

%% Simulation settings
boresight_gain = 20;                            % boresight gain of the antenna for near-field model !
d_user = 3;                                     % distance between user and the center of DMA or IRS [m]
RF_requirement = 1;                             % required RF power by user (Vector) [W]
freq_vec = [1 2.5 5 7.5 10 12.5 15 17.5 20].*1e9;                       % operating frequency [Hz]
antenna_length = 0.5;                          % antenna aperture
HPA_eff = 0.35; % HPA efficiency
%% Optimization loop
Q_opt_vec = cell(length(freq_vec), 1); % initialize the data containing the DMA configuration 
DMA_Final_Result_Vec = zeros(numel(freq_vec), 1); % inititalize the result vector
F = numel(freq_vec); 
group_iter = 20; % number of iterations for splitting the waveguides and optimizing them separately 

for ff = 1:F       % over frequency range
    disp([num2str(ff)])

    %% Start First Stage
    [channel_vec,~,H,RFC_num,passive_num,~] = DMA_deploy(freq_vec(ff), ...
        d_user, antenna_length, boresight_gain); % deploy DMA and user
    N_d = RFC_num; N_e = passive_num; 
    nvars = RFC_num*passive_num;       % total number of variables
    lb = zeros(1, nvars); ub = zeros(1, nvars) + 1;  % variables lower bound and upper bound
    max_iter = 6000;   % maximum iterations of PSO    
    swarm_size = 500;  % swarm size 
    optionsDMA1 = optimoptions("particleswarm",'MaxIterations',max_iter, ...
        'SwarmSize', swarm_size, 'PlotFcn','pswplotbestf', 'FunctionTolerance', 1e-6, 'UseParallel', true);
    
    a = reshape(channel_vec, [N_d*N_e 1]);
    aH = a'*H; % combination of channel and element loss 

    FitnessFunction1 = @(x) Gain_objective(x, aH, RFC_num, passive_num);    

    [x_gain,P_rcv] = particleswarm(FitnessFunction1, nvars, lb, ub, optionsDMA1); % run optimization with previously defined setting 

    phi_vec = reshape(x_gain, [RFC_num, passive_num]);
    Q = zeros(RFC_num*passive_num, RFC_num);
    
    for i = 1:RFC_num
        for l = 1:passive_num
            Q((i - 1)*passive_num + l, i) = Q_DMA(phi_vec(i,l) * 2 * pi); % construct optimal Q
        end
    end
    w = ones(N_d, 1);
    P_t = (RF_requirement*N_d)/((norm(a'*H*Q*w))^2); % derive the required transmit power based on Q

    DMA_Final_Result_Vec(ff) = P_t/HPA_eff % save the power consumption result in the result vector
    
    % second stage of the optimization (going over the waveguides)

    opt_iter = 1; 
    while opt_iter < group_iter
        pp = 1; % define your desired number of waveguides in each group for optimization 
        Xfinal = [];
        iter = 1;
        max_iter = 1500;               
        swarm_size = 500;  
        while true
            
            nvars = min(pp, N_d - (iter-1)*pp)*passive_num;         
            lb = zeros(1, nvars); ub = zeros(1, nvars) + 1; 
            optionsDMA1 = optimoptions("particleswarm",'MaxIterations',max_iter, ...
                'SwarmSize', swarm_size, 'PlotFcn','pswplotbestf', 'FunctionTolerance', ...
                1e-6,'InitialSwarmMatrix', x_gain((iter - 1)*pp*passive_num + 1:min(iter*pp, N_d)*passive_num), ...
                1e-6, 'UseParallel', true);
            FitnessFunction1 = @(x) Gain_objective_rev(x, aH, x_gain, iter, pp, RFC_num, passive_num);                 
            [x_gain1,P_rcv] = particleswarm(FitnessFunction1, nvars, lb, ub, optionsDMA1);
            x_gain((iter - 1)*pp*passive_num + 1:min(iter*pp, N_d)*passive_num) = ...
                x_gain1; % replace the new values for the selected waveguides
            phi_vec = reshape(x_gain, [RFC_num, passive_num]);
    
            Q = zeros(RFC_num*passive_num, RFC_num);
            for i = 1:RFC_num
                for l = 1:passive_num
                    Q((i - 1)*passive_num + l, i) = Q_DMA(phi_vec(i,l) * 2 * pi);
                end
            end
        
            %% Start Second Stage
            
            w = ones(N_d, 1);
            P_t = (RF_requirement*N_d)/((norm(aH*Q*w))^2);
        
            DMA_Final_Result_Vec(ff) = P_t/HPA_eff % update the power consumption result
            if iter*pp >= N_d
                break
            end
            iter = iter + 1;
            disp(opt_iter)
        end
        opt_iter = opt_iter + 1;
    end
    disp('Optimization is done for one of the frequency values!')
    Q_opt_vec{ff} = Q; % store your final Q (you will later need it for EMF calculation !)


end

disp('Optimization Procedure Finished !')
save('PSO_Results.mat')
