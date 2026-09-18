local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Маршрут авто-фарма (13 позиций)
local Waypoints = {
    Vector3.new(-58, 35, 1184.4),   -- Point 1
    Vector3.new(-50, 30, 2068.2),   -- Point 2
    Vector3.new(-63.6, 40, 2751.4), -- Point 3
    Vector3.new(-46.9, 40, 3575.9), -- Point 4
    Vector3.new(-52.6, 36, 4372.2), -- Point 5
    Vector3.new(-48.1, 45, 5143.2), -- Point 6
    Vector3.new(-52.7, 55, 5911.7), -- Point 7
    Vector3.new(-57.5, 35, 6669.8), -- Point 8
    Vector3.new(-51, 35, 7454.4),   -- Point 9
    Vector3.new(-43.2, 50, 8233.6), -- Point 10
    Vector3.new(-53.4, 55, 8668.9), -- Point 11
    Vector3.new(-65.5, -273.4, 8717.5), -- Point 12
    Vector3.new(-55, -360.4, 9486)  -- Point 13
}

-- Цветовые пресеты
local ThemeColors = {
    ["Черный"]     = Color3.fromRGB(10, 10, 12),
    ["Белый"]      = Color3.fromRGB(235, 235, 240),
    ["Фиолетовый"] = Color3.fromRGB(140, 40, 200)
}

-- Настройки
local Settings = {
    AutoFarm = false,
    AntiAfk = false,
    FlySpeed = 250,
    FinishDelay = 7,
    RespawnDelay = 5,
    
    -- Visuals
    Trails = false,
    ChinaHat = false,
    Snow = false,
    TimeChanger = 14,
    
    -- Active Color Theme
    ActiveColor = ThemeColors["Черный"],
    
    -- Optimizer
    OptimizerEnabled = false,
    
    -- Language
    Language = "RU"
}

local CurrentTween = nil
local CarrierPlatform = nil

----------------------------------------------------
-- МОДУЛЬ TRANSLATIONS (СЛОВАРЬ ПЕРЕВОДОВ)
----------------------------------------------------

local Translations = {
    RU = {
        WinTitle = "BABFT BARABAKA FARM",
        WinSub = "Система BARABAKA",
        
        TabFarm = "Авто-Фарм",
        TabVisuals = "Визуалы",
        TabMisc = "Прочее",
        TabSettings = "Настройки",
        
        ToggleFarm = "Активировать Auto Farm",
        SliderSpeed = "Скорость полёта",
        
        ToggleTrail = "Trails (След за игроком)",
        ToggleHat = "China Hat (Шляпа)",
        ToggleSnow = "Snow (Снегопад)",
        SliderTime = "Time Changer (Время суток)",
        
        ToggleAntiAfk = "AntiAFK (GUI BARABAKA)",
        BtnFps = "FPS Boost (Оптимизация)",
        BtnFpsDesc = "Убрать тяжелые эффекты и материалы",
        BtnRestore = "Back All (Сброс оптимизации)",
        BtnRestoreDesc = "Вернуть исходные текстуры и материалы",
        
        DropdownTheme = "Выбор цвета GUI и Визуалов",
        ThemeBlack = "Черный",
        ThemeWhite = "Белый",
        ThemePurple = "Фиолетовый"
    },
    EN = {
        WinTitle = "BABFT BARABAKA FARM",
        WinSub = "BARABAKA System",
        
        TabFarm = "Auto Farm",
        TabVisuals = "Visuals",
        TabMisc = "Misc",
        TabSettings = "Settings",
        
        ToggleFarm = "Activate Auto Farm",
        SliderSpeed = "Fly Speed",
        
        ToggleTrail = "Trails (Player Trail)",
        ToggleHat = "China Hat",
        ToggleSnow = "Snow",
        SliderTime = "Time Changer (Day Time)",
        
        ToggleAntiAfk = "AntiAFK (GUI BARABAKA)",
        BtnFps = "FPS Boost (Optimization)",
        BtnFpsDesc = "Remove heavy effects and materials",
        BtnRestore = "Back All (Reset Optimization)",
        BtnRestoreDesc = "Restore original textures and materials",
        
        DropdownTheme = "GUI & Visuals Theme Color",
        ThemeBlack = "Black",
        ThemeWhite = "White",
        ThemePurple = "Purple"
    }
}

