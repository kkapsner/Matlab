function dm = dialog(this)
%DROLET.DIALOG diplays the droplet within its stacks
    
    if (~numel(this))
        % no droplets to show - so don't show anything.
        return;
    end
    stacks = this(1).stacks;
    
    % video control variables
    currentIndex = 1;
    stopped = true;
    stackIndex = 1;
    numStacks = numel(stacks);
    stackSize = stacks{stackIndex}.size;
    dropletsToShow = [];
    
    % set up interface
    dm = DialogManager(this);
    dm.width = 850;
    dm.height = 700;
    
    dm.open();
    
    handles = createMainWindow();
    handles.timeCourse = createTimeCourseWindow();
    
    dm.addlistener('closeWin', @closeCallback);
    
    displayFrame();
    
    dm.show();
    
    %% interface build functions
    
    function handles = createMainWindow()
        dm.addPanel();
        
        handles.axes = axes( ...
            'HandleVisibility', 'callback', ...
            'Parent', dm.currentPanel, ...
            'Units', 'normalized', ...
            'Position', [0, 0, 1, 1] ...
        );


        set(handles.axes, ...
            'xlim', [0 stacks{stackIndex}.info(1).Height], ...
            'ylim', [0 stacks{stackIndex}.info(1).Width], ...
            'ButtonDownFcn', @axesClickCallback ...
        );
        
        dm.addPanel(2);
        
        handles.playPause = dm.addButton('Play', [0, 0, 60, 20], @hPlayPauseCallback);
        handles.stop = dm.addButton('Stop', [60, 0, 60, 20], @stopVideo);

        handles.stackSelect = dm.addPopupmenu( ...
            cellfun(@(s)s.char(), stacks, 'UniformOutput', false), ...
            [135 0 200 20], ...
            @hStackSelectCallback ...
        );

        handles.selectAll = dm.addButton('select all', [340 0 70 20], ...
            @selectAll ...
        );
        handles.numbersOn = dm.addCheckbox('display numbers', 0, ...
            [415 0 100 20], @numbersOnCallback ...
        );
        
        dm.newLine();
        handles.position = dm.addSlider(1, currentIndex, stackSize, 0, @hPositionCallback);

    end

    function handles = createTimeCourseWindow()
        handles.dm = DialogManager(this);
        handles.dm.open();
        handles.figure = handles.dm.f;
        handles.dm.addPanel();
        handles.axes = axes( ...
            'Parent', handles.dm.currentPanel, ...
            'Units', 'normalized', ...
            'OuterPosition', [0, 0, 1, 1], ...
            'HandleVisibility', 'callback' ...
        );
        hold(handles.axes, 'on');
        
        handles.dm.addPanel(1);
        handles.dm.addText('value to display:', [5 0 80 20]);
        handles.displayTypeSelect = handles.dm.addPopupmenu( ...
            { ...
                'max intensity', 'min intensity', 'intensity sum', ...
                'bright intensity', 'mean bright intensity', ...
                'position', 'radius'}, ...
            [90 0 100 20], ...
            @(~,~)plotIntensities() ...
        );
        
        handles.dm.addText('intensity to display:', [200 0 90 20]);
        handles.displayIntensity = handles.dm.addPopupmenu( ...
            [cellfun(@(s)s.char(), stacks(2:end), 'UniformOutput', false), 'all'], ...
            [300 0 150 20], ...
            @(~,~)plotIntensities() ...
        );
        handles.vline = Gui.imvline(handles.axes, currentIndex);
        addlistener(handles.vline, 'newPosition', @(~,~)displayFrame(round(handles.vline.position)));
        
        handles.dm.show();
    end
    
    %% video functions
    
    function stopVideo(~,~)
        pauseVideo();
        displayFrame(1);
    end
    
    function pauseVideo(~,~)
        stopped = true;
        set(handles.playPause, 'String', 'Play');
    end
    
    function playVideo(~,~)
        stopped = false;
        set(handles.playPause, 'String', 'Pause');
        
        for i = currentIndex:stackSize
            if (~ishandle(handles.axes) || stopped)
                break;
            end

            displayFrame(i);

            drawnow();
            pause(0.001);
        end
        pauseVideo();
    end
    

    %% display functions

    function displayFrame(index)
        % prevent multiple calls via handle-callbacks.
        persistent loopCall;
        if (isempty(loopCall))
            loopCall = false;
        elseif (loopCall)
            return;
        end
        
        if (nargin < 1)
            index = currentIndex;
        end
        if (index < 1)
            index = 1;
        elseif (index > stackSize)
            index = stackSize;
        end
        
        
        if (index ~= currentIndex)
            loopCall = true;
            set(handles.position, 'Value', index);
            if (ishandle(handles.timeCourse.dm.f))
                handles.timeCourse.vline.position = index;
            end
            loopCall = false;
        end
        currentIndex = index;
        
        xlim = get(handles.axes, 'xlim');
        ylim = get(handles.axes, 'ylim');
        set(Image.show(stacks{stackIndex}.getImage(index), handles.axes), 'ButtonDownFcn', @axesClickCallback);
        set(handles.axes, 'xlim', xlim, 'ylim', ylim);
        hold(handles.axes, 'on');
        for i = dropletsToShow
            d = this(i);
            if (~isnan(d.radius(index)))
                plotCircle(d.p(index, 1), d.p(index, 2), d.radius(index));
                if (get(handles.numbersOn, 'Value'))
                    text(d.p(index, 1), d.p(index, 2), sprintf('%d', i), ...
                        'Parent', handles.axes, ...
                        'Color', [1, 0, 0], ...
                        'Hit', 'off' ...
                    );
                end
            end
        end
        hold(handles.axes, 'off');
        set(get(handles.axes, 'Title'), 'String', sprintf('Image %i', index));
        
    end
    
    function plotCircle(x, y, r)
        phi = (0:(4*r + 1))/(2*r)*pi;
        x = x + r * sin(phi);
        y = y + r * cos(phi);
        plot(x, y, '-r', 'Parent', handles.axes, 'Hit', 'off');
    end

    lineH = [];
    function plotIntensities()
        if (ishandle(handles.timeCourse.figure))
            if (~isempty(lineH));
                delete(lineH);
                lineH = [];
            end
            if (~isempty(dropletsToShow))
                handles.timeCourse.vline.drawApi.removeReorderListener();
                
                d = this(dropletsToShow);
                displayType = get(handles.timeCourse.displayTypeSelect, 'value');
                switch displayType
                    case 1
                        displayValues = [d.maxIntensity];
