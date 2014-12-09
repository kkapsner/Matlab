classdef ROIBacterium < Bacterium
    
    properties (SetAccess=private)
        rois
    end
    
    properties (Dependent)
        allRois
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
        
        function value = getValue(this, property)
            property = strtrim(property);
            if (any(property == '*'))
                splitIdx = find(property == '*', 1, 'first');
                value = ...
                    this.getValue(property(1:(splitIdx - 1))) .* ...
                    this.getValue(property((splitIdx + 1):end));
            elseif (any(property == '/'))
                splitIdx = find(property == '/', 1, 'first');
                value = ...
                    this.getValue(property(1:(splitIdx - 1))) ./ ...
                    this.getValue(property((splitIdx + 1):end));
            elseif (any(property == '+'))
                splitIdx = find(property == '+', 1, 'first');
                value = ...
                    this.getValue(property(1:(splitIdx - 1))) + ...
                    this.getValue(property((splitIdx + 1):end));
            elseif (any(property == '-'))
                splitIdx = find(property == '-', 1, 'first');
                value = ...
                    this.getValue(property(1:(splitIdx - 1))) - ...
                    this.getValue(property((splitIdx + 1):end));
            else
                if (strcmp(property(1:min(end,10)), 'Intensity.'))
                    intensities = [this.allRois.Intensity];
                    value = [intensities.(property(11:end))];
                else
                    value = [this.allRois.(property)];
                end
            end
        end
        
        function plot(this, property, varargin)
            arguments = cell(2 * numel(this));
            for i = 1:numel(this)
                arguments{1 + (i - 1) * 2} = 1:this(i).dataSize;
                arguments{2 + (i - 1) * 2} = this(i).getValue(property);
            end
            plot(arguments{:}, varargin{:});
        end
    end
end