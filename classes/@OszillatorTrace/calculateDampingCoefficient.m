function calculateDampingCoefficient(oscTrace)
%CALCLATEAMPLITUDEANDDAMPINGCOEFFICIENT
    for o = oscTrace
        times = o.periodPeakTimes;
        if (numel(times) > 1)
            values = abs(o.periodPeakValues);

            c = fit(times, values, 'exp1');
%             o.amplitude = c.a;
            o.dampingCoefficient = -c.b;
        else
%             o.amplitude = 0;
            o.dampingCoefficient = 0;
        end
    end
end

