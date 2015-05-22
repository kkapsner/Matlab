classdef (Abstract) ConfigableProperty < handle
    %CONFIGABLEPROPERTY makes a class a writeable property to a ConfigAble
    %   
    %
    %   see also: ConfigAble
    
    methods(Abstract)
        value = toConfigString(this)
    end
    
    methods(Abstract, Static)
        obj = fromConfigString(str)
    end
end

