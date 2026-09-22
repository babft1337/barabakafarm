-- [1] АНТИЧИТ BYPASS
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
if setreadonly then setreadonly(mt, false) end

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        return
    end
    return oldNamecall(self, ...)
end)
if setreadonly then setreadonly(mt, true) end

-- [2] СЕРВИСЫ И ПЕРЕМЕННЫЕ
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 24 позиции
local Positions = {
    Vector3.new(-1451.8, -4.0, -1884.6),  -- 1
    Vector3.new(-1450.7, -3.7, -1860.9),  -- 2
    Vector3.new(-1483.1, -3.9, -1861.5),  -- 3
    Vector3.new(-1485.1, 18.7, -1804.8),  -- 4
    Vector3.new(-1486.5, 18.7, -1763.1),  -- 5
    Vector3.new(-1454.9, 18.8, -1735.2),  -- 6
    Vector3.new(-1363.6, 18.7, -1733.8),  -- 7
    Vector3.new(-1364.8, 18.7, -1664.2),  -- 8
    Vector3.new(-1301.6, 18.7, -1626.2),  -- 9
    Vector3.new(-1303.6, 18.7, -1597.9),  -- 10 (Hold E 5s)
    Vector3.new(-1303.9, 19.1, -1591.9),  -- 11
    Vector3.new(-1303.9, -10.5, -1591.9), -- 12
    Vector3.new(-1303.9, -10.5, -1554.3), -- 13
    Vector3.new(-1293.9, -10.5, -1518.3), -- 14
    Vector3.new(-1268.2, -10.5, -1486.1), -- 15
    Vector3.new(-1218.2, -12.1, -1461.0), -- 16
    Vector3.new(-1174.7, -18.2, -1452.7), -- 17
    Vector3.new(-1179.3, -16.0, -1431.9), -- 18
    Vector3.new(-1178.9, -6.4, -1431.4),  -- 19
    Vector3.new(-1178.2, 10.9, -1433.7),  -- 20
    Vector3.new(-1175.5, 27.3, -1432.9),  -- 21
    Vector3.new(-1174.9, 19.1, -1432.8),  -- 22
    Vector3.new(-1224.2, 18.4, -1387.6),  -- 23
    Vector3.new(-1219.5, 19.7, -1347.0)   -- 24 (Press E once)
}

local isEscaping = false
local noclipConnection = nil
local CurrentRGBColor = Color3.fromRGB(255, 255, 255)

-- RGB Радужный цикл для платформ и Anti-AFK
task.spawn(function()
    local hue = 0
    RunService.RenderStepped:Connect(function()
        hue = (hue + 0.005) % 1
        CurrentRGBColor = Color3.fromHSV(hue, 0.8, 1)
    end)
end)

-- [3] СОЗДАНИЕ ИНТЕРФЕЙСА RAYFIELD (БЕЛАЯ ТЕМА LIGHT)
local Window = Rayfield:CreateWindow({
    Name = "barabaka | jailbreak farm",
    LoadingTitle = "Loading barabaka hub...",
    LoadingSubtitle = "by @ssdkb",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
    Theme = "Light",
    ToggleKey = Enum.KeyCode.K
})

-- Отключение автолокализации Roblox
task.spawn(function()
    task.wait(0.5)
    local guiFolder = game:GetService("CoreGui"):FindFirstChild("Rayfield") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Rayfield")
    if guiFolder then
        for _, obj in ipairs(guiFolder:GetDescendants()) do
            if obj:IsA("GuiObject") or obj:IsA("ScreenGui") then
                obj.AutoLocalize = false
            end
        end
    end
end)

----------------------------------------------------
-- 1. TAB: AutoFarm
----------------------------------------------------
local FarmTab = Window:CreateTab("AutoFarm", 4483362458)

