--[[
	Components/Tab
	A vertical sidebar entry paired with a scrolling content page.
	Exposes the element factory methods (CreateButton, CreateToggle, ...).
]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Icons = import("Modules/Icons")

	local New = Utility.New

	-- Element constructors
	local Elements = {
		Button      = import("Elements/Button"),
		Toggle      = import("Elements/Toggle"),
		Slider      = import("Elements/Slider"),
		Dropdown    = import("Elements/Dropdown"),
		Input       = import("Elements/Input"),
		Keybind     = import("Elements/Keybind"),
		Colorpicker = import("Elements/Colorpicker"),
		Paragraph   = import("Elements/Paragraph"),
		Section     = import("Elements/Section"),
		Divider     = import("Elements/Divider"),
		Label       = import("Elements/Label"),
	}

	local Tab = {}
	Tab.__index = Tab

	function Tab.new(window, config)
		local self = setmetatable({}, Tab)
		self.Window = window
		self.Elements = {}

		-- Sidebar button
		local button = New("TextButton", {
			Name = "TabButton",
			BackgroundColor3 = Theme.Get("Element"),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 38),
			Text = "",
			AutoButtonColor = false,
			Parent = window.TabList,
		})
		Utility.Corner(9, button)
		self.Button = button

		-- Active indicator bar
		local indicator = New("Frame", {
			Name = "Indicator",
			BackgroundColor3 = Theme.Get("Accent"),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 3, 0, 0),
			Parent = button,
		})
		Theme.Apply(indicator, { BackgroundColor3 = "Accent" })
		Utility.Corner(2, indicator)
		self.Indicator = indicator

		local icon = New("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			Size = UDim2.fromOffset(17, 17),
			ImageColor3 = Theme.Get("SubText"),
			Parent = button,
		})
		Theme.Apply(icon, { ImageColor3 = "SubText" })
		if config.Icon then
			local res = Icons.Resolve(config.Icon)
			icon.Image = res.Image
			icon.ImageRectOffset = res.ImageRectOffset
			icon.ImageRectSize = res.ImageRectSize
		else
			icon.Visible = false
		end
		self.Icon = icon

		local label = New("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Text = config.Title or "Tab",
			TextColor3 = Theme.Get("SubText"),
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, config.Icon and 40 or 14, 0, 0),
			Size = UDim2.new(1, config.Icon and -48 or -22, 1, 0),
			Parent = button,
		})
		Theme.Apply(label, { TextColor3 = "SubText" })
		self.Label = label

		-- Content page
		local page = New("ScrollingFrame", {
			Name = "Page",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Get("StrokeLight"),
			ScrollBarImageTransparency = 0.3,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Visible = false,
			Parent = window.Content,
		})
		Theme.Apply(page, { ScrollBarImageColor3 = "StrokeLight" })
		Utility.Padding(page, { top = 18, bottom = 18, left = 18, right = 18 })
		Utility.List(page, 10)
		self.Page = page

		-- Hover feedback (only when inactive)
		self.Active = false
		Utility.Hover(button, function()
			if not self.Active then
				button.BackgroundColor3 = Theme.Get("ElementHover")
				Utility.Tween(button, { BackgroundTransparency = 0.4 }, 0.15)
				Utility.Tween(label, { TextColor3 = Theme.Get("Text") }, 0.15)
				Utility.Tween(icon, { ImageColor3 = Theme.Get("Text") }, 0.15)
			end
		end, function()
			if not self.Active then
				Utility.Tween(button, { BackgroundTransparency = 1 }, 0.15)
				Utility.Tween(label, { TextColor3 = Theme.Get("SubText") }, 0.15)
				Utility.Tween(icon, { ImageColor3 = Theme.Get("SubText") }, 0.15)
			end
		end)

		button.MouseButton1Click:Connect(function()
			window:SelectTab(self)
		end)

		return self
	end

	function Tab:SetActive(active)
		self.Active = active
		self.Page.Visible = active

		if active then
			self.Button.BackgroundColor3 = Theme.Get("ElementHover")
			Utility.Tween(self.Button, { BackgroundTransparency = 0 }, 0.18)
			Utility.Tween(self.Indicator, { Size = UDim2.new(0, 3, 0, 18) }, 0.2)
			Utility.Tween(self.Label, { TextColor3 = Theme.Get("Text") }, 0.18)
			Utility.Tween(self.Icon, { ImageColor3 = Theme.Get("Accent") }, 0.18)
		else
			Utility.Tween(self.Button, { BackgroundTransparency = 1 }, 0.18)
			Utility.Tween(self.Indicator, { Size = UDim2.new(0, 3, 0, 0) }, 0.2)
			Utility.Tween(self.Label, { TextColor3 = Theme.Get("SubText") }, 0.18)
			Utility.Tween(self.Icon, { ImageColor3 = Theme.Get("SubText") }, 0.18)
		end
	end

	-- Shared context handed to every element constructor.
	function Tab:_ctx()
		return {
			Tab = self,
			Window = self.Window,
			Container = self.Page,
			Config = self.Window.ctx.Config,
			Notify = self.Window.ctx.Notify,
		}
	end

	local function register(self, element)
		table.insert(self.Elements, element)
		return element
	end

	function Tab:CreateSection(config)
		if type(config) == "string" then config = { Title = config } end
		return register(self, Elements.Section(self:_ctx(), config or {}))
	end

	function Tab:CreateButton(config)
		return register(self, Elements.Button(self:_ctx(), config or {}))
	end

	function Tab:CreateToggle(config)
		return register(self, Elements.Toggle(self:_ctx(), config or {}))
	end

	function Tab:CreateSlider(config)
		return register(self, Elements.Slider(self:_ctx(), config or {}))
	end

	function Tab:CreateDropdown(config)
		return register(self, Elements.Dropdown(self:_ctx(), config or {}))
	end

	function Tab:CreateInput(config)
		return register(self, Elements.Input(self:_ctx(), config or {}))
	end

	function Tab:CreateKeybind(config)
		return register(self, Elements.Keybind(self:_ctx(), config or {}))
	end

	function Tab:CreateColorpicker(config)
		return register(self, Elements.Colorpicker(self:_ctx(), config or {}))
	end

	function Tab:CreateParagraph(config)
		return register(self, Elements.Paragraph(self:_ctx(), config or {}))
	end

	function Tab:CreateDivider()
		return register(self, Elements.Divider(self:_ctx(), {}))
	end

	function Tab:CreateLabel(config)
		if type(config) == "string" then config = { Text = config } end
		return register(self, Elements.Label(self:_ctx(), config or {}))
	end

	return Tab
end
