function filtered = filterTimeGauss(sigma, data, time)
    %FILTERED = filterTimeGauss(SIGMA, DATA, TIME)
    % Filters the DATA with a weighted moving average. The weighting is 
    % specified over a Gauss function with sigma SIGMA in the time domain
    % TIME
    
    s = size(data);
    if (s ~= size(time))
        error('filterTimeGauss:badDimensions', ...
            'Not matching dimensions of data and time.');
    end
    
    filtered = zeros(s(1), s(2));
    
    if (min(s) ~= 1)
        for i = 1:s(2)
            filtered(:, i) = filterTimeGauss(sigma, data(:, i), time(:, i));
        end
    else
        for i = 1:numel(data)
            weighting = exp(-((time - time(i))/sigma).^2);
            filtered(i) = sum(weighting .* data)/sum(weighting);
        end
    end
end