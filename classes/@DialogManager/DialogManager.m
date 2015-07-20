classdef DialogManager < handle
    properties(SetAccess=private)
        container
        parentManager = []
        childManagers = []
        obj
        currentPanel
    end
    properties(Access=private)
        currentVerticalPanelPosition
        eventListener
        
        springPanels = []
        normalPanels = []
        allPanels = []
    end
    
    events
        openWin
        showWin
        hideWin
        closeWin
        
        openContainer
        showContainer
        hideContainer
        closeContainer
        
        propertyChange
        message
    end
    
    properties
        padding = 10;
        innerPadding = 10;
        linePadding = 5;
        lineHeight = 20;
        width = 500;
        height = 500;
        remainingHeight;
        innerHeight;
        innerWidth;
        api = [];
    end
    
    methods
        function this = DialogManager(obj)
            this.obj = obj;
        end
        
        function open(this, title, container)
            if (nargin < 2 || isempty(title))
                title = [class(this.obj), ' Dialog'];
            end
            
            if (isempty(this.container) || ~ishandle(this.container))
                this.innerWidth = this.width - 2*this.padding;
                this.innerHeight = this.height - 2*this.padding;
                this.remainingHeight = this.height - this.padding;
                if (nargin > 2 && ~isempty(container))
                    if (ishghandle(container) && strcmp(get(container, 'Type'), 'figure'))
                        fig = clf(container, 'reset');
                    else
                        if (isa(container, 'DialogManager'))
                            fig = container.addPanel();
                            this.parentManager = container;
                            if (isempty(container.childManagers))
                                container.childManagers = this;
                            else
                                container.childManagers(end + 1) = this;
                            end
                        else
                            fig = container;
                        end
                    end
                else
                    fig = figure();
                end
                this.container = handle(fig);
                if (this.isStandalone())
                    set(this.container, ...
                        'Name', title, ...
                        'NumberTitle', 'off', ...
                        'Units', 'pixels', ...
                        'Position', [50, 50, this.width, this.height], ...
                        'Resize', 'on', ...
                        'HandleVisibility', 'off', ...
                        'Visible', 'off', ...
                        'CloseReq', @(~,~)this.close(), ...
                        'MenuBar', 'none', ...
                        'Toolbar', 'none' ...
                    );
                end
                try
                    addlistener(this.container, 'SizeChanged', @this.adjustPositions);
                catch
                    addlistener(this.container, 'SizeChange', @this.adjustPositions);
                end
                this.containerNotify('open');
            end
        end
        
        function is = isOpen(this)
            is = ishandle(this) && ~isempty(this.container) && ishandle(this.container);
        end
        
        function is = isStandalone(this)
            is = strcmpi(get(this.container, 'Type'), 'figure');
        end
        
        function fig = getFigure(this)
            fig = Gui.getParentFigure(this.container);
        end
        
        function focus(this)
            if (this.isOpen())
                figure(this.getFigure());
            end
        end
        
        function adjustPositions(this, varargin)
            pos = this.container.Position;
            this.width = pos(3);
            this.innerWidth = this.width - 2*this.padding;
            for p = this.allPanels
                p.Position(3) = this.innerWidth;
            end
            if (isempty(this.springPanels))
                % no spring panels --> figure height has to match panel
                % heights
                y = this.padding;
                for i = numel(this.allPanels):-1:1
                    this.allPanels(i).Position(2) = y;
                    y = y + this.allPanels(i).Position(4) + this.innerPadding;
                end
                this.height = y + this.padding;
                this.innerHeight = y - this.padding;
                
                this.container.Position(4) = this.height;
            else
                % spring panels --> spring panels have to be adjusted in
                % height
                
                this.height = pos(4);
                this.innerHeight = this.height - 2*this.padding;
                
                springHeight = this.innerHeight;
                for p = this.normalPanels
                    springHeight = springHeight - p.Position(4);
                end
                springHeight = springHeight - (numel(this.allPanels) - 1) * this.innerPadding;
                springHeight = springHeight / numel(this.springPanels);
                if (springHeight < this.lineHeight)
                    % figure not high enough for all panels --> figure has
                    % to get higher.
                    this.height = this.height + ...
                        (this.lineHeight - springHeight) * ...
                        numel(this.springPanels);
                    this.innerHeight = this.height - 2*this.padding;
                    this.container.Position(4) = this.height;
                    springHeight = this.lineHeight;
                end
                
                y = this.padding;
                for i = numel(this.allPanels):-1:1
                    p = this.allPanels(i);
                    if any(p == this.springPanels)
                        p.Position(4) = springHeight;
                    end
                    p.Position(2) = y;
                    y = y + p.Position(4) + this.innerPadding;
                end
            end
        end
        
        function dependsOn(this, otherDialog)
            this.addDeleteListener( ...
                addlistener(otherDialog, 'closeWin', @(~,~)this.close()) ...
            );
        end
        
        function hide(this)
            this.container.Visible = 'off';
            this.containerNotify('hide');
        end
        function show(this, fullscreen)
            if (nargin < 2)
                fullscreen = false;
            end
            if (fullscreen && this.isStandalone())
                this.container.Visible = 'on';
                Gui.maximizeFigure(this.container);
            else
                this.adjustPositions();
                this.container.Visible = 'on';
                if (~isempty(this.parentManager))
                    if (isempty(this.springPanels))
                        this.parentManager.normalPanel(this.container);
                    end
                end
            end
            this.containerNotify('show');
            drawnow;
        end
        
        function move(this, pos)
            movegui(this.getFigure(), pos);
        end
        
        function wait(this)
            uiwait(this.getFigure());
        end
        
        function resume(this)
            uiresume(this.getFigure());
        end
        
        function close(this)
            for o = this
                for c = o.childManagers
                    c.close();
                end
                delete(o.eventListener);
                this.containerNotify('close');
                delete(o.container);
                delete(o);
            end
        end
        
        function panel = addPanel(this, rowNum, str)
            if (nargin < 2)
                spring = true;
                rowNum = 1;
            else
                spring = false;
            end
            if (nargin < 3)
                str = '';
            elseif (~isempty(str))
                rowNum = rowNum + 1;
            end
            
            panelHeight = rowNum * this.lineHeight + ...
                (rowNum - 1) * this.linePadding;
            
            
            this.remainingHeight = this.remainingHeight - panelHeight;
            panel = handle(uipanel( ...
                'Parent', this.container, ...
                'Units', 'pixels', ...
                'Position', [this.padding, this.remainingHeight, this.innerWidth, panelHeight], ...
                'BorderWidth', 0, ...
                'BorderType', 'none', ...
                'HandleVisibility', 'off' ...
            ));
            if (this.isStandalone())
                panel.BackgroundColor = this.container.Color;
            else
                panel.BackgroundColor = this.container.BackgroundColor;
                Gui.bindBackgroundColorToParent(panel);
            end
            
            this.remainingHeight = this.remainingHeight - this.innerPadding;
            
            % set up panel properties
            this.currentPanel = panel;
            this.currentVerticalPanelPosition = panelHeight + this.linePadding;
            this.newLine();
            
            if (~isempty(str))
                this.addTitle(str, [0, 0, 0, this.lineHeight]);
                this.newLine();
            end
            
            % add to panel collection
            if (isempty(this.allPanels))
                this.allPanels = panel;
            else
                this.allPanels(end + 1) = panel;
            end
            if (spring)
                this.springPanel(panel);
            else
                this.normalPanel(panel);
            end
        end
        
        function [outerScrollPanel, innerScrollPanel] = addScrollPanel(this, outerRowNum, innerRowNum)
            panel = this.addPanel(outerRowNum);
            [outerScrollPanel, innerScrollPanel] = Gui.createScrollablePanel(panel);
            outerScrollPanel.Position = [0, 0, panel.Position(3), panel.Position(4)];
            Gui.makeFullWidth(outerScrollPanel);
            innerScrollPanel.Position(4) = innerRowNum * this.lineHeight + ...
                    (innerRowNum - 1) * this.linePadding;
            this.currentPanel = innerScrollPanel;
            this.currentVerticalPanelPosition = innerScrollPanel.Position(4) + this.linePadding;
            this.newLine();
        end
        
        function setCurrentPanel(this, panel)
            warning('DialogManager:handleWithCare', ...
                'Setting the current panel has to be handled with care!');
            this.currentPanel = panel;
            this.currentVerticalPanelPosition = panel.Position(4) + this.linePadding;
            this.newLine();
        end
        
        function springPanel(this, panel)
            this.normalPanels = this.normalPanels(this.normalPanels ~= panel);
            if (isempty(this.springPanels))
                this.springPanels = panel;
            else
                this.springPanels(end + 1) = panel;
            end
        end
        function normalPanel(this, panel)
            this.springPanels = this.springPanels(this.springPanels ~= panel);
            if (isempty(this.normalPanels))
                this.normalPanels = panel;
            else
                this.normalPanels(end + 1) = panel;
            end
        end
        
        function newLine(this)
            this.currentVerticalPanelPosition = ...
                this.currentVerticalPanelPosition - this.linePadding - this.lineHeight;
        end
        
        function pos = adaptPos(this, pos)
            if (numel(pos) == 1)
                pos = [0, 0, pos, 0];
            end
            pos(2) = this.currentVerticalPanelPosition;
            pos(4) = this.lineHeight;
        end
        
        function [prop, propIndex, value] = parsePropName(this, prop, obj)
            if (nargin < 3 || isempty(obj))
                obj = this.obj;
            end
            
            if (iscell(prop))
                propIndex = prop{2};
                prop = prop{1};
            else
                index = regexp(prop, '\(\d+\)$');
                if (~isempty(index))
                    propIndex = str2double(prop(index + 1:end-1));
                    prop = prop(1:index - 1);
                else
                    propIndex = 1:numel(obj.(prop));
                end
            end
            value = obj.(prop)(propIndex);
        end
        
        % add... functions
        
        function addElement(this, element, pos)
            if (nargin < 3)
                pos = 0;
            end
            
            set(element, 'Parent', this.currentPanel);
            
            if (iscell(pos))
                dynFunc = pos;
                pos = 0;
            elseif (isa(pos, 'function_handle'))
                dynFunc = {[], pos};
                pos = 0;
            else
                dynFunc = {};
            end
            
            pos = this.adaptPos(pos);
            
            if (pos(3) <= 0)
                pos(3) = this.innerWidth;
                set(element, 'Position', pos);
                Gui.makeFullWidth(element, dynFunc{:});
            else
                set(element, 'Position', pos);
            end
        end

        function text = addTitle(this, str, pos)
            if (nargin < 3)
                pos = 0;
            end
            
            text = this.addText(str, pos);
            text.FontWeight = 'bold';
            text.HorizontalAlignment = 'center';
        end
        
        function text = addText(this, str, pos)
            if (nargin < 3)
                pos = 0;
            end
            text = handle( ...
                uicontrol( ...
                    'Parent', this.currentPanel, ...
                    'Style', 'text', ...'edit', ...
                    'Enable', 'inactive', ...
                    'String', str, ...
                    'Units', 'pixels', ...
                    ...'Position', pos, ...
                    'HorizontalAlignment', 'left' ...
                ) ...
            );
            Gui.bindBackgroundColorToParent(text);
            
