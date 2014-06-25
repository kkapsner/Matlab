function fTrace = filter(this, filterValue, filterType)
%TRACE.FILTER generates a new filtered trace and returns it
%
%   FTRACE = TRACE.FILTER()
%   FTRACE = TRACE.FILTER(FILTERVALUE) generates a filtered trace with
%   FILTERVALUE as the parameter for the filter
%   FTRACE = TRACE.FILTER(..., FILTERTYPE) generates a filtered trace with
%   FILTERTYPE as the type of the filter
%
%   SEE ALSO: FILTEREDTRACE
    fTrace = FilteredTrace(this);
    if (nargin > 1 && ~isempty(filterValue))
        fTrace.setFilterValue(filterValue);
    end
    if (nargin > 2)
        fTrace.setFilterType(filterType);
    end
end