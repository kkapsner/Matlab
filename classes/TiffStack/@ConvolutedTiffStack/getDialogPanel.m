function panel = getDialogPanel(this, dm, changeCallback)
%GETDIALOGPANEL
    panel = dm.addPanel(1);
    
    %% create filter control
    dm.addPropertyCheckbox('Filter on', 'filterOn', 70);
end