----------------------------------------------------
-- МОДУЛЬ ANTI-AFK (BARABAKA GUI)
----------------------------------------------------

local AntiAfkConnection = nil
local AntiAfkGui = nil
local AntiAfkRunning = false

local function SetAntiAfkState(state)
    Settings.AntiAfk = state
    
    if state then
        if game.CoreGui:FindFirstChild("BarabakaAntiAfkGui") then
            game.CoreGui.BarabakaAntiAfkGui:Destroy()
        end

        AntiAfkRunning = true

        local VirtualUser = game:GetService("VirtualUser")
        if not AntiAfkConnection then
            AntiAfkConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end

        AntiAfkGui = Instance.new("ScreenGui")
        AntiAfkGui.Name = "BarabakaAntiAfkGui"
        AntiAfkGui.Parent = game:GetService("CoreGui")
        AntiAfkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Parent = AntiAfkGui
        MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        MainFrame.Position = UDim2.new(0.085, 0, 0.131, 0)
        MainFrame.Size = UDim2.new(0, 225, 0, 96)

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = MainFrame

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Parent = MainFrame
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Position = UDim2.new(0, 0, 0, 4)
        TitleLabel.Size = UDim2.new(1, 0, 0, 20)
        TitleLabel.Font = Enum.Font.SourceSansBold
        TitleLabel.Text = "BARABAKA"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 16

        local Divider = Instance.new("Frame")
        Divider.Parent = MainFrame
        Divider.BackgroundColor3 = Settings.ActiveColor
        Divider.BorderSizePixel = 0
        Divider.Position = UDim2.new(0.05, 0, 0.28, 0)
        Divider.Size = UDim2.new(0.9, 0, 0, 2)

        local PingTag = Instance.new("TextLabel")
        PingTag.Parent = MainFrame
        PingTag.BackgroundTransparency = 1
        PingTag.Position = UDim2.new(0.05, 0, 0.38, 0)
        PingTag.Size = UDim2.new(0, 35, 0, 20)
        PingTag.Font = Enum.Font.SourceSans
        PingTag.Text = "Ping:"
        PingTag.TextColor3 = Color3.fromRGB(200, 200, 200)
        PingTag.TextSize = 14

        local PingLabel = Instance.new("TextLabel")
        PingLabel.Parent = MainFrame
        PingLabel.BackgroundTransparency = 1
        PingLabel.Position = UDim2.new(0.2, 0, 0.38, 0)
        PingLabel.Size = UDim2.new(0, 45, 0, 20)
        PingLabel.Font = Enum.Font.SourceSans
        PingLabel.Text = "--"
        PingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        PingLabel.TextSize = 14

        local FpsTag = Instance.new("TextLabel")
        FpsTag.Parent = MainFrame
        FpsTag.BackgroundTransparency = 1
        FpsTag.Position = UDim2.new(0.52, 0, 0.38, 0)
        FpsTag.Size = UDim2.new(0, 30, 0, 20)
        FpsTag.Font = Enum.Font.SourceSans
        FpsTag.Text = "FPS:"
        FpsTag.TextColor3 = Color3.fromRGB(200, 200, 200)
        FpsTag.TextSize = 14

        local FpsLabel = Instance.new("TextLabel")
        FpsLabel.Parent = MainFrame
        FpsLabel.BackgroundTransparency = 1
        FpsLabel.Position = UDim2.new(0.68, 0, 0.38, 0)
        FpsLabel.Size = UDim2.new(0, 45, 0, 20)
        FpsLabel.Font = Enum.Font.SourceSans
        FpsLabel.Text = "--"
        FpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        FpsLabel.TextSize = 14

        local StatusLabel = Instance.new("TextLabel")
        StatusLabel.Parent = MainFrame
        StatusLabel.BackgroundTransparency = 1
        StatusLabel.Position = UDim2.new(0.05, 0, 0.68, 0)
        StatusLabel.Size = UDim2.new(0.5, 0, 0, 20)
        StatusLabel.Font = Enum.Font.SourceSans
        StatusLabel.Text = "Anti-AFK Active"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        StatusLabel.TextSize = 13
        StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

        local TimerLabel = Instance.new("TextLabel")
        TimerLabel.Parent = MainFrame
        TimerLabel.BackgroundTransparency = 1
        TimerLabel.Position = UDim2.new(0.55, 0, 0.68, 0)
        TimerLabel.Size = UDim2.new(0.4, 0, 0, 20)
        TimerLabel.Font = Enum.Font.SourceSans
        TimerLabel.Text = "00:00:00"
        TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TimerLabel.TextSize = 13

        local Dragging, DragInput, DragStart, StartPos
        MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPos = MainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then Dragging = false end
                end)
            end
        end)
        MainFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                local delta = input.Position - DragStart
                TweenService:Create(MainFrame, TweenInfo.new(0.04, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
                }):Play()
            end
        end)

        local FPSCount = {}
        local LastFPSTime = tick()
        RunService.RenderStepped:Connect(function()
            if not AntiAfkRunning then return end
            local now = tick()
            for i = #FPSCount, 1, -1 do
                FPSCount[i + 1] = (FPSCount[i] >= now - 1) and FPSCount[i] or nil
            end
            FPSCount[1] = now
            local fps = (now - LastFPSTime >= 1 and #FPSCount) or (#FPSCount / (now - LastFPSTime))
            FpsLabel.Text = tostring(math.floor(fps))
        end)

        task.spawn(function()
            while AntiAfkRunning do
                local pingStats = game:GetService("Stats"):FindFirstChild("PerformanceStats")
                if pingStats and pingStats:FindFirstChild("Ping") then
                    PingLabel.Text = tostring(math.floor(pingStats.Ping:GetValue()))
                end
                task.wait(1)
            end
        end)

        task.spawn(function()
            local seconds, minutes, hours = 0, 0, 0
            while AntiAfkRunning do
                task.wait(1)
                seconds = seconds + 1
                if seconds >= 60 then seconds = 0; minutes = minutes + 1 end
                if minutes >= 60 then minutes = 0; hours = hours + 1 end
                TimerLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            end
        end)

    else
        AntiAfkRunning = false
        if AntiAfkConnection then
            AntiAfkConnection:Disconnect()
            AntiAfkConnection = nil
        end
        if AntiAfkGui then
            AntiAfkGui:Destroy()
            AntiAfkGui = nil
        end
    end
end

----------------------------------------------------
-- ПЛАТФОРМА-НОСИТЕЛЬ
----------------------------------------------------

local function CreatePlatform()
    if not CarrierPlatform or not CarrierPlatform.Parent then
        CarrierPlatform = Instance.new("Part")
        CarrierPlatform.Name = "BarabakaCarrier"
        CarrierPlatform.Size = Vector3.new(7, 1, 7)
        CarrierPlatform.Color = Settings.ActiveColor
        CarrierPlatform.Material = Enum.Material.Neon
        CarrierPlatform.Anchored = true
        CarrierPlatform.CanCollide = true
        CarrierPlatform.Parent = Workspace
    end
end

local function RemovePlatform()
    if CarrierPlatform then
        CarrierPlatform:Destroy()
        CarrierPlatform = nil
    end
end

----------------------------------------------------
-- МОДУЛЬ VISUALS
----------------------------------------------------

local ActiveTrail = nil
local TrailAtt0, TrailAtt1 = nil, nil

local function ToggleTrail(state)
    local char = LocalPlayer.Character
    if state and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if not ActiveTrail or not ActiveTrail.Parent then
            TrailAtt0 = Instance.new("Attachment", hrp)
            TrailAtt0.Position = Vector3.new(0, 1.5, 0)
            
            TrailAtt1 = Instance.new("Attachment", hrp)
            TrailAtt1.Position = Vector3.new(0, -1.5, 0)
            
            ActiveTrail = Instance.new("Trail")
            ActiveTrail.Attachment0 = TrailAtt0
            ActiveTrail.Attachment1 = TrailAtt1
            ActiveTrail.Color = ColorSequence.new(Settings.ActiveColor)
            ActiveTrail.Lifetime = 0.8
            ActiveTrail.MinLength = 0.1
            ActiveTrail.Transparency = NumberSequence.new(0.2, 1)
            ActiveTrail.Parent = hrp
        end
    else
        if ActiveTrail then
            ActiveTrail:Destroy()
            ActiveTrail = nil
        end
        if TrailAtt0 then TrailAtt0:Destroy() TrailAtt0 = nil end
        if TrailAtt1 then TrailAtt1:Destroy() TrailAtt1 = nil end
    end
end

local HatPart = nil
local function UpdateChinaHat()
    local char = LocalPlayer.Character
    if Settings.ChinaHat and char and char:FindFirstChild("Head") then
        if not HatPart or not HatPart.Parent then
            HatPart = Instance.new("Part")
            HatPart.Name = "BarabakaChinaHat"
            HatPart.Size = Vector3.new(3, 1, 3)
            HatPart.Color = Settings.ActiveColor
            HatPart.Material = Enum.Material.Neon
            HatPart.CanCollide = false
            HatPart.Anchored = true
            
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://1033714"
            mesh.Scale = Vector3.new(2.5, 1, 2.5)
            mesh.Parent = HatPart
            HatPart.Parent = Workspace
        end
        HatPart.Color = Settings.ActiveColor
        HatPart.CFrame = char.Head.CFrame * CFrame.new(0, 1.2, 0)
    else
        if HatPart then
            HatPart:Destroy()
            HatPart = nil
        end
    end
end
RunService.RenderStepped:Connect(UpdateChinaHat)

local SnowPart = nil
local SnowEmitter = nil

local function ToggleSnow(state)
    if state then
        if not SnowPart or not SnowPart.Parent then
            SnowPart = Instance.new("Part")
            SnowPart.Name = "SnowEmitterPart"
            SnowPart.Size = Vector3.new(1, 1, 1)
            SnowPart.Transparency = 1
            SnowPart.CanCollide = false
            SnowPart.Anchored = true
            SnowPart.Parent = Workspace

            SnowEmitter = Instance.new("ParticleEmitter")
            SnowEmitter.Color = ColorSequence.new(Settings.ActiveColor)
            SnowEmitter.Size = NumberSequence.new(0.3, 0.6)
            SnowEmitter.Rate = 120
            SnowEmitter.Lifetime = NumberRange.new(2, 4)
            SnowEmitter.Speed = NumberRange.new(8, 15)
            SnowEmitter.VelocitySpread = 180
            SnowEmitter.Parent = SnowPart
        end
    else
        if SnowPart then
            SnowPart:Destroy()
            SnowPart = nil
            SnowEmitter = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Settings.Snow and SnowPart then
        SnowPart.CFrame = Camera.CFrame * CFrame.new(0, 15, -10)
        if SnowEmitter then
            SnowEmitter.Color = ColorSequence.new(Settings.ActiveColor)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.TimeChanger then
        local numTime = tonumber(Settings.TimeChanger)
        if numTime then
            Lighting.ClockTime = numTime
        end
    end
end)

