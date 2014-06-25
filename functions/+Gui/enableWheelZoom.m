function resetMaxLimFcn = enableWheelZoom(ax, enabled, ratio)
% ENABLEWHEELZOOM enables zooming in axes with the mouse wheel
% 
%   ENABLEWHEELZOOM(AXES) enables zooming on the specific axes
%   ENABLEWHEELZOOM(AXES, ENABLED) ENABLED has to be a vector with three
%   entries indicating if the zooming should be enabled for the x-, y- or
%   z-axis, respectively.
%   ENABLEWHEELZOOM(AXES, ENABLED, RATIO) RATIO specifies the ratio between
%   the axis sizes between two zoom steps.

    if (nargin < 3)
        ratio = 2;
    end
    if (nargin < 2)
        enabled = true(3, 1);
    end
    if (numel(enabled) < 3)
        enabled(3) = false;
    end
    
    f = Gui.getParentFigure(ax);
    oldWindowScrollWheel = get(f, 'WindowScrollWheelFcn');
    set(f, 'WindowScrollWheelFcn', @scrollWheel)
    
    maxXLim = get(ax, 'XLim');
    maxYLim = get(ax, 'YLim');
    maxZLim = get(ax, 'ZLim');
    
    resetMaxLimFcn = @resetMaxLim;
    
    function scrollWheel(hObject,eventData)
        if (isa(oldWindowScrollWheel, 'function_handle'))
            oldWindowScrollWheel(hObject, eventData);
        end
        if (Gui.isMouseOver(ax))
            if (eventData.VerticalScrollCount < 0)
                factor = 1/ ratio;
            else
                factor = ratio;
            end
            
            cursorPos = get(ax, 'CurrentPoint');
            
            if (enabled(1))
                currentXLim = get(ax, 'XLim');
                newXLim = changeLim(currentXLim, factor, cursorPos(1, 1), maxXLim);
                set(ax, 'XLim', newXLim);
            end
            if (enabled(2))
                currentYLim = get(ax, 'YLim');
                newYLim = changeLim(currentYLim, factor, cursorPos(1, 2), maxYLim);
                set(ax, 'YLim', newYLim);
            end
            if (enabled(3))
                currentZLim = get(ax, 'ZLim');
                newZLim = changeLim(currentZLim, factor, cursorPos(1, 3), maxZLim);
                set(ax, 'ZLim', newZLim);
            end
        end
    end

    function newLim = changeLim(oldLim, factor, center, limits)
        newLim = ((oldLim - center) * factor) + center;
        
        newRange = diff(oldLim) * factor;
        if (newRange > diff(limits))
            newRange = diff(limits);
        end
%         newLim = center + ([-newRange, newRange]/2);
        
        if (newLim(1) < limits(1))
            newLim = limits(1) + [0, newRange];
        elseif (newLim(2) > limits(2))
            newLim = limits(2) - [newRange, 0];
        end
    end

    function resetMaxLim()
        maxXLim = get(ax, 'XLim');
        maxYLim = get(ax, 'YLim');
        maxZLim = get(ax, 'ZLim');
    end
end