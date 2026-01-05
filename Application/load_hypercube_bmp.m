function [cube, lambda_axis] = load_hypercube_bmp(dataDir)
% Načte BMP stack do kostky cube[x, y, λ] (šířka=λ, výška=x, pořadí souborů=y).
%
% Konstanty kalibrace λ:
LAMBDA_MIN = 400;   % λ [nm] v prvním sloupci (po kalibraci)
LAMBDA_MAX = 850;   % λ [nm] v posledním sloupci
FIRST_PIXEL = 1;    % index sloupce, kde začíná λ_min (někde kus za 0. řádem)

files = dir(fullfile(dataDir, '*.bmp')); % načte soubory typu .bmp z poskytnuté složky

if isempty(files)
    error('Nenalezeny BMP v %s', dataDir); 
end

names = sort({files.name}); % seřadí názvy dle abecedy (měly by mít ascending čísla)

% Načte první soubor pro zjištění rozměrů
img0 = imread(fullfile(dataDir, names{1}));

x_dim     = size(img0, 1);   % výška = x
lambda_px = size(img0, 2);   % šířka = λ
y_dim = numel(names);        % šířka = y (počet snímků)


% Lineární osa λ (zleva doprava)
lambda_axis = LAMBDA_MIN + ((1:lambda_px) - FIRST_PIXEL) * (LAMBDA_MAX - LAMBDA_MIN) / (lambda_px - 1);

cube = zeros( y_dim, x_dim, lambda_px, 'single');

for yi = 1:y_dim
    img = imread(fullfile(dataDir, names{yi}));
    cube(yi, :, :) = single(img); % ulož [y, x, λ]
end

end