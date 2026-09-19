-- =======================================================
-- GUI: AllSkins | Barabaka (v2.2 Fixed Keybind Edition)
-- Game: Rivals (Visual SkinChanger & Utility Suite)
-- =======================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local UserInputService = game:GetService("UserInputService")

local Window = Rayfield:CreateWindow({
   Name = "AllSkins | Barabaka ✦ v2.2",
   LoadingTitle = "AllSkins | Barabaka",
   LoadingSubtitle = "Загрузка интерфейса...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "BarabakaConfigs",
      FileName = "RivalsConfig"
   },
   Discord = { Enabled = false },
   KeySystem = false,
   Theme = "Ocean" -- Тёмно-синяя ночная эстетика
})

-- =======================================================
-- ЖЕСТКАЯ ПРИВЯЗКА КЛАВИШИ "K" ДЛЯ ОТКРЫТИЯ / СКРЫТИЯ MENU
-- =======================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
   if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
      local coreGui = game:GetService("CoreGui")
      local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
      local rayfieldUI = coreGui:FindFirstChild("Rayfield") or (playerGui and playerGui:FindFirstChild("Rayfield"))
      
      if rayfieldUI then
         rayfieldUI.Enabled = not rayfieldUI.Enabled
      end
   end
end)

-- =======================================================
-- СОСТОЯНИЕ
-- =======================================================
local isUnlocked = false
local currentStatus = "Не активен"

-- =======================================================
-- ВКЛАДКИ
-- =======================================================
local MainTab = Window:CreateTab("🎯 Главная", 2483186)
local SkinsTab = Window:CreateTab("🎨 Скины & Обертки", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Настройки GUI", 4483362458)

-- =======================================================
-- ВКЛАДКА 1: ГЛАВНАЯ
-- =======================================================
MainTab:CreateSection("Статус Системы")

local StatusLabel = MainTab:CreateLabel("Состояние: 🔴 " .. currentStatus)

MainTab:CreateSection("Основное Управление")

MainTab:CreateButton({
   Name = "🔓 Разблокировать все скины (Unlock All)",
   Callback = function()
      if isUnlocked then
         Rayfield:Notify({
            Title = "AllSkins | Barabaka",
            Content = "Скинчейнджер уже запущен и работает!",
            Duration = 3,
            Image = 2483186
         })
         return
      end

      local success, err = pcall(function()
         -- ===================================================
         -- ЯДРО СКИНЧЕЙНДЖЕРА (Skin, Charm, Dance, Wrap)
         -- ===================================================
         local Players = game:GetService("Players")
         local ReplicatedStorage = game:GetService("ReplicatedStorage")
         local HttpService = game:GetService("HttpService")
         local player = Players.LocalPlayer
         local playerScripts = player.PlayerScripts
         local controllers = playerScripts.Controllers
         
         local EnumLibrary = require(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
         if EnumLibrary then EnumLibrary:WaitForEnumBuilder() end
         local CosmeticLibrary = require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 10))
         local ItemLibrary = require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 10))
         local DataController = require(controllers:WaitForChild("PlayerDataController", 10))
         
         local equipped, favorites = {}, {}
         local constructingWeapon, viewingProfile = nil, nil

         local function cloneCosmetic(name, cosmeticType, options)
             local base = CosmeticLibrary.Cosmetics[name]
             if not base then return nil end
             local data = {}
             for key, value in pairs(base) do data[key] = value end
             data.Name = name
             data.Type = data.Type or cosmeticType
             data.Seed = data.Seed or math.random(1, 1000000)
             if EnumLibrary then
                 local s, enumId = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
                 if s and enumId then data.Enum, data.ObjectID = enumId, data.ObjectID or enumId end
             end
             if options then
                 if options.inverted ~= nil then data.Inverted = options.inverted end
                 if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly end
             end
             return data
         end

         local saveFile = "unlockall/config.json"
         local function saveConfig()
             if not writefile then return end
             pcall(function()
                 local config = {equipped = {}, favorites = favorites}
                 for weapon, cosmetics in pairs(equipped) do
                     config.equipped[weapon] = {}
                     for cosmeticType, cosmeticData in pairs(cosmetics) do
                         if cosmeticData and cosmeticData.Name then
                             config.equipped[weapon][cosmeticType] = {
                                 name = cosmeticData.Name, seed = cosmeticData.Seed, inverted = cosmeticData.Inverted
                             }
                         end
                     end
                 end
                 makefolder("unlockall")
                 writefile(saveFile, HttpService:JSONEncode(config))
             end)
         end

         local function loadConfig()
             if not readfile or not isfile or not isfile(saveFile) then return end
             pcall(function()
                 local config = HttpService:JSONDecode(readfile(saveFile))
                 if config.equipped then
                     for weapon, cosmetics in pairs(config.equipped) do
                         equipped[weapon] = {}
                         for cosmeticType, cosmeticData in pairs(cosmetics) do
                             local cloned = cloneCosmetic(cosmeticData.name, cosmeticType, {inverted = cosmeticData.inverted})
                             if cloned then cloned.Seed = cosmeticData.seed equipped[weapon][cosmeticType] = cloned end
                         end
                     end
                 end
                 favorites = config.favorites or {}
             end)
         end

         local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
         CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
             if name:find("MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
             return true
         end

         CosmeticLibrary.OwnsCosmeticNormally = function(self, inventory, name, weapon) return true end
         CosmeticLibrary.OwnsCosmeticUniversally = function(self, inventory, name, weapon) return true end
         CosmeticLibrary.OwnsCosmeticForWeapon = function(self, inventory, name, weapon) return true end

         local originalGet = DataController.Get
         DataController.Get = function(self, key)
             local data = originalGet(self, key)
             if key == "CosmeticInventory" then
                 local proxy = {}
                 if data then for k, v in pairs(data) do proxy[k] = v end end
                 return setmetatable(proxy, {__index = function(t, k) return true end})
             end
             if key == "FavoritedCosmetics" then
                 local result = data and table.clone(data) or {}
                 for weapon, favs in pairs(favorites) do
                     result[weapon] = result[weapon] or {}
                     for name, isFav in pairs(favs) do result[weapon][name] = isFav end
                 end
                 return result
             end
             return data
         end

         local originalGetWeaponData = DataController.GetWeaponData
         DataController.GetWeaponData = function(self, weaponName)
             local data = originalGetWeaponData(self, weaponName)
             if not data then return nil end
             local merged = {}
             for key, value in pairs(data) do merged[key] = value end
             merged.Name = weaponName
             if equipped[weaponName] then
                 for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do 
                     merged[cosmeticType] = cosmeticData
                 end
             end
             return merged
         end

         if hookmetamethod then
             local remotes = ReplicatedStorage:FindFirstChild("Remotes")
             local dataRemotes = remotes and remotes:FindFirstChild("Data")
             local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
             local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
             
             if equipRemote then
                 local oldNamecall
                 oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                     if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                     local args = {...}
                     if self == equipRemote then
                         local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                         equipped[weaponName] = equipped[weaponName] or {}
                         if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                             equipped[weaponName][cosmeticType] = nil
                             if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                         else
                             local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                             if cloned then equipped[weaponName][cosmeticType] = cloned end
                         end
                         task.defer(function()
                             pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
                             task.wait(0.2)
                             saveConfig()
                         end)
                         return
                     end
                     if self == favoriteRemote then
                         favorites[args[1]] = favorites[args[1]] or {}
                         favorites[args[1]][args[2]] = args[3] or nil
                         saveConfig()
                         task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                         return
                     end
                     return oldNamecall(self, ...)
                 end)
             end
         end

         local ClientItem
         pcall(function() ClientItem = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)

         if ClientItem and ClientItem._CreateViewModel then
             local originalCreateViewModel = ClientItem._CreateViewModel
             ClientItem._CreateViewModel = function(self, viewmodelRef)
                 local weaponName = self.Name
                 local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                 constructingWeapon = (weaponPlayer == player) and weaponName or nil
                 if weaponPlayer == player and equipped[weaponName] and viewmodelRef then
                     local dataKey = self:ToEnum("Data")
                     if viewmodelRef[dataKey] then
                         for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do
                             local typeKey = self:ToEnum(cosmeticType)
                             if typeKey then viewmodelRef[dataKey][typeKey] = cosmeticData end
                         end
                     end
                 end
                 local result = originalCreateViewModel(self, viewmodelRef)
                 constructingWeapon = nil
                 return result
             end
         end

         loadConfig()
      end)

      if success then
         isUnlocked = true
         currentStatus = "Активен и работает"
         StatusLabel:Set("Состояние: 🟢 " .. currentStatus)
         
         Rayfield:Notify({
            Title = "AllSkins | Barabaka",
            Content = "Успешно! Все предметы инвентаря разблокированы.",
            Duration = 5,
            Image = 2483186
         })
      else
         Rayfield:Notify({
            Title = "Ошибка Инжекта",
            Content = "Не удалось применить код: " .. tostring(err),
            Duration = 6
         })
      end
   end
})

