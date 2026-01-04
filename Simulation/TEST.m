

h = 0;  %[mm]

%       LightRay(lambda[nm], h[mm], colour)
ray_laser = LightRay(632.8,h,"red");
ray0v = LightRay(589, h, '#9134db');
ray0g = LightRay(520, h, '#16b338');
ray0r = LightRay(700, h, '#f60909');
ray0ir = LightRay(589.6, h, '#4d0e10');

rayHg1 = LightRay(365,0,[0.3804 0 0.3804]);
rayHg2 = LightRay(405,0,[0.5098 0 0.7843]);
rayHg3= LightRay(436,0,[0.1137 0 1]);
rayHg4 = LightRay(546,0,[0.5882 1 0]);
rayHg5 = LightRay(579,0,[0.9882 1 0]);
rayHg5 = LightRay(850,0,[1 0 0]);

rayNa1 = LightRay(589.529,0,[1 0.8863 0]);
rayNa2 = LightRay(588.995,0,[1 0.8863 0]);

%       RefractionGrid(alpha [°], lines/mm, prumer[mm], DistanceFromOrigin [mm])
grid0 = RefractionGrid(0,271.028,30,20);

%grid20 = RefractionGrid(0,898.599,30,50);

%grid15 = RefractionGrid(5,271.028,30,50);
%grid220 = RefractionGrid(20,898.599,30,50);
%grid0 = RefractionGrid(30, 300, 20, 30);

%       ThinLens(f [mm], d[mm], DistanceFromOrigin[mm])
lens1 = ThinLens(30,16,45);
%lens1 = ThinLens(31.0485,16,30)

j = -1;

%   opticalAssembly(ray [obj], j [-], grid [obj], lens [obj])


opticalAssembly(rayHg1,j,grid0,lens1);
opticalAssembly(rayHg2,j,grid0,lens1);
opticalAssembly(rayHg3,j,grid0,lens1);
opticalAssembly(rayHg4,j,grid0,lens1);
opticalAssembly(rayHg5,j,grid0,lens1);

%{
opticalAssembly(rayNa1,-2,grid0,lens1);
opticalAssembly(rayNa2,-2,grid0,lens1);
%}

%opticalAssembly(ray0v, j, grid0, lens1)
%opticalAssembly(ray0ir, j, grid0, lens1)
%opticalAssembly(ray_laser, j, grid0, lens1)
% opticalAssembly(ray0r, j, grid0, lens1)
% opticalAssembly(ray0ir, j, grid0, lens1)