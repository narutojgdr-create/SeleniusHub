local TweenService = game:GetService("TweenService")

local Defaults = require(script.Parent.Parent.Assets.Defaults)
local IconPaths = require(script.Parent.Parent.Assets.Icons)

local Assets = require(script.Parent.Parent.Utils.Assets)
local InstanceUtil = require(script.Parent.Parent.Utils.Instance)
local Acrylic = require(script.Parent.Parent.Theme.Acrylic)

local Lifecycle = {}

function Lifecycle.CreateLoadingScreen(hub)
	local Theme = hub.ThemeManager:GetTheme()

	local gui = Instance.new("ScreenGui")
	gui.Name = Assets.RandomString(20)
	gui.ResetOnSpawn = false
	gui.Parent = Assets.GetSecureParent()
	gui.DisplayOrder = 100

	local main = Instance.new("Frame")
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Size = UDim2.new(0, 420, 0, 180)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.BackgroundColor3 = Theme.Background
	main.Parent = gui
	main.BorderSizePixel = 0
	main.ClipsDescendants = false
	InstanceUtil.AddCorner(main, 8)

	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 0
	mainScale.Parent = main

	Acrylic.Enable(main, Theme, InstanceUtil)

	local logo = Instance.new("ImageLabel")
	logo.BackgroundTransparency = 1
	logo.Size = UDim2.new(0, 64, 0, 64)
	logo.Position = UDim2.new(0, 20, 0, 20)
	logo.Image = Assets.GetIcon(IconPaths.Logo)
	logo.Parent = main

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 100, 0, 20)
	title.Size = UDim2.new(1, -120, 0, 32)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Theme.Accent
	title.Text = hub:GetText("loading_title")
	title.Parent = main

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.new(0, 100, 0, 52)
	sub.Size = UDim2.new(1, -120, 0, 20)
	sub.Font = Enum.Font.GothamMedium
	sub.TextSize = 18
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextColor3 = Theme.AccentDark
	sub.Text = hub:GetText("loading_sub")
	sub.Parent = main

	local barBg = Instance.new("Frame")
	barBg.BackgroundColor3 = Theme.Separator
	barBg.Position = UDim2.new(0, 20, 0, 100)
	barBg.Size = UDim2.new(1, -40, 0, 10)
	barBg.Parent = main
	barBg.BorderSizePixel = 0
	InstanceUtil.AddCorner(barBg, 5)

	local barFill = Instance.new("Frame")
	barFill.BackgroundColor3 = Theme.Accent
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.Parent = barBg
	barFill.BorderSizePixel = 0
	InstanceUtil.AddCorner(barFill, 5)

	local percentLabel = Instance.new("TextLabel")
	percentLabel.BackgroundTransparency = 1
	percentLabel.Position = UDim2.new(0, 20, 0, 116)
	percentLabel.Size = UDim2.new(0, 80, 0, 22)
	percentLabel.Font = Enum.Font.GothamMedium
	percentLabel.TextSize = 18
	percentLabel.TextXAlignment = Enum.TextXAlignment.Left
	percentLabel.TextColor3 = Theme.TextPrimary
	percentLabel.Text = "0%"
	percentLabel.Parent = main

	local openBtn = Instance.new("TextButton")
	openBtn.BackgroundColor3 = Theme.Button
	openBtn.Size = UDim2.new(0, 130, 0, 32)
	openBtn.Position = UDim2.new(1, -150, 1, -50)
	openBtn.Font = Enum.Font.GothamMedium
	openBtn.TextSize = 18
	openBtn.TextColor3 = Theme.TextPrimary
	openBtn.Text = hub:GetText("loading_button")
	openBtn.AutoButtonColor = false
	openBtn.Visible = false
	openBtn.Parent = main
	openBtn.BorderSizePixel = 0
	InstanceUtil.AddCorner(openBtn, 6)

	InstanceUtil.Tween(mainScale, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 })

	-- Loading agora roda DEPOIS do hub abrir, enquanto o hub finaliza a inicialização.
	local done = false
	task.spawn(function()
		local ok = pcall(function()
			if hub and type(hub.FinishInit) == "function" then
				hub:FinishInit()
			end
		end)
		-- Mesmo se der erro, não travar na tela.
		done = true
		if not ok then
			-- sem spam; só garante que sai do loading
		end
	end)

	local duration = 0.25
	local steps = 24
	task.spawn(function()
		-- Sobe até 90% enquanto o init pesado roda
		for i = 1, steps do
			local progress = (i / steps) * 0.9
			barFill.Size = UDim2.new(progress, 0, 1, 0)
			percentLabel.Text = tostring(math.floor(progress * 100)) .. "%"
			task.wait(duration / steps)
			if done then
				break
			end
		end

		-- Espera terminar (curto)
		local t0 = tick()
		while not done and (tick() - t0) < 8 do
			task.wait(0.05)
		end

		-- Finaliza 100%
		barFill.Size = UDim2.new(1, 0, 1, 0)
		percentLabel.Text = "100%"
		task.wait(0.12)

		openBtn.Visible = false
		InstanceUtil.Tween(mainScale, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0 })
		task.wait(0.35)
		if gui and gui.Parent then
			gui:Destroy()
		end
	end)

	openBtn.MouseEnter:Connect(function()
		InstanceUtil.Tween(openBtn, Defaults.Tween.AnimConfig, { BackgroundColor3 = Theme.ButtonHover })
	end)
	openBtn.MouseLeave:Connect(function()
		InstanceUtil.Tween(openBtn, Defaults.Tween.AnimConfig, { BackgroundColor3 = Theme.Button })
	end)
	openBtn.MouseButton1Click:Connect(function()
		InstanceUtil.Tween(mainScale, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0 })
		task.wait(0.4)
		gui:Destroy()
	end)
