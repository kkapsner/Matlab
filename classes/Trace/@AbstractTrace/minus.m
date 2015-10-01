function minusTrace = minus(trace1, trace2)
    if (isa(trace1, 'AbstractTrace'))
        if (isa(trace2, 'AbstractTrace'))
            minusTrace = CalculationTrace(trace1, '-', trace2);
        else
            minusTrace = ShiftedTrace(trace1, -trace2, 0);
        end
    else
        minusTrace = FunctionTrace(trace2, @(v)trace1 - v);
    end
end