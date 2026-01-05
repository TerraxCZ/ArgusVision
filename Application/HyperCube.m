% HYPERCUBE Třída pro práci s hyperspektrálními daty
% Tato třída umožňuje načítat hyperspektrální data ve formátu .BMP ze zvolené složky
% a provádět základní spektrální analýzu.
%
% Vlastnosti:
%   cube        - 3D matice [y, x, λ] hyperspektrálních dat
%   lambda_axis - Vektory vlnových délek [λ]
%   ...
%
% Metody:
%   spectrum    - Zobrazí spektrální křivku pro daný bod (x, y)
%   slice       - Vytváří monochromatický slice pro konkrétní vlnovou délku (λ)

classdef HyperCube
    properties (SetAccess = private)
        cube (:,:,:) single         % [y, x, λ] numeric
        lambda_axis (1,:) double    % [1 x nλ]

        x_dim (1,1) double {mustBePositive, mustBeInteger} = 1      %
        y_dim (1,1) double {mustBePositive, mustBeInteger} = 1      % 1 jsou placeholdery
        n_lambda (1,1) double {mustBePositive, mustBeInteger} = 1   %
    end

    properties (Constant, Access = private)
        LAMBDA_MIN = 400;   %                           % OG = 400
        LAMBDA_MAX = 650;   % Defaultní fixní hodnoty   % OG = 850
        FIRST_PIXEL = 1;    %
    end

    methods
        %% Konstruktor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = HyperCube(folder)
            % Konstruktor načte hyperspektrální kostku s Bitmap ve
            % specifikované složce
       
            arguments
                folder (1,1) string
            end

            LAMBDA_MIN = obj.LAMBDA_MIN;
            LAMBDA_MAX = obj.LAMBDA_MAX;
            FIRST_PIXEL = obj.FIRST_PIXEL;

            files = dir(fullfile(folder, '*.bmp')); % načte soubory typu .bmp z poskytnuté složky

            if isempty(files)
                error('Nenalezeny BMP v %s', folder); 
            end

            names = sort({files.name}); % seřadí názvy dle abecedy (měly by mít ascending čísla)

            % Načte první soubor pro zjištění rozměrů
            img0 = imread(fullfile(folder, names{1}));
            
            x_dim     = size(img0, 1);      % výška = x
            Lambda_dim = size(img0, 2);     % šířka = λ
            y_dim = numel(names);           % šířka = y (počet snímků)


            % Lineární osa λ (zleva doprava)
            lambda_axis = LAMBDA_MIN + ((1:Lambda_dim) - FIRST_PIXEL) * (LAMBDA_MAX - LAMBDA_MIN) / (Lambda_dim - 1);
            
            cube = zeros( y_dim, x_dim, Lambda_dim, 'single');
            
            for yi = 1:y_dim
                img = imread(fullfile(folder, names{yi}));
                cube(yi, :, :) = single(img); % ulož [y, x, λ]
            end

            % Přiřazení lokálních proměnných do Propreties
            obj.x_dim = x_dim; 
            obj.y_dim = y_dim; 
            obj.n_lambda = Lambda_dim; 
            obj.cube = cube; 
            obj.lambda_axis = lambda_axis;
           

        end

        %% Spektrum v bodě %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function spec = spectrum(obj, x, y)
            % Vrátí spektrum ve specifikovaném spexelu [x,y]

            arguments
                obj
                x (1,1) double {mustBePositive, mustBeInteger}
                y (1,1) double {mustBePositive, mustBeInteger}
            end

            disp(obj.cube)

             % Ověřit, že x,y jsou v rozsahu kostky
            if x > obj.x_dim || y > obj.y_dim
                error('Index out of range: x in [1..%d], y in [1..%d]', obj.x_dim, obj.y_dim);
            end
            
            spec = squeeze(obj.cube(y,x,:));

            figure("Name",'Spectrum')
            plot(obj.lambda_axis, spec);
            xlabel('λ [nm]');
            ylabel('Intensity [-]');
            title(sprintf('Spectrum at [%d, %d]', x, y));
        end

        %% Monochromatický slice Hyperkostkou ve zvoleném Lambda
        function slice = slice(obj, Lambda_nm)
            % Creates a monochromatic slice through the HyperCube
            % YOLO
            arguments
                obj
                Lambda_nm (1,1) double {mustBePositive}
            end
            
            Lambda = Lambda_nm;

            if Lambda < obj.LAMBDA_MIN || Lambda > obj.LAMBDA_MAX
                error('Lambda must be in range (%d - %d) [nm]',obj.LAMBDA_MIN, obj.LAMBDA_MAX)
            end
            
            [~, li] = min(abs(obj.lambda_axis - Lambda)); %Najde index nejbližší λ k zadané target_lambda
            slice = obj.cube(:, :, li);   % Obrázek v této vrstvě

            imshow(slice)
            title(sprintf('Řez v \\lambda=%.2f nm (sloupec %d)', obj.lambda_axis(li), li));
        end
        

    end
end