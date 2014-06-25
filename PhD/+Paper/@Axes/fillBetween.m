function h = fillBetween(a, x1, y1, x2, y2, varargin )
%AXES.FILLBETWEEN plot a filled area between the two series
    f1 = isfinite(y1);
    x1 = x1(f1);
    y1=y1(f1);
    
    f2 = isfinite(y2);
    x2 = x2(f2);
    y2 = y2(f2);
    
    h = fill( ...
        joinVectors(x1, x2), ...
        joinVectors(y1, y2), ...
        [0.9 0.9 1], ...
        'EdgeColor', 'none', ...
        varargin{:}, ...
        'Parent', a.ax ......
    );
    
    function j = joinVectors(a, b)
        if (~isrow(a))
            a = a';
        end
        if (~isrow(b))
            b = b';
        end
        j = [a fliplr(b)];
    end
end

