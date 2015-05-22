classdef ROI < Selectable & Binable & handle
    %ROI is the class for a region of interest
    
    properties
        segmentationStack
        intensityStacks = {}
    end
    
    properties (SetAccess=private)
        PixelIdxList
        width
        height
        
        Intensity
    end
    
    properties (SetAccess=private,Transient)
        % area estimation of the ROI
        Area
        
        %
        subX
        subY
        minX
        minY
        maxX
        maxY
        Centroid
    end
    
    properties (Dependent)
        EquivDiameter
        Image
        ConcaveImage
        Perimeter
        MajorAxisLength
        MinorAxisLength
        Eccentricity
        Orientation
        Cyclicity
        Concavity
    end
    properties (Access=private,Transient)
        EquivDiameter_
        Image_
        ConcaveImage_
        Perimeter_
        MajorAxisLength_
        MinorAxisLength_
        Eccentricity_
        Orientation_
        Cyclicity_
        Concavity_
    end
    
    %constructor
    methods
        function this = ROI(PixelIdxList, width, height, stack)
            if (nargin > 0)
                if (nargin < 4)
                    stack = height;
                    height = width(1);
                    width = width(2);
                end
                
                if (iscell(PixelIdxList))
                    numObj = numel(PixelIdxList);
                    if (numObj)
                        this(numObj) = ROI();
                        [this.PixelIdxList] = deal(PixelIdxList{:});
%                         [this.Area] = deal(cellfun(@numel, PixelIdxList, 'UniformOutput', false));
%                         [this.width] = deal(width);
%                         [this.height] = deal(height);
                        for i = 1:numObj
%                         for i=numObj:-1:1
%                             this(i).PixelIdxList = PixelIdxList{i};
                            this(i).Area = numel(PixelIdxList{i});
                            this(i).width = width;
                            this(i).height = height;
                            this(i).segmentationStack = stack;
                        end
                    end
                else
                    this.PixelIdxList = PixelIdxList;
                    this.Area = numel(PixelIdxList);
                    this.width = width;
                    this.height = height;
                    this.segmentationStack = stack;
                end
            end
        end
    end
    
    %getter
    methods
        function equivDiameter = get.EquivDiameter(this)
            if (isempty(this.EquivDiameter_))
                this.EquivDiameter_ = 2*sqrt(this.Area / pi);
            end
            equivDiameter = this.EquivDiameter_;
        end
        
        function image = get.Image(this)
            if (isempty(this.Image_))
                minX_ = this.minX;maxX_ = this.maxX;
                minY_ = this.minY;maxY_ = this.maxY;
                imageSize = [maxY_ - minY_ + 1, maxX_ - minX_ + 1];
                this.Image_ = false(imageSize);
                subX_ = this.subX - minX_ + 1;
                subY_ = this.subY - minY_ + 1;
                this.Image_((subX_ - 1) * imageSize(1) + subY_) = true;
                
