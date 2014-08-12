function dm = propertyDialog(this, container)
    dm = DialogManager(this);
    
    dm.open([], container);
    
    dm.addPanel(2, 'Shift settings');
    dm.addText('time shift', 80);
    dm.addPropertySlider( ...
        'timeShift', -1000, 1000, {@(w)85, @(w)w-85} ...
    );
    
    dm.newLine();
    dm.addText('value shift', 80);
    dm.addPropertySlider( ...
        'valueShift', -1000, 1000, {@(w)85, @(w)w-85} ...
    );
    
    dm.show();
end