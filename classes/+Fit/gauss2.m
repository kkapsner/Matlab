function fit = gauss2()
%EXPONENTIALDECAY creates an two gaussian fit object

    fit = Fit.FitObject(@(mu_1,sigma_1,a_1,mu_2,sigma_2,a_2,b,x)a_1.*exp(-1/2.*((x-mu_1)./sigma_1).^2)+a_2.*exp(-1/2.*((x-mu_2)./sigma_2).^2)+b);
    
    fit.setArgumentValue( ...
        {'a_1', 'sigma_1', 'mu_1', 'a_2', 'sigma_2', 'mu_2', 'b'}, ...
        [1, 1, 0, 1, 1, 0, 0] ...
    );
    
end

