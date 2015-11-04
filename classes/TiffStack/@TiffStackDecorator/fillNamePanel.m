function fillNamePanel(this, dm, panel, addText)
    addText('<');
    this.stack.getNamePanel(dm, panel);
    addText('>');
end