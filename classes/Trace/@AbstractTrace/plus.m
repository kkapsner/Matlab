function plusTrace = plus(trace1, trace2)
    if (isa(trace1, 'AbstractTrace'))
        if (isa(trace2, 'AbstractTrace'))
            plusTrace = CalculationTrace(trace1, '+', trace2);
        else
            plusTrace = ShiftedTrace(trace1, trace2, 0);
        end
    else
        plusTrace = ShiftedTrace(trace2, trace1, 0);
    end
end