classdef ThinLens < handle
    %ThinLens Summary of this class goes here
    %   Detailed explanation goes here

    properties
        FocalLength {mustBeNonnegative} %ohnisková vzdálenost f' čočky
        Diameter {mustBePositive}    %průměr čočky
        DistanceFromOrigin {mustBeNonnegative}  %vzdálenost čočky od počátku souřadného systému
        PlotHandles %Stores graphical objects, so it can be possible to delete them from figure later on
    end

    methods
        function obj = ThinLens(FocalLength_mm, Diameter_mm, DistanceFromOrigin_mm)
            %ThinLens Construct an instance of this class
            %   Detailed explanation goes here
            obj.FocalLength = FocalLength_mm*10^-3;
            obj.Diameter = Diameter_mm*10^-3;
            obj.DistanceFromOrigin = DistanceFromOrigin_mm*10^-3;
            obj.PlotHandles = [];
        end

        function Plot(obj)
            %PlotLens Summary of this method goes here
            %   Detailed explanation goes here
            
            hold on
            axis equal

            lensLine = plot([obj.DistanceFromOrigin obj.DistanceFromOrigin], [-obj.Diameter/2 obj.Diameter/2], 'k-', 'LineWidth', 2);
            
            positionOfFP1 = obj.DistanceFromOrigin - obj.FocalLength;
            positionOfFP2 = obj.DistanceFromOrigin + obj.FocalLength;
            focalPoint1 = plot(positionOfFP1, 0, 'kx', 'MarkerSize', 8, 'DisplayName', "F'");
            focalPoint2 = plot(positionOfFP2, 0, 'kx', 'MarkerSize', 8, 'DisplayName', "F");

            obj.PlotHandles = [obj.PlotHandles, lensLine, focalPoint1, focalPoint2];

            hold off
        end

        function Delete(obj)
            %DeleteLens Summary of this method goes here
            %   Detailed explanation goes here

            delete(obj.PlotHandles);
            obj.PlotHandles = [];
        end

        function delta_s = RayAngle(obj, delta, y)
            %DeleteLens Summary of this method goes here
            %   Detailed explanation goes here

            delta_s = atan(tan(delta)-(h/obj.FocalLength));
        end

        function RayTo(obj, h, to, delta, colour)
            x1 = obj.DistanceFromOrigin;
            x2 = to;
            y1 = h;

            %alpha = atan(tan(delta)-(h/obj.FocalLength))
            %y2 = h + obj.FocalLength*tan(alpha)


            y2 = obj.FocalLength*tan(delta); %Platí jen pro to = DistanceFromOrigin + FocalLength


            hold on

            plot([x1 x2],[y1 y2],'Color', colour)
            hold  off
        end
    end
end