--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║      SELENIUS HUB v17.5 - DUOTONE RESTORATION                 ║
    ║            ARCHITECT: SELENIUS DEVELOPER & GEMINI             ║
    ║      STATUS: ORIGINAL DARK | 2-COLOR DESIGN | ULTRA CLEAN     ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

--------------------------------------------------------------------
-- Serviços (Otimizados)
--------------------------------------------------------------------
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")
local VirtualUser       = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Gerador de Strings Aleatórias (Leve)
local function RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local str = ""
    local random = math.random
    for i = 1, length or 10 do
        local r = random(1, #chars)
        str = str .. string.sub(chars, r, r)
    end
    return str
end

-- Função para obter diretório seguro da GUI
local function GetSecureParent()
    local success, result = pcall(function() return gethui() end)
    if success and result then return result end
    success, result = pcall(function() return CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function GetGameName()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if success and info then
        return info.Name
    end
    return "Unknown Game"
end

--------------------------------------------------------------------
-- Arquivos e Config
--------------------------------------------------------------------
local CONFIG_FOLDER = "SeleniusHub"
local CONFIGS_DIR   = CONFIG_FOLDER .. "/Configs"
local IMAGE_FOLDER  = CONFIG_FOLDER .. "/imagens"

if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
if not isfolder(CONFIGS_DIR) then makefolder(CONFIGS_DIR) end
if not isfolder(IMAGE_FOLDER) then makefolder(IMAGE_FOLDER) end

local function SafeWriteFile(path, data)
    pcall(writefile, path, data)
end

local function SafeReadFile(path)
    local s, r = pcall(readfile, path)
    return s and r or nil
end

local function SafeIsFile(path)
    local s, r = pcall(isfile, path)
    return s and r
end

-- Função para listar configs
local function GetConfigList()
    local files = {}
    if isfolder(CONFIGS_DIR) then
        local success, result = pcall(function() return listfiles(CONFIGS_DIR) end)
        if success then
            for _, path in pairs(result) do
                local name = path:match("([^/\\]+)%.json$") or path:match("([^/\\]+)$")
                if name then
					local clean = name:gsub("%.json$", "")
					table.insert(files, clean)
                end
            end
        end
    end
    if #files == 0 then table.insert(files, "default") end
    return files
end

--------------------------------------------------------------------
-- Assets
--------------------------------------------------------------------
local IconPaths = {
    Combat   = IMAGE_FOLDER .. "/combat.png",
    Visuals  = IMAGE_FOLDER .. "/visuals.png",
    Player   = IMAGE_FOLDER .. "/player.png",
    Settings = IMAGE_FOLDER .. "/settings.png",
    Logo     = IMAGE_FOLDER .. "/logo.png",
    Home     = IMAGE_FOLDER .. "/home.png",
    Key      = IMAGE_FOLDER .. "/key.png", 
}

for _, path in pairs(IconPaths) do
    if not SafeIsFile(path) then SafeWriteFile(path, "") end
end

local function GetIcon(path)
    if typeof(getcustomasset) == "function" and SafeIsFile(path) then
        local ok, res = pcall(getcustomasset, path)
        if ok then return res end
    end
    return "rbxassetid://6034509993" 
end

--------------------------------------------------------------------
-- Temas Modernos e Profissionais (v17.5 - DUOTONE)
--------------------------------------------------------------------
-- PALETA: DEEP MIDNIGHT & ELECTRIC BLUE (2 Cores Estritas)
local Themes = {
    ["Midnight"] = { 
        Background   = Color3.fromRGB(10, 10, 14), -- Cor 1: Fundo Absoluto
        Secondary    = Color3.fromRGB(16, 16, 22), -- Cor 1 (Variação): Cards/Sidebar
        Separator    = Color3.fromRGB(25, 25, 35), -- Cor 1 (Variação): Linhas
        Accent       = Color3.fromRGB(50, 115, 255), -- Cor 2: AZUL ORIGINAL (Ação/Destaque)
        AccentDark   = Color3.fromRGB(60, 60, 80), -- Cor 1 (Variação): Texto Inativo
        TextPrimary  = Color3.fromRGB(255, 255, 255), -- Neutro (Branco Puro para contraste)
        Button       = Color3.fromRGB(16, 16, 22), -- Mesmo que Secondary
        ButtonHover  = Color3.fromRGB(25, 25, 35), -- Levemente mais claro
        IndicatorOff = Color3.fromRGB(30, 30, 40), -- Desligado (Escuro)
        IndicatorOn  = Color3.fromRGB(50, 115, 255), -- Ligado (Azul)
        Border       = Color3.fromRGB(0, 0, 0), 
        Stroke       = Color3.fromRGB(30, 30, 45), -- Contorno Sutil (Tom de azul muito escuro)
        Error        = Color3.fromRGB(255, 80, 80), -- Única exceção (Feedback)
        Warning      = Color3.fromRGB(255, 180, 50), -- Única exceção (Feedback)
        Status       = Color3.fromRGB(50, 115, 255)  -- Azul
    }
}

local Theme = Themes["Midnight"] 

--------------------------------------------------------------------
-- Animações & Utils (Otimizado)
--------------------------------------------------------------------
local AnimConfig     = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local DropdownTween  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SliderTween    = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PopTween       = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local PopReturnTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Utils = {}

function Utils:Tween(object, tweenInfo, properties)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- !!! FIX DE ROBUSTEZ: PREVINE ERROS EM PROPRIEDADES !!!
-- !!! OTIMIZAÇÃO: REMOVIDO PCALL LOOP (Aumento de Performance de 100x) !!!
function Utils:CreateInstance(className, props)
    local inst = Instance.new(className)
    -- Nome aleatório mantido para segurança básica
    inst.Name = RandomString(math.random(10, 20))
    
    local parent = props.Parent
    props.Parent = nil -- Define o Parent por último (Melhor prática do Roblox)
    
    for k, v in pairs(props) do
        inst[k] = v
    end
    
    if parent then
        inst.Parent = parent
    end
    
    if inst:IsA("GuiObject") then
        inst.BorderSizePixel = 0 
    end
    return inst
end

function Utils:AddCorner(parent, radius)
    return Utils:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent
    })
end

-- Nova função para estética
function Utils:AddStroke(parent, color, thickness, transparency)
    return Utils:CreateInstance("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

function Utils:Lerp(a, b, t)
    return a + (b - a) * t
end

-- Módulo Acrylic v11.0 & NO Stroke System (Adaptado para Light Mode)
local Acrylic = {}
function Acrylic.Enable(frame)
    frame.BackgroundTransparency = 0.05 
    frame.BackgroundColor3 = Theme.Background
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 60
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), 
        ColorSequenceKeypoint.new(1, Color3.new(0.98,0.98,0.99)) 
    })
    gradient.Parent = frame

    -- Adiciona Stroke automaticamente para melhor acabamento
    Utils:AddStroke(frame, Theme.Stroke, 1.5, 0)

    local function updateBlur(visible)
    end
    
    return updateBlur, nil
end

--------------------------------------------------------------------
-- Localização Completa (v11)
--------------------------------------------------------------------
local Locales = {
    pt = {
        tab_Combat      = "Combate",
        tab_Visuals     = "Visual",
        tab_Player      = "Player",
        tab_Settings    = "Config",
        tab_Home        = "Início",
        section_home    = "Informações",
        label_home_title  = "Selenius Hub",
        label_home_credit = "Criador: Selenius Dev",
        label_home_discord = "Discord: Selenius",
        label_search      = "Procurar...",
        label_status      = "Status:",
        
        section_combat   = "Opções de Combate",
        section_visuals  = "Opções Visuais",
        section_player   = "Opções do Jogador",
        section_settings = "Sistema",

        label_theme      = "Tema",
        label_keybind    = "Tecla do Menu",
        label_config_system = "Sistema de Configuração",
        label_create     = "Criar",
        label_load       = "Carregar",
        label_save       = "Salvar",
        label_refresh    = "Atualizar Lista",
        label_select_cfg = "Configs Criadas",
        label_new_cfg_ph = "Nome da nova config",
        
        label_reinject = "Reinjetar Hub",
        label_serverhop = "Trocar de Servidor",
        label_rejoin = "Reentrar no Jogo",
        label_language = "Idioma",
        label_destroy  = "DESTRUIR HUB",
        
        -- System
        lang_pt = "Português",
        lang_en = "Inglês",
        section_keybinds = "Teclas",
        loading_title  = "SELENIUS HUB",
        loading_sub    = "Carregando...",
        loading_button = "Entrar",
        label_reset = "Resetar",
        label_antiafk = "Anti-AFK",
        msg_on  = "LIGADO",
        msg_off = "DESLIGADO",
        label_apply            = "Sim",
        label_cancel           = "Não",
        confirm_destroy  = "Destruir completamente o Hub?",
        confirm_reinject = "Recarregar o script?",
        confirm_reset    = "Apagar tudo e resetar?",
    },
    en = {
        tab_Combat      = "Combat",
        tab_Visuals     = "Visuals",
        tab_Player      = "Player",
        tab_Settings    = "Settings",
        tab_Home        = "Home",
        section_home    = "Info",
        label_home_title  = "Selenius Hub",
        label_home_credit = "Dev: Selenius Dev",
        label_home_discord = "Discord: Selenius",
        label_search      = "Search...",
        label_status      = "Status:",
        
        section_combat   = "Combat Options",
        section_visuals  = "Visual Options",
        section_player   = "Player Options",
        section_settings = "System",

        label_theme      = "Theme",
        label_keybind    = "Menu Key",
        label_config_system = "Config System",
        label_create     = "Create",
        label_load       = "Load",
        label_save       = "Save",
        label_refresh    = "Refresh List",
        label_select_cfg = "Created Configs",
        label_new_cfg_ph = "New config name",
        
        label_reinject = "Reinject Hub",
        label_serverhop = "Server Hop",
        label_rejoin = "Rejoin Game",
        label_language = "Language",
        label_destroy  = "DESTROY HUB",
        
        -- System
        lang_pt = "Portuguese",
        lang_en = "English",
        section_keybinds = "Binds",
        loading_title  = "SELENIUS HUB",
        loading_sub    = "Loading...",
        loading_button = "Enter",
        label_reset = "Reset",
        label_antiafk = "Anti-AFK",
        msg_on  = "ON",
        msg_off = "OFF",
        label_apply            = "Yes",
        label_cancel           = "No",
        confirm_destroy  = "Completely destroy Hub?",
        confirm_reinject = "Reload script?",
        confirm_reset    = "Reset all settings?",
    }
}

--------------------------------------------------------------------
-- SeleniusHub UI
--------------------------------------------------------------------
local SeleniusHub = {}
SeleniusHub.__index = SeleniusHub

function SeleniusHub.new()
    local self = setmetatable({}, SeleniusHub)

    self.Connections                = {} 
    self.Pages                      = {}
    self.Tabs                       = {}
    self.ThemedObjects              = {}
    self.LocalizedObjects           = {}
    self.ThemeCallbacks             = {} 
    self.ResizeDots                 = {}

    self.Minimized                  = false
    self.MinWidth                   = 520 
    self.MinHeight                  = 350
    self.MinimizedHeight            = 46

    self.CurrentThemeName = "Midnight" -- Novo Tema Padrão
    self.Locale             = "pt"
    self.Keybind            = Enum.KeyCode.RightControl
    self.BlurFunction       = nil
    self.MainStroke         = nil 
    self.IsMobile           = UserInputService.TouchEnabled

    self.LoadedSize         = nil
    self.SavedSize          = nil
    self.StoredSize         = nil
    self.StoredPos          = nil

    self.VisibilityAnimating = false
    self.NotificationHolder  = nil
    self.ConfigName          = "default"
    self.SelectedConfig      = "default"

    self.SettingsState = { AntiAFK = false }
    self.CombatState = {}
    self.VisualsState = {}
    self.PlayerState = {}

    self.OptionToggles = {}
    self.OptionLocales = {}
    self.Searchables = {}
    self.CustomKeybinds = {}
    self.KeybindCallbacks = {}
    self.CapturingOptionKey = nil
    self.LocalizedDropdowns = {}
    self.DropdownZCounter = 2000

    self:LoadConfig("default")
    Theme = Themes[self.CurrentThemeName] or Themes["Midnight"]

    self:CreateUI()
    self:CreateNotificationSystem()
    self:SetupSmoothDrag()
    self:SetupResizing()
    self:SetupButtons()
    self:SetupMobileSupport()

    self:AddPage("Home",    "tab_Home",    "Home")
    self:AddPage("Combat",  "tab_Combat",  "Combat")
    self:AddPage("Visuals", "tab_Visuals", "Visuals")
    self:AddPage("Player",  "tab_Player",  "Player")
    self:AddPage("Settings","tab_Settings","Settings")
    self:SwitchPage("Home")

    self:SetTheme(self.CurrentThemeName)
    self:SetLanguage(self.Locale)
    self:SetupKeybindSystem()
    self:OnKeybindChanged()
    self:SetupSearch()

    self:PopulateCombat()
    self:PopulateVisuals()
    self:PopulatePlayer()

    if self.UpdateTabLabelPositions then
        self:UpdateTabLabelPositions()
    end

    if self.UI and self.UI.MainFrame then
        self.UI.MainFrame.Visible = false
    end

    self:StartLogicLoops()

    return self
