--[[ Elements/Slider ]]

return function(import)
	local UserInputService = game:GetService("UserInputService")

	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")

	local New = Utility.New

	return function(ctx, config)
		local min = config.Min or 0
		local max = config.Max or 100
		local increment = config.Increment or 1
		local suffix = config.Suffix or ""
		local value = math.clamp(config.Default or min, min, max)

		local root = New("Frame", {
			Name = "Slider",
			BackgroundColor3 = Theme.Get("Element"),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = ctx.Container,
		})
		Theme.Apply(root, { BackgroundColor3 = "Element" })
		Utility.Corner(10, root)
		local stroke = Utility.Stroke(root, Theme.Get("Stroke"), 1)
		Theme.Apply(stroke, { Color = "Stroke" })
		Utility.Padding(root, { top = 12, bottom = 13, left = 14, right = 14 })
		Utility.List(root, 12)

		-- Top: title + value
		local top = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Parent = root,
		})

		local title = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Title or "Slider",
			TextColor3 = Theme.Get("Text"),
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -70, 1, 0),
			Parent = top,
		})
		Theme.Apply(title, { TextColor3 = "Text" })

		local valueLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = tostring(value) .. suffix,
			TextColor3 = Theme.Get("Accent"),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, 70, 1, 0),
			Parent = top,
		})
		Theme.Apply(valueLabel, { TextColor3 = "Accent" })

		-- Track
		local track = New("Frame", {
			BackgroundColor3 = Theme.Get("ElementHold"),
			Size = UDim2.new(1, 0, 0, 6),
			Parent = root,
		})
		Theme.Apply(track, { BackgroundColor3 = "ElementHold" })
		Utility.Corner(3, track)

		local fill = New("Frame", {
			BackgroundColor3 = Theme.Get("Accent"),
			Size = UDim2.new(0, 0, 1, 0),
			Parent = track,
		})
		Theme.Apply(fill, { BackgroundColor3 = "Accent" })
		Utility.Corner(3, fill)

		local knob = New("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(14, 14),
			ZIndex = 2,
			Parent = fill,
		})
		Utility.Corner(7, knob)
		Utility.Stroke(knob, Theme.Get("Accent"), 2)

		local api = {}
		local dragging = false

		local function round(v)
			local snapped = min + math.floor((v - min) / increment + 0.5) * increment
			-- avoid floating point tails
			local decimals = math.max(0, -math.floor(math.log(increment, 10) + 1e-9))
			local mult = 10 ^ decimals
			return math.clamp(math.floor(snapped * mult + 0.5) / mult, min, max)
		end

		local function setFromAlpha(alpha, animate)
			alpha = math.clamp(alpha, 0, 1)
			value = round(min + (max - min) * alpha)
			local realAlpha = (value - min) / (max - min)
			local dur = animate and 0.12 or 0
			Utility.Tween(fill, { Size = UDim2.new(realAlpha, 0, 1, 0) }, dur)
			valueLabel.Text = tostring(value) .. suffix
		end

		function api.Set(v, silent)
			value = round(v)
			local alpha = (value - min) / (max - min)
			Utility.Tween(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, 0.12)
			valueLabel.Text = tostring(value) .. suffix
			if not silent and config.Callback then
				task.spawn(config.Callback, value)
			end
		end

		function api.Get()
			return value
		end

		local hitbox = New("TextButton", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(1, 0, 0, 22),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 3,
			Parent = track,
		})

		local function updateFromInput(x)
			local alpha = (x - track.AbsolutePosition.X) / track.AbsoluteSize.X
			setFromAlpha(alpha, false)
			if config.Callback then
				task.spawn(config.Callback, value)
			end
		end

		hitbox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				Utility.Tween(knob, { Size = UDim2.fromOffset(16, 16) }, 0.1)
				updateFromInput(input.Position.X)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				if dragging then
					Utility.Tween(knob, { Size = UDim2.fromOffset(14, 14) }, 0.1)
				end
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging
				and (input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromInput(input.Position.X)
			end
		end)

		-- Initial position (defer one frame so AbsoluteSize is valid)
		task.defer(function()
			local alpha = (value - min) / (max - min)
			fill.Size = UDim2.new(alpha, 0, 1, 0)
		end)

		if config.Flag and ctx.Config then
			ctx.Config:Register(config.Flag, { Get = api.Get, Set = function(v) api.Set(v, true) end })
		end
		if config.Default and config.Callback then
			task.spawn(config.Callback, value)
		end

		api.Instance = root
		return api
	end
end
