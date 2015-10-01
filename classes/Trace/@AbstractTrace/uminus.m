function minusTrace = uminus(trace)
    minusTrace = RescaledTrace(trace);
    minusTrace.setValueFactor(-1);
end