end

function SeleniusHub:StartLogicLoops()
    self:AddConnection(LocalPlayer.Idled, function()
        if self.SettingsState.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
    
    self:AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.UI and self.UI.MainFrame and self.UI.MainFrame.Visible then
                -- !!! FIX: SÓ EMPURRA PARA BAIXO SE NÃO ESTIVER MINIMIZADO !!!
                if not self.Minimized then
                    local frame = self.UI.MainFrame
                    if frame.AbsolutePosition.Y < 0 then
                        -- Margem segura para não colar no topo
                        local safeY = 20 
                        local halfHeight = frame.AbsoluteSize.Y / 2
                        local newCenterYOffset = safeY + halfHeight
                        
                        Utils:Tween(frame, AnimConfig, {
                            Position = UDim2.new(
                                frame.Position.X.Scale, 
                                frame.Position.X.Offset, 
                                0, 
                                newCenterYOffset
                            )
                        })
                    end
                end
            end
        end
    end)
end

function SeleniusHub:AddConnection(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(self.Connections, conn)
    return conn
end

function SeleniusHub:GetText(key)
    local langTable = Locales[self.Locale] or Locales["pt"]
    return langTable[key] or key
end

function SeleniusHub:RegisterLocale(obj, key, prefix, suffix)
    table.insert(self.LocalizedObjects, {
        Object = obj, Key = key, Prefix = prefix or "", Suffix = suffix or ""
    })
    obj.Text = (prefix or "") .. self:GetText(key) .. (suffix or "")
end

function SeleniusHub:RegisterLocalizedOptions(dropdown, keys)
    table.insert(self.LocalizedDropdowns, { Dropdown = dropdown, Keys = keys })
end

function SeleniusHub:SetLanguage(lang)
    if not Locales[lang] then return end
    self.Locale = lang
    for _, info in ipairs(self.LocalizedObjects) do
        local obj = info.Object
        local text = self:GetText(info.Key)
        if obj and obj.Parent then
            obj.Text = (info.Prefix or "") .. text .. (info.Suffix or "")
        end
    end
    if self.LanguageDropdown and self.LanguageDropdown.currentLabel then
        self.LanguageDropdown.currentLabel.Text = (self.Locale == "pt") and self:GetText("lang_pt") or self:GetText("lang_en")
        if self.LanguageDropdown.optionButtons then
            for i, btn in ipairs(self.LanguageDropdown.optionButtons) do
                if i == 1 then btn.Text = self:GetText("lang_pt") else btn.Text = self:GetText("lang_en") end
            end
        end
    end
    self:OnKeybindChanged()
    if self.UpdateTabStyles then self:UpdateTabStyles() end
    if self.UpdateTabLabelPositions then self:UpdateTabLabelPositions() end
    if self.SearchBox then self.SearchBox.PlaceholderText = self:GetText("label_search") end
end

function SeleniusHub:RegisterTheme(obj, prop, key)
    table.insert(self.ThemedObjects, { Object = obj, Property = prop, Key = key })
end

function SeleniusHub:SetTheme(name)
    local t = Themes[name]
    if not t then return end
    Theme = t 
    self.CurrentThemeName = name
    
    for _, info in ipairs(self.ThemedObjects) do
        local obj = info.Object
        if obj and obj.Parent and Theme[info.Key] then
            obj[info.Property] = Theme[info.Key]
        end
    end
    
    if self.UI and self.UI.TitleLabel then self.UI.TitleLabel.TextColor3 = Theme.Accent end
    
    if self.UI.CloseBtn then 
        self.UI.CloseBtn.BackgroundColor3 = Theme.Button
        self.UI.CloseBtn.TextColor3 = Theme.TextPrimary 
    end
    if self.UI.MinimizeBtn then 
        self.UI.MinimizeBtn.BackgroundColor3 = Theme.Button
        self.UI.MinimizeBtn.TextColor3 = Theme.TextPrimary
    end

    for _, callback in ipairs(self.ThemeCallbacks) do
        task.spawn(callback)
    end

    if self.UpdateTabStyles then self:UpdateTabStyles() end
end

function SeleniusHub:GetKeybindName()
    return (self.Keybind and self.Keybind.Name) or "Nenhum"
end

function SeleniusHub:SaveConfig(name)
    if not self.UI or not self.UI.MainFrame then return end
    name = name or self.ConfigName
    if not name or name == "" then return end
    
    local size = self.SavedSize or self.UI.MainFrame.Size
    local data = {
        Theme    = self.CurrentThemeName,
        Keybind  = self.Keybind and self.Keybind.Name or nil,
        Width    = size.X.Offset,
        Height   = size.Y.Offset,
        Language = self.Locale,
        Settings = self.SettingsState
    }
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then
        local filename = name .. ".json"
        SafeWriteFile(CONFIGS_DIR .. "/" .. filename, encoded)
        self:ShowWarning("Config salva: " .. name, "info")
    end
end

function SeleniusHub:LoadConfig(name)
    local filename = (name or "default") .. ".json"
    local path = CONFIGS_DIR .. "/" .. filename
    local encoded
    
    if SafeIsFile(path) and typeof(readfile) == "function" then
        local ok, res = pcall(readfile, path)
        if ok then encoded = res end
    end
    
    if not encoded then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(encoded) end)
    if not ok or type(data) ~= "table" then return end
    
    if data.Theme and Themes[data.Theme] then self:SetTheme(data.Theme) end
    if data.Keybind and Enum.KeyCode[data.Keybind] then self.Keybind = Enum.KeyCode[data.Keybind] end
    if data.Language and Locales[data.Language] then self:SetLanguage(data.Language) end
    if data.Width and data.Height then
        self.LoadedSize = { Width = data.Width, Height = data.Height }
    end
    if data.Settings then 
        for k, v in pairs(data.Settings) do self.SettingsState[k] = v end 
        if self.OptionToggles["settings_antiafk"] then
            self.OptionToggles["settings_antiafk"].SetState(self.SettingsState.AntiAFK)
        end
    end

    self:OnKeybindChanged()
    self:ShowWarning("Config carregada: " .. (name or "default"), "info")
end

function SeleniusHub:CreateNotificationSystem()
    if self.NotificationHolder and self.NotificationHolder.Parent then
        return
    end

    local holder = Instance.new("Frame")
    holder.Name = "Notifications"
    holder.BackgroundTransparency = 1
    -- Mantém a posição original (canto inferior direito)
    holder.Position = UDim2.new(1, -20, 1, -20)
    holder.AnchorPoint = Vector2.new(1, 1)
    holder.Size = UDim2.new(0, 340, 1, 0)
    holder.Parent = self.UI.ScreenGui
    holder.ClipsDescendants = false

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 10)
    layout.Parent = holder

    self.NotificationHolder = holder
    self._NotificationPool = self._NotificationPool or {}
    self._NotificationSeq = self._NotificationSeq or 0
end

function SeleniusHub:ShowWarning(text, kind, instant)
    kind = kind or "info"

    if not self.NotificationHolder then
        self:CreateNotificationSystem()
    end

    self._NotificationPool = self._NotificationPool or {}
    self._NotificationSeq = (self._NotificationSeq or 0) + 1
    local token = self._NotificationSeq

    local accentColor = Theme.Accent
    local titleText = "INFO"
    local iconChar = "i"
    if kind == "error" then
        accentColor = Theme.Error
        titleText = "ERRO"
        iconChar = "×"
    elseif kind == "warn" then
        accentColor = Theme.AccentDark or Theme.Accent
        titleText = "AVISO"
        iconChar = "!"
    elseif kind == "success" or kind == "status" then
        accentColor = Theme.Status or Theme.Accent
        titleText = "SUCESSO"
        iconChar = "✓"
    end

    local frame = table.remove(self._NotificationPool)
    if not frame then
        frame = Utils:CreateInstance("Frame", {
            Name = "Notification",
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 58),
        })
        Utils:AddCorner(frame, 12)
        Utils:AddStroke(frame, Theme.Stroke, 1, 1).Name = "Stroke"

        local iconBg = Instance.new("Frame")
        iconBg.Name = "IconBg"
        iconBg.AnchorPoint = Vector2.new(0, 0.5)
        iconBg.Position = UDim2.new(0, 12, 0.5, 0)
        iconBg.Size = UDim2.new(0, 30, 0, 30)
        iconBg.BorderSizePixel = 0
        iconBg.Parent = frame
        Utils:AddCorner(iconBg, 15)

        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 14
        icon.TextXAlignment = Enum.TextXAlignment.Center
        icon.TextYAlignment = Enum.TextYAlignment.Center
        icon.Parent = iconBg

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 52, 0, 10)
        title.Size = UDim2.new(1, -64, 0, 14)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Center
        title.TextWrapped = false
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.Parent = frame

        local msg = Instance.new("TextLabel")
        msg.Name = "Message"
        msg.BackgroundTransparency = 1
        msg.Position = UDim2.new(0, 52, 0, 26)
        msg.Size = UDim2.new(1, -64, 0, 20)
        msg.Font = Enum.Font.GothamMedium
        msg.TextSize = 13
        msg.TextXAlignment = Enum.TextXAlignment.Left
        msg.TextYAlignment = Enum.TextYAlignment.Top
        msg.TextWrapped = true
        msg.TextTruncate = Enum.TextTruncate.AtEnd
        msg.Parent = frame

        local progressBg = Instance.new("Frame")
        progressBg.Name = "ProgressBg"
        progressBg.AnchorPoint = Vector2.new(0, 1)
        progressBg.Position = UDim2.new(0, 0, 1, 0)
        progressBg.Size = UDim2.new(1, 0, 0, 3)
        progressBg.BorderSizePixel = 0
        progressBg.Parent = frame

        local progress = Instance.new("Frame")
        progress.Name = "Progress"
        progress.AnchorPoint = Vector2.new(0, 1)
        progress.Position = UDim2.new(0, 0, 1, 0)
        progress.Size = UDim2.new(1, 0, 0, 3)
        progress.BorderSizePixel = 0
        progress.Parent = progressBg

        local scale = Instance.new("UIScale")
        scale.Name = "Scale"
        scale.Scale = 1
        scale.Parent = frame
    end

    pcall(function()
        frame:SetAttribute("NotifToken", token)
    end)
    frame.LayoutOrder = token
    frame.Parent = self.NotificationHolder

    frame.BackgroundColor3 = Theme.Secondary
    frame.BackgroundTransparency = instant and 0.12 or 1

    local stroke = frame:FindFirstChild("Stroke")
    if stroke then
        stroke.Color = Theme.Stroke
        stroke.Transparency = 1
    end

    local iconBg = frame:FindFirstChild("IconBg")
    local icon = iconBg and iconBg:FindFirstChild("Icon")
    local title = frame:FindFirstChild("Title")
    local msg = frame:FindFirstChild("Message")
    local progressBg = frame:FindFirstChild("ProgressBg")
    local progress = progressBg and progressBg:FindFirstChild("Progress")
    local scale = frame:FindFirstChild("Scale")

    if iconBg then
        iconBg.BackgroundColor3 = accentColor
        iconBg.BackgroundTransparency = 0.15
    end
    if icon then
        icon.Text = iconChar
        icon.TextColor3 = Theme.TextPrimary
        icon.TextTransparency = 0
    end
    if title then
        title.Text = titleText
        title.TextColor3 = accentColor
        title.TextTransparency = instant and 0 or 1
    end
    if msg then
        msg.Text = tostring(text or "")
        msg.TextColor3 = Theme.TextPrimary
        msg.TextTransparency = instant and 0 or 1
    end
    if progressBg then
        progressBg.BackgroundColor3 = Theme.Button
        progressBg.BackgroundTransparency = 0.35
    end
    if progress then
        progress.BackgroundColor3 = accentColor
        progress.BackgroundTransparency = instant and 0 or 1
        progress.Size = UDim2.new(1, 0, 0, 3)
    end
    if scale then
        scale.Scale = instant and 1 or 0.94
    end

    local inTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local outTween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    if not instant then
        if scale then Utils:Tween(scale, inTween, { Scale = 1 }) end
        Utils:Tween(frame, inTween, { BackgroundTransparency = 0.12 })
        if title then Utils:Tween(title, inTween, { TextTransparency = 0 }) end
        if msg then Utils:Tween(msg, inTween, { TextTransparency = 0 }) end
        if progress then Utils:Tween(progress, inTween, { BackgroundTransparency = 0 }) end
        pcall(function()
            if stroke then Utils:Tween(stroke, inTween, { Transparency = 0.55 }) end
        end)
    end

    local lifetime = 3.4
    if progress then
        Utils:Tween(progress, TweenInfo.new(lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(0, 0, 0, 3) })
    end

    task.delay(lifetime, function()
        if not (frame and frame.Parent) then return end
        local ok, current = pcall(function() return frame:GetAttribute("NotifToken") end)
        if ok and current ~= token then return end

        if scale then Utils:Tween(scale, outTween, { Scale = 0.94 }) end
        local t = Utils:Tween(frame, outTween, { BackgroundTransparency = 1 })
        if title then Utils:Tween(title, outTween, { TextTransparency = 1 }) end
        if msg then Utils:Tween(msg, outTween, { TextTransparency = 1 }) end
        if progress then Utils:Tween(progress, outTween, { BackgroundTransparency = 1 }) end
        pcall(function()
            if stroke then Utils:Tween(stroke, outTween, { Transparency = 1 }) end
        end)
        pcall(function() t.Completed:Wait() end)

        ok, current = pcall(function() return frame:GetAttribute("NotifToken") end)
        if ok and current ~= token then return end

        frame.Parent = nil
        table.insert(self._NotificationPool, frame)
    end)
