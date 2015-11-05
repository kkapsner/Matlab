classdef DomainStepData < handle
    
    properties (SetObservable)
        domain
        domainStart
        domainRawData
        
        subdomains
        levels
        
        threshold = 5000
        maxSubdomains = 5
        medianSize = 100
        differentiationOffset = 100
        minimalSubdomainPopulation = 100
        minimalSubdomainSize = 100
        
        isValid = false
    end
    properties (Dependent)
        domainData
    end
    
    methods
        function data = get.domainData(this)
            data = this.domainRawData(this.domain(1):this.domain(2));
        end
        
        function setDefault(this, default)
            if (~isempty(default))
                this.threshold = default(1).threshold;
                this.maxSubdomains = default(1).maxSubdomains;
                this.medianSize = default(1).medianSize;
                this.differentiationOffset = default(1).differentiationOffset;
                this.minimalSubdomainPopulation = default(1).minimalSubdomainPopulation;
                this.minimalSubdomainSize = default(1).minimalSubdomainSize;
            end
        end
        
        function isAborted = analyse(this, filename)
            data = this.domainRawData;
            this.isValid = true;
            isAborted = false;
            
            dm = DialogManager(this);
            if (nargin > 1)
                dm.open(filename);
            else
                dm.open();
            end
            set(dm.getFigure(), 'Toolbar', 'figure');
            dm.addPanel();
            dataAxes = this.createDataAxes(dm, @updateDomain);
            
            dm.addPanel(3);
            dm.addText('Threshold', 100);
            dm.addPropertyInput('threshold', [100, 0, 100], @updateDomain);
            dm.addPropertySlider('threshold', 0, 2e4, {@(w)205, @(w)w-205}, @updateDomain);
            dm.newLine();
            dm.addText('max. domains', 100);
            dm.addPropertyInput('maxSubdomains', {@(w)100, @(w)w/2-100}, @updateDomain);
%             dm.addPropertySlider('maxSubdomains', 0, 20, {@(w)100, @(w)w-100}, @updateDomain);
            dm.addText('median size', {@(w)w/2, @(w)100});
            dm.addPropertyInput('medianSize', {@(w)w/2+100, @(w)w/2-100}, @updateDomain);
%             dm.addPropertySlider('medianSize', 0, 1000, {@(w)100, @(w)w/3-100}, @updateDomain);
            dm.newLine();
            dm.addText('d offset', {@(w)0*w/3, @(w)100});
            dm.addPropertyInput('differentiationOffset', {@(w)0*w/3+100, @(w)w/3-100}, @updateDomain);
%             dm.addPropertySlider('differentiationOffset', 1, 3000, {@(w)w/3+100, @(w)w/3-100}, @updateDomain);
            dm.addText('min. domain size', {@(w)1*w/3, @(w)100});
            dm.addPropertyInput('minimalSubdomainSize', {@(w)1*w/3+100, @(w)w/3-100}, @updateDomain);
%             dm.addPropertySlider('minimalSubdomainSize', 1, 3000, {@(w)2*w/3+100, @(w)w/3-100}, @updateDomain);
            dm.addText('min. domain count', {@(w)2*w/3, @(w)100});
            dm.addPropertyInput('minimalSubdomainPopulation', {@(w)2*w/3+100, @(w)w/3-100}, @updateDomain);
%             dm.addPropertySlider('minimalSubdomainPopulation', 1, 3000, {@(w)2*w/3+100, @(w)w/3-100}, @updateDomain);
            
            dm.addPanel();
            histAxes = this.createHistAxes(dm);
            
            dm.lineHeight = 40;
            dm.addPanel(1);
            dm.addButton('OK', @(w)w/3, @()dm.close());
            dm.addButton('false', {@(w)w/3, @(w)w/3}, @invalid);
            dm.addButton('cancel', {@(w)2*w/3, @(w)w/3}, @abort);
            dm.lineHeight = 20;
    
            
            subdomainBorderPlot = [];
            function updateDomain(varargin)
                if (~isempty(subdomainBorderPlot))
                    delete(subdomainBorderPlot);
                end
                
                filteredData = Filter.median1d(this.domainData, this.medianSize);
                dOffset = max(1, min(numel(this.domainData), this.differentiationOffset));
                
                % calculate difference
                dData = ...
                    filteredData(1:(end-dOffset)) - ...
                    filteredData((1+dOffset):end);
                dData = abs(dData);
                subdomainBorders = find(dData > this.threshold);
                filter = true(size(subdomainBorders));
                filter(1:end-1) = diff(subdomainBorders) > this.minimalSubdomainSize;
                subdomainBorders = subdomainBorders(filter);
