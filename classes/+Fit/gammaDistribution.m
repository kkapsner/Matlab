function fit = gammaDistribution()
%GAMMADISTRIBUTION creates fit object fro a gamma distribution
    
    fit = Fit.FitObject(@(a, mu, beta, x)a.*x^(mu./beta-1).*exp(-x./beta));
    
    fit.funcTex = '$a \cdot x^{\mu/\beta-1}\cdot e^{-x/\beta}$';
    fit.setArgumentValue( ...
        {'a', 'mu', 'beta'}, ...
        [1, 10, 1] ...
    );
end

