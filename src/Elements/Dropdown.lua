--[[ Elements/Dropdown - single or multi select, inline expanding ]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Icons = import("Modules/Icons")

	local New = Utility.New

	local ROW_HEIGHT = 32
	local MAX_VISIBLE = 5

	return function(ctx, config)
		local multi = config.Multi == true
		local values = config.Values or {}
		local placeholder = config.Placeholder or "Select..."

		-- selection state
		local selected = {}
		if config.Default ~= nil then
			if type(config.Default) == "table" then
				for _, v in ipairs(config.Default) do selected[v] = true end
			else
				selected[config.Default] = true
			end
		end

		local root = New("Frame", {
			Name = "Dropdown",
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
			Size = UDim2.new(1, 0, 0, config.Description and 52 or 44),
			Text = "",
			AutoButtonColor = false,
			Parent = root,
		})
		Utility.Padding(header, { left = 14, right = 14, top = 10, bottom = 10 })

		local title = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Title or "Dropdown",
			TextColor3 = Theme.Get("Text"),
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.new(0.5, 0, config.Description and 0.55 or 1, 0),
			Parent = header,
		})
		Theme.Apply(title, { TextColor3 = "Text" })

		if config.Description then
			local desc = New("TextLabel", {
				BackgroundTransparency = 1,
				Text = config.Description,
				TextColor3 = Theme.Get("SubText"),
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromScale(0, 0.55),
				Size = UDim2.new(0.5, 0, 0.45, 0),
				Parent = header,
			})
			Theme.Apply(desc, { TextColor3 = "SubText" })
		end

		local valueLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = placeholder,
			TextColor3 = Theme.Get("SubText"),
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -22, 0.5, 0),
			Size = UDim2.new(0.6, -22, 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		Theme.Apply(valueLabel, { TextColor3 = "SubText" })

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

		-- Options container
		local holder = New("Frame", {
			Name = "Options",
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

		local list = New("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 6),
			Size = UDim2.new(1, 0, 1, -12),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Get("StrokeLight"),
			Parent = holder,
		})
		Utility.Padding(list, { left = 8, right = 8 })
		Utility.List(list, 2)

		local open = false
		local optionButtons = {}

		local api = {}

		local function displayText()
			local picked = {}
			for _, v in ipairs(values) do
				if selected[v] then table.insert(picked, tostring(v)) end
			end
			if #picked == 0 then return placeholder, "SubText" end
			if multi then
				if #picked > 2 then
					return #picked .. " selected", "Text"
				end
			end
			return table.concat(picked, ", "), "Text"
		end

		local function refresh()
			local text, colorKey = displayText()
			valueLabel.Text = text
			valueLabel.TextColor3 = Theme.Get(colorKey)
			for value, record in pairs(optionButtons) do
				local isSel = selected[value] == true
				Utility.Tween(record.button, { BackgroundTransparency = isSel and 0 or 1 }, 0.12)
				Utility.Tween(record.label, { TextColor3 = isSel and Theme.Get("Text") or Theme.Get("SubText") }, 0.12)
				record.check.Visible = isSel
			end
		end

		local function fireCallback()
			if not config.Callback then return end
			if multi then
				local out = {}
				for _, v in ipairs(values) do
					if selected[v] then table.insert(out, v) end
				end
				task.spawn(config.Callback, out)
			else
				for _, v in ipairs(values) do
					if selected[v] then
						task.spawn(config.Callback, v)
						return
					end
				end
				task.spawn(config.Callback, nil)
			end
		end

		local function buildOptions()
			for _, child in ipairs(list:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			optionButtons = {}

			for i, value in ipairs(values) do
				local btn = New("TextButton", {
					BackgroundColor3 = Theme.Get("ElementHover"),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, ROW_HEIGHT - 2),
					Text = "",
					AutoButtonColor = false,
					LayoutOrder = i,
					Parent = list,
				})
				Theme.Apply(btn, { BackgroundColor3 = "ElementHover" })
				Utility.Corner(7, btn)
				Utility.Padding(btn, { left = 10, right = 10 })

				local lbl = New("TextLabel", {
					Name = "Label",
					BackgroundTransparency = 1,
					Text = tostring(value),
					TextColor3 = Theme.Get("SubText"),
					TextSize = 13,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -20, 1, 0),
					Parent = btn,
				})

				local check = New("ImageLabel", {
					Name = "Check",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.fromScale(1, 0.5),
					Size = UDim2.fromOffset(15, 15),
					ImageColor3 = Theme.Get("Accent"),
					Visible = false,
					Parent = btn,
				})
				Theme.Apply(check, { ImageColor3 = "Accent" })
				local chk = Icons.Resolve("check")
				check.Image = chk.Image
				check.ImageRectOffset = chk.ImageRectOffset
				check.ImageRectSize = chk.ImageRectSize

				optionButtons[value] = { button = btn, label = lbl, check = check }

				Utility.Hover(btn, function()
					if not selected[value] then
						Utility.Tween(btn, { BackgroundTransparency = 0.6 }, 0.12)
					end
				end, function()
					if not selected[value] then
						Utility.Tween(btn, { BackgroundTransparency = 1 }, 0.12)
					end
				end)

				btn.MouseButton1Click:Connect(function()
					if multi then
						selected[value] = not selected[value] or nil
					else
						table.clear(selected)
						selected[value] = true
						api.Close()
					end
					refresh()
					fireCallback()
				end)
			end
		end

		local function openHeight()
			local content = math.min(#values, MAX_VISIBLE) * ROW_HEIGHT
			return content + 12 + 1
		end

		function api.Open()
			open = true
			Utility.Tween(holder, { Size = UDim2.new(1, 0, 0, openHeight()) }, 0.22, Enum.EasingStyle.Quint)
			Utility.Tween(chevron, { Rotation = 180 }, 0.22)
			Utility.Tween(stroke, { Color = Theme.Get("StrokeLight") }, 0.2)
		end

		function api.Close()
			open = false
			Utility.Tween(holder, { Size = UDim2.new(1, 0, 0, 0) }, 0.22, Enum.EasingStyle.Quint)
			Utility.Tween(chevron, { Rotation = 0 }, 0.22)
			Utility.Tween(stroke, { Color = Theme.Get("Stroke") }, 0.2)
		end

		function api.Toggle()
			if open then api.Close() else api.Open() end
		end

		function api.Set(value, silent)
			table.clear(selected)
			if type(value) == "table" then
				for _, v in ipairs(value) do selected[v] = true end
			elseif value ~= nil then
				selected[value] = true
			end
			refresh()
			if not silent then fireCallback() end
		end

		function api.Get()
			if multi then
				local out = {}
				for _, v in ipairs(values) do
					if selected[v] then table.insert(out, v) end
				end
				return out
			else
				for _, v in ipairs(values) do
					if selected[v] then return v end
				end
				return nil
			end
		end

		function api.SetValues(newValues)
			values = newValues or {}
			buildOptions()
			refresh()
		end

		header.MouseButton1Click:Connect(api.Toggle)

		buildOptions()
		refresh()

		if config.Flag and ctx.Config then
			ctx.Config:Register(config.Flag, { Get = api.Get, Set = function(v) api.Set(v, true) end })
		end
		if config.Default and config.Callback then
			fireCallback()
		end

		api.Instance = root
		return api
	end
end
