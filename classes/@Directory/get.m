 function obj = get(startpath, title)
    %Directory.get opens a GUI interface to select a directory
    %   Directory.get() opens GUI in current directory
    %   Directory.get(STARTPATH) opens GUI in the STARTPATH directory
    %   Directory.get(STARTPATH, TITLE) opensGUI in the STARTPATH directory
    %       with a window title TITLE
    
    if (nargin < 1)
        startpath = '';
    end
    if (nargin < 2)
        title = '';
    end

    if (isa(startpath, 'Directory'))
        startpath = startpath.path;
    end

    p = uigetdir(startpath, title);
    if p == 0
        obj = 0;
    else
        obj = Directory(p);
    end
end