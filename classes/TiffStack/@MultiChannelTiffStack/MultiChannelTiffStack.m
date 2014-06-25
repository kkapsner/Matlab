classdef MultiChannelTiffStack < TiffStackDecorator
    %MultiChannelTiffStack
    
    properties(SetAccess=private)
        numChannel
        channel
    end
    
    methods
        function this = MultiChannelTiffStack(stack, numChannel, channel)
            if (nargin < 1)
                stack = [];
            end
            this = this@TiffStackDecorator(stack);
            
            if (nargin > 0)
                assert(isscalar(numChannel), 'Number of channels must be a scalar.');
                assert(isreal(numChannel), 'Number of channels must be real.');
                assert(mod(numChannel, 1) == 0, 'Number of channels must be integer.');
                assert(numChannel > 0, 'Number of channels must be greater than zero.');
                assert(mod(stack.size, numChannel) == 0, 'Numbers of channels does not fit number of images in stack.');

                assert(isscalar(channel), 'Channel number must be a scalar.');
                assert(isreal(channel), 'Channel number must be real.');
                assert(mod(channel, 1) == 0, 'Channel number must be integer.');
                assert(channel > 0, 'Channel number must be greater than zero.');
                assert(channel <= numChannel, 'Channel number must be smaller of equal to numbers of channels.');

                for o = this
                    o.numChannel = numChannel;
                    o.channel = channel;
                end
            end
        end
        
        function size = getSize(obj)
            size = obj.stack.size / obj.numChannel;
        end
        
        function image = getUncachedImage(obj, index)
            image = obj.stack.getImage((index - 1) * obj.numChannel + obj.channel);
        end
    end
    
    methods(Static)
        [panel, getParameter] = getGUIParameterPanel(parent)
    end
end

