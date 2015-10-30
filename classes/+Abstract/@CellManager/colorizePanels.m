function colorizePanels(this, startIndex, endIndex)
    %COLORIZEPANEL
    if (~this.isOpen)
        return;
    end
    if (nargin < 2 || isempty(startIndex))
        startIndex = 1;
    end
    if (nargin < 3 || isempty(endIndex))
        endIndex = numel(this.content);
    end
    
    for idx = startIndex:endIndex
        if (mod(idx, 2) == 0)
            this.handles.entryPanels{idx}.BackgroundColor = [0.8, 0.8, 0.8];
        else
            this.handles.entryPanels{idx}.BackgroundColor = [1, 1, 1];
        end
    end
end

