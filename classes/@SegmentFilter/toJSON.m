function json = toJSON(this)
    if ~isscalar(this)
        c = cell(size(this));
        for i = 1:numel(this)
            obj = this(i);
            c{i} = JSON.objectToMap(obj, {obj.property, obj.range}, 'property', 'range');
        end
        json = JSON.stringify(c);
    else
        json = JSON.objectStringify(this, {this.property, this.range}, 'property', 'range');
    end
end