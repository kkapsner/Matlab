classdef ROIBacterium < Bacterium
    
    properties (SetAccess=private)
        rois
    end
    properties (Transient, SetAccess=private)
        lengths
    end
    
    properties (Dependent)
        allRois
        allLengths
    end
    
    methods
        function this = ROIBacterium(parent, roi)
            if (nargin == 0)
                return;
            end
            this@Bacterium(parent);
            
            if (numel(roi) > 1)
                this = ROIBacterium(parent, roi(1));
                for i = 2:numel(roi)
                    this(i) = ROIBacterium(parent, roi(i));
                end
            else
                this.rois = roi;
            end
        end
        
        function appendROI(this, roi)
            if (numel(roi) == 1)
                this.rois(end + 1) = roi;
            else
                error('Can not append multiple ROIs.');
            end
        end
        
        function bacteria = split(this, rois)
            if (numel(rois) > 1)
                bacteria = ROIBacterium(this, rois(1));
                for i = 2: numel(rois);
                    bacteria(i) = ROIBacterium(this, rois(i));
                end
            else
                error('Can not split with less than 2 ROIs.');
            end
        end
        
        function dataSize = getDataSize(this)
            if (~isempty(this.parent))
                dataSize = this.parent.getDataSize();
            else
                dataSize = 0;
            end
            dataSize = dataSize + numel(this.rois);
        end
        
        function allRois = get.allRois(this)
            allRois = this.getAllRois();
        end
        function allRois = getAllRois(this)
            if (~isempty(this.parent))
                allRois = [this.parent.allRois, this.rois];
            else
                allRois = this.rois;
            end
        end
        
        function [bacs, innerFrames] = getBacByFrame(this, frame)
            assert(frame > 0, 'ROIBacterium:getBacByFrame:invalidFrame', 'Invalid frame index');
            bacs = this.empty(1, 0);
            innerFrames = zeros(1, 0);
            for o = this
                if (frame <= numel(o.rois))
                    bac = o;
                    innerFrame = frame;
                elseif (~isempty(o.children))
                    [bac, innerFrame] = o.children.getBacByFrame(frame - numel(o.rois));
                else
                    bac = this.empty(1, 0);
                    innerFrame = zeros(1, 0);
                end
                if (~isempty(bac))
                    bacs = [bacs, bac];
                    innerFrames = [innerFrames, innerFrame];
                end
            end
        end
        function rois = getRoiByFrame(this, frame)
            [bacs, innerFrames] = this.getBacByFrame(frame);
            rois(numel(bacs)) = bacs(end).rois(innerFrames(end));
            for i = 1:numel(bacs)
                rois(i) = bacs(i).rois(innerFrames(i));
            end
        end
        function lengths = getLengthByFrame(this, frame)
            [bacs, innerFrames] = this.getBacByFrame(frame);
            lengths(numel(bacs)) = bacs(end).lengths(innerFrames(end));
            for i = 1:numel(bacs)
                lengths(i) = bacs(i).lengths(innerFrames(i));
            end
        end
        
        function calculateLengths(this, pixelSize)
            if (nargin < 2 || isempty(pixelSize))
                pixelSize = 1;
            end
            for o = this
                r = o.rois;
                l = zeros(size(r));
                for i = 1:numel(r)
                    [~, ~, length] = Polyline.roiToPolyline(r(i));
                    l(i) = length * pixelSize;
                end
                o.lengths = l;
                if (~isempty(o.children))
                    o.children.calculateLengths(pixelSize);
                end
            end
        end
        
        function allLenghts = get.allLengths(this)
            allLenghts = this.getAllLengths();
        end
        function allLenghts = getAllLengths(this)
            if (~isempty(this.parent))
                allLenghts = [this.parent.allLengths, this.lengths];
            else
                allLenghts = this.lengths;
            end
        end
        
        
        function value = getValue(this, property, getAll)
            if (nargin < 3)
                getAll = true;
            end
            
            property = strtrim(property);
            if (any(property == '*'))
                splitIdx = find(property == '*', 1, 'first');
                value = ...
                    this.getValue(property(1:(splitIdx - 1)), getAll) .* ...
                    this.getValue(property((splitIdx + 1):end), getAll);
            elseif (any(property == '/'))
                splitIdx = find(property == '/', 1, 'first');
                value = ...
                    this.getValue(property(1:(splitIdx - 1)), getAll) ./ ...
                    this.getValue(property((splitIdx + 1):end), getAll);
            elseif (any(property == '+'))
                splitIdx = find(property == '+', 1, 'first');
                value = ...
                    this.getValue(property(1:(splitIdx - 1)), getAll) + ...
                    this.getValue(property((splitIdx + 1):end), getAll);
            elseif (any(property == '-'))
                splitIdx = find(property == '-', 1, 'first');
                value = ...
                    this.getValue(property(1:(splitIdx - 1)), getAll) - ...
                    this.getValue(property((splitIdx + 1):end), getAll);
            else
                if (strcmp(property(1:min(end,10)), 'Intensity.'))
                    if (getAll)
                        intensities = [this.allRois.Intensity];
                    else
                        intensities = [this.rois.Intensity];
                    end
                    value = [intensities.(property(11:end))];
                elseif (strcmp(property(1:min(end, 6)), 'Length'))
                    if (getAll)
                        value = this.allLengths;
                    else
                        value = this.lengths;
                    end
                else
                    if (getAll)
                        value = [this.allRois.(property)];
                    else
                        value = [this.rois.(property)];
                    end
                end
            end
        end
        
        function traces = Trace(this, propertyOrTimeStep, property)
            if (nargin < 3)
                property = propertyOrTimeStep;
                timeStep = [];
            else
                timeStep = propertyOrTimeStep;
            end
            
            if (isempty(timeStep))
                timeStep = 1;
                timeOffset = 0;
                timeUnit = '#';
                timeName = 'Frame';
            else
                timeOffset = 1;
                timeUnit = 's';
                timeName = 'time';
            end
            
            endBac = this.getEndBacteria();
            maxLength = max([endBac.dataSize]);
            fullX = ((1:maxLength) - timeOffset) * timeStep;
            traces = RawDataTrace.empty(1, 0);
            for o = this
                traces = [traces, getTraces(o)];
            end
            function traces = getTraces(bac)
                if (isempty(bac.parent))
                    x = 1:bac.dataSize;
                else
                    x = (bac.parent.dataSize + 1):bac.dataSize;
                end
                y = bac.getValue(property, false);
                fullY = NaN(maxLength, 1);
                fullY(x) = y;
                traces = RawDataTrace(fullX, fullY);
                traces.valueName = property;
                traces.timeName = timeName;
                traces.timeUnit = timeUnit;
                for c = bac.children
                    traces = [traces, getTraces(c)];
                end
            end
        end
        
        function lines = plot(this, propertyOrTimeStep, property, varargin)
            if (nargin < 3)
                property = propertyOrTimeStep;
                timeStep = [];
            else
                timeStep = propertyOrTimeStep;
            end
            
            if (isempty(timeStep))
                timeStep = 1;
                timeOffset = 0;
            else
                timeOffset = 1;
            end
            
            arguments = cell(4 * numel(this), 1);
            for i = 1:numel(this)
                [x, y, xC, yC] = getData(this(i), 0, [], [], [NaN], [NaN]);
                arguments{1 + (i - 1) * 4} = (x - timeOffset) * timeStep;
                arguments{2 + (i - 1) * 4} = y;
                arguments{3 + (i - 1) * 4} = (xC - timeOffset) * timeStep;
                arguments{4 + (i - 1) * 4} = yC;
            end
            lines = plot(arguments{:}, varargin{:});
            for i = 1:numel(this)
                try
                    idxOffset = (i - 1) * 2;
                    lines(2 + idxOffset).Color = lines(1 + idxOffset).Color;
                    lines(2 + idxOffset).LineStyle = ':';
                catch e
                end
            end
            
            function [x, y, xC, yC] = getData(bac, offsetX, x, y, xC, yC)
                x = [x, NaN, (offsetX + 1):bac.dataSize];
                y = [y, NaN, bac.getValue(property, false)];
                offsetX = bac.dataSize;
                endX = x(end);
                endY = y(end);
                for child = bac.children
                    startIdx = numel(x) + 2;
                    [x, y, xC, yC] = getData(child, offsetX, x, y, xC, yC);
                    xC = [xC, NaN, endX, x(startIdx)];
                    yC = [yC, NaN, endY, y(startIdx)];
                end
            end
        end
    end
end