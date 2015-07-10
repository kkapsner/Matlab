function [selection, antiSelection, filter] = guiDirectSelect(obj, colNames, rowNames)
%GUIDIRECTSELECT 
%   
    if (isa(colNames, 'function_handle'))
        colNames = arrayfun(colNames, obj(1, :), 'UniformOutput', false);
    end
    if (isa(rowNames, 'function_handle'))
        rowNames = arrayfun(rowNames, obj(:, 1), 'UniformOutput', false);
    end
    
    dm = DialogManager(obj);
    dm.open();
    dm.addPanel();
    
    filter = true(size(obj));
    table = handle(uitable( ...
        'Parent', dm.currentPanel, ...
        'Units', 'Pixels', ...
        ...'Position', [0, 0, 1, 1], ...
        'Data', filter, ...
        'ColumnName', colNames, ...
        'RowName', rowNames, ...
        'ColumnEditable', true(1, size(obj, 2)), ...
        'ColumnFormat', arrayfun(@(a)'logical', ones(1, size(obj, 2)), 'Uniform', false), ...
        'CellEditCallback', @setData...
    ));
    table.Units = 'normalized';
    table.Position = [0, 0, 1, 1];
    
    
    dm.addPanel(1);
    dm.addButtonRow('OK', @dm.close);
    
    dm.show();
    dm.wait();
    
    selection = obj(filter);
    if (nargout > 2)
        antiSelection = obj(~filter);
    end
    
    function setData(~,~)
        filter = table.Data;
    end
end