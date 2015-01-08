function [varargout] = dialog(tracker)
    
    dm = DialogManager(tracker);
    
    if (nargout == 1)
        varargout{1} = dm;
    end
    
    dm.height = 175;
    dm.open();
    
    %% data size
    dm.addPanel(1);
    
    % create controlls
    dm.addText('data size', 80);
    dataSizeSlider = dm.addPropertySlider('dataSize', 0, max(100, tracker.dataSize), ...
        [80, 0, dm.innerWidth - 80, 20], @dataSizeCallback ...
    );

    function dataSizeCallback(value)
        dataSizeSlider.Value = round(value);
        tracker.dataSize = round(value);
    end
    
    %% radius panel
    dm.addPanel(2, 'Radius change');
    
    % create controlls
    dm.addText('max', 80);
    dm.addPropertySlider('maxRadiusChange', 0, 1, ...
        [80, 0, dm.innerWidth - 80, 20] ...
    );

    dm.newLine();
    dm.addText('min-max', 80);
    dm.addPropertySlider('minMaxRadiusChange', 0, 10, ...
        [80, 0, dm.innerWidth - 80, 20] ...
    );
    
    %% border distance
    dm.addPanel(1, 'border distance');
    
    % create controlls
    dm.addText('max', 80);

    dm.addPropertySlider('maxBorderDistance', 0, 10, ...
        [80, 0, dm.innerWidth - 80, 20] ...
    );

    dm.show();
end