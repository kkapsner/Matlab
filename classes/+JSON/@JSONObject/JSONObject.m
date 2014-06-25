classdef JSONObject < containers.Map
    %JSONOBJECT extension of the containers.Map for better JSON
    %functionality
    
    properties
    end
    
    methods
        function this = JSONObject(varargin)
            this@containers.Map(varargin{:});
        end
        
        function value = subsref(this, name)
            if (numel(name) == 1 && numel(name.subs) > 1)
                oneName = name;
                oneName.subs = oneName.subs(1);
                value = this.subsref@containers.Map(oneName);
                
                restName = name;
                restName.subs = restName.subs(2:end);
                value = value.subsref(restName);
            else
                value = this.subsref@containers.Map(name);
            end
        end
    end
    
end

