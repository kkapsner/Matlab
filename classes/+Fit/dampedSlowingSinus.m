function fit = dampedSlowingSinus()
%EXPONENTIALDECAY creates an damped slowing sinus fit object

    fit = Fit.FitObject(@(A,tau,w,delta,phi,x)A.*exp(-x./tau).*sin(x.*(w-delta.*x)+phi));
    
    fit.funcTex = 'A\cdote^(-\frac{x}{\tau})\cdotsin(x\cdot(\omega-\delta\cdotx)+\phi)';
    fit.setArgumentValue( ...
        {'A', 'tau', 'w', 'delta','phi'}, ...
        [1, 0, 1, 0, 0, 0] ...
    );
    
end

