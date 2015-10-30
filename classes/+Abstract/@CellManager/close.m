function close(this, ~,~)
    if (this.isOpen)
        delete(this.handles.figure);
        notify(this, 'winClose');
    end
    this.resetHandles();
end