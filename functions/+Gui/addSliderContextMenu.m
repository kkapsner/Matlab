function menu = addSliderContextMenu(slider, menu)
%ADDSLIDERCONTEXTMENU adds some slider specific entries to a given or new
%context menu.
%
%   addSliderContextMenu(SLIDER) creates a new context menu with the
%   entries
%   addSliderContextMenu(SLIDER, MENU) adds the entries to the given
%   context menu MENU
%   MENU = addSliderContextMenu(...) returns the context menu
%   
%   The slider specific entries are:
%       * open a GUI were the minimum, maximum and value of the slider can
%       be entered
%       * toggle the numeric display of the sliders value
    slider = handle(slider);
    f = Gui.getParentFigure(slider);
    if (nargin < 2)
        menu = uicontextmenu('Parent', f);
    end
    
    slider.UIContextMenu = menu;
    
    %% GUI
    uimenu(menu, 'Label', 'open GUI', 'Callback', @openGUI);
    guiDm = [];
    function openGUI(~,~)
        if (isempty(guiDm) || ~guiDm.isOpen())
            guiDm = DialogManager(slider);
            addlistener(guiDm, 'closeWin', @removeListener);
            closeListener = addlistener(slider, 'ObjectBeingDestroyed', @(~,~)guiDm.close());
            guiDm.height = 90;
            guiDm.width = 100;
            guiDm.open();

            guiDm.addPanel(3);

            guiDm.addText('min', 40);
            guiDm.addPropertyInput('Min', [40, 0, guiDm.innerWidth - 40, 20], @checkValues);
            guiDm.newLine();
            guiDm.addText('value', 40);
            guiDm.addPropertyInput('Value', [40, 0, guiDm.innerWidth - 40, 20], @checkValues);
            guiDm.newLine();
            guiDm.addText('max', 40);
            guiDm.addPropertyInput('Max', [40, 0, guiDm.innerWidth - 40, 20], @checkValues);

            guiDm.show();

            set(guiDm.getFigure(), 'Resize', 'off');

        else
            guiDm.focus();
        end
        
        fPos = get(f, 'Position');
        mousePosition = get(f, 'CurrentPoint');
        guiDm.container.OuterPosition(1) = fPos(1) + mousePosition(1) - guiDm.container.OuterPosition(3)/2;
        guiDm.container.OuterPosition(2) = fPos(2) + mousePosition(2) - guiDm.container.OuterPosition(4);
        
        function removeListener(~,~)
            delete(closeListener);
        end
        
        function checkValues(~,~)
            if (slider.Value > slider.Max)
                slider.Max = slider.Value;
            end
            if (slider.Value < slider.Min)
                slider.Min = slider.Value;
            end
        end
    end
    
    %% toggle value display
    displayValueMenu = uimenu(menu, 'Label', 'display value', 'Checked', 'on', 'Callback', @toggleValueDisplay);
    visible = 1;
    text = handle(uicontrol( ...
        'Parent', slider.Parent, ...
        'Style', 'text', ...
        'HorizontalAlignment', 'center', ...
        'HandleVisibility', 'off', ...
        'HitTest', 'off', ...
        'Enable', 'off', ...
        'Position', [1, 2, 3, 4] ...
    ));
    
    % enable "click through text"
    jText = [];
    hideValueDisplay();
    start(timer('TimerFcn', @showValueDisplay, 'StartDelay', 0.2, 'TasksToExecute', 1, 'StopFcn', @(t, ~)delete(t))); 

    addlistener(slider, 'Value', 'PostSet', @(~,ev)updateString(slider.Value));
    
    updateString(slider.Value);
    function updateString(value)
        text.String = num2str(value);
        updatePosition(value);
        drawnow update;
    end

    try
        addlistener(slider, 'LocationChanged', @(~,~)updatePosition(slider.Value));
    catch
        addlistener(slider, 'Position', 'PostSet', @(~,~)updatePosition(slider.Value));
    end
    addlistener(slider, 'Max', 'PostSet', @(~,~)updatePosition(slider.Value));
    addlistener(slider, 'Min', 'PostSet', @(~,~)updatePosition(slider.Value));
    function updatePosition(value)
        pos = slider.Position;
        slideWidth = pos(3) - 2*16;
        sliderWidth = floor(slideWidth / (1/slider.SliderStep(2) + 1));
        if (true || sliderWidth < 20)
            text.Position = [ ...
                pos(1) + pos(3)/2 - 20, ...
                pos(2) + 2, ...
                40, ...
                pos(4) - 4 ...
            ];
        else
            width = sliderWidth;
            x = pos(1) + 16 + ...
                (value - slider.Min)/(slider.Max - slider.Min) * ...
                (slideWidth - sliderWidth);
            y = pos(2);
            height = pos(4);
            text.Position = [x + 2, y + 2, width - 4, height - 4];
        end
    end

    addlistener(slider, 'Visible', 'PostSet', @reflectSliderVisibility);
    
    function reflectSliderVisibility(~,~)
        if (visible && strcmp(slider.Visible, 'on'))
            showValueDisplay();
        else
		    hideValueDisplay();
        end
    end
    
    function toggleValueDisplay(~,~)
        if (visible)
            hideValueDisplay();
        else
            showValueDisplay();
        end
    end

    function showValueDisplay(~,~)
        text.Visible = slider.Visible;
        enableClickThrough();
        set(displayValueMenu, 'Checked', 'on');
        visible = true;
    end

    function hideValueDisplay(~,~)
        text.Visible = 'off';
        set(displayValueMenu, 'Checked', 'off');
        visible = false;
    end

    function enableClickThrough()
        if (isempty(jText))
            warning('off', 'YMA:FindJObj:invisibleHandle');
            jText = findjobj(text);
            if (~isempty(jText))
                jText.setOpaque(0);
                jText(end).getParent().setEnabled(0);
            end
        end
    end

    %% enable scroll wheel
    
    oldWindowScrollWheel = get(f, 'WindowScrollWheelFcn');
    set(f, 'WindowScrollWheelFcn', @scrollWheel)
    
    function scrollWheel(hObject,eventData)
        if (isa(oldWindowScrollWheel, 'function_handle'))
            oldWindowScrollWheel(hObject, eventData);
        end
        if (Gui.isMouseOver(slider))
            range = slider.Max - slider.Min;
            steps = slider.SliderStep;
            newValue = slider.Value +  steps(1) * range * eventData.VerticalScrollCount;
            if (newValue < slider.Min)
                newValue = slider.Min;
            elseif (newValue > slider.Max)
                newValue = slider.Max;
            end
            slider.Value = newValue;
        end
    end
end