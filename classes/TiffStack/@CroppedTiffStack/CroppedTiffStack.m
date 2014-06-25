classdef CroppedTiffStack < TiffStackDecorator
    %MultiChannelTiffStack
    
    properties (Dependent,SetObservable)
        xRange
        yRange
    end
    
    properties(Access=private)
        xRange_
        yRange_
    end
    
    methods
        function this = CroppedTiffStack(stack, xRange, yRange)
            if (nargin < 1)
                stack = [];
            end
            this = this@TiffStackDecorator(stack);
            
            if (nargin > 0)
                if (nargin < 2)
                    xRange = [1, stack.info(1).Width];
                end
                if (nargin < 3)
                    yRange = [1, stack.info(1).Height];
                end
                
                this.setXRange(xRange);
                this.setYRange(yRange);
            end
        end
        
        function xRange = get.xRange(this)
            xRange = this.xRange_;
        end
        
        function yRange = get.yRange(this)
            yRange = this.yRange_;
        end
        
        function set.xRange(this, xRange)
            this.setXRange(xRange);
            this.clearCache();
        end
        
        function set.yRange(this, yRange)
            this.setYRange(yRange);
            this.clearCache();
        end
        
        function setXRange(this, xRange)
            assert(isvector(xRange), 'X-Range must be a vector.');
            assert(numel(xRange) == 2, 'X-Range must be a vector with 2 entries.');

%             assert(round(xRange(1)) == xRange(1), 'X-Range start has to be an integer.');
%             assert(round(xRange(2)) == xRange(2), 'X-Range end has to be an integer.');

            assert(diff(xRange) > 0, 'X-Range start has to be smaller than the end.');

            assert(xRange(1) > 0, 'X-Range start has to be bigger than 0.');
            for o = this
                assert(xRange(2) <= o.stack.info(1).Width, 'X-Range end has to be smaller or equal to the image size.');
            end
            
            for o = this
                o.xRange_ = round(xRange);
            end
        end
        
        function setYRange(this, yRange)
            assert(isvector(yRange), 'Y-Range must be a vector.');
            assert(numel(yRange) == 2, 'Y-Range must be a vector with 2 entries.');

%             assert(round(yRange(1)) == yRange(1), 'Y-Range start has to be an integer.');
%             assert(round(yRange(2)) == yRange(2), 'Y-Range end has to be an integer.');

            assert(diff(yRange) > 0, 'Y-Range start has to be smaller than the end.');

            assert(yRange(1) > 0, 'Y-Range start has to be bigger than 0.');
            for o = this
                assert(yRange(2) <= o.stack.info(1).Height, 'Y-Range end has to be smaller or equal to the image size.');
            end
            
            for o = this
                o.yRange_ = round(yRange);
            end
        end
        function info = getInfo(this)
            info = this.stack.info;
            for i = 1:this.size
            	info(i).Width =  diff(this.xRange) + 1;
                info(i).Height = diff(this.yRange) + 1;
            end
        end
        
        function image = getUncachedImage(this, index)
            image = this.stack.getImage(index);
            image = image(this.yRange(1):this.yRange(2), this.xRange(1):this.xRange(2));
        end
    end
    
    methods(Static)
        [panel, getParameter] = getGUIParameterPanel(parent)
    end
end

