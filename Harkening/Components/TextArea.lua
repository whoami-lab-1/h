local TextInput = require("./TextInput")
local TextArea = {}
function TextArea.new(context, parent, options)
    options = table.clone(options or {})
    options.Name = options.Name or "TextArea"
    options.MultiLine = true
    options.Height = options.Height or (options.Description and 138 or 118)
    options.InputHeight = options.InputHeight or (options.Description and 56 or 62)
    options.Title = options.Title or "Text area"
    return TextInput.new(context, parent, options)
end
return TextArea
