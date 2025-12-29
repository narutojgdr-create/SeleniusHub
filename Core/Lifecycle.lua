local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Assets = require(script.Parent.Parent.Utils.Assets)
local InstanceUtil = require(script.Parent.Parent.Utils.Instance)
local Acrylic = require(script.Parent.Parent.Theme.Acrylic)

local Lifecycle = {}

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

	-- Notificação ao executar o Hub.
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "SeleniusHub",
			Text = "Hub inicializando, espere 5-10 segundos",
			Duration = 6,
		})
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

	local keyBox = Instance.new("TextBox")
	keyBox.BackgroundTransparency = 1
	keyBox.Position = UDim2.new(0, 10, 0, 0)
	keyBox.Size = UDim2.new(1, -20, 1, 0)
	keyBox.Font = Enum.Font.GothamMedium
	keyBox.TextSize = 14
	keyBox.TextColor3 = Theme.TextPrimary
	keyBox.PlaceholderText = "Insert Key Here..."
	keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
	keyBox.Text = ""
	keyBox.ClearTextOnFocus = false
	keyBox.Parent = inputBg

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
			-- Notificação após clicar/enter (do jeito que você pediu)
			pcall(function()
				StarterGui:SetCore("SendNotification", {
					Title = "SeleniusHub",
					Text = "Hub inicializando, espere 5-10 segundos",
					Duration = 6,
				})
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

			-- Sem Loading: finaliza init e abre o Hub automaticamente.
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
