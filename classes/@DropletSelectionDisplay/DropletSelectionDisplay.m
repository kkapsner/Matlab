classdef DropletSelectionDisplay < handle
    %DROPLETSELECTIONDISPLAY generates a GUI interface to display
    %selections of droplets
    
    properties (SetObservable)
        selections = {}
        clickSelection = true
        currentImageIndex = 1
        currentStackIndex = 1
        
        currentColorIndex = 1;
        colors = [ ...
            1, 0, 0 ; ...
            0.7, 0.7, 0 ; ...
            0, 0.8, 0.2; ...
            0, 0, 1 ...
        ];
    end
    
    properties (SetAccess=private)
        droplets
        stacks
        dm
        
        handles
    end
    
    properties (Access=private)
        stackSize
        numStacks
        
        selectionCircles
        selectionTexts
    end
    
    methods
        function this = DropletSelectionDisplay(droplets)
            this.droplets = droplets;
            
            this.stacks = droplets(1).stacks;
            this.stackSize = this.stacks{this.currentStackIndex}.size;
            this.numStacks = numel(this.stacks);
            
            this.createDialogManager();
            
            this.refreshImage();
            this.displaySelections();
            
            addlistener(this, 'selections', 'PostSet', @(~,~)this.displaySelections());
            addlistener(this, 'currentImageIndex', 'PostSet', @(~,~)this.refreshImage());
            addlistener(this, 'currentStackIndex', 'PostSet', @(~,~)this.refreshImage());
        end
        
        function refreshImage(this)

            this.handles.display.currentImageIndex = this.currentImageIndex;
            this.handles.display.stack = this.stacks{this.currentStackIndex};
            
            this.displaySelections();
            set(get(this.handles.display.axes, 'Title'), 'String', sprintf('Image %i', this.currentImageIndex));
        
        end
    end
    
    methods (Access=private)
        function createDialogManager(this)
            this.dm = DialogManager(this);
            this.dm.width = 850;
            this.dm.height = 700;
            this.dm.open();
            
            this.dm.addPanel();
            
            this.handles.display = TiffStackDisplay(...
                this.dm.currentPanel, ...
                this.stacks{this.currentStackIndex}, ...
                this.currentImageIndex ...
            );


            set(this.handles.display.axes, ...
                'xlim', [0 this.stacks{this.currentStackIndex}.info(1).Height], ...
                'ylim', [0 this.stacks{this.currentStackIndex}.info(1).Width], ...
                'ButtonDownFcn', @this.axesClickCallback ...
            );
            set(this.handles.display.bwImage, 'ButtonDownFcn', @this.axesClickCallback);

            this.dm.addPanel(2);

            this.handles.playPause = this.dm.addButton('Play', [0, 0, 60, 20], @hPlayPauseCallback);
            this.handles.stop = this.dm.addButton('Stop', [60, 0, 60, 20], @stopVideo);

            this.handles.stackSelect = this.dm.addPopupmenu( ...
                cellfun(@(s)s.char(), this.stacks, 'UniformOutput', false), ...
                [135 0 200 20], ...
                @hStackSelectCallback ...
            );

            this.handles.numbersOn = this.dm.addCheckbox('display numbers', 0, ...
                [340 0 100 20], @(~,~)this.displaySelections() ...
            );
            
            this.handles.export = this.dm.addButton('export data', [445 0 70 20], ...
                @exportData ...
            );
            addlistener(this, 'selections', 'PostSet', @updateExportDataEnable);
            updateExportDataEnable();
            
            
            this.handles.exportSelection = this.dm.addButton('export selection', [520 0 90 20], ...
                @exportSelection ...
            );
            
            this.handles.selectAll = this.dm.addButton('select all', [615 0 70 20], ...
                @selectAll ...
            );
            addlistener(this, 'selections', 'PostSet', @updateSelectAllText);
            
            this.handles.addAllInCurrentFrame = this.dm.addButton('select current', [690, 0, 70, 20], ...
                @addAllInCurrentFrame ...
            );
        
            addlistener(this, 'clickSelection', 'PostSet', @updateManualSelectVisible);

            this.dm.newLine();
            this.handles.position = this.dm.addSlider(1, this.currentImageIndex, this.stackSize, 0, @hPositionCallback);
            addlistener(this, 'currentImageIndex', 'PostSet', @updatePosition);
            
            this.dm.show();
            
            % video callbacks
            
            function hPlayPauseCallback(~, ~)
                if (stopped)
                   playVideo();
                else
                    pauseVideo();
                end
            end
            
            stopped = true;
            function stopVideo(~,~)
                pauseVideo();
                this.currentImageIndex = 1;
            end

            function pauseVideo(~,~)
                stopped = true;
                set(this.handles.playPause, 'String', 'Play');
            end

            function playVideo(~,~)
                stopped = false;
                set(this.handles.playPause, 'String', 'Pause');

                for i = this.currentImageIndex:this.stackSize
                    if (~ishandle(this.handles.display) || stopped)
                        break;
                    end
                    
                    this.currentImageIndex = i;

                    drawnow();
                    pause(0.001);
                end
                pauseVideo();
            end


            
            % stack select callbacks
            function hStackSelectCallback(~, ~)
                this.currentStackIndex = this.handles.stackSelect.Value;
            end
            
            % "select all" callbacks
            function selectAll(~, ~)
                if (numel(this.selections) && any(this.selections{1}))
                    this.selections = {false(size(this.droplets))};
                else
                    this.selections = {true(size(this.droplets))};
                end
            end
            
            function updateSelectAllText(~, ~)
                if (numel(this.selections) && any(this.selections{1}))
                    this.handles.selectAll.String = 'select none';
                else
                    this.handles.selectAll.String = 'select all';
                end
            end
            
            function updateManualSelectVisible(~, ~)
                if (this.clickSelection)
                    this.handles.selectAll.Visible = 'on';
                    this.handles.addAllInCurrentFrame.Visible = 'on';
                else
                    this.handles.selectAll.Visible = 'off';
                    this.handles.addAllInCurrentFrame.Visible = 'off';
                end
            end
            
            % select current callbacks
            
            function addAllInCurrentFrame(~, ~)
                radii = [this.droplets.radius];
                currentRadius = radii(this.currentImageIndex, :);
                current = ~isnan(currentRadius);
                
                if (numel(this.selections) == 0)
                    this.selections = {current};
                else
                    this.selections{1} = this.selections{1} | current;
                end
            end
            
            % export data callbacks
            function exportData(~, ~)
                for i = 1:numel(this.selections)
                    s = this.selections{i};
                    if (~isempty(s))
                        this.droplets(s).guiExport();
                    end
                end
            end
            
            function updateExportDataEnable(~, ~)
                if (~isempty(this.selections) && any(cellfun(@(s)any(s), this.selections)))
                   this.handles.export.Enable = 'on';
                else
                    this.handles.export.Enable = 'off';
                end
                    
            end
            
            % export selection callbacks
            function exportSelection(~, ~)
                for i = 1:numel(this.selections)
                    selection = this.droplets(this.selections{i});
                    if (~isempty(selection))
                        assignin('base', sprintf('dropletSelection_%d', i), selection);
                    end
                end
            end
            
            % position callbacks
            function hPositionCallback(~, ~)
                newIndex = round(this.handles.position.Value);
                if (newIndex ~= this.currentImageIndex)
                    this.currentImageIndex = newIndex;
                end
            end

            function updatePosition(~, ~)
                if (this.currentImageIndex ~= this.handles.position.Value)
                    this.handles.position.Value = this.currentImageIndex;
                end
            end
        end
        
        function displaySelections(this)
            if (~isempty(this.selectionCircles))
                delete(this.selectionCircles);  
                this.selectionCircles = [];
            end
            if (~isempty(this.selectionTexts))
                delete(this.selectionTexts);
                this.selectionTexts = [];
            end
            hold(this.handles.display.axes, 'on');
            
            index = this.currentImageIndex;
            
            for selectionIndex = 1:numel(this.selections)
                selection = this.selections{selectionIndex};
                if (any(selection))
                    this.currentColorIndex = ...
                        mod(selectionIndex - 1, size(this.colors, 1)) + 1;

                    selectedDroplets = this.droplets(selection);
                    p = [selectedDroplets.p];
                    p = p(index, :);
                    radius = [selectedDroplets.radius];
                    radius = radius(index, :);
                    this.selectionCircles = [ ...
                        this.selectionCircles, ...
                        this.plotCircles(p(1:2:end), p(2:2:end), radius) ...
                    ];

                    if (get(this.handles.numbersOn, 'Value'))
                        selectedIndices = find(selection);
                        for dropletIndex = selectedIndices
                            d = this.droplets(dropletIndex);
                            if (~isnan(d.radius(index)))
                                x = d.p(index, 1);
                                y = d.p(index, 2);
                                this.selectionTexts(end + 1) = ...
                                    text(x, y, sprintf('%d', dropletIndex), ...
                                        'Parent', this.handles.display.axes, ...
                                        'Color', this.getColor(), ...
                                        'Hit', 'off' ...
                                    );
                            end
                        end
                    end
                end
            end
            
            hold(this.handles.display.axes, 'off');
            
        end
        
        function color = getColor(this)
            color = this.colors(this.currentColorIndex, :);
        end
        
        function h = plotCircles(this, xs, ys, rs)
            X = [];
            Y = [];
            for i = 1:numel(xs)
                r = rs(i);
                if (~isnan(r))
                    x = xs(i);
                    y = ys(i);
                    phi = (0:(4*r + 1))/(2*r)*pi;
                    x = x + r * sin(phi);
                    y = y + r * cos(phi);
                    X = [X, NaN, x];
                    Y = [Y, NaN, y];
                end
            end
            
            h = plot( ...
                X, Y, '-', ...
                'Color', this.getColor(), ...
                'Parent', this.handles.display.axes, ...
                'Hit', 'off' ...
            );
        end

    end
    
    methods (Access=private)
        function axesClickCallback(this, ~, ~)
            if (this.clickSelection)
                pos = this.handles.display.getCurrentPoint();
                pos = pos(1, 1:2);
                idx = this.droplets.findDroplet(pos, this.currentImageIndex);

                if (~isempty(idx) && idx ~=0)
                    if (numel(this.selections))
                        oldSelection = this.selections{1};
                    else
                        oldSelection = false(size(this.droplets));
                    end
                    
                    newSelection = false(size(this.droplets));
                    newSelection(idx) = true;
                    switch (get(this.dm.f, 'SelectionType'))
                        case 'normal'

                        case {'extend', 'alt'}
                            newSelection = xor(newSelection, oldSelection);
                        otherwise
                    end

                    this.selections{1} = newSelection;
                end
            end
        end
    end
end

