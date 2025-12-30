local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Assets = require(script.Parent.Parent.Utils.Assets)
local InstanceUtil = require(script.Parent.Parent.Utils.Instance)
local Acrylic = require(script.Parent.Parent.Theme.Acrylic)

local Lifecycle = {}

local DISCORD_INVITE_URL = "https://discord.gg/selenius"

local SAVED_KEY_PATH = "SeleniusHub/key.txt"

local function ensureWorkspaceCache()
	local folder = Workspace:FindFirstChild("SeleniusHub")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "SeleniusHub"
		folder.Parent = Workspace
	end

	local keyValue = folder:FindFirstChild("SavedKey")
	if not keyValue then
		keyValue = Instance.new("StringValue")
		keyValue.Name = "SavedKey"
		keyValue.Value = ""
		keyValue.Parent = folder
	end

	local status = folder:FindFirstChild("Status")
	if not status then
		status = Instance.new("StringValue")
		status.Name = "Status"
		status.Value = "Loaded"
		status.Parent = folder
	else
		status.Value = "Loaded"
	end

	return folder, keyValue
end

local function getSavedKey()
	if type(Assets.SafeIsFile) == "function" and Assets.SafeIsFile(SAVED_KEY_PATH) then
		local k = Assets.SafeReadFile(SAVED_KEY_PATH)
		if type(k) == "string" then
			k = k:gsub("%s+$", "")
			if k ~= "" then
				return k
			end
		end
	end
	return nil
end

local function saveKey(value)
	if type(value) ~= "string" or value == "" then
		return
	end
	pcall(function()
		Assets.SafeWriteFile(SAVED_KEY_PATH, value)
	end)
end

local function hubNotify(hub, text, instant)
	pcall(function()
		if hub and type(hub.ShowWarning) == "function" then
			-- "info" usa o Accent do tema (normalmente azul)
			hub:ShowWarning(text, "info", instant)
		end
	end)
end

local function destroyGuiSafe(gui)
	pcall(function()
		if gui and gui.Parent then
			gui:Destroy()
		end
	end)
end

local function destroyExistingByName(parent, name)
	pcall(function()
		if parent and name then
			local existing = parent:FindFirstChild(name)
			if existing and existing:IsA("ScreenGui") then
				existing:Destroy()
			end
		end
	end)
end

-- Loading removido: mantemos apenas uma função compatível (não cria UI).
function Lifecycle.CreateLoadingScreen(hub)
	pcall(function()
		if hub and type(hub.FinishInit) == "function" then
			hub:FinishInit()
		end
	end)
	pcall(function()
		if hub and type(hub.SetVisible) == "function" then
			hub:SetVisible(true, true)
		end
	end)
end