%             l = addlistener(this, 'showWin', @removeBorder); 
            this.addElement(text, pos);
            text.Position(2) = text.Position(2) - 3;
            
%             function removeBorder(varargin)
%                 try
%                     jText = findjobj(text, 'persist');
%                     for idx = 1:numel(jText)
%                         jT = jText(idx);
%                         jT.Border = [];
%                         jT.setOpaque(0);
%                         jT.repaint();
%                         delete(l);
%                     end
%                 end
%             end
        end
        
        function box = addPropertyCheckbox(this, str, prop, pos, posCallback, negCallback, obj)
            if (nargin < 4)
                pos = 0;
            end
            if (nargin < 5 || isempty(posCallback))
                posCallback = @(a)a;
            end
            if (nargin < 6 || isempty(negCallback))
                negCallback = posCallback;
            end
            if (nargin < 7 || isempty(obj))
                obj = this.obj;
            end
            
            [prop, propIndex, value] = this.parsePropName(prop, obj);
            
            box = this.addCheckbox(str, value, pos, @callback);
            this.listen(prop, @reverseCallback, obj, box);
            function callback(value)
                obj.(prop)(propIndex) = value;
                if (value)
                    posCallback(box.Value);
                else
                    negCallback(box.Value);
                end
            end
            function reverseCallback(~,~)
                box.Value = obj.(prop)(propIndex);
            end
        end
        
        function box = addCheckbox(this, str, value, pos, userCallback)
            if (nargin < 4)
                pos = 0;
            end
            if (nargin < 5)
                userCallback = @(a)a;
            end
            
            box = handle(uicontrol( ...
                'Parent', this.currentPanel, ...
                'Style', 'checkbox', ...
                'String', str, ...
                'Value', value, ...
                'Units', 'pixels' ...
                ...'Position', pos, ...
                ...'Callback', @callback, ...
            ));
            Gui.bindBackgroundColorToParent(box);
            addlistener(box, 'Value', 'PostSet', @callback);
            this.addElement(box, pos);
            
            oldValue = value;
            function callback(~,~)
                newValue = logical(box.Value);
                if (newValue ~= oldValue)
                    userCallback(newValue);
                    notify(this, 'propertyChange', ArbitraryEventData( ...
                        struct('Object', box, ...
                            'OldValue', oldValue, ...
                            'NewValue', newValue) ...
                    ));
                    oldValue = newValue;
                end
            end
        end

        function slider = addPropertySlider(this, prop, minValue, maxValue, pos, userCallback, obj)
            if (nargin < 5)
                pos = 0;
            end
            if (nargin < 6 || isempty(userCallback))
                userCallback = @(a)a;
            end
            if (nargin < 7 || isempty(obj))
                obj = this.obj;
            end
            
            [prop, propIndex, value] = this.parsePropName(prop, obj);
            
            a = 1;
            if (~isscalar(value))
                a = ones(size(value));
                value = value(1);
            end
            
            if (~isfinite(value))
                if (value > 0)
                    value = maxValue;
                else
                    value = minValue;
                end
            end
            
            slider = this.addSlider(value, minValue, maxValue, pos, @callback);
            this.listen(prop, @reverseCallback, obj, slider);
            function callback(value)
                obj.(prop)(propIndex) = a * value;
                userCallback(value);
            end
            function reverseCallback(~,~)
                newValue = obj.(prop)(propIndex);
                if (newValue < slider.Min)
                    slider.Min = newValue;
                elseif (newValue > slider.Max)
                    slider.Max = newValue;
                end
                slider.Value = newValue(1);
            end
        end
        
        function slider = addSlider(this, value, minValue, maxValue, pos, userCallback)
            if (nargin < 5)
                pos = 0;
            end
            if (nargin < 6)
                userCallback = @(a)a;
            end
            
            minValue = min(minValue, value);
            maxValue = max(maxValue, value);
            slider = handle(uicontrol( ...
                'Parent', this.currentPanel, ...
                'Style', 'slider', ...
                'Min', minValue, ...
                'Value', value, ...
                'Max', maxValue, ...
                'SliderStep', [0.01, 0.1], ...
                'Units', 'pixels', ...
                ...'Position', pos, ...
                'HandleVisibility', 'off' ...
            ));
