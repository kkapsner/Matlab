function fit = exponentialDecay()
%EXPONENTIALDECAY creates an exponential decay fit object

    fit = Fit.FitObject(@(dy,tau,x0,y0,x)y0+dy.*(exp(-(x-x0)./tau)-1));
    
    fit.funcTex = '$y_0 + dy(\cdot e^{-(x-x_0)/\tau}-1)$';
    fit.setProblem('x0');
    fit.setArgumentValue( ...
        {'dy', 'tau', 'x0', 'y0'}, ...
        [1, 1, 0, 0] ...
    );
    
end