%                 canvas = false(this.height, this.width);
%                 canvas(this.PixelIdxList) = true;
%                 this.Image_ = canvas(this.minY:this.maxY, this.minX:this.maxX);
            end
            image = this.Image_;
        end
        
        function concaveImage = get.ConcaveImage(this)
            if (isempty(this.ConcaveImage_))
                this.ConcaveImage_ = Image.convexHull(this.Image);
            end
            concaveImage = this.ConcaveImage_;
        end
        
        function perimeter = get.Perimeter(this)
            if (isempty(this.Perimeter_))
                this.Perimeter_ = Image.getPerimeter(this.Image);
            end
            perimeter = this.Perimeter_;
        end
        
        function MajorAxisLength = get.MajorAxisLength(this)
            if (isempty(this.MajorAxisLength_))
                this.calculateEllipse();
            end
            MajorAxisLength = this.MajorAxisLength_;
        end
        
        function MinorAxisLength = get.MinorAxisLength(this)
            if (isempty(this.MinorAxisLength_))
                this.calculateEllipse();
            end
            MinorAxisLength = this.MinorAxisLength_;
        end
        
        function Eccentricity = get.Eccentricity(this)
            if (isempty(this.Eccentricity_))
                this.calculateEllipse();
            end
            Eccentricity = this.Eccentricity_;
        end
        
        function Orientation = get.Orientation(this)
            if (isempty(this.Orientation_))
                this.calculateEllipse();
            end
            Orientation = this.Orientation_;
        end
        
        function Cyclicity = get.Cyclicity(this)
            if (isempty(this.Cyclicity_))
                this.Cyclicity_ = this.EquivDiameter * pi / this.Perimeter;
            end
            Cyclicity = this.Cyclicity_;
        end
        
        function Concavity = get.Concavity(this)
            if (isempty(this.Concavity_))
                this.Concavity_ = sum(this.Image(:))/sum(this.ConcaveImage(:));
            end
            Concavity = this.Concavity_;
        end
    end
    
    methods (Access=private)
        calculateEllipse(this)
    end
    
    %normal methods
    methods
        function initialiseProperties(this)
            for o = this
%                 if (isempty(o.subY))
                if ~isempty(o.PixelIdxList)
                    [o.subY, o.subX, data] = ...
                        getSub([o.height, o.width], o.PixelIdxList);
                    o.minY = data(1);
                    o.maxY = data(2);
                    o.minX = data(4);
                    o.maxX = data(5);
                    o.Centroid = [data(6), data(3)];
                end
                    
%                     [o.subY, o.subX] = ind2sub2D([o.height, o.width], o.PixelIdxList);
%                     [o.minX, o.maxX] = minmax(o.subX);
%                     [o.minY, o.maxY] = minmax(o.subY);
%                 end
            end
        end
        
        function loadIntensity(this, image, numIntensityPoints, stackIndex, stack)
            if (nargin < 2)
                numIntensityPoints = 5;
            end
            if (nargin < 3)
                stackIndex = 1;
            end
            if (nargin < 4)
                stack = [];
            end
            for o = this
                intensityValues = double(image(o.PixelIdxList));
                brightValues = im2bw(intensityValues, graythresh(intensityValues));
