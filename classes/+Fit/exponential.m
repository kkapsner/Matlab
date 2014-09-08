function fit = exponential()
%EXPONENTIAL creates a exponential fit object
    
    fit = Fit.FitObject(@(offset, amplitude, exponent, x)offset+amplitude.*x.^exponent);
    
    fit.funcTex = '$offset + amplitude \cdot x^{exponent}$';
    fit.setArgumentValue( ...
        {'offset', 'amplitude', 'exponent'}, ...
        [0, 1, 1] ...
    );
end

