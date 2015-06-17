function dm = dialog(this, dm)
    if (nargin < 2 || isempty(dm))
        dm = DialogManager(this);
        dm.open();
    end
    if (numel(this) ~= 1)
        for o = this
            oDm = DialogManager(o);
            oDm.open([], dm);
            o.dialog(oDm);
        end
        dm.show();
    else
        dm.addPanel(3);
        dm.addText('Property', [0, 0, 100]);
        dm.addPropertyPopupmenu('property', ...
            { ...
                'width', ...
                'height', ...
                'Area', ...
                'minX', ...
                'minY', ...
                'maxX', ...
                'maxY', ...
                'EquivDiameter', ...
                'Perimeter', ...
                'MajorAxisLength', ...
                'MinorAxisLength', ...
                'Eccentricity', ...
                'Orientation', ...
                'Cyclicity', ...
                'Concavity', ...
            }, ...
            {@(w)100, @(w)w-100} ...
        );

        dm.newLine();
        dm.addText('Min', [0, 0, 100]);
        lowerSlider = dm.addPropertySlider('lowerRangeLimit', 0, 100, {@(w)100, @(w)w-100});

        dm.newLine();
        dm.addText('Max', [0, 0, 100]);
        upperSlider = dm.addPropertySlider('upperRangeLimit', 0, 100, {@(w)100, @(w)w-100});
        
        dm.connectRangeSliders(lowerSlider, upperSlider);
        
        dm.show();
    end
end