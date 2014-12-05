function adjustInnerStackContainerHeight(this)
    pos = get(this.handles.innerStackContainer, 'Position');
    pos(2) = pos(2) + pos(4);
    pos(4) = 0;
    for i = 1:numel(this.handles.stackPanels)
        panel = this.handles.stackPanels{i};
        pos(4) = pos(4) + panel.Position(4);
    end
    pos(2) = pos(2) - pos(4);
    set(this.handles.innerStackContainer, 'Position', pos);
end