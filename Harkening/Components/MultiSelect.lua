local Dropdown = require("./Dropdown")
local MultiSelect = {}
function MultiSelect.new(context, parent, options)
	options = options or {}
	local config = table.clone(options)
	config.Multiple = true
	return Dropdown.new(context, parent, config)
end
return MultiSelect
