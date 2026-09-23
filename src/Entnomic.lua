--[[
	Entnomic
	Main entry point. Creates the protected ScreenGui and exposes the public API.

	local Entnomic = loadstring(game:HttpGet(".../loader.lua"))()

	local Window = Entnomic:CreateWindow({
		Title = "Entnomic",
		Subtitle = "Script Hub",
		Icon = "layers",
		Theme = "Dark",
		Keybind = Enum.KeyCode.RightShift,
		ConfigSaving = true,
		ConfigFolder = "MyHub",
	})
]]

return function(import)
	local Players = game:GetService("Players")

	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Config = import("Modules/Config")
	local WindowClass = import("Components/Window")
	local Notifications = import("Modules/Notifications")

	local New = Utility.New

	local Entnomic = {
		Version = "1.0.0",
		Windows = {},
	}

	-- Create a ScreenGui and parent it as safely as the executor allows.
	local function createScreen()
		local gui = New("ScreenGui", {
			Name = "Entnomic_" .. tostring(math.random(1000, 9999)),
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			IgnoreGuiInset = true,
			DisplayOrder = 9999,
		})

		local parented = false

		-- syn/executor gui protection + hidden container
		pcall(function()
			if typeof(syn) == "table" and syn.protect_gui then
				syn.protect_gui(gui)
			end
			if typeof(gethui) == "function" then
				gui.Parent = gethui()
				parented = true
			end
		end)

		if not parented then
			pcall(function()
				gui.Parent = game:GetService("CoreGui")
				parented = true
			end)
		end

		if not parented then
			local lp = Players.LocalPlayer
			if lp then
				gui.Parent = lp:WaitForChild("PlayerGui")
			end
		end

		return gui
	end

	local screen = createScreen()
	local notifier = Notifications.new(screen)

	function Entnomic:CreateWindow(config)
		config = config or {}

		-- Apply the requested theme before building so colors resolve correctly.
		if config.Theme and Theme.Palettes[config.Theme] then
			Theme.Set(config.Theme)
		end

		local cfg = Config.new({
			Enabled = config.ConfigSaving == true,
			Folder = config.ConfigFolder or "Entnomic",
			FileName = config.ConfigFile or "config",
		})

		local ctx = {
			Screen = screen,
			Config = cfg,
			Notify = function(o) notifier:Notify(o) end,
			Destroy = function() Entnomic:Destroy() end,
		}

		local window = WindowClass.new(ctx, config)
		window.Config = cfg

		-- Config helpers exposed on the window.
		function window:SaveConfiguration()
			return cfg:Save()
		end
		function window:LoadConfiguration()
			return cfg:Load()
		end

		table.insert(self.Windows, window)
		return window
	end

	function Entnomic:Notify(config)
		return notifier:Notify(config)
	end

	function Entnomic:SetTheme(name)
		return Theme.Set(name)
	end

	function Entnomic:GetThemes()
		local names = {}
		for name in pairs(Theme.Palettes) do
			table.insert(names, name)
		end
		return names
	end

	function Entnomic:Destroy()
		for _, window in ipairs(self.Windows) do
			pcall(function() window.Root:Destroy() end)
		end
		pcall(function() screen:Destroy() end)
		self.Windows = {}
	end

	return Entnomic
end
