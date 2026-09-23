--[[ Elements/Colorpicker - inline HSV picker ]]

return function(import)
	local UserInputService = game:GetService("UserInputService")

	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Icons = import("Modules/Icons")

	local New = Utility.New

	local PICKER_HEIGHT = 120

	return function(ctx, config)
		local default = config.Default or Color3.fromRGB(96, 130, 255)
		local h, s, v = default:ToHSV()

		local root = New("Frame", {
			Name = "Colorpicker",
			BackgroundColor3 = Theme.Get("Element"),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = true,
			Parent = ctx.Container,
		})
		Theme.Apply(root, { BackgroundColor3 = "Element" })
		Utility.Corner(10, root)
		local stroke = Utility.Stroke(root, Theme.Get("Stroke"), 1)
		Theme.Apply(stroke, { Color = "Stroke" })
		Utility.List(root, 0)

		-- Header
		local header = New("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 44),
			Text = "",
			AutoButtonColor = false,
			Parent = root,
		})
		Utility.Padding(header, { left = 14, right = 14 })

		local title = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Title or "Color",
			TextColor3 = Theme.Get("Text"),
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -70, 1, 0),
			Parent = header,
		})
		Theme.Apply(title, { TextColor3 = "Text" })

		local swatch = New("Frame", {
			BackgroundColor3 = default,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -24, 0.5, 0),
			Size = UDim2.fromOffset(34, 20),
			Parent = header,
		})
		Utility.Corner(6, swatch)
		Utility.Stroke(swatch, Theme.Get("StrokeLight"), 1, 0.3)

		local chevron = New("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			ImageColor3 = Theme.Get("MutedText"),
			Parent = header,
		})
		Theme.Apply(chevron, { ImageColor3 = "MutedText" })
		local cres = Icons.Resolve("chevron-down")
		chevron.Image = cres.Image
		chevron.ImageRectOffset = cres.ImageRectOffset
		chevron.ImageRectSize = cres.ImageRectSize

		-- Body
		local holder = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			ClipsDescendants = true,
			Parent = root,
		})

		local divider = New("Frame", {
			BackgroundColor3 = Theme.Get("Stroke"),
			BorderSizePixel = 0,
			Size = UDim2.new(1, -28, 0, 1),
			Position = UDim2.fromOffset(14, 0),
			Parent = holder,
		})
		Theme.Apply(divider, { BackgroundColor3 = "Stroke" })

		-- Saturation / Value box
		local sv = New("ImageButton", {
			BackgroundColor3 = Color3.fromHSV(h, 1, 1),
			Position = UDim2.fromOffset(14, 14),
			Size = UDim2.new(1, -28 - 22, 0, PICKER_HEIGHT),
			Text = "",
			AutoButtonColor = false,
			ClipsDescendants = true,
			Parent = holder,
		})
		Utility.Corner(8, sv)
		-- Saturation (white -> clear, left to right) then Value (clear -> black, top to bottom)
		local whiteGrad = New("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), Parent = sv })
		Utility.Corner(8, whiteGrad)
		Utility.Gradient(whiteGrad, ColorSequence.new(Color3.new(1, 1, 1)), 0,
			NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }))
		local blackGrad = New("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), Parent = sv })
		Utility.Corner(8, blackGrad)
		Utility.Gradient(blackGrad, ColorSequence.new(Color3.new(0, 0, 0)), 90,
			NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }))

		local svDot = New("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(11, 11),
			ZIndex = 5,
			Parent = sv,
		})
		Utility.Corner(6, svDot)
		Utility.Stroke(svDot, Color3.new(0, 0, 0), 1.5, 0.2)

		-- Hue bar (vertical)
		local hue = New("ImageButton", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 14),
			Size = UDim2.fromOffset(14, PICKER_HEIGHT),
			Text = "",
			AutoButtonColor = false,
			Parent = holder,
		})
		Utility.Corner(6, hue)
		Utility.Gradient(hue, ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
		}), 90)

		local hueDot = New("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 4, 0, 4),
			ZIndex = 5,
			Parent = hue,
		})
		Utility.Corner(2, hueDot)
		Utility.Stroke(hueDot, Color3.new(0, 0, 0), 1, 0.3)

		local api = {}
		local color = default

		local function updateVisuals()
			color = Color3.fromHSV(h, s, v)
			sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			swatch.BackgroundColor3 = color
			svDot.Position = UDim2.new(s, 0, 1 - v, 0)
			hueDot.Position = UDim2.new(0.5, 0, h, 0)
			svDot.BackgroundColor3 = color
		end

		local function fire()
			if config.Callback then
				task.spawn(config.Callback, color)
			end
		end

		-- Dragging for SV
		local svDrag = false
		sv.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				svDrag = true
			end
		end)
		-- Dragging for hue
		local hueDrag = false
		hue.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				hueDrag = true
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				svDrag, hueDrag = false, false
			end
		end)

		local function processSV(pos)
			local x = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
			local y = math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
			s, v = x, 1 - y
			updateVisuals()
			fire()
		end

		local function processHue(pos)
			local y = math.clamp((pos.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
			h = y
			updateVisuals()
			fire()
		end

		sv.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				processSV(input.Position)
			end
		end)
		hue.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				processHue(input.Position)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				if svDrag then processSV(input.Position) end
				if hueDrag then processHue(input.Position) end
			end
		end)

		-- Open / close
		local open = false
		local function openHeight()
			return 14 + PICKER_HEIGHT + 14
		end

		function api.Toggle()
			open = not open
			if open then
				Utility.Tween(holder, { Size = UDim2.new(1, 0, 0, openHeight()) }, 0.22, Enum.EasingStyle.Quint)
				Utility.Tween(chevron, { Rotation = 180 }, 0.22)
				Utility.Tween(stroke, { Color = Theme.Get("StrokeLight") }, 0.2)
			else
				Utility.Tween(holder, { Size = UDim2.new(1, 0, 0, 0) }, 0.22, Enum.EasingStyle.Quint)
				Utility.Tween(chevron, { Rotation = 0 }, 0.22)
				Utility.Tween(stroke, { Color = Theme.Get("Stroke") }, 0.2)
			end
		end

		function api.Set(c, silent)
			color = c
			h, s, v = c:ToHSV()
			updateVisuals()
			if not silent then fire() end
		end

		function api.Get()
			return color
		end

		header.MouseButton1Click:Connect(api.Toggle)

		updateVisuals()

		if config.Flag and ctx.Config then
			ctx.Config:Register(config.Flag, { Get = api.Get, Set = function(c) api.Set(c, true) end })
		end
		if config.Default and config.Callback then
			fire()
		end

		api.Instance = root
		return api
	end
end
