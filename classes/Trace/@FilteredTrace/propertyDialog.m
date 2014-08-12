function dm = propertyDialog(this, container)
    dm = DialogManager(this);
    
    dm.open([], container);
    
    dm.addPanel(2, 'Filter settings');
    dm.addText('Type', 40);
    dm.addPropertyPopupmenu( ...
        'filterType', {'gauss', 'median', 'average', 'none'}, {@(w)45, @(w)w-45} ...
    );
    dm.newLine();
    dm.addText('Value', 40);
    dm.addPropertySlider( ...
        'filterValue', 0, max(this.time) / 4, {@(w)45, @(w)w-45} ...
    );
    
    dm.show();
end