--[[
	Components/Window
	The main window: draggable topbar, vertical tab sidebar, and content area.
]]

return function(import)
	local UserInputService = game:GetService("UserInputService")

	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Icons = import("Modules/Icons")
	local Tab = import("Components/Tab")

	local New = Utility.New

	local Window = {}
	Window.__index = Window

	function Window.new(ctx, config)
		config = config or {}
		local self = setmetatable({}, Window)

		self.ctx = ctx
		self.Tabs = {}
		self.ActiveTab = nil
		self.Visible = true
		self.Minimized = false

		local size = config.Size or UDim2.fromOffset(760, 500)
		self.Size = size

		-- Root
		local root = New("Frame", {
			Name = "Window",
			BackgroundColor3 = Theme.Get("Background"),
			Size = size,
			Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ClipsDescendants = true,
			Parent = ctx.Screen,
		})
		Theme.Apply(root, { BackgroundColor3 = "Background" })
		Utility.Corner(14, root)
		local rootStroke = Utility.Stroke(root, Theme.Get("Stroke"), 1)
		Theme.Apply(rootStroke, { Color = "Stroke" })
		self.Root = root

		-- Soft drop shadow
		New("ImageLabel", {
			Name = "Shadow",
			BackgroundTransparency = 1,
			Image = "rbxassetid://6014261993",
			ImageColor3 = Color3.new(0, 0, 0),
			ImageTransparency = 0.4,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 60, 1, 60),
			ZIndex = 0,
			Parent = root,
		})

		self:_buildSidebar(config)
		self:_buildContent(config)
		self:_buildTopbar(config)

		Utility.Drag(self.Topbar, root)

		-- Toggle keybind
		self.ToggleKey = config.Keybind or Enum.KeyCode.RightShift
		UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.KeyCode == self.ToggleKey then
				self:Toggle()
			end
		end)

		-- Entrance animation
		root.Size = UDim2.fromOffset(size.X.Offset, 0)
		root.BackgroundTransparency = 1
		Utility.Tween(root, { Size = size, BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Quint)

		return self
	end

	function Window:_buildTopbar(config)
		local topbar = New("Frame", {
			Name = "Topbar",
			BackgroundColor3 = Theme.Get("Topbar"),
			Size = UDim2.new(1, 0, 0, 52),
			Parent = self.Root,
		})
		Theme.Apply(topbar, { BackgroundColor3 = "Topbar" })
		self.Topbar = topbar

		-- Bottom hairline
		local line = New("Frame", {
			Name = "Divider",
			BackgroundColor3 = Theme.Get("Stroke"),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -1),
			Size = UDim2.new(1, 0, 0, 1),
			Parent = topbar,
		})
		Theme.Apply(line, { BackgroundColor3 = "Stroke" })

		local title = New("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			Text = config.Title or "Entnomic",
			TextColor3 = Theme.Get("Text"),
			TextSize = 15,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 244, 0, config.Subtitle and 10 or 0),
			Size = UDim2.new(0, 300, config.Subtitle and 0 or 1, config.Subtitle and 16 or 0),
			Parent = topbar,
		})
		Theme.Apply(title, { TextColor3 = "Text" })

		if config.Subtitle then
			local sub = New("TextLabel", {
				Name = "Subtitle",
				BackgroundTransparency = 1,
				Text = config.Subtitle,
				TextColor3 = Theme.Get("MutedText"),
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.new(0, 244, 0, 27),
				Size = UDim2.new(0, 300, 0, 14),
				Parent = topbar,
			})
			Theme.Apply(sub, { TextColor3 = "MutedText" })
		end

		-- Control buttons (close, minimize)
		local controls = New("Frame", {
			Name = "Controls",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.new(0, 64, 0, 28),
			Parent = topbar,
		})
		Utility.List(controls, 6, Enum.FillDirection.Horizontal)
		controls.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

		local function controlButton(icon, order, onClick, danger)
			local btn = New("TextButton", {
				Name = "Ctrl",
				BackgroundColor3 = Theme.Get("Element"),
				Size = UDim2.fromOffset(28, 28),
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = order,
				Parent = controls,
			})
			Theme.Apply(btn, { BackgroundColor3 = "Element" })
			Utility.Corner(8, btn)

			local img = New("ImageLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(15, 15),
				ImageColor3 = Theme.Get("SubText"),
				Parent = btn,
			})
			Theme.Apply(img, { ImageColor3 = "SubText" })
			local res = Icons.Resolve(icon)
			img.Image = res.Image
			img.ImageRectOffset = res.ImageRectOffset
			img.ImageRectSize = res.ImageRectSize

			Utility.Hover(btn, function()
				Utility.Tween(btn, {
					BackgroundColor3 = danger and Theme.Get("Danger") or Theme.Get("ElementHover"),
				}, 0.15)
				Utility.Tween(img, { ImageColor3 = danger and Color3.new(1, 1, 1) or Theme.Get("Text") }, 0.15)
			end, function()
				Utility.Tween(btn, { BackgroundColor3 = Theme.Get("Element") }, 0.15)
				Utility.Tween(img, { ImageColor3 = Theme.Get("SubText") }, 0.15)
			end)

			btn.MouseButton1Click:Connect(onClick)
			return btn
		end

		controlButton("minus", 1, function()
			self:SetMinimized(not self.Minimized)
		end)
		controlButton("x", 2, function()
			self:Close()
		end, true)
	end

	function Window:_buildSidebar(config)
		local sidebar = New("Frame", {
			Name = "Sidebar",
			BackgroundColor3 = Theme.Get("Sidebar"),
			Size = UDim2.new(0, 216, 1, 0),
			Parent = self.Root,
		})
		Theme.Apply(sidebar, { BackgroundColor3 = "Sidebar" })
		self.Sidebar = sidebar

		-- Right hairline
		local line = New("Frame", {
			BackgroundColor3 = Theme.Get("Stroke"),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -1, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Parent = sidebar,
		})
		Theme.Apply(line, { BackgroundColor3 = "Stroke" })

		-- Brand header
		local header = New("Frame", {
			Name = "Header",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -32, 0, 52),
			Parent = sidebar,
		})

		local logo = New("Frame", {
			Name = "Logo",
			BackgroundColor3 = Theme.Get("Accent"),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(30, 30),
			Parent = header,
		})
		Theme.Apply(logo, { BackgroundColor3 = "Accent" })
		Utility.Corner(9, logo)

		local logoIcon = New("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(17, 17),
			ImageColor3 = Color3.new(1, 1, 1),
			Parent = logo,
		})
		local lres = Icons.Resolve(config.Icon or "layers")
		logoIcon.Image = lres.Image
		logoIcon.ImageRectOffset = lres.ImageRectOffset
		logoIcon.ImageRectSize = lres.ImageRectSize

		local brand = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Title or "Entnomic",
			TextColor3 = Theme.Get("Text"),
			TextSize = 15,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(40, 0),
			Size = UDim2.new(1, -40, 1, 0),
			Parent = header,
		})
		Theme.Apply(brand, { TextColor3 = "Text" })

		-- Tab list (scrolling)
		local list = New("ScrollingFrame", {
			Name = "TabList",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(12, 60),
			Size = UDim2.new(1, -24, 1, -72),
			ScrollBarThickness = 0,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Parent = sidebar,
		})
		Utility.List(list, 4)
		self.TabList = list
	end

	function Window:_buildContent(config)
		local content = New("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(216, 52),
			Size = UDim2.new(1, -216, 1, -52),
			ClipsDescendants = true,
			Parent = self.Root,
		})
		self.Content = content
	end

	function Window:CreateTab(tabConfig)
		local tab = Tab.new(self, tabConfig or {})
		table.insert(self.Tabs, tab)

		-- Activate the first tab automatically.
		if not self.ActiveTab then
			self:SelectTab(tab)
		end
		return tab
	end

	function Window:SelectTab(tab)
		if self.ActiveTab == tab then return end

		for _, t in ipairs(self.Tabs) do
			local active = (t == tab)
			t:SetActive(active)
		end
		self.ActiveTab = tab
	end

	function Window:SetMinimized(state)
		self.Minimized = state
		if state then
			Utility.Tween(self.Root, { Size = UDim2.fromOffset(self.Size.X.Offset, 52) }, 0.3, Enum.EasingStyle.Quint)
		else
			Utility.Tween(self.Root, { Size = self.Size }, 0.3, Enum.EasingStyle.Quint)
		end
	end

	function Window:Toggle()
		self.Visible = not self.Visible
		if self.Visible then
			self.Root.Visible = true
			self.Root.BackgroundTransparency = 1
			Utility.Tween(self.Root, {
				Size = self.Minimized and UDim2.fromOffset(self.Size.X.Offset, 52) or self.Size,
				BackgroundTransparency = 0,
			}, 0.3, Enum.EasingStyle.Quint)
		else
			local t = Utility.Tween(self.Root, {
				Size = UDim2.fromOffset(self.Size.X.Offset, 0),
				BackgroundTransparency = 1,
			}, 0.25, Enum.EasingStyle.Quint)
			t.Completed:Once(function()
				if not self.Visible then
					self.Root.Visible = false
				end
			end)
		end
	end

	function Window:Close()
		local t = Utility.Tween(self.Root, {
			Size = UDim2.fromOffset(self.Size.X.Offset * 0.9, 0),
			BackgroundTransparency = 1,
		}, 0.3, Enum.EasingStyle.Quint)
		t.Completed:Once(function()
			self.ctx.Destroy()
		end)
	end

	return Window
end
