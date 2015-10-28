function panel = getDialogPanel(this, dm, handles)
%GETDIALOGPANEL
    panel = dm.addPanel(1);
    try
        addlistener(panel, 'SizeChanged', @resizeCallback);
    catch
        addlistener(panel, 'SizeChange', @resizeCallback);
    end
    
    
    dm.addText('Method', 70);
    handles.method = dm.addPropertyPopupmenu('method', this.knownMethods, [70, 0, 70], @methodCallback);
    handles.backgroundValue = dm.addPropertySlider('backgroundValue', 0, 1, [145, 0, 100]);
    methodCallback();
    resizeCallback();
    
    %% callbacks
    function resizeCallback(varargin)
        s = get(panel, 'Position');
        width = (s(3) - 145 - 10);
        set(handles.backgroundValue, 'Position', [145, 0, width, 20]);
    end
    function methodCallback(varargin)
        if (strcmp(this.knownMethods{get(handles.method, 'Value')}, 'fixed'))
            set(handles.backgroundValue, 'Visible', 'on');
        else
            set(handles.backgroundValue, 'Visible', 'off');
        end
    end
end