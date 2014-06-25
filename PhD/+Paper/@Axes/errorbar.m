function h = errorbar(a, x, y, r, c, varargin)
%AXES.ERRORBAR plots a line with error bars apropriate for the paper
    h = errorbar(x, y, r, c, varargin{:}, ...
        'Parent', a.ax ...
    );
    Paper.Axes.styleLineObject(h);
end

