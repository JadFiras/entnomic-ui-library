--[[
	Modules/Notifications
	Bottom-right stacked toast notifications.
]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Icons = import("Modules/Icons")

	local New = Utility.New

	local Notifications = {}
	Notifications.__index = Notifications

	function Notifications.new(screen)
		local self = setmetatable({}, Notifications)

		local holder = New("Frame", {
			Name = "Notifications",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.new(0, 300, 1, -36),
			Parent = screen,
		})
		local layout = Utility.List(holder, 10)
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right

		self.Holder = holder
		return self
	end

	function Notifications:Notify(config)
		config = config or {}
		local duration = config.Duration or 5

		local accentKey = "Accent"
		if config.Type == "success" then accentKey = "Success"
		elseif config.Type == "error" then accentKey = "Danger" end

		local card = New("Frame", {
			Name = "Toast",
			BackgroundColor3 = Theme.Get("Notification"),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.fromOffset(320, 0),
			Parent = self.Holder,
		})
		Theme.Apply(card, { BackgroundColor3 = "Notification" })
		Utility.Corner(11, card)
		local stroke = Utility.Stroke(card, Theme.Get("Stroke"), 1)
		Theme.Apply(stroke, { Color = "Stroke" })
		Utility.Padding(card, { top = 12, bottom = 12, left = 14, right = 14 })

		-- Accent side bar
		local bar = New("Frame", {
			BackgroundColor3 = Theme.Get(accentKey),
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.new(0, 3, 1, 0),
			Parent = card,
		})
		Theme.Apply(bar, { BackgroundColor3 = accentKey })

		local hasIcon = config.Icon ~= nil
		local textX = hasIcon and 30 or 0

		if hasIcon then
			local icon = New("ImageLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 1),
				Size = UDim2.fromOffset(18, 18),
				ImageColor3 = Theme.Get(accentKey),
				Parent = card,
			})
			Theme.Apply(icon, { ImageColor3 = accentKey })
			local res = Icons.Resolve(config.Icon)
			icon.Image = res.Image
			icon.ImageRectOffset = res.ImageRectOffset
			icon.ImageRectSize = res.ImageRectSize
		end

		local col = New("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(textX, 0),
			Size = UDim2.new(1, -textX, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = card,
		})
		Utility.List(col, 3)

		local title = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Title or "Notification",
			TextColor3 = Theme.Get("Text"),
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Parent = col,
		})
		Theme.Apply(title, { TextColor3 = "Text" })

		if config.Content then
			local content = New("TextLabel", {
				BackgroundTransparency = 1,
				Text = config.Content,
				TextColor3 = Theme.Get("SubText"),
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Parent = col,
			})
			Theme.Apply(content, { TextColor3 = "SubText" })
		end

		-- Progress bar
		local progressTrack = New("Frame", {
			BackgroundColor3 = Theme.Get("Stroke"),
			Position = UDim2.new(0, 0, 1, 4),
			Size = UDim2.new(1, 0, 0, 2),
			Parent = col,
		})
		Theme.Apply(progressTrack, { BackgroundColor3 = "Stroke" })
		Utility.Corner(1, progressTrack)

		local progress = New("Frame", {
			BackgroundColor3 = Theme.Get(accentKey),
			Size = UDim2.new(1, 0, 1, 0),
			Parent = progressTrack,
		})
		Theme.Apply(progress, { BackgroundColor3 = accentKey })
		Utility.Corner(1, progress)

		-- Entrance
		card.BackgroundTransparency = 1
		Utility.Tween(card, { Position = UDim2.fromOffset(0, 0), BackgroundTransparency = 0 }, 0.3, Enum.EasingStyle.Quint)

		local dismissed = false
		local function dismiss()
			if dismissed then return end
			dismissed = true
			local t = Utility.Tween(card, {
				Position = UDim2.fromOffset(320, 0),
				BackgroundTransparency = 1,
			}, 0.25, Enum.EasingStyle.Quint)
			t.Completed:Once(function()
				card:Destroy()
			end)
		end

		Utility.Tween(progress, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)
		task.delay(duration, dismiss)

		return { Dismiss = dismiss, Instance = card }
	end

	return Notifications
end
