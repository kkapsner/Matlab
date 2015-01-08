function dm = dialog(this, selectionDisplay)
%DROLET.DIALOG diplays the droplet within its stacks
    
    if (~numel(this))
        % no droplets to show - so don't show anything.
        return;
    end
    
    if (nargin < 2)
        selectionDisplay = DropletSelectionDisplay(this);
    end
    stacks = this(1).stacks;
    
    % video control variables
    currentIndex = 1;
    numStacks = numel(stacks);
    stackSize = stacks{1}.size;
    
    % set up interface
    dm = selectionDisplay.dm;
    
    handles = struct();
    handles.timeCourse = createTimeCourseWindow();
    
    addlistener(selectionDisplay, 'selections', 'PostSet', @(~,~)plotIntensities());
    
    %% interface build functions
    
    function handles = createTimeCourseWindow()
        handles.dm = DialogManager(this);
        handles.dm.dependsOn(selectionDisplay.dm);
        handles.dm.open();
        handles.figure = handles.dm.getFigure();
        set(handles.figure, 'ToolBar', 'figure');
        handles.dm.addPanel();
        handles.axes = axes( ...
            'Parent', handles.dm.currentPanel, ...
            'Units', 'normalized', ...
            'OuterPosition', [0, 0, 1, 1], ...
            'HandleVisibility', 'callback' ...
        );
        handles.resetMaxZoom = Gui.enableWheelZoom(handles.axes, [false, true, false]);
        hold(handles.axes, 'on');
        
        handles.dm.addPanel(1);
        handles.dm.addText('value to display:', [5 0 80 20]);
        handles.displayTypeSelect = handles.dm.addPopupmenu( ...
            { ...
                'max intensity', 'min intensity', ...
                'intensity sum', 'mean intensity', ...
                'bright intensity', 'mean bright intensity', ...
                'position', 'radius'}, ...
            [90 0 100 20], ...
            @(~,~)plotIntensities() ...
        );
        
        handles.dm.addText('intensity to display:', [200 0 100 20]);
        handles.displayIntensity = handles.dm.addPopupmenu( ...
            [cellfun(@(s)s.char(), stacks(2:end), 'UniformOutput', false), 'all'], ...
            [300 0 150 20], ...
            @(~,~)plotIntensities() ...
        );
        
        handles.restrictSelection = handles.dm.addButton( ...
            'restrict selection', ...
            [450 0 40 60], ...
            @restrictSelection ...
        );
        
        handles.vline = Gui.imvline(handles.axes, currentIndex);
        handles.vline.positionConstraintFcn = @constrainToImageIndex;
        addlistener(handles.vline, 'newPosition', @vlineCallback);
        addlistener(selectionDisplay, 'currentImageIndex', 'PostSet', @updateVline);
        
        handles.dm.show();
        
        function a = constrainToImageIndex(a)
            if (a < 1)
                a = 1;
            elseif (a > stackSize)
                a = stackSize;
            else
                a = round(a);
            end
        end
        function vlineCallback(~,~)
            selectionDisplay.currentImageIndex = round(handles.vline.position);
        end
        function updateVline(~,~)
            if (ishandle(handles.figure))
                handles.vline.position = selectionDisplay.currentImageIndex;
            end
        end
        
        function restrictSelection(~,~)
            if (~isempty(selectionDisplay.selections))
                selection = selectionDisplay.selections{1};
                if (any(selection))
                    [~, ~, filter] = this(selection).guiSelect( ...
                        @(d)getDisplayValues(d, selectionDisplay.currentImageIndex), ...
                        false, ...
                        true ...
                    );
                    selection(selection) = filter;
                    selectionDisplay.selections{1} = selection;
                end
            end
        end
    end
    
    lineH = [];
    lastSelection = false(size(this));
    function displayValues = getDisplayValues(droplets, index)
        displayType = get(handles.timeCourse.displayTypeSelect, 'value');
        switch displayType
            case 1
                displayValues = [droplets.maxIntensity];
%                 displayValues = displayValues(:, 1:2:end);
%                 displayValues = displayValues ./ (ones(size(displayValues, 1), 1) * mean(displayValues(end-50:end,:)));
            case 2
                displayValues = [droplets.minIntensity];
            case 3
                displayValues = [droplets.intensitySum];
            case 4
                displayValues = [droplets.intensitySum] ./ (pi .* [droplets.radius] .^ 2);
            case 5
                displayValues = [droplets.brightIntensitySum];
            case 6
                displayValues = [droplets.brightIntensitySum] ./ [droplets.brightArea];
            case 7
                p = [droplets.p];
                lineH = plot( ...
                    p(:, 1:2:end), p(:, 2:2:end), ...
                    'Parent', handles.timeCourse.axes ...
                );

                handles.timeCourse.vline.drawApi.setReorderListener();
                displayValues = [];
                return;
            case 8
                displayValues = [droplets.radius];
        end
        if (displayType < 7)
            intensityIdx = ...
                get(handles.timeCourse.displayIntensity, 'value');
            if (intensityIdx ~= numStacks)
                displayValues = ...
                    displayValues(:, intensityIdx:(numStacks - 1):end);
            end
        end
        
        if (nargin > 1)
            displayValues = displayValues(index, :);
        end
    end
    function plotIntensities()
        if (ishandle(handles.timeCourse.figure))
            if (numel(selectionDisplay.selections))
                selectionChanged = any(lastSelection ~= selectionDisplay.selections{1});
                lastSelection = selectionDisplay.selections{1};
            else
                selectionChanged = true;
            end
            if (selectionChanged)
                if (~isempty(lineH));
                    delete(lineH);
                    lineH = [];
                end
                if (numel(selectionDisplay.selections) && any(selectionDisplay.selections{1}))
                    handles.timeCourse.vline.drawApi.removeReorderListener();

                    d = this(selectionDisplay.selections{1});
                    dropletNumbers = find(selectionDisplay.selections{1});
                    displayValues = getDisplayValues(d);
                    set(handles.timeCourse.axes, 'XLimMode', 'auto', 'YLimMode', 'auto');
                    if (get(handles.timeCourse.displayTypeSelect, 'value') == 7)
                        handles.timeCourse.resetMaxZoom();
                        return;
                    end
                    if (~isempty(displayValues))
                        
                        set(handles.timeCourse.axes, 'ColorOrderIndex', 1);
                        lineH = plot( ...
                            displayValues, ...
                            'Parent', handles.timeCourse.axes ...
                        );
                        % proper legend entries
                        for idx = 1:numel(lineH)
                            set( ...
                                lineH(idx), ...
                                'DisplayName', ...
                                sprintf('Droplet %d', dropletNumbers(idx)), ...
                                'ButtonDownFcn', @(~,~) highlightDroplet(dropletNumbers(idx))...
                            );
                        end
                        % update legend - the legend position can not be
                        % preserved...
                        l = legend(handles.timeCourse.axes);
                        if (~isempty(l))
                            delete(l);
                            legend(handles.timeCourse.axes, 'show');
                        end
                    end
                    handles.timeCourse.resetMaxZoom();
                    handles.timeCourse.vline.drawApi.setReorderListener();
                end
            end
        end
    end
    function highlightDroplet(highlightIdx)
        selectionDisplay.selections{2} = false(size(selectionDisplay.droplets));
        selectionDisplay.selections{2}(highlightIdx) = true;
        start(timer('TimerFcn', @reset, 'StartDelay', 1, 'TasksToExecute', 1, 'StopFcn', @(t, ~)delete(t)));
        function reset(~,~)
            try
                selectionDisplay.selections{2}(highlightIdx) = false;
            end
        end
    end
end
 