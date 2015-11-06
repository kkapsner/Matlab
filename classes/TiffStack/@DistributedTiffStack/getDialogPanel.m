function panel = getDialogPanel(this, dm, handles)
    panel = dm.addPanel(1);
    dm.addButton('change file', [], @changeFile);
    
    function changeFile(varargin)
        folder = Directory.get(this.folder, 'Select Tiff stack folder');
        if (~isempty(folder))
            fileChangeDm = DialogManager(this);
            fileChangeDm.open();
            fileChangeDm.addPanel(2);
            
            fileChangeDm.addText('schema', 40);
            fileSchemaInput = fileChangeDm.addInput(this.fileSchema, {@(w)40, @(w)w/2-40});
            fileChangeDm.addText(', ', {@(w)w/2, @(w)20});
            filesInput = fileChangeDm.addInput(sprintf('[%d:%d]', min(this.files), max(this.files)), {@(w)w/2+20, @(w)w/2-20});
            fileChangeDm.newLine();
            
            fileChangeDm.addButtonRow('OK', @updateFile, 'cancel', @(~,~)fileChangeDm.close());
            fileChangeDm.show();
            fileChangeDm.wait();
        end
        
        function updateFile(~,~)
            try
                files = eval(filesInput.String);
                assert(isnumeric(files), 'File range has to be numeric.');
                
                firstFile = File( ...
                    folder, ...
                    DistributedTiffStack.parseFileSchema(fileSchemaInput.String, files, 1) ...
                );
                assert(firstFile.exists(), 'Files not found.');
                
                this.fileSchema = fileSchemaInput.String;
                this.files = files;
                this.clearCache();
                this.setFile(firstFile);
                notify(dm, 'propertyChange');
                fileChangeDm.close();
            catch e
                msgbox(sprintf('Invalid input: \n\t%s', e.message), 'Error', 'error');
            end
        end
    end
end

