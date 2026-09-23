--[[ Elements/Keybind ]]

return function(import)
	local UserInputService = game:GetService("UserInputService")

	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Element = import("Modules/Element")

	local New = Utility.New

	local function keyName(key)
		if not key then return "None" end
		local name = tostring(key):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
		return name
	end

	return function(ctx, config)
		local base = Element.Row(ctx.Container, {
			Name = "Keybind",
			Title = config.Title or "Keybind",
			Description = config.Description,
		})

		local current = config.Default
		local listening = false

		local button = New("TextButton", {
			BackgroundColor3 = Theme.Get("ElementHold"),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromOffset(90, 30),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = keyName(current),
			TextColor3 = Theme.Get("Text"),
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			AutoButtonColor = false,
			Parent = base.Right,
		})
		Theme.Apply(button, { BackgroundColor3 = "ElementHold", TextColor3 = "Text" })
		Utility.Corner(8, button)
		Utility.Padding(button, { left = 12, right = 12 })
		local stroke = Utility.Stroke(button, Theme.Get("StrokeLight"), 1, 0.4)
		Theme.Apply(stroke, { Color = "StrokeLight" })

		local minWidth = New("UISizeConstraint", { MinSize = Vector2.new(64, 0), Parent = button })

		local api = {}

		function api.Set(key, silent)
			current = key
			button.Text = keyName(current)
			if not silent and config.ChangedCallback then
				task.spawn(config.ChangedCallback, current)
			end
		end

		function api.Get()
			return current
		end

		button.MouseButton1Click:Connect(function()
			listening = true
			button.Text = "..."
			Utility.Tween(stroke, { Color = Theme.Get("Accent"), Transparency = 0 }, 0.15)
		end)

		UserInputService.InputBegan:Connect(function(input, gpe)
			if listening then
				local key
				if input.UserInputType == Enum.UserInputType.Keyboard then
					key = input.KeyCode
				elseif input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.MouseButton2 then
					key = input.UserInputType
				end
				if key then
					listening = false
					Utility.Tween(stroke, { Color = Theme.Get("StrokeLight"), Transparency = 0.4 }, 0.15)
					if key == Enum.KeyCode.Backspace then
						api.Set(nil)
					else
						api.Set(key)
					end
				end
				return
			end

			if gpe or not current then return end
			if (input.KeyCode == current) or (input.UserInputType == current) then
				if config.Callback then
					task.spawn(config.Callback, current)
				end
			end
		end)

		if config.Flag and ctx.Config then
			ctx.Config:Register(config.Flag, { Get = api.Get, Set = function(v) api.Set(v, true) end })
		end

		api.Instance = base.Root
		return api
	end
end
