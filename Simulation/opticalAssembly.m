function opticalAssembly(ray, j, grid, lens)
%refractionGridBeta returns angle beta[rad] of a refraction grid given angle
%alpha[°], order j[-], wavelength lambda[nm] and number of lines per mm d_mm[-]
%   Detailed explanation goes here

figure(1)
axis equal
set(gca, 'XAxisLocation', 'origin')

grid.Plot
lens.Plot
hold on
plot([0 grid.DistanceFromOrigin-ray.H*tan(grid.Alpha)], [ray.H ray.H], "Color", ray.Colour, "LineWidth", 1)
grid.RayTo(ray.H*10^3, lens.DistanceFromOrigin*10^3, j, ray.Lambda*10^9, ray.Colour)
lens.RayTo(grid.Y2, lens.DistanceFromOrigin+lens.FocalLength, grid.ABeta, ray.Colour)
hold on
plot([lens.DistanceFromOrigin+lens.FocalLength lens.DistanceFromOrigin+lens.FocalLength], [0 -0.0074444], 'k', "LineWidth",3)


end