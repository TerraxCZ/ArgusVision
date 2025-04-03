function beta = refractionGridBeta(alpha, j, lambda, d_mm)
%refractionGridBeta returns angle beta[rad] of a refraction grid given angle
%alpha[°], order j[-], wavelength lambda[nm] and number of lines per mm d_mm[-]
%   Detailed explanation goes here

lambda_m = lambda*10^-9;    %wavelength in meters
d = (d_mm^-1)*10^-3;    %grid constant in meters
alpha_rad = deg2rad(alpha);

beta = asin(j*lambda_m*d^-1 + sin(alpha_rad));

end