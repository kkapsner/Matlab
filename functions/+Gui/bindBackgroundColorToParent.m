function bindBackgroundColorToParent(element)
    parent = get(element, 'Parent');
    addlistener(parent, 'BackgroundColor', 'PostSet', @setBackgroundColor);
    setBackgroundColor();
    function setBackgroundColor(~,~)
        set(element, 'BackgroundColor', get(parent, 'BackgroundColor'));
    end
end