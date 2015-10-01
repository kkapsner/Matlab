function timesTrace = mtimes(trace1, trace2)
    if (isa(trace1, 'AbstractTrace'))
        if (isa(trace2, 'AbstractTrace'))
            timesTrace = CalculationTrace(trace1, '*', trace2);
        else
            timesTrace = RescaledTrace(trace1);
            timesTrace.setValueFactor(trace2);
        end
    else
        timesTrace = RescaledTrace(trace2);
        timesTrace.setValueFactor(trace1);
    end
end