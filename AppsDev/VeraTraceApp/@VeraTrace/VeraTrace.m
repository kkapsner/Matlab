classdef VeraTrace < handle
    properties
        data
    end
    properties (Access=private)
        lastAcceptedDomain
    end
    
    methods
        function step(this)
            this.data = cell(0, 1);
            this.lastAcceptedDomain = [];
            
            this.iterateFiles(this.getFiles(), @callback, 100);
            
            function abort = callback(trace, i, file)
                [this.data{i}, abort] = this.analyseTrace(trace * 1e12, file.filename);
            end
        end
        
        function [domainData, abort] = analyseTrace(this, trace, filename)
            domainData = DomainStepData.empty(0, 1);
            abort = this.iterateDomains(trace, @callback);
            domainData = domainData([domainData.isValid]);
            function abort = callback(domain, i)
                domainData(i) = DomainStepData();
                domainData(i).domainRawData = trace(domain(1):domain(2));
                domainData(i).domainStart = domain(1);
                domainData(i).domain = [1,numel(domainData(i).domainRawData)];
                domainData(i).setDefault(this.lastAcceptedDomain);

                abort = domainData(i).analyse(filename);
                if (abort)
                    return;
                end
                if (domainData(i).isValid)
                    this.lastAcceptedDomain = domainData(i);
                end
            end
        end
        
        function data = peak(this, analysisCallback, settings)
            data = {};
            currentTrace = [];
            currentResult = [];
            
            dataPlot = [];
            resultPlot = [];
            
            abort_ = false;
            
            files = this.getFiles();
            
            dm = DialogManager(settings);
            dm.open('Peak analysis GUI');
            set(dm.getFigure(), 'Toolbar', 'figure');
            dm.addPanel();
            dataAxes = handle(axes( ...
                'Parent', dm.currentPanel, ...
                'Units', 'normalize', ...
                'HandleVisibility', 'callback', ...
                'OuterPosition', [0, 0, 1, 1] ...
            ));
            hold(dataAxes, 'all');
            Gui.enableWheelZoom(dataAxes, [0, 1, 0]);
            
