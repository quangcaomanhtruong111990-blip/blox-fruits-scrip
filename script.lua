Config =
        Config or
        {
            Team = "Pirates",
            Configuration = {
                HideallPath = false,
                blackscreen = false,
                HideGui = false,
                HopWhenIdle = true,
                AutoHop = true,
                AutoHopDelay = 60 * 60,
                FpsBoost = true,
                ["IdleCheck"] = 150, -- every (x) seconds if not moving rejoin
            },
            Items = {
                -- Melees
                AutoFullyMelees = true,
                -- Swords
                Saber = true,
                CursedDualKatana = false,
                -- Guns
                SoulGuitar = false,
                -- Upgrades

                RaceV2 = false,
                AutoFarmFruitMastery = false,
                AutoEatFruit = 1,
                Eatlist = {}
            },
            Settings = {
                StayInSea2UntilHaveDarkFragments = false, -- bat cai nay se hop tim darkbeard / turn this on to force hop for darkbeard ( for sg )
                ["Fragments"] = 5000 -- Auto farm fragments until you have 5000 fragments to buy the chip
            }
}
repeat
    task.wait(0.5)
until game:IsLoaded()

-- Volt Performance Optimization Setup
local Volt = nil
pcall(function()
    -- Try to load Volt if available
    if typeof(volt) == "table" then
        Volt = volt
        print("[Volt] Volt detected and loaded")
    elseif typeof(getgenv().volt) == "table" then
        Volt = getgenv().volt
        print("[Volt] Volt detected from getgenv()")
    end
end)

-- Performance optimization flags
local UseVoltActors = Volt ~= nil
local PerformanceCache = {}

function CheckKick(v)
    if v.Name == 'ErrorPrompt' then
        task.wait(2)
        print(v.TitleFrame.ErrorTitle.Text)
        game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer( "teleport",game.PlaceId)
        v:Destroy()
    end
end
print = function()
    
