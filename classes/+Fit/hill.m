function fit = hill()
%EXPONENTIAL creates a exponential fit object
    
    fit = Fit.FitObject(@(a, b,  k, n, x)a./((k./x).^n+1) + b);
    
    fit.funcTex = '$\frac{a}{\left(\frac{k}{x}\right)^n+1}+b$';
    fit.setArgumentValue( ...
        {'a', 'b', 'k', 'n'}, ...
        [1, 0, 0, 1] ...
    );
end