local function UpdateVisualsColor()
    if ActiveTrail then ActiveTrail.Color = ColorSequence.new(Settings.ActiveColor) end
    if CarrierPlatform then CarrierPlatform.Color = Settings.ActiveColor end
end

----------------------------------------------------
-- ОПТИМИЗАЦИЯ
----------------------------------------------------

local SavedState = { Materials = {}, Shadows = {}, DisabledEffects = {}, GlobalLighting = {} }

local function ApplyOptimization()
    if Settings.OptimizerEnabled then return end
    Settings.OptimizerEnabled = true

    SavedState.GlobalLighting.GlobalShadows = Lighting.GlobalShadows
    Lighting.GlobalShadows = false

    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then
            if not SavedState.DisabledEffects[v] then SavedState.DisabledEffects[v] = v.Parent end
            v.Parent = nil
        end
    end

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if SavedState.Materials[v] == nil then SavedState.Materials[v] = v.Material end
            if SavedState.Shadows[v] == nil then SavedState.Shadows[v] = v.CastShadow end
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            if SavedState.DisabledEffects[v] == nil then SavedState.DisabledEffects[v] = v.Parent end
            v.Parent = nil
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            if SavedState.DisabledEffects[v] == nil then SavedState.DisabledEffects[v] = v.Enabled end
            v.Enabled = false
        end
    end
