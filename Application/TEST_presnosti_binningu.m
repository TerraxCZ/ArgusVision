clearvars ; close all ; clc;

folder = "D:\OneDrive - České vysoké učení technické v Praze\Škola\Magisterské Studium\Diplomová Práce\IMAGES\PohledSkrzSterbinuNaUzkou_ZaostreniNaOsvetlenyToaletak_1RAD.bmp";
img0_orig = imread(fullfile(folder));

imshow(img0_orig)

binning = 8; % Změnou binningu zde lze pozorovat, zda odpovídají spektrální špičky Hg výbojky (odpovídají)

BIN_X = binning;
BIN_L = binning;

LAMBDA_MIN = 400;   
LAMBDA_MAX = 701;   
FIRST_PIXEL = 2665;
LAST_PIXEL = 4024;

% Kalibrace pix = A * λ + B
A = 4.51;          % px / nm
B = 861;           % px offset

% --- spektrální ořez: zarovnání doprava, přebytek se zahodí zleva ---
raw_width    = LAST_PIXEL - FIRST_PIXEL + 1;
crop_left    = mod(raw_width, BIN_L);           % kolik sloupců zahodit vlevo
usable_start = FIRST_PIXEL + crop_left;     % nový začátek
usable_end   = LAST_PIXEL;                  % pravý okraj držíme
lambda_use   = usable_end - usable_start + 1;   % počet sloupců po ořezu

if mod(lambda_use, BIN_L) ~= 0
    error('Šířka po ořezu (%d) není dělitelná %d.', lambda_use, BIN_L);
end

% --- osa lambda z kalibrace pix = A*λ + B, průměr v každém binu ---
pix_keep       = usable_start:usable_end;           % pixely, které bereme
lambda_per_px  = (pix_keep - B) / A;        % λ pro každý sloupec
n_lambda       = lambda_use / BIN_L;
lambda_axis    = mean(reshape(lambda_per_px, BIN_L, n_lambda), 1);

% --- ořez a binning v ose x ---
x_raw = size(img0_orig, 1);
x_use = floor(x_raw / BIN_X) * BIN_X;
if x_use < BIN_X
    error('Příliš malá výška pro binning %d (x_raw=%d).', BIN_X, x_raw);
end
x_dim = x_use / BIN_X;

img = img0_orig;
img = img(:, usable_start:usable_end); % spektrální ořez zprava zarovnaný
img = img(1:x_use, :);                  % ořez na celé bloky v x

% binning ve spektru (sloupce)
imgL = mean(reshape(img, x_use, BIN_L, n_lambda), 2); % [x_use x 1 x n_lambda]
imgL = squeeze(imgL);                                 % [x_use x n_lambda]

% binning v x (řádky)
imgX = mean(reshape(imgL, BIN_X, x_dim, n_lambda), 1); % [1 x x_dim x n_lambda]
imgX = squeeze(imgX);                                  % [x_dim x n_lambda]

% Nalezení indexů jednotlivých špiček Rtuťové výbojky v přepočítané ose
% lambda
[~, l405] = min(abs(lambda_axis - 405));
[~, l436] = min(abs(lambda_axis - 436));
[~, l546] = min(abs(lambda_axis - 546));
[~, l579] = min(abs(lambda_axis - 579));

imshow(uint8(imgX))
hold on
% Plot vertical lines at the positions of the peaks
xline(l405, 'r--', '405 nm', 'LabelHorizontalAlignment', 'left');
xline(l436, 'g--', '436 nm', 'LabelHorizontalAlignment', 'left');
xline(l546, 'b--', '546 nm', 'LabelHorizontalAlignment', 'left');
xline(l579, 'm--', '579 nm', 'LabelHorizontalAlignment', 'left');