--[[ Elements/Toggle ]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Element = import("Modules/Element")

	local New = Utility.New

	return function(ctx, config)
		local base = Element.Row(ctx.Container, {
			Name = "Toggle",
			Title = config.Title or "Toggle",
			Description = config.Description,
			hover = true,
		})

		local state = config.Default == true

		-- Switch track
		local track = New("Frame", {
			BackgroundColor3 = Theme.Get("ElementHold"),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromOffset(42, 22),
			Parent = base.Right,
		})
		Theme.Apply(track, { BackgroundColor3 = "ElementHold" })
		Utility.Corner(11, track)
		local trackStroke = Utility.Stroke(track, Theme.Get("StrokeLight"), 1, 0.3)

		local knob = New("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			Parent = track,
		})
		Utility.Corner(8, knob)

		local click = New("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 3,
			Parent = base.Root,
		})

		local function apply(animate)
			local dur = animate and 0.18 or 0
			if state then
				Utility.Tween(track, { BackgroundColor3 = Theme.Get("Accent") }, dur)
				Utility.Tween(knob, { Position = UDim2.new(1, -19, 0.5, 0) }, dur, Enum.EasingStyle.Back)
				Utility.Tween(trackStroke, { Transparency = 1 }, dur)
			else
				Utility.Tween(track, { BackgroundColor3 = Theme.Get("ElementHold") }, dur)
				Utility.Tween(knob, { Position = UDim2.new(0, 3, 0.5, 0) }, dur, Enum.EasingStyle.Back)
				Utility.Tween(trackStroke, { Transparency = 0.3 }, dur)
			end
		end

		local api = {}

		function api.Set(value, silent)
			state = value and true or false
			apply(true)
			if not silent and config.Callback then
				task.spawn(config.Callback, state)
			end
		end

		function api.Get()
			return state
		end

		click.MouseButton1Click:Connect(function()
			api.Set(not state)
		end)

		apply(false)

		if config.Flag and ctx.Config then
			ctx.Config:Register(config.Flag, { Get = api.Get, Set = function(v) api.Set(v, true) end })
		end
		if config.Default and config.Callback then
			task.spawn(config.Callback, state)
		end

		api.Instance = base.Root
		return api
	end
end