function Lifecycle.CreateKeySystem(hub)
	local Theme = hub.ThemeManager:GetTheme()
	local correctKey = "testing123"
	local secureParent = Assets.GetSecureParent()
	local hoverTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local fadeTweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local cacheFolder, cacheKeyValue = ensureWorkspaceCache()

	-- A notificação "antes de tudo" é responsabilidade do loadstring.lua (bootstrap).
	-- Aqui só mostramos se não houver bootstrap (ex.: uso local sem o loader).
	pcall(function()
		local gv = (type(getgenv) == "function" and getgenv()) or _G
		if not rawget(gv, "SELENIUS_BOOT_NOTIFIED") then
			hubNotify(hub, "Inicializando Selenius...", true)
		end
	end)

	-- Key UI deve SEMPRE aparecer.
	-- Se existir key salva, apenas pré-preenche o campo para facilitar.
	local savedKey = getSavedKey()
	pcall(function()
		if cacheKeyValue and type(savedKey) == "string" then
			cacheKeyValue.Value = savedKey
		end
	end)

	-- Evita KeySystem duplicado
	if hub and hub.__SeleniusKeyGui then
		destroyGuiSafe(hub.__SeleniusKeyGui)
		hub.__SeleniusKeyGui = nil
	end
	destroyExistingByName(secureParent, "SeleniusHub_KeySystem")

	local gui = Instance.new("ScreenGui")
	gui.Name = "SeleniusHub_KeySystem"
	gui.ResetOnSpawn = false
	gui.Parent = secureParent
	gui.DisplayOrder = 100
	if hub then
		hub.__SeleniusKeyGui = gui
	end

	local main = Instance.new("Frame")
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = UDim2.new(0, 760, 0, 360)
	main.BackgroundColor3 = Theme.Background
	main.BorderSizePixel = 0
	main.ClipsDescendants = false
	main.Parent = gui

	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 0
	mainScale.Parent = main

	InstanceUtil.AddCorner(main, 12)
	Acrylic.Enable(main, Theme, InstanceUtil)

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = main
	content.Visible = true

	local left = Instance.new("Frame")
	left.BackgroundTransparency = 1
	left.Position = UDim2.new(0, 0, 0, 0)
	left.Size = UDim2.new(0, 400, 1, 0)
	left.Parent = content

	local leftPad = Instance.new("UIPadding")
	leftPad.PaddingLeft = UDim.new(0, 24)
	leftPad.PaddingRight = UDim.new(0, 24)
	leftPad.PaddingTop = UDim.new(0, 24)
	leftPad.PaddingBottom = UDim.new(0, 24)
	leftPad.Parent = left

	local leftLayout = Instance.new("UIListLayout")
	leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
	leftLayout.Padding = UDim.new(0, 10)
	leftLayout.Parent = left

	local separator = Instance.new("Frame")
	separator.BackgroundColor3 = Theme.Stroke
	separator.BackgroundTransparency = 0.45
	separator.BorderSizePixel = 0
	separator.Position = UDim2.new(0, 400, 0, 16)
	separator.Size = UDim2.new(0, 1, 1, -32)
	separator.Parent = content

	local right = Instance.new("Frame")
	right.BackgroundTransparency = 1
	right.Position = UDim2.new(0, 401, 0, 0)
	right.Size = UDim2.new(1, -401, 1, 0)
	right.Parent = content

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 26)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextColor3 = Theme.Accent
	title.Text = "SELENIUS KEY"
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.LayoutOrder = 1
	title.Parent = left

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Size = UDim2.new(1, 0, 0, 18)
	sub.Font = Enum.Font.GothamMedium
	sub.TextSize = 13
	sub.TextColor3 = Theme.AccentDark
	sub.Text = "Authentication Required"
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.LayoutOrder = 2
	sub.Parent = left

	local inputBg = Instance.new("Frame")
	inputBg.BackgroundColor3 = Theme.Secondary
	inputBg.Size = UDim2.new(1, 0, 0, 48)
	inputBg.LayoutOrder = 3
	inputBg.Parent = left
	InstanceUtil.AddCorner(inputBg, 8)
	InstanceUtil.AddStroke(inputBg, Theme.Stroke, 1, 0.55)

	local showKey = false
	local function maskKey(s)
		s = tostring(s or "")
		if showKey then
			return s
		end
		if #s == 0 then
			return ""
		end
		return string.rep("●", #s)
	end

	local showBtn = Instance.new("TextButton")
	showBtn.BackgroundColor3 = Theme.Button
	showBtn.Position = UDim2.new(1, -98, 0, 8)
	showBtn.Size = UDim2.new(0, 90, 0, 32)
	showBtn.Font = Enum.Font.GothamBold
	showBtn.TextSize = 12
	showBtn.TextColor3 = Theme.TextPrimary
	showBtn.Text = "MOSTRAR"
	showBtn.AutoButtonColor = false
	showBtn.Parent = inputBg
	InstanceUtil.AddCorner(showBtn, 8)

	local keyBox = Instance.new("TextBox")
	keyBox.BackgroundTransparency = 1
	keyBox.Position = UDim2.new(0, 10, 0, 0)
	keyBox.Size = UDim2.new(1, -122, 1, 0)
	keyBox.Font = Enum.Font.GothamMedium
	keyBox.TextSize = 16
	keyBox.TextColor3 = Theme.TextPrimary
	keyBox.PlaceholderText = "Insert Key Here..."
	keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
	keyBox.Text = (type(savedKey) == "string" and savedKey) or ""
	keyBox.ClearTextOnFocus = false
	keyBox.Parent = inputBg

	local maskLbl = Instance.new("TextLabel")
	maskLbl.BackgroundTransparency = 1
	maskLbl.Position = keyBox.Position
	maskLbl.Size = keyBox.Size
	maskLbl.Font = keyBox.Font
	maskLbl.TextSize = keyBox.TextSize
	maskLbl.TextColor3 = keyBox.TextColor3
	maskLbl.TextXAlignment = Enum.TextXAlignment.Left
	maskLbl.TextWrapped = false
	maskLbl.TextTruncate = Enum.TextTruncate.None
	maskLbl.Text = maskKey(keyBox.Text)
	maskLbl.Parent = inputBg
	maskLbl.Active = false
	maskLbl.Selectable = false
	maskLbl.ZIndex = (keyBox.ZIndex == 0 and 2) or (keyBox.ZIndex + 1)
	keyBox.ZIndex = (keyBox.ZIndex == 0 and 1) or keyBox.ZIndex

	local placeholderColorShown = keyBox.PlaceholderColor3

	local function refreshKeyMask()
		local current = tostring(keyBox.Text or "")
		if showKey then
			maskLbl.Visible = false
			keyBox.TextTransparency = 0
			keyBox.TextColor3 = Theme.TextPrimary
			keyBox.PlaceholderColor3 = placeholderColorShown
		else
			if current == "" then
				maskLbl.Visible = false
				keyBox.TextTransparency = 0
				keyBox.TextColor3 = Theme.TextPrimary
				keyBox.PlaceholderColor3 = placeholderColorShown
			else
				maskLbl.Text = string.rep("●", #current)
				maskLbl.Visible = true
				-- Some o texto real pra não interferir na edição/apagar.
				keyBox.TextTransparency = 1
				keyBox.TextColor3 = Theme.TextPrimary
				keyBox.PlaceholderColor3 = placeholderColorShown
			end
		end
		showBtn.Text = showKey and "OCULTAR" or "MOSTRAR"
	end

	keyBox:GetPropertyChangedSignal("Text"):Connect(refreshKeyMask)
	showBtn.MouseButton1Click:Connect(function()
		showKey = not showKey
		refreshKeyMask()
	end)
	refreshKeyMask()

	local btnContainer = Instance.new("Frame")
	btnContainer.BackgroundTransparency = 1
	btnContainer.Size = UDim2.new(1, 0, 0, 42)
	btnContainer.LayoutOrder = 4
	btnContainer.Parent = left

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
	btnLayout.Padding = UDim.new(0, 10)
	btnLayout.Parent = btnContainer

	local enterBtn = Instance.new("TextButton")
	enterBtn.BackgroundColor3 = Theme.Button
	enterBtn.Size = UDim2.new(0.5, -5, 1, 0)
	enterBtn.Font = Enum.Font.GothamBold
	enterBtn.TextSize = 15
	enterBtn.TextColor3 = Theme.Accent
	enterBtn.Text = "CHECK KEY"
	enterBtn.LayoutOrder = 1
	enterBtn.Parent = btnContainer
	InstanceUtil.AddCorner(enterBtn, 8)

	local getBtn = Instance.new("TextButton")
	getBtn.BackgroundColor3 = Theme.Button
	getBtn.Size = UDim2.new(0.5, -5, 1, 0)
	getBtn.Font = Enum.Font.GothamBold
	getBtn.TextSize = 15
	getBtn.TextColor3 = Theme.TextPrimary
	getBtn.Text = "GET KEY"
	getBtn.LayoutOrder = 2
	getBtn.Parent = btnContainer
	InstanceUtil.AddCorner(getBtn, 8)

	local discordRow = Instance.new("Frame")
	discordRow.BackgroundTransparency = 1
	discordRow.Size = UDim2.new(1, 0, 0, 44)
	discordRow.LayoutOrder = 5
	discordRow.Parent = left

	local discordLayout = Instance.new("UIListLayout")
	discordLayout.SortOrder = Enum.SortOrder.LayoutOrder
	discordLayout.Padding = UDim.new(0, 2)
	discordLayout.Parent = discordRow

	local discordLabel = Instance.new("TextLabel")
	discordLabel.BackgroundTransparency = 1
	discordLabel.Size = UDim2.new(1, 0, 0, 16)
	discordLabel.Font = Enum.Font.GothamMedium
	discordLabel.TextSize = 12
	discordLabel.TextColor3 = Theme.AccentDark
	discordLabel.TextTransparency = 0
	discordLabel.TextWrapped = false
	discordLabel.TextXAlignment = Enum.TextXAlignment.Left
	discordLabel.Text = "Problemas com a key?"
	discordLabel.LayoutOrder = 1
	discordLabel.Parent = discordRow

	local discordBtn = Instance.new("TextButton")
	discordBtn.BackgroundTransparency = 1
	discordBtn.AutoButtonColor = false
	discordBtn.Size = UDim2.new(1, 0, 0, 18)
	discordBtn.Font = Enum.Font.GothamBold
	discordBtn.TextSize = 12
	discordBtn.TextColor3 = Theme.Accent
	discordBtn.TextXAlignment = Enum.TextXAlignment.Left
	discordBtn.Text = "Entre no nosso servidor do Discord"
	discordBtn.LayoutOrder = 2
	discordBtn.Parent = discordRow

	local statusText = Instance.new("TextLabel")
	statusText.BackgroundTransparency = 1
	statusText.Size = UDim2.new(1, 0, 0, 20)
	statusText.Font = Enum.Font.GothamMedium
	statusText.TextSize = 13
	statusText.TextColor3 = Theme.Error
	statusText.TextTransparency = 1
	statusText.Text = ""
	statusText.TextXAlignment = Enum.TextXAlignment.Left
	statusText.LayoutOrder = 6
	statusText.Parent = left

	local function notifyLinkCopied()
		local notified = false
		pcall(function()
			if hub and type(hub.ShowWarning) == "function" then
				hub:ShowWarning("Link copiado", "info")
				notified = true
			end
		end)
		if not notified then
			statusText.TextColor3 = Theme.Accent
			statusText.Text = "Link copiado"
			TweenService:Create(statusText, fadeTweenInfo, { TextTransparency = 0 }):Play()
			task.delay(2, function()
				pcall(function()
					TweenService:Create(statusText, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
				end)
			end)
		end
	end

	discordBtn.MouseButton1Click:Connect(function()
		if typeof(setclipboard) == "function" then
			setclipboard(DISCORD_INVITE_URL)
		end
		notifyLinkCopied()
	end)

	local helpCard = Instance.new("Frame")
	helpCard.BackgroundColor3 = Theme.Secondary
	helpCard.BackgroundTransparency = 0.12
	helpCard.BorderSizePixel = 0
	helpCard.Position = UDim2.new(0, 18, 0, 18)
	helpCard.Size = UDim2.new(1, -36, 1, -36)
	helpCard.Parent = right
	InstanceUtil.AddCorner(helpCard, 10)
	InstanceUtil.AddStroke(helpCard, Theme.Stroke, 1, 0.6)

	local helpPad = Instance.new("UIPadding")
	helpPad.PaddingLeft = UDim.new(0, 16)
	helpPad.PaddingRight = UDim.new(0, 16)
	helpPad.PaddingTop = UDim.new(0, 16)
	helpPad.PaddingBottom = UDim.new(0, 16)
	helpPad.Parent = helpCard

	local helpLayout = Instance.new("UIListLayout")
	helpLayout.SortOrder = Enum.SortOrder.LayoutOrder
	helpLayout.Padding = UDim.new(0, 10)
	helpLayout.Parent = helpCard

	local helpTitle = Instance.new("TextLabel")
	helpTitle.BackgroundTransparency = 1
	helpTitle.Size = UDim2.new(1, 0, 0, 20)
	helpTitle.Font = Enum.Font.GothamBold
	helpTitle.TextSize = 15
	helpTitle.TextColor3 = Theme.TextPrimary
	helpTitle.TextXAlignment = Enum.TextXAlignment.Left
	helpTitle.Text = "Como pegar a key"
	helpTitle.LayoutOrder = 1
	helpTitle.Parent = helpCard

	local helpBody = Instance.new("TextLabel")
	helpBody.BackgroundTransparency = 1
	helpBody.Size = UDim2.new(1, 0, 1, -30)
	helpBody.Font = Enum.Font.GothamMedium
	helpBody.TextSize = 13
	helpBody.TextColor3 = Theme.AccentDark
	helpBody.TextXAlignment = Enum.TextXAlignment.Left
	helpBody.TextYAlignment = Enum.TextYAlignment.Top
	helpBody.TextWrapped = true
	helpBody.Text = "1) Clique em GET KEY\n2) Abra o link e complete o processo\n3) Copie a key gerada\n4) Cole aqui e clique CHECK KEY"
	helpBody.LayoutOrder = 2
	helpBody.Parent = helpCard

	-- Animação mais fluida (remake: base maior + leve zoom)
	InstanceUtil.Tween(mainScale, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1.1 })

	enterBtn.MouseEnter:Connect(function()
		TweenService:Create(enterBtn, hoverTweenInfo, { BackgroundColor3 = Theme.ButtonHover }):Play()
	end)
	enterBtn.MouseLeave:Connect(function()
		TweenService:Create(enterBtn, hoverTweenInfo, { BackgroundColor3 = Theme.Button }):Play()
	end)

	getBtn.MouseEnter:Connect(function()
		TweenService:Create(getBtn, hoverTweenInfo, { BackgroundColor3 = Theme.ButtonHover }):Play()
	end)
	getBtn.MouseLeave:Connect(function()
		TweenService:Create(getBtn, hoverTweenInfo, { BackgroundColor3 = Theme.Button }):Play()
	end)

	local submitting = false
	local function submitKey()
		if submitting then
			return
		end
		submitting = true
		if keyBox.Text == correctKey then
			saveKey(keyBox.Text)
			pcall(function()
				if cacheKeyValue then
					cacheKeyValue.Value = keyBox.Text
				end
			end)

			inputBg.Visible = false
			btnContainer.Visible = false
			title.Visible = false
			sub.Visible = false

			statusText.TextColor3 = Theme.Status
			statusText.Text = "Success! Abrindo Hub..."
			statusText.Position = UDim2.new(0, 0, 0.5, -10)
			statusText.TextSize = 18
			TweenService:Create(statusText, fadeTweenInfo, { TextTransparency = 0 }):Play()
			task.wait(0.35)
			content.Visible = false

			local closeTween = InstanceUtil.Tween(mainScale, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Scale = 0,
			})
			closeTween.Completed:Wait()
			gui:Destroy()

			-- Abrir o Hub rápido: mostra primeiro, termina init em paralelo.
			pcall(function()
				if hub and type(hub.SetVisible) == "function" then
					hub:SetVisible(true, true)
				end
			end)
			task.spawn(function()
				pcall(function()
					if hub and type(hub.FinishInit) == "function" then
						hub:FinishInit()
					end
				end)
			end)
		else
			statusText.TextColor3 = Theme.Error
			statusText.Text = "Invalid Key"
			TweenService:Create(statusText, fadeTweenInfo, { TextTransparency = 0 }):Play()
			local x = inputBg.Position.X.Scale
			local y = inputBg.Position.Y.Scale
			for _ = 1, 6 do
				inputBg.Position = UDim2.new(x, math.random(-3, 3), y, 0)
				task.wait(0.05)
			end
			inputBg.Position = UDim2.new(x, 0, y, 0)
			submitting = false
		end
	end

	enterBtn.MouseButton1Click:Connect(submitKey)
	keyBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			submitKey()
		end
	end)

	getBtn.MouseButton1Click:Connect(function()
		if typeof(setclipboard) == "function" then
			setclipboard("https://linkvertise.com/example-key")
		end
		notifyLinkCopied()
	end)
end

return Lifecycle
