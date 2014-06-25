function fit = gauss()
%EXPONENTIALDECAY creates an gaussian fit object

    fit = Fit.FitObject(@(mu,sigma,a,b,x)a.*exp(-1/2.*((x-mu)./sigma).^2)+b);
    
    fit.funcTex = '$a\cdot e^{-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2}+b$';
    fit.setArgumentValue( ...
        {'a', 'sigma', 'mu', 'b'}, ...
        [0, 1, 0, 0] ...
    );
    
end

