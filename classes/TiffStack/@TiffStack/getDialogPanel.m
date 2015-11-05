function panel = getDialogPanel(this, dm, handles)
    panel = dm.addPanel(1);
    dm.addButton('change file', [], @changeFile);
    
    function changeFile(varargin)
        file = File.get({'*.tiff;*.tif'}, 'Select Tiff stack', 'on', this.file);
        if (~isempty(file))
            this.setFile(file);
            notify(dm, 'propertyChange');
        end
    end
end

