function header = createHeader(this)
    header = handle(uipanel( ...
        'Parent', this.handles.mainPanel, ...
        'Units', 'pixels', ...
        'BackgroundColor', this.handles.mainPanel.BackgroundColor, ...
        'HandleVisibility', 'callback', ...
        'BorderWidth', 0 ...
    ));
    try
        addlistener(header, 'SizeChanged', @arrange);
    catch
        addlistener(header, 'SizeChange', @arrange);
    end

    text = handle(uicontrol( ...
        'Parent', header, ...
        'HandleVisibility', 'off', ...
        'BackgroundColor', header.BackgroundColor, ...
        'Style', 'text', ...
        'String', 'Stacks', ...
        'HorizontalAlignment', 'left' ...
    ));
    decorateAllStacks = handle(uicontrol( ...
        'Parent', header, ...
        'HandleVisibility', 'off', ...
        'Visible', 'off', ...
        'Style', 'pushbutton', ...
        'String', 'decorate all', ...
        'Callback', @(~,~)this.addEntry(TiffStackDecorator.guiAddDecorator(this.stacks)) ...
    ));
    calculateStacks = handle(uicontrol( ...
        'Parent', header, ...
        'HandleVisibility', 'off', ...
        'Visible', 'off', ...
        'Style', 'pushbutton', ...
        'String', 'calculate', ...
        'Callback', @(~,~)this.addEntry(CalculationTiffStack.guiCalculate(this.stacks)) ...
    ));
    this.handles.stackListener = [
        addlistener(this, 'content', 'PostSet', @setVisibility)
        addlistener(this, 'reset', @(~,~)delete(this.handles.stackListener))
    ];
    addEntry = handle(uicontrol( ...
        'Parent', header, ...
        'HandleVisibility', 'off', ...
        'Style', 'pushbutton', ...
        'String', '+', ...
        'Callback', @(~,~)this.addEntry(this.createEntry()) ...
    ));

    function arrange(~,~)
        pos = header.Position;
        text.Position = [5, 5, pos(3) - 10, pos(4) - 10];

        decorateAllStacks.Position = [ ...
            pos(3) - 25 - 55 - 75, ...
            (pos(4) - 20 ) / 2, ...
            70, ...
            20 ...
        ];
        calculateStacks.Position = [ ...
            pos(3) - 25 - 55, ...
            (pos(4) - 20 ) / 2, ...
            50, ...
            20 ...
        ];
        addEntry.Position = [ ...
            pos(3) - 25, ...
            (pos(4) - 20 ) / 2, ...
            20, ...
            20 ...
        ];
    end
    function setVisibility(~,~)
        if (numel(this.stacks) >= 1)
            decorateAllStacks.Visible = 'on';
        else
            decorateAllStacks.Visible = 'off';
        end
        if (numel(this.stacks) >= 2)
            calculateStacks.Visible = 'on';
        else
            calculateStacks.Visible = 'off';
        end
    end
end
