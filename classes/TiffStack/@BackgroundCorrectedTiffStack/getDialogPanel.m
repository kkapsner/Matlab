function panel = getDialogPanel(this, dm, handles)
%GETDIALOGPANEL
    panel = dm.addPanel(1);
    
    l = addlistener(this.backgroundStack, 'cacheCleared', @(~,~)handles.display.refreshImage());
    addlistener(dm, 'closeWin', @(~,~)delete(l));
    dm.addButton('open background', @(w)w, @openBackgroundStack);
    
    function openBackgroundStack(~,~)
        this.backgroundStack.dialog();
        
    end
end

