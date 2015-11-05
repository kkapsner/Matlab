classdef MultiChannelTiffStack < TiffStackDecorator
    %MultiChannelTiffStack
    
    properties(SetObservable)
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
                for c = channel
                    MultiChannelTiffStack.assertChannel(c, numChannel);
                end
                MultiChannelTiffStack.assertNumChannel(numChannel, stack);
                
                for o = this
                    o.numChannel = numChannel;
                    o.channel = channel(1);
                end
                numberOfSelectedChannels = numel(channel);
                if (numberOfSelectedChannels > 1)
                    bunches = cell(numberOfSelectedChannels);
                    bunches{1} = this;
                    for i = 2:numberOfSelectedChannels
                        bunches{i} = MultiChannelTiffStack(stack, numChannel, channel(i));
                    end
                    s = size(this);
                    singularDim = find(s == 1, 1, 'first');
                    if (isempty(singularDim))
                        singularDim = numel(s) + 1;
                    end
                    
                    this = cat(singularDim, bunches{:});
                else
                end
            end
        end
        
        function set.numChannel(this, numChannel)
            MultiChannelTiffStack.assertNumChannel(numChannel, this.stack);
            this.numChannel = numChannel;
            this.clearCache();
            notify(this, 'nameChanged');
            notify(this, 'sizeChanged');
        end
        
        function set.channel(this, channel)
            MultiChannelTiffStack.assertChannel(channel, this.numChannel);
            this.channel = channel;
            this.clearCache();
            notify(this, 'nameChanged');
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
        function assertChannel(channel, numChannel)
            assert(isscalar(channel), 'Channel number must be a scalar.');
            assert(isreal(channel), 'Channel number must be real.');
            assert(mod(channel, 1) == 0, 'Channel number must be integer.');
            assert(channel > 0, 'Channel number must be greater than zero.');
            assert(isempty(numChannel) || channel <= numChannel, 'Channel number must be smaller of equal to numbers of channels.');
        end
        function assertNumChannel(numChannel, stack)
            assert(isscalar(numChannel), 'Number of channels must be a scalar.');
            assert(isreal(numChannel), 'Number of channels must be real.');
            assert(mod(numChannel, 1) == 0, 'Number of channels must be integer.');
            assert(numChannel > 0, 'Number of channels must be greater than zero.');
            assert(isempty(stack) || mod(stack.size, numChannel) == 0, 'Numbers of channels does not fit number of images in stack.');
        end
    end
end