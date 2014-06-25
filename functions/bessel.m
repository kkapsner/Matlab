function output = bessel(cutoff, length, order)
%Generates a vector containing the values for a bessel filter
    if (nargin < 3)
        order = 3;
    end
    output = ones(length,1);
    for x = 1:length
        w = 1i*x/cutoff;
        switch order
            case 1
                output(x) = 1/(1 + w);
            case 2
                output(x) = 3/(3 + 3*w + w^2);
            case 4
                output(x) = 105/(105 + 105*w + 45*w^2 + w^4);
            case 5
                output(x) = 945/(945 + 945*w + 420*w^2 + 105*w^3 + 15*w^4 + w^5);
            otherwise
                output(x) = 15/(15 + 15*w + 6*w^2 + w^3);
                
        end
    end
end