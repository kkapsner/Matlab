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
    set(dm.f, ...
        'ToolBar', 'figure', ...
        'HandleVisibility', 'callback' ...
    );
    aPanel = dm.addPanel();
    handles.display = TiffStackDisplay(aPanel, this, currentIndex);
    
    dm.addPanel(1, this.char());
    
    %% create bw control
    
    handles.bwOn = dm.addCheckbox('display BW', false, [0, 0, 80, 20]);
    
    if (isempty(segmenter))
        handles.closeOn = dm.addCheckbox('close', false, [80, 0, 50, 20]);

        handles.fillingOn = dm.addCheckbox('fill', false, [130 0 50 20]);

        handles.thinningOn = dm.addCheckbox('thin', false, [180 0 50 20]);

        handles.segmentingOn = dm.addCheckbox('segment', false, [230 0 80 20]);

        dm.checkboxHides(handles.bwOn, [handles.closeOn, handles.fillingOn, handles.thinningOn, handles.segmentingOn]);
    else
        handles.segmentColorsOn = dm.addCheckbox('colorise', false, [80, 0, 100, 20]);
        
        dm.checkboxHides(handles.bwOn, handles.segmentColorsOn);
        
        lastROI = [];
        createROIContextMenu();
    end
    
    this.getDialogPanel(dm, @updateImage);

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
    
    dm.f.Position(4) = 400;
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
            handles.display.overlayImage = getBWImage(this.getImage(currentIndex));
            handles.display.overlayVisible = true;
        else
            handles.display.overlayVisible = false;
        end
    end

    function image = getBWImage(image)
        if (~isempty(segmenter))
            lastROI = segmenter.segment(image);
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
            if (get(handles.segmentColorsOn, 'Value'))
                colorROIS = lastROI.separateToColorize();
                colors = hsv(numel(colorROIS));
                image = [];
                for colorIdx = 1:numel(colorROIS)
                    image = colorROIS{colorIdx}.toImage(image, colors(colorIdx, :));
                end
%                 for roiIdx = 1:6
%                     image = lastROI(roiIdx:6:end).toImage(image, colors(roiIdx,:));
%                 end
            else
                image = lastROI.toImage();
            end
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

    function menu = createROIContextMenu()
        menu = get(handles.display.bwImage, 'uicontextmenu');
        if (isempty(menu))
            menu = uicontextmenu('Parent', dm.f, 'Callback', @callback);
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
end

