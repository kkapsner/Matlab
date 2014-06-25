function menuEntry = enableDataPointDeletion(plotHandle, callback)
%ENABLEDATAPOINTDELETION enables user controlles data point deletion
%   creates an entry in the context to delete the nearest data point where
%   clicked in the plot.
%   
%   enableDataPointDeletion(plotHandle) enables the deletion
%   enableDataPointDeletion(..., callback) registers a callback that is
%       called every time a data point is deleted. The callback gets as
%       parameter the index of the deleted data point
%   menuEntry = enableDataPointDeltion(...) returns the handle for the menu
%       entry.

    if (isempty(plotHandle))
        return;
    end
    
    if (nargin < 2)
        callback = @(a)a;
    end
    
    contextmenu = Gui.createContextMenuIfNotExisting(plotHandle);
    
    menuEntry = uimenu( ...
        contextmenu, ...
        'Label', 'delete data point', ...
        'Callback', @deletePoint ...
    );

    function deletePoint(~, ~)
        xData = get(plotHandle, 'XData');
        yData = get(plotHandle, 'YData');
        zData = get(plotHandle, 'ZData');
        
        if (isempty(zData))
            zData = zeros(size(xData));
        end
        
        mousePoint = get(Gui.getParentAxes(plotHandle), 'CurrentPoint');
        
        distance = ...
            (xData - mousePoint(1, 1)).^2 + ...
            (yData - mousePoint(1, 2)).^2 + ...
            (zData - mousePoint(1, 3)).^2;
        
        [~, idx] = min(distance);
        
        filter = true(size(xData));
        filter(idx) = false;
        
        set( ...
            plotHandle, ...
            'XData', xData(filter), ...
            'yData', yData(filter), ...
            'zData', zData(filter) ...
        );
        callback(idx);
    end
end

