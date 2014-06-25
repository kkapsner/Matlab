function h = scatter(a, varargin)
%AXES.scatter like normal plot
    if (isa(varargin{1}, 'Trace'))
        trace = varargin{1};
        varargin = {[trace.time], [trace.filteredValue], varargin{2:end}};
    end
    h = scatter(varargin{:}, 'Parent', a.ax);
    Paper.Axes.stylePointObject(h);
end