FarmTab:CreateButton({
    Name = "Auto Rob / Arrest (skidded)",
    Callback = function()
        Rayfield:Notify({
            Title = "Auto Farm",
            Content = "Запуск внешнего скрипта...",
            Duration = 3,
            Image = 4483362458,
        })
        loadstring(game:HttpGet('https://raw.githubusercontent.com/BlitzIsKing/UniversalFarm/main/Loader/Regular'))()
    end,
})

FarmTab:CreateLabel("⚠️ ( этот скрипт не мой, это skid все вопросы к создателю auto farm ) ⚠️")

-- ANTI-AFK SYSTEM
local AntiAfkEnabled = false
local AntiAfkGui = nil
local AntiAfkConnection = nil
local AfkStartTime = 0

local function CreateAntiAfkGui()
    if AntiAfkGui then AntiAfkGui:Destroy() end
    
    AntiAfkGui = Instance.new("ScreenGui")
    AntiAfkGui.Name = "BarabakaAntiAFK"
    AntiAfkGui.ResetOnSpawn = false
    AntiAfkGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 160, 0, 70)
    Frame.Position = UDim2.new(0, 15, 0.75, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Frame.BackgroundTransparency = 0.2
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = AntiAfkGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Frame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = "Barabaka Anti-AFK"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 11
    Title.Parent = Frame

    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Size = UDim2.new(1, -10, 1, -22)
    StatsLabel.Position = UDim2.new(0, 5, 0, 20)
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    StatsLabel.Font = Enum.Font.Code
    StatsLabel.TextSize = 10
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatsLabel.Parent = Frame
    
    task.spawn(function()
        while AntiAfkGui and AntiAfkGui.Parent do
            UIStroke.Color = CurrentRGBColor
            task.wait(0.05)
        end
    end)
    
    local lastUpdate = tick()
    local frameCount = 0
    local currentFps = 60
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastUpdate >= 1 then
            currentFps = frameCount
            frameCount = 0
            lastUpdate = tick()
        end
        
        if AntiAfkEnabled then
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            local elapsedTime = math.floor(tick() - AfkStartTime)
            local mins = math.floor(elapsedTime / 60)
            local secs = elapsedTime % 60
            
            StatsLabel.Text = string.format("FPS: %d\nPing: %d ms\nTime: %02dm %02ds", currentFps, ping, mins, secs)
        end
    end)
end

FarmTab:CreateToggle({
    Name = "AntiAfkGUI",
    CurrentValue = false,
    Flag = "AntiAfkToggle",
    Callback = function(Value)
        AntiAfkEnabled = Value
        if Value then
            AfkStartTime = tick()
            CreateAntiAfkGui()
            AntiAfkConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        else
            if AntiAfkGui then AntiAfkGui:Destroy() end
            if AntiAfkConnection then AntiAfkConnection:Disconnect() end
        end
    end,
})

----------------------------------------------------
-- 2. TAB: AutoEscape
----------------------------------------------------
local EscapeTab = Window:CreateTab("AutoEscape", 4483362458)

