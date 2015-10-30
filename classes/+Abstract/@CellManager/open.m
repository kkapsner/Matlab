function open(this, parent)
    if (isfield(this.handles, 'figure') && ishandle(this.handles.figure))
        return;
    end
    
    this.handles = struct();
    
    mainPanel = false;
    openNewFigure = false;
    if (nargin < 2)
        width = 500;
        height = 400;

        if (isempty(this.title))
            title = 'Cell Manager';
        else
            title = this.title;
        end

        this.handles.figure = handle(figure( ...
            'NumberTitle', 'off', ...
            'Name', title, ...
            'HandleVisibility', 'off', ...
            'Color', 'w', ...
            'Position', [50, 50, width - 1, height], ...
            'CloseRequestFcn', @this.close, ...
            'Resize', 'on', ...
            'Menubar', 'none', ...
            'Toolbar', 'none' ...
        ));
        openNewFigure = true;
    else
        this.handles.figure = Gui.getParentFigure(parent);
        if (~strcmpi(get(parent, 'Type'), 'figure'))
            mainPanel = parent;
        end
    end
    
    if (ishandle(mainPanel))
        this.handles.mainPanel = mainPanel;
        addlistener(mainPanel, 'ObjectBeingDestroyed', @(~,~)this.resetHandles());
    else
        this.handles.mainPanel = handle(uipanel( ...
            'Parent', this.handles.figure, ...
            'Units', 'pixels', ...
            'BackgroundColor', this.handles.figure.Color, ...
            'HandleVisibility', 'callback', ...
            'BorderWidth', 0 ...
        ));
    
        try
            addlistener(this.handles.figure, 'SizeChanged', @(~,~)set(this.handles.mainPanel, 'Position', [0, 0, this.handles.figure.Position(3:4)]));
        catch
            addlistener(this.handles.figure, 'SizeChange', @(~,~)set(this.handles.mainPanel, 'Position', [0, 0, this.handles.figure.Position(3:4)]));
        end
    end
    
    this.handles.header = this.createHeader();
    [this.handles.outerContainer, this.handles.innerContainer, this.handles.innerAPI] = ...
        Gui.createScrollablePanel(this.handles.mainPanel);
    this.handles.outerContainer.BackgroundColor = this.handles.mainPanel.BackgroundColor;
    this.handles.entryPanels = {};
    
    try
        addlistener(this.handles.mainPanel, 'SizeChanged', @arrangeFigure);
    catch
        addlistener(this.handles.mainPanel, 'SizeChange', @arrangeFigure);
    end
    if (openNewFigure)
        try
            addlistener(this.handles.figure, 'SizeChanged', @(~,~)set(this.handles.mainPanel, 'Position', [0, 0, this.handles.figure.Position(3:4)]));
        catch
            addlistener(this.handles.figure, 'SizeChange', @(~,~)set(this.handles.mainPanel, 'Position', [0, 0, this.handles.figure.Position(3:4)]));
        end
        movegui(this.handles.figure, 'center');
        arrangeFigure();
        notify(this, 'winOpen');
    else
        arrangeFigure();
    end
    
    this.handles.entryPanels = cell(size(this.content));
    for idx = 1:numel(this.content)
        this.handles.entryPanels{idx} = this.addEntryPanel(this.content{idx});
    end
    this.colorizePanels();
    
    function arrangeFigure(~,~)
        oldUnits = this.handles.mainPanel.Units;
        this.handles.mainPanel.Units = 'pixels';
        pos = this.handles.mainPanel.Position;
        this.handles.header.Position = [ ...
            10, ...
            pos(4) - 10 - 30, ...
            pos(3) - 20, ...
            30 ...
        ];
        this.handles.outerContainer.Position = [ ...
            10, ...
            10, ...
            pos(3) - 20, ...
            pos(4) - 10 - 10 - 30 ...
        ];
        this.handles.mainPanel.Units = oldUnits;
    end
end