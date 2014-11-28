function selectFolder(this, newFolder)
    if (nargin < 2)
        newFolder = Directory.get();
    end
    
    if (newFolder ~= 0)
        this.folder = newFolder;
        this.config = ConfigFile(this.folder, 'config.ini');
        if (this.config.exists)
            this.config.read();
        end
    end
end