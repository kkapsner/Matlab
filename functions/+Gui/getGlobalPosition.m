function pos = getGlobalPosition(element)
% GETGLOBALPOSITION return the position of the element within the parent
% figure measured in pixels.
    pos = getPixelPos(element);
    isFigure = strcmp(get(element, 'Type'), 'figure');
    while (~isFigure)
        element = get(element, 'Parent');
        isFigure = strcmp(get(element, 'Type'), 'figure');
        if (~isFigure)
            ppos = getPixelPos(element);
            pos(1) = pos(1) + ppos(1);
            pos(2) = pos(2) + ppos(2);
        end
    end
    
    function ppos = getPixelPos(el)
        oldUnits = get(el, 'Units');
        set(el, 'Units', 'pixels');
        ppos = get(el, 'Position');
        set(el, 'Units', oldUnits);
    end
end