function dm = propertyDialog(this, container)
    dm = DialogManager(this);
    
    dm.open([], container);
    
    dm.addPanel(1, 'Integration settings');
    dm.addText('constant', 80);
    dm.addPropertySlider( ...
        'integrationConstant', 0, 20, {@(w)85, @(w)w-85} ...
    );
    
    dm.show();
end