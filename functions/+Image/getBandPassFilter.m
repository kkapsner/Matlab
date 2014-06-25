function filter = getBandPassFilter(s, cutoffs, type)
%getBandPassFilter creates a filter matrix to be used for filtering in
%Fourier space
%   FILTER = getBandPassFilter(S, CUTOFFS) returns the FILTER for an image
%       of size S with CUTOFFS

    if (nargin < 3)
        type = 'gauss';
    end

    fcut1 = [0.5, 0.5] ./ cutoffs * s(1);
    fcut2 = [0.5, 0.5] ./ cutoffs * s(2);
    x = ones(s(1), 1) * (1:s(2));
    x_ = mod(((x - 1) + floor(s(2)/2)), s(2)) - floor(s(2)/2);
    y = (1:s(1))' * ones(1, s(2));
    y_ = mod(((y - 1) + floor(s(1)/2)), s(1)) - floor(s(1)/2);
    
    switch (type)
        case 'butterworth'
            filter = ...
                ( ...
                    1 ./ (1.0 + (x_ /fcut2(1)).^2 + (y_ /fcut1(1)).^2) - ...
                    1 ./ (1.0 + (x_ /fcut2(2)).^2 + (y_ /fcut1(2)).^2)...
                );
        otherwise
            filter = ...
                ( ...
                    exp(-((x_ /fcut2(1)).^2 + (y_ /fcut1(1)).^2)) - ...
                    exp(-((x_ /fcut2(2)).^2 + (y_ /fcut1(2)).^2)) ...
                );
    end

end

