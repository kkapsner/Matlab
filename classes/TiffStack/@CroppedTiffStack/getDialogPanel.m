function panel = getDialogPanel(this, dm, changeCallback)
%GETDIALOGPANEL
    panel = dm.addPanel(2);
    
    dm.addText('x crop', 100);
    dm.addPropertySlider('xRange(1)', 1, this.stack.width, {@(w)100, @(w)(w-100)/2}, @(~)changeCallback());
    dm.addPropertySlider('xRange(2)', 1, this.stack.width, {@(w)(w-100)/2 + 100, @(w)(w-100)/2}, @(~)changeCallback());
    
    dm.newLine();
    dm.addText('y crop', 100);
    dm.addPropertySlider('yRange(1)', 1, this.stack.height, {@(w)100, @(w)(w-100)/2}, @(~)changeCallback());
    dm.addPropertySlider('yRange(2)', 1, this.stack.height, {@(w)(w-100)/2 + 100, @(w)(w-100)/2}, @(~)changeCallback());
end

