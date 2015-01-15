classdef CSV < handle
    properties (SetAccess = protected)
        columns = {},
        data = {}
    end
    methods
        function this = addColumn(this, colName, colData)
            if (nargin < 3)
                colData = {};
            end
            if (iscell(colName))
                for i = 1:numel(colName)
                    this.addColumn(colName{i}, colData(:, i));
                end
            else
                if (~iscell(colData))
                    cellData = num2cell(reshape(colData, [], 1));
                else
                    cellData = reshape(colData, [], 1);
                end
                if (numel(this.columns) == 0)
                    this.columns = {colName};
                    this.data = cellData;
                else
                    if (numel(cellData) ~= size(this.data, 1))
                        error( ...
                            'CSV:addColumn:wrongDataSize', ...
                            'Wrong data size: got %d rows but expected %d.', ...
                            numel(cellData), ...
                            size(this.data, 1)...
                        );
                    end
                    this.columns{end + 1} = colName;
                    this.data(:, end + 1) = cellData;
                end
            end
        end
        function this = addTrace(this, traces)
            for tr = traces
                this.addColumn(tr.traceName, tr.value);
            end
        end
        function this = addRow(this, rowData)
            if (isstruct(rowData))
                cellData = cell(1, numel(this.columns));
                for i = 1:numel(this.columns)
                    if (~isfield(rowData, this.columns{i}))
                        error( ...
                            'CSV:addRow:insufficientData', ...
                            'Insufficient data: column %s mising.', ...
                            this.columns{i}...
                        );
                    end
                    cellData{i} = rowData.(this.columns{i});
                end
            else
                if (~iscell(rowData))
                    cellData = num2cell(reshape(rowData, 1, []));
                else
                    cellData = reshape(rowData, 1, []);
                end
                if (numel(cellData) ~= numel(this.columns))
                    error( ...
                        'CSV:addRow:wrongDataSize', ...
                        'Wrong data size: got %d columns but expected %d.', ...
                        numel(cellData), ...
                        numel(this.columns)...
                    );
                end
            end
            this.data(end + 1, :) = cellData;
        end
        
        function this = addRows(this, rowData)
            if (isstruct(rowData))
                for row = rowData
                    this.addRow(row);
                end
            else
                for i = 1:size(rowData, 1)
                    this.addRow(rowData(i, :));
                end
            end
        end
        
        function toFile(this, file, varargin)
            if (nargin < 2)
                file = [];
            end
            cellToCsv(this.data, this.columns, file, varargin{:});
        end
    end
end