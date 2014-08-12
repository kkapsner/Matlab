function dm = propertyDialog(this, container)
    dm = DialogManager(this);
    
    dm.open([], container);
    
    minTime = min(this.trace.time);
    maxTime = max(this.trace.time);
    
    dm.addPanel(2, 'Slice settings');
    dm.addText('start', 40);
    dm.addPropertySlider( ...
        'startTime', minTime, maxTime, {@(w)45, @(w)w-45} ...
    );
    dm.newLine();
    dm.addText('end', 40);
    dm.addPropertySlider( ...
        'endTime', minTime, maxTime, {@(w)45, @(w)w-45} ...
    );
    
    dm.show();
end