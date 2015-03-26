function panel = getDialogPanel(this, dm, ~)
%GETDIALOGPANEL
    panel = dm.addPanel(1);
    
    %% create filter control
    dm.addPropertyCheckbox('Filter on', 'filterOn', 70);
end

