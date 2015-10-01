function dm = propertyDialog(this, container)
    dm = DialogManager(this);
    
    dm.open([], container);
    
    dm.addPanel(1, 'Function');
    dm.addText(char(this.func));
    dm.show();
end