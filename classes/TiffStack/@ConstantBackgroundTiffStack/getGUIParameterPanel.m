function [panel, getParameter] = getGUIParameterPanel(parent)
    
    panel = handle(uipanel( ...
        'Parent', parent, ...
        'BackgroundColor', get(parent, 'Color'), ...
        'Units', 'pixels', ...
        'BorderWidth', 0, ...
        'HandleVisibility', 'off' ...
    ));

    methodText = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'text', ...
        'String', 'method', ...
        'HandleVisibility', 'off' ...
    ));
    method = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'popupmenu', ...
        'Value', 1, ...
        'String', ConstantBackgroundTiffStack.knownMethods, ...
        'HandleVisibility', 'off' ...
    ));
    backgroundText = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'text', ...
        'String', 'background', ...
        'HandleVisibility', 'off' ...
    ));
    backgroundValue = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'slider', ...
        'Min', 0, ...
        'Value', 0, ...
        'Max', 1, ...
        'SliderStep', [0.01, 0.1], ...
        'HandleVisibility', 'off' ...
    ));
    Gui.addSliderContextMenu(backgroundValue);
    
    try
        addlistener(panel, 'SizeChanged', @arrange);
    catch
        addlistener(panel, 'SizeChange', @arrange);
    end

    getParameter = @readParameter;
    function arrange(~,~)
        pos = panel.Position;
        lineHeight = (pos(4) - 5) / 2;
        textWidth = 80;
        controlWidth = pos(3) - textWidth - 5;
        methodText.Position = [0, lineHeight + 5, textWidth, lineHeight];
        method.Position = [textWidth + 5, lineHeight + 5, controlWidth, lineHeight];
        backgroundText.Position = [0, 0, textWidth, lineHeight];
        backgroundValue.Position = [textWidth + 5, 0, controlWidth, lineHeight];
    end
    function param = readParameter()
        param = { ...
            ConstantBackgroundTiffStack.knownMethods{method.Value}, ...
            backgroundValue.Value ...
        };
    end
end