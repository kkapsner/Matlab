function fit = linear()
%LINEAR creates an liner fit object

    fit = Fit.FitObject(@(slope, offset, x)slope.*x + offset);
    
    fit.funcTex = '$slope \cdot x + offset$';
    fit.setArgumentValue( ...
        {'slope', 'offset'}, ...
        [1, 0] ...
    );
end

