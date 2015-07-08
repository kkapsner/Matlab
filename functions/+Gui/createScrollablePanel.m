function [outerContainer, innerContainer] = createScrollablePanel(parent, innerArrangeCallback)
    if (nargin < 2)
        innerArrangeCallback = @()1;
    end
    outerContainer = handle(uipanel( ...
        'Parent', parent, ...
        'HandleVisibility', 'off', ...
        'Units', 'pixels', ...
        'BorderWidth', 1 ...
    ));

    try
        addlistener(outerContainer, 'SizeChanged', @arrangeOuter);
    catch
        addlistener(outerContainer, 'SizeChange', @arrangeOuter);
    end

    innerContainer = handle(uipanel( ...
        'Parent', outerContainer, ...
        'HandleVisibility', 'off', ...
        'Units', 'pixels', ...
        'BackgroundColor', outerContainer.BackgroundColor, ...
        'BorderWidth', 0 ...
    ));
    Gui.bindBackgroundColorToParent(innerContainer);
    try
        addlistener(innerContainer, 'SizeChanged', @arrangeInner);
    catch
        addlistener(innerContainer, 'SizeChange', @arrangeInner);
    end

    scrollbar = handle(uicontrol( ...
        'Parent', outerContainer, ...
        'Style', 'slider', ...
        'HandleVisibility', 'off', ...
        'Units', 'pixels', ...
        'Visible', 'off', ...
        'Min', 0 ...
    ));
    inArrange = false;
    addlistener(scrollbar, 'Value', 'PostSet', @updateScrollPosition);

    function arrangeOuter(~,~)
        inArrange = true;
        pos = outerContainer.Position;
        scrollbar.Position = [ ...
            pos(3) - 15, ...
            0, ...
            15, ...
            pos(4);
        ];
        innerPos = innerContainer.Position;
        neededSpace = innerPos(4) + 10;

        if (neededSpace > pos(4))
            rightPadding = 15;
            value = scrollbar.Max - scrollbar.Value;
            scrollbar.Value = 0;
            scrollbar.Max = neededSpace - pos(4);
            if (value > scrollbar.Max)
                value = scrollbar.Max;
            end
            scrollbar.Value = scrollbar.Max - value;
            scrollbar.Visible = 'on';
            minorStep = min(1, 30 / scrollbar.Max);
            majorStep = max(minorStep, pos(4) / (neededSpace - pos(4)));
            scrollbar.SliderStep = [minorStep, majorStep];
        else
            scrollbar.Value = scrollbar.Max;
            scrollbar.Visible = 'off';
            rightPadding = 15;
        end
        innerContainer.Position = [ ...
            5, ...
            pos(4) - 5 - innerPos(4) + scrollbar.Max - scrollbar.Value, ...
            pos(3) - 10 - rightPadding, ...
            innerPos(4) ...
        ];
        inArrange = false;
    end

    function updateScrollPosition(~,~)
        if ~inArrange
            arrangeOuter();
        end
    end

    function arrangeInner(~,~)
        innerArrangeCallback();
        arrangeOuter();
    end
end