%             Gui.bindBackgroundColorToParent(slider);
            this.addElement(slider, pos);
            
            Gui.addSliderContextMenu(slider);
            
            addlistener(slider, 'Value', 'PostSet', @callback);
            
            oldValue = value;
            function callback(~,~)
                newValue = slider.Value;
                if (isnan(newValue))
                    newValue = oldValue;
                    slider.Value = oldValue;
                end
                if (newValue ~= oldValue)
                    userCallback(newValue);
                    notify(this, 'propertyChange', ArbitraryEventData( ...
                        struct('Object', slider, ...
                            'OldValue', oldValue, ...
                            'NewValue', newValue) ...
                    ));
                    oldValue = newValue;
                end
            end
        end
        
        function input = addPropertyInput(this, prop, pos, userCallback, obj)
            if (nargin < 3)
                pos = 0;
            end
            if (nargin < 4 || isempty(userCallback))
                userCallback = @(a)a;
            end
            if (nargin < 5 || isempty(obj))
                obj = this.obj;
            end
            
            [prop, propIndex, value] = this.parsePropName(prop, obj);
            
            isnum = isnumeric(value);
            input = this.addInput(value, pos, @callback);
            this.listen(prop, @reverseCallback, obj, input);
            
            function callback(value)
                obj.(prop)(propIndex) = value;
                userCallback(value);
            end
            function reverseCallback(~,~)
                if (isnum)
                    input.value = obj.(prop)(propIndex);
                else
                    input.String = obj.(prop)(propIndex);
                end
            end
        end
        
        function input = addInput(this, value, pos, userCallback)
            if (nargin < 3)
                pos = 0;
            end
            if (nargin < 4)
                userCallback = @(a)a;
            end
            
            isnum = isnumeric(value);
            
            if (isnum)
                input = Gui.NumericInput( ...
                    'Parent', this.currentPanel, ...
                    'Value', value, ...
                    'HandleVisibility', 'off', ...
                    'Units', 'pixels' ...
                    ...'Position', pos ...
                );
                this.addElement(handle(input.handle), pos);
                addlistener(input, 'valueChange', @callback);
            else
                input = handle(uicontrol( ...
                    'Parent', this.currentPanel, ...
                    'Style', 'edit', ...
                    'String', value, ...
                    'HandleVisibility', 'off', ...
                    'Units', 'pixels', ...
                    ...'Position', pos, ...
                    'Callback', @callback...
                ));
                this.addElement(input, pos);
            end
            
            oldValue = value;
            function callback(~,~)
                if (isnum)
                    newValue = input.value;
                else
                    newValue = input.String;
                    if strcmp(newValue, oldValue)
                        return;
                    end
                end
                if (newValue ~= oldValue)
                    userCallback(newValue);
                    notify(this, 'propertyChange', ArbitraryEventData( ...
                        struct('Object', input, ...
                            'OldValue', oldValue, ...
                            'NewValue', newValue) ...
                    ));
                    oldValue = newValue;
                end
            end
        end
        
        function button = addButton(this, str, pos, userCallback)
            if (nargin < 3)
                pos = 0;
            end
            if (nargin < 4)
                userCallback = @(a)a;
            end
            
            
            button = handle(uicontrol( ...
                'Parent', this.currentPanel, ...
                'Style', 'pushbutton', ...
                'String', str, ...
                'HandleVisibility', 'off', ...
                'Units', 'pixels', ...
                ...'Position', pos, ...
                'Callback', @callback...
            ));
            this.addElement(button, pos);
            
            function callback(~,~)
                userCallback();
                if (ishandle(this))
                    notify(this, 'propertyChange', ArbitraryEventData( ...
                        struct('Object', button) ...
                    ));
                end
            end
        end
        
        function buttons = addButtonRow(this, varargin)
            numButtons = floor(numel(varargin) / 2);
            for i = numButtons:-1:1
                buttons(i) = this.addButton( ...
                    varargin{i * 2 - 1}, ...
                    {@(w)(i - 1) * w / numButtons, @(w)w / numButtons}, ...
                    varargin{i * 2} ...
                );
            end
        end
        
        function button = addToggleButton(this, str, pos, userCallbackDown, userCallbackUp)
            if (nargin < 3)
                pos = 0;
            end
            if (nargin < 4)
                userCallbackDown = @(a)a;
            end
            if (nargin < 5)
                userCallbackUp = @(a)a;
            end
            
            
            button = handle(uicontrol( ...
                'Parent', this.currentPanel, ...
                'Style', 'togglebutton', ...
                'String', str, ...
                'HandleVisibility', 'off', ...
                'Units', 'pixels', ...
                'Min', false, ...
                'Max', true, ...
                'Value', false, ...
                ...'Position', pos, ...
                'Callback', @callback...
            ));
            this.addElement(button, pos);
            
            function callback(~,~)
                if (button.Value)
                    userCallbackDown();
                else
                    userCallbackUp();
                end
                if (ishandle(this))
                    notify(this, 'propertyChange', ArbitraryEventData( ...
                        struct('Object', button) ...
                    ));
                end
            end
        end
        
        function popupmenu = addPropertyPopupmenu(this, prop, str, pos, userCallback, obj)
            if (nargin < 4)
                pos = 0;
            end
            if (nargin < 5 || isempty(userCallback))
                userCallback = @(a)a;
            end
            if (nargin < 6 || isempty(obj))
                obj = this.obj;
            end
            
