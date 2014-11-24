classdef OlympusTiffStack < TiffStack
    
    properties
        olympusInfo
    end
    
    methods
        function obj = OlympusTiffStack(file)
            obj = obj@TiffStack(file);
            obj.olympusInfo = OlympusTiffStack.readOlympusTags(obj.info);
        end
		
		time = getTime(this)
    end
    
    methods(Static)
        oInfo = readOlympusTags(info)
    end
end