%                         displayValues = displayValues(:, 1:2:end);
%                         displayValues = displayValues ./ (ones(size(displayValues, 1), 1) * mean(displayValues(end-50:end,:)));
                    case 2
                        displayValues = [d.minIntensity];
                    case 3
                        displayValues = [d.intensitySum];
                    case 4
                        displayValues = [d.brightIntensitySum];
                    case 5
                        displayValues = [d.brightIntensitySum] ./ [d.brightArea];
                    case 6
                        p = [d.p];
                        lineH = plot( ...
                            p(:, 1:2:end), p(:, 2:2:end), ...
                            'Parent', handles.timeCourse.axes ...
                        );
                        
                        handles.timeCourse.vline.drawApi.setReorderListener();
                        return;
                    case 7
                        displayValues = [d.radius];

                end
                if (displayType < 6)
                    intensityIdx = ...
                        get(handles.timeCourse.displayIntensity, 'value');
                    if (intensityIdx ~= numStacks)
                        displayValues = ...
                            displayValues(:, intensityIdx:(numStacks - 1):end);
                    end
                end
                lineH = plot( ...
                    displayValues, ...
                    'Parent', handles.timeCourse.axes ...
                );
                
                handles.timeCourse.vline.drawApi.setReorderListener();
            end
        end
    end

    %% callbacks
    
    function closeCallback(varargin)
        if (ishandle(handles.timeCourse.figure))
            handles.timeCourse.dm.close();
        end
    end

    function hPositionCallback(~, ~)
        displayFrame(round(get(handles.position, 'Value')));
    end

    function hPlayPauseCallback(~, ~)
        if (stopped)
           playVideo();
        else
            pauseVideo();
        end
    end
    
    function hStackSelectCallback(~, ~)
        stackIndex = get(handles.stackSelect, 'Value');
        displayFrame();
    end

    function axesClickCallback(~, ~)
        pos = get(handles.axes, 'CurrentPoint');
        pos = pos(1, 1:2);
        idx = this.findDroplet(pos, currentIndex);
        if (~isempty(idx) && idx ~=0)
            switch (get(dm.f, 'SelectionType'))
                case 'normal'
                    dropletsToShow = idx;
                case {'extend', 'alt'}
                    filter = dropletsToShow == idx;
                    if (any(filter))
                        dropletsToShow = dropletsToShow(~filter);
                    else
                        dropletsToShow = [dropletsToShow idx];
                    end
                otherwise
                    dropletsToShow = idx;
            end
            
            plotIntensities();
            displayFrame();
        end
    end

    function numbersOnCallback(~, ~)
        displayFrame();
    end

    function selectAll(varargin)
        if (numel(dropletsToShow))
            dropletsToShow = [];
            set(handles.selectAll, 'String', 'select all');
        else
            dropletsToShow = 1:numel(this);
            set(handles.selectAll, 'String', 'select none');
        end
        plotIntensities();
        displayFrame();
    end
end

