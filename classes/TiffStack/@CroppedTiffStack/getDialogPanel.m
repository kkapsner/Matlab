function panel = getDialogPanel(this, dm, changeCallback)
%GETDIALOGPANEL
    panel = dm.addPanel(2);
    
    parentInfo = this.stack.info(1);
    dm.addText('x crop', 100);
    dm.addPropertySlider('xRange(1)', 1, parentInfo.Width, {@(w)100, @(w)(w-100)/2}, @(~)changeCallback());
    dm.addPropertySlider('xRange(2)', 1, parentInfo.Width, {@(w)(w-100)/2 + 100, @(w)(w-100)/2}, @(~)changeCallback());
    
    dm.newLine();
    dm.addText('y crop', 100);
    dm.addPropertySlider('yRange(1)', 1, parentInfo.Width, {@(w)100, @(w)(w-100)/2}, @(~)changeCallback());
    dm.addPropertySlider('yRange(2)', 1, parentInfo.Width, {@(w)(w-100)/2 + 100, @(w)(w-100)/2}, @(~)changeCallback());
end

