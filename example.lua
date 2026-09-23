--[[
	Entnomic — usage example

	After uploading this repo to GitHub, set BASE_URL inside loader.lua to your
	raw path, then load the library like this:

		local Entnomic = loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/YOUR_USERNAME/entnomic/main/loader.lua"
		))()

	Icon names come straight from https://lucide.dev/icons (e.g. "home", "sword",
	"settings", "user", "eye"). You can also pass a Roblox asset id number.
]]

local Entnomic = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/JadFiras/entnomic-ui-library/refs/heads/main/loader.lua"
))()

local Window = Entnomic:CreateWindow({
	Title = "Entnomic",
	Subtitle = "Script Hub",
	Icon = "layers",
	Size = UDim2.fromOffset(760, 500),
	Theme = "Dark", -- "Dark" | "Midnight" | "Obsidian"
	Keybind = Enum.KeyCode.RightShift,
	ConfigSaving = true,
	ConfigFolder = "Entnomic",
})

-------------------------------------------------------------------
-- Main tab
-------------------------------------------------------------------
local Main = Window:CreateTab({ Title = "Main", Icon = "home" })

Main:CreateSection("Combat")

Main:CreateToggle({
	Title = "God Mode",
	Description = "Prevents all incoming damage",
	Default = false,
	Flag = "godmode",
	Callback = function(state)
		print("God Mode:", state)
	end,
})

Main:CreateSlider({
	Title = "Walk Speed",
	Description = "Adjust your character speed",
	Min = 16,
	Max = 500,
	Default = 16,
	Increment = 1,
	Suffix = " studs",
	Flag = "walkspeed",
	Callback = function(value)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = value
		end
	end,
})

Main:CreateButton({
	Title = "Kill All",
	Description = "Eliminate every player",
	Icon = "sword",
	Callback = function()
		Window:Notify({
			Title = "Executed",
			Content = "Kill All has been triggered.",
			Icon = "check",
			Type = "success",
			Duration = 4,
		})
	end,
})

Main:CreateDivider()

Main:CreateSection("Targeting")

Main:CreateDropdown({
	Title = "Aim Part",
	Placeholder = "Choose a part",
	Values = { "Head", "Torso", "HumanoidRootPart", "Random" },
	Default = "Head",
	Flag = "aimpart",
	Callback = function(value)
		print("Aim Part:", value)
	end,
})

Main:CreateDropdown({
	Title = "Active ESP",
	Multi = true,
	Values = { "Boxes", "Names", "Health", "Distance", "Tracers", "Skeleton" },
	Default = { "Boxes", "Names" },
	Flag = "esp",
	Callback = function(selected)
		print("ESP:", table.concat(selected, ", "))
	end,
})

-------------------------------------------------------------------
-- Visuals tab
-------------------------------------------------------------------
local Visuals = Window:CreateTab({ Title = "Visuals", Icon = "eye" })

Visuals:CreateSection("Appearance")

Visuals:CreateColorpicker({
	Title = "ESP Color",
	Default = Color3.fromRGB(96, 130, 255),
	Flag = "espcolor",
	Callback = function(color)
		print("ESP Color:", color)
	end,
})

Visuals:CreateInput({
	Title = "Watermark Text",
	Placeholder = "Type here...",
	Default = "entnomic",
	Flag = "watermark",
	Callback = function(text, enter)
		print("Watermark:", text, "submitted:", enter)
	end,
})

Visuals:CreateParagraph({
	Title = "About Visuals",
	Content = "These options control on-screen rendering. Everything you change here is saved to your config automatically when you call SaveConfiguration.",
})

-------------------------------------------------------------------
-- Settings tab
-------------------------------------------------------------------
local Settings = Window:CreateTab({ Title = "Settings", Icon = "settings" })

Settings:CreateSection("Interface")

Settings:CreateDropdown({
	Title = "Theme",
	Values = Entnomic:GetThemes(),
	Default = "Dark",
	Callback = function(theme)
		Entnomic:SetTheme(theme)
	end,
})

Settings:CreateKeybind({
	Title = "Toggle Menu",
	Default = Enum.KeyCode.RightShift,
	Flag = "togglekey",
	Callback = function()
		Window:Toggle()
	end,
})

Settings:CreateSection("Configuration")

Settings:CreateButton({
	Title = "Save Configuration",
	Icon = "save",
	Callback = function()
		local ok = Window:SaveConfiguration()
		Window:Notify({
			Title = ok and "Saved" or "Save Failed",
			Content = ok and "Your config was written to disk." or "No file API available.",
			Icon = ok and "check" or "x",
			Type = ok and "success" or "error",
		})
	end,
})

Settings:CreateButton({
	Title = "Load Configuration",
	Icon = "folder-open",
	Callback = function()
		Window:LoadConfiguration()
	end,
})

-- Welcome notification
Window:Notify({
	Title = "Welcome to Entnomic",
	Content = "Press Right Shift to toggle the menu.",
	Icon = "sparkles",
	Duration = 6,
})
