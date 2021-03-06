classdef TiffStackDisplay < handle
    %TiffStackDisplay
    
    properties (SetObservable,AbortSet)
        stack
        currentImageIndex
        overlayVisible = false
        
        minIntensity = 0
        maxIntensity = 255
        autoStrechIntensity = true
        ignoreLowAndHigh = 0.02
        
        overlayColors = [];
    end
    properties (Dependent)
        overlayImage
        image
    end
    properties (SetAccess=private)
        axes
        bwImage
        overlay
    end
    properties (Access=private)
        setEvent = true
    end
    
    events
        imageLoad
    end
    
    methods
        function this = TiffStackDisplay(parentElement, stack, index)
            this.stack = stack;
            this.currentImageIndex = index;
            
            this.axes = handle(axes( ...
                'Parent', parentElement, ...
                'Units', 'normalize', ...
                'HandleVisibility', 'callback', ...
                'Position', [0, 0, 1, 1] ...
            ));
        
            firstImage = stack.getImage(index);
            if (ismatrix(firstImage))
                firstImage = TiffStackDisplay.mat2rgb(firstImage);
            end
            this.bwImage = handle(image('CData', firstImage, 'Parent', this.axes, 'Clipping', 'off'));
            hold(this.axes, 'on');
            this.overlay = handle(image('Parent', this.axes, 'CData', firstImage, 'Visible', 'off', 'Hit', 'off', 'Clipping', 'off'));

            set(this.axes, ...
                'DataAspectRatioMode', 'manual', ...
                'DataAspectRatio', [1, 1, 1], ...
                'PlotBoxAspectRatioMode', 'manual', ...
                'PlotBoxAspectRatio', [stack.width, stack.height, 1], ...
                'YDir', 'reverse', ...
                'YTickMode', 'manual', ...
                'YTick', [], ...
                'XTickMode', 'manual', ...
                'XTick', [], ...
                'Clipping', 'off' ...
            );
            
            matlabVersion = version();
            matlabVersion = sscanf(matlabVersion, '%d.');
            if (matlabVersion(1) < 8 || matlabVersion(2) < 4)
                axis(this.axes, 'off');
            else
                set(this.axes, ...
                    'XColor', 'none', ...
                    'YColor', 'none' ...
                );
            end
            
            Gui.enableWheelZoom(this.axes, [1, 1, 0], 1.5);
            
            this.createContextMenu();
        
            addlistener(this, 'stack', 'PostSet', @refreshImage);
            addlistener(this, 'currentImageIndex', 'PostSet', @refreshImage);
            addlistener(this, 'minIntensity', 'PostSet', @refreshImage);
            addlistener(this, 'maxIntensity', 'PostSet', @refreshImage);
            addlistener(this, 'autoStrechIntensity', 'PostSet', @refreshImage);
            addlistener(this, 'ignoreLowAndHigh', 'PostSet', @refreshImage);
            addlistener(this, 'overlayVisible', 'PostSet', @updateOverlayVisible);
            refreshImage();
            
            function updateOverlayVisible(~,~)
                if (this.overlayVisible)
                    this.overlay.Visible = 'on';
                else
                    this.overlay.Visible = 'off';
                end
            end
            function refreshImage(~,~)
                if (this.setEvent)
                    this.refreshImage();
                end
            end
        end
        
        function image = get.image(this)
            image = this.stack.getImage(this.currentImageIndex);
        end
        function set.overlayImage(this, overlayImage)
            if (iscell(overlayImage) && ~isempty(overlayImage))
                if (isempty(this.overlayColors))
                    numDifferentColors = 6;
                    colors = prism(numDifferentColors);
                else
                    numDifferentColors = size(this.overlayColors, 1);
                    colors = this.overlayColors;
                end
                
                imageSize = size(overlayImage{find(cellfun(@(c)~isempty(c), overlayImage), 1, 'first')});
                
                cData = zeros(imageSize(1), imageSize(2), 3);
                alphaData = zeros(imageSize);
                normalisationData = zeros(imageSize(1), imageSize(2), 3);
                for i = 1:numel(overlayImage)
                    if (~isempty(overlayImage{i}))
                        cData(:,:,1) = cData(:,:,1) + colors(mod(i - 1,numDifferentColors) + 1, 1) * overlayImage{i}; 
                        cData(:,:,2) = cData(:,:,2) + colors(mod(i - 1,numDifferentColors) + 1, 2) * overlayImage{i}; 
                        cData(:,:,3) = cData(:,:,3) + colors(mod(i - 1,numDifferentColors) + 1, 3) * overlayImage{i}; 

                        alphaData = alphaData | overlayImage{i};
                        normalisationData(:,:,1) = normalisationData(:,:,1) + overlayImage{i};
                        normalisationData(:,:,2) = normalisationData(:,:,2) + overlayImage{i};
                        normalisationData(:,:,3) = normalisationData(:,:,3) + overlayImage{i};
                    end
                end
                this.overlay.CData = cData ./ normalisationData;%min(1, cData);
                this.overlay.AlphaData = alphaData * 0.15;
                
            else
                imageSize = size(overlayImage);
                if (numel(imageSize) ~= 3)
                    cData = zeros(imageSize(1), imageSize(2), 3);
                    cData(:,:,1) = overlayImage;
                else
                    cData = overlayImage;
                    overlayImage = max(overlayImage, [], 3);
                end
                this.overlay.CData = cData;
                this.overlay.AlphaData = overlayImage * 0.15;
            end
        end
        
        function refreshImage(this)
            image = double(this.stack.getImage(this.currentImageIndex));
            if (this.autoStrechIntensity)
                this.setEvent = false;
                if (this.ignoreLowAndHigh > 0)
                    this.minIntensity = quantile(image(:), this.ignoreLowAndHigh);
                    this.maxIntensity = quantile(image(:), 1 - this.ignoreLowAndHigh);
                else
                    [this.minIntensity, this.maxIntensity] = minmax(image(:));
                end
                this.setEvent = true;
            end 
            
            if (ismatrix(image))
                image = TiffStackDisplay.mat2rgb(...
                    image, ...
                    [1, 1, 1], ...
                    [this.minIntensity, this.maxIntensity]...
                );
            end
            this.bwImage.CData = image;
            notify(this, 'imageLoad');
        end
        
        function point = getCurrentPoint(this, dim)
            if (nargin < 2)
                point = this.axes.CurrentPoint;
            else
                point = this.axes.CurrentPoint(1, dim);
            end
        end
        
        function indexSlider = createIndexSlider(this, dm, callback)
            if (nargin < 3)
                callback = @(a)a;
            end
            if (this.stack.size > 1)
                indexSlider = dm.addSlider( ...
                    this.currentImageIndex, ...
                    1, ...
                    this.stack.size, ...
                    [0 0 0 20], @indexSliderCallback ...
                );
                set(indexSlider, 'SliderStep', [1, 10]./(this.stack.size - 1));
            else
                indexSlider = dm.addSlider( ...
                    this.currentImageIndex, ...
                    1, ...
                    2, ...
                    [0 0 0 20], @indexSliderCallback ...
                );
                indexSlider.Visible = 'off';
            end
            l = [
                addlistener(this.stack, 'sizeChanged', @updateSize)
                addlistener(indexSlider, 'ObjectBeingDestroyed', @removeListeners)
            ];
            function indexSliderCallback(varargin)
                index = round(get(indexSlider, 'Value'));
        %         set(handles.indexSlider, 'Value', index);
                this.currentImageIndex = index;
                callback(varargin{:});
            end
            function updateSize(~,~)
                indexSlider.Visible = Gui.booleanToStr(this.stack.size > 1);
                if (indexSlider.Value > this.stack.size)
                    this.currentImageIndex = this.stack.size;
                    indexSlider.Value = this.stack.size;
                end
                if (this.stack.size > 1)
                    indexSlider.Max = this.stack.size;
                    set(indexSlider, 'SliderStep', [1, 10]./(this.stack.size - 1));
                end
            end
            function removeListeners(~,~)
                delete(l);
            end
        end
        
        function is = ishandle(this)
            is = ishandle(this.axes);
        end
    end
    
    methods (Access=private)
        function createContextMenu(this)
            
            menu = uicontextmenu('Parent', Gui.getParentFigure(this.axes));
            set(this.bwImage, 'uicontextmenu', menu);
            set(this.overlay, 'uicontextmenu', menu);
            set(this.axes, 'uicontextmenu', menu);
        
            uimenu(menu, 'Label', 'Set brightness/contrast', 'Callback', @setBrightnessContrast);
            
            function setBrightnessContrast(~, ~)
                dm = DialogManager(this);
                dm.open();
                
                
                axesPanel = dm.addPanel();
                ax = handle(axes( ...
                    'Parent', axesPanel, ...
                    'Units', 'normalized', ...
                    'OuterPosition', [0, 0, 1, 1], ...
                    'HandleVisibility', 'callback' ...
                ));
                hHist = bar(0, 'Parent', double(ax));
                updateHist();
                
                dm.addPanel(3);
                dm.addPropertyCheckbox('auto strech', 'autoStrechIntensity', {@(w)0, @(w)(w/2-150)});
                dm.addText('ignore quantile', {@(w)w/2 - 150, @(w)100});
                dm.addPropertyInput('ignoreLowAndHigh', {@(w)w/2 - 50, @(w)100});
                dm.addButton('auto strech all', {@(w)w/2+50, @(w)w/2-50}, @autoStrechAll);
                dm.newLine();
                dm.addText('min', 40);
                dm.addPropertySlider('minIntensity', mi, ma, {@(w)40, @(w)w-40});
                dm.newLine();
                dm.addText('max', 40);
                dm.addPropertySlider('maxIntensity', mi, ma, {@(w)40, @(w)w-40});
                
                minLine = Gui.imvline(ax, this.minIntensity);
                maxLine = Gui.imvline(ax, this.maxIntensity);
                addlistener(minLine, 'newPosition', @minLineCallback);
                addlistener(maxLine, 'newPosition', @maxLineCallback);
                
                l = [ ...
                    addlistener(this, 'imageLoad', @updateHist), ...
                    addlistener(this, 'minIntensity', 'PostSet', @updateMinLine), ...
                    addlistener(this, 'maxIntensity', 'PostSet', @updateMaxLine), ...
                ];
            
                addlistener(dm, 'closeWin', @(~, ~)delete(l));
                dm.show();
                function updateHist(~,~)
                    data = double(this.stack.getImage(this.currentImageIndex));
                    data = data(:);
                    [mi, ma] = minmax(data);
                    [y, x] = hist(data(:), 255);
                    set(hHist, 'XData', x, 'YData', y);
                end
                function minLineCallback(~, ~)
                    this.minIntensity = minLine.position;
                end
                function updateMinLine(~, ~)
                    minLine.position = this.minIntensity;
                end
                function maxLineCallback(~, ~)
                    this.maxIntensity = maxLine.position;
                end
                function updateMaxLine(~, ~)
                    maxLine.position = this.maxIntensity;
                end
                function autoStrechAll(~, ~)
                    this.autoStrechIntensity = false;
                    
                    [mi, ma] = this.stack.getZProjection(@minmax);
                    this.minIntensity = min(mi);
                    this.maxIntensity = max(ma);
                end
            end
        end
    end
    
    methods (Static)
        function grayImage = mat2rgb(image, color, cLim)
            if (nargin < 3)
                color = [1, 1, 1];
            end
            image = double(image);
            if (nargin < 3)
                [min, max] = minmax(image);
            else
                min = cLim(1);
                max = cLim(2);
            end
                
            imageSize = size(image);
            image = (image - min) / (max - min);
            
            image(image < 0) = 0;
            image(image > 1) = 1;

            grayImage = zeros(imageSize(1), imageSize(2), 3);
            grayImage(:, :, 1) = image * color(1);
            grayImage(:, :, 2) = image * color(2);
            grayImage(:, :, 3) = image * color(3);
        end
    end
    
end