%                 properties = struct( ...
%                     'sum', sum(intensityValues), ...
%                     'min', sum(mink(intensityValues, numIntensityPoints) / numIntensityPoints), ...
%                     'max', sum(maxk(intensityValues, numIntensityPoints) / numIntensityPoints)...
%                 );
                properties.sum = sum(intensityValues);
                if (numel(intensityValues) >= numIntensityPoints)
                    properties.min = sum(mink(intensityValues, numIntensityPoints) / numIntensityPoints);
                    properties.max = sum(maxk(intensityValues, numIntensityPoints) / numIntensityPoints);
                else
                    properties.min = properties.sum / numel(intensityValues);
                    properties.max = properties.min;
                end

                properties.brightArea = sum(brightValues);
                properties.brightSum = sum(intensityValues(brightValues));
                
                if (isempty(o.Intensity) && stackIndex == 1)
                    o.Intensity = properties;
                else
                    o.Intensity(stackIndex) = properties;
                end
                
                o.intensityStacks{stackIndex} = stack;
            end
        end
        
        function image = toImage(this, image, color, alpha)
            if (numel(this))
                if (nargin < 2)
                    image = false(this(1).height, this(1).width);
                elseif (isempty(image))
                    image = zeros(this(1).height, this(1).width, 3);
                end
                
                pixelIdxList = vertcat(this.PixelIdxList);
                imageSize = size(image);
                switch (numel(imageSize))
                    case 2
                        image(pixelIdxList) = true;
                    case 3
                        if (nargin < 3)
                            color = [1, 1, 1];
                        end
                        if (nargin < 4)
                            alpha = 1;
                        end
                        
                        image(pixelIdxList) = (1 - alpha) * image(pixelIdxList) + alpha * color(1);
                        pixelIdxList = imageSize(1) * imageSize(2) + pixelIdxList;
                        image(pixelIdxList) = (1 - alpha) * image(pixelIdxList) + alpha * color(2);
                        pixelIdxList = imageSize(1) * imageSize(2) + pixelIdxList;
                        image(pixelIdxList) = (1 - alpha) * image(pixelIdxList) + alpha * color(3);
                    otherwise
                        error( ...
                            'ROI:toImage:invalidDimensions', ...
                            'Image has to be 2 or 3 dimensional.' ...
                        );
                end
            else
                if (nargin < 2)
                    image = false;
                end
            end
        end
        
        function video = toVideo(this)
            if (numel(this))
                video = false(this(1).height, this(1).width, numel(this));
                for i = 1:numel(this)
                    video(:,:,this(i).PixelIdxList) = true;
                end
            else
                video = false;
            end
        end
        
        function image = toSeparateColorImage(this, numColors, colorDist)
            if (nargin < 2)
                numColors = [];
            end
            if (nargin < 3)
                colorDist = [];
            end
            
            colorROIS = this.separateToColorize(numColors, colorDist);
            colors = hsv(numel(colorROIS));
            image = [];
            for colorIdx = 1:numel(colorROIS)
                image = colorROIS{colorIdx}.toImage(image, colors(colorIdx, :));
            end
        end
        
        function sameColor = separateToColorize(this, numColors, colorDist)
            if (nargin < 2 || isempty(numColors))
                numColors = 20;
            end
            if (nargin < 3 || isempty(colorDist))
                colorDist = 5;
            end
            
            numROIs = numel(this);
            colorMatrix = true(numROIs, numColors);
            
            neighbourhood = double(Image.circle(colorDist));
            for i = 1:numROIs
                color = find(colorMatrix(i, :), 1, 'first');
                if (isempty(color))
                    error('Not enough colors to colorize.');
                end
                colorMatrix(i, (color + 1):end) = false;
                
                distImage = conv2(double(this(i).toImage()), neighbourhood, 'same');
                for j = (i + 1):numROIs
                    if (any(distImage(this(j).PixelIdxList)))
                        colorMatrix(j, color) = false;
                    end
                end
            end
            
            sameColor = cell(numColors, 1);
            for i = 1:numColors
                sameColor{i} = this(colorMatrix(:, i));
                if (isempty(sameColor{i}))
                    sameColor = sameColor(1:(i-1));
                    break;
                end
            end
        end
        
        function obj = findByPosition(this, x, y)
            idx = y + (x - 1) * this(1).height;
            
            filter = false(size(this));
            for i = 1:numel(this)
                filter(i) = any(this(i).PixelIdxList == idx);
            end
            
            obj = this(filter);
        end
        
        d = Droplet(this, dataSize, currentIndex)
    end
    
    
    methods (Access=private)
        function resetProperties(this)
            for o = this
                o.Area = numel(o.PixelIdxList);
                o.subX = [];
                o.subY = [];
                o.minX = [];
                o.minY = [];
                o.maxX = [];
                o.maxY = [];
                o.Centroid = [];
                o.initialiseProperties();
                o.EquivDiameter_ = [];
                o.Image_ = [];
                o.ConcaveImage_ = [];
                o.Perimeter_ = [];
                o.MajorAxisLength_ = [];
                o.MinorAxisLength_ = [];
                o.Eccentricity_ = [];
                o.Orientation_ = [];
                o.Cyclicity_ = [];
                o.Concavity_ = [];
            end
        end
    end
    
    methods (Static)
        function o = loadobj(o)
            for this = o
                this.Area = numel(this.PixelIdxList);
            end
            o.initialiseProperties();
        end
        
        function o = create(stack)
            o = ROI([], stack.width, stack.height, stack);
            o.paint();
        end
    end
end

