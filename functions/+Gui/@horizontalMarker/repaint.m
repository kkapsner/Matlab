function repaint(obj)
%REPAINT 
    
    if (~isfield(obj.controls, 'panel'))
        return;
    end
    pDim = obj.getControlProperty('panel', 'Position');
%     pDim = get(obj.controls.panel, 'Position');
    if (isempty(pDim))
        return;
    end
    
    width = pDim(3);
    height = pDim(4);

    fLine = lineVisible(1);
    sLine = lineVisible(2);

    lineHeight = height / (fLine + sLine);

    if (fLine)
        iDim = obj.getControlProperty('valueInput', 'Position');
        iDim(1) = 1 + (width - iDim(3)) / 2;
        iDim(2) = 1 + lineHeight * sLine + (lineHeight - iDim(4)) / 2;
        obj.setControlProperty('valueInput', 'Position', iDim);
    end

    if (sLine)
        margin = 5;
        x = [1 0];
        if (Gui.isVisible(obj.controls.minInput))
            iDim = obj.getControlProperty('minInput', 'Position');
            iDim(1) = x(1);
            iDim(2) = 1 + (lineHeight - iDim(4)) / 2;
            obj.setControlProperty('minInput', 'Position', iDim);
            x(1) = margin + iDim(1) + iDim(3);
        end
        if (Gui.isVisible(obj.controls.maxInput))
            iDim = obj.getControlProperty('maxInput', 'Position');
            iDim(1) = 1 + width - iDim(3);
            iDim(2) = 1 + (lineHeight - iDim(4)) / 2;
            obj.setControlProperty('maxInput', 'Position', iDim);
            x(2) = margin + iDim(3);
        end
        if (Gui.isVisible(obj.controls.slider))
            iDim = obj.getControlProperty('slider', 'Position');
            iDim(1) = x(1);
            iDim(2) = 1 + (lineHeight - iDim(4)) / 2;
            iDim(3) = width - x(1) - x(2);
            obj.setControlProperty('slider', 'Position', iDim);
        end
    end
    
    
    function isV = lineVisible(index)
        switch index
            case 1
                isV = Gui.isVisible(obj.controls.valueInput);
            case 2
                isV = ...
                    Gui.isVisible(obj.controls.minInput) | ...
                    Gui.isVisible(obj.controls.slider) | ...
                    Gui.isVisible(obj.controls.maxInput);
        end
    end
end

