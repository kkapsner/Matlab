function startBac = trackByHand(stack, fluorescenceStack, segmenter, currentImageIndex)
    startBac = [];
    endBac = [];
    endBacIdx = 0;
    
    lastROI = ROI.empty();
    currentROI = [];
    paintMode = false;
    painting = -1;
    paintBW = [];
    
    
    if (nargin < 4 || isempty(currentImageIndex))
        currentImageIndex = 1;
    end
    previousFrameOverlay = false(size(stack.getImage(currentImageIndex)));
    
    dm = DialogManager(stack);
    dm.open('Semiautomated tracking');
    
    set(dm.getFigure(), ...
        'ToolBar', 'figure', ...
        'HandleVisibility', 'callback', ...
        'WindowButtonMotionFcn', @figMouseMove, ...
        'WindowButtonUpFcn', @figButtonUp ...
    );
    aPanel = dm.addPanel();
    display = TiffStackDisplay(aPanel, stack, currentImageIndex);
    display.overlayVisible = true;
    
    segmenterDm = segmenter.dialog();
    segmenterDm.dependsOn(dm);
    dm.addDeleteListener( ...
        addlistener(segmenterDm, 'propertyChange', @segmenterChange) ...
    );
    
    dm.addPanel(1);
    autoTracking = dm.addCheckbox('auto tracking', 1, [0, 0, 100]);
    dm.checkboxHides(autoTracking, dm.addText('overlap >', [100, 0, 50]));
    overlapValue = dm.addInput(0.2, [150, 0, 30]);
    dm.checkboxHides(autoTracking, dm.addText('growth', [180, 0, 50]));
    growthMin = dm.addInput(0.95, [230, 0, 30]);
    dm.checkboxHides(autoTracking, dm.addText('-', [260, 0, 5]));
    growthMax = dm.addInput(1.1, [265, 0, 30]);
    
    dm.checkboxHides(autoTracking, [overlapValue, growthMin, growthMax]);
    
    dm.addToggleButton('paint mode', [300, 0, 100], @enterPaintMode, @leavePaintMode);
    
    stackSelect = dm.addPopupmenu( ...
        arrayfun(@(s)s.char(), [stack, fluorescenceStack], 'UniformOutput', false), ...
        [405 0 200], ...
        @hStackSelectCallback ...
    );
    function hStackSelectCallback(~, ~)
        currentStackIndex = stackSelect.Value;
        if (currentStackIndex == 1)
            display.stack = stack;
        else
            display.stack = fluorescenceStack(currentStackIndex - 1);
        end
    end

    dm.addPanel(1);
    prevButton = dm.addButton( ...
        sprintf('previous (%d)', currentImageIndex - 1), ...
        {@(w)0, @(w)w/2}, @toggleImage);
    nextButton = dm.addButton( ...
        sprintf('next (%d)', currentImageIndex +1), ...
        {@(w)w/2, @(w)w/2}, @nextImage);
    set(display.axes, 'ButtonDownFcn', @imageButtonDown);
    set(display.bwImage, 'ButtonDownFcn', @imageButtonDown);
    set(display.overlay, 'ButtonDownFcn', @imageButtonDown, 'Hit', 'on');
    set(dm.getFigure(), 'KeyPressFcn', @keyPress);
    display.overlayColors = [ ...
        1, 0, 0;
        0, 1, 0;
        0, 0, 1
    ];
    dm.show();

    segment();
    displayOverlays();
    dm.wait();
    
    function enterPaintMode(~,~)
        selectROI([]);
        paintMode = true;
        showCurrentImage();
        set([prevButton, nextButton], 'Visible', 'off');
        if (~isempty(lastROI))
            paintBW = lastROI.toImage();
        else
            paintBW = false(size(stack.getImage(currentImageIndex)));
        end
    end
    function leavePaintMode(~,~)
        set([prevButton, nextButton], 'Visible', 'on');
        paintMode = false;
        lastROI = segmenter.segmentEnhancedBW(paintBW);
        paintBW = [];
        if (~isempty(endBac))
            autoTrack();
        end
    end
    function startPaint()
        x = round(display.getCurrentPoint(1));
        y = round(display.getCurrentPoint(2));
        painting = ~paintBW(y, x);
        paint();
    end
    function paint()
        if (painting ~= -1)
            x = round(display.getCurrentPoint(1));
            y = round(display.getCurrentPoint(2));
            if (x > 0 && y > 0 && x <= size(paintBW, 2) && y <= size(paintBW, 1))
                paintBW(y, x) = painting;
                display.overlayImage = {paintBW, previousFrameOverlay, []};
            end
        end
    end
    function stopPaint()
        painting = -1;
    end
    
    function toggleImage()
        if (currentImageIndex > 1 && display.currentImageIndex == currentImageIndex)
            showPreviousImage();
        else
            showCurrentImage();
        end
    end
    function showCurrentImage()
        display.currentImageIndex = currentImageIndex;
        prevButton.String = sprintf('previous (%d)', currentImageIndex - 1);
    end
    function showPreviousImage(~,~)
        display.currentImageIndex = currentImageIndex - 1;
        prevButton.String = sprintf('current (%d)', currentImageIndex);
    end
    
    function segmenterChange(~,~)
        segment();
        selectROI([]);
    end
    
    function segment(~,~)
        lastROI = segmenter.segment(stack.getImage(currentImageIndex));
    end
    function selectROIByClick(~,~)
        selectROI(lastROI.findByPosition( ...
            round(display.getCurrentPoint(1)), ...
            round(display.getCurrentPoint(2)) ...
        ));
    end
    function selectROI(roi)
        if (numel(roi) > 0)
            if (isempty(currentROI))
                currentROI = roi;
            else
                alreadySelectedIdx = find(currentROI == roi);
                if (isempty(alreadySelectedIdx))
                    currentROI(end + 1) = roi;
                else
                    currentROI = [ ...
                        currentROI(1:(alreadySelectedIdx - 1)), ...
                        currentROI((alreadySelectedIdx + 1):end) ...
                    ];
                end
            end
        else
            currentROI = [];
        end
        displayOverlays();
    end

    function displayOverlays()
        if (~isempty(currentROI))
            display.overlayImage = {lastROI.toImage(), previousFrameOverlay, currentROI.toImage()};
        else
            display.overlayImage = {lastROI.toImage(), previousFrameOverlay, false(size(previousFrameOverlay))};
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
            selectROIByClick();
        end
    end
    function figButtonUp(~, ~)
        if (paintMode)
            stopPaint();
        else
        end
    end
    
    function keyPress(~, event)
        if (~paintMode && any(strcmp({'return', 'space'}, event.Key)))
            nextImage();
        end
    end

    function nextImage(~,~)
        if (~isempty(startBac) && numel(currentROI) > 2)
            msgbox('A bacterium can only divide in two bacteria.');
            return;
        end
        if (~isempty(currentROI))
            for i = 1:numel(fluorescenceStack)
                currentROI.loadIntensity( ...
                    fluorescenceStack(i).getImage(currentImageIndex), ...
                    5, ...
                    i, ...
                    fluorescenceStack(i) ...
                );
            end
        end
        
        
        if (isempty(startBac))
            if (isempty(currentROI))
                dm.close();
                return;
            else
                startBac = ROIBacterium([], currentROI);
                endBac = startBac;
                endBacIdx = Inf;
            end
        else
            if (numel(currentROI) > 1)
                newBacs = endBac(endBacIdx).split(currentROI);
                endBac = [ ...
                    endBac(1:(endBacIdx - 1)), ...
                    newBacs, ...
                    endBac((endBacIdx + 1):end) ...
                ];
                endBacIdx = endBacIdx + numel(newBacs);

            else

                if (isempty(currentROI))
                    endBac = [ ...
                        endBac(1:(endBacIdx - 1)), ...
                        endBac((endBacIdx + 1):end) ...
                    ];
                else
                    endBac(endBacIdx).appendROI(currentROI);
                    endBacIdx = endBacIdx + 1;
                end
            end
        end
        if (endBacIdx > numel(endBac))
            if (~isempty(endBac) && currentImageIndex < stack.size)
                currentImageIndex = currentImageIndex + 1;
                endBacIdx = 1;
                segment();
            else
                dm.close();
                return;
            end
        end
        for r = currentROI
            lastROI = lastROI(~(lastROI == r));
        end
        
        showCurrentImage();
        nextButton.String = sprintf('next (%d)', currentImageIndex + 1);
        previousFrameOverlay = endBac(endBacIdx).rois(end).toImage();
        
        autoTrack();
    end

    function autoTrack()
        currentROI = [];
        overlap = arrayfun( ...
            @(roi)numel(intersect(roi.PixelIdxList, endBac(endBacIdx).rois(end).PixelIdxList)), ...
            lastROI ...
        );
        [overlapSize, maxOverlap] = max(overlap);
        oldSize = numel(endBac(endBacIdx).rois(end).PixelIdxList);
        newSize = numel(lastROI(maxOverlap).PixelIdxList);
        selectROI(lastROI(maxOverlap));
        
        overlapPercent = overlapSize / oldSize;
        growth = newSize / oldSize;
        
        displayOverlays();
        drawnow('expose');
        
        
        if ( ...
            autoTracking.Value && ...
            overlapPercent > overlapValue.value && ...
            growth < growthMax.value && ...
            growth > growthMin.value ...
        )
            nextImage();
        end
    end
end