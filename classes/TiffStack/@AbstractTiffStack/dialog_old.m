function dialog(this, waitForClose)
%DIALOG 
    if (nargin < 2)
        waitForClose = false;
    end
    
    if (numel(this) ~= 1)
        error('Stack dialog not available for array of stacks.');
    end
    
    currentIndex = 1;
    stackSize = this.size;
    
    padding = 5;
    innerPadding = 5;
    height = 400;
    width = 400;
    lineHeight = 20;
    
    %% create figure and axes
    handles.figure = figure( ...
        'HandleVisibility', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'figure', ...
        'Resize', 'on', ...
        'Position', [200 200 width height] ...
    );
    handles.axes = axes( ...
        'Parent', handles.figure, ...
        'Units', 'pixels', ...
        'Position', [5 100 390 300] ...
    );
    
    %% create image index slider
    handles.indexSlider = uicontrol( ...
        'Style', 'slider', ...
        'Parent', handles.figure, ...
        'Value', currentIndex, ...
        'Min', 1, ...
        'Max', stackSize, ...
        'SliderStep', [1/stackSize 5/stackSize], ...
        'Position', [5 5 390 20] ...
    );
    addlistener(handles.indexSlider, 'Value', 'PostSet', @indexSliderCallback);
    Gui.addSliderContextMenu(handles.indexSlider);
    
    handles.specialPanel = this.getDialogPanel(handles.figure, @updateImage);
    panelHeight = 0;
    for panel = handles.specialPanel
        pos = get(panel, 'Position');
        panelHeight = panelHeight + pos(4) + innerPadding;
    end
    
    %% create bw control
    handles.bwPanel = uipanel( ...
        'Parent', handles.figure, ...
        'Units', 'pixels', ...
        'BorderWidth', 0, ...
        'Position', [padding, 55, width - 2*padding, 20] ...
    );
    
    handles.bwOn = uicontrol( ...
        'Style', 'checkbox', ...
        'Parent', handles.bwPanel, ...
        'Value', false, ...
        'String', 'display BW', ...
        'Callback', @bwOnCallback, ...
        'Position', [0 0 80 20] ...
    );
    
    
    handles.closeOn = uicontrol( ...
        'Style', 'checkbox', ...
        'Parent', handles.bwPanel, ...
        'Value', false, ...
        'Visible', 'off', ...
        'String', 'close', ...
        'Callback', @closeOnCallback, ...
        'Position', [80 0 50 20] ...
    );
    
    handles.fillingOn = uicontrol( ...
        'Style', 'checkbox', ...
        'Parent', handles.bwPanel, ...
        'Value', false, ...
        'Visible', 'off', ...
        'String', 'fill', ...
        'Callback', @fillingOnCallback, ...
        'Position', [130 0 50 20] ...
    );
    
    handles.thinningOn = uicontrol( ...
        'Style', 'checkbox', ...
        'Parent', handles.bwPanel, ...
        'Value', false, ...
        'Visible', 'off', ...
        'String', 'thin', ...
        'Callback', @thinningOnCallback, ...
        'Position', [180 0 50 20] ...
    );
    
    handles.segmentingOn = uicontrol( ...
        'Style', 'checkbox', ...
        'Parent', handles.bwPanel, ...
        'Value', false, ...
        'Visible', 'off', ...
        'String', 'segment', ...
        'Callback', @thinningOnCallback, ...
        'Position', [230 0 80 20] ...
    );
    
    %% create file name control
    handles.fileName = uicontrol( ...
        'Style', 'text', ...
        'Parent', handles.figure, ...
        'String', this.char(), ...
        'Position', [5 75 390 20] ...
    );

    %% display first image
    updateImage(1, true);
    
    addlistener(handles.figure, 'SizeChange', @resizeCallback);
    resizeCallback();
    
%     imline(handles.axes);
    
    if (waitForClose)
        uiwait(handles.figure);
    end
    
    
    
    function updateImage(index, rescale)
        if (nargin < 1)
            index = currentIndex;
        end
        currentIndex = index;
        image = this.getImage(index);
        if (get(handles.bwOn, 'Value'))
            image = getBWImage(image);
        end
        xlim = get(handles.axes, 'XLim');
        ylim = get(handles.axes, 'YLim');
        Image.show(image, handles.axes);
%         colormap(handles.axes, lines(100));
        if (nargin < 2 || ~rescale)
            set(handles.axes, 'XLim', xlim, 'YLim', ylim);
        end
    end

    function image = getBWImage(image)
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
            image = bwlabel(image, 4);
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
    
    %% callbacks
    function resizeCallback(varargin)
        s = get(handles.figure, 'Position');
        
        innerWidth = s(3) - 2*padding;
        
        y = padding;
        set(handles.indexSlider, 'Position', [padding, y, innerWidth, lineHeight]);
        y = y + lineHeight + innerPadding;
        
        for i = 1:numel(handles.specialPanel)
            sPanel = handles.specialPanel(i);
            pPanel = get(sPanel, 'Position');
            set(sPanel, 'Position', [padding, y, innerWidth, pPanel(4)]);
            y = y + pPanel(4) + innerPadding;
        end
        
        set(handles.bwPanel, 'Position', [padding, y, innerWidth, lineHeight]);
        y = y + lineHeight + innerPadding;
        
        set(handles.fileName, 'Position', [padding, y, innerWidth, lineHeight]);
        y = y + lineHeight + innerPadding;
        
        set(handles.axes, 'Position', [padding, y, s(3)-2*padding, s(4)- padding - y]);
    end
    function indexSliderCallback(varargin)
        index = round(get(handles.indexSlider, 'Value'));
        set(handles.indexSlider, 'Value', index);
        updateImage(index);
    end
    function bwOnCallback(varargin)
        if (get(handles.bwOn, 'Value'))
           set(handles.closeOn, 'Visible', 'on');
           set(handles.fillingOn, 'Visible', 'on');
           set(handles.thinningOn, 'Visible', 'on');
           set(handles.segmentingOn, 'Visible', 'on'); 
        else
           set(handles.closeOn, 'Visible', 'off');
           set(handles.fillingOn, 'Visible', 'off');
           set(handles.thinningOn, 'Visible', 'off');
           set(handles.segmentingOn, 'Visible', 'off');
        end
        updateImage();
    end
    function closeOnCallback(varargin)
        updateImage();
    end
    function fillingOnCallback(varargin)
        updateImage();
    end
    function thinningOnCallback(varargin)
        updateImage();
    end
end

