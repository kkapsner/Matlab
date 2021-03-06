function fitP = fit(this, schar, weights)
%FIT performs the fitting on the family of functions
    
    if (nargin < 3)
        weights = [];
    end
    
    options = optimset('MaxFunEvals', 5000, 'MaxIter', 5000, 'OutputFcn', @output);
    [f, p, lb, ub] = this.createMinimizeProperties(schar, weights);
    
    [fitP, resnorm] = lsqnonlin(f, p, lb, ub, options);
    
    disp(resnorm);
    
    this.feedBackParameter(fitP);
    
    function stop = output(fitP, ~, ~)
        stop = false;
        this.feedBackParameter(fitP);
        drawnow('expose');
    end
end