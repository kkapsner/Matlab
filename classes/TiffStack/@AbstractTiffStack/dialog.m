function dm = dialog(this, waitForClose, segmenter)
%DIALOG 
    if (nargin < 2)
        waitForClose = false;
    end
    if (nargin < 3)
        segmenter = [];
    end
    
    if (numel(this) ~= 1)
        error('Stack dialog not available for array of stacks.');
    end
    
    currentIndex = 1;
    stackSize = this.size;
    
    dm = DialogManager(this);
    
    dm.padding = 5;
    dm.innerPadding = 5;
    dm.height = 400;
    dm.width = 400;
    dm.lineHeight = 20;
    
    dm.open();
    
    %% create figure and axes
    set(dm.getFigure(), ...
        'ToolBar', 'figure', ...
        'HandleVisibility', 'callback' ...
    );
    aPanel = dm.addPanel();
    handles.display = TiffStackDisplay(aPanel, this, currentIndex);
    
%     dm.addPanel(1, this.char());
    this.getNamePanel(dm);
    dm.addPanel(1);
    
    %% create bw control
    
    handles.bwOn = dm.addCheckbox('display BW', false, [0, 0, 80, 20]);
    
    if (isempty(segmenter))
        handles.closeOn = dm.addCheckbox('close', false, [80, 0, 50, 20]);

        handles.fillingOn = dm.addCheckbox('fill', false, [130 0 50 20]);

        handles.thinningOn = dm.addCheckbox('thin', false, [180 0 50 20]);

        handles.segmentingOn = dm.addCheckbox('segment', false, [230 0 80 20]);

        dm.checkboxHides(handles.bwOn, [handles.closeOn, handles.fillingOn, handles.thinningOn, handles.segmentingOn]);
    else
        handles.segmentColorsOn = dm.addCheckbox('colorise', false, [80, 0, 60, 20]);
        dm.checkboxHides(handles.bwOn, handles.segmentColorsOn);
        segmenterButtonOffset = 160;
        segmenterPanel = dm.currentPanel;
        handles.addSegmenterButton = @addSegmenterButton;
        handles.setROIs = @setROIs;
        handles.getROIs = @getROIs;
        handles.setBWImage = @setBWImage;
        handles.getBWImage = @getDisplayedBWImage;
        
        lastROI = [];
        createROIContextMenu();
    end
    handles.update = @updateImage;
    this.getDialogPanel(dm, handles);

    %% create image index slider
    dm.addPanel(1);
    handles.indexSlider = handles.display.createIndexSlider( ...
        dm, ...
        @indexSliderCallback ...
    );
    function indexSliderCallback(varargin)
        index = round(get(handles.indexSlider, 'Value'));
%         set(handles.indexSlider, 'Value', index);
        currentIndex = index;
    end

    %% display first image
    updateImage(1);
    
    dm.container.Position(4) = 400;
    addlistener(dm, 'propertyChange', @(~,~)handles.display.refreshImage());
    addlistener(dm, 'propertyChange', @(~,~)updateBWImage());
    dm.show();
    dm.api = handles;
    if (waitForClose)
        dm.wait();
    end
    
    
    
    function updateImage(index)
        if (nargin < 1)
            index = currentIndex;
        end
        
        currentIndex = index;
        handles.display.currentImageIndex = index;
        
        updateBWImage()
    end

    function updateBWImage()
        if (get(handles.bwOn, 'Value'))
            setBWImage(getBWImage(this.getImage(currentIndex)));
            handles.display.overlayVisible = true;
        else
            handles.display.overlayVisible = false;
        end
    end
    
    function image = roi2Img(roi)
        if (get(handles.segmentColorsOn, 'Value'))
            colorROIS = roi.separateToColorize();
            colors = hsv(numel(colorROIS));
            image = [];
            for colorIdx = 1:numel(colorROIS)
                image = colorROIS{colorIdx}.toImage(image, colors(colorIdx, :));
            end
