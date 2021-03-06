function [panel, getParameter] = getGUIParameterPanel(parent)
    panel = handle(uipanel( ...
        'Parent', parent, ...
        'BackgroundColor', get(parent, 'Color'), ...
        'BorderWidth', 0, ...
        'Units', 'pixels', ...
        'HandleVisibility', 'off' ...
    ));

    numChannelText = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'text', ...
        'String', 'channel number', ...
        'HandleVisibility', 'off' ...
    ));
    numChannelInput = handle(uicontrol( ...
        'Parent', panel, ...
        'Style', 'edit', ...
        'String', 1, ...
        'Value', 1, ...
        'HandleVisibility', 'off', ...
        'Callback', @(h,~)set(h, 'String', sprintf('%d', get(h, 'Value'))) ...
    ));
    addlistener(numChannelInput, 'String', 'PostSet', @adjustChannelSlider);
    function adjustChannelSlider(~,~)
        value = str2double(numChannelInput.String);
        if ~isnan(value)
            value = round(value);
            if (value <= 0)
                value = 1;
            end

            numChannelInput.Value = value;

%             channelInput.Value = min(channelInput.Value, value);
%             channelInput.Max = value + 0.1;
        end
    end

%     channelText = handle(uicontrol( ...
%         'Parent', panel, ...
%         'Style', 'text', ...
%         'String', 'channel', ...
%         'HandleVisibility', 'off' ...
%     ));
%     channelInput = handle(uicontrol( ...
%         'Parent', panel, ...
%         'Style', 'slider', ...
%         'Min', 1, ...
%         'Value', 1, ...
%         'Max', 1.1, ...
%         'SliderStep', [0.01, 0.1], ...
%         'HandleVisibility', 'off' ...
%     ));
%     Gui.addSliderContextMenu(channelInput);
%     addlistener(channelInput, 'Value', 'PostSet', @roundChannel);
%     function roundChannel(~,~)
%         channelInput.Value = round(channelInput.Value);
%     end
    
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
        numChannelText.Position = [0, lineHeight + 5, textWidth, lineHeight];
        numChannelInput.Position = [textWidth + 5, lineHeight + 5, controlWidth, lineHeight];
%         channelText.Position = [0, 0, textWidth, lineHeight];
%         channelInput.Position = [textWidth + 5, 0, controlWidth, lineHeight];
    end
    function param = readParameter()
        param = { ...
            numChannelInput.Value, ...
            1:numChannelInput.Value ...channelInput.Value ...
        };
    end
end
   