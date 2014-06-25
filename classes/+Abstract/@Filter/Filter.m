classdef (Abstract) Filter < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
    
    
    methods (Abstract)
        [filtered, filter] = filter(this, raw)
    end
end