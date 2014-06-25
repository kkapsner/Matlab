function mexAll(dir, recursive, varargin)
%MEXALL builds all .c and .cpp files in a given directory
%   MEXALL() or MEXALL([]) opens a dialog to choose the directory
%   MEXALL(DIR) uses the directory DIR
%   MEXALL(..., true) builds recursively
%   MEXALL(..., OPTION_1, ..., OPTION_N) passes the options to mex for
%       valid options see mex.
%
%   MEXALL will not build files that have a matching .h-header file.
%
% SEE ALSO: mex

    if (nargin < 1 || isempty(dir))
        dir = Directory.get();
    end
    if (nargin < 2)
        recursive = false;
    end
    
    for mexFile = [dir.search('*.c'); dir.search('*.cpp')]';
        file = File(dir, mexFile.name);
        if isempty(dir.search(regexprep(mexFile.name, '\.c(pp)?$', '.h')))
            % if there is no header file
            try
                disp(['mex ' file.fullpath]);
                mex('-outdir', dir.path, varargin{:}, file.fullpath)
            catch
                disp(['mex failed for ' file.fullpath]);
            end
        else
            disp(['<a href="matlab:disp([10 ''' file.fullpath ' has a header file.''])">no</a> mex ' file.fullpath]);
        end
    end
    
    if (recursive)
        for subDir = dir.search()'
            if (subDir.isdir && subDir.name(1) ~= '.')
                mexAll(dir.child(subDir.name), recursive, varargin{:});
            end
        end
    end
end

