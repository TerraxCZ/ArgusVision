classdef RefractionGrid < handle
    %RefractionGrid Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Alpha   %Uhel natoceni mrizky [rad] (CCW = +) 
        D   %vzdalenost mezi jednotlivimi drazkami na mrizce [m]
        Diameter    %"prumer" difrakční mrizky [m] (jakoby vyska)
        DistanceFromOrigin  %vzdalenost od pocatku souradnicoveho systemu [m]
        PlotHandles %Stores graphical objects, so it can be possible to delete them from figure later on

        Y2
        ABeta
    end

    methods
        function obj = RefractionGrid(alpha_d, linesPermm, diameter_mm, distanceFromOrigin_mm)
            %RefractionGrid Construct an instance of this class
            %   Detailed explanation goes here
            obj.Alpha = deg2rad(alpha_d);
            obj.D = (linesPermm^-1)*10^-3;
            obj.Diameter = diameter_mm*10^-3;
            obj.DistanceFromOrigin = distanceFromOrigin_mm*10^-3;
            obj.PlotHandles = [];
            obj.Y2 = NaN;
            obj.ABeta = NaN;
        end

        function Plot(obj)
            %Plot Summary of this method goes here
            %   Detailed explanation goes here
            
            hold on
            axis equal
            
            dx = obj.Diameter/2*sin(obj.Alpha);
            gridLine = plot([obj.DistanceFromOrigin+dx obj.DistanceFromOrigin-dx], [-obj.Diameter/2*cos(obj.Alpha) obj.Diameter/2*cos(obj.Alpha)], 'k-', 'LineWidth', 2);
            
            hold off

            obj.PlotHandles = [obj.PlotHandles, gridLine];
        end

        function Delete(obj)
            %Delete Summary of this method goes here
            %   Detailed explanation goes here

            delete(obj.PlotHandles);
            obj.PlotHandles = [];
        end

        function ABeta = RayAngle(obj, j, lambda)
            %Beta Summary of this method goes here
            %   Detailed explanation goes here

            beta = asin(((j*lambda)/obj.D) - sin(obj.Alpha));
            ABeta = beta + obj.Alpha;
            obj.ABeta = ABeta;
        end

        function RayTo(obj, h_mm, to_mm, j, lambda_nm, colour)
            %Beta Summary of this method goes here
            %   Detailed explanation goes here
            h = h_mm*10^-3;
            to = to_mm*10^-3;
            lambda = lambda_nm*10^-9;

            obj.RayAngle(j,lambda)

            x1 = obj.DistanceFromOrigin - h*tan(obj.Alpha);
            x2 = to;
            y1 = h;
            y2 = h - (x2-x1)*tan(-obj.ABeta);

            obj.Y2 = y2

            hold on

            plot([x1 x2], [y1 y2], 'Color', colour)
            
            hold off
        end
    end
end