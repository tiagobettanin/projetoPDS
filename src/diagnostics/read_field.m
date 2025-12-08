function value = read_field(structure, fieldName, defaultValue)
    if isstruct(structure) && isfield(structure, fieldName)
        value = structure.(fieldName);
        if isempty(value)
            value = defaultValue;
        end
    else
        value = defaultValue;
    end
end
