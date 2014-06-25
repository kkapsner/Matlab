classdef CSVFile < File
    methods
        function obj = CSVFile(path, filename)
            obj@File(path, filename);
        end
        
        function lines = readLines(obj, separator)
            if (nargin < 2)
                separator = ',';
            end
            rawLines = obj.readLines@File();
            lines = regexp(rawLines, separator, 'split');
        end
        
        function [varargout] = readData(obj, separator)
            if (nargin < 2)
                separator = ',';
            end
            data = importdata(obj.fullpath, separator);
            
            if (nargout == 1)
                varargout{1} = data.data;
            else
                varargout{1} = data.colheaders;
                varargout{2} = data.data;
            end
        end
        
        function writeData(obj, names, data, separator)
            fid = fopen(obj.fullpath, 'w');
            i = 0;
            for name = names
                if (i ~= 0)
                    fprintf(fid, '%s', separator);
                else
                    i = 1;
                end
                fprintf(fid, '%s', name{1});
            end
            dataSize = size(data);
            for row = 1:dataSize(1)
                fprintf(fid, '\n');
                i = 0;
                for col = 1:dataSize(2)
                    if (i ~= 0)
                        fprintf(fid, '%s', separator);
                    else
                        i = 1;
                    end
                    fprintf(fid, '%f', data(row, col));
                end
            end
            fclose(fid);
        end
    end
    
    methods(Static)
        function obj = get(varargin)
            if (nargin < 1)
                filterspec = {'*.*', 'All Files'};
            else
                filterspec = varargin(1);
                filterspec = filterspec{1};
            end
            if (nargin < 2)
                title = '';
            else
                title = varargin(2);
                title = title{1};
            end
            [filename, path] = uigetfile(filterspec, title);
            obj = CSVFile(path, filename);
        end
    end
end