%             xlabel(dataAxes, 'time (s)');
            ylabel(dataAxes, 'current (pA)');
            
            startLine = Gui.imvline(dataAxes, 1);
            startLine.drawApi.addPatch('left');
            
            endLine = Gui.imvline(dataAxes, 0);
            endLine.drawApi.addPatch('right');

            startLine.positionConstraintFcn = @(p)round(min(max(p, 1), endLine.position));
            endLine.positionConstraintFcn = @endLineConstrain;
            function p = endLineConstrain(p)
                p = round(min(max(p, startLine.position), numel(currentTrace)));
            end

            addlistener(startLine, 'newPosition', @clearResult);
            addlistener(endLine, 'newPosition', @clearResult);
            
            dm.addPanel(1);
            dm.addButton('settings', 60, @settings.dialog);
            dm.addButton('take std from selection', [60, 0, 120], @calculateStd);
            
            dm.addText('th_mult_on', [180, 0, 60]);
            dm.addPropertySlider('th_mult_on', 0, 10, {@(w)180+60, @(w)(w-180)/2-60}, @clearResult);
            dm.addText('th_mult_off', {@(w)180+(w-180)/2, @(w)60});
            dm.addPropertySlider('th_mult_off', 0, 10, {@(w)180+(w-180)/2+60, @(w)(w-180)/2-60}, @clearResult);
            
            dm.lineHeight = 40;
            dm.addPanel(1);
            dm.addButton('analyse', {@(w)0*w/4, @(w)w/4}, @startAnalysis);
            okButton = dm.addButton('OK', {@(w)1*w/4, @(w)w/4}, @saveResult);
            okButton.Visible = 'off';
            dm.addButton('next', {@(w)2*w/4, @(w)w/4}, @next);
            dm.addButton('cancel', {@(w)3*w/4, @(w)w/4}, @cancel);
            dm.lineHeight = 20;
            dm.show(true);
            
            this.iterateFiles(files, @fileCallback);
            
            dm.close();
            function abort = fileCallback(trace, ~, file)
                set(dm.getFigure(), 'Name', file.filename);
                trace = trace*1e12;
                abort = this.iterateDomains(trace, @domainCallback);
                function abort = domainCallback(domain, ~)
                    currentTrace = trace(domain(1):domain(2));
                    startLine.position = 1;
                    endLine.position = domain(2) - domain(1) + 1;
                    
                    delete(dataPlot);
                    dataPlot = plot(dataAxes, currentTrace, '-b');
                    axis(dataAxes, 'tight');
                    dm.wait();
                    abort = abort_;
                end
            end
            
            function calculateStd(~,~)
                settings.stdev = std(currentTrace(startLine.position:endLine.position));
            end
            
            function startAnalysis(~,~)
                clearResult();
                currentResult = analysisCallback( ...
                    currentTrace(startLine.position:endLine.position), ...
                    settings ...
                );
                peakOnIdx = currentResult.peakOn(:,1) + startLine.position - 1;
                peakEndIdx = currentResult.peakEnd(:,1) + startLine.position - 1;
                peakOffIdx = currentResult.peakOff(:,1) + startLine.position - 1;
                resultPlot = plot( ...
                    dataAxes, ...
                    peakOnIdx, currentTrace(peakOnIdx), 'og', ...
                    peakEndIdx, currentTrace(peakEndIdx), 'xr', ...
                    peakOffIdx, currentTrace(peakOffIdx), 'or', ...
                    [peakOnIdx'; peakOffIdx'], [currentResult.lowerBaseline; currentResult.lowerBaseline], '-k', ...
                    'MarkerSize', 10 ...
                );
                uistack(resultPlot, 'top');
                okButton.Visible = 'on';
            end
            
            function saveResult(~,~)
                if (~isempty(currentResult))
                    data{end + 1} = currentResult;
                end
                clearResult();
            end
            
            function next(~,~)
                clearResult();
                dm.resume();
            end
            
            function cancel(~,~)
                abort_ = true;
                dm.resume();
            end
            
            function clearResult(varargin)
                currentResult = [];
                okButton.Visible = 'off';
                if (ishandle(resultPlot))
                    delete(resultPlot);
                    resultPlot = [];
                end
%                 [yMin, yMax] = minmax(currentTrace(startLine.position:endLine.position));
%                 ylim(dataAxes, [yMin, yMax]);
            end
        end
        
    end
    
    methods (Access=private)
        function files = getFiles(~)
            files = File.get({ ...
                '*.mat', 'MATLAB data files'}, ...
                'Select trace files', ...
                'on' ...
            );
        end
        
        function iterateFiles(~, files, callback, medianSize)
            for i = 1:numel(files)
                file = files(i);
                traceVariable = load(file.fullpath);
                names = fieldnames(traceVariable);
                if (numel(names) ~= 1)
                    warning('Expected only one variable in file. Found %s.', numel(names));
                else
                    if (nargin > 3 && medianSize)
                        trace = Filter.median1d(traceVariable.(names{1}), medianSize);
                        trace = trace(floor(medianSize/2):medianSize:end);
                    else
                        trace = traceVariable.(names{1});
                    end
                        abort = callback(trace, i, file);
                    if (abort)
                        break;
                    end
                end
                clear traceVariable trace;
            end
        end
        
        function abort = iterateDomains(~, trace, callback)
            domains = VeraTrace.getPositiveDomains(trace);
            abort = false;
            if (numel(domains))
                for i = 1:size(domains, 1)
                    abort = callback(domains(i, :), i);
                    if (abort)
                        break;
                    end
                end
            end
        end
    end
    
    methods (Static)
        function domains = getPositiveDomains(data)
            dData = diff(sign(data));
%             domainBorders = [find(dData ~= 0), numel(data)];
            domainBorders = find(dData ~= 0);
            domainBorders(end + 1) = numel(data);
            domainStart = 1;
            domains = zeros(0, 2);
            for domainEnd = domainBorders
                if (data(domainStart) > 0)
                    domains(end + 1, :) = [domainStart, domainEnd];
                end
                domainStart = domainEnd + 1;
            end
        end
    end
end

