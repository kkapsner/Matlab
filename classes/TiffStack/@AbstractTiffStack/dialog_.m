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
    handles.axes = handle(axes( ...
        'Parent', aPanel, ...
        'Units', 'normalize', ...
        'HandleVisibility', 'callback', ...
        'Position', [0, 0, 1, 1] ...
    ));

    firstImage = mat2rgb(this.getImage(1));
    handles.image = handle(image('CData', firstImage, 'Parent', handles.axes));
    hold(handles.axes, 'on');
    handles.bwImage = handle(image('Parent', handles.axes, 'CData', firstImage, 'Visible', 'off'));
    axis(handles.axes, 'off');
    
    set(handles.axes, ...
        'DataAspectRatioMode', 'manual', ...
        'DataAspectRatio', [1, 1, 1], ...
        'PlotBoxAspectRatioMode', 'manual', ...
        'PlotBoxAspectRatio', [1, 1, 1], ...
        'YDir', 'reverse', ...
        'YTickMode', 'manual', ...
        'YTick', [], ...
        'XTickMode', 'manual', ...
        'XTick', [] ...
    );
    
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
        lastROI = [];
        createROIContextMenu();
    end
    
    this.getDialogPanel(dm, @updateImage);

    %% create image index slider
    dm.addPanel(1);
    handles.indexSlider = dm.addSlider(currentIndex, 1, stackSize, ...
        [0 0 0 20], @indexSliderCallback ...
    );
    function indexSliderCallback(varargin)
        index = round(get(handles.indexSlider, 'Value'));
%         set(handles.indexSlider, 'Value', index);
        currentIndex = index;
    end

    %% display first image
    updateImage(1);
    
    dm.container.Position(4) = 400;
    addlistener(dm, 'propertyChange', @(~,~)updateImage());
    dm.show();
    
%     imline(handles.axes);
    
    if (waitForClose)
        dm.wait();
    end
    
    
    
    function updateImage(index)
        if (nargin < 1)
            index = currentIndex;
        end
        
        currentIndex = index;
        handles.image.CData = mat2rgb(this.getImage(index));
        
        updateBWImage()
    end

    function updateBWImage()
        handles.bwImage.Visible = 'off';
        if (get(handles.bwOn, 'Value'))
            bwImage = getBWImage(this.getImage(currentIndex));
            imageSize = size(bwImage);
            cData = zeros(imageSize(1), imageSize(2), 3);
            cData(:,:,1) = bwImage; 
            handles.bwImage.CData = cData;
            handles.bwImage.AlphaData = bwImage * 0.15;
            handles.bwImage.Visible = 'on';
        end
    end

    function image = getBWImage(image)
        if (~isempty(segmenter))
            lastROI = segmenter.segment(image);
            image = lastROI.toImage();
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

    function grayImage = mat2rgb(image, color)
        if (nargin < 2)
            color = [1, 1, 1];
        end
        image = double(image);
        [min, max] = minmax(image(:));
        imageSize = size(image);
        image = (image - min) / (max - min);
        
        grayImage = zeros(imageSize(1), imageSize(2), 3);
        grayImage(:, :, 1) = image * color(1);
        grayImage(:, :, 2) = image * color(2);
        grayImage(:, :, 3) = image * color(3);
    end

    function menu = createROIContextMenu()
        menu = uicontextmenu('Parent', dm.getFigure(), 'Callback', @callback);
        
        menuItems = uimenu(menu, 'Label', 'Display ROI properties', 'Callback', @displayROI);
        
        set(handles.bwImage, 'uicontextmenu', menu);
        currentROI = [];
        function callback(~,~)
            pos = round(handles.axes.CurrentPoint);
            
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