%                 subdomainBorders = detectSteps(this.domainData, 'medianLength', 20, 'debug', true, 'comparePoint', 0.98);
                
                subdomainBorderPlot = handle(plot( ...
                    dataAxes, ...
                    this.domain(1) + subdomainBorders, ...
                    this.domainData(subdomainBorders + 1), ...
                    'ok', ...
                    'LineWidth', 2, ...
                    'MarkerFaceColor', 'none' ...
                ));
                Gui.enableDataPointDeletion(subdomainBorderPlot, @(~)updateSubdomains(subdomainBorderPlot.XData));
                Gui.enableDataPointMove(subdomainBorderPlot, @movePoint);
                
                updateSubdomains(this.domain(1) + subdomainBorders);
                
                function newPosition = movePoint(idx, newPosition)
                    xData = subdomainBorderPlot.XData;
                    if (idx <= 1)
                        lowerBorder = this.domain(1);
                    else
                        lowerBorder = xData(idx - 1) + 1;
                    end
                    
                    if (idx >= numel(xData))
                        upperBorder = this.domain(2);
                    else
                        upperBorder = xData(idx + 1) - 1;
                    end
                    
                    newPosition(1) = min(upperBorder, max(lowerBorder, round(newPosition(1))));
                    newPosition(2) = this.domainRawData(newPosition(1));
                    xData(idx) = newPosition(1);
                    updateSubdomains(xData);
                end
            end
            
            subdomainLevels = Gui.imvline.empty(0, 1);
            function updateSubdomains(subdomainBorders)
                if (~isempty(subdomainLevels))
                    delete(subdomainLevels);
                    subdomainLevels = Gui.imvline.empty(0, 1);
                end
                cla(histAxes);
                hold(histAxes, 'all');
                set(histAxes, 'ColorOrder', lines(100));
            
                if (numel(subdomainBorders) + 1 > this.maxSubdomains)
                    return;
                end
                
                subdomainBorders = [subdomainBorders - 1, this.domain(2)];
                subdomainStart = this.domain(1);
                
                
                this.subdomains = zeros(numel(subdomainBorders), 2);
                this.levels = zeros(numel(subdomainBorders), 1);
                
                colors = lines(numel(subdomainBorders));
                for subdomainIdx = 1:numel(subdomainBorders)
                    subdomainEnd = subdomainBorders(subdomainIdx);
                    subdomainData = this.domainRawData(subdomainStart:subdomainEnd);
                    
                    if (subdomainEnd - subdomainStart < this.minimalSubdomainPopulation)
                        this.levels(subdomainIdx) = NaN;
                    else
                    
                        [pdf, x] = hist(subdomainData, 100);
                        plot(histAxes, x, pdf, 'Color', colors(subdomainIdx, :));

                        this.subdomains(subdomainIdx, :) = [subdomainStart, subdomainEnd];
                        this.levels(subdomainIdx) = median(subdomainData);
                    end
                    
                    subdomainStart = subdomainEnd + 1;
                end
                    
                for subdomainIdx = 1:numel(subdomainBorders)
                    levelLine = Gui.imvline(histAxes, this.levels(subdomainIdx));
                    levelLine.color = colors(subdomainIdx, :);
                    addlistener(levelLine, 'newPosition', @(~,~)assignLevel(subdomainIdx, levelLine.position));
                    subdomainLevels(end + 1) = levelLine;
%                     levelLine.drawApi.removeReorderListener();
%                     levelLine.drawApi.removeResizeListener();
                end
            end
            function assignLevel(idx, level)
                this.levels(idx) = level;
            end
            function invalid(varargin)
                this.isValid = false;
                dm.close();
            end
            function abort(varargin)
                this.isValid = false;
                isAborted = true;
                dm.close();
            end
            
            updateDomain();
            
            dm.show(true);
            dm.wait();
        end
        
    end
    
    methods (Access=private)
        function dataAxes = createDataAxes(this, dm, updateCallback)
            dataAxes = handle(axes( ...
                'Parent', dm.currentPanel, ...
                'Units', 'normalize', ...
                'HandleVisibility', 'callback', ...
                'OuterPosition', [0, 0, 1, 1] ...
            ));
            hold(dataAxes, 'all');
            dataSize = numel(this.domainRawData);
            plot(dataAxes, this.domainRawData);
            
%             xlabel(dataAxes, 'time (s)');
            ylabel(dataAxes, 'current (pA)');
            
            axis(dataAxes, 'tight');
            Gui.enableWheelZoom(dataAxes, [0, 1, 0]);
            
            startLine = Gui.imvline(dataAxes, this.domain(1));
            startLine.drawApi.addPatch('left');
            
            endLine = Gui.imvline(dataAxes, this.domain(2));
            endLine.drawApi.addPatch('right');

            startLine.positionConstraintFcn = @(p)round(min(max(p, 1), endLine.position));
            endLine.positionConstraintFcn = @(p)round(min(max(p, startLine.position), dataSize));

            addlistener(startLine, 'newPosition', @updateStartPosition);
            addlistener(endLine, 'newPosition', @updateEndPosition);
            
            function updateStartPosition(~,~)
                this.domain(1) = startLine.position;
                [yMin, yMax] = minmax(this.domainData);
                ylim(dataAxes, [yMin, yMax]);
                updateCallback();
            end
            function updateEndPosition(~,~)
                this.domain(2) = endLine.position;
                [yMin, yMax] = minmax(this.domainData);
                ylim(dataAxes, [yMin, yMax]);
                updateCallback();
            end
        end
        
        function histAxes = createHistAxes(this, dm)
            histAxes = handle(axes( ...
                'Parent', dm.currentPanel, ...
                'Units', 'normalize', ...
                'HandleVisibility', 'callback', ...
                'OuterPosition', [0, 0, 1, 1] ...
            ));
            hold(histAxes, 'all');
            xlabel(histAxes, 'current (pA)');
            ylabel(histAxes, 'count');
        end
    end
    
end

