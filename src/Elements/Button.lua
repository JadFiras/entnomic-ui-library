--[[ Elements/Button ]]

return function(import)
	local Utility = import("Modules/Utility")
	local Theme = import("Modules/Theme")
	local Icons = import("Modules/Icons")
	local Element = import("Modules/Element")

	local New = Utility.New

	return function(ctx, config)
		local base = Element.Row(ctx.Container, {
			Name = "Button",
			Title = config.Title or "Button",
			Description = config.Description,
			hover = true,
		})

		local chevron = New("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromOffset(16, 16),
			ImageColor3 = Theme.Get("MutedText"),
			Parent = base.Right,
		})
		Theme.Apply(chevron, { ImageColor3 = "MutedText" })
		local res = Icons.Resolve(config.Icon or "chevron-right")
		chevron.Image = res.Image
		chevron.ImageRectOffset = res.ImageRectOffset
		chevron.ImageRectSize = res.ImageRectSize

		local click = New("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 3,
			Parent = base.Root,
		})

		click.MouseButton1Click:Connect(function()
			base.Root.BackgroundColor3 = Theme.Get("ElementHold")
			Utility.Tween(base.Root, { BackgroundColor3 = Theme.Get("ElementHover") }, 0.25)
			Utility.Tween(chevron, { Position = UDim2.new(1, 3, 0.5, 0) }, 0.1).Completed:Once(function()
				Utility.Tween(chevron, { Position = UDim2.fromScale(1, 0.5) }, 0.1)
			end)
			if config.Callback then
				task.spawn(config.Callback)
			end
		end)

		return {
			Instance = base.Root,
			SetTitle = function(text)
				base.Title.Text = text
			end,
		}
	end
end
