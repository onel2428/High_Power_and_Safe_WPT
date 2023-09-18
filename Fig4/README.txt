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