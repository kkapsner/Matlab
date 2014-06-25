function [selection, antiSelection, filter, limits] = guiSelect(obj, by, logScale, keepNaN)
%GUISELECT 
%   
    if (nargin < 3)
        logScale = false;
    end
    if (nargin < 4)
        keepNaN = false;
    end

    if (isa(by, 'function_handle'))
        values = arrayfun(by, obj);
        by = 'calculated value';
    else
        assert(ischar(by) && isrow(by), 'by Parameter must be a row char.');
        values = [obj.(by)];
    end
    
    minValue = min(values(:));
    maxValue = max(values(:));
    if (keepNaN)
        isNaNFilter = isnan(values);
    else
        isNaNFilter = false(size(values));
    end
    dBound = maxValue - minValue;
    
    dm = DialogManager(obj);
    dm.open();
    dm.addPanel();
    

    a = axes( ...
        'HandleVisibility', 'off', ...
        'Parent', dm.currentPanel ...
    );
    dm.show();
    
    plot(values, '.k', ...
        'Parent', a ...
    );
    set(a, ...
        'XLimMode', 'manual', ...
        'XLim', [0, numel(obj) + 1], ...
        'YLimMode', 'manual', ...
        'YLim', [minValue - 0.1 * dBound, maxValue + 0.1 * dBound], ...
        'XTickLabel', {''}...
    );
    ylabel(a, by);
    
    if (logScale)
        set(a, ...
            'YScale', 'log' ...
        );
    end
    
    minLine = Gui.imhline(a, minValue);
    maxLine = Gui.imhline(a, maxValue);
    minLine.positionConstraintFcn = @restrictLower;
    maxLine.positionConstraintFcn = @restrictUpper;
    minLine.color = [1, 0, 0];
    maxLine.color = [0.3, 1, 0.3];
    
    if (any(strcmp('displaySelection', methods(class(obj)))))
        display = obj.displaySelection();
        oldFilter = getFilter();
        display.selections = {oldFilter, ~oldFilter};
        l = [ ...
            addlistener(maxLine, 'newPosition', @updateFilter), ...
            addlistener(minLine, 'newPosition', @updateFilter) ...
        ];
        addlistener(display.dm, 'closeWin', @(~,~)delete(l));
        display.dm.dependsOn(dm);
    end
    
    dm.wait();
    
    lowerBound = minLine.position;
    upperBound = maxLine.position;
    
    filter = getFilter();
    selection = obj(filter);
    antiSelection = obj(~filter);
    limits = [lowerBound, upperBound];
    
    function filter = getFilter()
        filter = ( ...
            values >= minLine.position & values <= maxLine.position ...
            ) | isNaNFilter;
    end
    function updateFilter(~,~)
        newFilter = getFilter();
        if (any(newFilter ~= oldFilter))
            display.selections = {newFilter, ~newFilter};
        end
    end
    
    function v = restrictLower(v)
        if (v < minValue)
            v = minValue;
        elseif (v > maxLine.position)
            v = maxLine.position;
        elseif (v > maxValue)
            v = maxValue;
        end
    end
    function v = restrictUpper(v)
        if (v < minValue)
            v = minValue;
        elseif (v < minLine.position)
            v = minLine.position;
        elseif (v > maxValue)
            v = maxValue;
        end
    end
end

