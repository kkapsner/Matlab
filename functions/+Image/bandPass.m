function filteredImage = bandPass(image, cutoffs, type)
%bandPass filters the image with a DFT bandpass filter
%   bandPass(IMAGE, CUTOFFS)
    if (nargin < 3)
        type = 'gauss';
    end
    fImage = fft2(image);
    filter = Image.getBandPassFilter(size(image), cutoffs, type);
    filteredImage = ifft2(fImage .* filter);
end

