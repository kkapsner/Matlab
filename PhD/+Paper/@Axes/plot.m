function h = plot(a, varargin)
%AXES.PLOT like normal plot
    if (isa(varargin{1}, 'Trace'))
        trace = varargin{1};
        varargin = {[trace.time], [trace.filteredValue]};
    end
    h = plot(varargin{:}, 'Parent', a.ax);
    Paper.Axes.styleLineObject(h);
end