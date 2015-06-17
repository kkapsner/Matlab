function close(this, ~,~)
    if (isfield(this.handles, 'figure') && ishandle(this.handles.figure))
        delete(this.handles.figure);
        notify(this, 'winClose');
    end
    this.handles = struct();
end