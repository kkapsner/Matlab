function dTrace = diff(this, windowSize)
%TRACE.DIFF generates the differentiated trace and returns it
%
%   DTRACE = TRACE.DIFF()
%   DTRACE = TRACE.DIFF(WINDOWSIZE)
%
%   SEE ALSO: DIFFERENTIATEDTRACE
    dTrace = DifferentiatedTrace(this);
    if (nargin > 1)
        for o = dTrace
            o.differentiationWindowSize = windowSize;
        end
    end
end