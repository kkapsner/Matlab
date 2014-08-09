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
            if (numel(name) == 1 && strcmp(name.type, '()') && numel(name.subs) > 1)
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
        
        function this = subsasgn(this, name, value)
            if (numel(name) == 1 && strcmp(name.type, '()') && numel(name.subs) > 1)
                
                firstName = name.subs{1};
                
                oneName = name;
                oneName.subs = oneName.subs(1);
                
                restName = name;
                restName.subs = restName.subs(2:end);
                if (this.isKey(firstName))
                    newSubValue = this.subsref(oneName);
                else 
                    newSubValue = JSONObject();
                end
                newSubValue.subsasgn(restName, value);
                this = this.subsasgn@containers.Map( ...
                    oneName, ...
                    newSubValue ...
                );
            else
                this.subsasgn@containers.Map(name, value);
            end
        end
    end
    
end

