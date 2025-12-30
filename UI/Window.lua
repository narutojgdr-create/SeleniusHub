local Defaults = require(script.Parent.Parent.Assets.Defaults)
local IconPaths = require(script.Parent.Parent.Assets.Icons)
local Acrylic = require(script.Parent.Parent.Theme.Acrylic)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Window = {}

function Window.Create(ctx)
	local UI = {}
	local Theme = ctx.themeManager:GetTheme()

	local SIDEBAR_WIDTH = 220
	local SIDEBAR_MARGIN = 7
	local SIDEBAR_GAP = 6

	local guiName = ctx.instanceUtil.RandomString(12)
	UI.ScreenGui = ctx.instanceUtil.Create("ScreenGui", {
		Name = guiName,
		ResetOnSpawn = false,
		Parent = ctx.assets.GetSecureParent(),
		DisplayOrder = 10,
	})

	UI.MainFrame = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Background,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 720, 0, 600),
		ClipsDescendants = false,
		Parent = UI.ScreenGui,
		Visible = false,
	})

	local updateBlur, stroke = Acrylic.Enable(UI.MainFrame, Theme, ctx.instanceUtil)
	UI.BlurFunction = updateBlur
	UI.MainStroke = stroke

	ctx.instanceUtil.AddCorner(UI.MainFrame, 8)
	ctx.themeManager:Register(UI.MainFrame, "BackgroundColor3", "Background")

	UI.TitleBar = ctx.instanceUtil.Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 46),
		Parent = UI.MainFrame,
		ZIndex = 2,
	})

	UI.Logo = ctx.instanceUtil.Create("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 26, 0, 26),
		Position = UDim2.new(0, 8, 0, 10),
		Image = ctx.assets.GetIcon(IconPaths.Logo),
		ImageColor3 = Theme.TextPrimary,
		Parent = UI.TitleBar,
	})

	UI.TitleLabel = ctx.instanceUtil.Create("TextLabel", {
		Text = "SELENIUS HUB",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 40, 0, 0),
		Size = UDim2.new(0, 120, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = UI.TitleBar,
	})

	-- Version Badge (desativado)
	UI.VersionBadge = ctx.instanceUtil.Create("TextLabel", {
		Text = "",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 155, 0, 4),
		Size = UDim2.new(0, 30, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = false,
		Parent = UI.TitleBar,
	})

	local titleScale = Instance.new("UIScale")
	titleScale.Scale = 1
	titleScale.Parent = UI.TitleLabel

	UI.SearchBox = ctx.instanceUtil.Create("TextBox", {
		BackgroundColor3 = Theme.Button,
		Position = UDim2.new(0, 200, 0, 10),
		Size = UDim2.new(0, 160, 0, 26),
		PlaceholderText = ctx.localeManager:GetText("label_search"),
		Text = "",
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.TextPrimary,
		PlaceholderColor3 = Theme.AccentDark,
		ClearTextOnFocus = true,
		Parent = UI.TitleBar,
	})
	ctx.instanceUtil.AddCorner(UI.SearchBox, 6)
	ctx.instanceUtil.AddStroke(UI.SearchBox, Theme.Stroke, 1, 0.5)
	ctx.themeManager:Register(UI.SearchBox, "TextColor3", "TextPrimary")
	ctx.themeManager:Register(UI.SearchBox, "PlaceholderColor3", "AccentDark")

	ctx.themeManager:AddCallback(function()
		local T = ctx.themeManager:GetTheme()
		UI.SearchBox.BackgroundColor3 = T.Button
	end)

	UI.MinimizeBtn = ctx.instanceUtil.Create("TextButton", {
		Text = "-",
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = Theme.TextPrimary,
		BackgroundColor3 = Theme.Button,
		Size = UDim2.new(0, 29, 0, 29),
		Position = UDim2.new(1, -75, 0, 8),
		Parent = UI.TitleBar,
		AutoButtonColor = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	ctx.instanceUtil.AddCorner(UI.MinimizeBtn, 6)
	ctx.themeManager:Register(UI.MinimizeBtn, "TextColor3", "TextPrimary")
	ctx.themeManager:Register(UI.MinimizeBtn, "BackgroundColor3", "Button")

	UI.CloseBtn = ctx.instanceUtil.Create("TextButton", {
		Text = "X",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		BackgroundColor3 = Theme.Button,
		Size = UDim2.new(0, 29, 0, 29),
		Position = UDim2.new(1, -40, 0, 8),
		Parent = UI.TitleBar,
		AutoButtonColor = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	ctx.instanceUtil.AddCorner(UI.CloseBtn, 6)
	ctx.themeManager:Register(UI.CloseBtn, "TextColor3", "TextPrimary")
	ctx.themeManager:Register(UI.CloseBtn, "BackgroundColor3", "Button")

	ctx.themeManager:AddCallback(function()
		local T = ctx.themeManager:GetTheme()
		UI.MinimizeBtn.BackgroundColor3 = T.Button
		UI.CloseBtn.BackgroundColor3 = T.Button
	end)

	UI.ContentContainer = ctx.instanceUtil.Create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(1, 0, 1, -46),
		Parent = UI.MainFrame,
		ZIndex = 2,
	})

	UI.Sidebar = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, SIDEBAR_MARGIN, 0, SIDEBAR_MARGIN),
		Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -(SIDEBAR_MARGIN * 2)),
		Parent = UI.ContentContainer,
	})
	ctx.instanceUtil.AddCorner(UI.Sidebar, 6)
	ctx.instanceUtil.AddStroke(UI.Sidebar, Theme.Stroke, 1, 0.5)
	ctx.themeManager:Register(UI.Sidebar, "BackgroundColor3", "Secondary")

	UI.SidebarTop = ctx.instanceUtil.Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -78),
		Parent = UI.Sidebar,
	})

	UI.SidebarLayout = ctx.instanceUtil.Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = UI.SidebarTop,
	})
	ctx.instanceUtil.Create("UIPadding", { PaddingTop = UDim.new(0, 10), Parent = UI.SidebarTop })

	UI.SidebarBottom = ctx.instanceUtil.Create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 78),
		Parent = UI.Sidebar,
	})
	ctx.instanceUtil.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 6),
		Parent = UI.SidebarBottom,
	})

	UI.UserCard = ctx.instanceUtil.Create("Frame", {
		Name = "UserCard",
		BackgroundColor3 = Theme.Button,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(1, 0, 0, 62),
		Position = UDim2.new(0, 0, 1, -62),
		Parent = UI.SidebarBottom,
	})
	ctx.instanceUtil.AddCorner(UI.UserCard, 8)
	ctx.instanceUtil.AddStroke(UI.UserCard, Theme.Stroke, 1, 0.6)
	ctx.themeManager:Register(UI.UserCard, "BackgroundColor3", "Button")

	local avatar = ctx.instanceUtil.Create("ImageLabel", {
		Name = "Avatar",
		BackgroundColor3 = Theme.Secondary,
		BackgroundTransparency = 0,
		Size = UDim2.new(0, 38, 0, 38),
		Position = UDim2.new(0, 10, 0.5, -19),
		ImageColor3 = Theme.TextPrimary,
		Parent = UI.UserCard,
	})
	ctx.instanceUtil.AddCorner(avatar, 10)
	ctx.themeManager:Register(avatar, "BackgroundColor3", "Secondary")

	local name = ctx.instanceUtil.Create("TextLabel", {
		Name = "DisplayName",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 12),
		Size = UDim2.new(1, -66, 0, 16),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "Usuário",
		Parent = UI.UserCard,
	})
	ctx.themeManager:Register(name, "TextColor3", "TextPrimary")

	local user = ctx.instanceUtil.Create("TextLabel", {
		Name = "Username",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 30),
		Size = UDim2.new(1, -66, 0, 14),
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.AccentDark,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "@player",
		Parent = UI.UserCard,
	})
	ctx.themeManager:Register(user, "TextColor3", "AccentDark")

	task.spawn(function()
		local function limitChars(s, maxChars)
			s = tostring(s or "")
			maxChars = tonumber(maxChars) or 18
			if #s <= maxChars then
				return s
			end
			if maxChars <= 3 then
				return string.sub(s, 1, maxChars)
			end
			return string.sub(s, 1, maxChars - 3) .. "..."
		end

		local player = Players.LocalPlayer
		if not player then
			return
		end
		pcall(function()
			name.Text = limitChars(player.DisplayName or player.Name or "Usuário", 18)
			user.Text = "@" .. limitChars(player.Name or "player", 18)
		end)

		pcall(function()
			local content = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			if type(content) == "string" then
				avatar.Image = content
			end
		end)
	end)

	UI.PagesContainer = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, SIDEBAR_MARGIN + SIDEBAR_WIDTH + SIDEBAR_GAP, 0, SIDEBAR_MARGIN),
		Size = UDim2.new(1, -(SIDEBAR_MARGIN + SIDEBAR_WIDTH + SIDEBAR_GAP + SIDEBAR_MARGIN), 1, -(SIDEBAR_MARGIN * 2)),
		ClipsDescendants = true,
		Parent = UI.ContentContainer,
	})
	ctx.instanceUtil.AddCorner(UI.PagesContainer, 6)
	ctx.instanceUtil.AddStroke(UI.PagesContainer, Theme.Stroke, 1, 0.5)
	ctx.themeManager:Register(UI.PagesContainer, "BackgroundColor3", "Secondary")

	UI.ResizeHandle = ctx.instanceUtil.Create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -6, 1, -6),
		Size = UDim2.new(0, 18, 0, 18),
		ZIndex = 10,
		Parent = UI.MainFrame,
	})
	UI.ResizeDots = {}
	local dots = {
		{ offX = -3, offY = -3 },
		{ offX = -7, offY = -3 },
		{ offX = -11, offY = -3 },
		{ offX = -3, offY = -7 },
		{ offX = -7, offY = -7 },
		{ offX = -3, offY = -11 },
	}
	for _, d in ipairs(dots) do
		local dot = ctx.instanceUtil.Create("Frame", {
			BackgroundColor3 = Theme.Separator,
			Size = UDim2.new(0, 3, 0, 3),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, d.offX, 1, d.offY),
			ZIndex = 11,
			Parent = UI.ResizeHandle,
		})
		table.insert(UI.ResizeDots, dot)
		ctx.themeManager:Register(dot, "BackgroundColor3", "Separator")
	end

	return UI
end

return Window