end

function Lifecycle.CreateKeySystem(hub)
	local Theme = hub.ThemeManager:GetTheme()
	local correctKey = "testing123"

	local gui = Instance.new("ScreenGui")
	gui.Name = Assets.RandomString(20)
	gui.ResetOnSpawn = false
	gui.Parent = Assets.GetSecureParent()
	gui.DisplayOrder = 100

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

	InstanceUtil.Tween(mainScale, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 })

	enterBtn.MouseEnter:Connect(function()
		TweenService:Create(enterBtn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.ButtonHover }):Play()
	end)
	enterBtn.MouseLeave:Connect(function()
		TweenService:Create(enterBtn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Button }):Play()
	end)

	getBtn.MouseEnter:Connect(function()
		TweenService:Create(getBtn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.ButtonHover }):Play()
	end)
	getBtn.MouseLeave:Connect(function()
		TweenService:Create(getBtn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Button }):Play()
	end)

	enterBtn.MouseButton1Click:Connect(function()
		if keyBox.Text == correctKey then
			inputBg.Visible = false
			btnContainer.Visible = false
			title.Visible = false
			sub.Visible = false

			statusText.TextColor3 = Theme.Status
			statusText.Text = "Success! Loading..."
			statusText.Position = UDim2.new(0, 0, 0.5, -10)
			statusText.TextSize = 18
			TweenService:Create(statusText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
			task.wait(0.6)
			content.Visible = false

			local closeTween = InstanceUtil.Tween(mainScale, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Scale = 0,
			})
			closeTween.Completed:Wait()
			gui:Destroy()

			-- Mostra o hub IMEDIATAMENTE e faz o carregamento pesado no Loading.
			hub:SetVisible(true, true)
			Lifecycle.CreateLoadingScreen(hub)
		else
			statusText.TextColor3 = Theme.Error
			statusText.Text = "Invalid Key"
			TweenService:Create(statusText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
			local x = inputBg.Position.X.Scale
			local y = inputBg.Position.Y.Scale
			for _ = 1, 6 do
				inputBg.Position = UDim2.new(x, math.random(-3, 3), y, 0)
				task.wait(0.05)
			end
			inputBg.Position = UDim2.new(x, 0, y, 0)
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
