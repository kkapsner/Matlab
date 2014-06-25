function [varargout] = getPDF(data, threshold)
%GETPDF estimates the probability densitiy function (pdf) of a given dataset
%
% getPDF(DATA) displays the pdf of the DATA
% getPDF(DATA, THRESHOLD) uses a different threshold for the calculation
% PDF = getPDF(...) produces no output but returns the pdf (not really
% usefull due to unknown x-axes...)
% [x, PDF] = getPDF(...) outputs the x-axes and the PDF

    if (nargin < 2 || isempty(threshold))
        aimError = 0.001;
        deltaAim = 1/512;
        
        threshold = 1;
        lastDelta = 1;
        xAll = sort(data(~isnan(data)));
        a = axes('Parent', figure(), 'HandleVisibility', 'callback');
        hold(a, 'all');
        while (true)
            [x, pdf, error, xCum, yCum] = getPDF(xAll, threshold);
            plot( ...
                x, pdf, ...
                'DisplayName', sprintf('threshold %f', threshold), ...
                'Parent', a ...
            );
            
            change = abs(diff(sign(diff(pdf)))) / 2;
            error = max(change(1:end-2) + change(2:end-1) + change(3:end));
            aimError = 2.5;
            
            if (error > aimError)
                if (lastDelta > deltaAim)
                    threshold = threshold + lastDelta / 2;
                else
                    varargout = {x, pdf, error, threshold, xCum, yCum};
                    return;
                end
            else
                threshold = threshold  - lastDelta/ 2;
            end
            lastDelta = lastDelta / 2;
        end
    end
    
    if (numel(threshold) ~= 1)
        xAll = sort(data(~isnan(data)));
        y = reshape(linspace(0, 1, numel(xAll)), size(xAll));
        
        aPDF = axes('Parent', figure(), 'HandleVisibility', 'Callback');
        hold(aPDF, 'all');
        
        aCum = axes('Parent', figure(), 'HandleVisibility', 'Callback');
        hold(aCum, 'all');
        plot(xAll, y, '-k', ...
            'LineWidth', 2, ...
            'DisplayName', 'original', ...
            'Parent', aCum ...
        );
        
        for t = sort(threshold)
            [x, pdf, error, xCum, yCum] = getPDF(xAll, t);
            plot( ...
                x, pdf, '--', ...
                'DisplayName', sprintf('threshold %f (error: %f)', t, error),...
                'Parent', aPDF ...
            );
            plot( ...
                xCum, yCum, '-', ...
                'DisplayName', sprintf('threshold %f (error: %f)', t, error),...
                'Parent', aCum ...
            );
                
        end
        hold(aPDF, 'off');
        hold(aCum, 'off');
        return;
    end
    
    x = sort(data(~isnan(data)));
    y = reshape(linspace(0, 1, numel(x)), size(x));
    
    filter = true(size(x));
    threshold = threshold * max(diff(x));
    lastX = x(1);
    for i = 2:(numel(x) - 1)
        filter(i) = (x(i) - lastX) > threshold;
        if (filter(i))
            lastX = x(i);
        end
    end
    
    dx = diff(x(filter));
    dy = diff(y(filter));
    
    xOut = x(filter(1:(end-1))) + dx./2;
    pdf = dy./dx;
    
    if (nargout == 0)
        f = figure();
        a = axes('Parent', f);
        plot(x, y, '.', 'Parent', a);
        f = figure();
        a = axes('Parent', f);
        plot(xOut, pdf, 'x', 'DisplayName', 'pdf', 'Parent', a);
    elseif (nargout == 1)
        varargout{1} = pdf;
    elseif (nargout == 2)
        varargout{1} = xOut;
        varargout{2} = pdf;
    elseif (nargout == 3)
        varargout{1} = xOut;
        varargout{2} = pdf;
        varargout{3} = getError();
    elseif (nargout == 4)
        varargout{1} = xOut;
        varargout{2} = pdf;
        varargout{3} = x(filter);
        varargout{4} = y(filter);
    elseif (nargout == 5)
        varargout{1} = xOut;
        varargout{2} = pdf;
        varargout{3} = getError();
        varargout{4} = x(filter);
        varargout{5} = y(filter);
    end
    
    function error = getError()
        yEst = interp1(x(filter), y(filter), x);
        error = sqrt(mean((yEst - y).^2));
    end
end