end

function SeleniusHub:CreateSectionTitle(parent, localeKey, text, position)
    local label = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 24), 
        Position = position or UDim2.new(0, 10, 0, 10), 
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Center, -- Centralizado
        Text = text or self:GetText(localeKey),
        Parent = parent
    })
    self:RegisterTheme(label, "TextColor3", "TextPrimary")
    if localeKey then self:RegisterLocale(label, localeKey) end
    return label
end

-- ==================== COMPONENTS ==================== --

function SeleniusHub:CreateToggle(parent, position, localeKey, default, callback, size)
    local frame = Utils:CreateInstance("TextButton", {
        BackgroundColor3 = Theme.Button,
        BackgroundTransparency = 0.3, 
        Size = size or UDim2.new(0, 260, 0, 36),
        Position = position,
        AutoButtonColor = false,
        Text = "",
        Parent = parent
    })
    Utils:AddCorner(frame, 6)
    Utils:AddStroke(frame, Theme.Stroke, 1, 0.5) -- Stroke adicionado
    
    local labelWidth = nil
    if size then
        local w = size.X.Offset or 260
        labelWidth = math.max(0, w - 80)
    end
    local title = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = labelWidth and UDim2.new(0, labelWidth, 1, 0) or UDim2.new(0, 180, 1, 0),
        Font = Enum.Font.GothamMedium, -- Fonte atualizada
        TextSize = 18,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self:GetText(localeKey),
        Parent = frame
    })
    self:RegisterLocale(title, localeKey)
    self:RegisterTheme(title, "TextColor3", "TextPrimary")
    
    local indicatorBg = Utils:CreateInstance("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 18),
        BackgroundColor3 = Theme.IndicatorOff,
        Parent = frame
    })
    Utils:AddCorner(indicatorBg, 9)
    
    local knob = Utils:CreateInstance("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), -- Changed from Theme.Button to White
        Parent = indicatorBg
    })
    Utils:AddCorner(knob, 9)
    local state = default or false
    
    local function UpdateVisual()
        if state then
            Utils:Tween(indicatorBg, AnimConfig, {BackgroundColor3 = Theme.Accent})
            Utils:Tween(knob,        AnimConfig, {Position = UDim2.new(1, -18, 0, 0), BackgroundColor3 = Color3.new(1, 1, 1)}) -- Force White
        else
            Utils:Tween(indicatorBg, AnimConfig, {BackgroundColor3 = Theme.IndicatorOff})
            Utils:Tween(knob,        AnimConfig, {Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.new(1, 1, 1)}) -- Force White
        end
        frame.BackgroundColor3 = Theme.Button
        title.TextColor3 = Theme.TextPrimary
    end
    
    local function SetState(newState)
        state = newState
        UpdateVisual()
        if callback then callback(state) end
    end
    
    self:AddConnection(frame.MouseButton1Click, function() SetState(not state) end)
    self:AddConnection(frame.MouseEnter, function() Utils:Tween(frame, AnimConfig, {BackgroundColor3 = Theme.ButtonHover}) end)
    self:AddConnection(frame.MouseLeave, function() Utils:Tween(frame, AnimConfig, {BackgroundColor3 = Theme.Button}) end)
    
    table.insert(self.ThemeCallbacks, function() UpdateVisual() end)
    self:RegisterSearchable(frame, localeKey)
    
    UpdateVisual()
    return { Frame = frame, SetState = SetState, GetState = function() return state end }
end

function SeleniusHub:CreateCheckbox(parent, position, localeKey, default, callback)
    local frame = Utils:CreateInstance("TextButton", {
        BackgroundColor3 = Theme.Button,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 260, 0, 32), -- Um pouco menor que o toggle
        Position = position,
        AutoButtonColor = false,
        Text = "",
        Parent = parent
    })
    Utils:AddCorner(frame, 6)
    Utils:AddStroke(frame, Theme.Stroke, 1, 0.5)
    
    local box = Utils:CreateInstance("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        BackgroundColor3 = Theme.Secondary,
        Parent = frame
    })
    Utils:AddCorner(box, 4)
    Utils:AddStroke(box, Theme.AccentDark, 1, 0.5)
    
    local check = Utils:CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031094667", -- Checkmark icon garantido
        ImageColor3 = Theme.Secondary, -- BRANCO
        ImageTransparency = 1,
        Parent = box
    })
    
    local title = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self:GetText(localeKey),
        Parent = frame
    })
    self:RegisterLocale(title, localeKey)
    
    local state = default or false
    
    local function UpdateVisual()
        if state then
            Utils:Tween(check, AnimConfig, {ImageTransparency = 0})
            Utils:Tween(box, AnimConfig, {BackgroundColor3 = Theme.Accent})
        else
            Utils:Tween(check, AnimConfig, {ImageTransparency = 1})
            Utils:Tween(box, AnimConfig, {BackgroundColor3 = Theme.Secondary})
        end
    end
    
    frame.MouseButton1Click:Connect(function()
        state = not state
        UpdateVisual()
        if callback then callback(state) end
    end)
    
    table.insert(self.ThemeCallbacks, function()
        frame.BackgroundColor3 = Theme.Button
        title.TextColor3 = Theme.TextPrimary
        check.ImageColor3 = Theme.Secondary
        if not state then
            box.BackgroundColor3 = Theme.Secondary
        else
            box.BackgroundColor3 = Theme.Accent
        end
    end)
    
    UpdateVisual()
    self:RegisterSearchable(frame, localeKey)
    return { Frame = frame, SetState = function(s) state = s; UpdateVisual() end }
end

function SeleniusHub:CreateSlider(parent, position, localeKey, minValue, maxValue, defaultValue, callback, size)
    minValue      = minValue or 0
    maxValue      = maxValue or 100
    defaultValue = math.clamp(defaultValue or minValue, minValue, maxValue)
    local frame = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Button,
        BackgroundTransparency = 0.3,
        Size = size or UDim2.new(0, 260, 0, 52),
        Position = position,
        Parent = parent
    })
    Utils:AddCorner(frame, 6)
    Utils:AddStroke(frame, Theme.Stroke, 1, 0.5)

    local title = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 4),
        Size = UDim2.new(0, 160, 0, 22),
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self:GetText(localeKey),
        Parent = frame
    })
    self:RegisterLocale(title, localeKey)
    self:RegisterTheme(title, "TextColor3", "TextPrimary")
    local valueLabel = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 4),
        Size = UDim2.new(0, 52, 0, 22),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Theme.TextPrimary, -- FIX: Agora Branco
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(math.floor(defaultValue + 0.5)), -- Inicializa como inteiro
        Parent = frame
    })
    self:RegisterTheme(valueLabel, "TextColor3", "TextPrimary")
    local barBg = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.IndicatorOff,
        Position = UDim2.new(0, 8, 0, 30),
        Size = UDim2.new(1, -16, 0, 8),
        Parent = frame
    })
    Utils:AddCorner(barBg, 4)
    local barFill = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = barBg
    })
    Utils:AddCorner(barFill, 4)
    local knob = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Parent = barBg
    })
    -- Utils:AddStroke(knob, Theme.Accent, 1, 0) -- Removed stroke to make it totally white
    Utils:AddCorner(knob, 7)
    local dragging          = false
    local currentValue = defaultValue
    
    local function ApplyVisual(alpha)
        alpha = math.clamp(alpha, 0, 1)
        if dragging then
            barFill.Size  = UDim2.new(alpha, 0, 1, 0)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        else
            Utils:Tween(barFill, SliderTween, {Size = UDim2.new(alpha, 0, 1, 0)})
            Utils:Tween(knob,    SliderTween, {Position = UDim2.new(alpha, 0, 0.5, 0)})
        end
    end
    
    local function SetValue(v)
        v = math.clamp(v, minValue, maxValue)
        v = math.floor(v + 0.5)
        currentValue = v
        local alpha = (v - minValue) / (maxValue - minValue)
        ApplyVisual(alpha)
        valueLabel.Text = string.format("%d", v) 
        if callback then callback(currentValue) end
    end
    
    local function UpdateFromInput(input)
        local pos     = input.Position.X
        local barPos  = barBg.AbsolutePosition.X
        local barSize = barBg.AbsoluteSize.X
        if barSize <= 0 then return end
        local alpha = math.clamp((pos - barPos) / barSize, 0, 1)
        local v = minValue + (maxValue - minValue) * alpha
        SetValue(v)
    end
    
    self:AddConnection(barBg.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateFromInput(input)
        end
    end)
    self:AddConnection(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateFromInput(input)
        end
    end)
    self:AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    task.defer(function() dragging = false SetValue(defaultValue) end)
    
    self:AddConnection(frame.MouseEnter, function() Utils:Tween(frame, AnimConfig, {BackgroundColor3 = Theme.ButtonHover}) end)
    self:AddConnection(frame.MouseLeave, function() Utils:Tween(frame, AnimConfig, {BackgroundColor3 = Theme.Button}) end)
    
    table.insert(self.ThemeCallbacks, function()
        frame.BackgroundColor3 = Theme.Button
        title.TextColor3 = Theme.TextPrimary
        valueLabel.TextColor3 = Theme.TextPrimary
        barBg.BackgroundColor3 = Theme.IndicatorOff
        barFill.BackgroundColor3 = Theme.Accent
    end)
    self:RegisterSearchable(frame, localeKey)
    return { Frame = frame, SetValue = SetValue, GetValue = function() return currentValue end }
end

