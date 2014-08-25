function l = plotVerticalLines(axes, linePositions, varargin)
    y = get(axes, 'ylim');
    l = zeros(size(linePositions));
    for i = 1:numel(linePositions)
        l(i) = line( ...
            linePositions([i, i]), y, ...
            'parent', axes, ...
            varargin {:}, ...
            'YLimInclude', 'off', ...
            'XLimInclude', 'off', ...
            'ZLimInclude', 'off' ...
        );
    end
    
    resizeListener = addlistener(axes, 'YLim', 'PostSet', @resizeCallback);
    
    function resizeCallback(~, ~)
        if all(ishghandle(l))
            set(l, 'YData', get(axes, 'YLim'));
        else
            delete(resizeListener);
        end
    end
end