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
    
    y = get(axes, 'YLim');
    
    l = [ ...
        line( ...
            position([1 1]), y, ...
            'LineWidth', 2, ...
            'HitTest', 'off', ...
            'Parent', hg, ...
            'Color', 'w', ...
            'YLimInclude', 'off', ...
            'XLimInclude', 'off', ...
            'ZLimInclude', 'off'...
        ) ...
         line( ...
            position([1 1]), y, ...
            'LineWidth', 1, ...
            'HitTest', 'off', ...
            'Parent', hg, ...
            'Color', 'k', ...
            'YLimInclude', 'off', ...
            'XLimInclude', 'off', ...
            'ZLimInclude', 'off' ...
        ) ...
    ];

    resizeListener = addlistener(axes, 'YLim', 'PostSet', @resizeYCallback);
    reorderListener = addlistener(axes, 'ObjectChildAdded', @bringLineToTop);
    
    api.addPatch = @addPatch;
    api.setResizeListener = @setResizeListener;
    api.removeResizeListener = @removeResizeListener;
    api.setReorderListener = @setReorderListener;
    api.removeReorderListener = @removeReorderListener;
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
            xLim = get(axes, 'XLim');
            switch (side)
                case 'left'
                    startIdx = 1;
                case 'right'
                    startIdx = 2;
                otherwise
                    error('Unknown patch side.');
            end
            yLim = get(axes, 'YLim');
            patchHandle = handle(patch( ...
                [xLim(startIdx); xLim(startIdx); position([1; 1])], ...
                yLim([1; 2; 2; 1]), ...
                [0, 0, 0], ...
                'UserData', startIdx, ...
                'Parent', hg, ...
                'FaceAlpha', 0.1, ...
                'HandleVisibility', 'off', ...
                'HitTest', 'off', ...
                'YLimInclude', 'off', ...
                'XLimInclude', 'off', ...
                'ZLimInclude', 'off'...
            ));
        end
        listener = addlistener(axes, 'XLim', 'PostSet', @resizeXCallback);
        function resizeXCallback(~, ~)
            if (~isempty(patchHandle))
                if all(ishghandle(patchHandle))
                    xLimNew = get(axes, 'XLim');
                    patchHandle.XData([1,2]) = xLimNew(patchHandle.UserData([1, 1]));
                else
                    delete(listener);
                end
            end
        end
    end
    
    function setResizeListener()
        removeResizeListener();
        resizeListener = addlistener(axes, 'YLim', 'PostSet', @resizeYCallback);
        resizeYCallback();
    end
    function removeResizeListener()
        if (~isempty(resizeListener))
            delete(resizeListener);
            resizeListener = [];
        end
    end

    function setReorderListener()
        removeReorderListener();
        reorderListener = addlistener(axes, 'ObjectChildAdded', @bringLineToTop);
        bringLineToTop();
    end
    function removeReorderListener()
        if (~isempty(reorderListener))
            delete(reorderListener);
            reorderListener = [];
        end
    end
    
    function setVisible(isVisible)
        if isVisible
            value = 'on';
        else
            value = 'off';
        end
        set(hg, 'Visible', value);
        if (~isempty(patchHandle))
            patchHandle.Visible = value;
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

    function resizeYCallback(~, ~)
        if all(ishghandle(l))
            yLim = get(axes, 'YLim');
            set(l, 'YData', yLim);
            if (~isempty(patchHandle))
                patchHandle.YData = yLim([1; 2; 2; 1]);
            end
        else
            removeResizeListener();
        end
    end

    function bringLineToTop(varargin)
        if all(ishghandle(hg))
            uistack(hg, 'top');
        else
            removeReorderListener();
        end
    end

    function updateView(position)
        set(l, 'XData', position([1 1]));
        if (~isempty(patchHandle))
            patchHandle.XData(3:4) = position;
        end
    end

    function point = getCurrentPoint()
        p = get(axes, 'CurrentPoint');
        point = p(1);
    end

    function setHg(name, value)
        set(hg, name, value);
    end

    function deleteLine()
        if ishghandle(hg)
            if (~isempty(patchHandle) && ishghandle(patchHandle))
                delete(patchHandle);
            end
            delete(hg);
            delete(resizeListener);
            delete(reorderListener);
        end
    end
end

