--[[ Elements/Divider - a thin horizontal rule ]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")

	local New = Utility.New

	return function(ctx, config)
		local root = New("Frame", {
			Name = "Divider",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 1),
			Parent = ctx.Container,
		})

		local line = New("Frame", {
			BackgroundColor3 = Theme.Get("Stroke"),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(1, 0, 0, 1),
			Parent = root,
		})
		Theme.Apply(line, { BackgroundColor3 = "Stroke" })

		return { Instance = root }
	end
end