local function ToggleNoclip(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

local function CreateRGBPlatform()
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(6, 1, 6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.Neon
    platform.Transparency = 0.2
    platform.Parent = workspace
    
    task.spawn(function()
        while platform and platform.Parent do
            platform.Color = CurrentRGBColor
            task.wait(0.05)
        end
    end)
    
    return platform
end

local function WalkToPosition(targetPos)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4
    })

    local success, _ = pcall(function()
        path:ComputeAsync(hrp.Position, targetPos)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not isEscaping then break end
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
        end
    else
        humanoid:MoveTo(targetPos)
        humanoid.MoveToFinished:Wait()
    end
end

local function HoldEKey(seconds)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(seconds)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function PressEKey()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

EscapeTab:CreateButton({
    Name = "Start Escape",
    Callback = function()
        if isEscaping then return end
        isEscaping = true
        
        task.spawn(function()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            
            local startIdx = 1
            local minDistance = math.huge
            for i, pos in ipairs(Positions) do
                local dist = (hrp.Position - pos).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    startIdx = i
                end
            end
            
            local targetFirstPos = Positions[startIdx]
            local distToStart = (hrp.Position - targetFirstPos).Magnitude

            if distToStart > 8 then
                Rayfield:Notify({
                    Title = "Auto Escape",
                    Content = "Идем пешком к метке " .. startIdx .. " (обход стен)...",
                    Duration = 4,
                    Image = 4483362458,
                })
                WalkToPosition(targetFirstPos)
            end

            ToggleNoclip(true)
            local platform = CreateRGBPlatform()
            platform.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)

            for i = startIdx, #Positions do
                if not isEscaping then break end
                
                local targetPos = Positions[i]
                local distance = (hrp.Position - targetPos).Magnitude
                local tweenTime = distance / 65
                if tweenTime < 0.05 then tweenTime = 0.05 end
                
                local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                local playerTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
                local platformTween = TweenService:Create(platform, tweenInfo, {CFrame = CFrame.new(targetPos - Vector3.new(0, 3.5, 0))})
                
                playerTween:Play()
                platformTween:Play()
                
                Rayfield:Notify({
                    Title = "Auto Escape Status",
                    Content = "Перемещение к позиции " .. i .. " / " .. #Positions,
                    Duration = tweenTime,
                    Image = 4483362458,
                })
                
                playerTween.Completed:Wait()
                
                if i == 10 then
                    Rayfield:Notify({
                        Title = "Auto Escape",
                        Content = "Удерживание E (5 сек)...",
                        Duration = 5,
                        Image = 4483362458,
                    })
                    HoldEKey(5)
                end
                
                if i == 24 then
                    PressEKey()
                end
            end
            
            platform:Destroy()
            ToggleNoclip(false)
            isEscaping = false
            
            Rayfield:Notify({
                Title = "Успех",
                Content = "Escape выполнен успешно",
                Duration = 4,
                Image = 4483362458,
            })
        end)
    end,
})

----------------------------------------------------
-- 3. TAB: Optimizer
----------------------------------------------------
local OptimizerTab = Window:CreateTab("Optimizer", 4483362458)

OptimizerTab:CreateButton({
    Name = "Optimize (FPS Boost & Lower Lag)",
    Callback = function()
        pcall(function()
            settings().Rendering.QualityLevel = 1
            
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy()
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end
            
            workspace.GlobalShadows = false
        end)
        
        Rayfield:Notify({
            Title = "Optimizer",
            Content = "Оптимизация успешно применена!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

OptimizerTab:CreateButton({
    Name = "Remove Fog",
    Callback = function()
        pcall(function()
            local lighting = game:GetService("Lighting")
            lighting.FogEnd = 9e9
            for _, v in ipairs(lighting:GetChildren()) do
                if v:IsA("Atmosphere") then
                    v:Destroy()
                end
            end
        end)
        
        Rayfield:Notify({
            Title = "Optimizer",
            Content = "Туман успешно удален!",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

OptimizerTab:CreateButton({
    Name = "Fullbright",
    Callback = function()
        pcall(function()
            local lighting = game:GetService("Lighting")
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end)
        
        Rayfield:Notify({
            Title = "Optimizer",
            Content = "Максимальная яркость включена!",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

----------------------------------------------------
-- 4. TAB: Settings
----------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        isEscaping = false
        AntiAfkEnabled = false
        if AntiAfkGui then AntiAfkGui:Destroy() end
        if AntiAfkConnection then AntiAfkConnection:Disconnect() end
        ToggleNoclip(false)
        Rayfield:Destroy()
    end,
})

SettingsTab:CreateLabel("GUI отображается на символ K")

SettingsTab:CreateButton({
    Name = "🚨 Этот скрипт бесплатный и в полном чистом коде, если вы купили это то это мошенничество, tiktok: @ssdkb ⚠️",
    Callback = function()
        setclipboard("https://www.tiktok.com/@ssdkb")
        Rayfield:Notify({
            Title = "Успешно!",
            Content = "Ссылка скопирована!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})
