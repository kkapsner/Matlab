classdef DropletTracking < handle
%DROPLETTRACKING is an app to track droplets in a video and to get their
%fluorescence values over time

    properties (SetObservable)
        folder = 0
        config
    end
    
    properties(SetAccess=public,SetObservable)
        segmenter
        tracker
        
        bfStacks
        fluoStacks
        filters
    end
    properties(Access=protected)
        handles
        
        numImages
        numFluo
    end
    
    methods
        function this = DropletTracking()
            this.bfStacks = {};
            this.fluoStacks = {};
        end
    end
end