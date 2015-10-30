classdef Droplet < handle & Selectable
    
    properties
        p
        radius
        perimeter
        minIntensity
        maxIntensity
        intensitySum
        brightIntensitySum
        brightArea
        lastIndex
        
        stacks
    end
    
    properties(Dependent)
        dataSize
        startIndex
        meanRadius
        meanPerimeter
        meanCyclicity
    end
    
    methods
        function obj = Droplet(numDatapoints, numDroplets, numIntensities)
            if (nargin ~= 0)
                if (nargin < 2)
                    numDroplets = 1;
                end
                if (numDroplets > 0)
                    obj(numDroplets) = Droplet;
                    nanVector = NaN(numDatapoints, 1);
                    bigNanVector = NaN(numDatapoints, numIntensities);
                    for o = obj
                        o.p = [nanVector, nanVector];
                        o.radius = nanVector;
                        o.perimeter = nanVector;
                        o.minIntensity = bigNanVector;
                        o.maxIntensity = bigNanVector;
                        o.intensitySum = bigNanVector;
                        o.brightIntensitySum = bigNanVector;
                        o.brightArea = bigNanVector;
                        o.lastIndex = NaN;
                    end
                else
                    obj = Droplet.empty;
                end
            end
        end
        
        function dataSize = get.dataSize(obj)
            dataSize = sum(~isnan(obj.radius));
        end
        
        function startIndex = get.startIndex(obj)
            startIndex = find(~isnan(obj.radius), 1, 'first');
        end
        
        function meanRadius = get.meanRadius(obj)
            meanRadius = mean(obj.radius(~isnan(obj.radius)));
        end
        function meanPerimeter = get.meanPerimeter(obj)
            meanPerimeter = mean(obj.perimeter(~isnan(obj.radius)));
        end
        function meanCyclicity = get.meanCyclicity(obj)
            meanCyclicity = mean( ...
                obj.radius(~isnan(obj.radius)) * 2 * pi ./ ...
                obj.perimeter(~isnan(obj.radius)) ...
            );
        end
        
        function set(obj, p, radius, perimeter, intensity, idx)
            warning('Droplet:set:deprecated', 'Droplet.set() is deprecated');
            obj.p(idx, :) = p;
            obj.radius(idx) = radius;
            obj.perimeter(idx) = perimeter;
            obj.minIntensity(idx, :) = [intensity.min];
            obj.maxIntensity(idx, :) = [intensity.max];
            obj.intensitySum(idx, :) = [intensity.sum];
            obj.brightIntensitySum(idx, :) = [intensity.brightSum];
            obj.brightArea(idx, :) = [intensity.brightArea];
            obj.lastIndex = idx;
        end
        
        function setFromROI(obj, roi, idx)
            obj.p(idx, :) = roi.Centroid;
            obj.radius(idx) = roi.EquivDiameter / 2;
            obj.perimeter(idx) = roi.Perimeter;
            
            intensity = roi.Intensity;
            if (~isempty(intensity))
                obj.minIntensity(idx, :) = [intensity.min];
                obj.maxIntensity(idx, :) = [intensity.max];
                obj.intensitySum(idx, :) = [intensity.sum];
                obj.brightIntensitySum(idx, :) = [intensity.brightSum];
                obj.brightArea(idx, :) = [intensity.brightArea];
            end
            
            obj.lastIndex = idx;
        end
        
        function p = getLastPosition(obj)
            p = vertcat(obj.p(obj(1).lastIndex, :));
        end
        
        function copyDataFromDroplet(this, droplet, startIndex)
            if (nargin < 3)
                startIndex = 3;
            end
            
            if (numel(this) == numel(droplet))
                for i = 1:numel(this)
                    this(i).p(startIndex:end, :) = droplet(i).p(startIndex:end, :);
                    this(i).radius(startIndex:end, :) = droplet(i).radius(startIndex:end, :);
                    this(i).perimeter(startIndex:end, :) = droplet(i).perimeter(startIndex:end, :);
                    this(i).minIntensity(startIndex:end, :) = droplet(i).minIntensity(startIndex:end, :);
                    this(i).maxIntensity(startIndex:end, :) = droplet(i).maxIntensity(startIndex:end, :);
                    this(i).intensitySum(startIndex:end, :) = droplet(i).intensitySum(startIndex:end, :);
                    this(i).brightIntensitySum(startIndex:end, :) = droplet(i).brightIntensitySum(startIndex:end, :);
                    this(i).brightArea(startIndex:end, :) = droplet(i).brightArea(startIndex:end, :);
                end
            else
                error('Droplet:copyDataFromDroplet:numberMissmatch', ...
                    'Number of droplet differ.');
            end
        end
    end
    
    methods
        index = findDroplet(obj, p, dataIndex)
        dm = guiExport(this)
        dm = dialog(this, selectionDisplay)
        
        video = getVideo(this, stackIndex, varargin)
        
        droplet = trackByHand(this)
        
        droplet = merge(this)
        
        display = displaySelection(this)
    end
    
end
