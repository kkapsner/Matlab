function divideTrace = mrdivide(trace1, trace2)
    if (isa(trace1, 'AbstractTrace'))
        if (isa(trace2, 'AbstractTrace'))
            divideTrace = CalculationTrace(trace1, '/', trace2);
        else
            divideTrace = RescaledTrace(trace1);
            divideTrace.setValueFactor(trace2);
            divideTrace.setIsValueFactorInverse(true);
        end
    else
        divideTrace = FunctionTrace(trace2, @(v)trace1 ./ v);
    end
end