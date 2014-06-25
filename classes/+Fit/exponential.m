function fit = exponential()
%EXPONENTIAL creates a exponential fit object
    
    fit = Fit.FitObject(@(a, b, c, x)a+b.*x.^c);
    
    fit.funcTex = '$a + b \cdot x^c$';
    fit.setArgumentValue( ...
        {'a', 'b', 'c'}, ...
        [0, 1, 1] ...
    );
end

