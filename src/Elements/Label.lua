--[[ Elements/Label - a simple text line inside a subtle panel ]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")

	local New = Utility.New

	return function(ctx, config)
		local root = New("Frame", {
			Name = "Label",
			BackgroundColor3 = Theme.Get("Element"),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = ctx.Container,
		})
		Theme.Apply(root, { BackgroundColor3 = "Element" })
		Utility.Corner(10, root)
		local stroke = Utility.Stroke(root, Theme.Get("Stroke"), 1)
		Theme.Apply(stroke, { Color = "Stroke" })
		Utility.Padding(root, { top = 11, bottom = 11, left = 14, right = 14 })

		local label = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Text or "Label",
			TextColor3 = Theme.Get("SubText"),
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Parent = root,
		})
		Theme.Apply(label, { TextColor3 = "SubText" })

		return {
			Instance = root,
			SetText = function(text) label.Text = text end,
		}
	end
end
