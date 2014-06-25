function fit = exp()
%EXPONENTIAL creates a e^x fit object
    
    fit = Fit.FitObject(@(a, b, tau, x)a+b.*exp(x./tau));
    
    fit.funcTex = '$a + b \cdot e^{x/\tau}$';
    fit.setArgumentValue( ...
        {'a', 'b', 'tau'}, ...
        [0, 1, 1] ...
    );
end

