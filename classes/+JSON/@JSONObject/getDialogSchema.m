function dlgstruct = getDialogSchema(this, name) %#ok
% GETDIALOGSCHEMA

keys = this.keys();
dlgstruct = [];
if(isempty(keys)); return; end;

widget1.Type = 'textbrowser';
widget1.MinimumSize = [600 600];
widget1.Tag = 'widget1';
widget1.Text = strjoin(keys, ',');

dlgstruct.DialogTitle = 'test';%DAStudio.message('FixedPoint:fixedPointTool:resultreportTitle');
dlgstruct.StandaloneButtonSet  = {'OK'};
dlgstruct.CloseCallback  = 'me = fxptui.getexplorer;me.getaction(''VIEW_AUTOSCALEINFO'').on = ''off'';';
dlgstruct.LayoutGrid  = [1 1];
dlgstruct.RowStretch = 1;
dlgstruct.ColStretch = 1;
dlgstruct.Items = {widget1};
end

