function panel = getDialogPanel(this, dm, changeCallback)
%GETDIALOGPANEL
    panel = dm.addPanel(1);
    addlistener(panel, 'SizeChange', @resizeCallback);
    
    %% create filter control
    handles.filterOn = dm.addPropertyCheckbox('Filter on', 'filterOn', 70);
    
    highestCutOff = max( ...
        [this.info(1).Width, ...
        this.info(1).Height, ...
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
        changeCallback();
    end
end

