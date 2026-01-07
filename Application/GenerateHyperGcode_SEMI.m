function GenerateHyperGcode_SEMI(scanHeight, spectralBinning, acquisitionTime_us)
    % GCODE pro Ender3 Pro s manuálním pořízením snímků (pípání pro obsluhu).
    %
    % Sekvence:
    % - Start: 3× pípnutí (s mezerami), pak 2× rychle => „pořiď foto" (startovní snímek)
    % - Čeká se acquisitionTime + 0.5 s + čas na uložení
    % - Posun o krok dolů
    % - 1× pípnutí => „pořiď foto", pak opět čekání, pak posun...
    % - Na konci 2× pípnutí
    %
    % Vstupy:
    %   scanHeight        [mm]
    %   spectralBinning   [integer]
    %   acquisitionTime_us [µs]

    arguments
        scanHeight (1,1) double {mustBePositive}
        spectralBinning (1,1) double {mustBePositive, mustBeInteger}
        acquisitionTime_us (1,1) double {mustBePositive}
    end

    % Parametry
    MIN_HEIGHT = 93;     
    CAMERA_RESERVE = 10; 
    F_STOP_WIDTH = 8.3414e-3; 
    F_STOP_SET_STEP = 0.005;  
    MAGNIFICATION = 0.3346;   
    MOVE_SPEED = 120;         

    % Časy a zvuky
    BEEP_FREQ_PREP   = 1000;
    BEEP_FREQ_TAKE   = 1500;
    BEEP_DUR_PREP_MS = 150;
    BEEP_DUR_TAKE_MS = 200;
    BEEP_PAUSE_MS    = 1000;   
    DOUBLE_GAP_MS    = 120;   
    ACQ_MARGIN_MS    = 500;   
    SAVE_BUFFER_MS   = 2000;  

    acq_ms  = acquisitionTime_us / 1000;
    wait_ms = round(acq_ms + ACQ_MARGIN_MS + SAVE_BUFFER_MS);

    startHeight = MIN_HEIGHT + CAMERA_RESERVE + scanHeight;
    finalHeight = MIN_HEIGHT + CAMERA_RESERVE;
    if startHeight > 250
        error('Výška [%d mm] překračuje maximální hodnotu tiskárny (250 mm).', startHeight);
    end

    slitSize_mm   = F_STOP_WIDTH * spectralBinning;
    slitsize_STEPS = (round(slitSize_mm / F_STOP_SET_STEP) * F_STOP_SET_STEP) * 1e2;
    pixelShift_mm = slitSize_mm / MAGNIFICATION;
    numSteps = ceil((startHeight - finalHeight) / pixelShift_mm);

    fprintf('--- GCODE generátor pro Ender 3 Pro ---\n');
    fprintf('Výška skenování (mm): %.2f\n', scanHeight);
    fprintf('Počáteční výška (start Z): %.2f mm\n', startHeight);
    fprintf('Konečná výška (end Z): %.2f mm\n', finalHeight);
    fprintf('Posun na pixel (osa Z) [mm]: %.5f\n', pixelShift_mm);
    fprintf('Počet snímků: %d\n', numSteps);
    fprintf('Nastavte štěrbinu na: %.1f\n', slitsize_STEPS);
    fprintf('Acquisition time: %.1f ms, čekání na snímek: %.1f ms (včetně rezerv)\n\n', acq_ms, wait_ms);

    % Helpery pro pípnutí – řádkové buňky
    singleBeep = sprintf('M300 S%d P%d', BEEP_FREQ_PREP, BEEP_DUR_PREP_MS);
    takeBeep   = sprintf('M300 S%d P%d', BEEP_FREQ_TAKE, BEEP_DUR_TAKE_MS);
    prepSeq = { ...
        singleBeep, ...
        sprintf('G4 P%d', BEEP_PAUSE_MS), ...
        singleBeep, ...
        sprintf('G4 P%d', BEEP_PAUSE_MS), ...
        singleBeep, ...
        sprintf('G4 P%d', BEEP_PAUSE_MS), ...
        takeBeep, ...
        sprintf('G4 P%d', DOUBLE_GAP_MS), ...
        takeBeep ...
    };
    singleCue = { takeBeep };

    % Základ GCODE (řádkové pole)
    gcode = { ...
        'G21 ; Nastavení jednotek na mm', ...
        'G90 ; Absolutní režim polohování', ...
        sprintf('G1 Z%.2f F%d ; Vyjíždění kamery na počáteční výšku Z', startHeight, MOVE_SPEED), ...
        'M17 ; Zamknutí motorů pro udržení polohy osy Z', ...
        'M0 Press to START' ...
    };

    % Startovní sekvence pípnutí + čekání na snímek v první pozici
    gcode{end+1} = 'M117 Startovni snimek';
    gcode = [gcode, prepSeq{:}];  % vodorovná konkatenace
    gcode{end+1} = sprintf('G4 P%d ; Expozice + rezerva + ulozeni', wait_ms);

    % Smyčka přes pozice (po prvním snímku). Pozice i = 2..numSteps
    for i = 2:numSteps
        currentHeight = startHeight - (i-1) * pixelShift_mm;
        gcode{end+1} = sprintf('G1 Z%.2f F%d ; Krok %d dolů', currentHeight, MOVE_SPEED, i);
        gcode{end+1} = 'M400 ; počkej na dokončení pohybu';
        gcode{end+1} = sprintf('M117 Snímek: %d/%d', i, numSteps);
        gcode = [gcode, singleCue{:}];  % vodorovná konkatenace
        gcode{end+1} = sprintf('G4 P%d ; Expozice + rezerva + ulozeni', wait_ms);
    end

    % Ukončení: 2x pípnutí
    gcode{end+1} = 'M300 S1500 P250';
    gcode{end+1} = sprintf('G4 P%d', DOUBLE_GAP_MS);
    gcode{end+1} = 'M300 S1500 P250';
    gcode{end+1} = sprintf('G1 Z%.2f F%d ; Konečná výška Z (rezerva)', finalHeight, MOVE_SPEED);
    gcode{end+1} = 'M84 ; Vypnutí motorů';

    % Zápis GCODE do souboru
    outDir = fullfile("GCODEs");
    if ~exist(outDir, "dir")
        mkdir(outDir);
    end
    fileName = sprintf('SEMI_Hyper_Scan_%d_To%d_Bng%d_Acq%dms.gcode', startHeight, finalHeight, spectralBinning, acq_ms);
    filePath = fullfile(outDir, fileName);

    fileID = fopen(filePath, 'w');
    if fileID == -1
        error('Chyba při vytváření souboru GCODE (%s)!', filePath);
    end
    fprintf(fileID, '%s\n', gcode{:});
    fclose(fileID);

    fprintf('GCODE soubor byl úspěšně vygenerován: %s\n', filePath);
end