function SeleniusHub:CreateDropdown(parent, position, localeKey, options, defaultIndex, callback)
    options               = options or {}
    defaultIndex = defaultIndex or 1
    if defaultIndex < 1 or defaultIndex > #options then defaultIndex = 1 end
    
    self.DropdownZCounter = self.DropdownZCounter - 1
    local z = self.DropdownZCounter
    
    local dropdownObj = {}
    local frame = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Button,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 260, 0, 36),
        Position = position,
        Parent = parent,
        ZIndex = z
    })
    Utils:AddCorner(frame, 6)
    Utils:AddStroke(frame, Theme.Stroke, 1, 0.5)

    local title = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self:GetText(localeKey),
        Parent = frame,
        ZIndex = z + 1
    })
    self:RegisterLocale(title, localeKey)
    self:RegisterTheme(title, "TextColor3", "TextPrimary")
    local currentLabel = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 130, 0, 0),
        Size = UDim2.new(0, 90, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        TextColor3 = Theme.TextPrimary, -- FIX: Agora Branco
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = options[defaultIndex] or "",
        Parent = frame,
        ZIndex = z + 1
    })
    self:RegisterTheme(currentLabel, "TextColor3", "TextPrimary")
    local arrow = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.9, 0, 0, 0),
        Size = UDim2.new(0.1, -4, 1, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Theme.TextPrimary,
        Text = "▼",
        Rotation = 0,
        Parent = frame,
        ZIndex = z + 1
    })
    self:RegisterTheme(arrow, "TextColor3", "TextPrimary")
    local clickArea = Utils:CreateInstance("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
        ZIndex = z + 2
    })
    local listHeight = (#options * 26) + 6
    local listFrame = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Secondary,
        Position = UDim2.new(0, 0, 1, 2),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ClipsDescendants = true,
        Parent = frame,
        ZIndex = z + 5
    })
    Utils:AddCorner(listFrame, 6)
    Utils:CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = listFrame
    })
    local selectedIndex = defaultIndex
    local isOpen = false
    dropdownObj.optionButtons = {}
    
    local function CloseDropdown()
        isOpen = false
        Utils:Tween(listFrame, DropdownTween, {Size = UDim2.new(1, 0, 0, 0)})
        Utils:Tween(arrow,      DropdownTween, {Rotation = 0, TextColor3 = Theme.TextPrimary})
        arrow.Text = "▼"
        task.delay(DropdownTween.Time, function() if not isOpen then listFrame.Visible = false end end)
    end
    
    local function OpenDropdown()
        isOpen = true
        if not listFrame.Visible then
            listFrame.Size = UDim2.new(1, 0, 0, 0)
            listFrame.Visible = true
        end
        Utils:Tween(listFrame, DropdownTween, {Size = UDim2.new(1, 0, 0, listHeight)})
        Utils:Tween(arrow,      DropdownTween, {Rotation = 180, TextColor3 = Theme.Accent})
        arrow.Text = "▲"
    end
    
    local function SelectOption(idx)
        selectedIndex = idx
        currentLabel.Text = options[idx] or ""
        if callback then callback(currentLabel.Text, idx) end
        CloseDropdown()
    end
    
    function dropdownObj:UpdateOptions(newOptions)
        for _, btn in ipairs(dropdownObj.optionButtons) do btn:Destroy() end
        dropdownObj.optionButtons = {}
        options = newOptions or {}
        listHeight = (#options * 26) + 6
        
        for i, opt in ipairs(options) do
            local optBtn = Utils:CreateInstance("TextButton", {
                BackgroundColor3 = Theme.Button,
                Size = UDim2.new(1, 0, 0, 24),
                Text = opt,
                Font = Enum.Font.GothamMedium,
                TextSize = 16,
                TextColor3 = Theme.AccentDark,
                AutoButtonColor = false,
                Parent = listFrame,
                ZIndex = z + 6
            })
            Utils:AddCorner(optBtn, 4)
            optBtn.MouseEnter:Connect(function() Utils:Tween(optBtn, AnimConfig, {BackgroundColor3 = Theme.ButtonHover, TextColor3 = Theme.TextPrimary}) end)
            optBtn.MouseLeave:Connect(function() Utils:Tween(optBtn, AnimConfig, {BackgroundColor3 = Theme.Button, TextColor3 = Theme.AccentDark}) end)
            optBtn.MouseButton1Click:Connect(function() SelectOption(i) end)
            dropdownObj.optionButtons[i] = optBtn
        end
        if selectedIndex > #options then 
            selectedIndex = 1 
            currentLabel.Text = options[1] or "" 
        end
    end

    dropdownObj:UpdateOptions(options)
    
    self:AddConnection(clickArea.MouseButton1Click, function() if isOpen then CloseDropdown() else OpenDropdown() end end)
    
    table.insert(self.ThemeCallbacks, function()
        frame.BackgroundColor3 = Theme.Button
        title.TextColor3 = Theme.TextPrimary
        currentLabel.TextColor3 = Theme.TextPrimary
        arrow.TextColor3 = Theme.TextPrimary
        listFrame.BackgroundColor3 = Theme.Secondary
        for _, btn in ipairs(dropdownObj.optionButtons) do
            btn.BackgroundColor3 = Theme.Button
        end
    end)
    self:RegisterSearchable(frame, localeKey)
    return dropdownObj
end

-- ==================== NEW COMPONENTS ==================== --

function SeleniusHub:CreateMultiDropdown(parent, position, localeKey, options, defaultList, callback)
    self.DropdownZCounter = self.DropdownZCounter - 1
    local z = self.DropdownZCounter
    -- FIX: BackgroundColor -> BackgroundColor3
    local frame = Utils:CreateInstance("Frame", {
        BackgroundColor3=Theme.Button, 
        BackgroundTransparency=0.3,
        Size=UDim2.new(0,260,0,36), 
        Position=position, 
        Parent=parent, 
        ZIndex=z
    })
    Utils:AddCorner(frame, 6)
    Utils:AddStroke(frame, Theme.Stroke, 1, 0.5)
    
    -- Ajuste para dar mais espaço ao valor e menos ao título
    local title = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency=1, 
        Position=UDim2.new(0,8,0,0), 
        Size=UDim2.new(0,100,1,0), -- Reduzido
        Font=Enum.Font.GothamMedium, 
        TextSize=18, 
        TextColor3=Theme.TextPrimary, 
        TextXAlignment=Enum.TextXAlignment.Left, 
        Text=self:GetText(localeKey), 
        Parent=frame, 
        ZIndex=z+1
    })
    self:RegisterLocale(title, localeKey); self:RegisterTheme(title, "TextColor3", "TextPrimary")
    
    local disp = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency=1, 
        Position=UDim2.new(0,110,0,0), -- Movido para esquerda
        Size=UDim2.new(1,-120,1,0),    -- Aumentado
        Font=Enum.Font.GothamMedium, 
        TextSize=16, 
        TextColor3=Theme.TextPrimary, -- FIX: Agora Branco
        TextXAlignment=Enum.TextXAlignment.Right, 
        Text="...", 
        TextTruncate = Enum.TextTruncate.AtEnd, -- FIX: Corta com "..."
        Parent=frame, 
        ZIndex=z+1
    })
    self:RegisterTheme(disp, "TextColor3", "TextPrimary")
    
    local btn = Utils:CreateInstance("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", Parent=frame, ZIndex=z+2})
    local listFrame = Utils:CreateInstance("Frame", {BackgroundColor3=Theme.Secondary, Position=UDim2.new(0,0,1,2), Size=UDim2.new(1,0,0,0), Visible=false, Parent=frame, ZIndex=z+5, ClipsDescendants=true})
    Utils:AddCorner(listFrame, 6)
    Utils:CreateInstance("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2), Parent=listFrame})
    Utils:CreateInstance("UIPadding", {PaddingTop=UDim.new(0,2), PaddingBottom=UDim.new(0,2), Parent=listFrame})
    
    local selected = {}
    for _, v in ipairs(defaultList or {}) do selected[v] = true end
    
    local function UpdateText()
        local t = {}
        for k, v in pairs(selected) do if v then table.insert(t, k) end end
        disp.Text = #t>0 and table.concat(t, ", ") or "None"
        if callback then callback(t) end
    end
    UpdateText()
    
    local open = false
    btn.MouseButton1Click:Connect(function()
        open = not open
        listFrame.Visible = true
        Utils:Tween(listFrame, DropdownTween, {Size = UDim2.new(1,0,0, open and (#options*26+6) or 0)})
    end)
    
    for _, opt in ipairs(options) do
        local optBtn = Utils:CreateInstance("TextButton", {
            BackgroundColor3 = Theme.Button, 
            Size = UDim2.new(1,-4,0,24), 
            Text = "", 
            Parent = listFrame, 
            ZIndex=z+6
        })
        Utils:AddCorner(optBtn, 4)
        
        -- Checkbox Visual dentro do MultiDropdown
        local box = Utils:CreateInstance("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 4, 0.5, -8),
            BackgroundColor3 = selected[opt] and Theme.Accent or Theme.Secondary,
            Parent = optBtn,
            ZIndex = z+7
        })
        Utils:AddCorner(box, 4)
        -- NO STROKE
        
        local check = Utils:CreateInstance("ImageLabel", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0.5, -6, 0.5, -6),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6031094667", -- Vzinho
            ImageColor3 = Theme.Secondary,
            ImageTransparency = selected[opt] and 0 or 1,
            Parent = box,
            ZIndex = z+8
        })
        
        local optLabel = Utils:CreateInstance("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 28, 0, 0),
            Size = UDim2.new(1, -28, 1, 0),
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = selected[opt] and Theme.Accent or Theme.AccentDark,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = opt,
            Parent = optBtn,
            ZIndex = z+7
        })

        optBtn.MouseButton1Click:Connect(function()
            selected[opt] = not selected[opt]
            -- Atualiza visual
            optLabel.TextColor3 = selected[opt] and Theme.Accent or Theme.AccentDark
            box.BackgroundColor3 = selected[opt] and Theme.Accent or Theme.Secondary
            check.ImageTransparency = selected[opt] and 0 or 1
            
            UpdateText()
        end)
    end
    
    self:RegisterSearchable(frame, localeKey)
    return { Frame = frame, GetSelection = function() return selected end }
end

function SeleniusHub:CreateColorPicker(parent, position, localeKey, default, callback)
    self.DropdownZCounter = self.DropdownZCounter - 1
    local z = self.DropdownZCounter
    local frame = Utils:CreateInstance("Frame", {
        BackgroundColor3=Theme.Button, 
        BackgroundTransparency=0.3,
        Size=UDim2.new(0,260,0,36), 
        Position=position, 
        Parent=parent, 
        ZIndex=z
    })
    Utils:AddCorner(frame, 6)
    Utils:AddStroke(frame, Theme.Stroke, 1, 0.5)
    self:RegisterTheme(frame, "BackgroundColor3", "Button")
    
    local lbl = Utils:CreateInstance("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,8,0,0), Size=UDim2.new(1,-50,1,0), Font=Enum.Font.GothamMedium, TextSize=18, TextColor3=Theme.TextPrimary, TextXAlignment=Enum.TextXAlignment.Left, Text=self:GetText(localeKey), Parent=frame, ZIndex=z+1})
    self:RegisterLocale(lbl, localeKey); self:RegisterTheme(lbl, "TextColor3", "TextPrimary")
    
    local currentColor = default or Color3.fromRGB(255, 255, 255)
    local prev = Utils:CreateInstance("TextButton", {BackgroundColor3=currentColor, Size=UDim2.new(0,30,0,20), Position=UDim2.new(1,-40,0.5,-10), Text="", AutoButtonColor=false, Parent=frame, ZIndex=z+1})
    Utils:AddCorner(prev, 4)
    Utils:AddStroke(prev, Theme.Stroke, 1, 0.5)
    
    -- Main Picker Frame
    local pickerFrame = Utils:CreateInstance("Frame", {BackgroundColor3=Theme.Secondary, Position=UDim2.new(0,0,1,2), Size=UDim2.new(1,0,0,0), Visible=false, Parent=frame, ZIndex=z+5, ClipsDescendants=true})
    Utils:AddCorner(pickerFrame, 6)
    Utils:AddStroke(pickerFrame, Theme.Stroke, 1, 0.5)
    
    -- Content Container inside picker
    local pickerContent = Utils:CreateInstance("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=pickerFrame, Visible=false})
    
    -- Sat/Val Map
    local svMap = Utils:CreateInstance("ImageButton", {Size=UDim2.new(0, 240, 0, 120), Position=UDim2.new(0,10,0,10), BackgroundColor3=Color3.fromHSV(1,1,1), Image="rbxassetid://4155801252", AutoButtonColor=false, Parent=pickerContent, ZIndex=z+6})
    
    -- Knob Sat/Val (Bolinha)
    local svKnob = Utils:CreateInstance("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0,
        Parent = svMap,
        ZIndex = z+7
    })
    Utils:AddCorner(svKnob, 10)
    Utils:AddStroke(svKnob, Color3.new(0,0,0), 1, 0)
    -- REMOVED KNOB STROKE

    -- Hue Bar
    local hueBar = Utils:CreateInstance("ImageButton", {Size=UDim2.new(0, 240, 0, 15), Position=UDim2.new(0,10,0,140), BackgroundColor3=Color3.new(1,1,1), AutoButtonColor=false, Parent=pickerContent, ZIndex=z+6})
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
    })
    hueGradient.Parent = hueBar
    
    -- Knob Hue (Marcador)
    local hueKnob = Utils:CreateInstance("Frame", {
        Size = UDim2.new(0, 6, 1, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0,0,0.5,0),
        BackgroundColor3 = Color3.new(1,1,1),
        Parent = hueBar,
        ZIndex = z+7
    })
    Utils:AddCorner(hueKnob, 4)
    Utils:AddStroke(hueKnob, Color3.new(0,0,0), 1, 0)
    -- REMOVED KNOB STROKE

    -- RGB Inputs
    local rgbBox = Utils:CreateInstance("Frame", {BackgroundTransparency=1, Position=UDim2.new(0,10,0,165), Size=UDim2.new(0,240,0,25), Parent=pickerContent, ZIndex=z+6})
    local rInput = Utils:CreateInstance("TextBox", {BackgroundColor3=Theme.Button, Size=UDim2.new(0,70,1,0), Position=UDim2.new(0,0,0,0), Text=math.floor(currentColor.R*255), TextColor3=Theme.TextPrimary, Parent=rgbBox, ZIndex=z+7}); Utils:AddCorner(rInput,4); Utils:AddStroke(rInput, Theme.Stroke, 1, 0.5)
    local gInput = Utils:CreateInstance("TextBox", {BackgroundColor3=Theme.Button, Size=UDim2.new(0,70,1,0), Position=UDim2.new(0.5,-35,0,0), Text=math.floor(currentColor.G*255), TextColor3=Theme.TextPrimary, Parent=rgbBox, ZIndex=z+7}); Utils:AddCorner(gInput,4); Utils:AddStroke(gInput, Theme.Stroke, 1, 0.5)
    local bInput = Utils:CreateInstance("TextBox", {BackgroundColor3=Theme.Button, Size=UDim2.new(0,70,1,0), Position=UDim2.new(1,-70,0,0), Text=math.floor(currentColor.B*255), TextColor3=Theme.TextPrimary, Parent=rgbBox, ZIndex=z+7}); Utils:AddCorner(bInput,4); Utils:AddStroke(bInput, Theme.Stroke, 1, 0.5)
    
    -- Logic Vars
    local h, s, v = Color3.toHSV(currentColor)
    local draggingHue, draggingSV = false, false
    
    local function UpdateVisuals()
        -- Atualiza posições dos knobs
        svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
        hueKnob.Position = UDim2.new(1 - h, 0, 0.5, 0) -- H invertido para bater com gradiente padrão
        
        svMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        prev.BackgroundColor3 = currentColor
        
        if not rInput:IsFocused() then rInput.Text = math.floor(currentColor.R*255) end
        if not gInput:IsFocused() then gInput.Text = math.floor(currentColor.G*255) end
        if not bInput:IsFocused() then bInput.Text = math.floor(currentColor.B*255) end
    end

    local function UpdateColor()
        currentColor = Color3.fromHSV(h, s, v)
        UpdateVisuals()
        if callback then callback(currentColor) end
    end
    
    -- Inicializa visual
    UpdateVisuals()

    local function UpdateSV(input)
        local rPos = input.Position.X - svMap.AbsolutePosition.X
        local rPosY = input.Position.Y - svMap.AbsolutePosition.Y
        s = math.clamp(rPos / svMap.AbsoluteSize.X, 0, 1)
        v = 1 - math.clamp(rPosY / svMap.AbsoluteSize.Y, 0, 1)
        UpdateColor()
    end
    
    local function UpdateHue(input)
        local rPos = input.Position.X - hueBar.AbsolutePosition.X
        h = 1 - math.clamp(rPos / hueBar.AbsoluteSize.X, 0, 1) -- Inverted standard Hue
        UpdateColor()
    end
    
    -- Connections
    svMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true; UpdateSV(input) end end)
    hueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true; UpdateHue(input) end end)
    
    self:AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false; draggingHue = false end
    end)
    
    self:AddConnection(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingSV then UpdateSV(input) end
            if draggingHue then UpdateHue(input) end
        end
    end)
    
    -- Manual Input Logic
    local function ManualUpdate()
        local r, g, b = tonumber(rInput.Text) or 0, tonumber(gInput.Text) or 0, tonumber(bInput.Text) or 0
        currentColor = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
        h, s, v = Color3.toHSV(currentColor)
        UpdateColor()
    end
    rInput.FocusLost:Connect(ManualUpdate)
    gInput.FocusLost:Connect(ManualUpdate)
    bInput.FocusLost:Connect(ManualUpdate)
    
    -- Open/Close Logic
    local open = false
    prev.MouseButton1Click:Connect(function()
        open = not open
        pickerFrame.Visible = true
        pickerContent.Visible = open
        Utils:Tween(pickerFrame, DropdownTween, {Size = UDim2.new(1,0,0, open and 200 or 0)})
    end)
    
    self:RegisterSearchable(frame, localeKey)
    return { Frame = frame, SetColor = function(c) currentColor = c; h,s,v = Color3.toHSV(c); UpdateColor() end, GetColor = function() return currentColor end }
