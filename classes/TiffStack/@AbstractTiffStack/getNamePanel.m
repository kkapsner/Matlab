function panel = getNamePanel(this, dm, panel)
    
    text = this.getNamePanelText();
    if (nargin < 3)
        panel = dm.addPanel(1);
        panel.UserData = 0;
        textElement = addText(text);
    else
        textElement = dm.addButton(text, [panel.UserData, 0, 1], @openSubstack);
        updateHorizontalPosition(textElement);
    end
    l = [
        addlistener(this, 'nameChanged', @updateName)
        addlistener(textElement, 'ObjectBeingDestroyed', @removeListeners)
    ];
    this.fillNamePanel(dm, panel, @addText);
    
    function element = addText(text)
        element = dm.addText(text, [panel.UserData, 0, 1]);
        updateHorizontalPosition(element);
    end
    function element = updateHorizontalPosition(element)
        element.Position(3) = element.Extent(3);
        panel.UserData = panel.UserData + element.Position(3);
    end
    function updateName(~,~)
        textElement.String = this.getNamePanelText();
    end
    function openSubstack(~,~)
        subDm = this.dialog();
        lSub = [
            addlistener(subDm, 'propertyChange', @(~,~)notify(dm, 'propertyChange'))
            addlistener(panel, 'ObjectBeingDestroyed', @removeSubListeners)
        ];
        function removeSubListeners(~,~)
            delete(lSub);
        end
    end
    function removeListeners(~,~)
        delete(l);
    end
end