function fit = logarithmus()
%LOGARITHMUS creates a legarithmic fit object
    
    fit = Fit.FitObject(@(a, b, x)a+b.*log(x));
    
    fit.funcTex = '$a + b \cdot ln(x)$';
    fit.setArgumentValue( ...
        {'a', 'b'}, ...
        [0, 1] ...
    );
end

