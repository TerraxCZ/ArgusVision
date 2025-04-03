classdef LightRay
    %LightRay Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Lambda
        H
        Colour
    end

    methods
        function obj = LightRay(lambda_mm, h_mm, colour)
            % Construct an instance of this class
            %   Detailed explanation goes here
            obj.Lambda = lambda_mm*10^-9;
            obj.H = h_mm*10^-3;
            obj.Colour = colour;
        end
    end
end