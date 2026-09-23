--[[
	Modules/Element
	Builds the standard element row: a rounded panel with a left text column
	(title + optional description) and a right-aligned control holder.

	Elements that need a custom internal layout (slider, colorpicker, paragraph)
	can request `noRight = true` and build inside `.Body`.
]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")

	local New = Utility.New

	local Element = {}

	function Element.Row(parent, opts)
		opts = opts or {}

		local root = New("Frame", {
			Name = opts.Name or "Element",
			BackgroundColor3 = Theme.Get("Element"),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = opts.LayoutOrder or 0,
			Parent = parent,
		})
		Theme.Apply(root, { BackgroundColor3 = "Element" })
		Utility.Corner(10, root)

		local stroke = Utility.Stroke(root, Theme.Get("Stroke"), 1)
		Theme.Apply(stroke, { Color = "Stroke" })

		Utility.Padding(root, { top = 11, bottom = 11, left = 14, right = 14 })

		-- Body holds text column + control (or custom content).
		local body = New("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = root,
		})

		-- Left text column
		local textCol = New("Frame", {
			Name = "Text",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.new(1, opts.noRight and 0 or -128, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = body,
		})
		Utility.List(textCol, 3)

		local title = New("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			Text = opts.Title or "Element",
			TextColor3 = Theme.Get("Text"),
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.new(0, 0, 0, 0),
			Parent = textCol,
		})
		Theme.Apply(title, { TextColor3 = "Text" })

		local desc
		if opts.Description then
			desc = New("TextLabel", {
				Name = "Description",
				BackgroundTransparency = 1,
				Text = opts.Description,
				TextColor3 = Theme.Get("SubText"),
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Parent = textCol,
			})
			Theme.Apply(desc, { TextColor3 = "SubText" })
		end

		local right
		if not opts.noRight then
			right = New("Frame", {
				Name = "Control",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 118, 1, 0),
				Parent = body,
			})
		end

		-- Optional hover highlight for interactive rows.
		if opts.hover then
			Utility.Hover(root, function()
				Utility.Tween(root, { BackgroundColor3 = Theme.Get("ElementHover") }, 0.15)
			end, function()
				Utility.Tween(root, { BackgroundColor3 = Theme.Get("Element") }, 0.15)
			end)
		end

		return {
			Root = root,
			Body = body,
			TextColumn = textCol,
			Title = title,
			Description = desc,
			Right = right,
			Stroke = stroke,
		}
	end

	return Element
end
