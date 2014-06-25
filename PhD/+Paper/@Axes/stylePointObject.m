function stylePointObject(hs, varargin)
%STYLEPOINTOBJECT styles the point object apropriate for the paper
    for h = hs
        set(h, ...
            'MarkerFaceColor', [1 1 1], ...
            varargin{:}...
        );
    end

end

