function dm = inspectFilteredProperties(this, referenceTrace)
    if (nargin < 2)
        referenceTrace = this.trace;
    end
    
    dm = DialogManager(this);
    dm.open();
    
    dm.addPanel(2);
    valueName = dm.addPopupmenu({'Noise', 'first derivative', 'second derivative'}, 1, 0, @update);
    dm.newLine();
    name = dm.addTitle('Noise');
    
    dm.addPanel();
    ax = handle(axes( ...
        'Parent', dm.currentPanel, ...
        'Units', 'normalize', ...
        'OuterPosition', [0, 0, 1, 1] ...
    ));
    noiseLine = handle(plot(0, 0, 'Parent', ax));
    dm.addPanel(2);
    dm.addText('Mean', 40);
    meanValue = dm.addText('a', [40, 0, 100]);
    
    dm.addText('Std', [140, 0, 40]);
    stdValue = dm.addText('a', [280, 0, 100]);
    
    dm.newLine();
    dm.addText('Min', 40);
    minValue = dm.addText('a', [40, 0, 100]);
    
    dm.addText('Max', [140, 0, 40]);
    maxValue = dm.addText('a', [280, 0, 100]);
    
    l = addlistener(this, 'change', @update);
    addlistener(dm, 'closeWin', @(~,~) delete(l));
    update();
    
    dm.show();
    
    function update(~,~)
        switch (valueName.Value)
            case 1
                value = referenceTrace.value - this.value;
            case 2
                value = gradient(this.value);
            case 3
                value = gradient(gradient(this.value));
        end
        name.String = valueName.String{valueName.Value};
        
        meanValue.String = sprintf('%.2e', mean(value));
        stdValue.String = sprintf('%.2e', std(value));
        minValue.String = sprintf('%.2e', min(value));
        maxValue.String = sprintf('%.2e', max(value));
        
        noiseLine.xData = this.time;
        noiseLine.YData = value;
    end
end