end

-- ========================================================= --

function SeleniusHub:CreateKeybindControl(parent, position)
    local frame = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Button,
        Size = UDim2.new(0, 260, 0, 40),
        Position = position,
        Parent = parent
    })
    Utils:AddCorner(frame, 6)
    Utils:AddStroke(frame, Theme.Stroke, 1, 0.5)
    local title = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self:GetText("label_keybind"),
        Parent = frame
    })
    self:RegisterLocale(title, "label_keybind")
    self:RegisterTheme(title, "TextColor3", "TextPrimary")
    local btn = Utils:CreateInstance("TextButton", {
        BackgroundColor3 = Theme.ButtonHover,
        Size = UDim2.new(0, 110, 0, 26),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Theme.TextPrimary,
        Text = "[" .. self:GetKeybindName() .. "]",
        AutoButtonColor = false,
        Parent = frame
    })
    Utils:AddCorner(btn, 13)
    self:RegisterTheme(btn, "TextColor3", "TextPrimary")
    local btnScale = Instance.new("UIScale")
    btnScale.Scale = 1
    btnScale.Parent = btn
    self.KeybindButtonLabel = btn
    self:AddConnection(btn.MouseButton1Click, function()
        self.CapturingKeybind = true
        btn.Text = "..."
        TweenService:Create(btnScale, PopTween, {Scale = 1.15}):Play()
        task.delay(PopTween.Time, function() TweenService:Create(btnScale, PopReturnTween, {Scale = 1}):Play() end)
    end)
    self:AddConnection(btn.MouseEnter, function() Utils:Tween(btn, AnimConfig, {BackgroundColor3 = Theme.AccentDark}) end)
    self:AddConnection(btn.MouseLeave, function() Utils:Tween(btn, AnimConfig, {BackgroundColor3 = Theme.ButtonHover}) end)
    
    table.insert(self.ThemeCallbacks, function()
        frame.BackgroundColor3 = Theme.Button
        btn.BackgroundColor3 = Theme.ButtonHover
        title.TextColor3 = Theme.TextPrimary
        btn.TextColor3 = Theme.TextPrimary
    end)
    
    return frame
end

function SeleniusHub:RegisterSearchable(frame, localeKey)
    if localeKey then
        table.insert(self.Searchables, {Frame = frame, KeyLocale = localeKey})
    end
end

function SeleniusHub:SetupSearch()
    if not self.SearchBox then return end
    self:AddConnection(self.SearchBox:GetPropertyChangedSignal("Text"), function()
        local query = string.lower(self.SearchBox.Text or "")
        -- SEARCH GLOBAL (Procura em todas as abas)
        for _, item in ipairs(self.Searchables) do
            local text = (self:GetText(item.KeyLocale) or ""):lower()
            if query == "" then
                item.Frame.Visible = true
            else
                if string.find(text, query, 1, true) then
                    item.Frame.Visible = true
                else
                    item.Frame.Visible = false
                end
            end
        end
    end)
end

function SeleniusHub:CreateUI()
    local UI = {}
    
    local guiName = RandomString(12) 
    -- FIX: DisplayOrder 10 para ficar abaixo do Loading/Key
    UI.ScreenGui = Utils:CreateInstance("ScreenGui", { 
        Name = guiName, 
        ResetOnSpawn = false, 
        Parent = GetSecureParent(),
        DisplayOrder = 10 
    })
    
    UI.MainFrame = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Background,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 616, 0, 505),
        ClipsDescendants = false, -- Sombra via UIStroke
        Parent = UI.ScreenGui,
        -- FIX: Começa invisível
        Visible = false 
    })
    
    -- MODIFICAÇÃO: Acrylic atualizado com UIStroke
    local updateBlur, stroke = Acrylic.Enable(UI.MainFrame)
    self.BlurFunction = updateBlur
    self.MainStroke = stroke
    
    Utils:AddCorner(UI.MainFrame, 8)
    self:RegisterTheme(UI.MainFrame, "BackgroundColor3", "Background")
    self.DefaultSize = UI.MainFrame.Size
    self.SavedSize    = UI.MainFrame.Size
    self.StoredSize   = UI.MainFrame.Size
    self.StoredPos    = UI.MainFrame.Position
    
    if self.LoadedSize then
        local w = math.max(self.MinWidth,  self.LoadedSize.Width)
        local h = math.max(self.MinHeight, self.LoadedSize.Height)
        UI.MainFrame.Size = UDim2.new(0, w, 0, h)
        self.SavedSize    = UI.MainFrame.Size
        self.StoredSize   = UI.MainFrame.Size
    end
    
    UI.TitleBar = Utils:CreateInstance("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 46), Parent = UI.MainFrame, ZIndex=2 })
    
    UI.Logo = Utils:CreateInstance("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(0, 8, 0, 10),
        Image = GetIcon(IconPaths.Logo),
        ImageColor3 = Theme.TextPrimary, -- Adaptado para Light Mode
        Parent = UI.TitleBar
    })
    
    -- Título com ANIMAÇÃO NOVA (GRADIENT ROTATION LOOP)
    UI.TitleLabel = Utils:CreateInstance("TextLabel", {
        Text = "Selenius Hub",
        Font = Enum.Font.GothamBold,
        TextSize = 20, -- Reduzido para ficar "menos" (menor/minimalista)
        TextColor3 = Theme.TextPrimary,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(0, 350, 1, 0), 
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = UI.TitleBar,
        ClipsDescendants = true 
    })
    
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Rotation = 0
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Theme.Accent),
        ColorSequenceKeypoint.new(0.50, Theme.TextPrimary),
        ColorSequenceKeypoint.new(1.00, Theme.Accent)
    })
    titleGradient.Parent = UI.TitleLabel
    
    task.spawn(function()
        while true do
            -- Ciclo de rotação suave para efeito de "fluxo"
            for i = 0, 360, 2 do
                titleGradient.Rotation = i
                task.wait(0.02)
            end
        end
    end)
    
    UI.SearchBox = Utils:CreateInstance("TextBox", {
        BackgroundColor3 = Theme.Button,
        Position = UDim2.new(0, 200, 0, 10), 
        Size = UDim2.new(0, 160, 0, 26),
        PlaceholderText = self:GetText("label_search"),
        Text = "",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Theme.TextPrimary,
        PlaceholderColor3 = Theme.AccentDark,
        ClearTextOnFocus = true,
        Parent = UI.TitleBar
    })
    Utils:AddCorner(UI.SearchBox, 6)
    Utils:AddStroke(UI.SearchBox, Theme.Stroke, 1, 0.5)
    self:RegisterTheme(UI.SearchBox, "TextColor3", "TextPrimary")
    self:RegisterTheme(UI.SearchBox, "PlaceholderColor3", "AccentDark")
    
    table.insert(self.ThemeCallbacks, function()
        UI.SearchBox.BackgroundColor3 = Theme.Button
    end)
    
    -- REMOVED UI STROKE
    self.SearchBox = UI.SearchBox
    
    UI.MinimizeBtn = Utils:CreateInstance("TextButton", {
        Text = "-", Font = Enum.Font.GothamBold, TextSize = 24, TextColor3 = Theme.TextPrimary,
        BackgroundColor3 = Theme.Button, Size = UDim2.new(0, 29, 0, 29), Position = UDim2.new(1, -75, 0, 8),
        Parent = UI.TitleBar, AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
    })
    Utils:AddCorner(UI.MinimizeBtn, 6)
    self:RegisterTheme(UI.MinimizeBtn, "TextColor3", "TextPrimary")
    self:RegisterTheme(UI.MinimizeBtn, "BackgroundColor3", "Button")
    
    UI.CloseBtn = Utils:CreateInstance("TextButton", {
        Text = "X", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.TextPrimary,
        BackgroundColor3 = Theme.Button, Size = UDim2.new(0, 29, 0, 29), Position = UDim2.new(1, -40, 0, 8),
        Parent = UI.TitleBar, AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
    })
    Utils:AddCorner(UI.CloseBtn, 6)
    self:RegisterTheme(UI.CloseBtn, "TextColor3", "TextPrimary")
    self:RegisterTheme(UI.CloseBtn, "BackgroundColor3", "Button")
    
    table.insert(self.ThemeCallbacks, function()
        UI.MinimizeBtn.BackgroundColor3 = Theme.Button
        UI.CloseBtn.BackgroundColor3 = Theme.Button
    end)
    
    UI.Separator = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Separator, Position = UDim2.new(0, 0, 0, 46), Size = UDim2.new(1, 0, 0, 2), Parent = UI.MainFrame, ZIndex=2
    })
    self:RegisterTheme(UI.Separator, "BackgroundColor3", "Separator")
    UI.ContentContainer = Utils:CreateInstance("Frame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 48), Size = UDim2.new(1, 0, 1, -48), Parent = UI.MainFrame, ZIndex=2
    })
    UI.Sidebar = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Secondary, BackgroundTransparency = 0.5, Position = UDim2.new(0, 7, 0, 7), Size = UDim2.new(0, 140, 1, -14), Parent = UI.ContentContainer
    })
    Utils:AddCorner(UI.Sidebar, 6)
    Utils:AddStroke(UI.Sidebar, Theme.Stroke, 1, 0.5) -- Stroke adicionado
    self:RegisterTheme(UI.Sidebar, "BackgroundColor3", "Secondary")
    UI.SidebarLayout = Utils:CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = UI.Sidebar
    })
    Utils:CreateInstance("UIPadding", { PaddingTop = UDim.new(0, 10), Parent = UI.Sidebar })
    UI.VerticalSeparator = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Separator, Position = UDim2.new(0, 153, 0, 0), Size = UDim2.new(0, 2, 1, 0), Parent = UI.ContentContainer
    })
    self:RegisterTheme(UI.VerticalSeparator, "BackgroundColor3", "Separator")
    UI.PagesContainer = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.Secondary, 
        BackgroundTransparency = 0.5, -- TRANSPARÊNCIA NAS PÁGINAS
        Position = UDim2.new(0, 158, 0, 7), 
        Size = UDim2.new(1, -165, 1, -14), 
        ClipsDescendants = true, 
        Parent = UI.ContentContainer
    })
    Utils:AddCorner(UI.PagesContainer, 6)
    Utils:AddStroke(UI.PagesContainer, Theme.Stroke, 1, 0.5) -- Stroke adicionado
    self:RegisterTheme(UI.PagesContainer, "BackgroundColor3", "Secondary")
    
    UI.ResizeHandle = Utils:CreateInstance("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -6, 1, -6), Size = UDim2.new(0, 18, 0, 18), ZIndex = 10, Parent = UI.MainFrame
    })
    self.ResizeDots = {}
    local dots = {{offX = -3, offY = -3}, {offX = -7, offY = -3}, {offX = -11, offY = -3}, {offX = -3, offY = -7}, {offX = -7, offY = -7}, {offX = -3, offY = -11}}
    for _, d in ipairs(dots) do
        local dot = Utils:CreateInstance("Frame", {
            BackgroundColor3 = Theme.Separator, Size = UDim2.new(0, 3, 0, 3), AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, d.offX, 1, d.offY), ZIndex = 11, Parent = UI.ResizeHandle
        })
        table.insert(self.ResizeDots, dot)
        self:RegisterTheme(dot, "BackgroundColor3", "Separator")
    end
    self.UI = UI
