classdef DialogManager < handle
    properties(SetAccess=private)
        f
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
        propertyChange
        closeWin
        
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
        
        function open(this, title)
            if (nargin < 2 || isempty(title))
                title = [class(this.obj), ' Dialog'];
            end
            
            if (isempty(this.f) || ~ishandle(this.f))
                this.innerWidth = this.width - 2*this.padding;
                this.innerHeight = this.height - 2*this.padding;
                this.remainingHeight = this.height - this.padding;
                this.f = handle(figure( ...
                    'Name', title, ...
                    'NumberTitle', 'off', ...
                    'Units', 'pixels', ...
                    'Position', [50, 50, this.width, this.height], ...
                    'Resize', 'on', ...
                    'HandleVisibility', 'off', ...
                    'CloseReq', @(~,~)this.close(), ...
                    'MenuBar', 'none', ...
                    'Toolbar', 'none' ...
                ));
                addlistener(this.f, 'SizeChange', @this.adjustPositions);
                notify(this, 'openWin');
            end
        end
        
        function is = isOpen(this)
            is = ishandle(this) && ~isempty(this.f) && ishandle(this.f);
        end
        
        function focus(this)
            if (this.isOpen())
                figure(this.f);
            end
        end
        
        function adjustPositions(this, varargin)
            pos = this.f.Position;
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
                
                this.f.Position(4) = this.height;
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
                    this.f.Position(4) = this.height;
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
            this.f.Visible = 'off';
        end
        function show(this, fullscreen)
            if (nargin < 2)
                fullscreen = false;
            end
            if (fullscreen)
                this.f.Visible = 'on';
                Gui.maximizeFigure(this.f);
            else
                this.adjustPositions();
                this.f.Visible = 'on';
            end
            drawnow;
        end
        
        function move(this, pos)
            movegui(this.f, pos);
        end
        
        function wait(this)
            uiwait(this.f);
        end
        
        function resume(this)
            uiresume(this.f);
        end
        
        function close(this)
            for o = this
                delete(o.eventListener);
                delete(o.f);
                notify(o, 'closeWin');
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
                'Parent', this.f, ...
                'BackgroundColor', this.f.Color, ...
                'Units', 'pixels', ...
                'Position', [this.padding, this.remainingHeight, this.innerWidth, panelHeight], ...
                'BorderWidth', 0, ...
                'HandleVisibility', 'off' ...
            ));
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
                if (isempty(this.springPanels))
                    this.springPanels = panel;
                else
                    this.springPanels(end + 1) = panel;
                end
            else
                if (isempty(this.normalPanels))
                    this.normalPanels = panel;
                else
                    this.normalPanels(end + 1) = panel;
                end
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
        
        function makeFullWidth(this, element, dynX, dynWidth)
            if (nargin < 3)
                dynX = [];
            end
            if (nargin < 4 || isempty(dynWidth))
                dynWidth = @(a)a;
            end
            addlistener(element.Parent, 'SizeChange', @callback);
            callback();
            
            function callback(~,~)
                parentWidth = handle(element.Parent).Position(3);
                if (~isempty(dynX))
                    element.Position(1) = dynX(parentWidth);
                end
                element.Position(3) = dynWidth(parentWidth);
            end
        end
        
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
                this.makeFullWidth(element, dynFunc{:});
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
                    'BackgroundColor', this.currentPanel.BackgroundColor, ...
                    'Style', 'text', ...
                    'String', str, ...
                    'Units', 'pixels', ...
                    ...'Position', pos, ...
                    'HorizontalAlignment', 'left' ...
                ) ...
            );
            this.addElement(text, pos);
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
            if (nargin < 6 || isempty(obj))
                obj = this.obj;
            end
            
            [prop, propIndex, value] = this.parsePropName(prop, obj);
            
            box = this.addCheckbox(str, value, pos, @callback);
            this.listen(prop, @reverseCallback, obj);
            function callback(value)
                obj.(prop)(propIndex) = value;
                if (value)
                    posCallback(box.value);
                else
                    negCallback(box.value);
                end
            end
            function reverseCallback(~,~)
                box.value = obj.(prop)(propIndex);
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
                'BackgroundColor', this.currentPanel.BackgroundColor, ...
                'Style', 'checkbox', ...
                'String', str, ...
                'Value', value, ...
                'Units', 'pixels' ...
                ...'Position', pos, ...
                ...'Callback', @callback, ...
            ));
            addlistener(box, 'Value', 'PostSet', @callback);
            this.addElement(box, pos);
            
            oldValue = value;
            function callback(~,~)
                newValue = logical(box.value);
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
            this.listen(prop, @reverseCallback, obj);
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
                ...'BackgroundColor', panel.BackgroundColor, ...
                'Style', 'slider', ...
                'Min', minValue, ...
                'Value', value, ...
                'Max', maxValue, ...
                'SliderStep', [0.01, 0.1], ...
                'Units', 'pixels', ...
                ...'Position', pos, ...
                'HandleVisibility', 'off' ...
            ));
            this.addElement(slider, pos);
            
            Gui.addSliderContextMenu(slider);
            
            addlistener(slider, 'Value', 'PostSet', @callback);
            
            oldValue = value;
            function callback(~,~)
                newValue = slider.Value;
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
            this.listen(prop, @reverseCallback, obj);
            
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
            
            this.listen(prop, @reverseCallback, obj);
            
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
                if (box.value)
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
        
        function listen(this, prop, func, obj)
            if (nargin < 4 || isempty(obj))
                obj = this.obj;
            end
            try
                this.addDeleteListener( ...
                    addlistener(obj, prop, 'PostSet', func) ...
                );
            end
        end
        
        function arrange(this, rowCounts)
            Gui.arrangeFigures([this.f], rowCounts);
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