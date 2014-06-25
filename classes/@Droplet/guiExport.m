function dm = guiExport(this)
% DROPLETS.GUIEXPORT generates a GUI for the DROPLETS.EXPORT function
% 
%   DM = DROPLETS.GUIEXPORT()
% 
% see also: DROPLETS.EXPORT, DIALOGMANAGER

    dm = DialogManager(this);
    
    dir = 0;
    
    dm.open();
    
    
    property = {'position', 'radius', 'perimeter', ...
        'minimal intensity', 'maximal intensity', 'intensity sum', ...
        'bright intensity sum', 'bright area' ...
    };
    propertyName = {'p', 'radius', 'perimeter', ...
        'minIntensity', 'maxIntensity', 'intensitySum', ...
        'brightIntensitySum', 'brightArea' ...
    };
    
    dm.addPanel();
    propertyList = handle(uicontrol( ...
        'Parent', dm.currentPanel, ...
        'Style', 'listbox', ...
        'Min', 0, ...
        'Max', 10, ...
        'String', property, ...
        'Units', 'normalize', ...
        'Position', [0, 0, 1, 1] ...
    ));
    dm.addElement(propertyList, 1);
    propertyList.Position = [0, 0, 1, 1];
    
    dm.addPanel(2);
    
    dirButton = dm.addButton('export to workspace', @(w)w,  @saveToWorkspace);
    
    dm.newLine();
    dirButton = dm.addButton('select directory', @(w) w/2 - 5,  @selectDirectory);
    saveButton = dm.addButton('save', {@(w)w/2+5, @(w)w/2-5},  @save);
    saveButton.enable = 'off';
    
    dm.show();
    
    function selectDirectory(~,~)
        dir = Directory.get('select save directory');
        if (dir ~= 0)
            dirButton.String = dir.path;
            saveButton.Enable = 'on';
        else
            dirButton.String = 'select directory';
            saveButton.Enable = 'off';
        end
    end
    
    function saveToWorkspace(~,~)
        if (~isempty(propertyList.Value))
            for name = propertyName(propertyList.Value)
                name = name{1};
                assignin('base', name, [this.(name)]);
            end
            dm.close();
        end
    end
    function save(~,~)
        if (dir ~= 0)
            if (~isempty(propertyList.Value))
                this.export(dir, propertyName(propertyList.Value));
                dm.close();
            end
        end
    end
end