end

function SeleniusHub:CreateTabButton(id, localeKey, iconKey)
    local btn = Utils:CreateInstance("TextButton", {
        Text = "", Font = Enum.Font.GothamMedium, TextSize = 16, TextColor3 = Theme.AccentDark,
        BackgroundColor3 = Theme.Button, Size = UDim2.new(1, -10, 0, 44), AutoButtonColor = false, Parent = self.UI.Sidebar
    })
    Utils:AddCorner(btn, 6)
    local icon = Utils:CreateInstance("ImageLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 8, 0.5, -10),
        Image = GetIcon(IconPaths[iconKey] or ""), ImageColor3=Theme.AccentDark, Parent = btn
    })
    local label = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.AccentDark, TextXAlignment = Enum.TextXAlignment.Left,
        Text = self:GetText(localeKey), Parent = btn
    })
    self:RegisterLocale(label, localeKey)
    local indicator = Utils:CreateInstance("Frame", {
        BackgroundColor3 = Theme.IndicatorOff, Size = UDim2.new(0, 5, 1, 0), Position = UDim2.new(0, 0, 0, 0), Parent = btn
    })
    
    self:AddConnection(btn.MouseEnter, function() Utils:Tween(btn, AnimConfig, {BackgroundColor3 = Theme.ButtonHover}) end)
    self:AddConnection(btn.MouseLeave, function() if self.CurrentPage ~= id then Utils:Tween(btn, AnimConfig, {BackgroundColor3 = Theme.Button}) end end)
    self:AddConnection(btn.MouseButton1Click, function() self:SwitchPage(id) end)
    
    table.insert(self.ThemeCallbacks, function()
        local isSelected = (self.CurrentPage == id)
        if isSelected then
            indicator.BackgroundColor3 = Theme.IndicatorOn
            btn.BackgroundColor3 = Theme.ButtonHover
            label.TextColor3 = Theme.Accent
            icon.ImageColor3 = Theme.Accent
        else
            indicator.BackgroundColor3 = Theme.IndicatorOff
            btn.BackgroundColor3 = Theme.Button
            label.TextColor3 = Theme.AccentDark
            icon.ImageColor3 = Theme.AccentDark
        end
    end)
    
    return btn, indicator, label
end

function SeleniusHub:AddPage(id, localeKey, iconKey)
    if self.Pages[id] then return end
    local page = Instance.new("ScrollingFrame")
    page.Name = RandomString(8)
    page.BackgroundColor3 = Theme.Secondary
    page.BackgroundTransparency = 0.6 -- Mais Transparente
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.Parent = self.UI.PagesContainer
    
    page.ScrollBarThickness = 2 
    page.ScrollBarImageColor3 = Theme.Accent
    page.BorderSizePixel = 0
    
    self:RegisterTheme(page, "ScrollBarImageColor3", "Accent")
    page.CanvasSize = UDim2.new(0, 0, 0, 1200)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Utils:AddCorner(page, 6)
    self:RegisterTheme(page, "BackgroundColor3", "Secondary")
    local btn, indicator, label = self:CreateTabButton(id, localeKey, iconKey)
    self.Tabs[id] = { Button = btn, Indicator = indicator, Label = label }
    self.Pages[id] = page
    local scroller = page
    
    if id == "Home" then
        self:CreateSectionTitle(scroller, "section_home", "Informações")
        
        local infoContainer = Utils:CreateInstance("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 200), Position = UDim2.new(0, 20, 0, 60), Parent = scroller
        })
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.Parent = infoContainer
        
        -- Título
        local homeTitle = Utils:CreateInstance("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold, TextSize = 24, TextColor3 = Theme.Accent, 
            TextXAlignment = Enum.TextXAlignment.Left, Text = self:GetText("label_home_title"), Parent = infoContainer
        })
        self:RegisterTheme(homeTitle, "TextColor3", "Accent")
        
        -- Status Row (Horizontal Layout)
        local statusRow = Utils:CreateInstance("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Parent = infoContainer })
        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rowLayout.Padding = UDim.new(0, 8)
        rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        rowLayout.Parent = statusRow
        
        -- Label "Status:"
        local statusLabel = Utils:CreateInstance("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(0, 50, 1, 0),
            Font = Enum.Font.GothamMedium, TextSize = 18, TextColor3 = Theme.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left, Text = self:GetText("label_status"), Parent = statusRow
        })
        self:RegisterTheme(statusLabel, "TextColor3", "TextPrimary")
        
        -- Text "Estável"
        local statusText = Utils:CreateInstance("TextLabel", {
            BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0),
            Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Accent,
            Text = "Estável", Parent = statusRow
        })
        
        -- Bolinha (Dot) - AGORA DEPOIS DO TEXTO
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 10, 0, 10)
        dot.BackgroundColor3 = Theme.Accent
        dot.Parent = statusRow
        Utils:AddCorner(dot, 10)
        
        -- Créditos
        local credit = Utils:CreateInstance("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24),
            Font = Enum.Font.GothamMedium, TextSize = 16, TextColor3 = Theme.AccentDark, 
            TextXAlignment = Enum.TextXAlignment.Left, Text = self:GetText("label_home_credit"), Parent = infoContainer
        })
        self:RegisterTheme(credit, "TextColor3", "AccentDark")
    end
end

-- POPULATE EXAMPLES (Added functions to fill tabs)
function SeleniusHub:PopulateCombat()
    local page = self.Pages["Combat"]
    if not page then return end
    
    -- Seção 1: Topo
    self:CreateSectionTitle(page, "section_combat", nil, UDim2.new(0, 10, 0, 10))
    
    self:CreateToggle(page, UDim2.new(0, 10, 0, 50), "Enable Aimbot", false, function(s) print("Aimbot:", s) end)
    self:CreateCheckbox(page, UDim2.new(0, 10, 0, 90), "Silent Aim", true, function(s) print("Silent:", s) end)
    
    self:CreateSlider(page, UDim2.new(0, 10, 0, 130), "FOV Radius", 0, 500, 150, function(v) print("FOV:", v) end)
    
    -- Seção 2: Abaixo do Slider (Posição Ajustada)
    self:CreateSectionTitle(page, nil, "Target Selection", UDim2.new(0, 10, 0, 190))
    
    self:CreateDropdown(page, UDim2.new(0, 10, 0, 230), "Target Part", {"Head", "Torso", "Random"}, 1, function(opt) print("Target:", opt) end)
end

function SeleniusHub:PopulateVisuals()
    local page = self.Pages["Visuals"]
    if not page then return end
    
    self:CreateSectionTitle(page, "section_visuals", nil, UDim2.new(0, 10, 0, 10))
    
    self:CreateToggle(page, UDim2.new(0, 10, 0, 50), "Enable ESP", false, function(s) end)
    
    -- NEW: PRO COLOR PICKER
    self:CreateColorPicker(page, UDim2.new(0, 10, 0, 90), "ESP Color", Color3.fromRGB(255, 0, 0), function(col) 
        print("Color Picked:", col) 
    end)
    
    -- NEW: MULTI DROPDOWN
    self:CreateMultiDropdown(page, UDim2.new(0, 10, 0, 130), "ESP Features", {"Box", "Name", "Distance", "Health", "Skeleton"}, {"Box", "Name"}, function(list)
        print("Selected ESP:", table.concat(list, ", "))
    end)
end

function SeleniusHub:PopulatePlayer()
    local page = self.Pages["Player"]
    if not page then return end
    
    self:CreateSectionTitle(page, "section_player", nil, UDim2.new(0, 10, 0, 10))
    
    self:CreateSlider(page, UDim2.new(0, 10, 0, 50), "WalkSpeed", 16, 200, 16, function(v) 
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end)
    
    self:CreateSlider(page, UDim2.new(0, 10, 0, 110), "JumpPower", 50, 500, 50, function(v) 
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end)
    
    self:CreateButton(page, UDim2.new(0, 10, 0, 170), "Respawn Character", function()
        if LocalPlayer and LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
    end)
end

