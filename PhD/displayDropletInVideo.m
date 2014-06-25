function displayDropletInVideo(droplets, stacks)
    if (nargin < 2)
        stacks = droplets;
        droplets = Droplet.empty(0);
    end
    
    if (~iscell(stacks))
        stacks = mat2cell(stacks(:), ones(numel(stacks), 1));
    end
    
    % video control variables
    currentIndex = 1;
    stopped = true;
    stackIndex = 1;
    stackSize = stacks{stackIndex}.size;
    dropletsToShow = [];
    
    % set up interface
    
    handles = createMainWindow();
    handles.timeCourse = createTimeCourseWindow();

    displayFrame();
    
    %% interface build functions
    
    function handles = createMainWindow()
        handles.figure = figure( ...
            'HandleVisibility', 'off', ...
            ...'Visible', 'off', ...
            'Position', [700 20 850 700], ...
            'MenuBar', 'figure', ...
            'Toolbar', 'figure', ...
            'CloseRequestFcn', @figureCloseRequest ...
        );
        handles.axes = axes( ...
            'HandleVisibility', 'callback', ...
            'Parent', handles.figure, ...
            'Units', 'pixel', ...
            'Position', [5 90 800 550] ...
        );


        set(handles.axes, ...
            'xlim', [0 stacks{stackIndex}.info(1).Height], ...
            'ylim', [0 stacks{stackIndex}.info(1).Width], ...
            'ButtonDownFcn', @axesClickCallback ...
        );
        handles.position = uicontrol( ...
            'Parent', handles.figure, ...
            'Style', 'slider', ...
            'Value', currentIndex, ...
            'Min', 1, ...
            'Max', stackSize, ...
            'SliderStep', [1/stackSize 5/stackSize], ...
            'Position', [5 5 840 20] ...
        );
        addlistener(handles.position, 'Value', 'PostSet', @hPositionCallback);
        Gui.addSliderContextMenu(handle(handles.position));

        handles.playPause = uicontrol( ...
            'Parent', handles.figure, ...
            'Style', 'pushbutton', ...
            'String', 'Play', ...
            'Callback', @hPlayPauseCallback, ...
            'Position', [5 30 60 20] ...
        );
        handles.stop = uicontrol( ...
            'Parent', handles.figure, ...
            'Style', 'pushbutton', ...
            'String', 'Stop', ...
            'Callback', @stopVideo, ...
            'Position', [70 30 60 20] ...
        );

        handles.stackSelect = uicontrol( ...
            'Parent', handles.figure, ...
            'Style', 'popupmenu', ...
            'String', cellfun(@(s)s.char(), stacks, 'UniformOutput', false), ...
            'Callback', @hStackSelectCallback, ...
            'Position', [135 30 200 20] ...
        );

        handles.selectAll = uicontrol( ...
            'Parent', handles.figure, ...
            'Style', 'pushbutton', ...
            'String', 'select all', ...
            'Callback', @selectAll, ...
            'Position', [340 30 70 20] ...
        );
        handles.numbersOn = uicontrol( ...
            'Style', 'checkbox', ...
            'Parent', handles.figure, ...
            'Value', 0, ...
            'String', 'display numbers', ...
            'Callback', @numbersOnCallback, ...
            'Position', [415 30 100 20] ...
        );
    end

    function handles = createTimeCourseWindow()
        handles.figure = figure( ...
            'HandleVisibility', 'off' ...
        );
        handles.axes = axes( ...
            'Parent', handles.figure, ...
            'HandleVisibility', 'off' ...
        );
        hold(handles.axes, 'on');
        uicontrol( ...
            'Style', 'text', ...
            'String', 'value to display:', ...
            'Position', [5 5 100 20], ...
            'Parent', handles.figure ...
        );
        handles.displayTypeSelect = uicontrol( ...
            'Style', 'popupmenu', ...
            'String', { ...
                'max intensity', 'min intensity', 'intensity sum', ...
                'bright intensity', 'mean bright intensity', ...
                'position', 'radius'}, ...
            'Callback', @(~,~)plotIntensities(), ...
            'Position', [110 5 100 20], ...
            'Parent', handles.figure ...
        );
    %     timeMarker = Gui.verticalMarker(handles.axes, ...
    %         'Min', 1, 'Max', stackSize, ...
    %         'Value', currentIndex, ...
    %         'SliderInput', 'on' ...
    %     );
        handles.vline = Gui.imvline(handles.axes, currentIndex);
        addlistener(handles.vline, 'newPosition', @(~,~)displayFrame(round(handles.vline.position)));
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
            if (ishandle(handles.timeCourse.figure))
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
            d = droplets(i);
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
                
                d = droplets(dropletsToShow);
                switch get(handles.timeCourse.displayTypeSelect, 'value')
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
                lineH = plot( ...
                    displayValues, ...
                    'Parent', handles.timeCourse.axes ...
                );
                
                handles.timeCourse.vline.drawApi.setReorderListener();
            end
        end
    end

    %% callbacks
    
    function figureCloseRequest(varargin)
        if (ishandle(handles.timeCourse.figure))
            close(handles.timeCourse.figure);
        end
        delete(handles.figure);
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
        idx = droplets.findDroplet(pos, currentIndex);
        if (~isempty(idx) && idx ~=0)
            switch (get(handles.figure, 'SelectionType'))
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
            dropletsToShow = 1:numel(droplets);
            set(handles.selectAll, 'String', 'select none');
        end
        plotIntensities();
        displayFrame();
    end
end