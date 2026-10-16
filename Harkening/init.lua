-- Harkening UI v2 — public ModuleScript entry point.
local Framework = require("./Core/Framework")
local Harkening = { Version = Framework.Version, Icons = require("./Utilities/Icons") }

function Harkening.new(options)
	return Framework.new(options)
end

Harkening.Create = Harkening.new
Harkening.Crear = Harkening.new

return Harkening
