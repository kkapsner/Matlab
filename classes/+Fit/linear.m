function fit = linear()
%LINEAR creates an liner fit object

    fit = Fit.FitObject(@(a, b, x)a.*x + b);
    
    fit.funcTex = '$a \cdot x + b$';
    fit.setArgumentValue( ...
        {'a', 'b'}, ...
        [1, 0] ...
    );
end

