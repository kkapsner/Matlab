function sTrace = slice(this, startTime, endTime)
%TRACE.SLICE generates a new sliced trace and returns it
%
%   STRACE = TRACE.SLICE()
%   STRACE = TRACE.SLICE(STARTTIME) generates a sliced trace with
%   STARTTIME as the start time for slicing
%   STRACE = TRACE.SLICE(..., ENDTIME) generates a sliced trace with
%   ENDTIME as the end time for slicing
%
%   SEE ALSO: SLICEDTRACE
    sTrace = SlicedTrace(this);
    if (nargin > 1 && ~isempty(startTime))
        sTrace.setStartTime(startTime);
    end
    if (nargin > 2 && ~isempty(endTime))
        sTrace.setEndTime(endTime);
    end
end