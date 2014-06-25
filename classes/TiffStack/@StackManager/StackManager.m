classdef StackManager < handle
    %STACKMANAGER a GUI for managing stacks
    %   Detailed explanation goes here
    
    properties(SetObservable)
        title
        stacks
    end
    properties(Access=protected)
        handles
    end
    
    events
        stackAdded
        stackRemoved
    end
    
    methods
        function this = StackManager(title, stacks, preselect)
            if (nargin < 1)
                title = '';
            end
            if (nargin < 2)
                stacks = {};
            end
            if (nargin < 3)
                preselect = [];
            end
%             if (~iscell(stacks))
%                 stacks = mat2cell(stacks, ones(size(stacks, 1), 1), ones(size(stacks, 2), 1)); %#ok<MMTC>
%             end
            this.title = title;
            this.stacks = {};%stacks;
            this.open(preselect);
            this.addStack(stacks);
        end
        
        function wait(this)
            uiwait(this.handles.figure);
        end
        
        function delete(this)
            this.close();
        end
        
        open(this, preselect)
        close(this, ~,~)
        addStack(this, stack)
        removeStack(this, stack)
    end
    
    methods (Access=protected)
        panel = addStackPanel(this, stack)
        arrangeStackContainer(this)
    end
    
end