function SeleniusHub:SwitchPage(id)
    if self.CurrentPage == id then return end
    if self.CurrentPage then
        local oldTab = self.Tabs[self.CurrentPage]
        if oldTab then
            oldTab.Indicator.BackgroundColor3 = Theme.IndicatorOff
            Utils:Tween(oldTab.Button, AnimConfig, {BackgroundColor3 = Theme.Button})
            Utils:Tween(oldTab.Label, AnimConfig, {TextColor3 = Theme.AccentDark})
        end
        local oldPage = self.Pages[self.CurrentPage]
        if oldPage then 
            oldPage.Visible = false 
        end
    end
    local newTab = self.Tabs[id]
    if newTab then
        newTab.Indicator.BackgroundColor3 = Theme.IndicatorOn
        Utils:Tween(newTab.Button, AnimConfig, {BackgroundColor3 = Theme.ButtonHover})
        Utils:Tween(newTab.Label, AnimConfig, {TextColor3 = Theme.Accent})
    end
    local newPage = self.Pages[id]
    if newPage then
        newPage.Visible = true
        -- Nova Animação: Slide Up + Fade (Simulado via posição)
        newPage.Position = UDim2.new(0, 0, 0, 20) -- Começa um pouco em baixo
        newPage.BackgroundTransparency = 1 
        -- Tween
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        Utils:Tween(newPage, tweenInfo, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
    end
    self.CurrentPage = id
end

function SeleniusHub:IsVisible()
    return self.UI and self.UI.MainFrame.Visible
end

function SeleniusHub:SetVisible(visible, animated)
    if not self.UI then return end
    if self.VisibilityAnimating then return end
    local frame = self.UI.MainFrame
    if visible then
        if frame.Visible and not animated then return end
        frame.Visible = true
        
        if self.BlurFunction then self.BlurFunction(true) end
        
        -- FIX: ALWAYS RESET TO CENTER
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local size = self.StoredSize or self.SavedSize or self.DefaultSize
        -- Center Position: (0.5, 0, 0.5, 0)
        local pos  = UDim2.new(0.5, 0, 0.5, 0) 
        
        if animated then
            self.VisibilityAnimating = true
            frame.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 0)
            frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + size.Y.Offset / 2)
            
            -- FIX ANIMAÇÃO ABERTURA: Liga Clips durante animação
            frame.ClipsDescendants = true
            
            -- QUINT OUT = Mais suave e fluido na entrada
            Utils:Tween(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = size, Position = pos}).Completed:Connect(function() 
                self.VisibilityAnimating = false 
                frame.ClipsDescendants = false -- Desliga Clips para a sombra aparecer
            end)
        else
            frame.Size = size
            frame.Position = pos
            frame.ClipsDescendants = false
        end
    else
        if not frame.Visible then return end
        
        if self.BlurFunction then self.BlurFunction(false) end
        
        local size = frame.Size
        local pos  = frame.Position
        self.StoredSize = size
        self.StoredPos  = pos
        if animated then
            self.VisibilityAnimating = true
            local endPos = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + size.Y.Offset / 2)
            
            -- FIX ANIMAÇÃO FECHAMENTO: Liga Clips para não vazar conteúdo
            frame.ClipsDescendants = true
            
            -- QUINT IN = Saída rápida e limpa
            Utils:Tween(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 0), Position = endPos}).Completed:Connect(function() 
                frame.Visible = false 
                frame.Size = size 
                frame.Position = pos 
                self.VisibilityAnimating = false 
                frame.ClipsDescendants = false -- Reseta estado
            end)
        else
            frame.Visible = false
        end
    end
end

function SeleniusHub:OnKeybindChanged()
    local name = self:GetKeybindName()
    if self.KeybindButtonLabel then self.KeybindButtonLabel.Text = "[" .. name .. "]" end
end

function SeleniusHub:SetupKeybindSystem()
    self:AddConnection(UserInputService.InputBegan, function(input, gp)
        if gp or UserInputService:GetFocusedTextBox() then return end
        
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if self.CapturingKeybind then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                self.Keybind = input.KeyCode
                self.CapturingKeybind = false
                self:OnKeybindChanged()
            end
            return
        end
        if self.Keybind and input.KeyCode == self.Keybind then
            self:SetVisible(not self:IsVisible(), true)
            return
        end
    end)
end

function SeleniusHub:SetupMobileSupport()
    if self.IsMobile then
        local mobileBtn = Utils:CreateInstance("ImageButton", {
            Name = "SeleniusMobileButton",
            Image = IconPaths.Logo,
            BackgroundTransparency = 0.5,
            BackgroundColor3 = Theme.Background,
            Position = UDim2.new(0.9, -50, 0.1, 0),
            Size = UDim2.new(0, 50, 0, 50),
            Parent = self.UI.ScreenGui
        })
        Utils:AddCorner(mobileBtn, 12)
        
        local dragging, dragStart, startPos
        mobileBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mobileBtn.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        -- Se foi apenas um clique rápido (não arrastou muito), alterna a UI
                        if (input.Position - dragStart).Magnitude < 10 then
                            self:SetVisible(not self:IsVisible(), true)
                        end
                    end
                end)
            end
        end)
        
        mobileBtn.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                mobileBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
end

function SeleniusHub:SetupSmoothDrag()
    local dragging = false
    local dragInput, dragStart, startPos
    local frame = self.UI.MainFrame
    
    self:AddConnection(self.UI.TitleBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self:AddConnection(self.UI.TitleBar.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    self:AddConnection(RunService.RenderStepped, function(dt)
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            -- REVERTIU: Permite arrastar para qualquer lugar (sem clamp)
            local targetX = startPos.X.Offset + delta.X
            local targetY = startPos.Y.Offset + delta.Y
            
            frame.Position = UDim2.new(
                startPos.X.Scale,
                Utils:Lerp(frame.Position.X.Offset, targetX, 0.25),
                startPos.Y.Scale,
                Utils:Lerp(frame.Position.Y.Offset, targetY, 0.25)
            )
            self.StoredPos = frame.Position
        end
    end)
end

function SeleniusHub:SetupResizing()
    local handle = self.UI.ResizeHandle
    local frame  = self.UI.MainFrame
    local resizing = false
    local dragStart
    local startSize
    self:AddConnection(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.Minimized then return end
            resizing  = true
            dragStart = input.Position
            startSize = frame.Size
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    resizing = false 
                    conn:Disconnect()
                end
            end)
        end
    end)
    self:AddConnection(UserInputService.InputChanged, function(input)
        if not resizing or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = input.Position - dragStart
        local newW  = math.max(self.MinWidth,  startSize.X.Offset + delta.X)
        local newH  = math.max(self.MinHeight, startSize.Y.Offset + delta.Y)
        frame.Size    = UDim2.new(0, newW, 0, newH)
        self.SavedSize  = frame.Size
        self.StoredSize = frame.Size
    end)
    self:AddConnection(handle.MouseEnter, function() for _, dot in ipairs(self.ResizeDots) do Utils:Tween(dot, AnimConfig, {BackgroundColor3 = Theme.Accent}) end end)
    self:AddConnection(handle.MouseLeave, function() for _, dot in ipairs(self.ResizeDots) do Utils:Tween(dot, AnimConfig, {BackgroundColor3 = Theme.Separator}) end end)
end

function SeleniusHub:SetupButtons()
    local UI = self.UI
    
    self:AddConnection(UI.CloseBtn.MouseButton1Click, function() self:SetVisible(false, true) end)
    self:AddConnection(UI.MinimizeBtn.MouseButton1Click, function()
        local frame = UI.MainFrame
        if self.Minimized then
            self.Minimized = false
            local targetSize = self.SavedSize or self.DefaultSize
            
            -- Lógica Avançada de Correção de Posição (Smart Boundary Check)
            local viewport = Camera.ViewportSize
            local halfHeight = targetSize.Y.Offset / 2
            
            -- Posição Y absoluta atual do centro
            local currentAbsY = (viewport.Y * frame.Position.Y.Scale) + frame.Position.Y.Offset
            
            -- Previsão das bordas ao abrir
            local futureTop = currentAbsY - halfHeight
            local futureBottom = currentAbsY + halfHeight
            
            local finalYOffset = frame.Position.Y.Offset
            
            -- Se for sair pelo topo (ex: Topbar do Roblox ou limite da tela)
            if futureTop < 10 then 
                local correction = 10 - futureTop
                finalYOffset = finalYOffset + correction
            -- Se for sair por baixo
            elseif futureBottom > (viewport.Y - 10) then
                local correction = (viewport.Y - 10) - futureBottom
                finalYOffset = finalYOffset + correction
            end
            
            -- Executa a animação fluida (Tamanho + Posição simultaneamente)
            Utils:Tween(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = targetSize,
                Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, finalYOffset)
            })
            
            task.delay(0.1, function() 
                UI.ContentContainer.Visible = true
                UI.Separator.Visible        = true 
            end)
        else
            self.Minimized = true
            self.SavedSize = frame.Size
            
            UI.ContentContainer.Visible = false 
            UI.Separator.Visible        = false
            
            Utils:Tween(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, frame.Size.X.Offset, 0, self.MinimizedHeight)})
        end
    end)
end

function SeleniusHub:CreateButton(parent, position, localeKey, callback)
    local frame = Utils:CreateInstance("TextButton", {
        BackgroundColor3 = Theme.Button,
        Size = UDim2.new(0, 260, 0, 36),
        Position = position,
        AutoButtonColor = false,
        Text = "",
        Parent = parent
    })
    Utils:AddCorner(frame, 6)
    
    local title = Utils:CreateInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamMedium, -- Modernizado
        TextSize = 18,
        TextColor3 = Theme.TextPrimary,
        Text = self:GetText(localeKey),
        Parent = frame
    })
    self:RegisterLocale(title, localeKey)
    self:RegisterTheme(title, "TextColor3", "TextPrimary")
    
    self:AddConnection(frame.MouseButton1Click, callback)
    self:AddConnection(frame.MouseEnter, function() Utils:Tween(frame, AnimConfig, {BackgroundColor3 = Theme.ButtonHover}) end)
    self:AddConnection(frame.MouseLeave, function() Utils:Tween(frame, AnimConfig, {BackgroundColor3 = Theme.Button}) end)
    
    table.insert(self.ThemeCallbacks, function() frame.BackgroundColor3 = Theme.Button end)
    self:RegisterSearchable(frame, localeKey)
end

