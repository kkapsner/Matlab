function bindBackgroundColorToParent(element)
    parent = get(element, 'Parent');
    if (strcmp(get(parent, 'Type'), 'figure'))
        backgroundColor = 'Color';
    else
        backgroundColor = 'BackgroundColor';
    end
    l = [
        addlistener(parent, backgroundColor, 'PostSet', @setBackgroundColor)
        addlistener(element, 'ObjectBeingDestroyed', @removeListener)
        addlistener(parent, 'ObjectBeingDestroyed', @removeListener)
    ];
    setBackgroundColor();
    function setBackgroundColor(~,~)
        set(element, 'BackgroundColor', get(parent, backgroundColor));
    end
    function removeListener(~,~)
        delete(l);
    end
end