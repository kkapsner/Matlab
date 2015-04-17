function fit = parabel2D()
%POLY creates an polynomial fit object
    

    fit = Fit.FitObject(@(offset, slope1, bend1, slope2, bend2, x1, x2) ...
        offset + slope1 .* x1 + bend1 .* x1.^2 + slope2 .* x2 + bend2 .* x2.^2);
    
    fit.setIndependent({'x1', 'x2'});
end

