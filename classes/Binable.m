classdef (Abstract) Binable <  handle
    %BINABLE makes class binable
    
    properties
    end
    
    methods
        %OBJ.BIN bins the array
        function [bins, binningBorders] = bin(obj, by, minValue, stepSize, varargin)
            %   [bins, binningBorders] = OBJ.bin(by, minValue, stepSize)
            %       bins is a cell where bins{i} are the elements that have
            %       binningBorders(i) < obj.(by) <= binningBorders(i+1).
            %       First binningBorder is minValue and second element is
            %       minValue+stepSize.
            %       To take the minimal obj.(by) for lower border set
            %       minValue = Inf. (To also get ALL elements the minimal
            %       border is decreased by 0.0001% of the absolute value of
            %       the minimum since the lower boundary is exclusive.)
            %   OBJ.bin(..., 'optionName', option)
            %       you can provide additional options:
            %           NAME (TYPE=DEFAULT): DESCRIPTION
            %           logarithmic (boolean=false): if binning shall be
            %               logarithmic
            %           addLowerLeftover (boolean=false): if there should
            %               be a bin at the beginning containing the lower
            %               leftovers
            %           addUpperLeftover (boolean=false): if there should
            %               be a bin at the ending containing the upper
            %               leftovers
            
            p = inputParser;
            p.addParamValue('logarithmic', false, @islogical);
            p.addParamValue('addLowerLeftover', false, @islogical);
            p.addParamValue('addUpperLeftover', false, @islogical);
            p.parse(varargin{:});
            
            values = [obj.(by)];
            if (numel(minValue) == 2)
                maxValue = minValue(2);
                minValue = minValue(1);
            else
                maxValue = max(values);
            end
            if (~isfinite(minValue))
                minValue = min(values);
                minValue = minValue - 0.000001 * abs(minValue);
            end
            
            binningBorders = Binable.createBinningBorders( ...
                minValue, stepSize, maxValue, p.Results.logarithmic ...
            );
            if (p.Results.addLowerLeftover)
                binningBorders = [-Inf binningBorders];
            end
            if (p.Results.addUpperLeftover)
                binningBorders = [binningBorders Inf];
            end
            bins = Binable.createBins(binningBorders);
            
            for i = 1:numel(bins)
                filter = values > binningBorders(i) & values <= binningBorders(i + 1);
                bins{i} = obj(filter);
            end
        end
        
        %OBJ.BIN2D bins in two dimensions
        function [bins, binningBorders] = bin2D(obj, bys, minValues, stepSizes, logarithmic)
            %OBJ.BIN bins the array
            %   [bins, binningBorders] = OBJ.bin(bys, minValues, stepSizes, logarithmic)
            %       bins is a cell where bins{i} are the elements that have
            %       binningBorders{1}(i) < obj.(bys{1}) <=
            %       binningBorders{1}(i+1) and binningBorders{2}(j) <
            %       obj.(bys{2}) <= binningBorders{2}(j)
            %       First binningBorder is minValue and second element is
            %       minValue+stepSize.
            %       To take the minimal obj.(by) for lower border set
            %       minValue = Inf. (To also get ALL elements the minimal
            %       border is decreased by 0.0001% of the absolute value of
            %       the minimum since the lower boundary is exclusive.)
            values = cell(numel(obj), numel(bys));
            binningBorders = cell(size(bys));
            for i = 1:numel(bys)
                values{i} = [obj.(bys{i})];
                if (~isfinite(minValues(i)))
                    minValues(i) = min(values{i});
                    minValues(i) = minValues(i) - 0.000001 * abs(minValues(i));
                end
                
                if (nargin < 5)
                    loga = false;
                else
                    loga = logarithmic{i};
                end
                
                binningBorders{i} = Binable.createBinningBorders( ...
                    minValues(i), stepSizes(i), max(values{i}), loga ...
                );
            end
            
            bins = Binable.createBins(binningBorders{:});
            
            binSize1 = size(bins, 1);
            binSize2 = size(bins, 2);
            
            filter1 = false(binSize1, numel(obj));
            filter2 = false(binSize2, numel(obj));
            for x = 1:size(bins, 1)
                filter1(x, :) = values{1} > binningBorders{1}(x) & values{1} <= binningBorders{1}(x + 1);
            end
            for y = 1:size(bins, 2)
                filter2(y, :) = values{2} > binningBorders{2}(y) & values{2} <= binningBorders{2}(y + 1);
            end
            
            for x = 1:size(bins, 1)
                for y = 1:size(bins, 2)
                    bins{x, y} = obj(filter1(x, :) & filter2(y, :));
                end
            end
        end
    end
    
    methods(Access=protected)
    end
    
    methods(Static)
        function binningBorders = createBinningBorders( ...
                minValue, stepSize, maxValue, logarithmic)
            %CREATEBINNINGBORDERS
            %   creates the binning borders
            if (logarithmic)
                deltaX = log(minValue + stepSize)/log(minValue) - 1;
                xn = log(maxValue)/log(minValue);
                n = ceil((xn - 1)/deltaX);
                binningBorders = minValue .^ ((0:n)*deltaX + 1);
            else
                maxValue = minValue + ...
                    ceil((maxValue - minValue) / stepSize) * stepSize;
                binningBorders = minValue:stepSize:maxValue;
            end
        end
        
        function bins = createBins(varargin)
            %CREATEBINS
            %   createBins(binningBorders)
            %   createBins(binningBorders1, ... , binningBordersN)
            if (numel(varargin) == 1)
                bins = cell(1, numel(varargin{1}) - 1);
            else
                numbers = cellfun(@(c)numel(c)-1, varargin, ...
                    'UniformOutput', false ...
                );
                bins = cell(numbers{:});
            end
        end
        
        function bin = expandBinning(bin1, bin2)
            %expandBinning expands a binning by another in 2D
            %   expandBinning(bin1, bin2)
            bin = cell(numel(bin1), numel(bin2));
            numBin1 = numel(bin1);
            numBin2 = numel(bin2);
            for x = 1:numBin1
                for y = 1:numBin2
                    bin{x, y} = intersect(bin1{x}, bin2{y});
                end
            end
        end
    end
end

