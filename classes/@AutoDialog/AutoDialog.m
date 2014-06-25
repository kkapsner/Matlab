classdef (Abstract) AutoDialog < handle
    methods
        function dm = dialog(this)
            props_ = properties(this);
            props = cell(size(props_));
            j = 0;
            for i = 1:numel(props_)
                prop = props_{i};
                mp = findprop(this, prop);
                if ( ...
                    mp.SetObservable && ...
                    ~mp.Transient && ...
                    ~mp.Dependent && ...
                    ~mp.Constant &&  ...
                    isscalar(this.(prop)) ...
                )
                    j = j + 1;
                    props{j} = prop;
                end
            end
            props = props(1:j);
            
            
            dm = DialogManager(this);
            dm.width = 400;
            dm.open();
            dm.addPanel(numel(props));
            for i = 1:numel(props)
                prop = props{i};
                value = this.(prop);
                if (islogical(value))
                    dm.addPropertyCheckbox(prop, prop);
                else
                    dm.addText(prop, 150);
%                     if (isnumeric(value))
%                         dm.addPropertyInput(prop, [100, 0, 100]);
%                         dm.addPropertySlider( ...
%                             prop, ...
%                             value - 5 * abs(value), ...
%                             value + 5 * abs(value), ...
%                             {@(w)200, @(w)w-200} ...
%                         );
%                     else
                        dm.addPropertyInput(prop, {@(w)150, @(w)w-150});
%                     end
                end
                dm.newLine();
            end
            dm.show();
        end
    end
end