MainTab:CreateButton({
   Name = "🔄 Принудительно обновить инвентарь",
   Callback = function()
      if not isUnlocked then
         Rayfield:Notify({
            Title = "Внимание",
            Content = "Сначала нажмите кнопку 'Unlock All'!",
            Duration = 3
         })
         return
      end
      
      pcall(function()
         local playerScripts = game:GetService("Players").LocalPlayer.PlayerScripts
         local DataController = require(playerScripts.Controllers.PlayerDataController)
         DataController.CurrentData:Replicate("WeaponInventory")
         DataController.CurrentData:Replicate("CosmeticInventory")
      end)

      Rayfield:Notify({
         Title = "Синхронизация",
         Content = "Инвентарь и отображение скинов обновлены!",
         Duration = 3,
         Image = 2483186
      })
   end
})

-- =======================================================
-- БАННЕР ВНИЗУ
-- =======================================================
MainTab:CreateSection("Визуальный Баннер")

MainTab:CreateParagraph({
   Title = "Barabaka Community",
   Content = "AllSkins | Visual Unlocker loaded successfully.",
   Image = 2483186
})

-- =======================================================
-- ВКЛАДКА 2: СКИНЫ
-- =======================================================
SkinsTab:CreateSection("Инструкция")

SkinsTab:CreateParagraph({
   Title = "💡 Как использовать?",
   Content = "После нажатия кнопки Unlock All зайдите в стандартный инвентарь игры Rivals и выбирайте любые скины, шармы или обертки."
})

SkinsTab:CreateParagraph({
   Title = "Кастомизация",
   Content = "Скрипт автоматически сохраняет надетое оружие в локальный конфиг.",
   Image = 2483186
})

-- =======================================================
-- ВКЛАДКА 3: НАСТРОЙКИ
-- =======================================================
SettingsTab:CreateSection("Управление")

SettingsTab:CreateParagraph({
   Title = "⌨️ Горячая клавиша",
   Content = "Бинд настраивать больше нельзя. Нажмите клавишу [ K ] на клавиатуре, чтобы открыть или скрыть меню."
})

SettingsTab:CreateButton({
   Name = "❌ Выгрузить скрипт",
   Callback = function()
      Rayfield:Destroy()
   end
})

Rayfield:Notify({
   Title = "AllSkins | Barabaka",
   Content = "Интерфейс загружен! Нажмите [K] для скрыть/показать.",
   Duration = 5,
   Image = 2483186
})
