function adjustInnerContainerHeight(this)
    pos = get(this.handles.innerContainer, 'Position');
    pos(2) = pos(2) + pos(4);
    pos(4) = 0;
    for i = 1:numel(this.handles.entryPanels)
        panel = this.handles.entryPanels{i};
        pos(4) = pos(4) + panel.Position(4);
    end
    pos(2) = pos(2) - pos(4);
    set(this.handles.innerContainer, 'Position', pos);
end