function arrangeStackContainer(this)
    pos = this.handles.innerStackContainer.Position;

    y = pos(4);
    for i = 1:numel(this.handles.stackPanels)
        panel = this.handles.stackPanels{i};
        pPos = panel.Position;
        y = y - pPos(4);
        panel.Position = [ ...
            0, ...
            y, ...
            pos(3), ...
            pPos(4) ...
        ];
        if (mod(i, 2) == 0)
            panel.BackgroundColor = [0.8, 0.8, 0.8];
        else
            panel.BackgroundColor = [1, 1, 1];
        end
    end
end

