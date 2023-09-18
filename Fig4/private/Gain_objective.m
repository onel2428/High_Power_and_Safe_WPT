function y = Gain_objective(x, aH, N_d, N_e)

phi_vec = reshape(x, [N_d, N_e]);
Q = zeros(N_d*N_e, N_d);
w = ones(N_d, 1);

for i = 1:N_d
    for l = 1:N_e
        Q((i - 1)*N_e + l, i) = Q_DMA(phi_vec(i,l) * 2 * pi);
    end
end

% obtain the received RF power by the user (return the negative value since
% PSO minimizes the objective) 1/N_d represents the ratio of power going
% into each waveguide

y = -((1/N_d).*((norm(aH*Q*w))^2))./(norm(aH)^2 *N_d);

end