function json = toJSON(this)
    json = JSON.objectStringify(this, {this.property, this.range}, 'property', 'range');
end