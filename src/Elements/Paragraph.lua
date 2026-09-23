--[[ Elements/Paragraph - title + wrapped body text ]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")

	local New = Utility.New

	return function(ctx, config)
		local root = New("Frame", {
			Name = "Paragraph",
			BackgroundColor3 = Theme.Get("Element"),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = ctx.Container,
		})
		Theme.Apply(root, { BackgroundColor3 = "Element" })
		Utility.Corner(10, root)
		local stroke = Utility.Stroke(root, Theme.Get("Stroke"), 1)
		Theme.Apply(stroke, { Color = "Stroke" })
		Utility.Padding(root, { top = 13, bottom = 13, left = 14, right = 14 })
		Utility.List(root, 6)

		local title = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Title or "Paragraph",
			TextColor3 = Theme.Get("Text"),
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Parent = root,
		})
		Theme.Apply(title, { TextColor3 = "Text" })

		local body = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Content or "",
			TextColor3 = Theme.Get("SubText"),
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			LineHeight = 1.15,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Parent = root,
		})
		Theme.Apply(body, { TextColor3 = "SubText" })

		return {
			Instance = root,
			SetTitle = function(text) title.Text = text end,
			SetContent = function(text) body.Text = text end,
		}
	end
end
