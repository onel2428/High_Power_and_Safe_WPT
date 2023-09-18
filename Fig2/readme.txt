The following functions/scripts are used to generate the results in Fig.2 of [REF1]


power_density_as_rk_function:    illustrates how to generate the curve for 5 GHz and d'=5 in Fig. 2 of [REF1]. This script can be easily re-configured to generate the other curves by just updating the values of frequency and d'. This script uses the following functions:

- antenna_elements_position, which allows computing the spatial position of the transmit antenna elements 
- LOS_channel, which allows computing the LOS channels between the transmit antenna elements and the UE
- LOS_cov_sphere, which allows computing the average covariance matrix of the LOS channels between the UE and the transmit antenna elements
- power_density, which allows computing the power density at a distance rk from the UE

These computations are based on the equation (38) in [REF2]


[REF1] O. López et al., "High-Power and Safe RF Wireless Charging: Cautious Deployment and Operation", in IEEE Wireless Communications (submitted)
[REF2] O. L. A. López, D. Kumar, R. D. Souza, P. Popovski, A. Tölli and M. Latva-Aho, "Massive MIMO With Radio Stripes for Indoor Wireless Energy Transfer," in IEEE Transactions on Wireless Communications, vol. 21, no. 9, pp. 7088-7104, Sept. 2022, doi: 10.1109/TWC.2022.3154428.