end

local function RestoreOriginals()
    if not Settings.OptimizerEnabled then return end
    Settings.OptimizerEnabled = false

    if SavedState.GlobalLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = SavedState.GlobalLighting.GlobalShadows end
    for part, mat in pairs(SavedState.Materials) do if part and part.Parent then part.Material = mat end end
    for part, shadow in pairs(SavedState.Shadows) do if part and part.Parent then part.CastShadow = shadow end end
    for effect, state in pairs(SavedState.DisabledEffects) do
        if effect then
            if type(state) == "boolean" then effect.Enabled = state
            elseif typeof(state) == "Instance" then effect.Parent = state end
        end
    end
    table.clear(SavedState.Materials)
    table.clear(SavedState.Shadows)
    table.clear(SavedState.DisabledEffects)
    table.clear(SavedState.GlobalLighting)
end

----------------------------------------------------
-- ЛОГИКА АВТО-ФАРМА
----------------------------------------------------

RunService.Stepped:Connect(function()
    if Settings.AutoFarm and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.AutoFarm and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if CarrierPlatform then
                CarrierPlatform.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
            end
        end
    end
end)

local function MoveTo(hrp, targetPos)
    local distance = (hrp.Position - targetPos).Magnitude
    local timeToTravel = distance / Settings.FlySpeed
    
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    CurrentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    
    CurrentTween:Play()
    CurrentTween.Completed:Wait()
