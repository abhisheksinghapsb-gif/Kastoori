function [imgNorm, mask] = preprocess_fundus_bengraham(img, targetSize, sigma)
% PREPROCESS_FUNDUS_BENGRAHAM Landmark Ben Graham contrast normalization
% for robust Diabetic Retinopathy screening across diverse clinical cameras.
%
% Formula:
%   I_norm = 4 * I - 4 * GaussianFilter(I, sigma) + 128
%
% Standardizes global illumination, strips camera-specific glare, and sharply
% amplifies microaneurysms, hemorrhages, and lipid exudates.
%
% Inputs:
%   img        - Input RGB retinal fundus image (uint8 or double)
%   targetSize - Target output dimensions [H, W] (default: [227, 227])
%   sigma      - Gaussian standard deviation (default: 10)
%
% Outputs:
%   imgNorm    - Normalized RGB image (uint8, [targetSize, 3])
%   mask       - Circular field-of-view (FOV) mask

    if nargin < 2 || isempty(targetSize), targetSize = [227, 227]; end
    if nargin < 3 || isempty(sigma), sigma = 10; end

    % Standardize data type and size
    if isa(img, 'double') && max(img(:)) <= 1.0
        img = uint8(img * 255.0);
    else
        img = uint8(img);
    end

    if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
    end

    if size(img, 1) ~= targetSize(1) || size(img, 2) ~= targetSize(2)
        img = imresize(img, targetSize);
    end

    imgDbl = double(img);

    % Compute local Gaussian background estimate
    kSize = round(6 * sigma) + 1;
    if mod(kSize, 2) == 0, kSize = kSize + 1; end
    h = fspecial('gaussian', [kSize, kSize], sigma);
    blurred = imfilter(imgDbl, h, 'replicate');

    % Ben Graham contrast amplification
    normDbl = 4.0 * imgDbl - 4.0 * blurred + 128.0;
    imgNorm = uint8(max(0, min(255, normDbl)));

    % Generate circular FOV mask to eliminate border artifacts
    gray = rgb2gray(img);
    mask = gray > 15;
    mask = imfill(mask, 'holes');
    mask = imerode(mask, strel('disk', 3));

    mask3 = repmat(mask, [1, 1, 3]);
    imgNorm(~mask3) = 0;
end
