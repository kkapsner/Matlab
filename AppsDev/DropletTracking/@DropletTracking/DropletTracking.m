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
        
        positions
        filters
    end
    properties(Dependent)
        bfStacks
        fluoStacks
    end
    properties(Access=protected)
        handles
        
        numImages
        numFluo
    end
    
    methods
        function this = DropletTracking()
            this.positions = {};
        end
        
        function bfStacks = get.bfStacks(this)
            bfStacks = cellfun(@(p)p.stacks{1}, this.positions, 'Uniform', false);
        end
        
        function fluoStacks = get.fluoStacks(this)
            fluoStacks = cellfun(@(p)p.stacks(2:end), this.positions, 'Uniform', false);
        end
    end
end