function data = start()
    seg = Segmenter();
    stacksManager = StackManager();
    stacksManager.wait();
    tiffStacks = stacksManager.content;
    
    data = struct('frames', [], 'rois', {});
    
    for i = 1:numel(tiffStacks)
        currentData = struct();
        currentData.frames = [];
        currentData.rois = {};
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
        
        exportButton = bfDm.api.addSegmenterButton('save ROIs', @saveROIs);
        showLengthButton = bfDm.api.addSegmenterButton('show length', @showLength);
        
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
        data(i) = currentData;
    end
    
    % paint logic
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
            exportButton.Visible = 'off';
            showLengthButton.Visible = 'off';
        else
            bfDm.api.setROIs(seg.segmentEnhancedBW(paintImage));
            paintImage = [];
            paintMode = false;
            exportButton.Visible = 'on';
            showLengthButton.Visible = 'on';
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

    function saveROIs()
       if (~paintMode)
           currentData.frames(end + 1) = bfDm.api.display.currentImageIndex;
           currentData.rois{end + 1} = bfDm.api.getROIs();
           bfDm.api.indexSlider.Value = bfDm.api.display.currentImageIndex + 1;
       end
    end

    function showLength()
        if (~paintMode)
            rois = bfDm.api.getROIs();
            image = false(size(bfDm.api.display.image));
            for roi = rois(:)'
                rImage = Image.localConvexHull(roi.Image, 2);
%                 skel = logical(rImage);
%                 skel = bwmorph(rImage, 'skel', Inf);
                skel = bwmorph(rImage, 'thin', Inf);
                skel = Image.elongateEndPoints(skel, rImage, 4);
                [~, idx1, idx2] = Image.getMaxContour(skel);
                skel = Image.getShortestPath(skel, idx1, idx2);
                image(roi.minY:roi.maxY, roi.minX:roi.maxX) = ...
                    image(roi.minY:roi.maxY, roi.minX:roi.maxX) | ...
                    skel;
            end
            
            bfDm.api.setBWImage(image);
        end
    end
end

