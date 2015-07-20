function panel = getNamePanel(stack, dm, panel)
%CHAR cast function to char
    if (nargin < 3)
        panel = dm.addPanel(1);
        panel.UserData = 0;
        addText(class(stack));
    else
        updateHorizontalPosition(dm.addButton(class(stack), [panel.UserData, 0, 1], @(~,~)stack.dialog()));
    end
    addText('<');
    stack.stack.getNamePanel(dm, panel);
    addText('>');
    
    function addText(text)
        text = dm.addText(text, [panel.UserData, 0, 1]);
        updateHorizontalPosition(text);
    end
    function updateHorizontalPosition(element)
        element.Position(3) = element.Extent(3);
        panel.UserData = panel.UserData + element.Position(3);
    end
end

