classdef EventSettings < handle & AutoDialog & matlab.mixin.Copyable
    properties (SetObservable)
        th_mult_on = 7
        th_mult_off = 4
        sampleTime = 4e-6
        stdev = 1e4
        basePoints = 1000
        
        useMedian = true
        smoothWindowSize = 100
        
        peakEndBaselineRatio = 0.7
        
        lowerBaselineQuantile = 0.1
    end
    
end

