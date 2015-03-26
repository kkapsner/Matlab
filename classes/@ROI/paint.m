function dm = paint(this)
    paintMode = true;
    painting = -1;
    paintBW = this.toImage();
    dm = DialogManager(this);
    dm.open('Paint ROI');
    
    set(dm.getFigure(), ...
        'ToolBar', 'figure', ...
        'HandleVisibility', 'callback', ...
        'WindowButtonMotionFcn', @figMouseMove, ...
        'WindowButtonUpFcn', @figButtonUp ...
    );
    aPanel = dm.addPanel();
    display = TiffStackDisplay(aPanel, this.segmentationStack, 1);
    display.overlayVisible = true;
    
    dm.addPanel(1);
    dm.addButton('paint circle', 80, @(~,~)startCircle());
    stackSelect = dm.addPopupmenu( ...
        arrayfun(@(s)s.char(), [this.segmentationStack, this.intensityStacks{:}], 'UniformOutput', false), ...
        {@(w)80, @(w)w-80}, ...
        @hStackSelectCallback ...
    );
    function hStackSelectCallback(~, ~)
        currentStackIndex = stackSelect.Value;
        if (currentStackIndex == 1)
            display.stack = this.segmentationStack;
        else
            display.stack = this.intensityStacks{currentStackIndex - 1};
        end
    end
    set(display.axes, 'ButtonDownFcn', @imageButtonDown);
    set(display.bwImage, 'ButtonDownFcn', @imageButtonDown);
    set(display.overlay, 'ButtonDownFcn', @imageButtonDown, 'Hit', 'on');
    display.overlayColors = [1, 0.5, 0];
    display.overlayImage = {paintBW};
    dm.show();
    dm.wait();
    this.PixelIdxList = find(paintBW);
    this.resetProperties();
    
    function startPaint()
        if (paintMode)
            x = round(display.getCurrentPoint(1));
            y = round(display.getCurrentPoint(2));
            painting = ~paintBW(y, x);
            paint();
        end
    end
    function paint()
        if (painting ~= -1)
            x = round(display.getCurrentPoint(1));
            y = round(display.getCurrentPoint(2));
            if (x > 0 && y > 0 && x <= size(paintBW, 2) && y <= size(paintBW, 1))
                paintBW(y, x) = painting;
                display.overlayImage = {paintBW};
            end
        end
    end
    function stopPaint()
        if (paintMode)
            painting = -1;
        end
    end
    
    function startCircle()
        c = imellipse(display.axes);
        c.wait();
        if (isvalid(c))
            paintBW = paintBW | c.createMask(display.bwImage);
            delete(c);
            display.overlayImage = {paintBW};
        end
    end
    
    
    function figMouseMove(~,~)
        paint();
    end
    function imageButtonDown(~, ~)
        startPaint();
    end
    function figButtonUp(~, ~)
        stopPaint();
    end
end