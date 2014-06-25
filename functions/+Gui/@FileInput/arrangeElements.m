function arrangeElements(input)
    units = get(input.handles.container, 'Units');
    set(input.handles.container, 'Units', 'pixels');
    pos = get(input. handles.container, 'Position');
    set(input.handles.container, 'Units', units);
    
    set(input.handles.pathDisplay, 'Units', 'pixels');
    set(input.handles.selectButton, 'Units', 'pixels');
    
    width = pos(3);
    height = pos(4);
    
    if (width <= 50)
        set(input.handles.pathDisplay, 'Visible', 'off');
        set(input.handles.selectButton, 'Position', [0 0 width height]);
    else
        set(input.handles.pathDisplay, 'Visible', 'on');
        pathWidth = width - 30;
        set(input.handles.pathDisplay, 'Position', [0 0 pathWidth height]);
        set(input.handles.selectButton, 'Position', [0 pathWidth + 5 30 height]);
    end
end