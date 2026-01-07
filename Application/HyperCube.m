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
        binning (1,1)
    end

    properties (Constant, Access = private)
        LAMBDA_MIN = 400;   
        LAMBDA_MAX = 701;   
        FIRST_PIXEL = 2665;
        LAST_PIXEL = 4024;

        % Kalibrace pix = A * λ + B
        A = 4.51;          % px / nm
        B = 861;           % px offset

    end

    methods
        %% Konstruktor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = HyperCube(folder, binning)
            % Konstruktor načte hyperspektrální kostku s Bitmap ve
            % specifikované složce
       
            arguments
                folder (1,1) string
                binning (1,1) double {mustBePositive, mustBeInteger} = 10
            end

            BIN_X = binning;
            BIN_L = binning;

            files = dir(fullfile(folder, '*.bmp')); % načte soubory typu .bmp z poskytnuté složky

            if isempty(files)
                error('Nenalezeny BMP v %s', folder); 
            end

            names = sort({files.name}); % seřadí názvy dle abecedy (měly by mít ascending čísla)

            % Načte první soubor pro zjištění rozměrů
            img0_orig = imread(fullfile(folder, names{1}));

            % --- spektrální ořez: zarovnání doprava, přebytek se zahodí zleva ---
            raw_width    = obj.LAST_PIXEL - obj.FIRST_PIXEL + 1;
            crop_left    = mod(raw_width, BIN_L);           % kolik sloupců zahodit vlevo
            usable_start = obj.FIRST_PIXEL + crop_left;     % nový začátek
            usable_end   = obj.LAST_PIXEL;                  % pravý okraj držíme
            lambda_use   = usable_end - usable_start + 1;   % počet sloupců po ořezu

            if mod(lambda_use, BIN_L) ~= 0
                error('Šířka po ořezu (%d) není dělitelná %d.', lambda_use, BIN_L);
            end

            % --- osa lambda z kalibrace pix = A*λ + B, průměr v každém binu ---
            pix_keep       = usable_start:usable_end;           % pixely, které bereme
            lambda_per_px  = (pix_keep - obj.B) / obj.A;        % λ pro každý sloupec
            n_lambda       = lambda_use / BIN_L;
            lambda_axis    = mean(reshape(lambda_per_px, BIN_L, n_lambda), 1);

            % --- ořez a binning v ose x ---
            x_raw = size(img0_orig, 1);
            x_use = floor(x_raw / BIN_X) * BIN_X;
            if x_use < BIN_X
                error('Příliš malá výška pro binning %d (x_raw=%d).', BIN_X, x_raw);
            end
            x_dim = x_use / BIN_X;

            y_dim = numel(names);
            cube = zeros(y_dim, x_dim, n_lambda, 'single');

            for yi = 1:y_dim
                img = imread(fullfile(folder, names{yi}));
                img = img(:, usable_start:usable_end); % spektrální ořez zprava zarovnaný
                img = img(1:x_use, :);                  % ořez na celé bloky v x

                % binning ve spektru (sloupce)
                imgL = mean(reshape(img, x_use, BIN_L, n_lambda), 2); % [x_use x 1 x n_lambda]
                imgL = squeeze(imgL);                                 % [x_use x n_lambda]

                % binning v x (řádky)
                imgX = mean(reshape(imgL, BIN_X, x_dim, n_lambda), 1); % [1 x x_dim x n_lambda]
                imgX = squeeze(imgX);                                  % [x_dim x n_lambda]

                cube(yi, :, :) = single(imgX); % uložíme [y, x, λ]
            end

            % nastavení properties
            obj.cube        = cube;
            obj.lambda_axis = lambda_axis;
            obj.x_dim       = x_dim;
            obj.y_dim       = y_dim;
            obj.n_lambda    = n_lambda;
            obj.binning     = binning;
        end

        %% Spektrum v bodě - Vykreslit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function ShowSpectrum(obj, x, y)
            % Vykreslí spektrum ve specifikovaném spexelu [x,y]


            arguments
                obj
                x (1,1) double {mustBePositive, mustBeInteger}
                y (1,1) double {mustBePositive, mustBeInteger}
            end

             % Ověřit, že x,y jsou v rozsahu kostky
            if x > obj.x_dim || y > obj.y_dim
                error('Index out of range: x in [1..%d], y in [1..%d]', obj.x_dim, obj.y_dim);
            end
            
            spec.x = obj.lambda_axis;               % Hodnoty vlnových délek λ [nm] (osa x)
            spec.y = squeeze(obj.cube(y,x,:))';     % Hodnoty intenzit I [0-255] (osa y) 

            figure("Name",'Spectrum')
            plot(spec.x, spec.y);
            grid on
            xlabel('λ [nm]');
            ylabel('Intensity [-]');
            title(sprintf('Spectrum at [%d, %d]', x, y));
        end

        %% Spektrum v bodě - Pouze vrátit (pro GUI) %%%%%%%%%%%%%%%%%%%%%%%
        function spec = GetSpectrum(obj, x, y)
            % Vrátí spektrum ve specifikovaném spexelu [x,y]
            % Vrátí spektrum v struct {x,y} (Bez vykreslení)

            arguments
                obj
                x (1,1) double {mustBePositive, mustBeInteger}
                y (1,1) double {mustBePositive, mustBeInteger}
            end

             % Ověřit, že x,y jsou v rozsahu kostky
            if x > obj.x_dim || y > obj.y_dim
                error('Index out of range: x in [1..%d], y in [1..%d]', obj.x_dim, obj.y_dim);
            end
            
            spec.x = obj.lambda_axis;               % Hodnoty vlnových délek λ [nm] (osa x)
            spec.y = squeeze(obj.cube(y,x,:))';     % Hodnoty intenzit I [0-255] (osa y)
        end

        %% Monochromatický slice Hyperkostkou ve zvoleném Lambda - Vykreslit
        function ShowSlice(obj, Lambda_nm)
            % Zobrazí monochromatický řez zkrz HyperKostku v Lambda_nm
            % Zároveň vrátí monochromatický řez jako výstup
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
            slice = uint8(slice);   % Přeformátuje čísla do UINT8, aby se to zobrazilo jako B&W
            
            % Zobrazení výsledku
            figure("Name", "Monochromatic Slice");
            imshow(slice)
            title(sprintf('Řez v \\lambda=%.2f nm (sloupec %d)', obj.lambda_axis(li), li));
        end


        %% Monochromatický slice Hyperkostkou ve zvoleném Lambda - Pouze vrátit (Pro GUI)
        function slice = GetSlice(obj, Lambda_nm)
            % Zobrazí monochromatický řez zkrz HyperKostku v Lambda_nm
            % Zároveň vrátí monochromatický řez jako výstup
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
            slice = uint8(slice);   % Přeformátuje čísla do UINT8, aby se to zobrazilo jako B&W

        end


        %% RGB náhled hyperspektrálního snímku - Vykreslit %%%%%%%%%%%%%%%%
        function ShowAsRGB(obj)
            % ShowAsRGB Vytvoří RGB náhled hyperspektrálního snímku
            % Tato metoda kombinuje tři monochromatické řezy (červený, zelený a modrý)
            % při výchozích hodnotách vlnových délek.
            %
            % Výstupy:
            %   rgbImage - 3D matice [x, y, 3] představující obrázek ve formátu RGB
        
            arguments
                obj
            end

            lambdaR = 650;  % Vlnová délka pro červenou složku
            lambdaG = 550;  % Vlnová délka pro zelenou složku
            lambdaB = 450;  % Vlnová délka pro modrou složku
        
        
            % Extrakce jednotlivých monochromatických vrstev
            redSlice = obj.GetSlice(lambdaR);
            greenSlice = obj.GetSlice(lambdaG);
            blueSlice = obj.GetSlice(lambdaB);
        
            % Normalizace intenzity do rozsahu [0, 1]
            redNorm = mat2gray(redSlice);   % Červená barva
            greenNorm = mat2gray(greenSlice); % Zelená barva
            blueNorm = mat2gray(blueSlice);  % Modrá barva
        
            % Kombinace do RGB obrázku
            rgbImage = cat(3, redNorm, greenNorm, blueNorm);
        
            % Zobrazení výsledku
            figure("Name", "RGB Preview");
            imshow(rgbImage);
            title(sprintf('RGB Náhled (R=%.1f nm, G=%.1f nm, B=%.1f nm)', lambdaR, lambdaG, lambdaB));
        end


        %% RGB náhled hyperspektrálního snímku - Vrátit (Pro GUI) %%%%%%%%%
        function rgbImage = GetAsRGB(obj)
            % ShowAsRGB Vytvoří RGB náhled hyperspektrálního snímku
            % Tato metoda kombinuje tři monochromatické řezy (červený, zelený a modrý)
            % při výchozích hodnotách vlnových délek.
            %
            % Výstupy:
            %   rgbImage - 3D matice [x, y, 3] představující obrázek ve formátu RGB
        
            arguments
                obj
            end

            lambdaR = 650;  % Vlnová délka pro červenou složku
            lambdaG = 550;  % Vlnová délka pro zelenou složku
            lambdaB = 450;  % Vlnová délka pro modrou složku
        
        
            % Extrakce jednotlivých monochromatických vrstev
            redSlice = obj.GetSlice(lambdaR);
            greenSlice = obj.GetSlice(lambdaG);
            blueSlice = obj.GetSlice(lambdaB);
        
            % Normalizace intenzity do rozsahu [0, 1]
            redNorm = mat2gray(redSlice);   % Červená barva
            greenNorm = mat2gray(greenSlice); % Zelená barva
            blueNorm = mat2gray(blueSlice);  % Modrá barva
        
            % Kombinace do RGB obrázku
            rgbImage = cat(3, redNorm, greenNorm, blueNorm);
        
        end
        

    end
end