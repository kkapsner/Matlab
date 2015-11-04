function panel = getNamePanel(this, dm, panel)
    
    text = this.getNamePanelText();
    if (nargin < 3)
        panel = dm.addPanel(1);
        panel.UserData = 0;
        addText(text);
    else
        updateHorizontalPosition(dm.addButton(text, [panel.UserData, 0, 1], @openSubstack));
    end
    this.fillNamePanel(dm, panel, @addText);
    
    function addText(text)
        text = dm.addText(text, [panel.UserData, 0, 1]);
        updateHorizontalPosition(text);
    end
    function updateHorizontalPosition(element)
        element.Position(3) = element.Extent(3);
        panel.UserData = panel.UserData + element.Position(3);
    end
    function openSubstack(~,~)
        subDm = this.dialog();
        l = [
            addlistener(subDm, 'propertyChange', @(~,~)notify(dm, 'propertyChange'))
            addlistener(panel, 'ObjectBeingDestroyed', @removeListeners)
        ];
        function removeListeners(~,~)
            delete(l);
        end
    end
end

