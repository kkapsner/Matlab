function fit = hill2D()
%EXPONENTIAL creates a exponential fit object
    
    fit = Fit.FitObject(@(a, b, k1, n1, k2, n2, x1, x2)a./((k1./x1).^n1+1)./((k2./x2).^n2+1) + b);
    
    fit.funcTex = '$\frac{a}{\left[\left(\frac{k_1}{x_1}\right)^{n_1}+1\right]\cdot\left[\left(\frac{k_2}{x_2}\right)^{n_2}+1\right]}+b$';
    fit.setIndependent('x1');
    fit.setIndependent('x2');
    fit.setArgumentValue( ...
        {'a', 'b', 'k1', 'n1', 'k2', 'n2'}, ...
        [1, 0, 1, 1, 1, 1] ...
    );
end

