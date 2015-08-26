classdef FilteredTiffStack < TiffStackDecorator
    %FilteredTiffStack
    
    properties(SetAccess=private)
        filter
    end
    properties(SetAccess=private, SetObservable)
        cutoffs
    end
    properties(SetObservable)
        filterOn = true
        normalise = true
    end
    
    methods
        function obj = FilteredTiffStack(stack, cutoffs)
            if (nargin == 0)
                stack = [];
            end
            obj = obj@TiffStackDecorator(stack);
            
            if (nargin > 0)
                if (nargin < 2)
                    cutoffs = [0 1000];
                end
                obj.setCutOffs(cutoffs);
            end
        end
    end
    
    methods
        function setCutOffs(this, cutoffs)
            for o = this
                o.cutoffs = cutoffs(1:2);
                o.filter = Image.getBandPassFilter( ...
                    [o.height, o.width], ...
                    o.cutoffs ...
                );
                o.clearCache();
            end
        end
        
        function set.filterOn(this, value)
            this.filterOn = value;
            this.clearCache();
        end
        
        function image = getUncachedImage(obj, index)
            image = obj.stack.getImage(index);
            if (obj.filterOn)
                fImage = fft2(image);
                image = ifft2(fImage .* obj.filter);
                if (obj.normalise)
                    minValue = min(image(:));
                    maxValue = max(image(:));
                    if (minValue ~= maxValue)
                        image = (image - minValue) / (maxValue - minValue);
                    end
                end
            end
        end
    end
    
    methods (Static)
        [panel, getParameter] = getGUIParameterPanel(parent)
    end
end

