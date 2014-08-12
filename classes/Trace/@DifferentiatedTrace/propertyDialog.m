function dm = propertyDialog(this)
    dm = DialogManager(this);
    
    dm.open();
    
    dm.addPanel(1, 'Differentiation settings');
    dm.addText('diff. window size', 100);
    dm.addPropertySlider( ...
        'differentiationWindowSize', 0, 20, {@(w)105, @(w)w-105} ...
    );
    
    dm.show();
end