%             [prop, propIndex, value] = this.parsePropName(prop);
            
            value = find(strcmp(obj.(prop), str), 1, 'first');
            
            popupmenu = this.addPopupmenu(str, pos, @callback);
            popupmenu.Value = value;
            
            this.listen(prop, @reverseCallback, obj, popupmenu);
            
            function callback(value)
                obj.(prop) = value;
                userCallback(value);
            end
            function reverseCallback(~,~)
                popupmenu.Value = find( ...
                    strcmp( ...
                        obj.(prop),  ...
                        str ...
                    ), ...
                    1, ...
                    'first' ...
                );
            end
        end
        
        function popupmenu = addPopupmenu(this, str, pos, userCallback)
            if (nargin < 3)
                pos = 0;
            end
            if (nargin < 4)
                userCallback = @(a)a;
            end
            
            
            popupmenu = handle(uicontrol( ...
                'Parent', this.currentPanel, ...
                'Style', 'popupmenu', ...
                'String', str, ...
                'HandleVisibility', 'off', ...
                'Units', 'pixels', ...
                ...'Position', pos, ...
                'Callback', @callback...
            ));
            this.addElement(popupmenu, pos);
            
            function callback(~,~)
                userCallback(popupmenu.String{popupmenu.Value});
                if (ishandle(this))
                    notify(this, 'propertyChange', ArbitraryEventData( ...
                        struct('Object', popupmenu) ...
                    ));
                end
            end
        end
        
        
        function connectRangeSliders(~, lowerSlider, upperSlider)
            addlistener(lowerSlider, 'Value', 'PostSet', @setUpperMin);
            addlistener(upperSlider, 'Value', 'PostSet', @setLowerMax);
            setUpperMin();
            setLowerMax();
            function setUpperMin(~,~)
                set(upperSlider, 'Min', get(lowerSlider, 'Value'));
            end
            function setLowerMax(~,~)
                set(lowerSlider, 'Max', get(upperSlider, 'Value'));
            end
        end
        
        function checkboxHides(this, box, el, inverse)
            if (nargin < 4)
                inverse = false;
            end
            if (~inverse)
                on = 'on';
                off = 'off';
            else
                on = 'off';
                off = 'on';
            end
            
            addlistener(box, 'Value', 'PostSet', @callback);
            callback();
            function callback(~,~)
                if (box.Value)
                    set(el, 'Visible', on);
                else
                    set(el, 'Visible', off);
                end
            end
        end
        
        function openvarByValue(this)
            globVars = evalin('base', 'who');
            for i = 1:numel(globVars)
                try
                    globValue = evalin('base', globVars{i});
                    if (globValue == this.obj)
                        openvar(globVars{i});
                        break;
                    end
                end
            end
        end
        
        function containerNotify(this, event)
            notify(this, [event, 'Container']);
            
            if (this.isStandalone())
                notify(this, [event, 'Win']);
                for c = this.childManagers
                    if (isvalid(c))
                        notify(c, [event, 'Win']);
                    end
                end
            end
        end
        
        function listener = listen(this, prop, func, obj, involvedElement)
            if (nargin < 4 || isempty(obj))
                obj = this.obj;
            end
            try
                listener = addlistener(obj, prop, 'PostSet', func);
                this.addDeleteListener(listener);
            catch
                listener = [];
            end
            if (nargin > 4 && ~isempty(involvedElement))
                addlistener(involvedElement, 'ObjectBeingDestroyed', @(~,~)delete(listener));
            end
        end
        
        function arrange(this, rowCounts)
            Gui.arrangeFigures([this.container], rowCounts);
        end
    end
    
    methods (Access=public)
        function addDeleteListener(this, l)
            if isempty(this.eventListener)
                this.eventListener = l;
            else
                this.eventListener(end + 1) = l;
            end
        end
    end
end