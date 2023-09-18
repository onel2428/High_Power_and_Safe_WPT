# High_Power_and_Safe_WPT
This repository provides the codes to generate the results in Fig. 2 and Fig. 4 of the paper: "High-Power and Safe RF Wireless Charging: Cautious Deployment and Operation"

# Fig.2 Results:
The following functions/scripts are used to generate the results in Fig.2

power_density_as_rk_function:    illustrates how to generate the curve for 5 GHz and d'=5 in Fig. 2 of [REF1]. This script can be easily re-configured to generate the other curves by just updating the values of frequency and d'. This script uses the following functions:

- antenna_elements_position, which allows computing the spatial position of the transmit antenna elements 
- LOS_channel, which allows computing the LOS channels between the transmit antenna elements and the UE
- LOS_cov_sphere, which allows computing the average covariance matrix of the LOS channels between the UE and the transmit antenna elements
- power_density, which allows computing the power density at a distance rk from the UE

These computations are based on the equation (38) in [REF2]

[REF1] O. López et al., "High-Power and Safe RF Wireless Charging: Cautious Deployment and Operation", in IEEE Wireless Communications (submitted)
[REF2] O. L. A. López, D. Kumar, R. D. Souza, P. Popovski, A. Tölli and M. Latva-Aho, "Massive MIMO With Radio Stripes for Indoor Wireless Energy Transfer," in IEEE Transactions on Wireless Communications, vol. 21, no. 9, pp. 7088-7104, Sept. 2022, doi: 10.1109/TWC.2022.3154428.

# Fig.4 Results:
Description of the file directory:
1. data: it contains the .mat files with the results of the power consumption minimization of both IRS- and DMA-based ETs;
2. private: it contains the auxiliary functions which are necessary for the optimization. For the DMA-based ET, the following functions are included
    a. DMA_deploy.m, which contains the DMA_deploy function, which creates a DMA architecture with a user at your desired distance 
        with the specified system parameters. The function returns the necessary parameters associated with DMA
    b. Gain_objective.m, which returns the received RF power by the user as the objective of the optimization.
    c. Gain_objective_rev.m, which groups the waveguides (1 per group or more) and optimizes them separately, while the variables corresponding to the waveguides 
        outside the group are fixed.
    d. H_DMA.m, which calculates the propagation charachteristics of the DMA based on the system parameters. You can change the material type by changing the 
        corresponding design parameters in H_DMA function.
    e. Q_DMA.m, which calculates the Lorentzian constrained weight of a metamaterial element.
3. root directory:
    a. Optimization_script.m, which computes the metamaterial phases (Q_opt_vec cell array) and the power consumption values vs the operating frequency (DMA_Final_Result_Vec).
    b. optimizationIRS.m, which computes the transmission power, passive precoder (both in IRSOptConf cell array), and power consumption values (IRSPowConsumptVec vector) vs
        the operating frequencies and saves the results into a .mat file.
    c. Figure4.m, which plots the power consumption vs the operating frequency for both IRS- and DMA-based ETs.
