function dm = propertyDialog(this, container)
    dm = DialogManager(this);
    
    dm.open([], container);
    
    minTime = min(this.trace.time);
    maxTime = max(this.trace.time);
    
    dm.addPanel(2, 'Rescale settings');
    dm.addText('time factor', 80);
    dm.addPropertySlider( ...
        'timeFactor', 0, 3600, {@(w)85, @(w)w-125} ...
    );
    dm.addPropertyCheckbox( ...
        'inverse', 'isTimeFactorInverse', {@(w)w-40, @(w)40} ...
    );
    
    dm.newLine();
    dm.addText('value factor', 80);
    dm.addPropertySlider( ...
        'valueFactor', minTime, maxTime, {@(w)85, @(w)w-125} ...
    );
    dm.addPropertyCheckbox( ...
        'inverse', 'isValueFactorInverse', {@(w)w-40, @(w)40} ...
    );
    
    dm.show();
end