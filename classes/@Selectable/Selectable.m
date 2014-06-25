classdef (Abstract) Selectable < handle
    %SELECTABLE 
    
    properties
    end
    
    methods
        function [selection, antiSelection, filter] = select(obj, varargin)
            %SELECTABLE.SELECT 
            %   OBJ.select(callback)
            %   OBJ.select(by, minValue)
            %   OBJ.select(..., includeMin = false)
            %   OBJ.select(..., maxValue)
            %   OBJ.select(..., includeMax = true)
            
            if (nargin == 2)
                filter = arrayfun(varargin{1}, obj);
            else
                by = varargin{1};
                assert(ischar(by) && isrow(by), 'by Parameter must be a row char.');
                
                values = [obj.(by)];
                
                minValue = varargin{2};
                if (nargin >= 4)
                    if (varargin{3})
                        minFilter = values >= minValue;
                    else
                        minFilter = values > minValue;
                    end
                else
                    minFilter = values > minValue;
                end
                if (nargin >=5)
                    maxValue = varargin{4};
                    if (nargin >= 6)
                        if (varargin{5})
                            maxFilter = values <= maxValue;
                        else
                            maxFilter = values < maxValue;
                        end
                    else
                        maxFilter = values <= maxValue;
                    end
                else
                    maxFilter = true;
                end
                
                filter = minFilter & maxFilter;
            end
            
            selection = obj(filter);
            antiSelection = obj(~filter);
        end
    end
    
end