%                 for roiIdx = 1:6
%                     image = lastROI(roiIdx:6:end).toImage(image, colors(roiIdx,:));
%                 end
        else
            image = roi.toImage();
        end
    end
    function image = getBWImage(image)
        if (~isempty(segmenter))
            lastROI = segmenter.segment(image, this);
            dm.api.lastROI = lastROI;
            
%             assignin('base', 'classificationData', lastROI);
%             Gui.classificationPlot(lastROI, ...
%                 { ...
%                     'EquivDiameter', ...
%                     'Perimeter', ...
%                     'MajorAxisLength', ...
%                     'MinorAxisLength', ...
%                     'Eccentricity', ...
%                     'Orientation', ...
%                     'Cyclicity', ...
%                     'Concavity', ...
%                 } ...
%             );
            image = roi2Img(lastROI);
        else
            minV = double(min(image(:)));
            maxV = double(max(image(:)));

            image = (double(image) - minV) ./ (maxV - minV);

            image = im2bw(image, graythresh(image));
            if (get(handles.closeOn, 'Value'))
    %             image = ~bwmorph(~image, 'bridge');
                image = ~Image.bridge(~image);
            end
            if (get(handles.thinningOn, 'Value'))
                image = ~bwmorph(~image, 'thin', Inf);
            end
            if (get(handles.fillingOn, 'Value'))
                image = ~bwmorph(~image, 'clean');
            end
            if (get(handles.segmentingOn, 'Value'))
%                 image = bwlabel(image, 4);
    %             image = image == 2501;
    %             
    %             [h, w] = size(image);
    %             firstCol = 1:h;
    %             lastRow = ((2:(w-1))*h);
    %             image = image ~= imfill(image, [firstCol, lastRow, lastRow - h + 1, firstCol + (w-1)*h]', 8);
    % %             image = ~imfill(image, 8, 'holes');
    %             
    %             dist = Filter.gauss2D(-bwdist(image), 8);
    %             dist(image) = Inf;
    %             imageSeg = watershed(dist, 4);
    %             imageSeg(image) = 0;
    %             image = imageSeg;
            end
        end
    end

    function exportROI(~,~)
        assignin('base', 'exportedROIs', lastROI);
    end

    function menu = createROIContextMenu()
        menu = get(handles.display.axes, 'uicontextmenu');
        if (isempty(menu))
            menu = uicontextmenu('Parent', dm.getFigure(), 'Callback', @callback);
            set(handles.display.bwImage, 'uicontextmenu', menu);
        else
            set(menu, 'Callback', @callback);
        end
        
        menuItems = uimenu(menu, 'Label', 'Display ROI properties', 'Callback', @displayROI);
        
        currentROI = [];
        function callback(~,~)
            pos = round(handles.display.getCurrentPoint());
            
            if (~isempty(lastROI))
                currentROI = lastROI.findByPosition(pos(1, 1), pos(1, 2));
            else
                currentROI = [];
            end
            
            if (~isempty(currentROI))
                set(menuItems, 'Enable', 'on');
            else
                set(menuItems, 'Enable', 'off');
            end
        end
        
        function displayROI(~,~)
            if (~isempty(currentROI))
                currentROI(1).dialog();
            end
        end
    end
    
    function roi = getROIs()
        roi = lastROI;
    end
    function setROIs(roi)
        lastROI = roi;
        handles.display.overlayImage = roi2Img(roi);
    end
    function setBWImage(image)
        handles.display.overlayImage = image;
    end
    function image = getDisplayedBWImage()
        image = handles.display.overlayImage;
    end
    function button = addSegmenterButton(str, action)
        if (nargin < 2)
            if (strcmp(str, 'export'))
                button = addSegmenterButton('export ROI', @exportROI);
                return;
            end
        end
        w = warning('off', 'DialogManager:handleWithCare');
        dm.setCurrentPanel(segmenterPanel);
        warning(w);
        button = dm.addButton(str, [segmenterButtonOffset, 0, 20, 20], action);
        size = button.Extent;
        button.Position(3) = size(3) + 10;
        segmenterButtonOffset = segmenterButtonOffset + button.Position(3);
        dm.checkboxHides(handles.bwOn, button);
    end
end

