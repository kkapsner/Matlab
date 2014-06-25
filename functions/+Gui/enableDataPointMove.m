function menuEntry = enableDataPointMove(plotHandle, callback)
%ENABLEDATAPOINTMOVE enables data point moving
%   creates a context menu entry to move the nearest data point where
%   clicked in the plot.
%
%   ENABLEDATAPOINTMOVE(PLOTHANDLE) enables the moving
%   ENABLEDATAPOINTMOVE(..., CALLBACK) registers a callback that is called
%       everytime a data point is moved. The callback gets as parameters
%       the index of the moving point and the potentional new position. It
%       has to return the desired new position.
%   MENUENTRY = ENABLEDATAPOINTMOVE(...) returns the handle for the menu
%       entry.
    
    if (isempty(plotHandle))
        return;
    end
    
    if (nargin < 2)
        callback = @(~,a)a;
    end
    
    contextmenu = Gui.createContextMenuIfNotExisting(plotHandle);
    
    menuEntry = uimenu( ...
        contextmenu, ...
        'Label', 'move data point', ...
        'Callback', @menuCallback ...
    );
    
    moveIdx = [];
    ax = [];
    fig = [];
    motionListener = [];
    buttonDownListener = [];
    
    function menuCallback(~,~)
        if (isempty(moveIdx))
            startMoving();
        else
            stopMoving();
        end
    end
    
    function startMoving(~,~)
        set(menuEntry, 'Checked', 'on');
        
        xData = get(plotHandle, 'XData');
        yData = get(plotHandle, 'YData');
        zData = get(plotHandle, 'ZData');
        
        if (isempty(zData))
            zData = zeros(size(xData));
        end
        
        ax = Gui.getParentAxes(plotHandle);
        fig = Gui.getParentFigure(ax);
        mousePoint = get(ax, 'CurrentPoint');
        
        distance = ...
            (xData - mousePoint(1, 1)).^2 + ...
            (yData - mousePoint(1, 2)).^2 + ...
            (zData - mousePoint(1, 3)).^2;
        
        [~, moveIdx] = min(distance);
        
        motionListener = iptaddcallback(fig, ...
            'WindowButtonMotionFcn', @mouseMoveCallback);
        buttonDownListener = iptaddcallback(fig, ...
            'WindowButtonDownFcn', @stopMoving);
    end

    function mouseMoveCallback(~,~)
        mousePoint = get(ax, 'CurrentPoint');
        newPosition = callback(moveIdx, mousePoint(1, :));
        
        xData = get(plotHandle, 'XData');
        yData = get(plotHandle, 'YData');
        zData = get(plotHandle, 'ZData');
        
        if (isempty(zData))
            zData = zeros(size(xData));
        end
        
        xData(moveIdx) = newPosition(1);
        yData(moveIdx) = newPosition(2);
        zData(moveIdx) = newPosition(3);
        
        set( ...
            plotHandle, ...
            'XData', xData, ...
            'yData', yData, ...
            'zData', zData ...
        );
    end

    function stopMoving(~,~)
        set(menuEntry, 'Checked', 'off');
        
        iptremovecallback(fig, 'WindowButtonMotionFcn', motionListener);
        iptremovecallback(fig, 'WindowButtonDownFcn', buttonDownListener);
        
        moveIdx = [];
        ax = [];
        fig = [];
        motionListener = [];
        buttonDownListener = [];
    end
end

