function fit = lognormalDistribution()
%EXPONENTIALDECAY creates an gaussian fit object

    fit = Fit.FitObject(@(mu,sigma,a,b,x)a./x.*exp(-1/2.*((log(x)-mu)./sigma).^2)+b);
    
    fit.funcTex = '$\frac{a}{x}\cdot e^{-\frac{1}{2}\left(\frac{\ln{x}-\mu}{\sigma}\right)^2}+b$';
    fit.setArgumentValue( ...
        {'a', 'sigma', 'mu', 'b'}, ...
        [0, 1, 0, 0] ...
    );
    
end

