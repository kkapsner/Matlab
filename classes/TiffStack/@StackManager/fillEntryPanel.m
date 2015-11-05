function fillEntryPanel(this, stack, panel)
    try
        addlistener(panel, 'SizeChanged', @arrange);
    catch
        addlistener(panel, 'SizeChange', @arrange);
    end
    addlistener(panel, 'BackgroundColor', 'PostSet', @propagateColor);
    
    name = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'text', ...
        'BackgroundColor', panel.BackgroundColor, ...
        'HandleVisibility', 'off', ...
        'String', stack.char(), ...
        'HorizontalAlignment', 'left' ...
    ));

    l = [
        addlistener(stack, 'nameChanged', @refreshName)
        addlistener(panel, 'ObjectBeingDestroyed', @removeListener)
    ];
    function removeListener(~,~)
        delete(l);
    end
    
    inspectButton = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'pushbutton', ...
        'HandleVisibility', 'off', ...
        'String', 'inspect', ...
        'Callback', @inspect ...
    ));
    
    decorateButton = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'pushbutton', ...
        'HandleVisibility', 'off', ...
        'String', 'decorate', ...
        'Callback', @(~,~)this.addEntry(TiffStackDecorator.guiAddDecorator(stack)) ...
    ));
    
    removeButton = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'pushbutton', ...
        ...'BackgroundColor', panel.BackgroundColor, ...
        'HandleVisibility', 'off', ...
        'String', '-', ...
        'Callback', @(~,~)this.removeEntry(stack) ...
    ));
    
    arrange();

    function arrange(~,~)
        pos = panel.Position;
        name.Position = [ ...
            5, ...
            5, ...
            pos(3) - 10, ...
            pos(4) - 10 ...
        ];
        
        buttonHeight = 20;
        buttonY = (pos(4) - buttonHeight) / 2;
        
        inspectButton.Position = [ ...
            pos(3) - 5 - 20 - 5 - 50 - 5 - 50, ...
            buttonY, ...
            50, ...
            buttonHeight ...
        ];
        
        decorateButton.Position = [ ...
            pos(3) - 5 - 20 - 5 - 50, ...
            buttonY, ...
            50, ...
            buttonHeight ...
        ];
        
        removeButton.Position = [ ...
            pos(3) - 5 - 20, ...
            buttonY, ...
            20, ...
            buttonHeight ...
        ];
    end
    function propagateColor(~,~)
        name.BackgroundColor = panel.BackgroundColor;
%         removeButton.BackgroundColor = panel.BackgroundColor;
    end
    function refreshName(~,~)
        name.String = stack.char();
    end
    function inspect(~,~)
        stack.dialog();
    end
end