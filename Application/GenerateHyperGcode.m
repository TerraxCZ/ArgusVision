function GenerateHyperGcode(scanHeight, spectralBinning)
    % GENERATEGCODEFORENDER Generuje GCODE pro Ender3 Pro s posuvem kamery (směrem dolů)
    % Funkce vytvoří GCODE soubor, který začne na počáteční výšce (93 mm + bezpečnost
    % + výška skenování) a následně provede skenování směrem dolů.
    %
    % Syntaxe:
    %   GenerateGcodeForEnder(scanHeight, spectralBinning)
    %
    % Vstupy:
    %   scanHeight     - Výška skenování v milimetrech [double]
    %   spectralBinning - Spektrální binning (násobek zvětšení pro výpočet posunu Z [integer])

    %% Kontrola vstupů
    arguments
        scanHeight (1,1) double {mustBePositive}       % Výška skenování
        spectralBinning (1,1) double {mustBePositive, mustBeInteger} % Binning
    end

    %% Parametry tiskárny a kamery
    MIN_HEIGHT = 93;     % Minimální výška od podložky (v mm)
    CAMERA_RESERVE = 10; % Rezerva pro bezpečnost (v mm)
    F_STOP_WIDTH = 8.3414e-3; % Velikost štěrbiny při binning=1 (v mm)
    F_STOP_SET_STEP = 0.005;  % polovina kroku nastavení štěrbiny (v mm)  
    MAGNIFICATION = 0.3346;   % Zvětšení objektivu kamery
    MOVE_SPEED = 120;         % Rychlost pohybu v mm/min (doporučeno pro osu Z)
    

    % Počáteční výška pro skenování = MIN_HEIGHT + rezerva + výška skenování
    startHeight = MIN_HEIGHT + CAMERA_RESERVE + scanHeight;

    % Minimální výška po dokončení skenu
    finalHeight = MIN_HEIGHT + CAMERA_RESERVE;

    % Kontrola, aby se kamera nepohybovala mimo povolený rozsah
    if startHeight > 250
        error('Výška [%d mm] překračuje maximální hodnotu tiskárny (250 mm).', startHeight);
    end
    
    % Výpočet velikosti štěrbiny
    slitSize_mm = F_STOP_WIDTH * spectralBinning;

    % Zaokrouhlí velikost štěrbiny na nastavení na kotouči 
    slitsize_STEPS = (round(slitSize_mm/F_STOP_SET_STEP)*F_STOP_SET_STEP)*10^2;

    % Výpočet posunu kamery na 1 "pixel"
    pixelShift_mm = (slitSize_mm) / MAGNIFICATION;

    % Počet kroků kamery během skenování
    numSteps = ceil((startHeight - finalHeight) / pixelShift_mm);

    %% Metadata - výpočet a CMD výpis
    fprintf('--- GCODE generátor pro Ender 3 Pro ---\n');
    fprintf('Výška skenování (mm): %.2f\n', scanHeight);
    fprintf('Počáteční výška (start Z): %.2f mm\n', startHeight);
    fprintf('Konečná výška (end Z): %.2f mm\n', finalHeight);
    fprintf('Posun na pixel (uloha Z) [mm]: %.5f\n', pixelShift_mm);
    fprintf('Počet snímků: %d\n', numSteps);
    fprintf('Nastavte štěrbinu na: %.1f\n\n', slitsize_STEPS);

    %% Generování GCODE
    gcode = { ...
        'G21 ; Nastavení jednotek na mm', ...
        'G90 ; Absolutní režim polohování', ...
        sprintf('G1 Z%.2f F%d ; Vyjíždění kamery na počáteční výšku Z', startHeight, MOVE_SPEED), ...
        'M17 ; Zamknutí motorů pro udržení polohy osy Z', ...
        'M0 Stiskněte tlačítko pro zahájení skenování' ...
    };

    % Generování jednotlivých kroků směrem dolů
    for step = 0:numSteps-1
        currentHeight = startHeight - step * pixelShift_mm; % Výška Z pro tento krok
        gcode{end+1} = sprintf('G1 Z%.2f F%d ; Krok %d dolů', currentHeight, MOVE_SPEED, step + 1);
        gcode{end+1} = 'M17 ; Zamknutí motorů'; % Zamknutí motorů na každé pozici
        gcode{end+1} = sprintf('M117 Snímek: %d/%d', step + 1, numSteps); % Krátká zpráva na LCD
        gcode{end+1} = 'M0 ; Čeká na uživatelský vstup'; % Zastavení po každém kroku
    end

    % Přidání GCODE pro bezpečné ukončení
    gcode{end+1} = sprintf('G1 Z%.2f F%d ; Konečná výška Z (rezerva)', finalHeight, MOVE_SPEED);
    gcode{end+1} = 'M84 ; Vypnutí motorů';

    %% Zápis GCODE do souboru
    fileName = sprintf('Scan_GCODE_From%.2f_To%.2f_Binning%d.gcode', startHeight, finalHeight, spectralBinning);
    fileID = fopen(fileName, 'w');

    if fileID == -1
        error('Chyba při vytváření souboru GCODE!');
    end

    fprintf(fileID, '%s\n', gcode{:});
    fclose(fileID);

    %% Potvrzení výsledku
    fprintf('GCODE soubor byl úspěšně vygenerován: %s\n', fileName);
end