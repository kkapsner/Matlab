function dm = propertyDialog(this, container)
    dm = DialogManager(this);
    
    dm.open([], container);
    
    dm.addPanel(1, 'Statistic settings');
    dm.addText('property', 80);
    dm.addPropertyPopupmenu( ...
        'operation', {'mean', 'std', 'mean + std', 'mean - std'}, ...
        {@(w)85, @(w)w - 85} ...
    );
    
    dm.show();
end