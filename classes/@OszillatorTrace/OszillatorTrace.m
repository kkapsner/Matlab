classdef OszillatorTrace < Trace
    
    properties
        % either a number for amplitdeThreshold or a function handle
        % getting the trace as parameter and returning the threshold
        amplitudeThreshold = @(tr)tr.std('noise')
        
        minimalExtremaCountForOscillating = 5
        extremaCountForPeriod = 5
    end
    properties (SetAccess=private)
        %raw data
        dataPath
        intensity
        area
        normalisation
        
        %calculated
        radius
        dampingCoefficient
        amplitude
    end
    properties (Access=private)
        peaks
    end
    properties (Dependent)
        advancedName
        
        dataSize
        meanRadius
        volume
        
        peakTimes
        peakValues
        
        isOscillating
        
        period
        periodPeaks
        periodPeakTimes
        periodPeakValues
    end
    
    %% constructor
    methods
        function obj = OszillatorTrace(names, ...
                intensities, areas, normalisation, ...
                mumPPixel, timestep)
            if (nargin ~= 0) %zero attributes for preallocating
                if (nargin < 5)
                    timestep = 6;
                end
                if (nargin < 4)
                    mumPPixel = 1/1.54;
                end
                
                m = length(names);
                intensitySize = size(intensities);
                if (m ~= intensitySize(2))
                    error('Trace:notEqualSizes', 'names count and number of columns of intensities must be equal');
                end
                if (any(intensitySize ~= size(areas)))
                    error('Trace:notEqualSizes', 'intensities and areas must be same size');
                end
                
                obj(m) = OszillatorTrace; % Preallocate object array
                noNormalisation = isempty(normalisation);
                for i = 1:m
                    obj(i).name = names{i};
                    obj(i).intensity = intensities(:,i);
                    obj(i).area = areas(:,i);
                    if ~noNormalisation
                        obj(i).normalisation = normalisation(:, i);
                    else
                        obj(i).normalisation = zeros(0,0);
                    end

                    obj(i).time = transpose( ...
                    0:timestep:timestep*(intensitySize(1) - 1) ...
                    );
                    %obj(i).isEqualyTimed = true;

                    obj(i).trim();
                    obj(i).calculateRadius(mumPPixel);
                    if noNormalisation
                        obj(i).normalisation = 4/3 * pi * (obj(i).radius .^ 3);
                    end
                    obj(i).calculateIpv();
                end
            end
        end
    end
    
    %% getter
    methods
        function value = get.peaks(obj)
            if isempty(obj.peaks)
                obj.calculateExtrema();
            end
            value = obj.peaks;
        end
        function value = get.dampingCoefficient(obj)
            if (isempty(obj.dampingCoefficient))
                obj.calculateDampingCoefficient();
            end
            value = obj.dampingCoefficient * 60;
        end
        function value = get.amplitude(obj)
            if (isempty(obj.amplitude))
                obj.calculateAmplitude();
            end
            value = obj.amplitude;
        end
    end
    
    %% dependent getter
    methods
        function value = get.advancedName(obj)
            value = sprintf('%s (r=%2.2f, p=%2.1f, T=%2.1f)', ...
                obj.name, obj.mean('radius'), numel(obj.peaks), obj.period ...
            );
        end
        
        function value = get.dataSize(obj)
            value = numel(obj.time);
        end
        function value = get.meanRadius(obj)
            value = mean(obj.radius);
        end
        function value = get.volume(obj)
            value = 4/3 * pi * obj.meanRadius .^ 3;
        end
        
        function value = get.peakTimes(obj)
            value = obj.time(obj.peaks);
        end
        function value = get.peakValues(obj)
            value = obj.filteredValue(obj.peaks);
        end
        
        function value = get.isOscillating(obj)
            value = numel(obj.periodPeaks) >= ...
                obj.minimalExtremaCountForOscillating;
        end
        
        function value = get.period(obj)
            times = obj.periodPeakTimes;
            if (numel(times) < obj.minimalExtremaCountForOscillating)
                value = inf;
            else
                value = 2 * (times(obj.extremaCountForPeriod) - times(1)) / ...
                    (obj.extremaCountForPeriod - 1);
            end
        end
        function value = get.periodPeaks(obj)
            value = obj.peaks;
            
            if (numel(value))
                if (value(1) == 1)
                    value = value(2:end);
                end
                if (numel(value) && value(end) == obj.dataSize)
                    value = value(1:end-1);
                end
            end
        end
        function value = get.periodPeakTimes(obj)
            value = obj.time(obj.periodPeaks);
        end
        function value = get.periodPeakValues(obj)
            value = obj.filteredValue(obj.periodPeaks);
        end
        
    end
    
    %% resetter to cover dependencies
    methods (Access=private)
        function resetPeaks(obj)
            warning('OscillatorTrace:deprecated', 'resetPeaks is deprecated');
            obj.resetExtrema();
        end
        function resetExtrema(obj)
            obj.peaks = [];
            obj.resetDampingCoefficient();
            obj.resetAmplitude();
        end
        function resetDampingCoefficient(obj)
            obj.dampingCoefficient = [];
        end
        function resetAmplitude(obj)
            obj.dampingCoefficient = [];
        end
    end
    
    %% public functions
    methods
        function traces = getOscillating(obj)
            traces = obj([obj.isOscillating]);
        end
        function traces = getNonOscillating(obj)
            traces = obj(~[obj.isOscillating]);
        end
        
        calculateExtrema(obj)
        function calculatePeaks(obj)
            warning('OscillatorTrace:deprecated', 'calculatePeaks is deprecated');
            obj.calculateExtrema
        end
        
        calculateDampingCoefficient(oscTrace)
        calculateAmplitude(oscTrace)
        
    end
    
    %% plot methods
    methods
        ax = overviewPlot(obj)
        savePlot(obj, dir, rows, cols)
    end
    
    methods (Access=protected)
        trim(obj)
        
        function calculateRadius(obj, mumPPixel)
            for o = obj
                o.radius = sqrt(o.area / pi) * mumPPixel;
            end
        end
        
        function calculateIpv(obj)
            for o = obj
                o.value = o.intensity ./ o.normalisation; %(4/3 * pi * o.radius .^ 3);
            end
        end
        
    end
    
    methods (Static)
        
        function t = readFile(areaFile, mumPPixel, timeStep)
            intensityFile = CSVFile( ...
                areaFile.path, ...
                strrep(areaFile.filename, 'area', 'intensity') ...
            );
            assert( ...
                intensityFile.exist, ...
                'processFile:noIntensityFile', ...
                'intensity file not found' ...
            );
            [names, areaData] = areaFile.readData;
            intensityData = intensityFile.readData;
            
            pathParts = regexp(areaFile.path, filesep, 'split');
            normalisationNames = {'normalisation', 'normalization', ...
                'reference', ['reference' filesep 'intensity'], ...
                [pathParts{end - 1} ' ref' filesep 'intensity'], ...
                ['ref' filesep 'intensity'] ...
            };
            
            for name = normalisationNames
                normalisationFile = CSVFile( ...
                    areaFile.path, ...
                    strrep(areaFile.filename, 'area', name{1}) ...
                );
                if (normalisationFile.exist)
                    disp('...found normalisation');
                    break;
                end
            end
            
            if (normalisationFile.exist)
                normalisationData = normalisationFile.readData;
                if (~all(size(normalisationData) == size(intensityData)))
                    error(['Normalisation data have different size then intensity data.' ...
                        '(' areaFile.filename ')']);
                end
            else
                warning('OscillatorTrace:noNormalisation', ...
                    '!!! NO NORMALISATION FOUND !!!');
                normalisationData = zeros(0, 0);
            end
            
            t = OszillatorTrace(names, ...
                intensityData, areaData, normalisationData, ...
                mumPPixel, timeStep);
            for tr=t
                tr.dataPath = intensityFile.fullpath;
            end
        end
        
        function t = readDirectory(dir, mumPPixel, timeStep)
            t = OszillatorTrace.empty();
            areaFiles = dir.search('area*.csv');
            for i = 1:numel(areaFiles)
                file = areaFiles(i);
                fprintf('process file %s\n', file.name);
                if (~file.isdir)
                    areaFile = CSVFile(dir, file.name);
                    if (areaFile.exist)
                        t = [t OszillatorTrace.readFile(areaFile, mumPPixel, timeStep)];
                    end
                end
            end
            
            iOfNs = dir.search('*of*');
            for i = 1:numel(iOfNs)
                iOfN = iOfNs(i);
                if (iOfN.isdir && numel(strfind(iOfN.name, 'ref')) == 0)
                    fprintf('enter directory %s\n', iOfN.name);
                    iOfNDir = dir.child(iOfN.name);
                    t = [t OszillatorTrace.readDirectory(iOfNDir, mumPPixel, timeStep)];
                end
            end
            
            assert( ...
                ~isempty(t), ...
                'processFile:noAreaFile', ...
                'area file not found' ...
            );
        end
        
        function s = createSignalToNoiseSplit(traces, splitSize)
            s = struct( ...
                'splitSize', splitSize, ...
                'splitRanges', struct() ...
            );
            
            startLevel = 0;
            endLevel = splitSize;
            signalToNoise = [traces.signalToNoise];
            maxSignalToNoise = max(signalToNoise);
            notDone = true;
            while notDone
                name = sprintf('split%u', startLevel / splitSize);
                s.splitRanges.(name) = [startLevel, endLevel];
                s.(name) = traces( ...
                        signalToNoise >= startLevel & ...
                        signalToNoise < endLevel ...
                );
                startLevel = endLevel;
                endLevel = endLevel + splitSize;
                notDone = startLevel < maxSignalToNoise;
            end
        end
    end
end