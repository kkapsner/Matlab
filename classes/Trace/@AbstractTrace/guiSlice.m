function [tr, times] = guiSlice(this, title)
    startTime = min(cellfun(@min, {this.time}));
    endTime = max(cellfun(@max, {this.time}));
    
    if (nargin < 2)
        title = [];
    end
    
    dm = DialogManager(this);
    dm.open(title);
    dm.addPanel();
    
    set(dm.getFigure(), 'Toolbar', 'figure');
    
    ax = axes( ...
        'Parent', dm.currentPanel, ...
        'Units', 'normalized', ...
        'OuterPosition', [0, 0, 1, 1] ...
    );
    this.plot('Parent', ax);
    
    yLim = get(ax, 'YLim');
    gray = handle(patch( ...
        [startTime([1; 1; 1; 1]), endTime([1; 1; 1; 1])], ...
        yLim([1, 1; 2, 2; 2, 2; 1, 1]), ...
        [0, 0, 0], ...
        'Parent', ax, ...
        'FaceAlpha', 0.1, ...
        'HitTest', 'off', ...
        'YLimInclude', 'off', ...
        'XLimInclude', 'off', ...
        'ZLimInclude', 'off'...
    ));
    
    startLine = Gui.imvline(ax, startTime);
    endLine = Gui.imvline(ax, endTime);
    
    startLine.positionConstraintFcn = @(p)min(max(p, startTime), endLine.position);
    endLine.positionConstraintFcn = @(p)min(max(p, startLine.position), endTime);
    
    addlistener(startLine, 'newPosition', @updateStartGray);
    addlistener(endLine, 'newPosition', @updateEndGray);
    
    dm.show();
    
    dm.wait();
    
    tr = this.slice(startLine.position, endLine.position);
    times = [startLine.position, endLine.position];
    
    function updateStartGray(~,~)
        gray.XData(3:4, 1) = startLine.position;
    end
    function updateEndGray(~,~)
        gray.XData(3:4, 2) = endLine.position;
    end
end