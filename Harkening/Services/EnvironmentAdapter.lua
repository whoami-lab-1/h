-- Centralizes client/environment resolution and Roblox service access.
local EnvironmentAdapter = {}
EnvironmentAdapter.__index = EnvironmentAdapter

function EnvironmentAdapter.new(options)
	return setmetatable({ Options = options or {} }, EnvironmentAdapter)
end

function EnvironmentAdapter:GetService(name)
	assert(type(name) == "string" and name ~= "", "GetService necesita un nombre de servicio")
	return game:GetService(name)
end

function EnvironmentAdapter:GetPlayer()
	local runService = self:GetService("RunService")
	if not runService:IsClient() then
		return nil, "Harkening UI debe inicializarse desde un LocalScript en el cliente."
	end
	local players = self:GetService("Players")
	local player = players.LocalPlayer
	if not player then return nil, "Players.LocalPlayer aún no está disponible." end
	return player
end

function EnvironmentAdapter:ResolveParent()
	-- Explicit Parent does not bypass client validation: a server-side ScreenGui
	-- is not a usable player interface and would otherwise fail silently.
	local player, errorMessage = self:GetPlayer()
	assert(player, errorMessage)

	local requestedParent = self.Options.Parent
	if requestedParent ~= nil then
		assert(typeof(requestedParent) == "Instance", "Parent debe ser una Instance válida para ScreenGui")
		return requestedParent
	end

	local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")
	assert(playerGui and playerGui:IsA("PlayerGui"), "No se pudo resolver PlayerGui")
	return playerGui
end

function EnvironmentAdapter:GetServices()
	return {
		Players = self:GetService("Players"),
		RunService = self:GetService("RunService"),
		TweenService = self:GetService("TweenService"),
		UserInputService = self:GetService("UserInputService"),
		Workspace = self:GetService("Workspace"),
        MarketplaceService = self:GetService("MarketplaceService"),
        MarketplaceService = self:GetService("MarketplaceService"),
	}
end

return EnvironmentAdapter
