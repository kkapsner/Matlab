function styleLineObject(hs, varargin)
%STYLELINEOBJECT styles the line object apropriate for the paper
    for h = hs
        set(h, ...
            'MarkerSize', 10, ...
            'LineWidth', 2 ...
        );
    end
    Paper.Axes.stylePointObject(hs, varargin{:});

end