end
repeat
    task.wait() 
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer('SetTeam', 'Pirates')
until game.Players.LocalPlayer.Character
game:GetService('CoreGui').RobloxPromptGui.promptOverlay.ChildAdded:Connect(CheckKick)
    if os.time() >= 1756319996 then
    --  while true do end
    end
    
        local checkdone = false


    local LogService = game:GetService("LogService")
    local GameName = "Blox Fruit"

    pcall(
        function()
            GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end
    )

    local StartTime = os.time()
    local Traces = {}

    -- Đã xóa hàm Build và hàm Report gửi qua Webhook Discord để tránh lỗi
    function Report(Message)
        -- Vô hiệu hóa tính năng gửi báo lỗi qua Webhook
    end

    function mmb()
        local Orders = {"Task1", "Task2", "Currencies", "Melees", "LiveTime", "DebugLine"}
        local Interface = {
            Instances = {}
        }

        local isVisible = true
        local isToggleOpen = false
        local player = game.Players.LocalPlayer

        repeat
            task.wait()
        until game.CoreGui

        local HopGui = Instance.new("ScreenGui")
        local NameHub = Instance.new("TextLabel")
        local UIStroke = Instance.new("UIStroke")
        local StrokeBounty = Instance.new("UIStroke")
        local Bounty = Instance.new("TextLabel")
        local ToggleButton = Instance.new("ImageButton")
        local ToggleContainer = Instance.new("Frame")
        local ToggleUIStroke = Instance.new("UIStroke")
        local ToggleIcon = Instance.new("TextLabel")

        -- Create a table to store UI references for blurring
        local UIReferences = {}

        HopGui.Name = "CyndralDev"
        HopGui.Parent = game:GetService("CoreGui")
        HopGui.Enabled = not Config.Configuration.HideGui
        HopGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        HopGui.IgnoreGuiInset = true

        NameHub.Name = "NameHub"
        NameHub.Parent = HopGui
        NameHub.AnchorPoint = Vector2.new(0.5, 0.5)
        NameHub.Position = UDim2.new(0.5, 0, 0.3, 0)
        NameHub.Size = UDim2.new(1, 0, 0, 80)
        NameHub.BackgroundTransparency = 0.999
        NameHub.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        NameHub.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NameHub.BorderSizePixel = 0
        NameHub.Font = Enum.Font.FredokaOne
        NameHub.Text = "kunblox.net"

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Parent = NameHub
        UIStroke.Color = Color3.fromRGB(0, 0, 0)
        UIStroke.Thickness = 1

        NameHub.TextColor3 = Color3.fromRGB(9, 255, 248)
        NameHub.TextSize = 50

        -- Create Toggle Button Container
        ToggleContainer.Name = "ToggleContainer"
        ToggleContainer.Parent = HopGui
        ToggleContainer.AnchorPoint = Vector2.new(1, 0)
        ToggleContainer.Position = UDim2.new(1, -20, 0, 20)
        ToggleContainer.Size = UDim2.new(0, 50, 0, 50)
        ToggleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleContainer.BackgroundTransparency = 0.2
        ToggleContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleContainer.BorderSizePixel = 0
        ToggleContainer.ClipsDescendants = true
        -- Make it circular
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = ToggleContainer

        -- Add stroke to toggle container
        ToggleUIStroke.Parent = ToggleContainer
        ToggleUIStroke.Color = Color3.fromRGB(9, 255, 248)
        ToggleUIStroke.Thickness = 2

        -- Create Toggle Button
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = ToggleContainer
        ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
        ToggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
        ToggleButton.Size = UDim2.new(1, 0, 1, 0)
        ToggleButton.BackgroundTransparency = 1
        ToggleButton.BorderSizePixel = 0

        -- Add toggle icon
        ToggleIcon.Name = "ToggleIcon"
        ToggleIcon.Parent = ToggleContainer
        ToggleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        ToggleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        ToggleIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
        ToggleIcon.BackgroundTransparency = 1
        ToggleIcon.BorderSizePixel = 0
        ToggleIcon.Font = Enum.Font.GothamBold
        ToggleIcon.Text = "👁️"
        ToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleIcon.TextSize = 24
        ToggleIcon.TextScaled = true

        local function createTextLabel(text, position, isImage)
            local StrokeBounty = Instance.new("UIStroke")
            local Bounty = Instance.new("TextLabel")
            Bounty.Name = "hmph ><"
            Bounty.Parent = HopGui
            Bounty.AnchorPoint = Vector2.new(0.5, 0.5)
            Bounty.Position = position
            Bounty.Size = UDim2.new(0, 200, 0, 30)
            Bounty.BackgroundTransparency = 0.999
            Bounty.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Bounty.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Bounty.BorderSizePixel = 0
            Bounty.Font = Enum.Font.FredokaOne
            Bounty.Text = text
            Bounty.TextColor3 = Color3.fromRGB(255, 255, 255)
            Bounty.TextSize = 13
            Bounty.RichText = true
            StrokeBounty.Parent = Bounty
            StrokeBounty.Color = Color3.fromRGB(0, 0, 0)
            StrokeBounty.Thickness = 1

            return Bounty
        end

        MainTextLabel = createTextLabel(" ", UDim2.new(0.5, 0, 0.4, 0))

        Interface.Instances.MainTextLabel = MainTextLabel

        for Index, OrderName in pairs(Orders) do
            Interface.Instances[OrderName] = createTextLabel("...", UDim2.new(0.5, 0, 0.45 + (.05 * Index), 0))
        end

        -- Custom blur effect that can blur other UIs
        local BlurManager = {}

        function BlurManager:Create()
            local blurFrame = Instance.new("Frame")
            blurFrame.Name = "BlurFrame"
            blurFrame.Parent = HopGui
            blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            blurFrame.BackgroundTransparency = 1
            blurFrame.BorderSizePixel = 0
            blurFrame.Size = UDim2.new(1, 0, 1, 0)
            blurFrame.Position = UDim2.new(0, 0, 0, 0)
            blurFrame.ZIndex = 0

            self.blurFrame = blurFrame
            self.blurIntensity = 0

            return self
        end

        function BlurManager:SetIntensity(intensity)
            intensity = math.clamp(intensity, 0, 0.95)
            self.blurIntensity = intensity

            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

            local tween = tweenService:Create(self.blurFrame, tweenInfo, {BackgroundTransparency = 1 - intensity})
            tween:Play()

            if not self.blurEffect then
                self.blurEffect = Instance.new("BlurEffect")
                self.blurEffect.Name = "CustomBlur"
                self.blurEffect.Parent = game.Lighting
                self.blurEffect.Enabled = true
            end

            local blurSizeTween = tweenService:Create(self.blurEffect, tweenInfo, {Size = intensity * 30})
            blurSizeTween:Play()

            for _, uiElement in pairs(UIReferences) do
                if uiElement and uiElement.Parent then
                    local uiTween = tweenService:Create(uiElement, tweenInfo, {BackgroundTransparency = uiElement._originalTransparency + (intensity * 0.5)})
                    uiTween:Play()
                end
            end
        end

        function BlurManager:RegisterUI(uiElement)
            if uiElement and uiElement:IsA("GuiObject") then
                uiElement._originalTransparency = uiElement.BackgroundTransparency
                table.insert(UIReferences, uiElement)
            end
        end

        local blurEffect = BlurManager:Create()

        function SetText(Name, Text)
            task.spawn(
                function()
                    local TextIns = Interface.Instances[Name]
                    if not TextIns then
                        return
                    end

                    if not isVisible then
                        TextIns.Text = Text
                        return
                    end

                    if TextIns.Text == Text then
                        return
                    end

                    local tweenService = game:GetService("TweenService")
                    local fadeOutInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                    local fadeOut = tweenService:Create(TextIns, fadeOutInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
                    fadeOut:Play()
                    fadeOut.Completed:Wait()

                    TextIns.Text = Text

                    local fadeInInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                    local fadeIn = tweenService:Create(TextIns, fadeInInfo, {TextTransparency = 0, TextStrokeTransparency = 0})
                    fadeIn:Play()
                end
            )
        end

        local OldExposureCompensation = game:GetService("Lighting").ExposureCompensation
        function ToggleUI(State)
            isToggleOpen = State or not isToggleOpen

            local contentLabels = {NameHub, MainTextLabel}
            for _, instance in pairs(Interface.Instances) do
                table.insert(contentLabels, instance)
            end

            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)

            if isToggleOpen then
                ToggleIcon.Text = "🔍"

                local rotationTween = tweenService:Create(ToggleIcon, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = 360})
                rotationTween:Play()
                rotationTween.Completed:Connect(function() ToggleIcon.Rotation = 0 end)

                for _, label in pairs(contentLabels) do
                    label.TextTransparency = 1

                    local tween = tweenService:Create(label, tweenInfo, {TextTransparency = 0})

                    if label:FindFirstChildOfClass("UIStroke") then
                        label:FindFirstChildOfClass("UIStroke").Transparency = 1

                        local strokeTween = tweenService:Create(label:FindFirstChildOfClass("UIStroke"), tweenInfo, {Transparency = 0})
                        strokeTween:Play()
                    end

                    tween:Play()
                end

                blurEffect:SetIntensity(0.4)
            else
                ToggleIcon.Text = "🔍"

                local shrinkTween = tweenService:Create(ToggleIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0.3, 0, 0.3, 0)})
                shrinkTween:Play()
                shrinkTween.Completed:Connect(
                    function()
                        local growTween = tweenService:Create(ToggleIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.7, 0, 0.7, 0)})
                        growTween:Play()
                    end
                )

                for _, label in pairs(contentLabels) do
                    local tween = tweenService:Create(label, tweenInfo, {TextTransparency = 1})

                    if label:FindFirstChildOfClass("UIStroke") then
                        local strokeTween = tweenService:Create(label:FindFirstChildOfClass("UIStroke"), tweenInfo, {Transparency = 1})
                        strokeTween:Play()
                    end

                    tween:Play()
                end

                blurEffect:SetIntensity(0)
            end

            isVisible = isToggleOpen
        end

        function Interface.RegisterForBlur(uiElement)
            blurEffect:RegisterUI(uiElement)
        end

        ToggleButton.MouseButton1Click:Connect(function() ToggleUI() end)

        ToggleButton.MouseEnter:Connect(
            function()
                local tweenService = game:GetService("TweenService")

                local pulseSequence = function()
                    local expandTween = tweenService:Create(ToggleContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 55, 0, 55)})
                    local glowTween = tweenService:Create(ToggleUIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(0, 255, 255), Thickness = 3})

                    expandTween:Play()
                    glowTween:Play()
                end

                pulseSequence()
            end
        )

        ToggleButton.MouseLeave:Connect(
            function()
                local tweenService = game:GetService("TweenService")
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                local shrinkTween = tweenService:Create(ToggleContainer, tweenInfo, {Size = UDim2.new(0, 50, 0, 50)})
                local strokeTween = tweenService:Create(ToggleUIStroke, tweenInfo, {Color = Color3.fromRGB(9, 255, 248), Thickness = 2})

                shrinkTween:Play()
                strokeTween:Play()
            end
        )

        function Interface.ToggleInterface(State)
            isToggleOpen = State

            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            if State then
                HopGui.Enabled = true
                ToggleIcon.Text = "👁️"
                blurEffect:SetIntensity(0.4)
            else
                ToggleIcon.Text = "🔍"
                blurEffect:SetIntensity(0)
            end

            isVisible = State
        end

        local function setupFloatingAnimation()
        end

        setupFloatingAnimation()

        ToggleUI(true)
        Interface.SetText = SetText
        Interface.ToggleUI = ToggleUI
        Interface.BlurManager = blurEffect

        if not isfile("fluent.lua") then
            writefile(
                "fluent.lua",
                game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
            )
        end

        local Fluent = loadstring(readfile("fluent.lua"))()
        local Animation = Instance.new("Animation")
        Animation.AnimationId = "http://www.roblox.com/asset/?id=1elutruahuabuahd"

        getgenv().alert = function(t1, t2)
            pcall(
                function()
                    Fluent:Notify(
                        {
                            Title = t1 or "",
                            Content = t2 or "",
                            Duration = 5
                        }
                    )
                end
            )
        end
        alert("Cyndral", "Endpoint reached")

        local CDN_HOST = "https://files.lumitone.xyz/"

        StartTime = os.time()

        OldSessionTime =
            isfile(".tdif-" .. game.Players.LocalPlayer.Name) and
            tonumber(readfile(".tdif-" .. game.Players.LocalPlayer.Name)) or
            0

           
        if Config.Configuration.blackscreen then 
        game:GetService("Lighting").ExposureCompensation = -math.huge
        end
        repeat
            wait()
        until game.Players.LocalPlayer.Character
        spawn(
            function()
                if true then return end
                game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("NewIslandLOD", 9999):Destroy()
                game:GetService("Players")
                LocalPlayer.PlayerScripts:WaitForChild("IslandLOD", 9999):Destroy()
            end
        )
        alert("wait 1", "ok")
        
        local Segmants = {
            "RawConstants",
            "Utilly",
            "QuestManager",
            "SpawnRegionLoader",
            "TweenController",
            "AttackController",
            "CombatController",
            "FunctionsHandler",
            "Hooks",
            "Debug",
            "Hop",
            "Storage"
        }

        StartTick = tick()
        repeat
            task.wait()
        until SetText
        alert("load 2")
        SetText("MainTextLabel", "Initalizing Script...")

        local FolderPath = "Rua_Hub/Blox_Fruit/Assets/"

        ScriptStorage = {
            IsInitalized = false,
            PlayerData = {},
            Melees = {},
            CurrentMeleeData = {},
            Enemies = {},
            Tools = {},
            Backpack = {},
            IgnoreStoreFruits = {},
            Connections = {
                LocalPlayer = {}
            },
            Task = {},
            Tracebacks = {},
            TaskController = {},
            TracebackUpdater = {},
            Interface = Interface,
            NPCs = {}
        }
        hookfunction(require(game.ReplicatedStorage.Reparent).Unparent, newcclosure(function()
            return function(...) end
        end)) 
        Players = game.Players
        LocalPlayer = Players.LocalPlayer
        Character = LocalPlayer.Character

        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

        PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
        Lighting = game:GetService("Lighting")

        Services = {}

        setmetatable(
            Services,
            {
                __index = function(_, Index)
                    return game:GetService(Index)
                end
            }
        )

        setmetatable(
            ScriptStorage.Enemies,
            {
                __index = function(_, Index)
                    return Services.Workspace.Enemies:FindFirstChild(Index) or
                        Services.ReplicatedStorage:FindFirstChild(Index)
                end
            }
        )

        setmetatable(
            ScriptStorage.Tools,
            {
                __index = function(Self, Index)
                    return LocalPlayer.Character:FindFirstChild(Index) or LocalPlayer.Backpack:FindFirstChild(Index)
                end
            }
        )

        setmetatable(
            ScriptStorage.NPCs,
            {
                __index = function(_, Index)
                    if not Index then return end 
                    return workspace.NPCs:FindFirstChild(Index) or game.ReplicatedStorage.NPCs:FindFirstChild(Index)
                end
            }
        )
        -- AFK Check System
        task.spawn(function()
            local lastPosition = nil
            local idleStartTime = nil
            
            while task.wait(1) do
                if not _G.Stop and Config.Configuration.IdleCheck and Config.Configuration.IdleCheck > 0 then
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local currentPosition = LocalPlayer.Character.HumanoidRootPart.Position
                            local currentTime = os.time()
                            
                            if lastPosition then
                                local distance = (currentPosition - lastPosition).Magnitude
                                
                                if distance >= 5 then
                                    idleStartTime = nil
                                else
                                    if not idleStartTime then
                                        idleStartTime = currentTime
                                    else
                                        if (currentTime - idleStartTime) >= Config.Configuration.IdleCheck then
                                            print("[AFK Check] Player is idle for " .. (currentTime - idleStartTime) .. " seconds, rejoining...")
                                            if Hop then
                                                Hop("Rejoin")
                                            else
                                                game.Players.LocalPlayer:Kick("Rejoining...")
                                            end
                                            return
                                        end
                                    end
                                end
                            end
                            
                            lastPosition = currentPosition
                        else
                            lastPosition = nil
                            idleStartTime = nil
                        end
                    end)
                end
            end
        end)
        function CreateTraceback(Index, Value)
            table.insert(
                ScriptStorage.Tracebacks,
                (GetCurrentDateTime() ..
                    " ( " .. DispTime(os.time() - StartTime, true) .. " ) after execution | " .. Index .. " | " .. Value)
            )
        end

        function SetTask(Index, Value)
            if ScriptStorage.Task[Index] == Value then
                return
            end
            local Parser = {
                MainTask = "Task1",
                SubTask = "Task2"
            }
            if Parser[Index] then
                if SetText then
                    SetText(Parser[Index], Index .. " : " .. Value)
                end
            end
            ScriptStorage.Task[Index] = Value
            ScriptStorage.Task[Index .. "-d"] = os.time()
        end

        Remotes = {}
        BindedMeleeNPCNames = {
            DragonClaw = "Sabi",
            FishmanKarate = "Water Kung-fu Teacher",
            Electro = "Mad Scientist",
            BlackLeg = "Dark Step Teacher",
            DeathStep = "Phoeyu, the Reformed",
            SharkmanKarate = "Sharkman Teacher",
            DragonTalon = "Uzoth",
            ElectricClaw = "Previous Hero",
            Godhuman = "Ancient Monk",
            Superhuman = "Martial Arts Master"
        }
        local MeleeCanBuy = {}
        setmetatable(Remotes, {
            __index = function(Self, Key)
                if Key ~= "CommF_" then
                    print("captured unregistered signal", key)
                    return Services.ReplicatedStorage.Remotes[Key]
                end
        
                local tbl = {
                    InvokeServer = function(Self, ...)
                        print("remote fired", ...)
                        local RemoteAction, IsValidate = ...
                        if string.find(RemoteAction, "Buy") == 1 and not IsValidate then
                            local MeleeName = string.gsub(RemoteAction, "Buy", '')
                            warn(table.find(MeleeCanBuy, MeleeName), MeleeName, #MeleeCanBuy)
                            if BindedMeleeNPCNames then
                                if table.find(MeleeCanBuy, MeleeName) then
        
                                    local NPC = ScriptStorage.NPCs[BindedMeleeNPCNames[MeleeName]]
                                    if NPC then
                                        local NPCPos = NPC.WorldPivot
                                        SetTask("SubTask", "Buying Melee - " .. MeleeName)
                                        getgenv().anchored = true
                                        if CaculateDistance(NPCPos) > 10 then
                                            repeat
                                                wait()
                                                TweenController.Create(NPCPos.Position)
        
                                            until CaculateDistance(NPCPos) < 10
                                            task.wait(3)
                                            Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
                                        end
                                    end
                                end
                            end
                        end
                        return Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
        
                    end
                }
        
                return tbl
            end
        })
        

        Tasks = {}

        function AwaitUntilPlayerLoaded(Player, Timeout)
            repeat
                task.wait()
            until Player.Character

            Player.Character:WaitForChild("Humanoid")

            repeat
                task.wait()
            until Player.Character.Humanoid.Health > 0
        end

        function AddPoint()
            local PointsValue = {}
            local Result

            for _, CInst in LocalPlayer.Data.Stats:GetChildren() do
                if CInst and CInst:FindFirstChild("Level") then
                    PointsValue[CInst.Name] = CInst.Level.Value
                end
            end
            if
                PointsValue.Defense < MaxLevel and
                    (PointsValue.Defense < (ScriptStorage.PlayerData.Level / 80) or MaxLevel - PointsValue.Melee < 100)
             then
                Result = "Defense"
            elseif PointsValue.Melee < MaxLevel then
                Result = "Melee"
            else
                Result = "Sword"
            end

            Remotes.CommF_:InvokeServer("AddPoint", Result, 999)
        end

        local Colors = {
            Currencies = {
                Level = "#00FF40",
                Beli = "#FF7800",
                Fragments = "#6600FF"
            },
            Races = {}
        }
        function RefreshPlayerData()
            for _, ChildInstance in LocalPlayer.Data:GetChildren() do
                pcall(
                    function()
                        local val = nil
                        if ChildInstance:IsA("IntValue") or ChildInstance:IsA("NumberValue") then
                            val = ChildInstance.Value
                        elseif ChildInstance:IsA("StringValue") then
                            val = ChildInstance.Value
                        elseif ChildInstance:IsA("BoolValue") then
                            val = ChildInstance.Value
                        end
                        if val == nil or val == 0 then
                            if ChildInstance:GetAttribute("Fragments") then
                                val = ChildInstance:GetAttribute("Fragments")
                            elseif ChildInstance:GetAttribute("Value") then
                                val = ChildInstance:GetAttribute("Value")
                            end
                        end
                        if val == nil and ChildInstance.Value ~= nil then
                            val = ChildInstance.Value
                        end
                        ScriptStorage.PlayerData[ChildInstance.Name] = val
                    end
                )
            end

            local Currencies = ""
            for Index, Value in ScriptStorage.PlayerData do
                local Color = Colors.Currencies[Index]
                if Color then
                    Currencies = Currencies .. '<font color="' .. Color .. '">' .. Index .. "</font>: " .. Value .. " "
                end
            end

            if ScriptStorage.Interface then
                SetText("Currencies", Currencies)
            end
        end

        function RefreshRace()
            local v27, v28 =
                Remotes.CommF_:InvokeServer("Alchemist", "1"),
                Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
            ScriptStorage.PlayerData.RaceLevel = 1
            if LocalPlayer.Character:FindFirstChild("RaceTransformed") then
                ScriptStorage.PlayerData.RaceLevel = 4
            elseif v28 == -2 then
                ScriptStorage.PlayerData.RaceLevel = 3
            elseif v27 == -2 then
                ScriptStorage.PlayerData.RaceLevel = 2
            end
        end

        function RefreshInventory()
            ScriptStorage.Backpack2 = {}
            for _, Value in Remotes.CommF_:InvokeServer("getInventory") do
                if Value.Type == 'Blox Fruit' and game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and
                table.find(Config.Items.Eatlist, Value.Name) then 
                    warn("Load fruit", Value.Name)
                    Remotes.CommF_:InvokeServer("LoadFruit", Value.Name)
                    task.wait(1)
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(FruitIdToName(Value.Name))
                end
                ScriptStorage.Backpack2[Value.Name] = Value
            end

            ScriptStorage.Backpack = ScriptStorage.Backpack2
        end

        function ResearchMoves(Child)
            if Child and tostring(Child) == "V" then
                if ScriptStorage.Connections.BurstCheck then
                    ScriptStorage.Connections.BurstCheck:Disconnect()
                    task.wait(1)
                end
                print("[ Debug ] Registering burst", Child)
                ScriptStorage.Connections.BurstCheck =
                    Child.Cooldown:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                    function()
                        if EnablingBurstDebounce and os.time() - EnablingBurstDebounce < 10 then
                            return
                        end
                        local Value = Child.Cooldown.AbsoluteSize.X
                        if Value < 3 then
                            EnablingBurstDebounce = os.time()
                            SendKey("V", 0)
                        end
                    end
                )
            end
        end

        function CheckMeleeBurstMove(Child)
            if Child.Name == "Black Leg" or Child.Name == "Death Step" then
                local UI = PlayerGui.Main.Skills:WaitForChild(Child.Name, 9)

                ResearchMoves(UI:WaitForChild("V"))
            end
        end

        function RefreshMelees(ReturnOrSet)
            local Result = ""

            for MeleeName, Level in ScriptStorage.Melees do
                Result = Result .. MeleeName .. ": " .. Level .. " "
            end
            Result = Result == "" and "[0]" or Result
            if ReturnOrSet then
                return Result
            end

            if ScriptStorage.Interface then
                SetText("Melees", Result)
            end
        end
        function MeleeCheck(Child)
            print("Melee check", Child)

            if Child and typeof(Child) == "Instance" and Child:IsA("Tool") then
                if Child.ToolTip == "Melee" then

                    if ScriptStorage.Connections.Melees then
                        ScriptStorage.Connections.Melees:Disconnect()
                    end

                    ScriptStorage.CurrentMeleeData.Name = Child.Name
                    pcall(
                        function()
                            ScriptStorage.Connections.Melees:Destroy()
                        end
                    )

                    if Child:FindFirstChild("Level") then
                        ScriptStorage.Connections.Melees =
                            Child.Level.Changed:Connect(
                            function(Value)
                                ScriptStorage.Melees[Child.Name] = Value
                                RefreshMelees()
                            end
                        )
                        ScriptStorage.Melees[Child.Name] = Child.Level.Value
                        RefreshMelees()
                    else
                        print("[MeleeCheck] Tool", Child.Name, "does not have Level property")
                    end
                elseif string.find(tostring(Child), "Fruit") then
                    task.spawn(
                        function()
                            if FunctionsHandler.Trevor and FunctionsHandler.Trevor:Get("IsLoadingFruit") then
                                return
                            end
                            
                            if table.find(ScriptStorage.IgnoreStoreFruits, Child:GetAttribute("OriginalName")) then
                                return
                            end
                            if
                                Config.Items.AutoEatFruit and
                                    game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and
                                    table.find(Config.Items.Eatlist, Child:GetAttribute("OriginalName"))
                             then
                                while not LocalPlayer.Character:FindFirstChild(Child.Name) and
                                    game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and
                                    task.wait(3) do
                                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(Child.Name)
                                end
                                LocalPlayer.Character:FindFirstChild(Child.Name).EatRemote:InvokeServer()
                            end
                            local StoreResult =
                                Remotes.CommF_:InvokeServer("StoreFruit", Child:GetAttribute("OriginalName"), Child)
                        end
                    )
                end
            end
        end
        print(0)
        SetText("MainTextLabel", "Refreshing Player Data 18219")
        print(-1)
        MeleeCheck(LocalPlayer.Character:FindFirstChildOfClass("Tool"))
        print(-2)
        RefreshPlayerData()
        print(-3)
        function RegisterLocalPlayerEventsConnection()
            task.spawn(
                function()
                    task.wait(2)
                    if LocalPlayer.Character:FindFirstChild("HasBuso") then
                        return
                    end
                    Remotes.CommF_:InvokeServer("Buso")
                end
            )

            for _, Connection in ScriptStorage.Connections.LocalPlayer do
                pcall(
                    function()
                        Connection:Disconnect()
                    end
                )
            end

            AwaitUntilPlayerLoaded(LocalPlayer)

            LocalPlayer:SetAttribute("IsAvailable", true)

            ScriptStorage.Connections.LocalPlayer["HealthCheck"] =
                LocalPlayer.Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("Health"):Connect(
                function()
                    local Health = LocalPlayer.Character.Humanoid.Health

                    LocalPlayer:SetAttribute("IsAvailable", Health > 10)
                    ScriptStorage.LocalPlayerHealth = Health
                end
            )

            ScriptStorage.Connections.LocalPlayer["Melee"] = LocalPlayer.Character.ChildAdded:Connect(MeleeCheck)
            ScriptStorage.Connections.LocalPlayer["Fruit"] = LocalPlayer.Backpack.ChildAdded:Connect(MeleeCheck)

            table.foreach(
                LocalPlayer.Backpack:GetChildren(),
                function(_, Melee)
                    MeleeCheck(Melee)
                end
            )

            LastIdleCheck = os.time()
            ScriptStorage.Connections.LocalPlayer.PositionChecker =
                LocalPlayer.Character.HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(
                function()
                    if os.time() == LastIdleCheck then
                        return
                    end
                    LastIdleCheck = os.time()
                    if oldPos then
                        if (LocalPlayer.Character.HumanoidRootPart.CFrame.p - oldPos).magnitude < 2 then
                            return
                        end
                    end
                    oldPos = (LocalPlayer.Character.HumanoidRootPart.CFrame.p)
                    LastIdling = os.time()
                end
            )

            local PointsInstance = LocalPlayer.Data:WaitForChild("Points")
            ScriptStorage.Connections.LocalPlayer.PointConnection =
                PointsInstance:GetPropertyChangedSignal("Value"):Connect(
                function()
                    local CurrentValue = LocalPlayer.Data:WaitForChild("Points")
                    if OldPointValue == CurrentValue then
                        return
                    end

                    OldPointValue = CurrentValue
                    task.wait(1)
                    AddPoint()
                end
            )
        end
        RegisterLocalPlayerEventsConnection(LocalPlayer)

        print(-4)
        game.Players.LocalPlayer.CharacterAdded:Connect(
            function(Character)
                print("[ Debug ] re-registering events")
                RegisterLocalPlayerEventsConnection(LocalPlayer)
            end
        )

        task.spawn(
            function()
                if LocalPlayer.Character:FindFirstChild("HasBuso") then
                    return
                end
                Remotes.CommF_:InvokeServer("Buso")
            end
        )

        print(1)
        MeleesTable = {
            "Black Leg",
            "Electro",
            "Fishman Karate",
            "Dragon Claw",
            "Superhuman",
            "Death Step",
            "Electric Claw",
            "Sharkman Karate",
            "Dragon Talon",
            "Godhuman",
            "SanguineArt"
        }

        MeleesId = {
            "BlackLeg",
            "Electro",
            "FishmanKarate",
            "DragonClaw",
            "Superhuman",
            "DeathStep",
            "ElectricClaw",
            "SharkmanKarate",
            "DragonTalon",
            "Godhuman",
            "SanguineArt"
        }

        MeleePrices = {
            ["Black Leg"] = {
                Price = {
                    Beli = 150000
                },
                Id = "BlackLeg",
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                position = CFrame.new(),
                Buy = function(Check)
                  
                    return BuyMelee("BlackLeg", Check,"Dark Step Teacher")
                end
            },
            ["Electro"] = {
                Price = {
                    Beli = 500000
                },
                Id = "Electro",
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                   
                    return BuyMelee("Electro", Check,"Mad Scientist")
                end
            },
            ["Fishman Karate"] = {
                Price = {
                    Beli = 750000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("FishmanKarate", Check, "Water Kung-fu Teacher")
                end
            },
            ["Dragon Claw"] = {
                Price = {
                    Fragments = 1500
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                   
                    return BuyMelee("DragonClaw", Check, "Sabi")
                end
            },
            ["Superhuman"] = {
                Price = {
                    Beli = 3000000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("Superhuman", Check,"Martial Arts Master")                    
                end
            },
            ["Death Step"] = {
                Price = {
                    Beli = 2500000,
                    Fragments = 5000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("DeathStep", Check,"Phoeyu, the Reformed")
                end
            },
            ["Sharkman Karate"] = {
                Price = {
                    Beli = 2500000,
                    Fragments = 5000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                   
                    return BuyMelee("SharkmanKarate", Check,"Sharkman Teacher")
                end
            },
            ["Dragon Talon"] = {
                Price = {
                    Beli = 2500000,
                    Fragments = 5000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                  
                    return BuyMelee("DragonTalon", Check,"Uzoth")
                end
            },
            ["Electric Claw"] = {
                Price = {
                    Beli = 2500000,
                    Fragments = 5000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("ElectricClaw", Check,"Previous Hero")
                end
            },
            
            
            ["Godhuman"] = {
                Price = {
                    Beli = 5000000,
                    Fragments = 5000
                },
                NextLevelRequirement = 350,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("Godhuman", Check,"Ancient Monk")
                end
            }
        }

        DropItemData = {
            
        }

        GodhumanMaterials = {
            ["Fish Tail"] = {
                20,
                3,
                {
                    "Fishman Raider",
                    "Fishman Captain"
                },
                {
                    "DeepForestIsland3",
                    1,
                    1775,
                    "Turtle Adventure Quest Giver"
                }
            },
            ["Dragon Scale"] = {
                10,
                3,
                {
                    "Dragon Crew Warrior",
                    "Dragon Crew Archer"
                },
                {
                    "DragonCrewQuest",
                    1,
                    1575,
                    "Dragon Crew Quest Giver"
                }
            },
            ["Magma Ore"] = {
                20,
                2,
                {
                    "Magma Ninja"
                },
                {
                    "FireSideQuest",
                    1,
                    1100,
                    "Fire Quest Giver"
                }
            },
            ["Mystic Droplet"] = {
                10,
                2,
                {
                    "Sea Soldier",
                    "Water Fighter"
                },
                {
                    "ForgottenQuest",
                    2,
                    1425,
                    "Forgotten Quest Giver"
                }
            }
        }

        SeaIndexes = {"Main", "Dressrosa", "Zou"}

        TasksOrder = {
            "ExpRedeem",
            "SoulGuitar",
            "Tushita",
            "SpecialBossesTask",
            "RaidController",
            "Trevor",
            "UtillyItemsActivitation",
            "ColosseumPuzzle",
            "ThirdSeaPuzzle",
            "Yama",
            "Saber",
            "PirateRaid",
            "SecondSeaPuzzle",
            "ThirdSeaPuzzle",
            "CollectDrops",
            "BossesTask",
            "LevelFarm"
        }

        MaxLevel = 2800

        placeId = game.PlaceId
        if placeId == 2753915549 or placeId == 85211729168715 then
            Sea = "Main"
            SeaIndex = 1
        elseif placeId == 4442272183 or placeId == 79091703265657 then
            Sea = "Dressrosa"
            SeaIndex = 2
        elseif placeId == 7449423635 or placeId == 100117331123089 then
            Sea = "Zou"
            SeaIndex = 3
        end
        
    
        Portals =
            (
           
                {
            {
                Vector3.new(-7894.6201171875, 5545.49169921875, -380.246346191406),
                Vector3.new(-4607.82275390625, 872.5422973632812, -1667.556884765625),
                Vector3.new(61163.8515625, 11.759522438049316, 1819.7841796875),
                Vector3.new(3876.280517578125, 35.10614013671875, -1939.3201904296875)
            },
            {
                Vector3.new(-288.46246337890625, 306.130615234375, 597.9988403320312),
                Vector3.new(2284.912109375, 15.152046203613281, 905.48291015625),
                Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
                Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422)
            },
            {}
        })[SeaIndex]

        BossesOrder = {
            "Awakened Ice Admiral", 
            "Tide Keeper", 
            "Deandre", 
            "Urban", 
            "Diablo", 
            "Soul Reaper", 
            "Cake Prince"
        }
        BossesOrderLevel = {
            ["Awakened Ice Admiral"] = 700,
            ["Tide Keeper"] = 700,
            ["Deandre"] = 1500,
            ["Urban"] = 1500,
            ["Diablo"] = 1500,
            ["Cake Prince"] = 1500,
            ["Soul Reaper"] = 1500
        }

        BossesOrderWL = {
            ["Deandre"] = 1500,
            ["Urban"] = 1500,
            ["Diablo"] = 1500,
            ["Cake Prince"] = 1500,
            ["Don Swan"] = 1100,
            ["Awakened Ice Admiral"] = 700,
            ["Tide Keeper"] = 700
        }

        SpecialBossesOrder = {
            ["Core"] = 700,
            ["Darkbeard"] = 700,
            ["rip_indra True Form"] = 1500,
            ["Dough King"] = 1500
        }

        BlankTablets = {
            "Segment6",
            "Segment2",
            "Segment8",
            "Segment9",
            "Segment5"
        }

        Trophy = {
            ["Segment1"] = "Trophy1",
            ["Segment3"] = "Trophy2",
            ["Segment4"] = "Trophy3",
            ["Segment7"] = "Trophy4",
            ["Segment10"] = "Trophy5"
        }

        Pipes = {
            ["Part1"] = "Really black",
            ["Part2"] = "Really black",
            ["Part3"] = "Dusty Rose",
            ["Part4"] = "Storm blue",
            ["Part5"] = "Really black",
            ["Part6"] = "Parsley green",
            ["Part7"] = "Really black",
            ["Part8"] = "Dusty Rose",
            ["Part9"] = "Really black",
            ["Part10"] = "Storm blue"
        }

        function ConvertTo(Type, Instance)
            return Type.new(Instance.X, Instance.Y, Instance.Z)
        end

        function CaculateDistance(Origin, Desnitation)
            if not Origin then
                return 0
            end

            Desnitation = Desnitation or game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            local Origin, Desnitation = ConvertTo(Vector3, Origin), ConvertTo(Vector3, Desnitation)

            return (Origin - Desnitation).magnitude
        end

        function DispTime(time, cc)
            time = tonumber(time)
            if not time then
                return "[err]"
            end
            local days = math.floor(time / 86400)
            local hours = math.floor(math.fmod(time, 86400) / 3600)
            local minutes = math.floor(math.fmod(time, 3600) / 60)
            local seconds = math.floor(math.fmod(time, 60))
            if cc then
                return (days .. "day, " .. hours .. "hrs, " .. minutes .. "min, " .. seconds .. "sec.")
            end
            return (days .. "day, " .. hours .. "hrs.")
        end

        function GetCurrentDateTime()
            local now = os.date("*t")

            local hour = now.hour
            local minute = now.min
            local day = now.day
            local month = now.month
            local year = now.year
            local weekday = now.wday

            local formattedTime = string.format("%02d:%02d ", hour, minute)

            local weekdays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
            local formattedWeekday = weekdays[weekday]

            local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
            local formattedMonth = months[month]

            local formattedDate = string.format("%s, %s %d %d", formattedWeekday, formattedMonth, day, year)

            return formattedTime .. formattedDate
        end

    
        function RoundVector3Down(vec)
            return Vector3.new(math.floor(vec.X / 10) * 10, math.floor(vec.Y / 10) * 10, math.floor(vec.Z / 10) * 10)
        end

        local Angle = 30
        lastChange = tick()
        CaculateCircreDirection = function(Position)
            if Angle > 50000 then
                Angle = 60
            end

            Angle = Angle + ((tick() - lastChange) > .4 and 80 or 0)

            if tick() - lastChange > .4 then
                lastChange = tick()
            end

            local sum = Position + Vector3.new(math.cos(math.rad(Angle)) * 40, 0, math.sin(math.rad(Angle)) * 40)
            return CFrame.new(RoundVector3Down(sum.p))
        end

        function GetMonAsSortedRange()
            local Result = {}

            table.foreach(
                Services.Workspace.Enemies:GetChildren(),
                function(_, Mon)
                    if
                        Mon and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and
                            Mon.Humanoid.Health > 0
                     then
                        table.insert(Result, Mon)
                    end
                end
            )

            table.foreach(
                game.ReplicatedStorage:GetChildren(),
                function(_, Mon)
                    if
                        Mon and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and
                            Mon.Humanoid.Health > 0
                     then
                        table.insert(Result, Mon)
                    end
                end
            )

            table.sort(
                Result,
                function(C1, C2)
                    return CaculateDistance(C1.HumanoidRootPart.CFrame) < CaculateDistance(C2.HumanoidRootPart.CFrame)
                end
            )

            return Result
        end
        print(1.5)
        function GetMeleeIdByName(MeleeName)
            for Index, Melee in MeleesTable do
                if Melee == MeleeName then
                    return MeleesId[Index]
                end
            end
        end
        function getpos(npcname)
            for i,v in game:GetService("ReplicatedStorage").NPCs:GetChildren() do
                if v.Name == npcname then
                    return v.HumanoidRootPart.CFrame
                end
            end
            for i,v in workspace.NPCs:GetChildren() do
                if v.Name == npcname then
                    return v.HumanoidRootPart.CFrame
                end
            end
        end


        function SendKey(key, hold)
            (function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
                task.wait(hold)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
            end)()
        end

        function FruitIdToName(FruitId)
            local ParserResult = string.match(FruitId, "(((%u)%-?)([^-.]+))$")

            return ParserResult .. " Fruit"
        end

        function Split(inputstr, sep)
            if sep == nil then
                sep = "%s"
            end
            local t = {}
            for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
                table.insert(t, str)
            end
            return t
        end

        function FruitNameToId(FruitName)
            local Id = Split(FruitName)[1]
            return Id .. "-" .. Id
        end

        local QuestManager = {
            CurrentLevel = 2,
            DoubleQuest = true,
            CurrentQuests = {},
            BlacklistedQuestIds = {
                BartiloQuest = 1,
                CitizenQuest = 1,
                Trainees = 1,
                MarineQuest = 1,
                ImpelQuest = 1
            }
        }

        local NpcList = require(game.ReplicatedStorage.GuideModule).Data.NPCList

        repeat
            task.wait()
        until game.Players.LocalPlayer.DataLoaded and ScriptStorage

        QuestManager.Quests = require(game.ReplicatedStorage.Quests)

        function QuestManager.Set(Self, Index, Value)
            Self[Index] = Value
        end

        function QuestManager.RefreshQuest(Self)
            while not ScriptStorage.PlayerData.Level do
                task.wait(1)
                print("[ Debug ] Waiting for LocalPlayer datas.")
            end

            local QuestLevelFlag = 0
            local CurrentQuestData

            for QuestID, QuestDatas in QuestManager.Quests do
                if not QuestManager.BlacklistedQuestIds[QuestID] then
                    if
                        (QuestDatas[1].LevelReq >= QuestLevelFlag and
                            QuestDatas[1].LevelReq <= ScriptStorage.PlayerData.Level)
                     then
                        QuestLevelFlag = QuestDatas[1].LevelReq
                        CurrentQuestData = QuestDatas
                        Self.CurrentQuestId = QuestID
                        if ScriptStorage.PlayerData.Level >= 1500 and SeaIndex == 2 and QuestID == "ForgottenQuest" then
                            break
                        end
                    end
                end
            end

            local LastQuest = CurrentQuestData[#CurrentQuestData]

            for _, Count in LastQuest.Task do
                if Count == 1 then
                    table.remove(CurrentQuestData, #CurrentQuestData)
                end
            end

            for i, v in require(game.ReplicatedStorage.GuideModule).Data.NPCList do
                for i1, v1 in v.Levels do
                    if v1 == CurrentQuestData[#CurrentQuestData].LevelReq then
                        Self.CurrentNpc = i.CFrame
                    end
                end
            end

            Self.CurrentQuests = CurrentQuestData
        end

        function QuestManager.GetCurrentQuest(Self)
            local QuestIndex =
                Self.CurrentQuests[Self.CurrentLevel] and
                Self.CurrentQuests[Self.CurrentLevel].LevelReq <= ScriptStorage.PlayerData.Level and
                Self.CurrentLevel or
                1

            for Name in Self.CurrentQuests[QuestIndex].Task do
                return Name, Self.CurrentNpc, Self.CurrentQuestId, QuestIndex, Self.CurrentQuests[QuestIndex].Name
            end
        end

        function QuestManager.MarkAsCompleted(Self)
            Self.CurrentLevel = Self.CurrentLevel == 2 and 1 or 2
        end

        function QuestManager.AbandonQuest()
            print("Abandon quest")
            Remotes.CommF_:InvokeServer("AbandonQuest")
        end

        function QuestManager.GetCurrentClaimQuest(RawResponse)
            local QuestTitle =
                game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible and
                game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:gsub(
                    "%s*Defeat%s*(%d*)%s*(.-)%s*%b()",
                    "%2"
                )
            return (type(QuestTitle) == "string" and string.gsub(QuestTitle, "Military ", "Mil. ") or QuestTitle), game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
        end

        function QuestManager.StartQuest(QuestId, QuestLevel)
            return Remotes.CommF_:InvokeServer("StartQuest", QuestId, QuestLevel)
        end

        ScriptStorage.MobRegions = {}
        for _, Region in game:GetService("ReplicatedStorage").FortBuilderReplicatedSpawnPositionsFolder:GetChildren() do
            ScriptStorage.MobRegions[tostring(Region)] = ScriptStorage.MobRegions[tostring(Region)] or {}
            table.insert(ScriptStorage.MobRegions[tostring(Region)], Region.CFrame)
        end

        TweenController = {}
        local LastestTeleportToHomePoint = 0
        local Entries = {}
        for _, NPC in game.ReplicatedStorage.NPCs:GetChildren() do
            if NPC.Name == "Set Home Point" then
                table.insert(Entries, NPC:GetModelCFrame())
            end
        end
        local function NoclipLoop()
            speaker = LocalPlayer
            if speaker.Character ~= nil then
                for _, child in pairs(speaker.Character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= nil then
                        child.CanCollide = false
                    end
                end
            end
        end
        Noclipping = Services.RunService.Stepped:Connect(NoclipLoop)
        function GetPortal(Position)
            local Nearest, Current = 9e9, nil
            for _, Portal in Portals do
                local Dist1 = CaculateDistance(Portal, Position)
                if Dist1 < (CaculateDistance(Position) - 300) and Dist1 < Nearest then
                    Nearest = Dist1
                    Current = Portal
                end
            end
            if Current then
                Remotes.CommF_:InvokeServer("requestEntrance", Current)
                return task.wait()
            end
        end
        function GetEntries(Position)
            local Nearest, Current = 9e9, nil
            for _, Entry in Entries do
                local Dist1 = CaculateDistance(Entry, Position)
                if Dist1 < (CaculateDistance(Position) - 700) and Dist1 < Nearest then
                    Nearest = Dist1
                    Current = Entry
                end
            end
            if Current then
                if os.time() - LastestTeleportToHomePoint > 30 then
                    for i = 1, 10, 1 do
                        task.wait()
                    end
                end
            end
        end
        local lp = game.Players.LocalPlayer
        local usebypassteleport = true
        function CheckNearestTeleporter(vcs)
            vcspos = vcs.Position
            min = math.huge
            min2 = math.huge
            local placeId = game.PlaceId
            if placeId == 2753915549 then
                OldWorld = true
            elseif placeId == 4442272183 then
                NewWorld = true
            elseif placeId == 7449423635 then
                ThreeWorld = true
            end
            if ThreeWorld then
                TableLocations = {
                    ["Caslte On The Sea"] = Vector3.new(- 5058.77490234375, 314.5155029296875, - 3155.88330078125),
                    ["Hydra"] = Vector3.new(5756.83740234375, 610.4240112304688, - 253.9253692626953),
                    ["Mansion"] = Vector3.new(- 12463.8740234375, 374.9144592285156, - 7523.77392578125),
                    ["Temple of Time"] = Vector3.new(28282.5703125, 14896.8505859375, 105.1042709350586)
                }
            elseif NewWorld then
                TableLocations = {
                    ["122"] = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
                    ["3032"] = Vector3.new(- 6508.5581054688, 150.034996032715, - 132.83953857422)
                }
            elseif OldWorld then
                TableLocations = {
                    ["1"] = Vector3.new(- 7894.6201171875, 5545.49169921875, - 380.2467346191406),
                    ["2"] = Vector3.new(- 4607.82275390625, 872.5422973632812, - 1667.556884765625),
                    ["3"] = Vector3.new(61163.8515625, 11.759522438049316, 1819.7841796875),
                    ["4"] = Vector3.new(3876.280517578125, 35.10614013671875, - 1939.3201904296875)
                }
            end
            TableLocations2 = {}
            if TableLocations then
                for i, v in pairs(TableLocations) do
                    TableLocations2[i] = (v - vcspos).Magnitude
                end
                for i, v in pairs(TableLocations2) do
                    if v < min then
                        min = v
                        min2 = v
                    end
                end
                for i, v in pairs(TableLocations2) do
                    if v < min then
                        min = v
                        min2 = v
                    end
                end
                for i, v in pairs(TableLocations2) do
                    if v <= min then
                        choose = TableLocations[i]
                    end
                end
                min3 = (vcspos - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if min2 <= min3 then
                    return choose
                end
            end
            return false
        end

        function requestEntrance(vector3)
            local args = {
                [1] = "requestEntrance",
                [2] = vector3
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
        end
        
        -- TweenController
        function TweenController.Create(Position)
            local Character = game.Players.LocalPlayer.Character
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
            if not Position or TweenDebounce or TweenController._isCreating then return end
        
            local TargetCFrame = typeof(Position) ~= "CFrame" and CFrame.new(Position) or Position
            TargetCFrame = CFrame.new(TargetCFrame.Position)
        
            local RootPart = Character.HumanoidRootPart
            local CurrentDist = (RootPart.Position - TargetCFrame.Position).Magnitude
        
            if TweenInstance and TweenInstance.PlaybackState == Enum.PlaybackState.Playing then
                if CurrentDist < 5 then return end
            end
        
            TweenController._isCreating = true
        
            pcall(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        
            local head = Character:FindFirstChild("Head")
            if head and not head:FindFirstChild("eltrul") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "eltrul"
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                bv.Velocity = Vector3.zero
                bv.Parent = head
            end
        
            if CurrentDist > 500 then
                if SeaIndex ~= 3 then
                    GetPortal(TargetCFrame)
                end
            end
        
            if SeaIndex == 3 and (TargetCFrame.Position - Vector3.new(11256, -2138, 9888)).Magnitude < (CurrentDist - 700) then
                local SubmarinePos = CFrame.new(-16269, 23, 1371)
                if (RootPart.Position - SubmarinePos.Position).Magnitude > 60 then
                    TweenController._isCreating = false
                    TweenController.Create(SubmarinePos)
                    return
                end
                pcall(function()
                    require(game.ReplicatedStorage.Modules.Net):RemoteFunction("SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
                end)
                TweenController._isCreating = false
                return
            end
        
            if TweenInstance then
                TweenInstance:Cancel()
            end
        
            local Speed = (CurrentDist < 18) and 25 or 330
            local Time = CurrentDist / Speed
        
            TweenInstance = Services.TweenService:Create(
                RootPart,
                TweenInfo.new(Time, Enum.EasingStyle.Linear),
                {CFrame = TargetCFrame}
            )
            
            TweenInstance:Play()
        
            task.delay(0.1, function()
                TweenController._isCreating = false
            end)
        end

        local AttackController = {}
        function BuyMelee(M1, Check, NPCName)
            if M1 == "DragonClaw" then
                if Check then
                    RefreshPlayerData()
                    local PlayerData = ScriptStorage.PlayerData
                    local RequiredFragments = 1500
                    local HasEnoughFragments = PlayerData and PlayerData.Fragments and PlayerData.Fragments >= RequiredFragments

                    if HasEnoughFragments and not table.find(MeleeCanBuy, M1) then
                        warn("Inserted DragonClaw")
                        table.insert(MeleeCanBuy, M1)
                    end
                    return HasEnoughFragments
                end

                if SeaIndex == 3 then
                    local SabiPos = CFrame.new(-4979.9091796875, 371.34295654296875, -3205.458251953125)
                    SetTask("SubTask", "Buying Melee - Dragon Claw (Sea 3)")
                    getgenv().anchored = true
                    if CaculateDistance(SabiPos) > 10 then
                        repeat
                            task.wait()
                            TweenController.Create(SabiPos)
                        until CaculateDistance(SabiPos) < 10
                        task.wait(3)
                    end
                    return Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
                end

                if NPCName and ScriptStorage.NPCs[NPCName] then
                    local NPC = ScriptStorage.NPCs[NPCName]
                    if NPC then
                        local NPCPos = nil
                        if NPC.WorldPivot then
                            NPCPos = NPC.WorldPivot
                        elseif NPC:FindFirstChild("HumanoidRootPart") then
                            NPCPos = NPC.HumanoidRootPart.CFrame
                        end

                        if NPCPos then
                            SetTask("SubTask", "Buying Melee - Dragon Claw (Sea 2)")
                            getgenv().anchored = true
                            local NPCPosition = NPCPos.Position or (NPCPos and NPCPos.Position)
                            if NPCPosition and CaculateDistance(NPCPosition) > 10 then
                                repeat
                                    task.wait()
                                    TweenController.Create(NPCPosition)
                                until CaculateDistance(NPCPosition) < 10
                                task.wait(3)
                            end
                        end
                    end
                end
                return Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
            end 
            if Check then
                local Response_ = Remotes.CommF_:InvokeServer("Buy" .. M1, true)
                print("Response_", Response_ == 1, typeof(Response_))
                if type(Response_) == "number" and not table.find(MeleeCanBuy,M1) then
                    table.insert(MeleeCanBuy, M1)
                    warn("Inserted " .. M1)
                end
                return Response_ == 1
            end
            return Remotes.CommF_:InvokeServer("Buy" .. M1)
        end

        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Workspace = game:GetService("Workspace")
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local Player = Players.LocalPlayer
        local Modules = ReplicatedStorage:WaitForChild("Modules")
        local Net = Modules:WaitForChild("Net")
        local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
        local RegisterHit = Net:WaitForChild("RE/RegisterHit")
        local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")
        local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")
        local Modules = game.ReplicatedStorage.Modules
        local Net = Modules.Net
        local Register_Hit, Register_Attack = Net:WaitForChild("RE/RegisterHit"), Net:WaitForChild("RE/RegisterAttack")
        local Funcs = {}
        function GetAllBladeHits()
            bladehits = {}
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if
                    v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and
                        (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <=
                            65
                 then
                    table.insert(bladehits, v)
                end
            end
            return bladehits
        end
        function Getplayerhit()
            bladehits = {}
            for _, v in pairs(workspace.Characters:GetChildren()) do
                if
                    v.Name ~= game.Players.LocalPlayer.Name and v:FindFirstChild("Humanoid") and
                        v:FindFirstChild("HumanoidRootPart") and
                        v.Humanoid.Health > 0 and
                        (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <=
                            65
                 then
                    table.insert(bladehits, v)
                end
            end
            return bladehits
        end

        local Net = (Services.ReplicatedStorage.Modules.Net)

        local RegisterAttack = require(Net):RemoteEvent("RegisterAttack", true)
        local RegisterHit = require(Net):RemoteEvent("RegisterHit", true)

        function Funcs:Attack()
            local bladehits = {}
            for r, v in pairs(GetAllBladeHits()) do
                table.insert(bladehits, v)
            end
            for r, v in pairs(Getplayerhit()) do
                table.insert(bladehits, v)
            end

            if #bladehits == 0 then
                return
            end

            local args = {
                [1] = nil,
                [2] = {},
                [4] = "078da341"
            }
            for r, v in pairs(bladehits) do
                RegisterAttack:FireServer(0)
                if not args[1] then
                    args[1] = v.Head
                end
                table.insert(
                    args[2],
                    {
                        [1] = v,
                        [2] = v.HumanoidRootPart
                    }
                )
                table.insert(args[2], v)
            end

            RegisterHit:FireServer(unpack(args))
        end

        local FastAttackLoop = function()
            while task.wait(.06) do
                if _G.FastAttack == os.time() then
                    pcall(
                        function()
                            Funcs:Attack()
                        end
                    )
                end
            end
        end
        
        if UseVoltActors and Volt and Volt.Actor then
            pcall(function()
                local actor = Volt.Actor.new()
                actor:Call(FastAttackLoop)
            end)
        else
            task.spawn(FastAttackLoop)
        end

        function AttackController.Attack(MonResult)
            pcall(
                function()
                    _G.FastAttack = os.time()
                end
            )
        end

        CombatController = {
            GRAB = true,
            GRAB_DISTANCE = SeaIndex == 1 and 250 or 350,
            MAX_ATTACK_DURATION = 3,
            MAX_ATTACK_DURATION_2 = 60,
            LEVITATE_TIME = 1,
            CurrentIndex = 1
        }
        
        LastFound = os.time()

        function CombatController.Grab(MobName)
            pcall(sethiddenproperty, game.Players.LocalPlayer, "SimulationRadius", math.huge)
            if not CombatController.GRAB or GrabDebounce == os.time() then
            end
            GrabDebounce = os.time()

            local MidPoint, Count = Vector3.zero, 0
            ForcePosition = nil
            local MobsTable = {}

            for _, Mon in Services.Workspace.Enemies:GetChildren() do
                if Mon.Name == MobName then
                    if Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and
                            Mon.Humanoid.Health > 0 then
                        local MonPosition = Mon.HumanoidRootPart.Position
                        if MonPosition and isnetworkowner(Mon.PrimaryPart) then
                            if
                                not ForcePosition or
                                    CaculateDistance(MonPosition, ForcePosition) < CombatController.GRAB_DISTANCE
                             then
                                Count = Count + 1
                                Mon:SetAttribute("OldPosition", Mon:GetAttribute("OldPosition") or MonPosition)
                                MidPoint = MidPoint + MonPosition
                                ForcePosition = ForcePosition or MonPosition

                                table.insert(MobsTable, Mon)
                            end
                        end
                    end
                end
            end
            MidPoint = CFrame.new(MidPoint / Count)

            table.foreach(
                MobsTable,
                function(_, ChildInstance)
                    (function()
                        if ChildInstance:GetAttribute("IgnoreGrab") then
                            return
                        end
                        if (ChildInstance:GetAttribute("FailureCount") or 0) > 7 then
                            return
                        end
                        local RootPart = ChildInstance:FindFirstChild("HumanoidRootPart")
                        local BodyVelocity = RootPart:FindFirstChild("FarmingVelocity")
                        if not BodyVelocity then
                            BodyVelocity = Instance.new("BodyVelocity")
                            BodyVelocity.Name = "FarmingVelocity"
                            BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                            BodyVelocity.Parent = RootPart
                        end

                        BodyVelocity.Velocity = Vector3.new(0, 0, 0)

                        local BodyPosition = RootPart:FindFirstChild("FarmingPosition")
                        if not BodyPosition then
                            BodyPosition = Instance.new("BodyPosition")
                            BodyPosition.Name = "FarmingPosition"
                            BodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
                            BodyPosition.P = 4.12
                            BodyPosition.D = 1000
                            BodyPosition.Parent = RootPart
                        end
                        ChildInstance:SetAttribute("IsGrabbed", true)
                        ChildInstance.HumanoidRootPart.CFrame = MidPoint

                        ChildInstance:SetAttribute("MidPoint", MidPoint)
                    end)()
                end
            )
        end


        function Sort1(N)
            return N and N:FindFirstChild("HumanoidRootPart") and
                math.floor(CaculateDistance(N.HumanoidRootPart.CFrame))
        end

        function CombatController.Search(MobTable)
            local Lists = {}
            local Found = false
            for _, ChildInstance in GetMonAsSortedRange() do
                if
                    table.find(MobTable, ChildInstance.Name) and ChildInstance:FindFirstChild("Humanoid") and
                        ChildInstance.Humanoid.Health > 0
                 then
                    if (ChildInstance:GetAttribute("FailureCount") or 0) < 3 then
                        Found = true
                        table.insert(Lists, ChildInstance)
                    end
                end
            end

            table.sort(
                Lists,
                function(a, b)
                    return Sort1(a) < Sort1(b)
                end
            )

            if Found then
                local Mon1 = Lists[1]
                return Mon1
            end

            for _, ChildName in MobTable do
                local MonResult2 = game.ReplicatedStorage:FindFirstChild(ChildName)
                if MonResult2 then
                    return MonResult2
                end
            end
        end

        function CombatController.Attack(MobTable, NearbyHit, Range, Callback)
            local GuideEnv = pcall(function()
                return getsenv(game.ReplicatedStorage.GuideModule)
            end) and getsenv(game.ReplicatedStorage.GuideModule)

            if ScriptStorage.Tools["Sweet Chalice"] and GuideEnv and GuideEnv["_G"]["InCombat"] then
                TweenController.Create(Vector3.new(0, 0, 0))
                return
            end

            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
            MobTable = type(MobTable) == "string" and {MobTable} or (MobTable or {})

            for _, Child in (MobTable) do
                local ChildName = tostring(Child)
                if
                    ChildName == "Deandre" or ChildName == "Urban" or
                        ChildName == "Diablo" and (os.time() - (LastFire12 or 0)) > 180
                 then
                    LastFire12 = os.time()
                    Remotes.CommF_:InvokeServer("EliteHunter")
                end

                if NearbyHit then
                    local Mon = GetMonAsSortedRange()[1]

                    local MonPosition = Mon and Mon:FindFirstChild("HumanoidRootPart") and Mon.HumanoidRootPart.Position
                    if MonPosition and CaculateDistance(MonPosition) < Range then
                        MonResult = Mon
                    end
                else
                    MonResult = CombatController.Search(MobTable)
                end

                if MonResult then
                    LastFound = os.time()
                    local Count, Debounce = 0, os.time()
                    local Count2, Debounce = 0, os.time()
                    while task.wait(0.1) do
                        if _G.Stop then
                            return
                        end

                        if ScriptStorage.Tools["Sweet Chalice"] and GuideEnv and GuideEnv["_G"]["InCombat"] then
                            TweenController.Create(Vector3.new(0, 0, 0))
                            return
                        end

                        local MobHumanoid = MonResult:FindFirstChild("Humanoid")
                        local MobHumanoidRootPart = MonResult:FindFirstChild("HumanoidRootPart")

                        if not MobHumanoid or MobHumanoid.Health <= 0 then
                            if MonResult.Name == "Don Swan" then
                                Storage:Set("SwanDefeated", true)
                                
                            end
                            break
                        end

                        TweenController.Create(
                            CaculateCircreDirection(MobHumanoidRootPart.CFrame) + Vector3.new(0, 35, 0)
                        )

                        if CaculateDistance(MobHumanoidRootPart.Position + Vector3.new(0, 35, 0)) < 150 then
                            CombatController.Grab(Child or "")
                            if MonResult.Name ~= "Core" then
                                if
                                    ScriptStorage.PlayerData.Level > 100 and
                                        Count2 >= CombatController.MAX_ATTACK_DURATION_2 and
                                        MobHumanoid.Health - MobHumanoid.MaxHealth == 0
                                 then
                                    SetTask(
                                        "SubTask",
                                        "Hop Server - Mob Health Unchanged ( " ..
                                            MobHumanoid.Health .. " / " .. MobHumanoid.MaxHealth .. ")"
                                    )
                                    alert("Stuck", "Mob health unchanged")
                                    _G.Stop = true
                                    game.Players.LocalPlayer:Kick("Rejoining...")

                                end

                              
                                if
                                    Count >= CombatController.MAX_ATTACK_DURATION and
                                        MobHumanoid.Health - MobHumanoid.MaxHealth == 0
                                 then
                                    Count = 0

                                    local OldPosition = MonResult:GetAttribute("OldPosition")

                                    if OldPosition then
                                        MonResult:SetPrimaryPartCFrame(CFrame.new(OldPosition))
                                        MonResult:SetAttribute("IgnoreGrab", true)
                                        MonResult:SetAttribute(
                                            "FailureCount",
                                            (MonResult:GetAttribute("FailureCount") or 0) + 1
                                        )
                                        alert(
                                            "Failed to attack",
                                            "Returning to the old position ( #" ..
                                                MonResult:GetAttribute("FailureCount") .. " )"
                                        )
                                       MonResult.HumanoidRootPart.CFrame = (CFrame.new(OldPosition))
                                        task.wait()

                                        return
                                    end
                                end
                            end
                         
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(
                                    ScriptStorage.ForceToUseSword and "Sword" or "Melee"
                                )

                            AttackController:Attack(MonResult)
                            if os.time() ~= Debounce then
                                Debounce = os.time()

                                Count = Count + 1
                                Count2 = Count2 + 1
                            end
                            if Count > 30 and MonResult.Name ~= "Core" then
                                alert("Take more than 30s to attack, cancelling")
                                break
                            end
                       
                        end
                    end
                elseif not NearbyHit then
                    if (os.time() - LastFound) > 200 then
                        alert("KUN", "Error while farming, rejoin")
                        game.Players.LocalPlayer:Kick("Rejoining...")
                        return
                    end

                    local Region = ScriptStorage.MobRegions[Child]

                    if not Region then
                        local Inst =
                            Services.Workspace.Enemies:FindFirstChild(Child) or
                            game.ReplicatedStorage:FindFirstChild(Child)

                        Region = Inst and {Inst:GetPrimaryPartCFrame().p}
                    end

                    if not Region then
                        return
                    end

                    local CurrentPosition

                    if not Region[CombatController.CurrentIndex] then
                        CombatController.CurrentIndex = 1
                    end

                    CurrentPosition = Region[CombatController.CurrentIndex]

                    local Count2 = os.time()
                    TweenController.Create(CurrentPosition + Vector3.new(0, 35, 35))
                    if CaculateDistance(CurrentPosition + Vector3.new(0, 35, 35)) < 15 then
                        CombatController.CurrentIndex = CombatController.CurrentIndex + 1
                    end

                end
            end
        end

        LevelFarmTTL = 0
        LastTravel = os.time()

        FunctionsHandler = {
            Initalized = false
        }

        print(3000)
        setmetatable(
            FunctionsHandler,
            {
                __index = function(Self, Index)
                    QueryResult = rawget(Self, Index)

                    if not QueryResult then
                        return {
                            Register = function(Coditional)
                                if Coditional == false then
                                    return
                                end

                                Result = {
                                    CacheListener = {},
                                    RealCache = {},
                                    Methods = {},
                                    Constants = {},
                                    Events = {},
                                    Initalized = true
                                }

                                function Result.RegisterMethod(Self, Name, Function)
                                    Self.Methods[Name] = {
                                        Name = Name,
                                        Callback = Function,
                                        Call = function(Self, ...)
                                            return Self.Callback(...)
                                        end,
                                        Events = {}
                                    }
                                    return true
                                end

                                setmetatable(
                                    Result.Constants,
                                    {
                                        __newindex = function()
                                            assert(false, "cannot change constant value!")
                                        end
                                    }
                                )

                                if Self.Constants[Key] then
                                    function Result.SaveConstant(Self, Key, Value)
                                        return assert(false, "constant name was used before!")
                                    end

                                    rawset(Self.Constants, Key, Value)
                                end

                                function Result.Set(Self, Key, Value)
                                    Self.CacheListener[Key] = Value
                                    return Value
                                end

                                function Result.Get(Self, Index)
                                    return Self.Constants[Index] or Self.RealCache[Index]
                                end

                                function Result.AddVariableChangeListener(Self, Index, Callback)
                                    Self.Events[Index] = Callback
                                end

                                Result.CacheListener.__parent = Result

                                setmetatable(
                                    Result.CacheListener,
                                    {
                                        __newindex = function(Self, Key, Value)
                                            _ = Self.__parent.Events[Key] and Self.__parent.Events[Key](Key, Value)

                                            Self.__parent.RealCache[Key] = Value
                                        end
                                    }
                                )

                                FunctionsHandler[Index] = Result
                            end,
                            Initalized = false
                        }
                    end

                    return QueryResult
                end
            }
        )

        function FunctionsHandler.SynchorizeUntilModuleLoaded(Self, Timeout)
            local StartTime = os.time()

            while not Self.Initalized do
                task.wait()
                local Difference = os.time() - StartTime

                assert(not (Timeout and Difference > Timeout), "timed out")
            end
        end

        function GetCurrentClaimQuest(RawResponse)
            local QuestTitle =
                game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible and
                game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:gsub(
                    "%s*Defeat%s*(%d*)%s*(.-)%s*%b()",
                    "%2"
                )
            return (type(QuestTitle) == "string" and string.gsub(QuestTitle, "Military ", "Mil. ") or QuestTitle), game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
        end

 
        -- LP Controller
        FunctionsHandler.LocalPlayerController.Register()
        -- Exp Redeem
        FunctionsHandler.ExpRedeem:Register()

        -- Level Farm
        FunctionsHandler.LevelFarm:Register()

        -- Items / Sword
        FunctionsHandler.Saber:Register()
        FunctionsHandler.Rengoku:Register()
        FunctionsHandler.Yama:Register()
        FunctionsHandler.Tushita:Register()
        FunctionsHandler.SpikeyTrident:Register()
        FunctionsHandler.SharkAchor:Register()
        FunctionsHandler.Pole:Register()
        FunctionsHandler.FoxLamp:Register()
        FunctionsHandler.DarkDagger:Register()
        FunctionsHandler.Canvander:Register()
        FunctionsHandler.BuddySword:Register()
        FunctionsHandler.HallowScythe:Register()

        -- Items / Guns
        FunctionsHandler.AcidumRifle:Register()
        FunctionsHandler.Kabucha:Register()
        FunctionsHandler.VenomBow:Register()
        FunctionsHandler.SoulGuitar:Register()
        FunctionsHandler.DragonStorm:Register()

        -- Items / Etc
        FunctionsHandler.InsictV2:Register()
        FunctionsHandler.RainbowSaviour:Register()

        -- Puzzles / First Sea
        FunctionsHandler.DarkBladeV2:Register()
        FunctionsHandler.SecondSeaPuzzle:Register()

        -- Puzzles / Second Sea
        FunctionsHandler.ColosseumPuzzle:Register()
        FunctionsHandler.Trevor:Register()
        FunctionsHandler.EvoRace:Register()
        FunctionsHandler.Wenlocktoad:Register()
        FunctionsHandler.DarkBladeV3:Register()
        FunctionsHandler.ThirdSeaPuzzle:Register()

        -- Puzzles / Third Sea
        FunctionsHandler.DojoQuest:Register()
        FunctionsHandler.RaceAwakening:Register()
        FunctionsHandler.PirateRaid:Register()

        -- Functions / Raid
        FunctionsHandler.RaidController:Register()

        -- Functions / Auto Melees
        FunctionsHandler.MeleesController:Register()

        FunctionsHandler.Superhuman:Register()
        FunctionsHandler.DeathStep:Register()
        FunctionsHandler.SharkmanKarate:Register()
        FunctionsHandler.ElectricClaw:Register()
        FunctionsHandler.DragonTalon:Register()
        FunctionsHandler.Godhuman:Register()

        -- Functions / Boss Task
        FunctionsHandler.BossesTask:Register()
        FunctionsHandler.SpecialBossesTask:Register()
        -- Functions / CollectDrops
        FunctionsHandler.CollectDrops:Register()

        -- Functions / UtillyItemsActivitation
        FunctionsHandler.UtillyItemsActivitation:Register()

        -- Exp Redeem
        FunctionsHandler.ExpRedeem:RegisterMethod(
            "Refresh",
            function()
                return ScriptStorage.PlayerData.Level < MaxLevel and
                    getsenv(game.ReplicatedStorage.GuideModule)._G.ServerData.ExpBoost == 0 and
                    not Storage.Get(Storage, "IsCodesRanOut")
            end
        )

        FunctionsHandler.ExpRedeem:RegisterMethod(
            "Start",
            function()
                local Code = ({
                    "BANEXPLOIT",
                    "NOMOREHACK",
                    "WildDares",
                    "BossBuild",
                    "GetPranked",
                    "EARN_FRUITS",
                    "Sub2UncleKizaru",
                    "FIGHT4FRUIT",
                    "kittgaming",
                    "TRIPLEABUSE",
                    "Sub2CaptainMaui",
                    "Sub2Fer999",
                    "Enyu_is_Pro",
                    "Magicbus",
                    "JCWK",
                    "Starcodeheo",
                    "Bluxxy",
                    "SUB2GAMERROBOT_EXP1",
                    "Sub2NoobMaster123",
                    "Sub2Daigrock",
                    "Axiore",
                    "TantaiGaming",
                    "StrawHatMaine",
                    "Sub2OfficialNoobie",
                    "TheGreatAce",
                    "SEATROLLING",
                    "24NOADMIN",
                    "ADMIN_TROLL",
                    "NEWTROLL",
                    "SECRET_ADMIN",
                    "staffbattle",
                    "NOEXPLOIT",
                    "NOOB2ADMIN",
                    "CODESLIDE",
                    "fruitconcepts"
                })

                for Index, Promo in Code do
                    SetTask("MainTask", "Code Redemption | " .. Promo .. " | Redeeming...")
                    local Response = (Remotes.Redeem:InvokeServer(Promo))
                    task.wait()
                    SetTask("MainTask", "Code Redemption | " .. Promo .. " | " .. (Response or "Failed"))
                    if getsenv(game.ReplicatedStorage.GuideModule)._G.ServerData.ExpBoost == 0 then
                        if Response and string.find(Response, "SUCC") then
                            return SetTask("MainTask", "Code Redemption | X2 Exp Boost Activated!") and task.wait(1)
                        end
                    else
                        return
                    end
                end

                Storage:Set("IsCodesRanOut", 1)
                Storage:Save()
            end
        )

        -- Level Farm
        FunctionsHandler.LevelFarm:RegisterMethod(
            "Refresh",
            function()
                if FunctionsHandler.RaidController:Get("IsInRaidProcess") then
                    return
                end
                
                local Level = ScriptStorage.PlayerData.Level
                if Level < 10 then
                    return 1
                elseif Level < 70 then
                    return 2
                else
                    return 4
                end
                return true
            end
        )

        FunctionsHandler.LevelFarm:RegisterMethod(
            "Start",
            function(Level)
                if SeaIndex == 3 then
                    if (ScriptStorage.Backpack.Bones or {Count = 0}).Count >= 50 then
                        if os.time() > (BonesCooldown or 0) then
                            local _, _, State, Message = Remotes.CommF_:InvokeServer("Bones", "Check")
                            print("State", State, "Message", Message)
                            if tonumber(State or 1) == 0 then
                                local SplitedNum = Split(Message, ":")
                                local SecondsLeft = ((tonumber(SplitedNum[1]) * 60) + tonumber(SplitedNum[2])) * 60
                                BonesCooldown = os.time() + SecondsLeft
                                print("Next", BonesCooldown)
                            else
                                print("Roll")
                                if CaculateDistance(Vector3.new(-8727, 143, 6249)) > 30 then
                                    TweenController.Create(Vector3.new(-8727, 143, 6249))
                                    return task.wait(2)
                                end
                                Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                            end
                        end
                    end
                end

                local PlayerLevel = ScriptStorage.PlayerData.Level
                if GodHumanFlag then
                    local Material, MaterialData = (function()
                        getgenv()["     mphm >< <3"] = {}
                        for Material, MaterialData in GodhumanMaterials do
                            if (ScriptStorage.Backpack[Material] or {Count = 0}).Count < MaterialData[1] then
                                getgenv()["     mphm >< <3"] = {Material, MaterialData}
                            end
                        end

                        return unpack(getgenv()["     mphm >< <3"])
                    end)()

                    if Material then
                        if SeaIndex ~= MaterialData[2] then
                            alert("Material - " .. Material, "Travelling sea " .. MaterialData[2])
                            SetTask(
                                "MainTask",
                                "Sea Travel | Godhuman Materials | Travelling to Sea " .. MaterialData[2]
                            )

                            Remotes.CommF_:InvokeServer("Travel" .. SeaIndexes[MaterialData[2]])
                            return
                        end

                        SetTask("MainTask", "Material Farming | Godhuman | " .. Material .. " | In Progress" )

                        if PlayerLevel >= MaterialData[4][3] then
                            CombatController.Attack(MaterialData[3])
                        end

                        CombatController.Attack(MaterialData[3])
                    end

                    BuyMelee("Godhuman", true,"Ancient Monk")

                    GodHumanFlag = false
                    return true
                end

                    LastTravel = os.time()
                    if PlayerLevel >= 1500 and (SeaIndex == 2) then
                        if not Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor")  then
                            Remotes.CommF_:InvokeServer("TravelZou")
                            SetTask("MainTask", "Sea Travel | Teleporting to Third Sea")
                        end
                    elseif PlayerLevel >= 700 and (SeaIndex == 1)  then
                        SetTask("MainTask", "Sea Travel | Teleporting to Second Sea")
                        Remotes.CommF_:InvokeServer("TravelDressrosa")
                    end

                if ScriptStorage.Tools["God's Chalice"] and not ScriptStorage.Tools["Mirror Fractal"] then
                    if (ScriptStorage.Backpack["Conjured Cocoa"] or {Count = 0}).Count < 10 then
                        SetTask("MainTask", "Material Farming | Conjured Cocoa | Need 10x | Farming...")
                        CombatController.Attack({"Cocoa Warrior", "Chocolate Bar Battler"})
                        return
                    end
                    Remotes.CommF_:InvokeServer("SweetChaliceNpc")
                end

                if
                    ScriptStorage.Tools["Sweet Chalice"] or
                        (PlayerLevel == MaxLevel and (ScriptStorage.Backpack.Bones or {Count = 0}).Count >= 500)
                 then
                    SetTask("MainTask", "Fragments Farming | Cake Prince | Dough King")

                    if (ScriptStorage.Tools["Sweet Chalice"]) and (not SpawnReflect or os.time() - SpawnReflect > 10) then
                        task.spawn(
                            function()
                                while not ScriptStorage.Enemies["Dough King"] and task.wait() and
                                    ScriptStorage.Tools["Sweet Chalice"] do
                                    SpawnReflect = os.time()
                                    Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                                end
                            end
                        )
                    end

                    CombatController.Attack(
                        {
                            "Head Baker",
                            "Baking Staff",
                            "Cookie Crafter",
                            "Cake Guard"
                        }
                    )

                    if PlayerLevel >= 2200 then
                        local IsAvailabe, CurrentClaimQuest2 = GetCurrentClaimQuest()

                        if IsAvailabe then
                            if not string.find(CurrentClaimQuest2, "Cookie") then
                                QuestManager.AbandonQuest()
                            else
                                Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                                return
                            end
                        else
                            print("Start Quest")

                            local NpcPosition1 = ScriptStorage.NPCs["Cake Quest Giver 1"]
                            NpcPosition1 = NpcPosition1 and NpcPosition1:GetModelCFrame()

                            if NpcPosition1 then
                                TweenController.Create(NpcPosition1 + Vector3.new(0, 5, 3))
                                if CaculateDistance(NpcPosition1) < 10 then
                                    task.wait(1)
                                else
                                    return
                                end
                            else
                                print("NPC HauntedQuest2 not found")
                            end
                            QuestManager.StartQuest("CakeQuest1", 1)
                            return
                        end
                    end
                    print("attack ohoo")

                    return
                end
                if PlayerLevel == MaxLevel and SeaIndex == 3 then
              if
                        (PlayerLevel == MaxLevel and (ScriptStorage.Backpack.Bones or {Count = 0}).Count >= 500)
                 then
                    SetTask("MainTask", "Fragments Farming | Cake Prince | Dough King")

                    if (not SpawnReflect or os.time() - SpawnReflect > 10) then
                        task.spawn(
                            function()
                                while not ScriptStorage.Enemies["Cake Prince"] and task.wait()  do
                                    SpawnReflect = os.time()
                                    Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                                end
                            end
                        )
                    end

                    CombatController.Attack(
                        {
                            "Head Baker",
                            "Baking Staff",
                            "Cookie Crafter",
                            "Cake Guard"
                        }
                    )

                    print("attack ohoo")

                    return
                end
            end
                if
                    PlayerLevel >= 2025 and
                        (getsenv(game.ReplicatedStorage.GuideModule)._G.ServerData.ExpBoost == 0 or
                            PlayerLevel == MaxLevel) and
                        (ScriptStorage.Backpack.Bones or {Count = 0}).Count < 500 and SeaIndex == 3
                then
                    SetTask("MainTask", "Resource Farming | Bones | For X2 Mastery/Beli")
                    
                    CurrentClaimQuest3 = GetCurrentClaimQuest(true)

                    if CurrentClaimQuest3 then
                        if not string.find(CurrentClaimQuest3, "Demonic") then
                            QuestManager.AbandonQuest()
                            return
                        else
                            CombatController.Attack(
                                {
                                    "Reborn Skeleton",
                                    "Living Zombie",
                                    "Demonic Soul",
                                    "Posessed Mummy"
                                }
                            )
                            return
                        end
                    else
                        print("StartQuest", CurrentClaimQuest3)
                        local NpcPosition1 = ScriptStorage.NPCs["Haunted Castle Quest Giver 2"]
                        NpcPosition1 = NpcPosition1 and NpcPosition1:GetModelCFrame()

                        if NpcPosition1 then
                            TweenController.Create(NpcPosition1 + Vector3.new(0, 5, 3))
                            if CaculateDistance(NpcPosition1) < 20 then
                                task.wait(1)
                            else
                                return
                            end
                        else
                            print("NPC HauntedQuest2 not found")
                        end

                        QuestManager.StartQuest("HauntedQuest2", 1)
                        return
                    end
                end

                if Level == 1 then
                    SetTask("MainTask", "Level Farming | Skip Mode | Floor " .. Level)
                    CombatController.Attack("Sky Bandit")
                elseif Level == 2 then
                    SetTask("MainTask", "Level Farming | Skip Mode | Floor " .. Level)
                     CombatController.Attack({"Royal Soldier", "Royal Squad"})
                elseif Level == 3 then
                    SetTask("MainTask", "Level Farming | Skip Mode | Floor " .. Level)
                    CombatController.Attack({"Royal Soldier", "Royal Squad"})
                elseif Level == 4 then
                    local MonName, NpcPosition, QuestId, QuestIndex, QuestTitle = QuestManager:GetCurrentQuest()
                    CurrentClaimQuest1 = GetCurrentClaimQuest()
                    if CurrentClaimQuest1 then
                        if CurrentClaimQuest1 ~= QuestTitle and CurrentClaimQuest1 ~= (QuestTitle .. "s") then
                            AbandonedCount = AbandonedCount and AbandonedCount + 1 or 0
                            if AbandonedCount > 20 then 
                            game.Players.LocalPlayer:Kick("Rejoining...")
                            end
                            alert("Abandon Quest", CurrentClaimQuest1 or '' .. ' / ' .. QuestTitle or '')
                            return QuestManager.AbandonQuest()
                        end
                    else
                        if not NpcPosition then
                            return QuestManager:RefreshQuest()
                        end
                        TweenController.Create(NpcPosition + Vector3.new(0, 5, 3))
                        SetTask("MainTask", "Level Farming | " .. MonName .. " | Claiming Quest")
                        if CaculateDistance(NpcPosition) > 10 then
                            return
                        end

                        task.wait(2)
                        LevelFarmTTL = 0
                        QuestManager.StartQuest(QuestId, QuestIndex)
                        task.wait(1)
                    end

                    SetTask("MainTask", "Level Farming | " .. MonName .. " | Defeating Enemies")
                    local AttackTime1 = os.time()
                    CombatController.Attack(MonName)
                    LevelFarmTTL = LevelFarmTTL + os.time() - AttackTime1
                end
            end
        )

        -- LP Controller
        FunctionsHandler.LocalPlayerController:RegisterMethod(
            "EquipTool",
            function(Tool)
                if not Humanoid then
                    return
                end

                for _, Item in LocalPlayer.Backpack:GetChildren() do
                    if
                        Item:IsA("Tool") and Item.Name ~= "Tool" and
                            (Item.Name == tostring(Tool) or Item.ToolTip == Tool)
                     then
                        LocalPlayer.Character:WaitForChild "Humanoid":EquipTool(Item)
                    end
                end
            end
        )

        FunctionsHandler.LocalPlayerController:RegisterMethod(
            "ToggleAbilities",
            function(Ability, State)
                if Ability == "Buso" then
                    if  LocalPlayer.Character:FindFirstChild('HasBuso') == nil or State then
                        Remotes.CommF_:InvokeServer("Buso")
                    end
                elseif Ability == "Observation" then
                end
            end
        )

        FunctionsHandler.LocalPlayerController:RegisterMethod(
            "ConfigurationAbilitiesToggle",
            function()
                FunctionsHandler.LocalPlayerController.Methods.ToggleAbilities:Call("Buso", SCRIPT_CONFIG.BUSO)
                FunctionsHandler.LocalPlayerController.Methods.ToggleAbilities:Call(
                    "Observation",
                    SCRIPT_CONFIG.OBSERVATION
                )
            end
        )
        print(3)

        -- Items / Saber
        FunctionsHandler.S
