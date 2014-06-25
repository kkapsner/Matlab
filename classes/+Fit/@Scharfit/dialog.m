function dm = dialog(this)
%DIALOG opens a dialog for the Scharfit

    dm = DialogManager(this);
    dm.width = 570;
    dm.open();
    dm.addPanel();
    
    a = handle(axes( ...
        'Units', 'normalized', ...
        'Position', [0, 0, 1, 1], ...
        'HandleVisibility', 'off', ...
        'Box', 'on', ...
        'XTick', [], ...
        'YTick', [], ...
        'Parent', dm.currentPanel ...
    ));
    text( ...
        'Parent', a, ...
        'String', '... not spezified ...', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Interpreter', 'latex', ...
        'FontSize', 20, ...
        'Units', 'normalized', ...
        'Position', [0.5 0.5] ...
    );
    
    dm.addPanel(1);
    dm.addText('Schar Size', 100);
    dm.addPropertyInput('scharSize', [100, 0, 100], @updateTable);
    
    dm.addPanel(numel(this.allParameter) + 1, 'Parameter');
    
    dm.addTitle('Type', [100, 0, 150]);
    dm.addTitle('Value', [250, 0, 100]);
    dm.addTitle('Lower Bound', [350, 0, 100]);
    dm.addTitle('Upper Bound', [450, 0, 100]);
    
    handles = struct();
    table = [];
    for i = 1:numel(this.allParameter)
        dm.newLine();
        para = this.allParameter(i);
        dm.addText(para.name, 95).HorizontalAlignment = 'center';
        handles(i).menu = dm.addPropertyPopupmenu('type', {'parameter', 'problem', 'scharParameter', 'scharProblem', 'independent'}, [100, 0, 150], @(value)updateMenu(i, value), para);
        handles(i).valueText = dm.addText('', [250, 0, 100]);
        handles(i).valueInput = dm.addPropertyInput('value(1)', [250, 0, 100], [], para);
        handles(i).lowerBoundInput = dm.addPropertyInput('lowerBound', [350, 0, 100], [], para);
        handles(i).upperBoundInput = dm.addPropertyInput('upperBound', [450, 0, 100], [], para);
        
        dm.listen('value', @updateTable, para); 
        
        updateMenu(i, para.type);
    end
    
    dm.addPanel(0, 'Schar Values');
    tablePanel = dm.addPanel(1);
    table = handle(uitable( ...
        'Parent', dm.currentPanel, ...
        'Units', 'normalized', ...
        'Position', [0, 0, 1, 1], ...
        'ColumnEditable', true(1, numel(this.allParameter)), ...
        'CellEditCallback', @tableChangeCallback...
    ));
    updateTable();
    dm.show();
    
    function updateMenu(i, value)
        switch (value)
            case {'parameter', 'problem'}
                set(handles(i).valueInput, 'Visible', 'on');
                handles(i).valueText.Visible = 'off';
            case {'scharParameter', 'scharProblem'}
                set(handles(i).valueInput, 'Visible', 'off');
                handles(i).valueText.Visible = 'on';
                handles(i).valueText.String = 'see below';
            case 'independent'
                set(handles(i).valueInput, 'Visible', 'off');
                handles(i).valueText.Visible = 'on';
                handles(i).valueText.String = '';
                
        end
        
        switch (value)
            case {'parameter', 'scharParameter'}
                    set(handles(i).lowerBoundInput, 'Visible', 'on');
                    set(handles(i).upperBoundInput, 'Visible', 'on');
            case {'problem', 'scharProblem', 'independent'}
                    set(handles(i).lowerBoundInput, 'Visible', 'off');
                    set(handles(i).upperBoundInput, 'Visible', 'off');
                
        end
        
        if (~isempty(table))
            updateTable();
        end
    end
    
    function updateTable(~, ~)
        this.adjustParameterDimensions();

        scharParam = this.allParameter.select(@(p)any(strcmpi(p.type, {'scharParameter', 'scharProblem'})));

        table.ColumnName = {scharParam.name};
        table.Data = [scharParam.value];
        tablePanel.Position(4) = dm.f.Position(4) * table.Extent(4);
        dm.adjustPositions();
    end

    function tableChangeCallback(~, event)
        scharParam = this.allParameter.select(@(p)any(strcmpi(p.type, {'scharParameter', 'scharProblem'})));
        p = scharParam(event.Indices(2));
        p.value(event.Indices(1)) = table.Data(event.Indices(1), event.Indices(2));
    end
end

