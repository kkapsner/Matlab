classdef Sortable < handle
    %SORTABLE makes a class sortable by one of its properties
    
    properties
    end
    
    methods
        function [sorted, indices] = sort(obj, by, dim, mode)
            %SORTABLE.SORT
            %   BOBJ = OBJ.sort(by)
            %   BOBJ = OBJ.sort(by, dim)
            %   BOBJ = OBJ.sort(..., mode)
            %   [BOBJ, IX] = OBJ.sort(by, ...)
            if (nargin < 3 || isempty(dim))
                dim = find(size(obj) ~= 1, 1, 'first');
                if isempty(dim)
                    dim = 1;
                end
            end
            if (nargin < 4)
                mode = 'ascend';
            end
            [~, indices] = sort([obj.(by)], dim, mode);
            sorted = obj(indices);
        end
    end
    
end

