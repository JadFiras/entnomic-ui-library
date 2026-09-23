--[[ Elements/Input (textbox) ]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Element = import("Modules/Element")

	local New = Utility.New

	return function(ctx, config)
		local base = Element.Row(ctx.Container, {
			Name = "Input",
			Title = config.Title or "Input",
			Description = config.Description,
		})

		local box = New("Frame", {
			BackgroundColor3 = Theme.Get("ElementHold"),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromOffset(118, 30),
			Parent = base.Right,
		})
		Theme.Apply(box, { BackgroundColor3 = "ElementHold" })
		Utility.Corner(8, box)
		local boxStroke = Utility.Stroke(box, Theme.Get("StrokeLight"), 1, 0.4)
		Theme.Apply(boxStroke, { Color = "StrokeLight" })
		Utility.Padding(box, { left = 10, right = 10 })

		local input = New("TextBox", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = config.Default or "",
			PlaceholderText = config.Placeholder or "...",
			PlaceholderColor3 = Theme.Get("MutedText"),
			TextColor3 = Theme.Get("Text"),
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			ClipsDescendants = true,
			Parent = box,
		})
		Theme.Apply(input, { TextColor3 = "Text", PlaceholderColor3 = "MutedText" })

		input.Focused:Connect(function()
			Utility.Tween(boxStroke, { Color = Theme.Get("Accent"), Transparency = 0 }, 0.15)
		end)

		local api = {}

		input.FocusLost:Connect(function(enter)
			Utility.Tween(boxStroke, { Color = Theme.Get("StrokeLight"), Transparency = 0.4 }, 0.15)
			if config.Callback then
				task.spawn(config.Callback, input.Text, enter)
			end
		end)

		function api.Set(text, silent)
			input.Text = tostring(text)
			if not silent and config.Callback then
				task.spawn(config.Callback, input.Text, false)
			end
		end

		function api.Get()
			return input.Text
		end

		if config.Flag and ctx.Config then
			ctx.Config:Register(config.Flag, { Get = api.Get, Set = function(v) api.Set(v, true) end })
		end

		api.Instance = base.Root
		return api
	end
end
