function str = char(this)
    if (~isempty(this.name))
        str = this.name;
    else
        str = 'raw data';
    end
end