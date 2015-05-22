classdef Segmenter < handle & Configable
    %Segmenter is a class to provide image segmenting techniques
    
    properties (SetObservable)
        % whether the threshold should be computed for every image
        % seperately with graythresh (Otzus method)
        computeThreshold = true
        
        % if the threshold should not be computed the threshold to use
        threshold = 0.5
        
        % whether a filling algorithm should be performed on the binary
        % image to remove single black pixels
        performFilling = true
        
        % maximal hole size that should be closed by the filling algorithm
        fillingMaxHoleSize = 1
        
        % whether a dead end removing algorithm should be performed
        performDeadEndRemoving = false
        
        % whether a bridging algorithm should be performed on the binary
        % image to close small gaps in area borders
        performBridging = true
        
        % whether a thinning algorithm should be performed on the binary
        % image to make the white areas as big as possible
        performThinning = true
        
        % if the thinning algorithm is active if a black area that connects
        % to the image border should be force to connect to it afterwards.
        % This can introduce border artefacts!
        preserveBorderConnectionsOnThinning = false
        
        % whether a extrude algorithm should be proformed on the binary 
        % image to make the black areas bigger
        performExtrude = false
        
        % strength of the extrude algorithm
        extrudeStrength = 1
        
        % whether a watershed algorithm should be performed on the binary
        % image to separate regions with an intersection
        performWatershed = true
        
        % threshold for the eccentricity that must be overcome to start the
        % watershed algorithm on the specific ROI
        watershedEccentricityThreshold = 0.6
        
        % sigma for the gaussian filter that is performed before the
        % watershed algorithm
        watershedFilter = 8
        
        % threshold for the size of holes that get removed before
        % performing the distance measurement for the watershed
        watershedHoleThreshold = Inf
        
        % whether white areas touching the border should be removed
        clearBorder = true
        
        % range within the found segments have to be
        areaRange = [-Inf, Inf]
        
        % additional filters for the segmentation
        filters = SegmentFilter.empty()
    end
    
    methods
        roi = segment(this, image, stack)
        roi = enhanceBW(this, image)
        roi = segmentEnhancedBW(this, image, stack)
    end
end

