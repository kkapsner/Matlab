function panel = getDialogPanel(this, dm, handles)
%GETDIALOGPANEL
    panel = dm.addPanel(1);
    try
        addlistener(panel, 'SizeChanged', @resizeCallback);
    catch
        addlistener(panel, 'SizeChange', @resizeCallback);
    end
    
    
    %% create filter control
    handles.filterOn = dm.addPropertyCheckbox('Filter on', 'filterOn', 70);
    
    highestCutOff = max( ...
        [this.width, ...
        this.height, ...
        this.cutoffs(1), ...
        this.cutoffs(2)] ...
    );
    handles.lowCutOff = dm.addSlider(this.cutoffs(1), 0, highestCutOff, ...
        [75 0 155 20], @cutoffSliderCallback ...
    );
    handles.highCutOff = dm.addSlider(this.cutoffs(2), 0, highestCutOff, ...
        [240 0 155 20], @cutoffSliderCallback ...
    );

    dm.checkboxHides(handles.filterOn, [handles.lowCutOff, handles.highCutOff]);
    resizeCallback();
    
    %% callbacks
    function resizeCallback(varargin)
        s = get(panel, 'Position');
        width = (s(3) - 75 - 10) / 2;
        set(handles.lowCutOff, 'Position', [75, 0, width, 20]);
        set(handles.highCutOff, 'Position', [75 + width + 10, 0, width, 20]);
    end
    function cutoffSliderCallback(varargin)
        low = get(handles.lowCutOff, 'Value');
        high = get(handles.highCutOff, 'Value');
        
        this.setCutOffs([low high]);
        handles.update();
    end
end

