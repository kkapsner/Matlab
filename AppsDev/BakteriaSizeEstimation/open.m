function open()
    seg = Segmenter();
    stacksManager = StackManager();
    stacksManager.wait();
    tiffStacks = stacksManager.content;
    
    for i = 1:numel(tiffStacks)
        bfDm = tiffStacks{1}.dialog(false, seg);
        paintMode = false;
        paintImage = [];
        painting = -1;
        paintButton = bfDm.api.addSegmenterButton('paint', @togglePaint);
        paintButton.Style = 'togglebutton';
        set(bfDm.container, ...
            'WindowButtonMotionFcn', @figMouseMove, ...
            'WindowButtonUpFcn', @figButtonUp ...
        );
        set(bfDm.api.display.axes, 'ButtonDownFcn', @imageButtonDown);
        set(bfDm.api.display.bwImage, 'ButtonDownFcn', @imageButtonDown);
        set(bfDm.api.display.overlay, 'ButtonDownFcn', @imageButtonDown, 'Hit', 'on');
        
        sDm = seg.dialog();

        listeners = [
            addlistener(sDm, 'closeWin', @(~,~)bfDm.close()), ...
            addlistener(bfDm, 'closeWin', @(~,~)sDm.close()), ...
            addlistener(sDm, 'propertyChange', @(~,~)notify(bfDm, 'propertyChange')) ...
        ];
        addlistener(bfDm, 'closeWin', @(~,~)delete(listeners));
        dms = [sDm, bfDm];
        dms.arrange([1, 1]);

        bfDm.wait();
    end
    
    function togglePaint(~,~)
        if (~paintMode)
            rois = bfDm.api.getROIs();
            if (~isempty(rois))
                paintImage = rois.toImage();
            else
                paintImage = false(size(bfDm.api.getBWImage()));
            end
            bfDm.api.setBWImage(paintImage);
            paintMode = true;
        else
            bfDm.api.setROIs(seg.segmentEnhancedBW(paintImage));
            paintImage = [];
            paintMode = false;
        end
    end

    function figMouseMove(~,~)
        if (paintMode)
            paint();
        end
    end
    function imageButtonDown(~, ~)
        if (paintMode)
            startPaint();
        else
        end
    end
    function figButtonUp(~, ~)
        if (paintMode)
            stopPaint();
        else
        end
    end
    function startPaint()
        x = round(bfDm.api.display.getCurrentPoint(1));
        y = round(bfDm.api.display.getCurrentPoint(2));
        painting = ~paintImage(y, x);
        paint();
    end
    function paint()
        if (painting ~= -1)
            x = round(bfDm.api.display.getCurrentPoint(1));
            y = round(bfDm.api.display.getCurrentPoint(2));
            if (x > 0 && y > 0 && x <= size(paintImage, 2) && y <= size(paintImage, 1))
                paintImage(y, x) = painting;
                bfDm.api.setBWImage(paintImage);
            end
        end
    end
    function stopPaint()
        painting = -1;
    end
end

