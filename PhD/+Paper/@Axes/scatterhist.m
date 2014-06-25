function h = scatterhist(a, varargin)
%AXES.SCATTERHIST like normal scatterhist
    if (isa(varargin{1}, 'Trace'))
        trace = varargin{1};
        varargin = {[trace.time], [trace.filteredValue], varargin{2:end}};
    end
    h = scatterhist(varargin{:});
    a.ax = h(1);
    hold(a.ax, 'on');
%     Paper.Axes.styleLineObject(h(1));


end

