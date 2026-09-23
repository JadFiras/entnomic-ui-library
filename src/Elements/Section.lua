--[[ Elements/Section - a heading that groups the elements below it ]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")

	local New = Utility.New

	return function(ctx, config)
		local root = New("Frame", {
			Name = "Section",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			Parent = ctx.Container,
		})

		local bar = New("Frame", {
			BackgroundColor3 = Theme.Get("Accent"),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(3, 12),
			Parent = root,
		})
		Theme.Apply(bar, { BackgroundColor3 = "Accent" })
		Utility.Corner(2, bar)

		local label = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Title or "Section",
			TextColor3 = Theme.Get("Text"),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -12, 1, 0),
			Parent = root,
		})
		Theme.Apply(label, { TextColor3 = "Text" })

		return {
			Instance = root,
			SetTitle = function(text) label.Text = text end,
		}
	end
end
