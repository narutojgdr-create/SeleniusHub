local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Assets = require(script.Parent.Parent.Utils.Assets)
local InstanceUtil = require(script.Parent.Parent.Utils.Instance)
local Acrylic = require(script.Parent.Parent.Theme.Acrylic)

local Lifecycle = {}

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
			hubNotify(hub, "Carregando...", true)
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
	main.Size = UDim2.new(0, 380, 0, 220)
	main.BackgroundColor3 = Theme.Background
	main.BorderSizePixel = 0
	main.ClipsDescendants = false
	main.Parent = gui

	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 0
	mainScale.Parent = main

	InstanceUtil.AddCorner(main, 8)
	Acrylic.Enable(main, Theme, InstanceUtil)

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = main
	content.Visible = true

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 0, 0, 25)
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextColor3 = Theme.Accent
	title.Text = "SELENIUS KEY"
	title.Parent = content

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.new(0, 0, 0, 50)
	sub.Size = UDim2.new(1, 0, 0, 20)
	sub.Font = Enum.Font.GothamMedium
	sub.TextSize = 14
	sub.TextColor3 = Theme.AccentDark
	sub.Text = "Authentication Required"
	sub.Parent = content

	local inputBg = Instance.new("Frame")
	inputBg.BackgroundColor3 = Theme.Secondary
	inputBg.Position = UDim2.new(0.1, 0, 0.35, 0)
	inputBg.Size = UDim2.new(0.8, 0, 0, 40)
	inputBg.Parent = content
	InstanceUtil.AddCorner(inputBg, 6)

	local showKey = false
	local function maskKey(s)
		s = tostring(s or "")
		if showKey then
			return s
		end
		if #s == 0 then
			return ""
		end
		local prefixLen = math.min(2, #s)
		local prefix = string.sub(s, 1, prefixLen)
		local rest = #s - prefixLen
		if rest <= 0 then
			return prefix
		end
		return prefix .. " " .. string.rep("•", rest)
	end

	local showBtn = Instance.new("TextButton")
	showBtn.BackgroundColor3 = Theme.Button
	showBtn.Position = UDim2.new(1, -92, 0, 6)
	showBtn.Size = UDim2.new(0, 86, 0, 28)
	showBtn.Font = Enum.Font.GothamBold
	showBtn.TextSize = 12
	showBtn.TextColor3 = Theme.TextPrimary
	showBtn.Text = "MOSTRAR"
	showBtn.AutoButtonColor = false
	showBtn.Parent = inputBg
	InstanceUtil.AddCorner(showBtn, 6)

	local keyBox = Instance.new("TextBox")
	keyBox.BackgroundTransparency = 1
	keyBox.Position = UDim2.new(0, 10, 0, 0)
	keyBox.Size = UDim2.new(1, -112, 1, 0)
	keyBox.Font = Enum.Font.GothamMedium
	keyBox.TextSize = 14
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
	maskLbl.TextTruncate = Enum.TextTruncate.AtEnd
	maskLbl.Text = maskKey(keyBox.Text)
	maskLbl.Parent = inputBg

	local function refreshKeyMask()
		maskLbl.Text = maskKey(keyBox.Text)
		maskLbl.Visible = not showKey
		keyBox.TextTransparency = showKey and 0 or 1
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
	btnContainer.Position = UDim2.new(0.1, 0, 0.65, 0)
	btnContainer.Size = UDim2.new(0.8, 0, 0, 35)
	btnContainer.Parent = content

	local enterBtn = Instance.new("TextButton")
	enterBtn.BackgroundColor3 = Theme.Button
	enterBtn.Size = UDim2.new(0.48, 0, 1, 0)
	enterBtn.Font = Enum.Font.GothamBold
	enterBtn.TextSize = 14
	enterBtn.TextColor3 = Theme.Accent
	enterBtn.Text = "CHECK KEY"
	enterBtn.Parent = btnContainer
	InstanceUtil.AddCorner(enterBtn, 6)

	local getBtn = Instance.new("TextButton")
	getBtn.BackgroundColor3 = Theme.Button
	getBtn.Position = UDim2.new(0.52, 0, 0, 0)
	getBtn.Size = UDim2.new(0.48, 0, 1, 0)
	getBtn.Font = Enum.Font.GothamBold
	getBtn.TextSize = 14
	getBtn.TextColor3 = Theme.TextPrimary
	getBtn.Text = "GET KEY"
	getBtn.Parent = btnContainer
	InstanceUtil.AddCorner(getBtn, 6)

	local statusText = Instance.new("TextLabel")
	statusText.BackgroundTransparency = 1
	statusText.Position = UDim2.new(0, 0, 0.85, 0)
	statusText.Size = UDim2.new(1, 0, 0, 20)
	statusText.Font = Enum.Font.GothamMedium
	statusText.TextSize = 12
	statusText.TextColor3 = Theme.Error
	statusText.TextTransparency = 1
	statusText.Text = ""
	statusText.Parent = content

	-- Animação mais fluida
	InstanceUtil.Tween(mainScale, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 })

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
		statusText.TextColor3 = Theme.Accent
		statusText.Text = "Link copied to clipboard"
		TweenService:Create(statusText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
		task.delay(2, function()
			TweenService:Create(statusText, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		end)
	end)
end

return Lifecycle
