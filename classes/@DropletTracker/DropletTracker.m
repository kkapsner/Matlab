classdef DropletTracker < handle & Configable
    properties (SetObservable)
        dataSize
        startIndex = 1
        stopIndex
        numIntensities
        
        maxBorderDistance = 5
        maxRadiusChange = 0.2
        minMaxRadiusChange = 2
    end
    
    properties (Transient)
        droplets
        currentIndex = 0
        p1
        r1
        currentDropletIndices
    end
    
    methods
        function obj = DropletTracker(dataSize, numIntensities)
            if (nargin < 1)
                dataSize = 1;
            end
            if (nargin < 2)
                numIntensities = 1;
            end
            
            obj.dataSize = dataSize;
            obj.stopIndex = dataSize;
            obj.numIntensities = numIntensities;
        end
        
        function addFirstDroplets(obj, roi)
            obj.p1 = vertcat(roi.Centroid);
            obj.r1 = vertcat(roi.EquivDiameter) / 2;
            obj.currentIndex = obj.startIndex;
            
            obj.droplets = roi.Droplet(obj.dataSize, obj.currentIndex);
            obj.currentDropletIndices = 1:numel(roi);
        end
        
        function addDroplets(obj, roi)
            obj.currentIndex = obj.currentIndex + 1;
            
            if (isempty(roi))
                obj.p1 = [];
                obj.r1 = [];
                obj.currentDropletIndices = [];
            elseif (isempty(obj.p1))
                obj.addWithoutLink(roi);
            else
                p2 = vertcat(roi.Centroid);
                r2 = vertcat(roi.EquivDiameter) / 2;

                assignment = obj.track(obj.p1, obj.r1, p2, r2);
                unassigned = setxor(1:numel(roi), assignment(:, 2));

                % do tracking
                for i = 1:size(assignment, 1)
                    idx1 = assignment(i, 1);
                    idx2 = assignment(i, 2);
                    data = roi(idx2);
                    obj.droplets(obj.currentDropletIndices(idx1)).setFromROI( ...
                        data, ...
                        obj.currentIndex...
                    );
                end
                obj.currentDropletIndices = ...
                    obj.currentDropletIndices(assignment(:, 1));
                p2Ass = p2(assignment(:, 2), :);
                r2Ass = r2(assignment(:, 2));

                % add new droplets
                p2unAss = p2(unassigned, :);
                r2unAss = r2(unassigned);

                firstNewIndex = numel(obj.droplets) + 1;
                newIndices = firstNewIndex:(firstNewIndex + numel(unassigned));
                newDroplets = roi(unassigned).Droplet(obj.dataSize, obj.currentIndex);
                obj.droplets = [obj.droplets, newDroplets];
                obj.currentDropletIndices = ...
                    [obj.currentDropletIndices, newIndices];

                obj.p1 = [p2Ass; p2unAss];
                obj.r1 = [r2Ass; r2unAss];
            end
        end
    end
    
    methods
        assignment = track(obj, x1, y1, r1, x2, y2, r2)
    end
    
    methods (Access=private)
        function addWithoutLink(obj, roi)
            
            obj.p1 = vertcat(roi.Centroid);
            obj.r1 = vertcat(roi.EquivDiameter) / 2;
            
            firstNewIndex = numel(obj.droplets) + 1;
            newIndices = firstNewIndex:(firstNewIndex + numel(roi));
            newDroplets = roi.Droplet(obj.dataSize, obj.currentIndex);
            obj.droplets = [obj.droplets, newDroplets];
            obj.currentDropletIndices = newIndices;
        end
    end
end

