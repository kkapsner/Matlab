function result = randomPoints(trace)
%RANDOMPOINTS 
    result = struct();
    
    result.peakOn = randi(numel(trace), 4, 2);
    result.peakOff = randi(numel(trace), 4, 2);
end