end

task.spawn(function()
    while true do
        if Settings.AutoFarm then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            local humanoid = char:WaitForChild("Humanoid", 5)
            
            if hrp and humanoid and humanoid.Health > 0 then
                CreatePlatform()
                humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                
                hrp.CFrame = CFrame.new(Waypoints[1])
                task.wait(0.1)
                
                for i = 2, #Waypoints do
                    if not Settings.AutoFarm or not LocalPlayer.Character or humanoid.Health <= 0 then break end
                    MoveTo(hrp, Waypoints[i])
                end
                
                if Settings.AutoFarm and humanoid.Health > 0 then
                    task.wait(Settings.FinishDelay)
                    RemovePlatform()
                    humanoid.Health = 0
                    
                    LocalPlayer.CharacterAdded:Wait()
                    task.wait(Settings.RespawnDelay)
                end
            else
                task.wait(1)
            end
        else
            RemovePlatform()
            if CurrentTween then CurrentTween:Cancel() end
            task.wait(0.5)
        end
    end
end)

----------------------------------------------------
-- ФУНКЦИЯ ИНИЦИАЛИЗАЦИИ ИНТЕРФЕЙСА FLUENT
----------------------------------------------------

local function InitMainGUI()
    local lang = Translations[Settings.Language]
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

    local Window = Fluent:CreateWindow({
        Title = lang.WinTitle,
        SubTitle = lang.WinSub,
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 420),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.K
    })

    local Tabs = {
        Farm = Window:AddTab({ Title = lang.TabFarm, Icon = "play" }),
        Visuals = Window:AddTab({ Title = lang.TabVisuals, Icon = "eye" }),
        Misc = Window:AddTab({ Title = lang.TabMisc, Icon = "cpu" }),
        Settings = Window:AddTab({ Title = lang.TabSettings, Icon = "settings" })
    }

    -- Вкладка: Auto Farm
    local ToggleFarm = Tabs.Farm:AddToggle("FarmToggle", {Title = lang.ToggleFarm, Default = false})
    ToggleFarm:OnChanged(function(Value)
        Settings.AutoFarm = Value
        if not Value then
            RemovePlatform()
            if CurrentTween then CurrentTween:Cancel() end
        end
    end)

    -- Добавленная памятка перед слайдером скорости
    Tabs.Farm:AddParagraph({
        Title = Settings.Language == "RU" and "⚠️ Примечание по скорости" or "⚠️ Speed Note",
        Content = Settings.Language == "RU" 
            and "Чем ВЫШЕ скорость, тем МЕНЬШЕ золота вы получите. Чем НИЖЕ скорость, тем БОЛЬШЕ награда." 
            or "HIGHER speed values result in LESS gold earned. LOWER speed values yield MORE rewards."
    })

    Tabs.Farm:AddSlider("SpeedSlider", {
        Title = lang.SliderSpeed,
        Min = 100,
        Max = 1000,
        Default = 250,
        Rounding = 0,
        Callback = function(Value) Settings.FlySpeed = Value end
    })

    -- Вкладка: Visuals
    local TrailToggle = Tabs.Visuals:AddToggle("TrailToggle", {Title = lang.ToggleTrail, Default = false})
    TrailToggle:OnChanged(function(Value)
        Settings.Trails = Value
        ToggleTrail(Value)
    end)

    local HatToggle = Tabs.Visuals:AddToggle("HatToggle", {Title = lang.ToggleHat, Default = false})
    HatToggle:OnChanged(function(Value) Settings.ChinaHat = Value end)

    local SnowToggle = Tabs.Visuals:AddToggle("SnowToggle", {Title = lang.ToggleSnow, Default = false})
    SnowToggle:OnChanged(function(Value)
        Settings.Snow = Value
        ToggleSnow(Value)
    end)

    local TimeSlider = Tabs.Visuals:AddSlider("TimeSlider", {
        Title = lang.SliderTime,
        Min = 0,
        Max = 24,
        Default = 14,
        Rounding = 1
    })

    TimeSlider:OnChanged(function(Value)
        local numericVal = tonumber(Value)
        if numericVal then
            Settings.TimeChanger = numericVal
            Lighting.ClockTime = numericVal
        end
    end)

    -- Вкладка: Misc
    local ToggleAntiAfk = Tabs.Misc:AddToggle("AntiAfkToggle", {Title = lang.ToggleAntiAfk, Default = false})
    ToggleAntiAfk:OnChanged(function(Value)
        SetAntiAfkState(Value)
    end)

    Tabs.Misc:AddButton({
        Title = lang.BtnFps,
        Description = lang.BtnFpsDesc,
        Callback = function() ApplyOptimization() end
    })

    Tabs.Misc:AddButton({
        Title = lang.BtnRestore,
        Description = lang.BtnRestoreDesc,
        Callback = function() RestoreOriginals() end
    })

    -- Вкладка: Settings
    local ThemeDropdown = Tabs.Settings:AddDropdown("ThemeDropdown", {
        Title = lang.DropdownTheme,
        Values = {lang.ThemeBlack, lang.ThemeWhite, lang.ThemePurple},
        Default = lang.ThemeBlack,
        Callback = function(Value)
            if Value == lang.ThemeBlack then
                Settings.ActiveColor = ThemeColors["Черный"]
                Fluent:SetTheme("Dark")
            elseif Value == lang.ThemeWhite then
                Settings.ActiveColor = ThemeColors["Белый"]
                Fluent:SetTheme("Light")
            elseif Value == lang.ThemePurple then
                Settings.ActiveColor = ThemeColors["Фиолетовый"]
                Fluent:SetTheme("Amethyst")
            end
            UpdateVisualsColor()
        end
    })

    Window:SelectTab(1)
