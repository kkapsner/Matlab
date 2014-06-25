function fit = bacteriaGrowth()
%BACTERIAGROWTH creates a fit object for bacterial growth data
%
% Fits an exponential at the start of the curve and a linear in the middle
% and an exponential saturation at the end
    fit = Fit.FitObject( ...
        @(offset, delta, exp_a1, exp_b1, t_switch_1, lin_slope, t_switch_2, exp2, x) ...
            growth(offset, delta, exp_a1, exp_b1, t_switch_1, lin_slope, t_switch_2, exp2, x) ...
    );
    
    fit.funcTex = '$ $';
    fit.setArgumentValue( ...
        {'offset', 'delta', 'exp_a1', 'exp_b1', 't_switch_1', 'lin_slope', 't_switch_2', 'exp2'}, ...
        [0, 1, 1, 1, 1, 0, 2, 1] ...
    );
end

function y = growth(offset, delta, exp_a, exp_b, switchTime1, lin_slope, switchTime2, exp2, x)
    filter1 = x < switchTime1;
    filter2 = ~filter1 & x < switchTime2;
    filter3 = ~filter1 & ~filter2;
    
    y = zeros(size(x));
    try
        if (any(filter1))
            y(filter1) = offset + exp_a.*exp(exp_b .* x(filter1));
        end

        lin_offset = offset + exp_a.*exp(exp_b .* switchTime1);
        if (any(filter2))
            y(filter2) = lin_offset + lin_slope .* (x(filter2) - switchTime1);
        end

        if (any(filter3))
            exp_offset = lin_offset + lin_slope .* (switchTime1 - switchTime1);
            y(filter3) = exp_offset + (delta - exp_offset + offset) .* exp(-exp2 .* (x(filter3) - switchTime2));
        end
    catch e
        disp(e);
    end
end

