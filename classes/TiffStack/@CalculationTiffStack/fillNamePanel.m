function fillNamePanel(this, dm, panel, addText)
    addText('<');
    this.stack1.getNamePanel(dm, panel);
    addText('>');
    addText(this.operation);
    addText('<');
    this.stack2.getNamePanel(dm, panel);
    addText('>');
end