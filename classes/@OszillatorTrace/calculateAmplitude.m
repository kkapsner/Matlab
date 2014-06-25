function calculateAmplitude(oscTrace)
% CALCULATEAMPLITUDE
    for o = oscTrace
        if (o.isOscillating)
            values = o.periodPeakValues;
            if (values(1) < 0)
                values = values(2:end);
            end
            if (numel(values) > 5)
                values = values(1:5);
            end
            o.amplitude = max(abs(diff(values)));
        else
            o.amplitude = 0;
        end
    end
end