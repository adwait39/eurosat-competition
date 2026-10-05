% ASEN 6337 - EuroSAT competition - MATLAB loader
% Use the .mat files, not the .npz files. MATLAB cannot read .npz.
% Nothing beyond base MATLAB is required. No Image Processing Toolbox.

%% ------------------------------------------------------------ training set
load('train.mat');            % gives X, y, classes, bands, wavelength_nm, resolution_m

classes = cellstr(classes);   % stored as a padded char matrix -> cell of strings
bands   = cellstr(bands);

size(X)                       % 18900  64  64  13   uint16
disp(classes{y(1)})           % label of patch 1

% y is already 1-based (1..10) so it indexes `classes` directly.

%% ----------------------------------------------------------------- test set
test = load('test.mat');
Xt  = test.X;                 % 8100  64  64  13
ids = test.id;                % 8100  1

%% ------------------------------------------------------- band information
% Bands are in CANONICAL Sentinel-2 order. In MATLAB (1-based):
%
%    1=B01   2=B02   3=B03   4=B04   5=B05   6=B06   7=B07
%    8=B08   9=B8A  10=B09  11=B10  12=B11  13=B12
%
% NOTE: every band index is one higher than the Python index in the README,
% because MATLAB counts from 1. B8A is index 9 here, index 8 in Python.

red = double(X(:,:,:,4));     % B04
nir = double(X(:,:,:,8));     % B08
ndvi = (nir - red) ./ (nir + red + 1e-6);

% Mean NDVI per patch:
ndvi_mean = squeeze(mean(ndvi, [2 3]));

%% --------------------------------------------------------- writing an answer
% One row per test id. Labels are class-name strings, exactly as in `classes`.

preds = repmat(classes(1), numel(ids), 1);   % replace with your model's output

T = table(ids(:), string(preds(:)), 'VariableNames', {'id','label'});
writetable(T, 'submission.csv');

fprintf('wrote submission.csv with %d rows\n', height(T));
