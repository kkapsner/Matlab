function save(a, filename, formats)
%SAVE saves axes to filename.fig and filename.pdf
    if (nargin < 3)
        formats = { ...
            {'-dpdf'} ...
            ,
            {'-dpng', '-r500'}...
        };
    end
    if (isa(filename, 'Directory'))
        dir = filename;
        filename = a.figureName;
        if any(strfind(filename, '.') > 0)
            filename = strrep(filename, '.', ',');
        end
        filename = File(dir, filename);
    end
    if (isa(filename, 'File'))
        filename = filename.fullpath;
    end
%     try
%         YTickMode = get(a.ax, 'YTickMode');
%         XTickMode = get(a.ax, 'XTickMode');
%         set(a.ax, 'YTickMode', 'manual');
%         set(a.ax, 'XTickMode', 'manual');
%     end
    
%     drawnow();
    for i = 1:numel(formats)
        print(a.f, filename, formats{i}{:});
    end
    
%     try
%         set(a.ax, 'YTickMode', YTickMode);
%         set(a.ax, 'XTickMode', XTickMode);
%     end
    
    hgsave(a.f, filename);
end

