--[[
	Modules/Theme
	Palette definitions + a live registry so themes can be swapped at runtime.

	Usage:
		Theme.Apply(instance, { BackgroundColor3 = "Element", TextColor3 = "Text" })
		Theme.Set("Midnight")
]]

return function(import)
	local Utility = import("Modules/Utility")

	local Theme = {}

	-- Every palette shares the same key set so switching is seamless.
	Theme.Palettes = {
		Dark = {
			Background   = Color3.fromRGB(14, 14, 17),
			Sidebar      = Color3.fromRGB(18, 18, 22),
			Topbar       = Color3.fromRGB(18, 18, 22),
			Element      = Color3.fromRGB(26, 26, 32),
			ElementHover = Color3.fromRGB(33, 33, 40),
			ElementHold  = Color3.fromRGB(38, 38, 46),
			Stroke       = Color3.fromRGB(38, 38, 46),
			StrokeLight  = Color3.fromRGB(52, 52, 62),
			Accent       = Color3.fromRGB(96, 130, 255),
			AccentDim    = Color3.fromRGB(63, 84, 168),
			Text         = Color3.fromRGB(244, 244, 247),
			SubText      = Color3.fromRGB(160, 160, 172),
			MutedText    = Color3.fromRGB(104, 104, 116),
			Notification = Color3.fromRGB(22, 22, 27),
			Danger       = Color3.fromRGB(235, 87, 87),
			Success      = Color3.fromRGB(86, 199, 130),
		},
		Midnight = {
			Background   = Color3.fromRGB(10, 12, 20),
			Sidebar      = Color3.fromRGB(13, 16, 26),
			Topbar       = Color3.fromRGB(13, 16, 26),
			Element      = Color3.fromRGB(19, 23, 37),
			ElementHover = Color3.fromRGB(26, 31, 48),
			ElementHold  = Color3.fromRGB(31, 37, 57),
			Stroke       = Color3.fromRGB(30, 36, 55),
			StrokeLight  = Color3.fromRGB(44, 52, 78),
			Accent       = Color3.fromRGB(112, 148, 255),
			AccentDim    = Color3.fromRGB(70, 92, 168),
			Text         = Color3.fromRGB(238, 242, 255),
			SubText      = Color3.fromRGB(150, 158, 186),
			MutedText    = Color3.fromRGB(96, 104, 132),
			Notification = Color3.fromRGB(16, 20, 32),
			Danger       = Color3.fromRGB(240, 96, 108),
			Success      = Color3.fromRGB(88, 208, 148),
		},
		Obsidian = {
			Background   = Color3.fromRGB(12, 12, 12),
			Sidebar      = Color3.fromRGB(16, 16, 16),
			Topbar       = Color3.fromRGB(16, 16, 16),
			Element      = Color3.fromRGB(23, 23, 23),
			ElementHover = Color3.fromRGB(30, 30, 30),
			ElementHold  = Color3.fromRGB(36, 36, 36),
			Stroke       = Color3.fromRGB(34, 34, 34),
			StrokeLight  = Color3.fromRGB(50, 50, 50),
			Accent       = Color3.fromRGB(228, 228, 232),
			AccentDim    = Color3.fromRGB(140, 140, 146),
			Text         = Color3.fromRGB(245, 245, 245),
			SubText      = Color3.fromRGB(158, 158, 158),
			MutedText    = Color3.fromRGB(102, 102, 102),
			Notification = Color3.fromRGB(20, 20, 20),
			Danger       = Color3.fromRGB(235, 87, 87),
			Success      = Color3.fromRGB(86, 199, 130),
		},
	}

	Theme.Current = "Dark"
	Theme.Colors = Theme.Palettes.Dark

	-- registry entries: { inst = Instance, map = { Prop = "Key" } }
	local registry = {}

	local function resolve(key)
		return Theme.Colors[key] or Color3.fromRGB(255, 0, 255)
	end

	-- Apply a color mapping now and register for future theme swaps.
	function Theme.Apply(inst, map)
		table.insert(registry, { inst = inst, map = map })
		for prop, key in pairs(map) do
			inst[prop] = resolve(key)
		end

		-- Clean the registry when the instance is destroyed.
		inst.Destroying:Connect(function()
			for i = #registry, 1, -1 do
				if registry[i].inst == inst then
					table.remove(registry, i)
				end
			end
		end)

		return inst
	end

	function Theme.Get(key)
		return resolve(key)
	end

	-- Swap the active palette, tweening every registered instance.
	function Theme.Set(name)
		local palette = Theme.Palettes[name]
		if not palette then
			return false
		end

		Theme.Current = name
		Theme.Colors = palette

		for _, entry in ipairs(registry) do
			if entry.inst and entry.inst.Parent then
				local goal = {}
				for prop, key in pairs(entry.map) do
					goal[prop] = resolve(key)
				end
				Utility.Tween(entry.inst, goal, 0.25)
			end
		end

		return true
	end

	return Theme
end
