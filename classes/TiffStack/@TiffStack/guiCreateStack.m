function stack = guiCreateStack(selectedFile)
%GUICREATESTACK creates a stack over a GUI
%   STACK = GUICREATESTACK()
%       opens the GUI and after closing it returns the selected stack(s).
%   STACK = GUICRATESTACK(PRESELECT)
%       opens the file choose GUI at the specified position PRESELECT
%   STACK = GUICREATESTACK(FILE)
%       does not open a file select GUI but only the stack creation GUI

    if (nargin < 1)
        selectedFile = [];
    end
    if (~isa(selectedFile, 'File'))
        file = File.get({'*.tiff;*.tif'}, 'Select Tiff stack', 'on', selectedFile);
    else
        file = selectedFile;
    end
    
    if isempty(file)
        stack = [];
        return;
    end
    
    numFiles = numel(file);
    width = 500;
    padding = 10;
    innerPadding = 5;
    lineHeight = 20;
    innerWidth = width - 2*padding;
    height = 2*padding + numFiles * lineHeight + (numFiles - 1) * innerPadding;
    textWidth = 50;
    selectWidth = 90;
    panelWidth = innerWidth - textWidth - selectWidth - 2*innerPadding;
    
    stackTypes = {'TiffStack', 'DistributedTiffStack'};
    numTypes = numel(stackTypes);
    
    f = handle(figure( ...
        'NumberTitle', 'off', ...
        'Name', 'Select stack type', ...
        'HandleVisibility', 'off', ...
        'Color', 'w', ...
        'Position', [50, 50, width, height], ...
        'CloseRequestFcn', @createStack, ...
        'Resize', 'off', ...
        'Menubar', 'none', ...
        'Toolbar', 'none' ...
    ));

    movegui(f, 'center');
    
    nameDisplay = cell(size(file));
    typeSelect = cell(size(file));
    parameterPanel = cell(numFiles, numTypes);
    getParameter = cell(size(parameterPanel));
    for itemIndex = 1:numFiles
        x = padding;
        y = padding + (numFiles - itemIndex) * (lineHeight + innerPadding);
        [~, name, ~] = fileparts(file(itemIndex).fullpath);
        nameDisplay{itemIndex} = handle(uicontrol( ...
            'Parent', f, ...
            'BackgroundColor', f.Color, ...
            'Style', 'text', ...
            'TooltipString', file(itemIndex).fullpath, ...
            'String', name, ...
            'HorizontalAlign', 'left', ...
            'Position', [x, y, textWidth, lineHeight], ...
            'HandleVisibility', 'off'...
        ));
        x = x + textWidth + innerPadding;
        typeSelect{itemIndex} = handle(uicontrol( ...
            'Parent', f, ...
            'BackgroundColor', f.Color, ...
            'Style', 'popupmenu', ...
            'String', stackTypes, ...
            'Position', [x, y, selectWidth, lineHeight], ...
            'HandleVisibility', 'off', ...
            'Callback', @(~,~)togglePanel(itemIndex) ...
        ));
        x = x + selectWidth + innerPadding;
        for j = 1:numTypes
            [parameterPanel{itemIndex, j}, getParameter{itemIndex, j}] = ...
                feval( ...
                    sprintf('%s.getGUIParameterPanel', stackTypes{j}), f, file(itemIndex) ...
                );
            parameterPanel{itemIndex, j}.Position = [x, y, panelWidth, lineHeight];
        end
        togglePanel(itemIndex);
    end
    
    
    uiwait(f);
    
    function togglePanel(itemIndex)
        for i = 1:numTypes
            parameterPanel{itemIndex, i}.Visible = 'off';
        end
        parameterPanel{itemIndex, typeSelect{itemIndex}.Value}.Visible = 'on';
    end
    
    function createStack(~,~)
        for i = 1:numFiles
            nameDisplay{i}.Visible = 'off';
            typeSelect{i}.Visible = 'off';
            for i_ = 1:numTypes
                parameterPanel{i, i_}.Visible = 'off';
            end
        end
        
        uicontrol( ...
            'Parent', f, ...
            'Style', 'text', ...
            'BackgroundColor', f.Color, ...
            'Position', [padding, (height - 40) / 2 + 20, innerWidth, 20], ...
            'String', 'Create stacks...' ...
        );
        w = Gui.Waitbar(0, ...
            'Parent', f, ...
            'Position', [padding, (height - 40) / 2, innerWidth, 15] ...
        );
        
        stack = cell(size(file));
        allSameType = true;
        firstType = typeSelect{1}.Value;
        for i = 1:numFiles
            typeI = typeSelect{i}.Value;
            param = getParameter{i, typeI};
            param = param();
            stack{i} = feval(stackTypes{typeI}, param{:});
            if (typeI ~= firstType)
                allSameType = false;
            end
            
            w.Value = i / numFiles;
        end
        if allSameType
            stackC = stack;
%             stack = feval(sprintf('%s.empty', stackTypes{firstType}));
            stack = [stackC{:}];
%             for i = numFiles:-1:1
%                 stack(i) = stackC{i};
%             end
        end
        
        delete(f);
    end
end