function SeleniusHub:ShowConfirmation(text, onConfirm)
    local gui = self.UI.ScreenGui
    
    local overlay = Instance.new("Frame")
    overlay.BackgroundColor3 = Color3.new(0,0,0)
    overlay.BackgroundTransparency = 1 -- NÃO ESCURECE TELA
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Parent = gui
    overlay.ZIndex = 100
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 320, 0, 160)
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.Position = UDim2.new(0.5, 0, 0.5, 50) 
    box.BackgroundColor3 = Theme.Secondary
    box.Parent = overlay
    Utils:AddCorner(box, 8)
    
    -- STROKE REMOVED
    
    box.BackgroundTransparency = 1
    TweenService:Create(box, tweenInfo, {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0}):Play()
    
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 10, 0, 10)
    lbl.Size = UDim2.new(1, -20, 0, 60)
    lbl.Font = Enum.Font.GothamBold -- Moderno
    lbl.TextSize = 18
    lbl.Text = text
    lbl.TextWrapped = true
    lbl.TextColor3 = Theme.TextPrimary
    lbl.TextTransparency = 1
    lbl.Parent = box
    TweenService:Create(lbl, tweenInfo, {TextTransparency = 0}):Play()
    
    local yesBtn = Instance.new("TextButton")
    yesBtn.Text = self:GetText("label_apply")
    yesBtn.Size = UDim2.new(0.4, -10, 0, 32)
    yesBtn.Position = UDim2.new(0.1, 0, 1, -50)
    yesBtn.BackgroundColor3 = Theme.Button
    yesBtn.BackgroundTransparency = 1
    yesBtn.TextColor3 = Theme.TextPrimary
    yesBtn.TextTransparency = 1
    yesBtn.Parent = box
    Utils:AddCorner(yesBtn, 6)
    TweenService:Create(yesBtn, tweenInfo, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    
    local noBtn = Instance.new("TextButton")
    noBtn.Text = self:GetText("label_cancel")
    noBtn.Size = UDim2.new(0.4, -10, 0, 32)
    noBtn.Position = UDim2.new(0.5, 10, 1, -50)
    noBtn.BackgroundColor3 = Theme.Button
    noBtn.BackgroundTransparency = 1
    noBtn.TextColor3 = Theme.TextPrimary
    noBtn.TextTransparency = 1
    noBtn.Parent = box
    Utils:AddCorner(noBtn, 6)
    TweenService:Create(noBtn, tweenInfo, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    
    local function Close()
        TweenService:Create(box, tweenInfo, {Position = UDim2.new(0.5, 0, 0.5, 50), BackgroundTransparency = 1}):Play()
        TweenService:Create(lbl, tweenInfo, {TextTransparency = 1}):Play()
        TweenService:Create(yesBtn, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(noBtn, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.3)
        overlay:Destroy()
    end
    
    yesBtn.MouseButton1Click:Connect(function() 
        Close()
        if onConfirm then onConfirm() end 
    end)
    noBtn.MouseButton1Click:Connect(function() 
        Close() 
    end)
end

function SeleniusHub:Destroy()
    for _, conn in ipairs(self.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    self.Connections = {}
    
    if self.BlurFunction then self.BlurFunction(false) end
    if self.BlurInstance then self.BlurInstance:Destroy() end
    
    if self.UI and self.UI.ScreenGui then
        self.UI.ScreenGui:Destroy()
    end
end

local function CreateLoadingScreen(hub)
    local gui = Instance.new("ScreenGui")
    gui.Name = RandomString(20)
    gui.ResetOnSpawn = false
    gui.Parent = GetSecureParent()
    gui.DisplayOrder = 100 -- !!! FIX: Loading aparece acima de tudo !!!
    
    local main = Instance.new("Frame")
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, 420, 0, 180) -- Tamanho total desde o início
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = Theme.Background -- FIX: Tema consistente
    main.Parent = gui
    main.BorderSizePixel = 0
    main.ClipsDescendants = false -- Sombra visível
    Utils:AddCorner(main, 8)
    
    -- UIScale para animação de Pop-Up
    local mainScale = Instance.new("UIScale")
    mainScale.Scale = 0
    mainScale.Parent = main

    -- ACRYLIC (UI STROKE SHADOW)
    Acrylic.Enable(main)
    
    local logo = Instance.new("ImageLabel")
    logo.BackgroundTransparency = 1
    logo.Size = UDim2.new(0, 64, 0, 64)
    logo.Position = UDim2.new(0, 20, 0, 20)
    logo.Image = GetIcon(IconPaths.Logo)
    logo.Parent = main
    
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 100, 0, 20)
    title.Size = UDim2.new(1, -120, 0, 32)
    title.Font = Enum.Font.GothamBold -- FIX: Fonte consistente
    title.TextSize = 28
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Theme.Accent -- FIX: Cor consistente
    title.Text = Locales[hub.Locale].loading_title
    title.Parent = main
    
    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.new(0, 100, 0, 52)
    sub.Size = UDim2.new(1, -120, 0, 20)
    sub.Font = Enum.Font.GothamMedium -- FIX: Fonte consistente
    sub.TextSize = 18
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextColor3 = Theme.AccentDark -- FIX: Cinza (AccentDark) em vez de Azul
    sub.Text = Locales[hub.Locale].loading_sub
    sub.Parent = main
    
    local barBg = Instance.new("Frame")
    barBg.BackgroundColor3 = Theme.Separator -- FIX: Tema consistente
    barBg.Position = UDim2.new(0, 20, 0, 100)
    barBg.Size = UDim2.new(1, -40, 0, 10)
    barBg.Parent = main
    barBg.BorderSizePixel = 0
    Utils:AddCorner(barBg, 5)
    
    local barFill = Instance.new("Frame")
    barFill.BackgroundColor3 = Theme.Accent -- FIX: Cor consistente
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.Parent = barBg
    barFill.BorderSizePixel = 0
    Utils:AddCorner(barFill, 5)
    
    local percentLabel = Instance.new("TextLabel")
    percentLabel.BackgroundTransparency = 1
    percentLabel.Position = UDim2.new(0, 20, 0, 116)
    percentLabel.Size = UDim2.new(0, 80, 0, 22)
    percentLabel.Font = Enum.Font.GothamMedium -- FIX: Fonte consistente
    percentLabel.TextSize = 18
    percentLabel.TextXAlignment = Enum.TextXAlignment.Left
    percentLabel.TextColor3 = Theme.TextPrimary -- FIX: Branco (TextPrimary)
    percentLabel.Text = "0%"
    percentLabel.Parent = main
    
    local openBtn = Instance.new("TextButton")
    openBtn.BackgroundColor3 = Theme.Button -- FIX: Tema consistente
    openBtn.Size = UDim2.new(0, 130, 0, 32)
    openBtn.Position = UDim2.new(1, -150, 1, -50)
    openBtn.Font = Enum.Font.GothamMedium -- FIX: Fonte consistente
    openBtn.TextSize = 18
    openBtn.TextColor3 = Theme.TextPrimary -- FIX: Cor consistente
    openBtn.Text = Locales[hub.Locale].loading_button
    openBtn.AutoButtonColor = false
    openBtn.Visible = false
    openBtn.Parent = main
    openBtn.BorderSizePixel = 0
    Utils:AddCorner(openBtn, 6)
    
    -- ANIMAÇÃO NOVA: Pop Up (Zoom In) com Quintic Easing
    Utils:Tween(mainScale, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1})
    
    local progress = 0
    local duration = 0.8
    local steps = 40
    task.spawn(function()
        for i = 1, steps do
            progress = i / steps
            barFill.Size = UDim2.new(progress, 0, 1, 0)
            percentLabel.Text = tostring(math.floor(progress * 100)) .. "%"
            task.wait(duration / steps)
        end
        openBtn.Visible = true
    end)
    
    openBtn.MouseEnter:Connect(function() Utils:Tween(openBtn, AnimConfig, {BackgroundColor3 = Theme.ButtonHover}) end)
    openBtn.MouseLeave:Connect(function() Utils:Tween(openBtn, AnimConfig, {BackgroundColor3 = Theme.Button}) end)
    openBtn.MouseButton1Click:Connect(function() 
        -- Animação de Saída do Loader (Zoom Out)
        Utils:Tween(mainScale, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0})
        task.wait(0.4)
        gui:Destroy() 
        -- !!! FIX: SÓ MOSTRA O HUB AQUI !!!
        hub:SetVisible(true, true) 
    end)
end

--================================================================================--
-- KEY SYSTEM FIXED & OPTIMIZED
--================================================================================--
local function CreateKeySystem(hub)
    local correctKey = "testing123"
    
    local gui = Instance.new("ScreenGui")
    gui.Name = RandomString(20)
    gui.ResetOnSpawn = false
    gui.Parent = GetSecureParent()
    gui.DisplayOrder = 100 -- !!! FIX: Prioridade Máxima !!!
    
    local main = Instance.new("Frame")
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 380, 0, 220) -- FIX: Começa com tamanho TOTAL
    main.BackgroundColor3 = Theme.Background -- FIX: Tema consistente
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    main.Parent = gui
    
    local mainScale = Instance.new("UIScale")
    mainScale.Scale = 0
    mainScale.Parent = main
    
    Utils:AddCorner(main, 8)
    Acrylic.Enable(main)
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Parent = main
    content.Visible = true
    
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 25)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold -- FIX: Fonte consistente
    title.TextSize = 22
    title.TextColor3 = Theme.Accent -- FIX: Cor consistente (AZUL)
    title.Text = "SELENIUS KEY"
    title.Parent = content
    
    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.new(0, 0, 0, 50)
    sub.Size = UDim2.new(1, 0, 0, 20)
    sub.Font = Enum.Font.GothamMedium -- FIX: Fonte consistente
    sub.TextSize = 14
    sub.TextColor3 = Theme.AccentDark -- FIX: Cinza (AccentDark) em vez de Azul
    sub.Text = "Authentication Required"
    sub.Parent = content
    
    local inputBg = Instance.new("Frame")
    inputBg.BackgroundColor3 = Theme.Secondary -- FIX: Tema consistente
    inputBg.Position = UDim2.new(0.1, 0, 0.35, 0)
    inputBg.Size = UDim2.new(0.8, 0, 0, 40)
    inputBg.Parent = content
    Utils:AddCorner(inputBg, 6)
    
    -- NO STROKE
    
    local keyBox = Instance.new("TextBox")
    keyBox.BackgroundTransparency = 1
    keyBox.Position = UDim2.new(0, 10, 0, 0)
    keyBox.Size = UDim2.new(1, -20, 1, 0)
    keyBox.Font = Enum.Font.GothamMedium -- FIX: Fonte consistente
    keyBox.TextSize = 14
    keyBox.TextColor3 = Theme.TextPrimary -- FIX: Cor consistente
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
    enterBtn.BackgroundColor3 = Theme.Button -- FIX: Tema consistente
    enterBtn.Size = UDim2.new(0.48, 0, 1, 0)
    enterBtn.Font = Enum.Font.GothamBold -- FIX: Fonte consistente
    enterBtn.TextSize = 14
    enterBtn.TextColor3 = Theme.Accent -- FIX: Cor consistente
    enterBtn.Text = "CHECK KEY"
    enterBtn.Parent = btnContainer
    Utils:AddCorner(enterBtn, 6)
    
    -- NO STROKE
    
    local getBtn = Instance.new("TextButton")
    getBtn.BackgroundColor3 = Theme.Button -- FIX: Tema consistente
    getBtn.Position = UDim2.new(0.52, 0, 0, 0)
    getBtn.Size = UDim2.new(0.48, 0, 1, 0)
    getBtn.Font = Enum.Font.GothamBold -- FIX: Fonte consistente
    getBtn.TextSize = 14
    getBtn.TextColor3 = Theme.TextPrimary -- FIX: Cor consistente (BRANCO)
    getBtn.Text = "GET KEY"
    getBtn.Parent = btnContainer
    Utils:AddCorner(getBtn, 6)
    
    local statusText = Instance.new("TextLabel")
    statusText.BackgroundTransparency = 1
    statusText.Position = UDim2.new(0, 0, 0.85, 0)
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Font = Enum.Font.GothamMedium -- FIX: Fonte consistente
    statusText.TextSize = 12
    statusText.TextColor3 = Theme.Error -- FIX: Cor consistente
    statusText.TextTransparency = 1
    statusText.Text = ""
    statusText.Parent = content
    
    Utils:Tween(mainScale, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1})
    
    enterBtn.MouseEnter:Connect(function() TweenService:Create(enterBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ButtonHover}):Play() end)
    enterBtn.MouseLeave:Connect(function() TweenService:Create(enterBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button}):Play() end)
    
    getBtn.MouseEnter:Connect(function() TweenService:Create(getBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ButtonHover}):Play() end)
    getBtn.MouseLeave:Connect(function() TweenService:Create(getBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button}):Play() end)
    
    enterBtn.MouseButton1Click:Connect(function()
        if keyBox.Text == correctKey then
            inputBg.Visible = false; btnContainer.Visible = false; title.Visible = false; sub.Visible = false
            statusText.TextColor3 = Theme.Status -- FIX: Usando tema
            statusText.Text = "Success! Loading..."
            statusText.Position = UDim2.new(0, 0, 0.5, -10)
            statusText.TextSize = 18
            TweenService:Create(statusText, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
            task.wait(0.6)
            content.Visible = false
            local closeTween = Utils:Tween(mainScale, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0})
            closeTween.Completed:Wait()
            gui:Destroy()
            CreateLoadingScreen(hub)
        else
            statusText.TextColor3 = Theme.Error -- FIX: Usando tema
            statusText.Text = "Invalid Key"
            TweenService:Create(statusText, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
            local x = inputBg.Position.X.Scale
            local y = inputBg.Position.Y.Scale
            -- SHAKE EFFECT OPTIMIZED
            for i = 1, 6 do
                inputBg.Position = UDim2.new(x, math.random(-3, 3), y, 0)
                task.wait(0.05)
            end
            inputBg.Position = UDim2.new(x, 0, y, 0)
        end
    end)
    
    getBtn.MouseButton1Click:Connect(function()
        setclipboard("https://linkvertise.com/example-key")
        statusText.TextColor3 = Theme.Accent
        statusText.Text = "Link copied to clipboard"
        TweenService:Create(statusText, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
        task.delay(2, function() TweenService:Create(statusText, TweenInfo.new(0.5), {TextTransparency = 1}):Play() end)
    end)
end

--------------------------------------------------------------------
-- Iniciar Hub + Key System + Loading Seguro
--------------------------------------------------------------------
do
    local existing = getgenv().SeleniusHubInstance
    if existing then
        pcall(function()
            if type(existing.SetVisible) == "function" then
                existing:SetVisible(true, true)
            end
        end)
        return existing
    end
end

local hub = SeleniusHub.new()

-- Inicia o Sistema de Key primeiro (Prioridade 100)
-- O Hub (Prioridade 10) fica invisível até o fim do Loading
CreateKeySystem(hub)

_G.SeleniusHubReload = function()
    if hub then
        hub:Destroy()
        task.wait(0.1)
        hub = SeleniusHub.new()
        CreateKeySystem(hub)
        getgenv().SeleniusHubInstance = hub
    end
end

getgenv().SeleniusHubInstance = hub
return hub