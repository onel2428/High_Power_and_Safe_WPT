function hlos = LOS_channel(posUE, posA, M, frequency)
%%Input
%posUE:        3-element spatial position of the UE
%M:            number of transmit antenna elements
%posA:         Mx3 matrix collecting the 3D positions (in each row) of the M transmit antenna elements
%frequency:    frequency of operation
%%Output
%hlos:         LOS channel vector (M elements)

c = 3e8;              %speed of light
lambda = c/frequency; %wavelength   
b = 20;               %boresight gain of the transmit antenna elements

for i=1:M
    dist = norm(posA(i,:)-posUE);           %distance between i-transmit antenna element and the UE
    varpi = 2*pi*dist/lambda;               %phase shift in number of wavelengths between i-transmit antenna element and the UE
    ang = atan((posUE(3)-posA(i,3))/dist);  %elevation angle of the UE with respect to the i-th transmit antenna element    
    hlos(i) = sqrt(2*(b+1)*cos(ang)^b)*lambda/(4*pi*dist)*exp(-1i*2*pi*varpi);    %hlos computation based on Eq. 4-6 from [REF]
end

%%
%[REF]: Azarbahram, Amirhossein, et al. "Waveform and Beamforming Optimization for Wireless Power Transfer with Dynamic Metasurface Antennas." arXiv preprint arXiv:2307.01081 (2023).  https://arxiv.org/pdf/2307.01081.pdf

end

