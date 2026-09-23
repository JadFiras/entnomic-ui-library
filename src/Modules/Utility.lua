--[[
	Modules/Utility
	Instance creation, tweening, layout helpers, and dragging.
]]

return function(import)
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")

	local Utility = {}

	-- Create an instance with properties + children. Parent is set last for perf.
	function Utility.New(class, props, children)
		local inst = Instance.new(class)

		if props then
			for prop, value in pairs(props) do
				if prop ~= "Parent" then
					inst[prop] = value
				end
			end
		end

		if children then
			for _, child in ipairs(children) do
				child.Parent = inst
			end
		end

		if props and props.Parent then
			inst.Parent = props.Parent
		end

		return inst
	end

	local New = Utility.New

	-- Rounded corners
	function Utility.Corner(radius, parent)
		return New("UICorner", {
			CornerRadius = UDim.new(0, radius or 8),
			Parent = parent,
		})
	end

	-- Border stroke
	function Utility.Stroke(parent, color, thickness, transparency)
		return New("UIStroke", {
			Color = color or Color3.fromRGB(255, 255, 255),
			Thickness = thickness or 1,
			Transparency = transparency or 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = parent,
		})
	end

	-- Padding (single value or {top,bottom,left,right})
	function Utility.Padding(parent, padding)
		if type(padding) == "number" then
			padding = { top = padding, bottom = padding, left = padding, right = padding }
		end
		return New("UIPadding", {
			PaddingTop = UDim.new(0, padding.top or 0),
			PaddingBottom = UDim.new(0, padding.bottom or 0),
			PaddingLeft = UDim.new(0, padding.left or 0),
			PaddingRight = UDim.new(0, padding.right or 0),
			Parent = parent,
		})
	end

	-- Vertical / horizontal list layout
	function Utility.List(parent, spacing, direction, align)
		return New("UIListLayout", {
			Padding = UDim.new(0, spacing or 0),
			FillDirection = direction or Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Parent = parent,
		})
	end

	-- Gradient helper
	function Utility.Gradient(parent, colors, rotation, transparency)
		return New("UIGradient", {
			Color = colors,
			Rotation = rotation or 0,
			Transparency = transparency or NumberSequence.new(0),
			Parent = parent,
		})
	end

	-- Tween any instance, returns the Tween object
	function Utility.Tween(inst, props, duration, style, direction)
		local info = TweenInfo.new(
			duration or 0.18,
			style or Enum.EasingStyle.Quart,
			direction or Enum.EasingDirection.Out
		)
		local tween = TweenService:Create(inst, info, props)
		tween:Play()
		return tween
	end

	-- Make `target` draggable using `handle` as the grab area.
	function Utility.Drag(handle, target)
		local dragging = false
		local dragStart, startPos

		local function update(input)
			local delta = input.Position - dragStart
			local goal = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
			Utility.Tween(target, { Position = goal }, 0.08)
		end

		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = target.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging
				and (input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)
	end

	-- Hover state helper: runs enter/leave callbacks on a GuiObject
	function Utility.Hover(inst, onEnter, onLeave)
		inst.MouseEnter:Connect(onEnter)
		inst.MouseLeave:Connect(onLeave)
	end

	-- HSV <-> Color3 convenience (used by the colorpicker)
	function Utility.FromHSV(h, s, v)
		return Color3.fromHSV(h, s, v)
	end

	-- Wait for the next render step (used to measure absolute sizes)
	function Utility.Step()
		RunService.RenderStepped:Wait()
	end

	return Utility
end
