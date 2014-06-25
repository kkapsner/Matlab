function fit = logistic()
%LOGARITHMUS creates a legarithmic fit object
    
    fit = Fit.FitObject(@(a, b, c, x_0, x)a+b./(1+exp(-(c.*(x-x_0)))));
    
    fit.setArgumentValue( ...
        {'a', 'b', 'c', 'x_0'}, ...
        [0, 1, 1, 0] ...
    );
end

