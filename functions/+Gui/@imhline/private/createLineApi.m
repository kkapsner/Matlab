function api = createLineApi(axes, position)
%LINEAPI creates the line and provides the api.
%   Detailed explanation goes here
    try
        hg = hggroup( ...
            'HandleVisibility', 'off', ...
            'Visible', 'off', ...
            'Parent', axes ...
        );
    catch e
        error('images:imvline:invalidHParent', 'Invalid parent handle.');
    end

    f = ancestor(axes, 'figure');
    
    iptPointerManager(f);
    iptSetPointerBehavior(hg, @(f, ~)set(f, 'Pointer', 'fleur'));
    
    x = get(axes, 'XLim');
    
    l = [ ...
        line( ...
            x, position([1 1]), ...
            'LineWidth', 2, ...
            'HitTest', 'off', ...
            'Parent', hg, ...
            'Color', 'w', ...
            'YLimInclude', 'off', ...
            'XLimInclude', 'off', ...
            'ZLimInclude', 'off'...
        ) ...
         line( ...
            x, position([1 1]), ...
            'LineWidth', 1, ...
            'HitTest', 'off', ...
            'Parent', hg, ...
            'Color', 'k', ...
            'YLimInclude', 'off', ...
            'XLimInclude', 'off', ...
            'ZLimInclude', 'off' ...
        ) ...
    ];

    resizeListener = addlistener(axes, 'XLim', 'PostSet', @resizeCallback);
    reorderListener = addlistener(axes, 'ObjectChildAdded', @bringLineToTop);
    
    api.setVisible = @setVisible;
    api.getLineWidth = @getLineWidth;
    api.setLineWidth = @setLineWidth;
    api.getColor = @getColor;
    api.setColor = @setColor;
    api.updateView = @updateView;
    api.getCurrentPoint = @getCurrentPoint;
    api.setHg = @setHg;
    api.delete = @deleteLine;
    api.figure = f;
    api.axes = axes;
    api.hg = hg;
    
    patchHandle = [];
    function addPatch(side)
        if (isempty(patchHandle))
            yLim = get(axes, 'YLim');
            switch (side)
                case 'top'
                    startY = yLim(2);
                case 'bottom'
                    startY = yLim(1);
                otherwise
                    error('Unknown patch side.');
            end
            xLim = get(axes, 'XLim');
            patchHandle = handle(patch( ...
                xLim([1; 2; 2; 1]), ...
                [startY([1;1]); position([1; 1])], ...
                [0, 0, 0], ...
                'Parent', hg, ...
                'FaceAlpha', 0.1, ...
                'HitTest', 'off', ...
                'YLimInclude', 'off', ...
                'XLimInclude', 'off', ...
                'ZLimInclude', 'off'...
            ));
        end
    end
    
    function setVisible(isVisible)
        if isVisible
            set(hg, 'Visible', 'on');
        else
            set(hg, 'Visible', 'off');
        end
    end

    function width = getLineWidth()
        width = get(l(1), 'LineWidth');
    end

    function setLineWidth(width)
        set(l(1), 'LineWidth', width);
        set(l(2), 'LineWidth', width * 2);
    end
    
    function setColor(color)
        set(l(2), 'Color', color);
    end

    function color = getColor()
        color = get(l(2), 'Color');
    end

    function resizeCallback(~, ~)
        if all(ishghandle(l))
            set(l, 'XData', get(axes, 'XLim'));
        else
            delete(resizeListener);
        end
    end

    function bringLineToTop(varargin)
        if all(ishghandle(hg))
            uistack(hg, 'top');
        else
            delete(reorderListener);
        end
    end

    function updateView(position)
        set(l, 'YData', position([1 1]));
        if (~isempty(patchHandle))
            patchHandle.YData(3:4) = position;
        end
    end

    function point = getCurrentPoint()
        p = get(axes, 'CurrentPoint');
        point = p(1, 2);
    end

    function setHg(name, value)
        set(hg, name, value);
    end

    function deleteLine()
        if ishghandle(hg)
            delete(hg);
            delete(resizeListener);
            delete(reorderListener);
        end
    end
end

