function dialog(droplet)
    if (numel(droplet) == 1)
        f = figure();
        ax = axes('Parent', f);
        plot([droplet.intensity.max], 'Parent', ax);
    else
        error('Droplet:dialog:multipleDroplets', ...
            'Calling dialog on a Droplet array is not allowed.');
    end
    
    function displays = createMeanDisplays(parent)
        displays = struct();
        displays.container = uicontainer('Parent', parent);
    end

    function row = createTextValueRow(parent, text, value)
        row = struct();
        row.container = uicontainer('Parent', parent);
        row.text = uicontrol( ...
            'Parent', row.container, ...
            'Style', 'text', ...
            'String', text ...
        );
        row.value = uicontrol( ...
            'Parent', row.container, ...
            'Style', 'text', ...
            'String', sprintf('%.2f', value) ...
        );
    end

    function horizontalLayout(container)
        sizeChangeCallback();
        try
            addlistender(container, 'SizeChanged', @sizeChangeCallback);
        catch
            addlistender(container, 'SizeChange', @sizeChangeCallback);
        end
        function sizeChangeCallback(varargin)
            c = get(container, 'Children');
            
        end
    end
end     