function fit = binomialDistribution()
%BINOMIALDISTRIBUTION creates a fit object for a binomial distribution
    
    fit = Fit.FitObject(@(a, mu, x)a.*exp(-(x - mu).^2./mu));
    
    fit.funcTex = '$a \cdot e^{-\left(x - \mu\right)^2/\mu}$';
    fit.setArgumentValue( ...
        {'a', 'mu'}, ...
        [1, 10] ...
    );
end

