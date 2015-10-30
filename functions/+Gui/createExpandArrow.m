function arrow = createExpandArrow(expandable, varargin)
%CREATEEXPANDARROW
    arrowMask = [
		0 0 1 1 1 1 1 1 1 1;
		0 0 0 0 1 1 1 1 1 1;
		0 0 0 0 0 0 1 1 1 1;
		0 0 0 0 0 0 0 0 1 1;
		0 0 0 0 0 0 0 0 0 0;
		0 0 0 0 0 0 0 0 0 0;
		0 0 0 0 0 0 0 0 1 1;
		0 0 0 0 0 0 1 1 1 1;
		0 0 0 0 1 1 1 1 1 1;
		0 0 1 1 1 1 1 1 1 1;
    ];
    arrow = handle(uicontrol( ...
        'Style', 'checkbox', ...
        varargin{:}...
    ));
    Gui.bindBackgroundColorToParent(arrow);
    arrow.Value = Gui.strToBoolean(expandable.Visible);
    
    addlistener(arrow, 'BackgroundColor', 'PostSet', @drawArrow);
    addlistener(arrow, 'Value', 'PostSet', @toggle);
    l = [
        addlistener(expandable, 'Visible', 'PostSet', @(~,~)set(arrow, 'Value', Gui.strToBoolean(expandable.Visible)))
        addlistener(arrow, 'ObjectBeingDestroyed', @removeListeners)
        addlistener(expandable, 'ObjectBeingDestroyed', @removeListeners)
    ];
    
    drawArrow();

    function drawArrow(varargin)
        mask = arrowMask;
        if (arrow.Value)
            mask = mask';
        end
        picture = zeros(10, 10, 3);
        picture(:, :, 1) = mask * arrow.BackgroundColor(1);
        picture(:, :, 2) = mask * arrow.BackgroundColor(2);
        picture(:, :, 3) = mask * arrow.BackgroundColor(3);
        arrow.CData = picture;
    end
    function toggle(varargin)
        drawArrow();
        expandable.Visible = Gui.booleanToStr(arrow.Value);
    end
    function removeListeners(varargin)
        delete(l);
    end
end