end

----------------------------------------------------
-- МЕНЮ ВЫБОРА ЯЗЫКА (ОТРИСОВКА ФЛАГОВ КОДОМ)
----------------------------------------------------

local function CreateLanguageSelector()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BarabakaLangSelector"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 320, 0, 200)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(60, 60, 80)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = MainFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 0, 0, 15)
    TitleLabel.Size = UDim2.new(1, 0, 0, 25)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = "SELECT LANGUAGE / ВЫБЕРИТЕ ЯЗЫК"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 15

    -- СЕКЦИЯ США / ENGLISH (СЛЕВА)
    local USFrame = Instance.new("Frame")
    USFrame.Parent = MainFrame
    USFrame.BackgroundTransparency = 1
    USFrame.Position = UDim2.new(0.08, 0, 0.28, 0)
    USFrame.Size = UDim2.new(0, 110, 0, 120)

    local USText = Instance.new("TextLabel")
    USText.Parent = USFrame
    USText.BackgroundTransparency = 1
    USText.Size = UDim2.new(1, 0, 0, 18)
    USText.Font = Enum.Font.SourceSans
    USText.Text = "english"
    USText.TextColor3 = Color3.fromRGB(180, 180, 190)
    USText.TextSize = 13

    local USButton = Instance.new("TextButton")
    USButton.Parent = USFrame
    USButton.Position = UDim2.new(0.05, 0, 0.2, 0)
    USButton.Size = UDim2.new(0, 100, 0, 70)
    USButton.Text = ""
    USButton.BackgroundColor3 = Color3.fromRGB(180, 20, 30)
    USButton.ClipsDescendants = true

    local USBtnCorner = Instance.new("UICorner")
    USBtnCorner.CornerRadius = UDim.new(0, 6)
    USBtnCorner.Parent = USButton

    for i = 1, 3 do
        local stripe = Instance.new("Frame")
        stripe.Parent = USButton
        stripe.BorderSizePixel = 0
        stripe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        stripe.Position = UDim2.new(0, 0, (i * 2 - 1) / 7, 0)
        stripe.Size = UDim2.new(1, 0, 1/7, 0)
    end

    local USBlueBox = Instance.new("Frame")
    USBlueBox.Parent = USButton
    USBlueBox.BorderSizePixel = 0
    USBlueBox.BackgroundColor3 = Color3.fromRGB(20, 30, 100)
    USBlueBox.Size = UDim2.new(0.45, 0, 0.55, 0)

    -- СЕКЦИЯ РОССИЯ / RUSSIA (СПРАВА)
    local RUFrame = Instance.new("Frame")
    RUFrame.Parent = MainFrame
    RUFrame.BackgroundTransparency = 1
    RUFrame.Position = UDim2.new(0.58, 0, 0.28, 0)
    RUFrame.Size = UDim2.new(0, 110, 0, 120)

    local RUText = Instance.new("TextLabel")
    RUText.Parent = RUFrame
    RUText.BackgroundTransparency = 1
    RUText.Size = UDim2.new(1, 0, 0, 18)
    RUText.Font = Enum.Font.SourceSans
    RUText.Text = "russia"
    RUText.TextColor3 = Color3.fromRGB(180, 180, 190)
    RUText.TextSize = 13

    local RUButton = Instance.new("TextButton")
    RUButton.Parent = RUFrame
    RUButton.Position = UDim2.new(0.05, 0, 0.2, 0)
    RUButton.Size = UDim2.new(0, 100, 0, 70)
    RUButton.Text = ""
    RUButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RUButton.ClipsDescendants = true

    local RUBtnCorner = Instance.new("UICorner")
    RUBtnCorner.CornerRadius = UDim.new(0, 6)
    RUBtnCorner.Parent = RUButton

    local RUBlueStripe = Instance.new("Frame")
    RUBlueStripe.Parent = RUButton
    RUBlueStripe.BorderSizePixel = 0
    RUBlueStripe.BackgroundColor3 = Color3.fromRGB(0, 55, 160)
    RUBlueStripe.Position = UDim2.new(0, 0, 1/3, 0)
    RUBlueStripe.Size = UDim2.new(1, 0, 1/3, 0)

    local RURedStripe = Instance.new("Frame")
    RURedStripe.Parent = RUButton
    RURedStripe.BorderSizePixel = 0
    RURedStripe.BackgroundColor3 = Color3.fromRGB(210, 20, 35)
    RURedStripe.Position = UDim2.new(0, 0, 2/3, 0)
    RURedStripe.Size = UDim2.new(1, 0, 1/3, 0)

    -- КЛИК НА ENGLISH
    USButton.MouseButton1Click:Connect(function()
        Settings.Language = "EN"
        ScreenGui:Destroy()
        InitMainGUI()
    end)

    -- КЛИК НА RUSSIA
    RUButton.MouseButton1Click:Connect(function()
        Settings.Language = "RU"
        ScreenGui:Destroy()
        InitMainGUI()
    end)
end

-- Запуск скрипта
CreateLanguageSelector()
