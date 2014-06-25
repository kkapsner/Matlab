function steps = detectSteps(data, varargin)
%DETECTSTEPS
%
% STEPS = detectSteps(DATA) detects the steps in the DATA vector and stores
% the positions of the steps in the vector STEPS.
% STEPS = detectSteps(..., paramKey, paramValue)
%
% Parameter:
%           medianLength  (3)    : the median filter half window size
%           comparePoint  (0.9)  : the compare quantile
%           compareFactor (5)    : the compare factor
%           debug         (false): flag for debug mode

    %% get input parameter
    p = inputParser;
    p.addParamValue('medianLength', 3, @(x)x==round(x)&&x>0);
    p.addParamValue('comparePoint', 0.9, @isnumeric);
    p.addParamValue('compareFactor', 5, @isnumeric);
    p.addParamValue('debug', false, @islogical);
    p.parse(varargin{:});
    
    % the filter length
    medianLength = p.Results.medianLength;
    % the point in the population to compare with (i.e. the quantile)
    comparePoint = p.Results.comparePoint;
    % the factor by which the compare point has to be mulipied to get the
    % threshold
    compareFactor = p.Results.compareFactor;
    
    %% data too short
    if (numel(data) < 2*medianLength + 1)
        steps = [];
        return
    end
    
    %% validate data input
    assert(isvector(data), 'detectSteps:dataNoVector', 'Data has to be a vector.');
    
    %% filter data, calculate derivative and generate threshold
    filteredData = medfilt1(data, 2*medianLength + 1);
    dFilteredData = abs(diff(filteredData));
    
    % remove artefacts from median filtering
    trimmedDFilteredData = dFilteredData(medianLength:(end-medianLength));
    % calculate threshold
    compareValue = quantile(trimmedDFilteredData, comparePoint) * compareFactor;
    % get step positions
    steps = find(trimmedDFilteredData > compareValue) ...
        + medianLength - 1;
    
    %% debug output
    if (p.Results.debug)
        fprintf(['Parameter:' ...
            '\n\tmedian window size: %d' ...
            '\n\tcompare point: %.2f' ...
            '\n\tcompare factor: %.2f' ...
            '\n' ...
            '\n\tcompare value: %.2f\n' ], ...
            2*medianLength + 1, ...
            comparePoint, ...
            compareFactor, ...
            compareValue...
        );
        dataLength = numel(data);
        plot(1:dataLength, data, '-', ...
            1:dataLength, filteredData, '-', ...
            1:(dataLength - 1), dFilteredData, '-', ...
            [1 dataLength], [compareValue compareValue], '--', ...
            steps, data(steps), '+' ...
        );
    end
end

