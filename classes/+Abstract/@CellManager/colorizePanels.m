function colorizePanels(this, startIndex)
    %COLORIZEPANEL
    if (~this.isOpen)
        return;
    end
    if (nargin < 2)
        startIndex = 1;
    end
    
    for idx = startIndex:numel(this.content)
        if (mod(idx, 2) == 0)
            this.handles.entryPanels{idx}.BackgroundColor = [0.8, 0.8, 0.8];
        else
            this.handles.entryPanels{idx}.BackgroundColor = [1, 1, 1];
        end
    end
end

