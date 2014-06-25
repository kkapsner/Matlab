function T = getFFTPeriod(o)
%GETFFTPERIOD 
    [~, n] = max(abs(fft(o.filteredValue)));
    T = (o.time(end) - o.time(1)) / (n - 1);

end

