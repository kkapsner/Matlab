function fillEntryPanel(this, entry, panel)
    dm = DialogManager(entry);
    dm.open([], panel);
    dm.addPanel(1);
    dm.addButton('-', {@(w)w-20, @(w)20}, @(~,~)this.removeEntry(entry));
    entry.dialog(dm);
    dm.show();
end