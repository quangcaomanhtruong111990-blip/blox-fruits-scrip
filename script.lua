-- ========================================================
-- [ULTRA COMPATIBILITY SHIM FOR ALL EXECUTORS]
-- Tương thích 100% Delta, Fluxus, Codex, Arceus X, Solara, Wave
-- ========================================================
pcall(function()
    if typeof(task) ~= "table" then
        getfenv().task = {}
    end
    if typeof(task.wait) ~= "function" then
        task.wait = function(n)
            if typeof(wait) == "function" then return wait(n or 0) end
            return 0
        end
    end
    if typeof(task.spawn) ~= "function" then
        task.spawn = function(f, ...)
            if typeof(spawn) == "function" then return spawn(f) end
            if typeof(coroutine) == "table" and coroutine.wrap then return coroutine.wrap(f)(...) end
            return f(...)
        end
    end
    if typeof(task.delay) ~= "function" then
        task.delay = function(n, f)
            if typeof(delay) == "function" then return delay(n, f) end
            task.spawn(function() task.wait(n) f() end)
        end
    end
    if typeof(task.defer) ~= "function" then
        task.defer = task.spawn
    end
    if typeof(setfpscap) ~= "function" then
        getfenv().setfpscap = function() end
    end
end)

print("========================================")
print("[Bocchi Hub] SCRIPT INJECTED SUCCESSFULLY!")
print("[Bocchi Hub] Initializing modules...")
print("========================================")

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Bocchi Hub",
        Text = "Script đang khởi động... Vui lòng đợi!",
        Duration = 5
    })
end)

-- LogService Message Logger disabled to prevent log spam

Config =
        Config or
        {
            Team = "Pirates",
            Configuration = {
                HideallPath = false,
                blackscreen = false,
                HideGui = false,
                HopWhenIdle = false,
                AutoHop = false,
                AutoHopDelay = 60 * 60,
                FpsBoost = false,
                ["IdleCheck"] = 0, -- Tắt tự động Hop để tránh out game
            },
            Items = {
                -- Melees
                AutoFullyMelees = true,
                -- Swords
                Saber = true,
                AutoFarmFruitMastery = false,
                AutoEatFruit = 1,
                Eatlist = {},
                -- Quay trai ngau nhien tu xa + tu dong cat rương
                FruitGacha = true,
                FruitGachaDelay = 60,          -- giua 2 lan quay thanh cong
                FruitGachaFailDelay = 600,     -- cho lai sau khi quay that bai (thieu tien / hoi chieu)
                FruitGachaBox = "ZiolesGacha",
                -- Gia 1 lan quay. De 0 = de script tu do qua so Beli bi tru
                FruitGachaCost = 0
            },
            Settings = {
                ["Fragments"] = 5000,
                FruitRescanDelay = 45,         -- giay / 1 lan quet nong (re, khong di toan ban do)
                FruitDeepScanDelay = 300,      -- giay / 1 lan quet SAU toan ban do (dat, de khong lag)
                FruitReachTimeout = 30,        -- giay toi da bay toi 1 trai, qua thi bo qua tam thoi
                FruitSkipDuration = 90,        -- giay danh dau bo qua trai khong lay duoc
                QuestGracePeriod = 25,       -- Thời gian ân hạn cơ bản sau khi nhận Quest (tự động cộng thêm thời gian bay nếu bãi quái xa)
                QuestStartTimeout = 1.0,    -- Thời gian chờ UI sau khi gửi lệnh StartQuest
                QuestGoneDelay = 20,       -- Thời gian chờ UI ẩn trước khi xác nhận hết quest (để nhận lại ngay)
                MinFarmDuration = 2.5,      -- Thời gian farm tối thiểu trước khi kiểm tra hoàn thành quest
            }
}

local loadedStart = tick()
while not game:IsLoaded() and tick() - loadedStart < 10 do
    task.wait(0.5)
end

task.wait(0.5)

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
        pcall(function()
            warn("[Kick Detected]", v.TitleFrame.ErrorTitle.Text)
        end)
    end
end

-- Auto Select Team safely in background (only once)
task.spawn(function()
    task.wait(1.5)
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        if lp and not lp.Character then
            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            local commF = remotes and remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer('SetTeam', (Config and Config.Team) or 'Pirates')
            end
        end
    end)
end)
pcall(function()
    game:GetService('CoreGui').RobloxPromptGui.promptOverlay.ChildAdded:Connect(CheckKick)
end)
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
   -- -- print restored
    local StartTime = os.time()

    local Traces = {}

    function Build(Error)
        warn("Error\n\n", Error, "\n\n")
        local Result = {
            content = "<@12313> " .. tostring(Error) or " " .. tostring(LocalPlayer) or "",
            embeds = {
                {
                    title = GameName,
                    description = game.PlaceId .. " | " .. game.JobId,
                    color = 15642286,
                    fields = {
                        {
                            name = "Error Details",
                            value = Error
                        },
                        {
                            name = "Player Info",
                            value = "Level: " .. tostring((ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or "n/a")
                        },
                        {
                            name = "Script Details",
                            value = GetCurrentDateTime() ..
                                " | " ..
                                    DispTime(os.time() - StartTime, true) ..
                                        " after execution\nMain task: " ..
                                            (ScriptStorage.Task.MainTask or "n/a") ..
                                                " ( " ..
                                                    (ScriptStorage.Task["MainTask-d"] and
                                                        DispTime(os.time() - ScriptStorage.Task["MainTask-d"], true) or
                                                        "n/a") ..
                                                        " ) \nSub task: " ..
                                                            (ScriptStorage.Task.SubTask or "n/a") ..
                                                                " ( " ..
                                                                    (ScriptStorage.Task["SubTask-d"] and
                                                                        DispTime(
                                                                            os.time() - ScriptStorage.Task["SubTask-d"],
                                                                            true
                                                                        ) or
                                                                        "n/a") ..
                                                                        " )"
                        },
                        {
                            name = "Traceback",
                            value = (function()
                                local Result = ""

                                for Index, Content in ScriptStorage.Tracebacks do
                                    if #ScriptStorage.Tracebacks > 20 then
                                        break
                                    end

                                    Result = Result .. (Content or "null") .. "\n"
                                end

                                return Result ~= "" and Result or "... ( empty list ) "
                            end)()
                        }
                    },
                    author = {
                        name = tostring(LocalPlayer)
                    }
                }
            },
            attachments = {}
        }

        for Index, Value in Result.embeds[1].fields do
            Value.value = "```" .. Value.value .. "```"
        end
        return Result
    end

    function Report(Message)
        warn("[Cyndral Dev Debug]", tostring(Message))
        print("[Cyndral Dev Debug]", tostring(Message))
    end

    function mmb()
        local Orders = {"Task1", "Task2", "Currencies", "Melees", "LiveTime", "DebugLine"}
        local Interface = {
            Instances = {}
        }

        local isVisible = true
        local isToggleOpen = false
        local player = game.Players.LocalPlayer

        local getGuiParent = function()
            if typeof(gethui) == "function" then
                local ok, h = pcall(gethui)
                if ok and h then return h end
            end
            local success, cg = pcall(function() return game:GetService("CoreGui") end)
            if success and cg then
                local testSuccess = pcall(function() 
                    local t = Instance.new("Folder")
                    t.Parent = cg
                    t:Destroy()
                end)
                if testSuccess then return cg end
            end
            local lp = game:GetService("Players").LocalPlayer or player
            local pg = lp and (lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui", 5))
            return pg or game:GetService("CoreGui")
        end

        local parentGui = getGuiParent()
        pcall(function()
            local old = parentGui:FindFirstChild("CyndralDev")
            if old then old:Destroy() end
        end)

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
        HopGui.Parent = parentGui
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
        NameHub.Text = "(SEA 1 ONLY)"

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
            -- Create a new transparent frame that covers the screen
            local blurFrame = Instance.new("Frame")
            blurFrame.Name = "BlurFrame"
            blurFrame.Parent = HopGui
            blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            blurFrame.BackgroundTransparency = 1 -- Start fully transparent
            blurFrame.BorderSizePixel = 0
            blurFrame.Size = UDim2.new(1, 0, 1, 0)
            blurFrame.Position = UDim2.new(0, 0, 0, 0)
            blurFrame.ZIndex = 0 -- Behind everything

            -- Store the reference
            self.blurFrame = blurFrame
            self.blurIntensity = 0

            return self
        end

        function BlurManager:SetIntensity(intensity)
            -- Clamp intensity between 0 and 0.95 (0.95 is nearly opaque)
            intensity = math.clamp(intensity, 0, 0.95)
            self.blurIntensity = intensity

            -- Apply the intensity to our blur frame
            local tweenService = game:GetService("TweenService")
            local tweenInfo =
                TweenInfo.new(
                0.3, -- Time
                Enum.EasingStyle.Cubic, -- Easing style
                Enum.EasingDirection.Out -- Easing direction
            )

            local tween =
                tweenService:Create(
                self.blurFrame,
                tweenInfo,
                {
                    BackgroundTransparency = 1 - intensity
                }
            )

            tween:Play()

            -- Also apply the actual blur effect in lighting
            if not self.blurEffect then
                self.blurEffect = Instance.new("BlurEffect")
                self.blurEffect.Name = "CustomBlur"
                self.blurEffect.Parent = game.Lighting
                self.blurEffect.Enabled = true
            end

            local blurSizeTween =
                tweenService:Create(
                self.blurEffect,
                tweenInfo,
                {
                    Size = intensity * 30 -- Max blur size is 30
                }
            )

            blurSizeTween:Play()

            -- Apply blur to registered UI elements
            for _, uiElement in pairs(UIReferences) do
                if uiElement and uiElement.Parent then
                    local uiTween =
                        tweenService:Create(
                        uiElement,
                        tweenInfo,
                        {
                            BackgroundTransparency = uiElement._originalTransparency + (intensity * 0.5)
                        }
                    )
                    uiTween:Play()
                end
            end
        end

        function BlurManager:RegisterUI(uiElement)
            if uiElement and uiElement:IsA("GuiObject") then
                -- Store the original transparency
                uiElement._originalTransparency = uiElement.BackgroundTransparency
                table.insert(UIReferences, uiElement)
            end
        end

        -- Create our blur manager
        local blurEffect = BlurManager:Create()

        -- Improved Text Transition Animation
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

                    -- Fade out with smoother animation
                    local tweenService = game:GetService("TweenService")
                    local fadeOutInfo =
                        TweenInfo.new(
                        0.3, -- Time
                        Enum.EasingStyle.Quad, -- Easing style
                        Enum.EasingDirection.Out -- Easing direction
                    )

                    local fadeOut =
                        tweenService:Create(
                        TextIns,
                        fadeOutInfo,
                        {
                            TextTransparency = 1,
                            TextStrokeTransparency = 1
                        }
                    )

                    fadeOut:Play()
                    fadeOut.Completed:Wait()

                    -- Change text while invisible
                    TextIns.Text = Text

                    -- Fade in with smoother animation
                    local fadeInInfo =
                        TweenInfo.new(
                        0.3, -- Time
                        Enum.EasingStyle.Quad, -- Easing style
                        Enum.EasingDirection.Out -- Easing direction
                    )

                    local fadeIn =
                        tweenService:Create(
                        TextIns,
                        fadeInInfo,
                        {
                            TextTransparency = 0,
                            TextStrokeTransparency = 0
                        }
                    )

                    fadeIn:Play()
                end
            )
        end

        local OldExposureCompensation = game:GetService("Lighting").ExposureCompensation
        -- Enhanced toggle function with improved animations
        function ToggleUI(State)
            isToggleOpen = State or not isToggleOpen

            -- game:GetService("Lighting").ExposureCompensation = State and -math.huge or OldExposureCompensation

            local contentLabels = {NameHub, MainTextLabel}
            for _, instance in pairs(Interface.Instances) do
                table.insert(contentLabels, instance)
            end

            local tweenService = game:GetService("TweenService")
            local tweenInfo =
                TweenInfo.new(
                0.5, -- Time
                Enum.EasingStyle.Quart, -- Easing style
                Enum.EasingDirection.InOut -- Easing direction
            )

            if isToggleOpen then
                -- Show UI
                ToggleIcon.Text = "🔍"

                -- Fancy rotation animation for toggle button
                local rotationTween =
                    tweenService:Create(
                    ToggleIcon,
                    TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    {Rotation = 360}
                )
                rotationTween:Play()
                task.spawn(function()
                    task.wait(0.5)
                    pcall(function()
                        ToggleIcon.Rotation = 0
                    end)
                end)

                -- Animate all elements in
                for _, label in pairs(contentLabels) do
                    label.TextTransparency = 1

                    local tween =
                        tweenService:Create(
                        label,
                        tweenInfo,
                        {
                            TextTransparency = 0
                        }
                    )

                    if label:FindFirstChildOfClass("UIStroke") then
                        label:FindFirstChildOfClass("UIStroke").Transparency = 1

                        local strokeTween =
                            tweenService:Create(
                            label:FindFirstChildOfClass("UIStroke"),
                            tweenInfo,
                            {
                                Transparency = 0
                            }
                        )

                        strokeTween:Play()
                    end

                    tween:Play()
                end

                -- Apply blur effect
                blurEffect:SetIntensity(0.4) -- 40% blur intensity
            else
                -- Hide UI
                ToggleIcon.Text = "🔍"

                -- Fancy shrink animation for toggle button
                local shrinkTween =
                    tweenService:Create(
                    ToggleIcon,
                    TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                    {Size = UDim2.new(0.3, 0, 0.3, 0)}
                )
                shrinkTween:Play()
                task.spawn(function()
                    task.wait(0.3)
                    pcall(function()
                        local growTween =
                            tweenService:Create(
                            ToggleIcon,
                            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                            {Size = UDim2.new(0.7, 0, 0.7, 0)}
                        )
                        growTween:Play()
                    end)
                end)

                -- Animate all elements out
                for _, label in pairs(contentLabels) do
                    local tween =
                        tweenService:Create(
                        label,
                        tweenInfo,
                        {
                            TextTransparency = 1
                        }
                    )

                    if label:FindFirstChildOfClass("UIStroke") then
                        local strokeTween =
                            tweenService:Create(
                            label:FindFirstChildOfClass("UIStroke"),
                            tweenInfo,
                            {
                                Transparency = 1
                            }
                        )

                        strokeTween:Play()
                    end

                    tween:Play()
                end

                -- Remove blur effect
                blurEffect:SetIntensity(0) -- 0% blur intensity
            end

            isVisible = isToggleOpen
        end

        -- Function to register an external UI for blurring
        function Interface.RegisterForBlur(uiElement)
            blurEffect:RegisterUI(uiElement)
        end

        -- Configure toggle button click event
        ToggleButton.MouseButton1Click:Connect(
            function()
                ToggleUI()
            end
        )

        -- Add pulse animation to toggle button on hover
        ToggleButton.MouseEnter:Connect(
            function()
                local tweenService = game:GetService("TweenService")

                -- Pulse animation
                local pulseSequence = function()
                    local expandTween =
                        tweenService:Create(
                        ToggleContainer,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Size = UDim2.new(0, 55, 0, 55)}
                    )

                    local glowTween =
                        tweenService:Create(
                        ToggleUIStroke,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Color = Color3.fromRGB(0, 255, 255), Thickness = 3}
                    )

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

                local shrinkTween =
                    tweenService:Create(
                    ToggleContainer,
                    tweenInfo,
                    {
                        Size = UDim2.new(0, 50, 0, 50)
                    }
                )

                local strokeTween =
                    tweenService:Create(
                    ToggleUIStroke,
                    tweenInfo,
                    {
                        Color = Color3.fromRGB(9, 255, 248),
                        Thickness = 2
                    }
                )

                shrinkTween:Play()
                strokeTween:Play()
            end
        )

        -- Original toggle interface function (for backward compatibility)
        function Interface.ToggleInterface(State)
            isToggleOpen = State

            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            if State then
                HopGui.Enabled = true
                ToggleIcon.Text = "👁️"
                blurEffect:SetIntensity(0.4) -- 40% blur intensity
            else
                ToggleIcon.Text = "🔍"
                blurEffect:SetIntensity(0) -- 0% blur intensity
            end

            isVisible = State
        end

        -- Add a floating animation to the toggle button
        local function setupFloatingAnimation()
        end

        setupFloatingAnimation()

        ToggleUI(true)
        -- Export the SetText function and other functions
        Interface.SetText = SetText
        Interface.ToggleUI = ToggleUI
        Interface.BlurManager = blurEffect

        function alert(t1, t2)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = tostring(t1 or "Bocchi Hub"),
                    Text = tostring(t2 or ""),
                    Duration = 3
                })
            end)
            pcall(function() print("[Alert]", tostring(t1 or ""), tostring(t2 or "")) end)
        end
        _G.alert = alert
        if typeof(getgenv) == "function" then
            getgenv().alert = alert
        end

        -- Tự động dọn dẹp file Fluent cũ nếu có để không bị Executor load nhầm
        pcall(function()
            if typeof(isfile) == "function" and typeof(delfile) == "function" and isfile("fluent.lua") then
                pcall(delfile, "fluent.lua")
            end
        end)

        -- Hàm require an toàn chống treo luồng trên Solara / PC Executor
        local function safe_require(module, timeout)
            if not module then return nil end
            local result = nil
            local done = false
            task.spawn(function()
                pcall(function()
                    result = require(module)
                end)
                done = true
            end)
            local maxWait = math.floor((timeout or 1.5) * 10)
            local waited = 0
            while not done and waited < maxWait do
                task.wait(0.1)
                waited = waited + 1
            end
            return result
        end
        alert("Bocchi Hub", "Kaitun Loaded Successfully!")

        local CDN_HOST = ""

        StartTime = os.time()

        OldSessionTime = 0
        pcall(function()
            if typeof(isfile) == "function" and typeof(readfile) == "function" then
                local filename = ".tdif-" .. (game.Players.LocalPlayer and game.Players.LocalPlayer.Name or "default")
                if isfile(filename) then
                    OldSessionTime = tonumber(readfile(filename)) or 0
                end
            end
        end)

        if Config and Config.Configuration and Config.Configuration.blackscreen then 
            pcall(function()
                game:GetService("Lighting").ExposureCompensation = -math.huge
            end)
        end

        local charWaitStart = tick()
        while not (game.Players.LocalPlayer and game.Players.LocalPlayer.Character) and tick() - charWaitStart < 8 do
            task.wait(0.5)
        end

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

        -- Interface.ToggleDarkScreen(Config.Utilly.BlackScreen)

        StartTick = tick()
        local setWaitStart = tick()
        while not SetText and tick() - setWaitStart < 5 do
            task.wait(0.1)
        end
        alert("load 2")
        print("[Bocchi Hub] GUI Created! Initializing Script...")
        if SetText then
            SetText("MainTextLabel", "Initalizing Script...")
        end
        

        local FolderPath = "Rua_Hub/Blox_Fruit/Assets/"

        
        -- Safe Rejoin / Server Hop Helper (replaces raw Kick calls)
        local function SafeRejoinOrHop(reason)
            print("[Auto Rejoin/Hop Disabled for Stability] Reason: " .. tostring(reason or "Stuck/Idle/Desync"))
        end

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
        Players = game.Players
        LocalPlayer = Players.LocalPlayer
        Character = LocalPlayer.Character
        if not Character then
            local waitStart = tick()
            local conn
            conn = LocalPlayer.CharacterAdded:Connect(function(c)
                Character = c
            end)
            while not Character and tick() - waitStart < 5 do
                task.wait(0.2)
            end
            if conn then conn:Disconnect() end
        end

        Humanoid = Character and (Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 5))
        HumanoidRootPart = Character and (Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 5))

        PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
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
                    local enemies = workspace:FindFirstChild("Enemies")
                    local found = enemies and enemies:FindFirstChild(Index)
                    if not found then
                        local chars = workspace:FindFirstChild("Characters")
                        found = chars and chars:FindFirstChild(Index)
                    end
                    return found
                end
            }
        )

        setmetatable(
            ScriptStorage.Tools,
            {
                __index = function(Self, Index)
                    return (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(Index)) or
                        (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild(Index))
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
        -- AFK Check System (Tối ưu hóa)
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
                                
                                -- Check if player is moving (distance >= 5 studs)
                                if distance >= 5 then
                                    -- Player moved, reset idle timer
                                    idleStartTime = nil
                                else
                                    -- Player not moving
                                    if not idleStartTime then
                                        -- Start tracking idle time
                                        idleStartTime = currentTime
                                    else
                                        -- Check if idle time exceeds threshold
                                        if (currentTime - idleStartTime) >= Config.Configuration.IdleCheck then
                                            print("[AFK Check] Player is idle for " .. (currentTime - idleStartTime) .. " seconds, rejoining...")
                                            if Hop then
                                                Hop("Rejoin")
                                            else
                                                SafeRejoinOrHop("Rejoin")
                                            end
                                            return
                                        end
                                    end
                                end
                            end
                            
                            lastPosition = currentPosition
                        else
                            -- Character not loaded, reset tracking
                            lastPosition = nil
                            idleStartTime = nil
                        end
                    end)
                end
            end
        end)
        function CreateTraceback(Index, Value) -- i gave up
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
        local DummyRemote = {
            InvokeServer = function(...) return nil end,
            FireServer = function(...) return nil end,
            OnClientEvent = {
                Connect = function(...) return { Disconnect = function() end } end
            }
        }

        setmetatable(Remotes, {
            __index = function(Self, Key)
                if Key == "CommF_" then
                    local tbl = {
                        InvokeServer = function(Self, ...)
                            if Services.ReplicatedStorage and Services.ReplicatedStorage:FindFirstChild("Remotes") and Services.ReplicatedStorage.Remotes:FindFirstChild("CommF_") then
                                return Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
                            end
                            return nil
                        end
                    }
                    return tbl
                end

                if Key == "Redeem" then
                    return {
                        InvokeServer = function(Self, code)
                            pcall(function()
                                if Services.ReplicatedStorage and Services.ReplicatedStorage:FindFirstChild("Remotes") and Services.ReplicatedStorage.Remotes:FindFirstChild("CommF_") then
                                    Services.ReplicatedStorage.Remotes.CommF_:InvokeServer("RedeemCustomCode", code)
                                end
                            end)
                            return nil
                        end
                    }
                end

                local targetRemote = nil
                pcall(function()
                    if Services.ReplicatedStorage and Services.ReplicatedStorage:FindFirstChild("Remotes") then
                        targetRemote = Services.ReplicatedStorage.Remotes:FindFirstChild(Key)
                    end
                end)
                return targetRemote or DummyRemote
            end
        })
        

        Tasks = {}

        function AwaitUntilPlayerLoaded(Player, Timeout)
            local maxWait = tick() + (Timeout or 8)
            repeat
                task.wait(0.2)
            until (Player and Player.Character and Player.Character:FindFirstChild("Humanoid")) or tick() > maxWait
        end

        function AddPoint()
            pcall(function()
                if not LocalPlayer or not LocalPlayer:FindFirstChild("Data") or not LocalPlayer.Data:FindFirstChild("Stats") then return end
                local PointsValue = {}
                local Result
                for _, CInst in pairs(LocalPlayer.Data.Stats:GetChildren()) do
                    if CInst and CInst:FindFirstChild("Level") then
                        PointsValue[CInst.Name] = CInst.Level.Value
                    end
                end
                local defense = PointsValue.Defense or 0
                local melee = PointsValue.Melee or 0
                local lvl = (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or 1
                if defense < MaxLevel and (defense < (lvl / 80) or MaxLevel - melee < 100) then
                    Result = "Defense"
                elseif melee < MaxLevel then
                    Result = "Melee"
                else
                    Result = "Sword"
                end
                if Remotes and Remotes.CommF_ then
                    Remotes.CommF_:InvokeServer("AddPoint", Result, 999)
                end
            end)
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
            pcall(function()
                if not LocalPlayer or not LocalPlayer:FindFirstChild("Data") then return end
                for _, ChildInstance in pairs(LocalPlayer.Data:GetChildren()) do
                    pcall(function()
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
                        if ScriptStorage and ScriptStorage.PlayerData then
                            ScriptStorage.PlayerData[ChildInstance.Name] = val
                        end
                    end)
                end

                local Currencies = ""
                if ScriptStorage and ScriptStorage.PlayerData then
                    for Index, Value in pairs(ScriptStorage.PlayerData) do
                        local Color = Colors and Colors.Currencies and Colors.Currencies[Index]
                        if Color then
                            Currencies = Currencies .. '<font color="' .. Color .. '">' .. Index .. "</font>: " .. tostring(Value) .. " "
                        end
                    end
                end

                if ScriptStorage and ScriptStorage.Interface and type(ScriptStorage.Interface.SetText) == "function" then
                    pcall(function() SetText("Currencies", Currencies) end)
                end
            end)
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

        local LastInventoryRefreshTime = 0
        function RefreshInventory(Force)
            if not Force and os.time() - LastInventoryRefreshTime < 5 then
                return
            end
            LastInventoryRefreshTime = os.time()
            pcall(function()
                if not Remotes or not Remotes.CommF_ then return end
                
                -- 1. Quét các vật phẩm & nguyên liệu thông thường
                local inv = nil
                pcall(function() inv = Remotes.CommF_:InvokeServer("getInventory") end)
                if type(inv) == "table" and #inv > 0 then
                    local newBp = {}
                    for _, Value in pairs(inv) do
                        if type(Value) == "table" and Value.Name then
                            pcall(function()
                                if Value.Type == 'Blox Fruit' and game:GetService("Players").LocalPlayer:FindFirstChild("Data") and game:GetService("Players").LocalPlayer.Data:FindFirstChild("DevilFruit") and game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and Config and Config.Items and type(Config.Items.Eatlist) == "table" and table.find(Config.Items.Eatlist, Value.Name) then
                                    warn("Load fruit", Value.Name)
                                    Remotes.CommF_:InvokeServer("LoadFruit", Value.Name)
                                    task.wait(1)
                                    if FunctionsHandler and FunctionsHandler.LocalPlayerController and FunctionsHandler.LocalPlayerController.Methods and FunctionsHandler.LocalPlayerController.Methods.EquipTool then
                                        pcall(function() FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(FruitIdToName(Value.Name)) end)
                                    end
                                end
                            end)
                            newBp[Value.Name] = Value
                            local cleanName = string.lower(string.gsub(Value.Name, "^%s*(.-)%s*$", "%1"))
                            newBp[cleanName] = Value
                            newBp[string.gsub(cleanName, "%s+", "")] = Value
                        end
                    end

                    -- 2. Quét toàn bộ Trái Ác Quỷ lưu trữ trong Treasure Inventory (getInventoryFruits)
                    local fruits = nil
                    pcall(function() fruits = Remotes.CommF_:InvokeServer("getInventoryFruits") end)
                    if type(fruits) == "table" then
                        for _, Value in pairs(fruits) do
                            if type(Value) == "table" and Value.Name then
                                Value.Type = "Blox Fruit"
                                newBp[Value.Name] = Value
                                local cleanName = string.lower(string.gsub(Value.Name, "^%s*(.-)%s*$", "%1"))
                                newBp[cleanName] = Value
                                newBp[string.gsub(cleanName, "%s+", "")] = Value
                            end
                        end
                    end

                    ScriptStorage.Backpack2 = newBp
                    ScriptStorage.Backpack = newBp
                end
            end)
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
                    -- task.spawn(function()
                    --   CheckMeleeBurstMove(Child)
                    -- end)

                    if ScriptStorage.Connections.Melees then
                        ScriptStorage.Connections.Melees:Disconnect()
                    end

                    ScriptStorage.CurrentMeleeData.Name = Child.Name
                    pcall(
                        function()
                            ScriptStorage.Connections.Melees:Destroy()
                        end
                    )

                    -- Check if Level property exists before accessing it
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
                        -- Tool doesn't have Level property, skip
                        print("[MeleeCheck] Tool", Child.Name, "does not have Level property")
                    end
                elseif string.find(tostring(Child), "Fruit") then
                    task.spawn(
                        function()
                            -- Tạm thời disable store fruit khi đang load fruit cho Trevor
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
        SetText("MainTextLabel", "Loading Game Modules...")
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

            pcall(function()
                local char = LocalPlayer.Character
                if not char then
                    local waitChar = tick() + 3
                    repeat
                        task.wait(0.1)
                        char = LocalPlayer.Character
                    until char or tick() > waitChar
                end
                local hum = char and (char:FindFirstChild("Humanoid") or char:FindFirstChildOfClass("Humanoid"))
                if hum then
                    ScriptStorage.Connections.LocalPlayer["HealthCheck"] =
                        hum:GetPropertyChangedSignal("Health"):Connect(
                        function()
                            local Health = hum.Health
                            LocalPlayer:SetAttribute("IsAvailable", Health > 10)
                            ScriptStorage.LocalPlayerHealth = Health
                        end
                    )
                end

                if char then
                    ScriptStorage.Connections.LocalPlayer["Melee"] = char.ChildAdded:Connect(MeleeCheck)
                end
                if LocalPlayer:FindFirstChild("Backpack") then
                    ScriptStorage.Connections.LocalPlayer["Fruit"] = LocalPlayer.Backpack.ChildAdded:Connect(MeleeCheck)
                    for _, Melee in pairs(LocalPlayer.Backpack:GetChildren()) do
                        pcall(function() MeleeCheck(Melee) end)
                    end
                end

                local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3))
                if hrp then
                    LastIdleCheck = os.time()
                    ScriptStorage.Connections.LocalPlayer.PositionChecker =
                        hrp:GetPropertyChangedSignal("CFrame"):Connect(
                        function()
                            if os.time() == LastIdleCheck then
                                return
                            end
                            LastIdleCheck = os.time()
                            if oldPos and hrp and hrp.Parent then
                                if (hrp.CFrame.p - oldPos).magnitude < 2 then
                                    return
                                end
                            end
                            if hrp and hrp.Parent then
                                oldPos = (hrp.CFrame.p)
                            end
                            LastIdling = os.time()
                        end
                    )
                end
            end)

            pcall(function()
                if not LocalPlayer or not LocalPlayer:FindFirstChild("Data") then return end
                local PointsInstance = LocalPlayer.Data:FindFirstChild("Points") or LocalPlayer.Data:WaitForChild("Points", 3)
                if PointsInstance then
                    ScriptStorage.Connections.LocalPlayer.PointConnection =
                        PointsInstance:GetPropertyChangedSignal("Value"):Connect(
                        function()
                            local CurrentValue = PointsInstance.Value
                            if OldPointValue == CurrentValue then
                                return
                            end

                            OldPointValue = CurrentValue
                            task.wait(1)
                            AddPoint()
                        end
                    )
                end
            end)
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
            "Fishman Karate"
        }

        MeleesId = {
            "BlackLeg",
            "Electro",
            "FishmanKarate"
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
            "SpecialBossesTask",
            "UtillyItemsActivitation",
            "Saber",
            "CollectDrops",
            "BossesTask",
            -- MeleesController dat o day vi Refresh cua no tra ve true suot khi chua du 400
            -- mastery ca 3 vo; de tren thi CollectDrops/BossesTask khong bao duoc chay
            "MeleesController",
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
        else
            -- Robust fallback detection using workspace Map
            local map = workspace:FindFirstChild("Map")
            if map and (map:FindFirstChild("Turtle") or map:FindFirstChild("Haunted Castle") or map:FindFirstChild("Port Town") or map:FindFirstChild("Great Tree")) then
                Sea = "Zou"
                SeaIndex = 3
            elseif map and (map:FindFirstChild("Ice Castle") or map:FindFirstChild("Green Zone") or map:FindFirstChild("Colosseum") or map:FindFirstChild("Kingdom of Rose")) then
                Sea = "Dressrosa"
                SeaIndex = 2
            elseif map and (map:FindFirstChild("Jungle") or map:FindFirstChild("Pirate") or map:FindFirstChild("Marine")) then
                Sea = "Main"
                SeaIndex = 1
            else
                Sea = "Zou"
                SeaIndex = 3
            end
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
        })[SeaIndex] or {}

        BossesOrder = {
            "The Gorilla King",
            "Bobby",
            "Awakened Ice Admiral", 
            "Tide Keeper", 
            "Deandre", 
            "Urban", 
            "Diablo", 
            "Soul Reaper", 
            "Cake Prince"
        }
        BossesOrderLevel = {
            -- Boss pop o Sea 1: them de lvl thap van co boss ma danh (danh sach cu bat dau tu 700)
            ["The Gorilla King"] = 25,
            ["Bobby"] = 35,
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

            local lp = game:GetService("Players").LocalPlayer
            local myHrp = lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            Desnitation = Desnitation or (myHrp and myHrp.CFrame)
            if not Desnitation then return 0 end

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
            local now = os.date("*t") -- Get the current time as a table

            local hour = now.hour
            local minute = now.min
            local day = now.day
            local month = now.month
            local year = now.year
            local weekday = now.wday -- Day of the week (1 = Sunday, 7 = Saturday)

            local formattedTime = string.format("%02d:%02d ", hour, minute) -- Format time HH:MM

            local weekdays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
            local formattedWeekday = weekdays[weekday]

            local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
            local formattedMonth = months[month]

            local formattedDate = string.format("%s, %s %d %d", formattedWeekday, formattedMonth, day, year)

            return formattedTime .. formattedDate -- Combine time and date
        end

    
        function RoundVector3Down(vec)
            if not vec then return Vector3.new() end
            return vec
        end

        CaculateCircreDirection = function(Position)
            local posVec = (typeof(Position) == "CFrame" and Position.Position) or (typeof(Position) == "Vector3" and Position) or Vector3.new()
            return CFrame.new(posVec.X, posVec.Y, posVec.Z)
        end

        function GetMonAsSortedRange()
            local Result = {}
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, Mon in pairs(enemies:GetChildren()) do
                        if Mon and Mon:IsA("Model") and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and Mon.Humanoid.Health > 0 then
                            table.insert(Result, Mon)
                        end
                    end
                end

                local chars = workspace:FindFirstChild("Characters")
                if chars then
                    for _, Mon in pairs(chars:GetChildren()) do
                        if Mon and Mon:IsA("Model") and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and Mon.Humanoid.Health > 0 and Mon ~= game.Players.LocalPlayer.Character then
                            table.insert(Result, Mon)
                        end
                    end
                end

                table.sort(
                    Result,
                    function(C1, C2)
                        local p1 = C1 and C1:FindFirstChild("HumanoidRootPart") and C1.HumanoidRootPart.Position
                        local p2 = C2 and C2:FindFirstChild("HumanoidRootPart") and C2.HumanoidRootPart.Position
                        if not p1 or not p2 then return false end
                        return CaculateDistance(p1) < CaculateDistance(p2)
                    end
                )
            end)

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
            local repNpcs = game:GetService("ReplicatedStorage"):FindFirstChild("NPCs")
            if repNpcs then
                for _, v in pairs(repNpcs:GetChildren()) do
                    if v.Name == npcname then
                        local hrp = v:FindFirstChild("HumanoidRootPart")
                        if hrp then return hrp.CFrame end
                        if v.PrimaryPart then return v.PrimaryPart.CFrame end
                        return v:GetPivot()
                    end
                end
            end
            local wsNpcs = workspace:FindFirstChild("NPCs")
            if wsNpcs then
                for _, v in pairs(wsNpcs:GetChildren()) do
                    if v.Name == npcname then
                        local hrp = v:FindFirstChild("HumanoidRootPart")
                        if hrp then return hrp.CFrame end
                        if v.PrimaryPart then return v.PrimaryPart.CFrame end
                        return v:GetPivot()
                    end
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
                ImpelQuest = 1,
                PrisonerQuest = 1, -- Bỏ qua nhiệm vụ đảo nhà tù (tránh trùng tên NPC)
                SubmergedQuest1 = 1,
                SubmergedQuest2 = 1
            }
        }

        local BuiltInQuests = {
            -- Sea 1
            BanditQuest1 = { { Task = { ["Bandit"] = 5 }, LevelReq = 1, Name = "Bandit" } },
            JungleQuest = { { Task = { ["Monkey"] = 6 }, LevelReq = 10, Name = "Monkey" }, { Task = { ["Gorilla"] = 8 }, LevelReq = 15, Name = "Gorilla" } },
            BuggyQuest1 = { { Task = { ["Pirate"] = 8 }, LevelReq = 30, Name = "Pirate" }, { Task = { ["Brute"] = 8 }, LevelReq = 40, Name = "Brute" } },
            DesertQuest = { { Task = { ["Desert Bandit"] = 8 }, LevelReq = 60, Name = "Desert Bandit" }, { Task = { ["Desert Officer"] = 6 }, LevelReq = 75, Name = "Desert Officer" } },
            SnowQuest = { { Task = { ["Snow Bandit"] = 7 }, LevelReq = 90, Name = "Snow Bandit" }, { Task = { ["Snowman"] = 8 }, LevelReq = 100, Name = "Snowman" } },
            MarineQuest2 = { { Task = { ["Chief Petty Officer"] = 8 }, LevelReq = 120, Name = "Chief Petty Officer" } },
            SkyQuest = { { Task = { ["Sky Bandit"] = 7 }, LevelReq = 150, Name = "Sky Bandit" }, { Task = { ["Dark Master"] = 8 }, LevelReq = 175, Name = "Dark Master" } },
            PrisonerQuest = { { Task = { ["Prisoner"] = 8 }, LevelReq = 190, Name = "Prisoner" }, { Task = { ["Dangerous Prisoner"] = 8 }, LevelReq = 210, Name = "Dangerous Prisoner" } },
            ColosseumQuest = { { Task = { ["Toga Warrior"] = 7 }, LevelReq = 250, Name = "Toga Warrior" }, { Task = { ["Gladiator"] = 8 }, LevelReq = 275, Name = "Gladiator" } },
            MagmaQuest = { { Task = { ["Military Soldier"] = 8 }, LevelReq = 300, Name = "Military Soldier" }, { Task = { ["Military Spy"] = 8 }, LevelReq = 325, Name = "Military Spy" } },
            FishmanQuest = { { Task = { ["Fishman Warrior"] = 8 }, LevelReq = 375, Name = "Fishman Warrior" }, { Task = { ["Fishman Commando"] = 7 }, LevelReq = 400, Name = "Fishman Commando" } },
            SkyExp1Quest = { { Task = { ["Gods Guard"] = 7 }, LevelReq = 450, Name = "Gods Guard" }, { Task = { ["Shanda"] = 8 }, LevelReq = 475, Name = "Shanda" } },
            SkyExp2Quest = { { Task = { ["Royal Squad"] = 8 }, LevelReq = 525, Name = "Royal Squad" }, { Task = { ["Royal Soldier"] = 8 }, LevelReq = 550, Name = "Royal Soldier" } },
            FountainQuest = { { Task = { ["Galley Pirate"] = 8 }, LevelReq = 625, Name = "Galley Pirate" }, { Task = { ["Galley Captain"] = 8 }, LevelReq = 650, Name = "Galley Captain" } }
        }

        local BuiltInNpcPositions = {
            BanditQuest1 = Vector3.new(1060, 16, 1549),
            JungleQuest = Vector3.new(-1600, 37, 153),
            BuggyQuest1 = Vector3.new(-1140, 4, 3828),
            DesertQuest = Vector3.new(896, 6, 4390),
            SnowQuest = Vector3.new(1386, 87, -1298),
            MarineQuest2 = Vector3.new(-5035, 29, 4325),
            SkyQuest = Vector3.new(-4840, 718, -2620),
            PrisonerQuest = Vector3.new(4840, 6, 743),
            ColosseumQuest = Vector3.new(-1575, 7, -2985),
            MagmaQuest = Vector3.new(-5315, 9, 8515),
            FishmanQuest = Vector3.new(61122, 18, 1568),
            SkyExp1Quest = Vector3.new(-7720, 5545, -450),
            SkyExp2Quest = Vector3.new(-7780, 5607, -1450),
            FountainQuest = Vector3.new(5258, 39, 4050)
        }

        local NpcList = {}
        QuestManager.Quests = BuiltInQuests

        task.spawn(function()
            pcall(function()
                local guideMod = game:GetService("ReplicatedStorage"):FindFirstChild("GuideModule")
                if guideMod and guideMod:IsA("ModuleScript") then
                    local reqGuide = require(guideMod)
                    if reqGuide and reqGuide.Data and reqGuide.Data.NPCList then
                        NpcList = reqGuide.Data.NPCList
                    end
                end
            end)
        end)

        task.spawn(function()
            pcall(function()
                local questsMod = game:GetService("ReplicatedStorage"):FindFirstChild("Quests")
                if questsMod and questsMod:IsA("ModuleScript") then
                    local q = require(questsMod)
                    if q and type(q) == "table" then
                        for k, v in pairs(q) do
                            QuestManager.Quests[k] = v
                        end
                    end
                end
            end)
        end)

        local Sea1Quests = {
            "BanditQuest1", "JungleQuest", "BuggyQuest1", "DesertQuest", "SnowQuest",
            "MarineQuest2", "SkyQuest", "ColosseumQuest", "MagmaQuest",
            "FishmanQuest", "SkyExp1Quest", "SkyExp2Quest", "FountainQuest"
        }

        local QuestNpcCandidateNames = {
            BanditQuest1 = {"Bandit Quest Giver", "Quest Giver"},
            JungleQuest = {"Jungle Quest Giver", "Quest Giver"},
            BuggyQuest1 = {"Pirate Quest Giver", "Buggy Quest Giver", "Quest Giver"},
            DesertQuest = {"Desert Quest Giver", "Quest Giver"},
            SnowQuest = {"Snow Quest Giver", "Quest Giver"},
            MarineQuest2 = {"Marine Quest Giver", "Quest Giver"},
            SkyQuest = {"Sky Quest Giver", "Sky Quest", "Quest Giver", "Sky Adventure"},
            PrisonerQuest = {"Prison Quest Giver", "Warden", "Quest Giver"},
            ColosseumQuest = {"Colosseum Quest Giver", "Quest Giver"},
            MagmaQuest = {"Magma Quest Giver", "Quest Giver"},
            FishmanQuest = {"Fishman Quest Giver", "Quest Giver"},
            SkyExp1Quest = {"Sky Quest Giver 1", "Sky Quest 1", "Sky Quest Giver", "Quest Giver"},
            SkyExp2Quest = {"Sky Quest Giver 2", "Sky Quest 2", "Sky Quest Giver", "Quest Giver"},
            FountainQuest = {"Fountain Quest Giver", "Quest Giver"}
        }

        function QuestManager.FindLiveNpc(Self, QuestId, TargetMobName)
            local foundPos = nil
            pcall(function()
                local wsNpcs = workspace:FindFirstChild("NPCs")
                local refPos = (QuestId and BuiltInNpcPositions[QuestId]) or nil
                if not refPos and TargetMobName then
                    if ScriptStorage.MobRegions and ScriptStorage.MobRegions[TargetMobName] and #ScriptStorage.MobRegions[TargetMobName] > 0 then
                        local r = ScriptStorage.MobRegions[TargetMobName][1]
                        refPos = (typeof(r) == "CFrame" and r.Position) or (typeof(r) == "Vector3" and r)
                    elseif MobPositionsFallback and MobPositionsFallback[TargetMobName] then
                        local r = MobPositionsFallback[TargetMobName]
                        refPos = (typeof(r) == "CFrame" and r.Position) or (typeof(r) == "Vector3" and r)
                    end
                end

                if not refPos then
                    return nil
                end

                -- Quét model trong workspace.NPCs để chọn đúng NPC đứng gần refPos trên cùng hòn đảo
                -- KHÔNG dùng wsNpcs:FindFirstChild vì các NPC đều bị đặt tên trùng nhau ("Quest Giver")
                -- CHỈ chấp nhận NPC model nằm trong bán kính 300 studs quanh refPos chuẩn!
                if wsNpcs then
                    local bestDist = 300
                    local bestNpcPos = nil
                    local candidateList = (QuestId and QuestNpcCandidateNames[QuestId]) or {"Quest Giver"}

                    for _, npcObj in ipairs(wsNpcs:GetChildren()) do
                        if npcObj:IsA("Model") then
                            local nName = npcObj.Name
                            local isGiver = string.find(nName, "Quest") or string.find(nName, "Giver") or table.find(candidateList, nName)
                            if isGiver then
                                local hrp = npcObj:FindFirstChild("HumanoidRootPart") or npcObj:FindFirstChild("Head") or npcObj.PrimaryPart or npcObj:FindFirstChildWhichIsA("BasePart")
                                local p = hrp and hrp.Position or (npcObj.GetPivot and npcObj:GetPivot().Position)
                                if p then
                                    local sameAltitude = true
                                    if refPos.Y > 4000 and p.Y < 4000 then sameAltitude = false end
                                    if refPos.Y < 2000 and p.Y > 4000 then sameAltitude = false end
                                    if refPos.X > 50000 and p.X < 20000 then sameAltitude = false end
                                    if refPos.X < 20000 and p.X > 50000 then sameAltitude = false end

                                    if sameAltitude then
                                        local d = (p - refPos).Magnitude
                                        if d < bestDist then
                                            bestDist = d
                                            bestNpcPos = p
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if bestNpcPos then
                        foundPos = bestNpcPos
                        return
                    end
                end

                -- Nếu không tìm thấy live model trong 300 studs, sử dụng chính xác refPos (BuiltInNpcPositions)
                foundPos = refPos
            end)
            return foundPos
        end

        function QuestManager.Set(Self, Index, Value)
            Self[Index] = Value
        end

        function QuestManager.RefreshQuest(Self)
            pcall(function()
                local retries = 0
                while not (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) do
                    pcall(RefreshPlayerData)
                    if not (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) then
                        local lp = game:GetService("Players").LocalPlayer
                        if lp and lp:FindFirstChild("Data") and lp.Data:FindFirstChild("Level") then
                            if not ScriptStorage.PlayerData then ScriptStorage.PlayerData = {} end
                            ScriptStorage.PlayerData.Level = lp.Data.Level.Value
                        end
                    end
                    if ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level then break end
                    task.wait(0.2)
                    retries = retries + 1
                    if retries > 15 then
                        if not ScriptStorage.PlayerData then ScriptStorage.PlayerData = {} end
                        ScriptStorage.PlayerData.Level = 1
                        break
                    end
                end

                local pLevel = ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level or 1
                local allowedQuests = Sea1Quests
                local QuestLevelFlag = -1
                local CurrentQuestData = nil
                local BestQuestId = nil

                for _, QuestID in ipairs(allowedQuests) do
                    if not QuestManager.BlacklistedQuestIds or not QuestManager.BlacklistedQuestIds[QuestID] then
                        local QuestDatas = (QuestManager.Quests and QuestManager.Quests[QuestID]) or BuiltInQuests[QuestID]
                        if QuestDatas and QuestDatas[1] and QuestDatas[1].LevelReq then
                            if QuestDatas[1].LevelReq <= pLevel and QuestDatas[1].LevelReq > QuestLevelFlag then
                                QuestLevelFlag = QuestDatas[1].LevelReq
                                -- Make a shallow copy of table so modifications don't corrupt BuiltInQuests
                                local copied = {}
                                for idx, entry in ipairs(QuestDatas) do
                                    table.insert(copied, entry)
                                end
                                CurrentQuestData = copied
                                BestQuestId = QuestID
                            end
                        end
                    end
                end

                if BestQuestId then
                    Self.CurrentQuestId = BestQuestId
                end

                Self.CurrentNpc = nil

                if CurrentQuestData and #CurrentQuestData > 0 then
                    local LastQuest = CurrentQuestData[#CurrentQuestData]
                    if LastQuest and LastQuest.Task then
                        for _, Count in pairs(LastQuest.Task) do
                            if Count == 1 then
                                table.remove(CurrentQuestData, #CurrentQuestData)
                            end
                        end
                    end

                    -- Xác định quái mục tiêu cho quest hiện tại
                    local targetMobName = nil
                    for qIdx = #CurrentQuestData, 1, -1 do
                        local qData = CurrentQuestData[qIdx]
                        if qData and qData.LevelReq and qData.LevelReq <= pLevel then
                            if qData.Task then
                                for mName in pairs(qData.Task) do
                                    targetMobName = mName
                                    break
                                end
                            end
                            break
                        end
                    end

                    -- 1. ƯU TIÊN SỐ 1: Quét trực tiếp NPC Model đang spawn trong workspace.NPCs trên cùng hòn đảo
                    local liveNpcPos = QuestManager:FindLiveNpc(Self.CurrentQuestId, targetMobName)
                    if liveNpcPos then
                        Self.CurrentNpc = liveNpcPos
                    elseif Self.CurrentQuestId and BuiltInNpcPositions[Self.CurrentQuestId] then
                        Self.CurrentNpc = BuiltInNpcPositions[Self.CurrentQuestId]
                    end
                end

                Self.CurrentQuests = CurrentQuestData
            end)
        end

        function QuestManager.GetCurrentQuest(Self)
            if not Self.CurrentQuests or #Self.CurrentQuests == 0 then
                return nil, Self.CurrentNpc, Self.CurrentQuestId, 1, nil
            end
            local pLvl = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or 1
            local QuestIndex = 1
            -- Chọn sub-quest cao nhất mà người chơi đã đủ cấp độ nhận
            for qIdx = #Self.CurrentQuests, 1, -1 do
                local qData = Self.CurrentQuests[qIdx]
                if qData and qData.LevelReq and qData.LevelReq <= pLvl then
                    QuestIndex = qIdx
                    break
                end
            end

            if Self.CurrentQuests[QuestIndex] and Self.CurrentQuests[QuestIndex].Task then
                for Name in pairs(Self.CurrentQuests[QuestIndex].Task) do
                    return Name, Self.CurrentNpc, Self.CurrentQuestId, QuestIndex, Self.CurrentQuests[QuestIndex].Name
                end
            end
            return nil, Self.CurrentNpc, Self.CurrentQuestId, 1, nil
        end

        function QuestManager.MarkAsCompleted(Self)
            Self.CurrentLevel = Self.CurrentLevel == 2 and 1 or 2
        end

        function QuestManager.AbandonQuest()
            print("Abandon quest")
            Remotes.CommF_:InvokeServer("AbandonQuest")
        end

        -- [PERF] Tim frame Quest co cache. Di qua TOAN BO PlayerGui:GetDescendants() moi frame
        -- la nguyen nhan lag lon nhat tren dien thoai -> chi quet lai khi cache chet, toi da 2s/lan
        QuestFrameCache = {Frame = nil, NextTry = 0}
        function FindQuestFrameCached()
            local player = game:GetService("Players").LocalPlayer
            local pgui = player and player:FindFirstChild("PlayerGui")
            if not pgui then
                return nil
            end
            local mainGui = pgui:FindFirstChild("Main") or pgui:FindFirstChild("MainGui") or pgui:FindFirstChild("Hud")
            local questFrame = mainGui and (mainGui:FindFirstChild("Quest") or mainGui:FindFirstChild("QuestFrame"))
            if questFrame then
                return questFrame
            end
            local cached = QuestFrameCache.Frame
            if cached and cached.Parent then
                return cached
            end
            if tick() < QuestFrameCache.NextTry then
                return nil
            end
            QuestFrameCache.NextTry = tick() + 2
            for _, child in pairs(pgui:GetDescendants()) do
                if child.Name == "Quest" and (child:IsA("Frame") or child:IsA("CanvasGroup") or child:IsA("GuiObject")) then
                    QuestFrameCache.Frame = child
                    return child
                end
            end
            QuestFrameCache.Frame = nil
            return nil
        end

        function QuestManager.HasActiveQuest()
            -- [PERF] Ham nay goi MOI FRAME; no duyet toan bo cay UI cua frame Quest
            -- -> cache ket qua 0.5s de tiet kiem CPU tren dien thoai
            if QuestUIPollCache and tick() < QuestUIPollCache.Next then
                return table.unpack(QuestUIPollCache.Val, 1, 4)
            end
            local hasQuest = false
            local cleanTitle, rawTitle = nil, nil
            local currentKills, maxKills = nil, nil

            -- 0. Grace period: Trong thời gian ân hạn sau khi nhận quest (mặc định 8s), luôn coi là đang có quest active
            -- Tự động mở rộng thời gian ân hạn nếu bãi quái ở xa (DynamicQuestGracePeriod)
            local baseGracePeriod = (Config and Config.Settings and tonumber(Config.Settings.QuestGracePeriod)) or 8
            local gracePeriod = math.max(baseGracePeriod, tonumber(getgenv().DynamicQuestGracePeriod) or baseGracePeriod)
            if getgenv().LastQuestClaimTick and (tick() - getgenv().LastQuestClaimTick < gracePeriod) then
                hasQuest = true
            end

            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local pgui = player and player:FindFirstChild("PlayerGui")
                local mainGui = pgui and (pgui:FindFirstChild("Main") or pgui:FindFirstChild("MainGui") or pgui:FindFirstChild("Hud"))

                local questFrame = FindQuestFrameCached()

                if questFrame and questFrame.Visible == true then
                    hasQuest = true
                    
                    -- Tìm label tiến độ nhiệm vụ chính xác (ưu tiên label trong Container hoặc chứa định dạng (X/Y))
                    local foundProgress = false
                    for _, desc in pairs(questFrame:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
                            local txt = desc.Text
                            local isRewardOrLevel = string.find(txt, "Beli") or string.find(txt, "beli") or string.find(txt, "Exp") or string.find(txt, "exp") or string.find(txt, "Reward") or string.find(txt, "%+") or string.find(txt, "%$")

                            if not isRewardOrLevel then
                                -- Ưu tiên định dạng chuẩn (X/Y) ví dụ (0/8), (4/8)
                                local cur, total = string.match(txt, "%((%d+)%s*/%s*(%d+)%)")
                                if cur and total and tonumber(total) and tonumber(total) > 0 and tonumber(total) <= 50 then
                                    currentKills = tonumber(cur)
                                    maxKills = tonumber(total)
                                    foundProgress = true
                                elseif not foundProgress then
                                    local c2, t2 = string.match(txt, "(%d+)%s*/%s*(%d+)")
                                    if c2 and t2 and tonumber(t2) and tonumber(t2) > 1 and tonumber(t2) <= 50 then
                                        currentKills = tonumber(c2)
                                        maxKills = tonumber(t2)
                                    end
                                end

                                if string.find(txt, "Defeat") or string.find(txt, "defeat") or desc.Name == "Title" or desc.Name == "QuestTitle" then
                                    rawTitle = txt
                                end
                            end
                        end
                    end
                end

                -- Fallback qua GuideModule nếu UI chưa render kịp
                if not hasQuest then
                    local GuideEnv = pcall(function() return GetGuideEnv() end) and GetGuideEnv()
                    if GuideEnv and GuideEnv._G then
                        local curQ = GuideEnv._G.CurrentQuest or (GuideEnv._G.QuestData and GuideEnv._G.QuestData.QuestTitle)
                        if curQ and type(curQ) == "string" and curQ ~= "" and curQ ~= "None" then
                            hasQuest = true
                            rawTitle = curQ
                        end
                    end
                end

                if hasQuest then
                    local qClean, qRaw = QuestManager.GetCurrentClaimQuest()
                    if qClean and qClean ~= "" then
                        cleanTitle = qClean
                        rawTitle = rawTitle or qRaw
                    end
                end
            end)

            QuestUIPollCache = QuestUIPollCache or {}
            QuestUIPollCache.Val = {hasQuest, currentKills, maxKills, cleanTitle or rawTitle or "ActiveQuest"}
            QuestUIPollCache.Next = tick() + 0.5
            return table.unpack(QuestUIPollCache.Val, 1, 4)
        end

        function QuestManager.GetCurrentClaimQuest(selfOrRaw, rawResponse)
            local cleanTitle, rawTitle = nil, nil
            local isRaw = false
            if type(selfOrRaw) == "boolean" then
                isRaw = selfOrRaw
            elseif type(rawResponse) == "boolean" then
                isRaw = rawResponse
            end

            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local pgui = player and player:FindFirstChild("PlayerGui")
                local mainGui = pgui and (pgui:FindFirstChild("Main") or pgui:FindFirstChild("MainGui") or pgui:FindFirstChild("Hud"))

                -- 1. Check PlayerGui.Main.Quest (Standard Blox Fruits quest UI)
                local questFrame = FindQuestFrameCached()

                if questFrame then
                    -- IMPORTANT: In Blox Fruits, Quest.Visible is false when no quest is active!
                    if questFrame.Visible == false then
                        return
                    end

                    -- Check Container -> QuestTitle first
                    local container = questFrame:FindFirstChild("Container") or questFrame
                    local questTitleObj = container:FindFirstChild("QuestTitle") or container:FindFirstChild("Title") or container:FindFirstChild("QuestName")
                    
                    if questTitleObj then
                        if questTitleObj:IsA("TextLabel") and questTitleObj.Text and questTitleObj.Text ~= "" then
                            local t = questTitleObj.Text
                            if not string.match(t, "^%s*%(?%d+/%d+%)?%s*$") and not string.match(t, "^%s*%$?[%d,]+%s*[Ee]xp") and not string.match(t, "^%s*%$?[%d,]+%s*[Bb]eli") then
                                rawTitle = t
                            end
                        else
                            local childLabel = questTitleObj:FindFirstChild("Title") or questTitleObj:FindFirstChild("QuestTitle") or questTitleObj:FindFirstChildWhichIsA("TextLabel")
                            if childLabel and childLabel:IsA("TextLabel") and childLabel.Text and childLabel.Text ~= "" then
                                local t = childLabel.Text
                                if not string.match(t, "^%s*%(?%d+/%d+%)?%s*$") and not string.match(t, "^%s*%$?[%d,]+%s*[Ee]xp") and not string.match(t, "^%s*%$?[%d,]+%s*[Bb]eli") then
                                    rawTitle = t
                                end
                            end
                        end
                    end

                    -- Search text labels inside questFrame
                    if not rawTitle then
                        for _, desc in pairs(questFrame:GetDescendants()) do
                            if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
                                local txt = desc.Text
                                local isProgressOnly = string.match(txt, "^%s*%(?%d+/%d+%)?%s*$")
                                local isReward = string.find(txt, "Exp") or string.find(txt, "exp") or string.find(txt, "Beli") or string.find(txt, "beli") or string.find(txt, "Reward")
                                
                                if not isProgressOnly and not isReward and string.match(txt, "%a+") then
                                    if string.find(txt, "Defeat") or string.find(txt, "defeat") or desc.Name == "Title" or desc.Name == "QuestTitle" or desc.Name == "QuestName" then
                                        rawTitle = txt
                                        break
                                    elseif not rawTitle then
                                        rawTitle = txt
                                    end
                                end
                            end
                        end
                    end

                    -- If Quest frame is visible but couldn't parse title string, mark as active
                    if not rawTitle then
                        rawTitle = "ActiveQuest"
                    end
                end

                -- 2. Fallback: Check GuideModule
                if not rawTitle then
                    local GuideEnv = pcall(function() return GetGuideEnv() end) and GetGuideEnv()
                    if GuideEnv and GuideEnv._G then
                        if GuideEnv._G.CurrentQuest and type(GuideEnv._G.CurrentQuest) == "string" and GuideEnv._G.CurrentQuest ~= "" then
                            rawTitle = GuideEnv._G.CurrentQuest
                        elseif GuideEnv._G.QuestData and GuideEnv._G.QuestData.QuestTitle then
                            rawTitle = GuideEnv._G.QuestData.QuestTitle
                        end
                    end
                end

                if rawTitle and rawTitle ~= "" then
                    if isRaw then
                        cleanTitle = rawTitle
                    else
                        local cleaned = rawTitle:gsub("^%s*[Dd]efeat%s*%d*%s*", ""):gsub("%s*%b()", ""):gsub("%d+/%d+", ""):gsub("^%s*(.-)%s*$", "%1")
                        cleaned = string.gsub(cleaned, "Military ", "Mil. ")
                        if cleaned == "" then
                            cleaned = "ActiveQuest"
                        end
                        cleanTitle = cleaned
                    end
                end
            end)

            if cleanTitle and cleanTitle ~= "" then
                return cleanTitle, rawTitle
            end
            return nil, nil
        end

        function QuestManager.StartQuest(QuestId, QuestLevel)
            return Remotes.CommF_:InvokeServer("StartQuest", QuestId, QuestLevel)
        end

        ScriptStorage.MobRegions = {}
        pcall(function()
            local folder = game:GetService("ReplicatedStorage"):FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
            if folder then
                for _, Region in pairs(folder:GetChildren()) do
                    ScriptStorage.MobRegions[tostring(Region)] = ScriptStorage.MobRegions[tostring(Region)] or {}
                    table.insert(ScriptStorage.MobRegions[tostring(Region)], Region.CFrame)
                end
            end
        end)

        TweenController = {}
        local LastestTeleportToHomePoint = 0
        local Entries = {}
        pcall(function()
            local npcsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("NPCs") or workspace:FindFirstChild("NPCs")
            if npcsFolder then
                for _, NPC in pairs(npcsFolder:GetChildren()) do
                    if NPC.Name == "Set Home Point" and NPC:IsA("Model") then
                        pcall(function()
                            table.insert(Entries, NPC:GetModelCFrame())
                        end)
                    end
                end
            end
        end)
        local function NoclipLoop()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.CanCollide then
                    hrp.CanCollide = false
                end
            end
        end
        Noclipping = game:GetService("RunService").Stepped:Connect(NoclipLoop)
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
                    -- ["Great Tree"] = Vector3.new(2968.699951171875, 2284.286865234375, -7226.28662109375),
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
            pcall(function()
                if Remotes and Remotes.CommF_ then
                    Remotes.CommF_:InvokeServer(unpack(args))
                else
                    local rem = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                    local comm = rem and rem:FindFirstChild("CommF_")
                    if comm then comm:InvokeServer(unpack(args)) end
                end
            end)
        end
        
        -- TweenController
        
        function TweenController.Create(Position)
            -- 1. KIỂM TRA CƠ BẢN
            local Character = game.Players.LocalPlayer.Character
            if not Character or not Character:FindFirstChild("HumanoidRootPart") or not Character:FindFirstChild("Humanoid") then return end
            if not Position or TweenDebounce or TweenController._isCreating then return end
            
            -- Chống bay khi đang chết
            if Character.Humanoid.Health <= 0 then return end
        
            -- Chuyển đổi Position sang CFrame nếu cần
            local TargetCFrame = typeof(Position) ~= "CFrame" and CFrame.new(Position) or Position
            TargetCFrame = CFrame.new(TargetCFrame.Position)
        
            local RootPart = Character.HumanoidRootPart
            local CurrentDist = (RootPart.Position - TargetCFrame.Position).Magnitude
        
            -- 3. XỬ LÝ NOCLIP VÀ GIỮ VỮNG NHÂN VẬT (Chống rớt / chống dao động)
            pcall(function()
                Character.Humanoid.PlatformStand = true
                for _, name in ipairs({"HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso", "Head"}) do
                    local p = Character:FindFirstChild(name)
                    if p and p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end)
        
            -- 4. GIỮ NHÂN VẬT TRÊN KHÔNG AN TOÀN TUYỆT ĐỐI (BodyVelocity luôn bật MaxForce 9e9 để triệt tiêu trọng lực)
            local bv = RootPart:FindFirstChild("BocchiBV") or RootPart:FindFirstChild("eltrul")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "BocchiBV"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.zero
                bv.Parent = RootPart
            else
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.zero
            end

            pcall(function()
                RootPart.AssemblyLinearVelocity = Vector3.zero
                RootPart.AssemblyAngularVelocity = Vector3.zero
            end)

            -- 2. KHOẢNG CÁCH GẦN (<= 4 studs): Giữ nguyên vị trí ổn định, không tạo Tween liên tục gây rung lắc
            if CurrentDist <= 4 then
                RootPart.CFrame = TargetCFrame
                return
            end

            if TweenInstance and TweenInstance.PlaybackState == Enum.PlaybackState.Playing then
                if CurrentDist < 8 then return end
            end
        
            TweenController._isCreating = true

            -- 5. LOGIC DI CHUYỂN ĐẶC BIỆT (Sea 3 Submarine)
            if SeaIndex == 3 and TargetCFrame.Position.Y < -1500 then
                local SubmarinePos = CFrame.new(-16269, 23, 1371)
                if (RootPart.Position - SubmarinePos.Position).Magnitude > 60 then
                    TweenController._isCreating = false
                    TweenController.Create(SubmarinePos)
                    return
                end
                pcall(function()
                    local netModule = game.ReplicatedStorage:FindFirstChild("Modules") and game.ReplicatedStorage.Modules:FindFirstChild("Net")
                    if netModule and netModule:IsA("ModuleScript") then
                        local reqNet = require(netModule)
                        if reqNet and reqNet.RemoteFunction then
                            reqNet:RemoteFunction("SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
                        end
                    end
                end)
                TweenController._isCreating = false
                return
            end

            -- 6. THỰC THI TWEEN MƯỢT MÀ
            if TweenInstance then
                TweenInstance:Cancel()
            end

            local Speed = (CurrentDist < 30) and 45 or 160
            local Time = CurrentDist / Speed

            local tweenService = game:GetService("TweenService")
            TweenInstance = tweenService:Create(
                RootPart,
                TweenInfo.new(Time, Enum.EasingStyle.Linear),
                {CFrame = TargetCFrame}
            )
            
            TweenInstance.Completed:Connect(function()
                if bv and bv.Parent then
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Velocity = Vector3.zero
                end
                pcall(function()
                    RootPart.AssemblyLinearVelocity = Vector3.zero
                    RootPart.AssemblyAngularVelocity = Vector3.zero
                end)
            end)

            TweenInstance:Play()
        
            task.delay(0.08, function()
                TweenController._isCreating = false
            end)
        end



        local AttackController = {}

        -- ========================================================
        -- [GLOBAL INVENTORY & GODHUMAN REQUIREMENTS CONTROLLER]
        -- ========================================================
        local LastDirectInventoryCall = 0
        local AncientMonkMaterialsSubmitted = {}
        local AncientMonkCooldown = 0
        local LastSeaTravelTime = 0

        local GodhumanMaterialsList = {
            { Name = "Fish Tail", Req = 20, Sea = 3, Mobs = {"Fishman Raider", "Fishman Captain"} },
            { Name = "Dragon Scale", Req = 10, Sea = 3, Mobs = {"Dragon Crew Warrior", "Dragon Crew Archer"} },
            { Name = "Magma Ore", Req = 20, Sea = 2, Mobs = {"Magma Ninja"} },
            { Name = "Mystic Droplet", Req = 10, Sea = 2, Mobs = {"Sea Soldier", "Water Fighter"} }
        }

        local GodhumanMeleesList = {
            "Superhuman",
            "Death Step",
            "Electric Claw",
            "Sharkman Karate",
            "Dragon Talon"
        }

        function GetItemCount(itemName)
            if not itemName then return 0 end
            local searchName = string.lower(string.gsub(tostring(itemName), "^%s*(.-)%s*$", "%1"))
            local searchCompact = string.gsub(searchName, "%s+", "")
            
            -- 1. Check inside ScriptStorage.Backpack
            if ScriptStorage and ScriptStorage.Backpack and type(ScriptStorage.Backpack) == "table" then
                if ScriptStorage.Backpack[itemName] then
                    local v = ScriptStorage.Backpack[itemName]
                    if type(v) == "number" then return v end
                    if type(v) == "table" then
                        local cnt = tonumber(v.Count or v.Value or v.Amount or v.Quantity or 0) or 0
                        return cnt
                    end
                end
                if ScriptStorage.Backpack[searchName] then
                    local v = ScriptStorage.Backpack[searchName]
                    if type(v) == "number" then return v end
                    if type(v) == "table" then
                        local cnt = tonumber(v.Count or v.Value or v.Amount or v.Quantity or 0) or 0
                        return cnt
                    end
                end

                for k, v in pairs(ScriptStorage.Backpack) do
                    local nameInStorage = type(k) == "string" and k or (type(v) == "table" and v.Name)
                    if nameInStorage then
                        local cleanName = string.lower(string.gsub(tostring(nameInStorage), "^%s*(.-)%s*$", "%1"))
                        local cleanCompact = string.gsub(cleanName, "%s+", "")
                        if cleanName == searchName or cleanCompact == searchCompact or string.find(cleanName, searchName, 1, true) or string.find(cleanCompact, searchCompact, 1, true) then
                            if type(v) == "number" then return v end
                            if type(v) == "table" then
                                local cnt = tonumber(v.Count or v.Value or v.Amount or v.Quantity or 0) or 0
                                return cnt
                            end
                        end
                    end
                end
            end

            -- 2. Throttled fallback: Chỉ gọi getInventory nếu đã qua ít nhất 10s để chống lag và remote throttle
            local foundCount = 0
            local now = os.time()
            if now - LastDirectInventoryCall > 10 then
                LastDirectInventoryCall = now
                pcall(function()
                    if Remotes and Remotes.CommF_ then
                        local inv = Remotes.CommF_:InvokeServer("getInventory")
                        if type(inv) == "table" then
                            for _, Value in pairs(inv) do
                                if type(Value) == "table" and Value.Name then
                                    local cleanName = string.lower(string.gsub(tostring(Value.Name), "^%s*(.-)%s*$", "%1"))
                                    local cleanCompact = string.gsub(cleanName, "%s+", "")
                                    if cleanName == searchName or cleanCompact == searchCompact or string.find(cleanName, searchName, 1, true) or string.find(cleanCompact, searchCompact, 1, true) then
                                        foundCount = tonumber(Value.Count or Value.Value or Value.Amount or Value.Quantity or 0) or 0
                                    end
                                    if ScriptStorage and ScriptStorage.Backpack then
                                        ScriptStorage.Backpack[Value.Name] = Value
                                        ScriptStorage.Backpack[cleanName] = Value
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            return foundCount
        end

        function GetMeleeMastery(mName)
            if not mName then return 0 end
            local curPlayer = game.Players.LocalPlayer
            local char = curPlayer and curPlayer.Character
            local bp = curPlayer and curPlayer:FindFirstChild("Backpack")
            local tool = (char and char:FindFirstChild(mName)) or (bp and bp:FindFirstChild(mName))
            if tool then
                local lvlObj = tool:FindFirstChild("Level")
                if lvlObj and typeof(lvlObj.Value) == "number" and lvlObj.Value > 0 then
                    if ScriptStorage and ScriptStorage.Melees then
                        ScriptStorage.Melees[mName] = lvlObj.Value
                    end
                    return lvlObj.Value
                end
            end
            if ScriptStorage and ScriptStorage.Melees and tonumber(ScriptStorage.Melees[mName]) then
                return tonumber(ScriptStorage.Melees[mName]) or 0
            end
            return 0
        end

        function CheckGodhumanProgress()
            local status = {
                Unlocked = false,
                MissingMaterials = {},
                MissingMelees = {},
                CurBeli = 0,
                ReqBeli = 5000000,
                CurFragments = 0,
                ReqFragments = 5000,
                IsAllReady = false,
                SummaryText = ""
            }

            -- 0. Check xem đã sở hữu Godhuman chưa
            local curPlayer = game.Players.LocalPlayer
            local char = curPlayer and curPlayer.Character
            local bp = curPlayer and curPlayer:FindFirstChild("Backpack")
            if (char and char:FindFirstChild("Godhuman")) or (bp and bp:FindFirstChild("Godhuman")) or (ScriptStorage and ScriptStorage.Melees and ScriptStorage.Melees["Godhuman"]) then
                status.Unlocked = true
                status.SummaryText = "Godhuman đã mở khóa thành công!"
                return status
            end

            -- 1. Check Nguyên liệu
            for _, mat in ipairs(GodhumanMaterialsList) do
                local cnt = GetItemCount(mat.Name)
                if cnt < mat.Req and not AncientMonkMaterialsSubmitted[mat.Name] then
                    table.insert(status.MissingMaterials, {
                        Name = mat.Name,
                        Count = cnt,
                        Req = mat.Req,
                        Sea = mat.Sea,
                        Mobs = mat.Mobs
                    })
                end
            end

            -- 2. Check Mastery của 5 võ V2 (phải >= 400)
            for _, mName in ipairs(GodhumanMeleesList) do
                local lvl = GetMeleeMastery(mName)
                if lvl < 400 then
                    table.insert(status.MissingMelees, {
                        Name = mName,
                        Level = lvl,
                        Req = 400
                    })
                end
            end

            -- 3. Check Beli & Fragments
            local pData = ScriptStorage and ScriptStorage.PlayerData
            local rawBeli = (pData and pData.Beli) or (curPlayer and curPlayer:FindFirstChild("Data") and curPlayer.Data:FindFirstChild("Beli") and curPlayer.Data.Beli.Value) or 0
            local rawFrags = (pData and pData.Fragments) or (curPlayer and curPlayer:FindFirstChild("Data") and curPlayer.Data:FindFirstChild("Fragments") and curPlayer.Data.Fragments.Value) or 0
            status.CurBeli = tonumber(rawBeli) or 0
            status.CurFragments = tonumber(rawFrags) or 0

            local missingBeli = status.CurBeli < status.ReqBeli
            local missingFrags = status.CurFragments < status.ReqFragments

            -- Tổng kết trạng thái
            if #status.MissingMaterials == 0 and #status.MissingMelees == 0 and not missingBeli and not missingFrags then
                status.IsAllReady = true
                status.SummaryText = "ĐỦ 100% ĐIỀU KIỆN! Sẵn sàng nhận Godhuman tại Ancient Monk!"
            else
                local details = {}
                if #status.MissingMaterials > 0 then
                    local mList = {}
                    for _, m in ipairs(status.MissingMaterials) do
                        table.insert(mList, m.Name .. " (" .. m.Count .. "/" .. m.Req .. ")")
                    end
                    table.insert(details, "Thiếu NL: " .. table.concat(mList, ", "))
                end
                if #status.MissingMelees > 0 then
                    local meList = {}
                    for _, me in ipairs(status.MissingMelees) do
                        table.insert(meList, me.Name .. " (" .. me.Level .. "/400)")
                    end
                    table.insert(details, "Thiếu Mastery: " .. table.concat(meList, ", "))
                end
                if missingBeli then
                    table.insert(details, "Thiếu Beli (" .. math.floor(status.CurBeli/1000) .. "k/5,000k)")
                end
                if missingFrags then
                    table.insert(details, "Thiếu Frags (" .. status.CurFragments .. "/5,000)")
                end
                status.SummaryText = table.concat(details, " | ")
            end

            return status
        end

        function HasSaberItem()
            local lp = game:GetService("Players").LocalPlayer
            if not lp then return false end
            if ScriptStorage and ScriptStorage.Backpack and (ScriptStorage.Backpack.Saber or ScriptStorage.Backpack["saber"]) then return true end
            if ScriptStorage and ScriptStorage.Tools and (ScriptStorage.Tools.Saber or ScriptStorage.Tools["saber"]) then return true end
            if lp:FindFirstChild("Backpack") and (lp.Backpack:FindFirstChild("Saber") or lp.Backpack:FindFirstChild("saber")) then return true end
            if lp.Character and (lp.Character:FindFirstChild("Saber") or lp.Character:FindFirstChild("saber")) then return true end
            if ScriptStorage and ScriptStorage.Inventory and (ScriptStorage.Inventory.Saber or ScriptStorage.Inventory["saber"]) then return true end
            return false
        end

        function IsSaberQuestActive()
            if not (Config and Config.Items and Config.Items.Saber) then return false end
            if SeaIndex ~= 1 then return false end
            local level = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) 
                or (game.Players.LocalPlayer:FindFirstChild("Data") and game.Players.LocalPlayer.Data:FindFirstChild("Level") and game.Players.LocalPlayer.Data.Level.Value) or 0
            if level < 200 then return false end
            if HasSaberItem() then return false end
            return true
        end

        function BuyMelee(M1, Check, NPCName)
            -- Với Godhuman, CHỈ bay đến NPC Ancient Monk khi đã gom ĐỦ 100% nguyên liệu và điều kiện
            if M1 == "Godhuman" then
                local ghStatus = CheckGodhumanProgress()
                if not ghStatus.IsAllReady then
                    -- Chưa đủ nguyên liệu/điều kiện -> Tuyệt đối không bay tới Ancient Monk để tránh xung đột loop farm
                    return false
                end

                -- [SEA 1 ONLY] Không hỗ trợ Godhuman (Sea 3)
                if SeaIndex ~= 3 then
                    return false
                end

                local AncientMonkPos = CFrame.new(-2864, 45, -8378)
                -- Tìm NPC Ancient Monk trong workspace hoặc ReplicatedStorage nếu có
                local repNpc = game:GetService("ReplicatedStorage"):FindFirstChild("NPCs") and game:GetService("ReplicatedStorage").NPCs:FindFirstChild("Ancient Monk")
                local wsNpc = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Ancient Monk")
                local monkNpc = wsNpc or repNpc or (ScriptStorage.NPCs and ScriptStorage.NPCs["Ancient Monk"])
                if monkNpc then
                    if monkNpc.WorldPivot then
                        AncientMonkPos = monkNpc.WorldPivot
                    elseif monkNpc:FindFirstChild("HumanoidRootPart") then
                        AncientMonkPos = monkNpc.HumanoidRootPart.CFrame
                    end
                end

                local monkPosition = AncientMonkPos.Position or AncientMonkPos
                SetTask("MainTask", "Godhuman | Flying to Ancient Monk to Claim/Buy")
                SetTask("SubTask", "Flying to Ancient Monk (-2864, 45, -8378)")
                getgenv().anchored = true

                if CaculateDistance(monkPosition) > 15 then
                    local flyStart = os.time()
                    repeat
                        task.wait()
                        TweenController.Create(AncientMonkPos)
                    until CaculateDistance(monkPosition) < 15 or _G.Stop or (os.time() - flyStart > 60)
                    task.wait(1.5)
                end

                if CaculateDistance(monkPosition) <= 25 then
                    SetTask("SubTask", "Talking to Ancient Monk / Submitting Materials...")
                    -- Nộp nguyên liệu & mua võ từ Ancient Monk
                    pcall(function() Remotes.CommF_:InvokeServer("BuyGodhuman", 1) end)
                    pcall(function() Remotes.CommF_:InvokeServer("BuyGodhuman", 2) end)
                    pcall(function() Remotes.CommF_:InvokeServer("BuyGodhuman", 3) end)
                    pcall(function() Remotes.CommF_:InvokeServer("BuyGodhuman", 4) end)
                    local resCheck = Remotes.CommF_:InvokeServer("BuyGodhuman", true)
                    local resBuy = Remotes.CommF_:InvokeServer("BuyGodhuman")
                    task.wait(1)

                    -- Kiểm tra xem đã nhận được võ Godhuman chưa
                    pcall(RefreshInventory)
                    local char = game.Players.LocalPlayer.Character
                    local bp = game.Players.LocalPlayer:FindFirstChild("Backpack")
                    local hasGod = (char and char:FindFirstChild("Godhuman")) or (bp and bp:FindFirstChild("Godhuman")) or (ScriptStorage.Melees and ScriptStorage.Melees["Godhuman"])
                    if hasGod then
                        ScriptStorage.Melees["Godhuman"] = 1
                        GodHumanFlag = false
                        SetTask("MainTask", "Godhuman | Unlocked Successfully!")
                        alert("Godhuman", "Unlocked Godhuman successfully!")
                        if FunctionsHandler and FunctionsHandler.LocalPlayerController and FunctionsHandler.LocalPlayerController.Methods and FunctionsHandler.LocalPlayerController.Methods.EquipTool then
                            pcall(function() FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Godhuman") end)
                        end
                        return true
                    end

                    warn("[Ancient Monk Response]", "resBuy:", tostring(resBuy), "resCheck:", tostring(resCheck))
                    if resCheck == 1 then
                        for _, mat in ipairs(GodhumanMaterialsList or {}) do
                            AncientMonkMaterialsSubmitted[mat.Name] = true
                        end
                    end
                    AncientMonkCooldown = os.time() + 25
                    if Check then
                        return resCheck == 1
                    end
                    return resBuy
                end
                return false
            end

            -- Với Dragon Claw, cần tele tới NPC "Sabi" trước khi mua
            if M1 == "DragonClaw" then
                if Check then
                    -- Chỉ check fragments trong PlayerData, không gọi remote để tránh trừ fragments
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

                -- Sea 3: dùng tọa độ cố định cho Sabi
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

                -- Sea 2: dùng logic cũ tìm NPC trong workspace/replicated storage
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
        local Modules = ReplicatedStorage:FindFirstChild("Modules") or ReplicatedStorage:WaitForChild("Modules", 3)
        local Net = Modules and (Modules:FindFirstChild("Net") or Modules:WaitForChild("Net", 3))
        local RegisterAttack = Net and (Net:FindFirstChild("RE/RegisterAttack") or Net:WaitForChild("RE/RegisterAttack", 3))
        local RegisterHit = Net and (Net:FindFirstChild("RE/RegisterHit") or Net:WaitForChild("RE/RegisterHit", 3))
        local ShootGunEvent = Net and (Net:FindFirstChild("RE/ShootGunEvent") or Net:WaitForChild("RE/ShootGunEvent", 3))
        local GunValidator = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Validator2")
        local Register_Hit, Register_Attack = RegisterHit, RegisterAttack
        local Funcs = {}
        local lastBladeScan = 0
        local cachedBladeHits = {}
        function GetAllBladeHits()
            local now = tick()
            if now - lastBladeScan < 0.2 and #cachedBladeHits > 0 then
                return cachedBladeHits
            end
            lastBladeScan = now
            cachedBladeHits = {}
            local myChar = game.Players.LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myPos = myHrp and myHrp.Position
            if not myPos then return cachedBladeHits end

            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, v in pairs(enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        if (v.HumanoidRootPart.Position - myPos).Magnitude <= 65 then
                            table.insert(cachedBladeHits, v)
                        end
                    end
                end
            end
            return cachedBladeHits
        end
        function Getplayerhit()
            bladehits = {}
            local myChar = game.Players.LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myPos = myHrp and myHrp.Position
            if not myPos then return bladehits end

            local chars = workspace:FindFirstChild("Characters")
            if chars then
                for _, v in pairs(chars:GetChildren()) do
                    if
                        v.Name ~= game.Players.LocalPlayer.Name and v:FindFirstChild("Humanoid") and
                            v:FindFirstChild("HumanoidRootPart") and
                            v.Humanoid.Health > 0 and
                            (v.HumanoidRootPart.Position - myPos).Magnitude <= 65
                     then
                        table.insert(bladehits, v)
                    end
                end
            end
            return bladehits
        end

        pcall(function()
            if Net and Net:IsA("ModuleScript") and (not RegisterAttack or not RegisterHit) then
                local reqNet = safe_require(Net, 1)
                if reqNet and type(reqNet) == "table" and type(reqNet.RemoteEvent) == "function" then
                    if not RegisterAttack then
                        pcall(function() RegisterAttack = reqNet:RemoteEvent("RegisterAttack", true) end)
                    end
                    if not RegisterHit then
                        pcall(function() RegisterHit = reqNet:RemoteEvent("RegisterHit", true) end)
                    end
                end
            end
        end)

        function Funcs:Attack()
            pcall(function()
                local char = game:GetService("Players").LocalPlayer.Character
                if char and not char:FindFirstChild("HasBuso") then
                    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                    if remotes and remotes:FindFirstChild("CommF_") then
                        remotes.CommF_:InvokeServer("Buso")
                    end
                end
            end)

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

            pcall(function()
                if RegisterAttack then
                    RegisterAttack:FireServer(0)
                end
            end)

            local targetHead = nil
            local targetsTable = {}
            for r, v in pairs(bladehits) do
                if not targetHead and v:FindFirstChild("Head") then
                    targetHead = v.Head
                end
                if v:FindFirstChild("HumanoidRootPart") then
                    table.insert(targetsTable, {
                        [1] = v,
                        [2] = v.HumanoidRootPart
                    })
                end
            end

            if RegisterHit and targetHead and #targetsTable > 0 then
                pcall(function()
                    RegisterHit:FireServer(targetHead, targetsTable)
                end)
            end
        end

        -- Optimized FastAttack loop with Volt Actor support
        local FastAttackLoop = function()
            while task.wait(.1) do
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
            -- Use Volt Actor to run on separate thread (if available)
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

        
        -- Comprehensive Mob Spawn Coordinates Fallback (Chống kẹt/đứng im khi mob chưa render)
        local MobPositionsFallback = {
            -- Sea 1 Mobs
            ["Bandit"] = Vector3.new(1145, 17, 1634),
            ["Monkey"] = Vector3.new(-1496, 23, 137),
            ["Gorilla"] = Vector3.new(-1240, 7, -500),
            ["Gorilla King"] = Vector3.new(-1130, 15, -490),
            ["Pirate"] = Vector3.new(-1215, 5, 3915),
            ["Brute"] = Vector3.new(-1145, 15, 4350),
            ["Bobby"] = Vector3.new(-1130, 15, 4150),
            ["Desert Bandit"] = Vector3.new(930, 7, 4480),
            ["Desert Officer"] = Vector3.new(1570, 4, 4370),
            ["Snow Bandit"] = Vector3.new(1285, 106, -1440),
            ["Snowman"] = Vector3.new(1200, 106, -1500),
            ["Chief Petty Officer"] = Vector3.new(-4870, 21, 4260),
            ["Sky Bandit"] = Vector3.new(-4980, 278, -2830),
            ["Dark Master"] = Vector3.new(-5250, 388, -2250),
            ["Prisoner"] = Vector3.new(5030, 2, 475),
            ["Dangerous Prisoner"] = Vector3.new(5540, 2, 740),
            ["Toga Warrior"] = Vector3.new(-1820, 7, -2760),
            ["Gladiator"] = Vector3.new(-1390, 7, -3150),
            ["Military Soldier"] = Vector3.new(-5410, 11, 8450),
            ["Military Spy"] = Vector3.new(-5810, 77, 8820),
            ["Fishman Warrior"] = Vector3.new(60850, 19, 1500),
            ["Fishman Commando"] = Vector3.new(61800, 19, 1470),
            ["Gods Guard"] = Vector3.new(-7680, 5600, -440),
            ["Shanda"] = Vector3.new(-7685, 5545, -500),
            ["Royal Squad"] = Vector3.new(-7660, 5607, -1460),
            ["Royal Soldier"] = Vector3.new(-7800, 5607, -1790),
            ["Galley Pirate"] = Vector3.new(5590, 40, 3980),
            ["Galley Captain"] = Vector3.new(5650, 40, 4920),
            ["Mob Leader"] = Vector3.new(-2850.2, 7.4, 5350.5),
            ["Saber Expert"] = Vector3.new(-1442.2, 29.9, -8.8)
        }

CombatController = {
            GRAB = false,
            GRAB_DISTANCE = SeaIndex == 1 and 250 or 350,
            MAX_ATTACK_DURATION = 3,
            MAX_ATTACK_DURATION_2 = 60,
            LEVITATE_TIME = 1,
            CurrentIndex = 1
        }
        
        LastFound = os.time()
        -- save center pos vao attribute cua con mob r set de cho do bi move idk

        function CombatController.Grab(MobName)
            if not CombatController.GRAB then return end
            -- [v1.09] Disabled SimulationRadius to prevent crashes in Sea 3
            -- pcall(sethiddenproperty, game.Players.LocalPlayer, "SimulationRadius", 1000)
            if not CombatController.GRAB or GrabDebounce == os.time() then
            end
            GrabDebounce = os.time()

            local MidPoint, Count = Vector3.zero, 0
            ForcePosition = nil
            local MobsTable = {}

            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, Mon in pairs(enemies:GetChildren()) do
                    if Mon.Name == MobName then
                        if --not Mon:GetAttribute("IsGrabbedreci") and
                            Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and
                                Mon.Humanoid.Health > 0 then
                            local MonPosition = Mon.HumanoidRootPart.Position
                            local isOwner = true
                            if typeof(isnetworkowner) == "function" and (Mon.PrimaryPart or Mon:FindFirstChild("HumanoidRootPart")) then
                                local okOwner, resOwner = pcall(isnetworkowner, Mon.PrimaryPart or Mon.HumanoidRootPart)
                                if okOwner and resOwner ~= nil then
                                    isOwner = resOwner
                                end
                            end
                            if MonPosition and isOwner then
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
                        --[[ChildInstance.Humanoid.PlatformStand = true
                ChildInstance.Humanoid.Sit = true
                ChildInstance.HumanoidRootPart.CanCollide = false ]]
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
            MobTable = type(MobTable) == "string" and {MobTable} or (MobTable or {})
            for _, ChildInstance in ipairs(GetMonAsSortedRange()) do
                if ChildInstance and ChildInstance:IsDescendantOf(workspace) then
                    local mobName = ChildInstance.Name
                    local matches = false
                    for _, targetName in ipairs(MobTable) do
                        if mobName == targetName or string.find(mobName, targetName) then
                            matches = true
                            break
                        end
                    end
                    if matches and ChildInstance:FindFirstChild("Humanoid") and ChildInstance.Humanoid.Health > 0 and ChildInstance:FindFirstChild("HumanoidRootPart") then
                        if (ChildInstance:GetAttribute("FailureCount") or 0) < 3 then
                            Found = true
                            table.insert(Lists, ChildInstance)
                        end
                    end
                end
            end

            table.sort(
                Lists,
                function(a, b)
                    return Sort1(a) < Sort1(b)
                end
            )

            if Found and #Lists > 0 then
                return Lists[1]
            end

            return nil
        end

        function CombatController.Attack(MobTable, NearbyHit, Range, Callback)
            -- Cache GuideModule env để tránh gọi getsenv nhiều lần
            local GuideEnv = pcall(function()
                return GetGuideEnv()
            end) and GetGuideEnv()

            if ScriptStorage.Tools["Sweet Chalice"] and GuideEnv and GuideEnv["_G"]["InCombat"] then
                TweenController.Create(Vector3.new(0, 0, 0))
                return
            end

            pcall(function()
                if typeof(sethiddenproperty) == "function" then
                    sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                end
            end)
            MobTable = type(MobTable) == "string" and {MobTable} or (MobTable or {})

            for _, Child in ipairs(MobTable) do
                local ChildName = tostring(Child)
                if
                    (ChildName == "Deandre" or ChildName == "Urban" or ChildName == "Diablo") and
                    (os.time() - (LastFire12 or 0)) > 180
                then
                    LastFire12 = os.time()
                    Remotes.CommF_:InvokeServer("EliteHunter")
                end
            end

            local MonResult = nil
            if NearbyHit then
                local sorted = GetMonAsSortedRange()
                local Mon = sorted[1]
                local MonPosition = Mon and Mon:FindFirstChild("HumanoidRootPart") and Mon.HumanoidRootPart.Position
                if MonPosition and CaculateDistance(MonPosition) < (Range or 100) then
                    MonResult = Mon
                end
            else
                MonResult = CombatController.Search(MobTable)
            end

            if MonResult and MonResult:IsDescendantOf(workspace) then
                LastFound = os.time()
                local Count, Debounce = 0, os.time()
                local Count2 = 0
                while task.wait(0.1) do
                    if _G.Stop then
                        return
                    end

                    if not MonResult or not MonResult:IsDescendantOf(workspace) then
                        break
                    end

                    -- Cache lại InCombat mỗi lần loop để kiểm tra trạng thái combat
                    if ScriptStorage.Tools["Sweet Chalice"] and GuideEnv and GuideEnv["_G"]["InCombat"] then
                        TweenController.Create(Vector3.new(0, 0, 0))
                        return
                    end

                    local MobHumanoid = MonResult:FindFirstChild("Humanoid")
                    local MobHumanoidRootPart = MonResult:FindFirstChild("HumanoidRootPart")

                    if not MobHumanoid or MobHumanoid.Health <= 0 or not MobHumanoidRootPart then
                        if MonResult.Name == "Don Swan" then
                            Storage:Set("SwanDefeated", true)
                        end
                        break
                    end

                    local targetAttackPos = CaculateCircreDirection(MobHumanoidRootPart.CFrame).Position + Vector3.new(0, 20, 0)
                    local myChar = LocalPlayer.Character
                    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local distToMob = myHrp and (myHrp.Position - targetAttackPos).Magnitude or 999

                    if distToMob <= 25 then
                        if myHrp then
                            -- Giữ nguyên vị trí hoặc lerp mượt mà tránh giạt hình
                            myHrp.CFrame = myHrp.CFrame:Lerp(CFrame.new(targetAttackPos), 0.3)
                        end
                    else
                        TweenController.Create(targetAttackPos)
                    end

                    if CaculateDistance(MobHumanoidRootPart.Position + Vector3.new(0, 20, 0)) < 150 then
                        CombatController.Grab(MonResult.Name or "")
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
                                SafeRejoinOrHop("Rejoin")
                                return
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
                                    if MonResult:FindFirstChild("HumanoidRootPart") then
                                        MonResult.HumanoidRootPart.CFrame = (CFrame.new(OldPosition))
                                    end
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
                if (os.time() - LastFound) > 600 then
                    alert("KUN", "Error while farming, rejoin")
                    SafeRejoinOrHop("Rejoin")
                    return
                end

                for _, Child in ipairs(MobTable) do
                    local Region = ScriptStorage.MobRegions[Child]

                    if not Region or (type(Region) == "table" and #Region == 0) then
                        local Inst = workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild(Child)
                        Region = Inst and Inst.PrimaryPart and {Inst.PrimaryPart.Position}
                    end

                    if (not Region or (type(Region) == "table" and #Region == 0)) and MobPositionsFallback and MobPositionsFallback[Child] then
                        Region = {MobPositionsFallback[Child]}
                    end

                    if not Region or (type(Region) == "table" and #Region == 0) then
                        -- [PERF] Quet TOAN cay workspace rat lag tren dien thoai, va cho nay chay
                        -- moi khi khong thay quai gan day -> cache ket qua 5 phut / ten quai
                        MobRegionScanCache = MobRegionScanCache or {}
                        local scanCache = MobRegionScanCache[Child]
                        if scanCache and tick() < scanCache.Until then
                            if scanCache.Pos then
                                Region = {scanCache.Pos}
                            end
                        else
                            local foundPos = nil
                            pcall(function()
                                for _, spawnObj in pairs(workspace:GetDescendants()) do
                                    if spawnObj:IsA("BasePart") and (spawnObj.Name == Child or string.find(spawnObj.Name, Child)) then
                                        foundPos = spawnObj.Position
                                        break
                                    end
                                end
                            end)
                            MobRegionScanCache[Child] = {Pos = foundPos, Until = tick() + 300}
                            if foundPos then
                                Region = {foundPos}
                            end
                        end
                    end

                    if Region and #Region > 0 then
                        if not Region[CombatController.CurrentIndex] then
                            CombatController.CurrentIndex = 1
                        end

                        local CurrentPosition = Region[CombatController.CurrentIndex]
                        if typeof(CurrentPosition) == "CFrame" then
                            CurrentPosition = CurrentPosition.Position
                        end

                        if CurrentPosition then
                            SetTask("SubTask", "Flying to " .. tostring(Child) .. " Spawn Area")
                            TweenController.Create(CurrentPosition + Vector3.new(0, 20, 0))
                            return
                        end
                    end
                end
            end
        end

        LevelFarmTTL = 0
        LastTravel = os.time()

        
local function GetGuideEnv()
    local ok, env = pcall(function()
        if type(getsenv) == "function" then
            local lp = game:GetService("Players").LocalPlayer
            local clientGuide = lp and lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("Guide")
            if clientGuide then
                return getsenv(clientGuide)
            end
        end
    end)
    return ok and env or nil
end

local function GetExpBoost()
    local env = GetGuideEnv()
    if env and env._G and env._G.ServerData and env._G.ServerData.ExpBoost then
        return env._G.ServerData.ExpBoost
    end
    return 0
end


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

                                function Result.SaveConstant(Self, Key, Value)
                                    if Self and Self.Constants and Key and Self.Constants[Key] then
                                        return assert(false, "constant name was used before!")
                                    end
                                    if Self and Self.Constants and Key then
                                        rawset(Self.Constants, Key, Value)
                                    end
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
            return QuestManager.GetCurrentClaimQuest(RawResponse)
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
                --Report("Typeof: " .. typeof(Storage))

                return ScriptStorage.PlayerData.Level < MaxLevel and
                    GetExpBoost() == 0 and
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
                    if GetExpBoost() == 0 then
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
                -- [SEA 1 ONLY] Không farm nếu không ở Sea 1
                if SeaIndex ~= 1 then
                    return
                end
                -- Don't run LevelFarm if currently in raid process
                if FunctionsHandler.RaidController:Get("IsInRaidProcess") then
                    return
                end
                
                return 4
            end
        )

        FunctionsHandler.LevelFarm:RegisterMethod(
            "Start",
            function(Level)
                -- [SEA 1 ONLY] Script này chỉ farm ở Sea 1, không bao giờ tự chuyển Sea
                if SeaIndex ~= 1 then
                    SetTask("MainTask", "SEA 1 ONLY | Dang o Sea " .. tostring(SeaIndex) .. " | Hay quay lai Sea 1 de farm!")
                    return
                end
                -- if SeaIndex == 1 then
                --     if getrenv()._G.ServerData.ExpBoost - (tick() - getrenv()._G.ServerData.ExpBoostTick) < 60*60 then 
                --         local args = {
                --             [1] = "Purchase",
                --             [2] = "15minDouble"
                --         }
                        
                --         game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Celebration"):InvokeServer(unpack(args))
                --     end
                -- else 
                --     if getrenv()._G.ServerData.ExpBoost - (tick() - getrenv()._G.ServerData.ExpBoostTick) < 0 then 
                --         local args = {
                --             [1] = "Purchase",
                --             [2] = "15minDouble"
                --         }
                        
                --         game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Celebration"):InvokeServer(unpack(args))
                --     end
                -- end
                    
                local PlayerLevel = tonumber(ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or 1

                pcall(RefreshInventory)

                -- [SEA 1 ONLY] Đã bỏ logic chuyển Sea 2/3, Godhuman và Cake/Fragments farm
                -- Nếu đang làm nhiệm vụ Saber (hoặc đủ điều kiện làm Saber tại Sea 1): Nhường hoàn toàn cho Saber!
                local isSaberOngoing = (type(IsSaberQuestActive) == "function" and IsSaberQuestActive()) or (CurrentTask == "Saber")
                if isSaberOngoing then
                    return
                end

                -- Nếu đang bật AutoFullyMelees và võ hiện tại đã đạt đủ Mastery:
                if Config.Items.AutoFullyMelees and type(GetCurrentMeleeMastery) == "function" then
                    local curMelee, curMastery, reqMastery = GetCurrentMeleeMastery()
                    if curMelee and curMastery and curMastery >= reqMastery then
                        -- Kiểm tra xem còn võ nào khác cần cày hoặc mua không
                        local hasOtherMelee = false
                        for _, mName in ipairs(MeleesTable or {}) do
                            if mName ~= "SanguineArt" and mName ~= curMelee then
                                local mData = MeleePrices and MeleePrices[mName]
                                local mReq = (mData and mData.NextLevelRequirement) or 400
                                local knownMastery = (type(GetPlayerMeleeMastery) == "function" and GetPlayerMeleeMastery(mName)) or (ScriptStorage.Melees and ScriptStorage.Melees[mName]) or 0
                                if knownMastery < mReq then
                                    hasOtherMelee = true
                                    break
                                end
                            end
                        end
                        if hasOtherMelee and ScriptStorage.IsGettingMelee then
                            -- Nhường lượt cho MeleesController khi đang đổi võ
                            return
                        end
                    end
                end

                -- LEVEL 1 ĐẾN 150 (SEA 1): Fast Farm trên Đảo Trời để lên cấp cực nhanh
                if SeaIndex == 1 and PlayerLevel < 150 then
                    SetTask("MainTask", "Fast Farming (Lv " .. tostring(PlayerLevel) .. "/150) | Sky Island")
                    local skyEntrance = Vector3.new(-4607.82275390625, 872.5422973632812, -1667.556884765625)
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp and myHrp.Position.Y < 300 then
                        pcall(function()
                            Remotes.CommF_:InvokeServer("requestEntrance", skyEntrance)
                        end)
                        task.wait(0.5)
                    end
                    CombatController.Attack({"Shanda", "Gods Guard", "Sky Bandit"})
                    return
                end

                -- TỪ LEVEL 150 TRỞ ĐI: TỰ ĐỘNG NHẬN NHIỆM VỤ THEO CẤP ĐỘ
                QuestManager:RefreshQuest()
                local MonName, NpcPosition, QuestId, QuestIndex, QuestTitle = QuestManager:GetCurrentQuest()
                if not MonName or not QuestId then
                    QuestManager:RefreshQuest()
                    MonName, NpcPosition, QuestId, QuestIndex, QuestTitle = QuestManager:GetCurrentQuest()
                end

                if not NpcPosition and QuestId and BuiltInNpcPositions[QuestId] then
                    NpcPosition = BuiltInNpcPositions[QuestId]
                end

                -- 1. Kiểm tra xem hiện tại đã có nhiệm vụ đang chạy hay chưa
                local hasActiveQuest, curKills, maxKills, activeTitle = QuestManager.HasActiveQuest()

                -- Chỉ khi CHƯA có nhiệm vụ (hoàn toàn không có Quest UI active) thì mới bay về NPC để nhận nhiệm vụ mới
                if not hasActiveQuest then
                    -- Quét trực tiếp NPC model tại thời điểm hiện tại để luôn bay tới ngay trước mặt ông NPC
                    local liveNpcVec = QuestManager:FindLiveNpc(QuestId, MonName)
                    if liveNpcVec then
                        NpcPosition = liveNpcVec
                    end

                    if not NpcPosition then
                        if MonName then
                            CombatController.Attack(MonName)
                        end
                        return
                    end
                    local targetNpcVec = (typeof(NpcPosition) == "CFrame" and NpcPosition.Position) or (typeof(NpcPosition) == "Vector3" and NpcPosition) or Vector3.new(0, 0, 0)
                    
                    -- Tự động đi cổng lên Đảo Trời (Sky 2) hoặc Đảo Người Cá (Fishman) trong Sea 1
                    if SeaIndex == 1 then
                        local myChar = LocalPlayer.Character
                        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        local myPos = myHrp and myHrp.Position
                        if myPos then
                            if targetNpcVec.Y > 4000 and myPos.Y < 2000 then
                                pcall(function()
                                    Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.62, 5545.49, -380.25))
                                end)
                                task.wait(0.5)
                            elseif targetNpcVec.X > 50000 and myPos.X < 20000 then
                                pcall(function()
                                    Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.85, 11.76, 1819.78))
                                end)
                                task.wait(0.5)
                            end
                        end
                    end

                    SetTask("MainTask", "Level Farming | " .. tostring(MonName or "Enemy") .. " | Claiming Quest (Instant at Mob Area)")
                    LevelFarmTTL = 0
                    if QuestId and QuestIndex then
                        -- Tự động tính toán khoảng cách để đặt thời gian ân hạn
                        local mobPos = nil
                        pcall(function()
                            if MonName and ScriptStorage.MobRegions and ScriptStorage.MobRegions[MonName] and #ScriptStorage.MobRegions[MonName] > 0 then
                                local r = ScriptStorage.MobRegions[MonName][1]
                                mobPos = (typeof(r) == "CFrame" and r.Position) or (typeof(r) == "Vector3" and r)
                            elseif MonName and MobPositionsFallback and MobPositionsFallback[MonName] then
                                local r = MobPositionsFallback[MonName]
                                mobPos = (typeof(r) == "CFrame" and r.Position) or (typeof(r) == "Vector3" and r)
                            end
                        end)

                        local distToMob = (mobPos and targetNpcVec and (mobPos - targetNpcVec).Magnitude) or 0
                        local estimatedTravelTime = math.clamp(distToMob / 160, 0, 30)
                        local baseGrace = (Config and Config.Settings and tonumber(Config.Settings.QuestGracePeriod)) or 8
                        getgenv().DynamicQuestGracePeriod = baseGrace + estimatedTravelTime

                        getgenv().LastQuestClaimTick = tick()
                        QuestManager.StartQuest(QuestId, QuestIndex)
                        local startTimeout = (Config and Config.Settings and tonumber(Config.Settings.QuestStartTimeout)) or 2.0
                        local waitQuest = tick() + startTimeout
                        repeat
                            task.wait(0.1)
                            hasActiveQuest = QuestManager.HasActiveQuest()
                        until hasActiveQuest or tick() > waitQuest
                    end
                end

                -- 2. Đánh quái cho đến khi hoàn thành 100% nhiệm vụ (tuyệt đối không bay về giữa chừng)
                if MonName then
                    SetTask("MainTask", "Level Farming | " .. MonName .. " | Defeating Enemies")
                    local farmMobStart = os.time()
                    local hasArrivedAtMob = false
                    local arriveTime = nil
                    local noQuestGoneSince = nil
                    local lastCurKills = nil
                    local lastTotalKills = nil

                    -- Tìm tọa độ mục tiêu quái để kiểm tra xem nhân vật đã tiếp cận bãi quái chưa
                    local targetMobPos = nil
                    pcall(function()
                        if ScriptStorage.MobRegions and ScriptStorage.MobRegions[MonName] and #ScriptStorage.MobRegions[MonName] > 0 then
                            local r = ScriptStorage.MobRegions[MonName][1]
                            targetMobPos = (typeof(r) == "CFrame" and r.Position) or (typeof(r) == "Vector3" and r)
                        elseif MobPositionsFallback and MobPositionsFallback[MonName] then
                            local r = MobPositionsFallback[MonName]
                            targetMobPos = (typeof(r) == "CFrame" and r.Position) or (typeof(r) == "Vector3" and r)
                        end
                    end)

                    while task.wait(0.05) do
                        if _G.Stop then break end

                        -- KIỂM TRA ĐÃ TIẾP CẬN BÃI QUÁI HAY CHƯA (Tránh nhận nhầm quest khi đang bay đường dài)
                        if not hasArrivedAtMob then
                            local isNear = false
                            if targetMobPos and CaculateDistance(targetMobPos) <= 350 then
                                isNear = true
                            else
                                local enemies = workspace:FindFirstChild("Enemies")
                                if enemies then
                                    for _, enemy in ipairs(enemies:GetChildren()) do
                                        if enemy.Name == MonName and enemy:FindFirstChild("HumanoidRootPart") then
                                            if CaculateDistance(enemy.HumanoidRootPart.Position) <= 350 then
                                                isNear = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end

                            -- Nếu đã đến gần quái hoặc đã bay quá 15s thì kích hoạt trạng thái đã đến bãi quái
                            if isNear or (os.time() - farmMobStart >= 15) then
                                hasArrivedAtMob = true
                                arriveTime = os.time()
                            end
                        end

                        -- KIỂM TRA MASTERY VÕ: Nếu AutoFullyMelees bật và võ hiện tại đã đủ Mastery (>= 400 hoặc req)
                        -- Dừng farm ngay lập tức, hủy quest và thoát khỏi loop farm để đổi/nhận võ mới không tốn thời gian!
                        -- Không áp dụng nếu đang làm nhiệm vụ Saber
                        if not isSaberOngoing and Config.Items.AutoFullyMelees and type(GetCurrentMeleeMastery) == "function" then
                            local curMelee, curMastery, reqMastery = GetCurrentMeleeMastery()
                            if curMelee and curMastery and curMastery >= reqMastery then
                                print("[Mastery Complete] Võ " .. tostring(curMelee) .. " đã đủ Mastery (" .. tostring(curMastery) .. "/" .. tostring(reqMastery) .. ") -> Dừng farm ngay để nhận võ tiếp theo!")
                                pcall(function() QuestManager.AbandonQuest() end)
                                task.wait(0.2)
                                break
                            end
                        end

                        -- KIỂM TRA TIẾN ĐỘ NHIỆM VỤ:
                        local isQuestActive, currentKills, totalKills = QuestManager.HasActiveQuest()

                        if isQuestActive then
                            noQuestGoneSince = nil -- Quest vẫn đang hoạt động, reset bộ đếm thời gian
                            if currentKills and totalKills and totalKills > 0 then
                                lastCurKills = currentKills
                                lastTotalKills = totalKills
                                -- Nếu đã đủ 100% số lượng quái yêu cầu (vd: 8/8) -> Hoàn thành nhiệm vụ!
                                if currentKills >= totalKills then
                                    getgenv().LastQuestClaimTick = nil
                                    getgenv().DynamicQuestGracePeriod = nil
                                    task.wait(0.1)
                                    break
                                end
                            end
                        else
                            -- Quest UI biến mất:
                            -- CHỈ xét hoàn thành khi NHÂN VẬT ĐÃ ĐẾN BÃI QUÁI (hasArrivedAtMob) và UI biến mất liên tục trong QuestGoneDelay
                            if not hasArrivedAtMob then
                                noQuestGoneSince = nil -- Đang trên đường bay tới bãi quái xa, không xác nhận mất quest!
                            elseif lastCurKills and lastTotalKills and lastCurKills < lastTotalKills then
                                -- Dù quái ít hay nhiều, nếu chưa đạt đủ số lượng yêu cầu (vd: 3/8) mà UI tạm ẩn, KHÔNG ĐƯỢC PHÉP hoàn thành sớm!
                                noQuestGoneSince = nil
                            else
                                local questGoneDelay = (Config and Config.Settings and tonumber(Config.Settings.QuestGoneDelay)) or 1.0
                                local minFarmDuration = (Config and Config.Settings and tonumber(Config.Settings.MinFarmDuration)) or 2.0
                                local farmingElapsed = os.time() - (arriveTime or farmMobStart)

                                if lastCurKills and lastTotalKills and lastCurKills < lastTotalKills then
                                    noQuestGoneSince = nil
                                else
                                    if not noQuestGoneSince then
                                        noQuestGoneSince = os.clock()
                                    elseif (os.clock() - noQuestGoneSince >= questGoneDelay) and (farmingElapsed >= minFarmDuration) then
                                        getgenv().LastQuestClaimTick = nil
                                        getgenv().DynamicQuestGracePeriod = nil
                                        break -- Thực sự đã hoàn thành nhiệm vụ!
                                    end
                                end
                            end
                        end

                        local AttackTime1 = os.time()
                        CombatController.Attack(MonName)
                        LevelFarmTTL = (LevelFarmTTL or 0) + os.time() - AttackTime1

                        -- Giới hạn an toàn tránh kẹt
                        if os.time() - farmMobStart > 300 then
                            break
                        end
                    end
                end
            end
        )
        -- LP Controller

        FunctionsHandler.LocalPlayerController:RegisterMethod(
            "EquipTool",
            function(Tool)
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return end

                    -- Check if already equipped
                    local currentTool = char:FindFirstChildOfClass("Tool")
                    if currentTool then
                        if Tool == "Melee" and (currentTool.ToolTip == "Melee" or table.find({"Electro", "Electric", "Godhuman", "Superhuman", "Dark Step", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon", "Sanguine Art", "Black Leg", "Fishman Karate", "Dragon Claw"}, currentTool.Name)) then
                            return
                        elseif Tool == "Sword" and (currentTool.ToolTip == "Sword" or currentTool:GetAttribute("IsSword")) then
                            return
                        elseif currentTool.Name == tostring(Tool) or currentTool.ToolTip == tostring(Tool) then
                            return
                        end
                    end

                    -- Search in Backpack
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    if backpack then
                        for _, Item in pairs(backpack:GetChildren()) do
                            if Item:IsA("Tool") then
                                local match = false
                                if Tool == "Melee" then
                                    if Item.ToolTip == "Melee" or table.find({"Electro", "Electric", "Godhuman", "Superhuman", "Dark Step", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon", "Sanguine Art", "Black Leg", "Fishman Karate", "Dragon Claw"}, Item.Name) then
                                        match = true
                                    end
                                elseif Tool == "Sword" then
                                    if Item.ToolTip == "Sword" or Item:GetAttribute("IsSword") then
                                        match = true
                                    end
                                else
                                    if Item.Name == tostring(Tool) or Item.ToolTip == tostring(Tool) then
                                        match = true
                                    end
                                end

                                if match then
                                    hum:EquipTool(Item)
                                    task.wait(0.05)
                                    return
                                end
                            end
                        end
                    end
                end)
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

        FunctionsHandler.Saber:RegisterMethod(
            "Refresh",
            function()
                if not (Config and Config.Items and Config.Items.Saber) then
                    return
                end
                if SeaIndex ~= 1 then
                    return
                end

                local lp = game:GetService("Players").LocalPlayer
                if HasSaberItem() then
                    return
                end

                local level = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level)
                    or (lp and lp:FindFirstChild("Data") and lp.Data:FindFirstChild("Level") and lp.Data.Level.Value)
                    or 0
                if level < 200 then
                    return
                end

                local Result = 1
                local Tasks = nil
                pcall(function()
                    Tasks = Remotes.CommF_:InvokeServer("ProQuestProgress")
                end)
                if type(Tasks) == "table" then
                    local platesDone = true
                    if type(Tasks.Plates) == "table" then
                        for _, Value in pairs(Tasks.Plates) do
                            if Value == false then
                                platesDone = false
                                Result = 1
                                break
                            end
                        end
                    end

                    if platesDone then
                        if not Tasks.UsedTorch then
                            Result = 2
                        elseif not Tasks.UsedCup then
                            Result = 3
                        elseif not Tasks.TalkedSon then
                            Result = 4
                        elseif not Tasks.KilledMob then
                            Result = 5
                        elseif not Tasks.UsedRelic then
                            Result = 6
                        elseif not Tasks.KilledShanks then
                            Result = 7
                        end
                    end
                else
                    Result = FunctionsHandler.Saber:Get("CurrentProgressLevel") or 1
                end

                FunctionsHandler.Saber:Set("CurrentProgressLevel", Result)
                FunctionsHandler.Saber:Set("LastestRefreshSenque", os.time())

                return Result
            end
        )

        FunctionsHandler.Saber:RegisterMethod(
            "GetQuestplates",
            function()
                local CachedData = FunctionsHandler.Saber:Get("QuestplatesCache")
                if CachedData and #CachedData > 0 then
                    return CachedData
                end

                local JungleCenter = Vector3.new(-1600, 37, 153)
                if CaculateDistance(JungleCenter) > 200 then
                    SetTask("MainTask", "Saber Quest | Traveling to Jungle Island...")
                    local t0 = os.time()
                    repeat
                        task.wait(0.2)
                        TweenController.Create(JungleCenter)
                    until CaculateDistance(JungleCenter) < 150 or (os.time() - t0 > 25)
                    task.wait(1)
                end

                local Jungle = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jungle")
                local Result = {}

                if Jungle and Jungle:FindFirstChild("QuestPlates") then
                    for _, Inst in ipairs(Jungle.QuestPlates:GetChildren()) do
                        local btn = Inst:FindFirstChild("Button") or Inst
                        if btn then
                            table.insert(Result, btn)
                        end
                    end
                end

                if #Result == 0 then
                    -- Fallback: scan workspace near Jungle
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (string.find(obj.Name, "Plate") or string.find(obj.Name, "Button")) then
                            if (obj.Position - JungleCenter).Magnitude < 400 then
                                table.insert(Result, obj)
                            end
                        end
                    end
                end

                if #Result == 0 then
                    -- Hardcoded fallback CFrames for the 5 Jungle plates
                    Result = {
                        CFrame.new(-1605.5, 11.8, 156.2),
                        CFrame.new(-1490.2, 11.8, 120.5),
                        CFrame.new(-1615.1, 12.0, 75.4),
                        CFrame.new(-1240.2, 7.2, -490.1),
                        CFrame.new(-1150.5, 6.8, -520.3)
                    }
                end

                FunctionsHandler.Saber:Set("QuestplatesCache", Result)
                return Result
            end
        )

        FunctionsHandler.Saber:RegisterMethod(
            "Start",
            function()
                local Progress = FunctionsHandler.Saber:Get("CurrentProgressLevel")
                local LastestRefreshSenque = FunctionsHandler.Saber:Get("LastestRefreshSenque") or 0

                print("[ Debug ] Saber quest indexes", Progress)
                if not Progress or (os.time() - LastestRefreshSenque > 30) then
                    Progress = FunctionsHandler.Saber.Methods.Refresh:Call()
                end

                if not Progress or Progress == 0 then
                    return
                end

                if Progress == 1 then
                    local Questplates = FunctionsHandler.Saber.Methods.GetQuestplates:Call()

                    for Index, Questplate in ipairs(Questplates) do
                        SetTask("MainTask", "Saber Quest | Quest Plates | Touching " .. Index .. "/5")
                        local targetPos = (typeof(Questplate) == "CFrame" and Questplate) or (Questplate:IsA("BasePart") and Questplate.CFrame) or (Questplate:FindFirstChild("Button") and Questplate.Button.CFrame) or (Questplate.PrimaryPart and Questplate.PrimaryPart.CFrame)
                        if targetPos then
                            local LoopStartTime = os.time()
                            local MaxLoopDuration = 20
                            while CaculateDistance(targetPos.Position) > 3 do
                                if os.time() - LoopStartTime > MaxLoopDuration then
                                    break
                                end
                                task.wait(0.2)
                                TweenController.Create(targetPos)
                            end
                            pcall(function()
                                local part = (typeof(Questplate) == "Instance" and (Questplate:FindFirstChild("Button") or Questplate)) or nil
                                if part and part:IsA("BasePart") and firetouchinterest then
                                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, part, 0)
                                    task.wait(0.05)
                                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, part, 1)
                                end
                            end)
                            task.wait(0.5)
                        end
                    end
                    pcall(function() FunctionsHandler.Saber.Methods.Refresh:Call() end)
                elseif Progress == 2 then
                    SetTask("MainTask", "Saber Quest | Torch Puzzle | Using Torch")
                    -- Lấy đuốc tại hầm Jungle
                    local torchHole = CFrame.new(-1610.9, 12.3, 163.5)
                    if CaculateDistance(torchHole.Position) > 10 then
                        local t0 = os.time()
                        repeat
                            task.wait(0.2)
                            TweenController.Create(torchHole)
                        until CaculateDistance(torchHole.Position) < 10 or (os.time() - t0 > 25)
                        task.wait(0.5)
                    end
                    pcall(function() Remotes.CommF_:InvokeServer("ProQuestProgress", "GetTorch") end)
                    task.wait(1)

                    -- Đến sa mạc đốt cửa nhà
                    local desertHouse = CFrame.new(1113.8, 5.4, 4350.5)
                    if CaculateDistance(desertHouse.Position) > 10 then
                        local t0 = os.time()
                        repeat
                            task.wait(0.2)
                            TweenController.Create(desertHouse)
                        until CaculateDistance(desertHouse.Position) < 10 or (os.time() - t0 > 35)
                        task.wait(0.5)
                    end
                    pcall(function() Remotes.CommF_:InvokeServer("ProQuestProgress", "DestroyTorch") end)
                    task.wait(1)
                    pcall(function() FunctionsHandler.Saber.Methods.Refresh:Call() end)
                elseif Progress == 3 then
                    SetTask("MainTask", "Saber Quest | Sick Man | Helping with Cup")
                    pcall(function() Remotes.CommF_:InvokeServer("ProQuestProgress", "GetCup") end)
                    task.wait(1)

                    local cupTool = (ScriptStorage.Tools and ScriptStorage.Tools.Cup) or (game.Players.LocalPlayer:FindFirstChild("Backpack") and game.Players.LocalPlayer.Backpack:FindFirstChild("Cup"))
                    if cupTool then
                        pcall(function() FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Cup") end)
                        task.wait(0.5)
                        local iceCave = CFrame.new(1398.2, 37.4, -1320.1)
                        if CaculateDistance(iceCave.Position) > 10 then
                            local t0 = os.time()
                            repeat
                                task.wait(0.2)
                                TweenController.Create(iceCave)
                            until CaculateDistance(iceCave.Position) < 10 or (os.time() - t0 > 30)
                            task.wait(0.5)
                        end
                        local char = game.Players.LocalPlayer.Character
                        local cup = (char and char:FindFirstChild("Cup")) or cupTool
                        pcall(function() Remotes.CommF_:InvokeServer("ProQuestProgress", "FillCup", cup) end)
                        task.wait(1)
                    end

                    local sickManPos = CFrame.new(1392.8, 37.4, -1300)
                    if CaculateDistance(sickManPos.Position) > 15 then
                        TweenController.Create(sickManPos)
                        task.wait(1)
                    end
                    pcall(function() Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan") end)
                    task.wait(1)
                    pcall(function() FunctionsHandler.Saber.Methods.Refresh:Call() end)
                elseif Progress == 4 then
                    SetTask("MainTask", "Saber Quest | Rich Son | Getting Information")
                    local richSonPos = CFrame.new(-1399.7, 30.2, 400.1)
                    if CaculateDistance(richSonPos.Position) > 15 then
                        TweenController.Create(richSonPos)
                        task.wait(1)
                    end
                    pcall(function() Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon") end)
                    task.wait(1)
                    pcall(function() FunctionsHandler.Saber.Methods.Refresh:Call() end)
                elseif Progress == 5 then
                    SetTask("MainTask", "Saber Quest | Mob Leader | Defeating Boss")
                    local mobLeaderPos = CFrame.new(-2850.2, 7.4, 5350.5)
                    local mob = ScriptStorage.Enemies["Mob Leader"] or (workspace.Enemies and workspace.Enemies:FindFirstChild("Mob Leader"))
                    if not mob and CaculateDistance(mobLeaderPos.Position) > 40 then
                        TweenController.Create(mobLeaderPos)
                    else
                        CombatController.Attack("Mob Leader")
                    end
                elseif Progress == 6 then
                    SetTask("MainTask", "Saber Quest | Relic | Placing at Location")
                    local richSonPos = CFrame.new(-1399.7, 30.2, 400.1)
                    if CaculateDistance(richSonPos.Position) > 15 then
                        TweenController.Create(richSonPos)
                        task.wait(1)
                    end
                    pcall(function() Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon") end)
                    task.wait(1)

                    local RelicDoor = CFrame.new(-1406.87, 29.85, 3.84)
                    if CaculateDistance(RelicDoor.Position) > 8 then
                        local t0 = os.time()
                        repeat
                            task.wait(0.2)
                            TweenController.Create(RelicDoor)
                        until CaculateDistance(RelicDoor.Position) < 8 or (os.time() - t0 > 30)
                        task.wait(0.5)
                    end
                    local relicTool = (ScriptStorage.Tools and ScriptStorage.Tools.Relic) or (game.Players.LocalPlayer:FindFirstChild("Backpack") and game.Players.LocalPlayer.Backpack:FindFirstChild("Relic"))
                    if relicTool then
                        pcall(function() FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Relic") end)
                        task.wait(0.5)
                    end
                    pcall(function() Remotes.CommF_:InvokeServer("ProQuestProgress", "PlaceRelic") end)
                    task.wait(1)
                    pcall(function() FunctionsHandler.Saber.Methods.Refresh:Call() end)
                elseif Progress == 7 then
                    SetTask("MainTask", "Saber Quest | Saber Expert | Final Battle")
                    local saberExpert = ScriptStorage.Enemies["Saber Expert"]
                    if saberExpert and saberExpert:FindFirstChild("HumanoidRootPart") and saberExpert:FindFirstChild("Humanoid") and saberExpert.Humanoid.Health > 0 then
                        CombatController.Attack("Saber Expert")
                    else
                        local shanksRoom = CFrame.new(-1442.16, 29.87, -8.76)
                        if CaculateDistance(shanksRoom.Position) > 15 then
                            TweenController.Create(shanksRoom)
                        end
                        SetTask("SubTask", "Waiting for Saber Expert to spawn...")
                        task.wait(1)
                    end
                end
            end
        )

        pcall(function()
            if Remotes and Remotes.RefreshQuestPro and Remotes.RefreshQuestPro.OnClientEvent then
                Remotes.RefreshQuestPro.OnClientEvent:Connect(function(...)
                    local questArgs = {...}
                    if FunctionsHandler and FunctionsHandler.Saber and FunctionsHandler.Saber.Methods and FunctionsHandler.Saber.Methods.Refresh then
                        pcall(function() FunctionsHandler.Saber.Methods.Refresh.Callback(unpack(questArgs)) end)
                    end
                end)
            end
        end)

        -- Aim Position Handler (Safe, non-hooking)
        function LockAimPositionTo(LockedPosition)
            getgenv().LastestLockDate = os.time()
            getgenv().LockPosition = LockedPosition
        end

        MeleeLastCursor = 1
        FirstCall = true
        CanPurchase = {}
        FruitDataCache = {}

        local MeleeCanonicalNames = {
            ["Dark Step"] = "Black Leg",
            ["Black Leg"] = "Black Leg",
            ["BlackLeg"] = "Black Leg",
            ["Electro"] = "Electro",
            ["Electric"] = "Electro",
            ["Water Kung-fu"] = "Fishman Karate",
            ["Water Kung Fu"] = "Fishman Karate",
            ["Fishman Karate"] = "Fishman Karate",
            ["FishmanKarate"] = "Fishman Karate",
            ["Dragon Claw"] = "Dragon Claw",
            ["DragonClaw"] = "Dragon Claw",
            ["Superhuman"] = "Superhuman",
            ["Death Step"] = "Death Step",
            ["DeathStep"] = "Death Step",
            ["Sharkman Karate"] = "Sharkman Karate",
            ["SharkmanKarate"] = "Sharkman Karate",
            ["Electric Claw"] = "Electric Claw",
            ["ElectricClaw"] = "Electric Claw",
            ["Dragon Talon"] = "Dragon Talon",
            ["DragonTalon"] = "Dragon Talon",
            ["Godhuman"] = "Godhuman",
            ["Sanguine Art"] = "SanguineArt",
            ["SanguineArt"] = "SanguineArt"
        }

        local MeleeToolAliases = {
            ["Black Leg"] = {"Dark Step", "Black Leg", "BlackLeg"},
            ["Electro"] = {"Electro", "Electric"},
            ["Fishman Karate"] = {"Water Kung-fu", "Water Kung Fu", "Fishman Karate", "FishmanKarate"},
            ["Dragon Claw"] = {"Dragon Claw", "DragonClaw"},
            ["Superhuman"] = {"Superhuman"},
            ["Death Step"] = {"Death Step", "DeathStep"},
            ["Sharkman Karate"] = {"Sharkman Karate", "SharkmanKarate"},
            ["Electric Claw"] = {"Electric Claw", "ElectricClaw"},
            ["Dragon Talon"] = {"Dragon Talon", "DragonTalon"},
            ["Godhuman"] = {"Godhuman"},
            ["SanguineArt"] = {"Sanguine Art", "SanguineArt"}
        }

        function ToCanonicalMeleeName(name)
            if not name then return nil end
            return MeleeCanonicalNames[name] or name
        end

        function GetPlayerMeleeTool(meleeName)
            local canon = ToCanonicalMeleeName(meleeName)
            local aliases = MeleeToolAliases[canon] or {meleeName}
            local char = game.Players.LocalPlayer.Character
            local bp = game.Players.LocalPlayer:FindFirstChild("Backpack")
            for _, alias in ipairs(aliases) do
                local t = (char and char:FindFirstChild(alias)) or (bp and bp:FindFirstChild(alias))
                if t and t:IsA("Tool") then
                    return t
                end
            end
            return nil
        end

        function GetPlayerMeleeMastery(meleeName)
            local canon = ToCanonicalMeleeName(meleeName)
            local aliases = MeleeToolAliases[canon] or {meleeName}

            -- 1. Nếu tool đang có sẵn trong người (Character/Backpack), cập nhật mastery mới nhất
            for _, alias in ipairs(aliases) do
                local t = GetPlayerMeleeTool(alias)
                if t and t:FindFirstChild("Level") then
                    local lvl = tonumber(t.Level.Value) or 0
                    if ScriptStorage and ScriptStorage.Melees then
                        ScriptStorage.Melees[alias] = lvl
                        ScriptStorage.Melees[canon] = lvl
                    end
                    return lvl
                end
            end

            -- 2. Đọc từ bộ nhớ ScriptStorage.Melees (đảm bảo không bị quên mastery khi đã cất võ)
            if ScriptStorage and ScriptStorage.Melees then
                for _, alias in ipairs(aliases) do
                    local cached = tonumber(ScriptStorage.Melees[alias])
                    if cached and cached > 0 then
                        return cached
                    end
                end
                local cachedCanon = tonumber(ScriptStorage.Melees[canon])
                if cachedCanon and cachedCanon > 0 then
                    return cachedCanon
                end
            end

            return 0
        end

        function GetCurrentMeleeMastery()
            local success, mName, mLvl, maxReq = pcall(function()
                local CurrentPlayer = game.Players.LocalPlayer
                if not CurrentPlayer then return nil, 0, 400 end

                -- Check character equipped tool first
                local char = CurrentPlayer.Character
                local equippedTool = char and char:FindFirstChildOfClass("Tool")
                if equippedTool and (equippedTool.ToolTip == "Melee" or MeleeCanonicalNames[equippedTool.Name]) then
                    local lvlVal = equippedTool:FindFirstChild("Level") and equippedTool.Level.Value
                    local rawName = equippedTool.Name
                    local canonName = ToCanonicalMeleeName(rawName)
                    local curLvl = lvlVal or GetPlayerMeleeMastery(canonName) or 0
                    if ScriptStorage and ScriptStorage.Melees then
                        ScriptStorage.Melees[rawName] = curLvl
                        ScriptStorage.Melees[canonName] = curLvl
                    end
                    local req = (MeleePrices and MeleePrices[canonName] and MeleePrices[canonName].NextLevelRequirement) or 400
                    return canonName, curLvl, req
                end

                -- Check backpack
                local bp = CurrentPlayer:FindFirstChild("Backpack")
                if bp then
                    for _, tool in ipairs(bp:GetChildren()) do
                        if tool:IsA("Tool") and (tool.ToolTip == "Melee" or MeleeCanonicalNames[tool.Name]) then
                            local lvlVal = tool:FindFirstChild("Level") and tool.Level.Value
                            local rawName = tool.Name
                            local canonName = ToCanonicalMeleeName(rawName)
                            local curLvl = lvlVal or GetPlayerMeleeMastery(canonName) or 0
                            if ScriptStorage and ScriptStorage.Melees then
                                ScriptStorage.Melees[rawName] = curLvl
                                ScriptStorage.Melees[canonName] = curLvl
                            end
                            local req = (MeleePrices and MeleePrices[canonName] and MeleePrices[canonName].NextLevelRequirement) or 400
                            return canonName, curLvl, req
                        end
                    end
                end

                return nil, 0, 400
            end)

            if success and mName then
                return mName, mLvl or 0, maxReq or 400
            end
            return nil, 0, 400
        end

        function GetCurrentFruitMastery()
            local success, level, maxLvl = pcall(function()
                local CurrentPlayer = game.Players.LocalPlayer
                if not CurrentPlayer or not CurrentPlayer:FindFirstChild("Data") or not CurrentPlayer.Data:FindFirstChild("DevilFruit") then
                    return 0, 0
                end
                local CurrentFruit = CurrentPlayer.Data.DevilFruit.Value
                local DF =
                    CurrentPlayer.Character and
                    (CurrentPlayer.Character:FindFirstChild(CurrentFruit) or
                        (CurrentPlayer:FindFirstChild("Backpack") and CurrentPlayer.Backpack:FindFirstChild(CurrentFruit)))
                local bfMaxLevel = 0

                if DF and CurrentFruit and CurrentFruit ~= "" then
                    local Data = FruitDataCache[CurrentFruit]
                    if not Data and DF:FindFirstChild("Data") then
                        Data = safe_require(DF.Data, 1)
                    end
                    if Data then
                        FruitDataCache[CurrentFruit] = Data
                        for _, v in {"V", "C", "X", "F", "Z"} do
                            if Data.Lvl and Data.Lvl[v] then
                                bfMaxLevel = Data.Lvl[v]
                                break
                            end
                        end
                    end

                    return (DF:FindFirstChild("Level") and DF.Level.Value) or 0, bfMaxLevel
                end
                return 0, bfMaxLevel
            end)
            if success and level then
                return level, maxLvl or 0
            end
            return 0, 0
        end

        pcall(function() Remotes.Redeem:InvokeServer("KITT_RESET") end)
        pcall(function() Remotes.Redeem:InvokeServer("Sub2UncleKizaru") end)
        pcall(function() Remotes.Redeem:InvokeServer("SUB2GAMERROBOT_RESET1") end)

        function ResetStat(PrimaryPoint)
            if (LocalPlayer.Data.Stats:FindFirstChild(PrimaryPoint).Level.Value < 2000) then
                if ScriptStorage.PlayerData.StatRefunds > 0 then
                    Remotes.CommF_:InvokeServer("redeemRefundPoints", "Refund Points")
                elseif ScriptStorage.PlayerData.Fragments > 2500 then
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "1")
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
                else
                    return false
                end

                Remotes.CommF_:InvokeServer("AddPoint", PrimaryPoint, 9999)
                Remotes.CommF_:InvokeServer("AddPoint", "Melee", 9999)
                Remotes.CommF_:InvokeServer("AddPoint", "Defense", 9999)
            end
            return true
        end
 
        pcall(function() print(GetCurrentFruitMastery()) end)
        FunctionsHandler.MeleesController:RegisterMethod(
            "Refresh",
            function()
                if not Config.Items.AutoFullyMelees then
                    return false
                end

                local isSaberOngoing = (type(IsSaberQuestActive) == "function" and IsSaberQuestActive()) or (CurrentTask == "Saber")
                if isSaberOngoing then
                    return false
                end

                -- Always return true when AutoFullyMelees is enabled to actively check all fighting styles in MeleesTable
                for _, meleeName in ipairs(MeleesTable) do
                    if meleeName ~= "SanguineArt" then
                        local mastery = GetPlayerMeleeMastery(meleeName)
                        local req = (MeleePrices and MeleePrices[meleeName] and MeleePrices[meleeName].NextLevelRequirement) or 400
                        if mastery < req then
                            return true
                        end
                        local existingTool = GetPlayerMeleeTool(meleeName)
                        if not existingTool then
                            return true
                        end
                    end
                end

                return false
            end
        )

        FunctionsHandler.MeleesController:RegisterMethod(
            "Start",
            function()
                ScriptStorage.IsGettingMelee = false

                if not Config.Items.AutoFullyMelees then
                    return
                end

                -- [ƯU TIÊN TUYỆT ĐỐI CHO SABER]
                -- Nếu đang làm nhiệm vụ Saber hoặc đến cấp làm Saber (>= 200 tại Sea 1 mà chưa có Saber)
                -- TẠM DỪNG HOÀN TOÀN việc đổi/mua/cày võ để người chơi làm xong nhiệm vụ Saber!
                local isSaberOngoing = (type(IsSaberQuestActive) == "function" and IsSaberQuestActive()) or (CurrentTask == "Saber")
                if isSaberOngoing then
                    ScriptStorage.IsGettingMelee = false
                    return
                end

                -- 1. Kiểm tra võ đang cầm hiện tại
                local curMelee, curMastery, reqMastery = GetCurrentMeleeMastery()

                -- Chi cay mastery vo dang cầm NEU no thuoc danh sach can dung (MeleesTable).
                -- Vo mac dinh "Combat" bo qua de buoc duoi di mua vo, tranh cham 400 mastery vo tran.
                local function IsListedMelee(nm)
                    for _, n in ipairs(MeleesTable) do
                        if n == nm then
                            return true
                        end
                    end
                    return false
                end

                -- Nếu đang cầm một võ và võ đó CHƯA ĐẠT Mastery yêu cầu (thường là 400)
                -- TIẾP TỤC DÙNG VÕ NÀY để cày, KHÔNG nhảy lung tung sang võ khác!
                if curMelee and IsListedMelee(curMelee) then
                    LastLockedMelee = curMelee
                    if curMastery < reqMastery then
                        SetTask("MainTask", "Checking & Farming Melee Mastery")
                        SetTask("SubTask", "Farming Mastery: " .. tostring(curMelee) .. " (" .. curMastery .. "/" .. reqMastery .. ")")
                        if FunctionsHandler.LevelFarm and FunctionsHandler.LevelFarm.Methods and FunctionsHandler.LevelFarm.Methods.Start then
                            pcall(function() FunctionsHandler.LevelFarm.Methods.Start:Call() end)
                        end
                        return
                    end
                elseif LastLockedMelee then
                    local lastTool = GetPlayerMeleeTool(LastLockedMelee)
                    if lastTool then
                        local lastMastery = GetPlayerMeleeMastery(LastLockedMelee)
                        local req = (MeleePrices and MeleePrices[LastLockedMelee] and MeleePrices[LastLockedMelee].NextLevelRequirement) or 400
                        if lastMastery < req then
                            if FunctionsHandler.LocalPlayerController and FunctionsHandler.LocalPlayerController.Methods and FunctionsHandler.LocalPlayerController.Methods.EquipTool then
                                pcall(function()
                                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(lastTool.Name)
                                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                                end)
                            end
                            SetTask("MainTask", "Checking & Farming Melee Mastery")
                            SetTask("SubTask", "Farming Mastery: " .. tostring(LastLockedMelee) .. " (" .. lastMastery .. "/" .. req .. ")")
                            if FunctionsHandler.LevelFarm and FunctionsHandler.LevelFarm.Methods and FunctionsHandler.LevelFarm.Methods.Start then
                                pcall(function() FunctionsHandler.LevelFarm.Methods.Start:Call() end)
                            end
                            return
                        end
                    end
                end

                -- 2. Nếu không cầm võ hoặc võ hiện tại đã đạt đủ Mastery:
                -- Tìm duy nhất MỘT võ đầu tiên trong danh sách MeleesTable mà chưa đạt Mastery
                local targetMelee = nil
                local targetIndex = nil
                for idx, meleeName in ipairs(MeleesTable) do
                    if meleeName ~= "SanguineArt" then
                        local mastery = GetPlayerMeleeMastery(meleeName)
                        local req = (MeleePrices and MeleePrices[meleeName] and MeleePrices[meleeName].NextLevelRequirement) or 400
                        if mastery < req then
                            targetMelee = meleeName
                            targetIndex = idx
                            break -- QUAN TRỌNG: Dừng ngay tại võ đầu tiên cần cày! Tuyệt đối không duyệt tiếp để tránh nhảy qua nhảy lại!
                        end
                    end
                end

                if not targetMelee then
                    -- Tất cả võ đã đạt Mastery yêu cầu!
                    return
                end

                -- 3. Kiểm tra xem người chơi đã có sẵn công cụ võ targetMelee chưa
                local existingTool = GetPlayerMeleeTool(targetMelee)
                if existingTool then
                    LastLockedMelee = targetMelee
                    -- Đã có võ trong Character hoặc Backpack, trang bị ngay!
                    if FunctionsHandler.LocalPlayerController and FunctionsHandler.LocalPlayerController.Methods and FunctionsHandler.LocalPlayerController.Methods.EquipTool then
                        pcall(function()
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(existingTool.Name)
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                        end)
                    end
                    return
                end

                -- 4. Nếu chưa có tool võ trên người:
                -- Kiểm tra xem đã từng mua võ này chưa (có thể chuyển miễn phí qua remote)
                local mId = GetMeleeIdByName(targetMelee) or string.gsub(targetMelee, "%s+", "")
                local mData = MeleePrices[targetMelee]

                -- Thử đổi võ qua Remote trước (nếu đã từng mua trước đó)
                pcall(function()
                    Remotes.CommF_:InvokeServer("Buy" .. mId)
                end)
                
                -- Check lại xem đã nhận được tool võ chưa
                task.wait(0.3)
                existingTool = GetPlayerMeleeTool(targetMelee)
                if existingTool then
                    LastLockedMelee = targetMelee
                    if FunctionsHandler.LocalPlayerController and FunctionsHandler.LocalPlayerController.Methods and FunctionsHandler.LocalPlayerController.Methods.EquipTool then
                        pcall(function()
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(existingTool.Name)
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                        end)
                    end
                    return
                end

                -- 5. Nếu chưa từng mua võ này:
                -- Kiểm tra điều kiện tiền/vật phẩm để mua
                local PlayerData = ScriptStorage.PlayerData
                if mData and mData.Price then
                    for currency, reqAmount in pairs(mData.Price) do
                        local curAmount = (PlayerData and tonumber(PlayerData[currency])) or 0
                        local reqVal = tonumber(reqAmount) or 0
                        if curAmount < reqVal then
                            SetTask("SubTask", "Farming " .. tostring(currency) .. " (" .. curAmount .. "/" .. reqVal .. ") for " .. targetMelee)
                            return -- Chưa đủ tiền thì tiếp tục farm bằng võ cũ, không làm gì thêm!
                        end
                    end
                end

                -- 6. Nếu đã đủ tiền mua võ mới:
                -- Bay đến NPC tương ứng tại Sea hiện tại để mua võ
                local npcPositions = {
                    ["Black Leg"] = {Sea = 1, CFrame = CFrame.new(-1436.5, 29.8, 298.5), Npc = "Dark Step Teacher"},
                    ["Electro"] = {Sea = 1, CFrame = CFrame.new(-4722.5, 717.8, -842.2), Npc = "Mad Scientist"},
                    ["Fishman Karate"] = {Sea = 1, CFrame = CFrame.new(61163.8, 18.5, 1569.4), Npc = "Water Kung-fu Teacher"}
                }

                local targetInfo = npcPositions[targetMelee]
                if targetInfo then
                    if SeaIndex == targetInfo.Sea then
                        -- Lay vi tri THAT cua NPC trong game (workspace.NPCs / ReplicatedStorage.NPCs),
                        -- toa do co dinh chi dung khi game chua load NPC do
                        local npcCF = nil
                        pcall(function()
                            local npc = ScriptStorage.NPCs[targetInfo.Npc]
                            if npc then
                                if npc.WorldPivot and typeof(npc.WorldPivot) == "CFrame" then
                                    npcCF = npc.WorldPivot
                                elseif npc:FindFirstChild("HumanoidRootPart") then
                                    npcCF = npc.HumanoidRootPart.CFrame
                                elseif npc:FindFirstChild("Handle") and npc.Handle:IsA("BasePart") then
                                    npcCF = npc.Handle.CFrame
                                end
                            end
                        end)
                        -- NPC chua spawn thi WorldPivot hay nam o (0,0,0) -> khong duoc dung
                        if npcCF and math.abs(npcCF.Position.X) < 1 and math.abs(npcCF.Position.Z) < 1 then
                            npcCF = nil
                        end
                        if not npcCF then
                            npcCF = targetInfo.CFrame
                        end
                        print(
                            "[Melee] Bay toi NPC '" .. targetInfo.Npc .. "' tai " .. tostring(npcCF.Position) ..
                                " (cach " .. math.floor(CaculateDistance(npcCF.Position)) .. " stud)"
                        )

                        SetTask("MainTask", "Buying Melee | " .. targetMelee)
                        SetTask("SubTask", "Moving to " .. targetInfo.Npc .. " to purchase...")
                        ScriptStorage.IsGettingMelee = true

                        local npcTargetPos = npcCF.Position
                        if CaculateDistance(npcTargetPos) > 12 then
                            TweenController.Create(npcCF)
                        else
                            pcall(function() Remotes.CommF_:InvokeServer("Buy" .. mId) end)
                            task.wait(1)
                            pcall(RefreshInventory)
                            existingTool = GetPlayerMeleeTool(targetMelee)
                            if existingTool then
                                LastLockedMelee = targetMelee
                                if FunctionsHandler.LocalPlayerController and FunctionsHandler.LocalPlayerController.Methods and FunctionsHandler.LocalPlayerController.Methods.EquipTool then
                                    pcall(function()
                                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(existingTool.Name)
                                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                                    end)
                                end
                            end
                        end
                        ScriptStorage.IsGettingMelee = false
                    end
                end
                return
            end
        )
        -- Second Sea

        FunctionsHandler.SecondSeaPuzzle:RegisterMethod(
            "Refresh",
            function()
                if ScriptStorage.PlayerData.Level < 700 or SeaIndex ~= 1 then
                    return
                end
                if FunctionsHandler.SecondSeaPuzzle:Get("IsCompleted") then
                    return
                end

                local Result = nil
                local ok, Response = pcall(function()
                    return Remotes.CommF_:InvokeServer("DressrosaQuestProgress")
                end)
                if ok and type(Response) == "table" then
                    print(959, Response.TalkedDetective, Response.KilledIceBoss)
                    if not Response.TalkedDetective then
                        Result = 1
                    elseif not Response.KilledIceBoss then
                        Result = 2
                    else
                        FunctionsHandler.SecondSeaPuzzle:Set("IsCompleted", true)
                    end
                end

                FunctionsHandler.SecondSeaPuzzle:Set("CurrentProgressLevel", Result)
                FunctionsHandler.SecondSeaPuzzle:Set("LastestRefreshSenque", os.time())

                return Result
            end
        )

        FunctionsHandler.SecondSeaPuzzle:RegisterMethod(
            "Start",
            function()
                local Progress, LastestRefreshSenque =
                    FunctionsHandler.SecondSeaPuzzle:Get("CurrentProgressLevel"),
                    FunctionsHandler.SecondSeaPuzzle:Get("LastestRefreshSenque")

                FunctionsHandler.SecondSeaPuzzle:Set("CurrentProgressLevel", nil)
                if not Progress then
                    return
                elseif Progress == 1 then
                    SetTask("MainTask", "Auto Second Sea - Talk To Detective")
                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")

                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")

                    task.wait(1)
                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "UseKey")
                elseif Progress == 2 then
                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")

                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")

                    task.wait(1)
                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "UseKey")
                    SetTask("MainTask", "Auto Second Sea - Defeating Ice Admiral")
                    CombatController.Attack("Ice Admiral")
                    alert("Traveling back to Dressrosa [ Ice Admiral ]")
                    Remotes.CommF_:InvokeServer("TravelDressrosa")
                end
            end
        )

        -- Bartilo

        FunctionsHandler.ColosseumPuzzle:RegisterMethod(
            "Refresh",
            function()
                if SeaIndex ~= 2 then
                    return
                end

                if ScriptStorage.PlayerData.Level < 850 or ScriptStorage.PlayerData.Level >= 1500 then
                    return
                end

                if ScriptStorage.Backpack["Warrior Helmet"] or (ScriptStorage.Inventory and ScriptStorage.Inventory["Warrior Helmet"]) or (ScriptStorage.Accessories and ScriptStorage.Accessories["Warrior Helmet"]) then
                    return
                end

                local Result = nil
                local ok, Response = pcall(function()
                    return Remotes.CommF_:InvokeServer("BartiloQuestProgress")
                end)

                if ok and type(Response) == "table" then
                    if not Response.KilledBandits then
                        Result = 1
                    elseif not Response.KilledSpring then
                        if ScriptStorage.Enemies.Jeremy then
                            Result = 2
                        end
                    elseif not Response.DidPlates then
                        Result = 3
                    end
                end

                FunctionsHandler.ColosseumPuzzle:Set("CurrentProgressLevel", Result)
                FunctionsHandler.ColosseumPuzzle:Set("LastestRefreshSenque", os.time())
                return Result
            end
        )
        print(4)
        FunctionsHandler.ColosseumPuzzle:RegisterMethod(
            "Start",
            function()
                local Progress, LastestRefreshSenque =
                    FunctionsHandler.ColosseumPuzzle:Get("CurrentProgressLevel"),
                    FunctionsHandler.ColosseumPuzzle:Get("LastestRefreshSenque")
                FunctionsHandler.ColosseumPuzzle:Set("CurrentProgressLevel", nil)
                print("Progress", Progress)
                if not Progress then
                    return
                elseif Progress == 1 then
                    SetTask("MainTask", "Auto Bartilo Quest - Defeating 50x Swan Pirate")
                    local CurrentQuest, RawText = QuestManager:GetCurrentClaimQuest()

                    if CurrentQuest then
                        if not string.find(RawText, "50") then
                            QuestManager.AbandonQuest()
                        else
                            CombatController.Attack("Swan Pirate")
                        end
                    else
                        QuestManager.StartQuest("BartiloQuest", 1)
                    end
                elseif Progress == 2 then
                    SetTask("MainTask", "Auto Bartilo Quest - Defeating Jeremy")
                    CombatController.Attack("Jeremy")
                elseif Progress == 3 then
                    SetTask("MainTask", "Auto Bartilo Quest - Doing Puzzle")
                    if
                        CaculateDistance(
                            CFrame.new(
                                -1837.46155,
                                44.2921753,
                                1656.1987,
                                0.999881566,
                                -1.03885048e-22,
                                -0.0153914848,
                                1.07805858e-22,
                                1,
                                2.53909284e-22,
                                0.0153914848,
                                -2.55538502e-22,
                                0.999881566
                            )
                        ) > 10
                     then
                        alert("tween to")
                        TweenController.Create(
                            CFrame.new(
                                -1837.46155,
                                44.2921753,
                                1656.1987,
                                0.999881566,
                                -1.03885048e-22,
                                -0.0153914848,
                                1.07805858e-22,
                                1,
                                2.53909284e-22,
                                0.0153914848,
                                -2.55538502e-22,
                                0.999881566
                            )
                        )
                    else
                        LocalPlayer = game.Players.LocalPlayer
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1836, 11, 1714)
                        alert("1")
                        task.wait(.5)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1850.49329, 13.1789551, 1750.89685)
                        alert("2")
                        task.wait(1)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1858.87305, 19.3777466, 1712.01807)
                        alert("3")
                        task.wait(1)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1803.94324, 16.5789185, 1750.89685)
                        task.wait(1)
                        alert("4")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1858.55835, 16.8604317, 1724.79541)
                        task.wait(1)
                        alert("5")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1869.54224, 15.987854, 1681.00659)
                        task.wait(1)
                        alert("6")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1800.0979, 16.4978027, 1684.52368)
                        task.wait(1)
                        alert("7")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1819.26343, 14.795166, 1717.90625)
                        task.wait(1)
                        alert("8")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1813.51843, 14.8604736, 1724.79541)
                    end
                end
            end
        )

        -- Race v2

        FunctionsHandler.EvoRace:RegisterMethod(
            "Refresh",
            function()
                if not Config.Items.RaceV2 then
                    return
                end
                if SeaIndex ~= 2 then
                    return
                end
                if
                    GetExpBoost() ~= 0 or
                        ScriptStorage.PlayerData.Level < 900 or
                        ScriptStorage.PlayerData.Beli < 1000000 or
                        ScriptStorage.PlayerData.RaceLevel ~= 1
                 then
                    return
                end
                return true
            end
        )

        FunctionsHandler.EvoRace:RegisterMethod(
            "Start",
            function()
                Remotes.CommF_:InvokeServer("Alchemist", "1")
                Remotes.CommF_:InvokeServer("Alchemist", "2")

                for i = 1, 2, 1 do
                    local Check1 = ScriptStorage.Tools["Flower " .. i]
                    local Check2 = Services.Workspace:FindFirstChild("Flower" .. i)

                    if not Check1 then
                        if Check2 and Check2.Transparency == 0 then
                            SetTask("MainTask", "Auto Race V2 - Collecting Flower " .. i)
                            while not ScriptStorage.Tools["Flower " .. i] do
                                task.wait()
                                TweenController.Create(Check2.CFrame + Vector3.new(0, math.random(-1, 2), 0))
                            end
                        end
                    end
                end

                if not ScriptStorage.Tools["Flower 3"] then
                    SetTask("MainTask", "Auto Race V2 - Collecting Flower " .. 3)
                    CombatController.Attack("Swan Pirate")
                else
                    SetTask("MainTask", "Auto Race V2 - Idling")
                    if LocalPlayer.Character.HumanoidRootPart.CFrame.Y < 50000 then
                        TweenController.Create(LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 50, 0))
                    end

                    Remotes.CommF_:InvokeServer("Alchemist", "3")
                    RefreshRace()
                end
            end
        )

        -- BossesTask

        FunctionsHandler.BossesTask:RegisterMethod(
            "Refresh",
            function()
                local Boss
                for _, BossName in BossesOrder do
                    if BossName then 
                    local LevelReq = BossesOrderLevel[BossName]

                    if ScriptStorage.PlayerData.Level >= LevelReq then
                        local Result = ScriptStorage.Enemies[BossName]
                        if Result and Result:FindFirstChild("Humanoid") and Result.Humanoid.Health > 0 then
                            Boss = Result
                        end
                    end
                    end
                end

                if
                    Boss and
                        (CaculateDistance(Boss.HumanoidRootPart.CFrame) < (SeaIndex == 2 and 3000 or 5000) or
                            BossesOrderWL[tostring(Boss)] or
                            ScriptStorage.PlayerData.Level == MaxLevel)
                 then
                    return Boss
                end
            end
        )

        FunctionsHandler.BossesTask:RegisterMethod(
            "Start",
            function(Boss)
                if Boss then
                    SetTask("MainTask", "Auto Farm Boss - Defeating " .. Boss.Name)

                    CombatController.Attack(
                        tostring(Boss),
                        null,
                        null,
                        function()
                            SpecialItems = nil
                        end
                    )

                    SpecialItems = nil
                end
            end
        )

        FunctionsHandler.SpecialBossesTask:RegisterMethod(
            "Refresh",
            function()
                local Boss2

                for BossName, LevelReq in SpecialBossesOrder do
                    if ScriptStorage.PlayerData.Level >= LevelReq then
                        local Result = ScriptStorage.Enemies[BossName]
                        if Result and Result:FindFirstChild("Humanoid") and Result.Humanoid.Health > 0 then
                            Boss2 = Result
                        end
                    end
                end
                return Boss2
            end
        )

        FunctionsHandler.SpecialBossesTask:RegisterMethod(
            "Start",
            function(Boss)
                if FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() then
                    pcall(
                        function()
                            LocalPlayer.Character.Humanoid.Health = 0
                        end
                    )
                end

                if Boss then
                    SetTask("MainTask", "Auto Farm Boss - Defeating " .. Boss.Name)
                    CombatController.Attack(tostring(Boss))
                end
            end
        )

        -- RaidController

        FunctionsHandler.RaidController:RegisterMethod(
            "RefreshRaidType",
            function()
                pcall(function()
                    local raidsMod = game.ReplicatedStorage:FindFirstChild("Raids")
                    if raidsMod then
                        local raidsData = safe_require(raidsMod, 1)
                        if raidsData and raidsData.raids then
                            for _, Raid in raidsData.raids do
                                if ScriptStorage.PlayerData and ScriptStorage.PlayerData.DevilFruit and string.find(tostring(ScriptStorage.PlayerData.DevilFruit), Raid) then
                                    FunctionsHandler.RaidController:Set("CurrentChip", Raid)
                                    return
                                end
                            end
                        end
                    end
                end)
                FunctionsHandler.RaidController:Set("CurrentChip", "Flame")
            end
        )

        FunctionsHandler.RaidController:RegisterMethod(
            "GetRaidableFruit",
            function()
                pcall(RefreshInventory)
                
                local TrashFruits = {
                    ["Rocket-Rocket"] = true, ["Spin-Spin"] = true, ["Blade-Blade"] = true, ["Chop-Chop"] = true,
                    ["Spring-Spring"] = true, ["Bomb-Bomb"] = true, ["Smoke-Smoke"] = true, ["Spike-Spike"] = true,
                    ["Flame-Flame"] = true, ["Falcon-Falcon"] = true, ["Ice-Ice"] = true, ["Sand-Sand"] = true,
                    ["Dark-Dark"] = true, ["Diamond-Diamond"] = true, ["Light-Light"] = true, ["Rubber-Rubber"] = true,
                    ["Barrier-Barrier"] = true, ["Ghost-Ghost"] = true, ["Magma-Magma"] = true, ["Quake-Quake"] = true
                }
                
                local HighFruits = {
                    "Kitsune", "Dragon", "Leopard", "Spirit", "Control", "Venom", "Shadow", "Dough", 
                    "T-Rex", "Mammoth", "Gravity", "Blizzard", "Pain", "Rumble", "Portal", "Phoenix", 
                    "Sound", "Spider", "Love", "Buddha"
                }

                -- 1. Kiểm tra trực tiếp qua getInventoryFruits
                local directFruits = nil
                pcall(function() directFruits = Remotes.CommF_:InvokeServer("getInventoryFruits") end)
                if type(directFruits) == "table" then
                    for _, Fruit in pairs(directFruits) do
                        if type(Fruit) == "table" and Fruit.Name then
                            local rawName = tostring(Fruit.Name)
                            local price = tonumber(Fruit.Price) or tonumber(Fruit.Value) or 0
                            local isTrash = TrashFruits[rawName] or (price > 0 and price < 1000000)
                            if not isTrash then
                                for tName, _ in pairs(TrashFruits) do
                                    local baseName = string.split(tName, "-")[1]
                                    if string.find(rawName, baseName) then
                                        isTrash = true
                                        break
                                    end
                                end
                            end
                            local isHighTier = false
                            for _, hName in ipairs(HighFruits) do
                                if string.find(rawName, hName) then
                                    isHighTier = true
                                    break
                                end
                            end
                            local isEatList = Config and Config.Items and Config.Items.Eatlist and table.find(Config.Items.Eatlist, rawName)
                            if (isTrash or (price > 0 and price < 1000000)) and not isHighTier and not isEatList then
                                Fruit.Type = "Blox Fruit"
                                return Fruit
                            end
                        end
                    end
                end

                -- 2. Kiểm tra trong ScriptStorage.Backpack
                for _, Fruit in pairs(ScriptStorage.Backpack or {}) do
                    if type(Fruit) == "table" and Fruit.Name then
                        local rawName = tostring(Fruit.Name)
                        local isBloxFruit = (Fruit.Type == "Blox Fruit") or string.find(rawName, "-") or string.find(rawName, "Fruit")
                        if isBloxFruit then
                            local price = tonumber(Fruit.Price) or tonumber(Fruit.Value) or 0
                            local isTrash = TrashFruits[rawName] or (price > 0 and price < 1000000)
                            if not isTrash then
                                for tName, _ in pairs(TrashFruits) do
                                    local baseName = string.split(tName, "-")[1]
                                    if string.find(rawName, baseName) then
                                        isTrash = true
                                        break
                                    end
                                end
                            end
                            local isHighTier = false
                            for _, hName in ipairs(HighFruits) do
                                if string.find(rawName, hName) then
                                    isHighTier = true
                                    break
                                end
                            end
                            local isEatList = Config and Config.Items and Config.Items.Eatlist and table.find(Config.Items.Eatlist, rawName)
                            if (isTrash or (price > 0 and price < 1000000)) and not isHighTier and not isEatList then
                                return Fruit
                            end
                        end
                    end
                end

                -- 3. Kiểm tra nếu người chơi đang cầm trái rác vật lý trong túi đồ Backpack/Character
                local lp = game:GetService("Players").LocalPlayer
                if lp then
                    local checkTools = {}
                    if lp.Character then
                        for _, tool in pairs(lp.Character:GetChildren()) do
                            if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then table.insert(checkTools, tool) end
                        end
                    end
                    if lp:FindFirstChild("Backpack") then
                        for _, tool in pairs(lp.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then table.insert(checkTools, tool) end
                        end
                    end
                    for _, tool in ipairs(checkTools) do
                        local toolName = tool.Name
                        local isHighTier = false
                        for _, hName in ipairs(HighFruits) do
                            if string.find(toolName, hName) then
                                isHighTier = true
                                break
                            end
                        end
                        if not isHighTier then
                            return { Name = toolName, Type = "Blox Fruit", IsPhysical = true }
                        end
                    end
                end

                return nil
            end
        )

        FunctionsHandler.RaidController:RegisterMethod(
            "GetCurrentRaidIsland",
            function()
                PlayerPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
                IslandsList = {{}, {}, {}, {}, {}}

                for _, Island in workspace["_WorldOrigin"].Locations:GetChildren() do
                    if
                        string.find(Island.Name, "Island ") and
                            CaculateDistance(Island.Position, Vector3.new(0, 0, 0)) > 7000
                     then
                        (function()
                            local IslandIndex = string.gsub(Island.Name, "Island ", "")
                            local IslandIndex = tonumber(IslandIndex)
                            table.insert(IslandsList[IslandIndex], Island)
                        end)()
                    end
                end

                if true then
                    for Index = 5, 1, -1 do
                        for _, Island in IslandsList[Index] do
                            if CaculateDistance(Island.Position) < 2000 then
                                return Island
                            end
                        end
                    end
                end
            end
        )

        function CheckSpecialMicrochip()
            for _, v in {LocalPlayer.Character:GetChildren(), LocalPlayer.Backpack:GetChildren()} do
                for _, v in v do
                    if v.Name == "Special Microchip" then
                        return v
                    end
                end
            end
        end
     
    
        FunctionsHandler.RaidController:RegisterMethod("Refresh", function()
            if getgenv().IsCheckingMelees then return end
        
            local Level = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or 0
            local Fragments = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Fragments) or 0
            local Beli = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Beli) or 0
        
            -- Điều kiện cơ bản: Raid mở từ Sea 2 (Lv 1100+) hoặc Sea 3
            if Level < 1100 or SeaIndex == 1 then return end
            if ScriptStorage.IsGettingMelee then return end

            local isSaberOngoing = (type(IsSaberQuestActive) == "function" and IsSaberQuestActive()) or (CurrentTask == "Saber")
            if isSaberOngoing then return end
        
            -- 1. Check Melee: Chỉ chặn Raid nếu thực sự có thể mua NGAY LẬP TỨC
            if Config.Items.AutoFullyMelees then
                for Cursor, Melee in pairs(MeleesTable) do
                    if Melee ~= "SanguineArt" then
                        local Data = MeleePrices[Melee]
                        if Data then
                            local CanMeleePurchaseable = CanPurchase[Melee]
                            if not CanMeleePurchaseable and type(Data.Buy) == "function" then
                                CanMeleePurchaseable = Data.Buy(1)
                            end

                            local RequiredFragments = (Data.Price and Data.Price.Fragments) or 0
                            local CurrentFragments = Fragments

                            if CanMeleePurchaseable and Data.Requirements and Data.Requirements() and
                               (RequiredFragments == 0 or CurrentFragments >= RequiredFragments)
                            then
                                if not ScriptStorage.Melees[Melee] or ScriptStorage.Melees[Melee] == 0 then
                                    print("Da du dieu kien mua " .. Melee .. ". Dung Raid de di mua!")
                                    return
                                end
                            end
                        end
                    end
                end
            end

            -- 2. Logic tích luỹ Fragments:
            -- Nếu đang trên đảo Raid hoặc có Microchip sẵn -> LUÔN tiếp tục Raid!
            local inRaidIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
            local hasChip = CheckSpecialMicrochip()
            if inRaidIsland or hasChip then
                return true
            end

            -- Nếu Level chưa Max: farm tích luỹ đến 10k Fragments
            -- Nếu đã Max Level: farm tích luỹ đến 15k Fragments
            if Level < MaxLevel then
                if Fragments >= 10000 then return end 
            else
                if Fragments >= 15000 then return end 
            end
        
            -- 3. Thực hiện đi Raid (Hỗ trợ cả Fruit dưới 1M lẫn mua Chip bằng 100k Beli)
            local RaidFruit = FunctionsHandler.RaidController.Methods.GetRaidableFruit:Call()
            if RaidFruit then
                FunctionsHandler.RaidController:Set("CurrentProgressLevel", RaidFruit)
                return RaidFruit
            end
            
            -- Nếu không có Fruit nhưng có Beli -> Chỉ đi mua nếu không bị Cooldown 2 tiếng
            -- Nếu đang bị cooldown -> return false để LevelFarm đi làm nhiệm vụ / cày cấp!
            if Beli >= 100000 then
                if not (getgenv().BeliChipCooldownUntil and os.time() < getgenv().BeliChipCooldownUntil) then
                    return true
                end
            end
            
            return false
        end)
        
        
        
        FunctionsHandler.RaidController:RegisterMethod(
            "Start",
            function()
                if getgenv().IsRaidStarting then
                    return
                end
                
                -- 🔒 BẬT KHÓA TOÀN CỤC NGAY LẬP TỨC ĐỂ BLOCK LEVELFARM VÀ MELEE
                getgenv().IsRaidStarting = true
                getgenv().InRaidSafe = true 
                FunctionsHandler.RaidController:Set("IsInRaidProcess", true)
                
                -- Cooldown chống spam — kiểm tra NGOÀI pcall để không khóa script khi return
                if getgenv().RaidBuyingCooldown and os.clock() - getgenv().RaidBuyingCooldown < 30 then
                    getgenv().IsRaidStarting = false
                    return
                end

                -- Wrap toàn bộ logic trong pcall để đảm bảo các khóa (lock) luôn được xử lý kể cả khi lỗi
                local ok, err = pcall(function()
                    
                    if not FunctionsHandler.RaidController:Get("CurrentChip") then
                        FunctionsHandler.RaidController.Methods.RefreshRaidType:Call()
                    end

                    local CurrentIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                    RefreshInventory()

                    FunctionsHandler.RaidController:Set("CurrentProgressLevel", nil)
                    
                    getgenv().anchored = true 

                    if not CurrentIsland then
                        SetTask(
                            "MainTask",
                            "Auto Raid - Buying Chip - " .. FunctionsHandler.RaidController:Get("CurrentChip")
                        )

                        local RootRaidIsland = ({nil, "CircleIsland", "Boat Castle"})[SeaIndex]
                        local RaidIsland = workspace.Map:FindFirstChild(RootRaidIsland) or workspace:FindFirstChild(RootRaidIsland)
                        
                        if not RaidIsland or not RaidIsland:FindFirstChild("RaidSummon2") then
                            task.wait(1)
                            return
                        end
                        
                        -- Lấy trực tiếp cái nút để sau này bấm hoặc bay tới (cho Sea 2)
                        local RaidButton = RaidIsland.RaidSummon2.Button.Main
                        
                        if not CheckSpecialMicrochip() then
                            local cRaidFruit = FunctionsHandler.RaidController.Methods.GetRaidableFruit:Call()
                            
                            if cRaidFruit then
                                -- Mua bằng trái ác quỷ
                                if not table.find(ScriptStorage.IgnoreStoreFruits, cRaidFruit.Name) then
                                    table.insert(ScriptStorage.IgnoreStoreFruits, cRaidFruit.Name)
                                end
                                if getgenv().LastLoadedFruit ~= cRaidFruit.Name then
                                    getgenv().LastLoadedFruit = cRaidFruit.Name
                                    alert("Load Fruit", cRaidFruit.Name)
                                    Remotes.CommF_:InvokeServer("LoadFruit", cRaidFruit.Name)
                                    task.wait(1.5)
                                end
                                Remotes.CommF_:InvokeServer("RaidsNpc", "Select", FunctionsHandler.RaidController:Get("CurrentChip"))
                                task.wait(1)
                                Remotes.CommF_:InvokeServer("LoadFruit", cRaidFruit.Name)
                                task.wait(1)
                            else
                                -- Mua bằng Beli (nếu đủ 100k và hết cooldown)
                                local Beli = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Beli) or 0
                                if Beli >= 100000 then
                                    if not (getgenv().BeliChipCooldownUntil and os.time() < getgenv().BeliChipCooldownUntil) then
                                        alert("Raid", "Mua Chip bằng Beli (100k)!")
                                        -- Cất tay không để nó charge bằng Beli
                                        if FunctionsHandler.LocalPlayerController and FunctionsHandler.LocalPlayerController.Methods and FunctionsHandler.LocalPlayerController.Methods.EquipTool then
                                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("")
                                        end
                                        task.wait(1)
                                        Remotes.CommF_:InvokeServer("RaidsNpc", "Select", FunctionsHandler.RaidController:Get("CurrentChip"))
                                        task.wait(1)
                                        -- Đặt cooldown 2 tiếng (7200 giây)
                                        getgenv().BeliChipCooldownUntil = os.time() + 7200
                                    else
                                        warn("Beli Chip đang trong thời gian hồi chiêu 2 tiếng!")
                                        return
                                    end
                                else
                                    warn("Không có trái và không đủ Beli!")
                                    return
                                end
                            end
                        end
                        
                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Special Microchip")
                        task.wait(2)
                        
                        if not CheckSpecialMicrochip() then
                            warn("Failed to get Special Microchip after buying")
                            return
                        end
                        
                        local lastTweenTime = 0
                        local tweenStartTime = os.time()
                        
                        -- 🔧 [ĐÃ SỬA]: Đặt mục tiêu kiểm tra khoảng cách là cái nút bấm, KHÔNG PHẢI NPC
                        local TargetPosition = (SeaIndex == 3) and Vector3.new(-5008.51, 313.85, -2817.10) or RaidButton.Position
                        
                        repeat task.wait() 
                            if os.time() - tweenStartTime > 60 then
                                warn("Tween to Raid Start timed out")
                                return
                            end
                            
                            if os.clock() - lastTweenTime > 0.5 then
                                if SeaIndex == 3 then
                                    TweenController.Create(CFrame.new(-5008.51, 313.85, -2817.10))
                                else
                                    -- Sea 2 bay thẳng vào nút bấm Raid dựa trên RootRaidIsland
                                    TweenController.Create(RaidButton.CFrame)
                                end
                                lastTweenTime = os.clock()
                            end
                            
                        -- Đo khoảng cách với TargetPosition (vị trí cái nút bấm)
                        until CaculateDistance(TargetPosition) <= 100
                        
                        pcall(function()
                            fireclickdetector((workspace.Map:FindFirstChild(RootRaidIsland) or
                                                  workspace:FindFirstChild(RootRaidIsland)).RaidSummon2.Button.Main
                                                  .ClickDetector)
                        end)

                        local RaidStartSenque = os.time()
                        SetTask("MainTask", "Auto Raid - Waiting Until Raid Is Started")

                        local RaidStarted = false
                        repeat
                            task.wait(0.5)
                            local CheckIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                            if CheckIsland then
                                RaidStarted = true
                                break
                            end
                        until os.time() - RaidStartSenque > 30

                        if not RaidStarted then
                            SetTask("MainTask", "Auto Raid - Raid Is Not Started?")
                            Report("[ Raid Error ] Time Limit Reached - No Island Detected")
                            getgenv().LastLoadedFruit = nil
                            return
                        end

                        -- Chỉ set cooldown & block fruit KHI raid thực sự start thành công
                        getgenv().RaidBuyingCooldown = os.clock()

                        alert("Raid Started", "Entering raid island")
                        task.wait(1)
                        
                        CurrentIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                    end
                    
                    if not CurrentIsland then
                        return
                    end
                    
                    if CurrentIsland then
                        FunctionsHandler.RaidController:Set("IsInRaidProcess", true)
                        
                        while true do
                            task.wait(1)
                            CurrentIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                            
                            if not CurrentIsland then
                                SetTask("MainTask", "Auto Raid - Completed")
                                return
                            end
                            
                            SetTask("MainTask", "Auto Raid - " .. CurrentIsland.Name .. " / 5")
                            local Found = false
                            for _, Mon in GetMonAsSortedRange() do
                                local StartTick1 = os.time()
                                while Mon and Mon:FindFirstChild("HumanoidRootPart") and Mon.Humanoid.Health > 0 and
                                    CaculateDistance(Mon.HumanoidRootPart.Position) < 1000 and
                                    os.time() - StartTick1 < 60 and
                                    task.wait(.05) do
                                    Found = true
                                    CombatController.Attack(Mon.Name)
                                    
                                    local CheckIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                                    if not CheckIsland then
                                        SetTask("MainTask", "Auto Raid - Completed")
                                        return
                                    end
                                end
                            end

                            if not Found then
                                TweenController.Create(CurrentIsland.Position + Vector3.new(0, 100, 0))
                            end
                        end
                    end
                end)
                
                -- 🔓 MỞ KHÓA BẢO VỆ — luôn reset IsRaidStarting
                getgenv().IsRaidStarting = false

                if not ok then
                    warn("[RaidController Start Error]", err)
                end

                -- Chỉ reset InRaidSafe/IsInRaidProcess khi raid đã thực sự kết thúc (không còn ở đảo raid)
                if not FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() and not CheckSpecialMicrochip() then
                    getgenv().InRaidSafe = false
                    FunctionsHandler.RaidController:Set("IsInRaidProcess", false)
                end
            end
        )
        

        -- CollectDrops


        -- ========================================================
        -- [FRUIT SCAN v2] Quet trai ac quy - TOI UU CHO DIEN THOAI / MAY YEU
        -- Ban cu quet GetDescendants() TOAN BAN DO moi 45s (hang chuc ngan doi tuong)
        -- va FindNearestFruit chay MOI FRAME -> lag kinh hoai.
        -- Ban nay: (1) lang nghe DescendantAdded voi bo loc sieu re,
        -- (2) quet nong chi 2 cap, (3) quet sau only 1 luc bat dau + moi 5 phut,
        -- (4) cache part / ten trai trong balo, (5) chan tim kiem 0.75s
        -- ========================================================
        FruitWatch = {}
        FruitSkipUntil = {}
        FruitPartCache = {}
        CurrentFruitTarget = nil
        CurrentFruitTargetTime = 0
        FruitOwnedCache = nil
        FruitOwnedCacheTime = 0
        FruitScanNextDeep = 0
        FruitScanNextFind = 0
        FruitScanNextPrune = 0
        FruitScanNextBossPrint = 0
        FruitScanSeenCount = 0

        -- Loc theo ten, plain=true cho nhanh (khong phai pattern)
        -- [FIX] "Blox Fruit Dealer" / "Fruit Gacha" cung chua chu "Fruit" nen bot
        -- nhan lam trai roi va bo toi tan NPC. Chan ten NPC + loc folder NPCs.
        FruitNpcWords = {"Dealer", "Gacha", "Trader", "NPC", "Shop", "Store", "Chest", "Crate", "Island", "Boat", "Ship", "Quest", "Statue", "Stand", "Pedestal", "Prop", "Decor", "Model", "Spawn", "Dummy"}
        function FruitNameBad(nm)
            for _, w in ipairs(FruitNpcWords) do
                if string.find(nm, w, 1, true) then
                    return true
                end
            end
            return false
        end

        -- NPC (ke ca Blox Fruit Dealer) nam trong folder NPCs/Shops -> khong phai trai roi
        function IsInNpcFolder(obj)
            local p = obj and obj.Parent
            local guard = 0
            while p and p ~= workspace and guard < 12 do
                local pn = p.Name
                if pn == "NPCs" or pn == "Shops" or pn == "Quest" or pn == "Arenas" then
                    return true
                end
                p = p.Parent
                guard = guard + 1
            end
            return false
        end

        local function FruitNameHit(nm)
            if FruitNameBad(nm) then
                return false
            end
            -- [FIX] Cai tuong / do trang tri ten "Fruit1", "Fruit2"... nam tren dao.
            -- Trai that LUON co ten loai dung TRUOC chu Fruit ("Flame Fruit"),
            -- con ten BAT DAU bang "Fruit" thi chac chan do -> bo qua.
            if string.match(nm, "^%s*[Ff]ruit") then
                return false
            end
            if string.find(nm, "Fruit", 1, true) then
                return true
            end
            if string.find(nm, "no Mi", 1, true) then
                return true
            end
            return false
        end

        -- Part chuan de lay toa do cua 1 model trai (Handle, hoac BasePart dau tien) - co cache
        function GetFruitPart(obj)
            if not obj then
                return nil
            end
            local cached = FruitPartCache[obj]
            if cached and cached.Parent == obj then
                return cached
            end
            local part = nil
            pcall(function()
                local h = obj:FindFirstChild("Handle")
                if h and h:IsA("BasePart") then
                    part = h
                else
                    for _, c in ipairs(obj:GetChildren()) do
                        if c:IsA("BasePart") then
                            part = c
                            break
                        end
                    end
                end
            end)
            FruitPartCache[obj] = part
            return part
        end

        function IsObjAlive(obj)
            local alive = false
            pcall(function()
                alive = obj ~= nil and obj.Parent ~= nil and obj:IsDescendantOf(workspace)
            end)
            return alive
        end

        function IsFruitLike(obj)
            if not obj then
                return false
            end
            local cl = obj.ClassName
            if cl ~= "Model" and cl ~= "Tool" then
                return false
            end
            local nm = obj.Name
            -- Do ten truoc khi lam nhung thu dat hon
            if not FruitNameHit(nm) and not (cl == "Tool" and obj.ToolTip == "Blox Fruit") then
                return false
            end
            if FruitNameBad(nm) or IsInNpcFolder(obj) then
                return false
            end
            if Players:FindFirstChild(nm) then
                return false
            end
            if not GetFruitPart(obj) then
                return false
            end
            -- Bo qua trai dang nam tren nhan vat (chi lay trai roi o ban dat)
            if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then
                return false
            end
            return true
        end

        function TrackFruit(obj)
            if FruitWatch[obj] then
                return true
            end
            -- pcall o day vi con trai co the bi xoa bat ky luc nao
            local ok, res = pcall(IsFruitLike, obj)
            if ok and res then
                FruitWatch[obj] = true
                FruitScanSeenCount = FruitScanSeenCount + 1
                print("[FruitScan] Thay trai:", tostring(obj.Name), "|", obj.ClassName)
                return true
            end
            return false
        end

        -- Quet nong: chi workspace + con truc tiep cua chung (hang tram doi tuong)
        function ScanWorkspaceShallow()
            local found = 0
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if TrackFruit(obj) then
                        found = found + 1
                    end
                    for _, c in ipairs(obj:GetChildren()) do
                        if TrackFruit(c) then
                            found = found + 1
                        end
                    end
                end
            end)
            return found
        end

        -- Quet sau (dat): chi goi luc bat dau va moi FruitDeepScanDelay giay
        function ScanWorkspaceDeep()
            local found = 0
            local okList, list = pcall(function()
                return workspace:GetDescendants()
            end)
            if not okList then
                warn("[FruitScan] GetDescendants bi loi:", tostring(list))
                return 0
            end
            for _, obj in ipairs(list or {}) do
                local cl = obj.ClassName
                if (cl == "Model" or cl == "Tool") and TrackFruit(obj) then
                    found = found + 1
                end
            end
            print("[FruitScan] Quet sau:", #(list or {}), "doi tuong ->", found, "trai")
            return found
        end

        function ScanWorkspaceForFruits()
            local found = ScanWorkspaceShallow()
            if tick() >= FruitScanNextDeep then
                FruitScanNextDeep = tick() + (tonumber(Config.Settings.FruitDeepScanDelay) or 300)
                found = found + ScanWorkspaceDeep()
            end
            return found
        end

        function PruneFruitWatchRaw()
            for obj in pairs(FruitWatch) do
                if not IsObjAlive(obj) then
                    FruitWatch[obj] = nil
                    FruitSkipUntil[obj] = nil
                    FruitPartCache[obj] = nil
                    if CurrentFruitTarget == obj then
                        CurrentFruitTarget = nil
                    end
                end
            end
        end

        -- CollectDrops.Refresh goi ham NAY moi frame -> chan 1s
        function PruneFruitWatch()
            local nowT = tick()
            if nowT < FruitScanNextPrune then
                return
            end
            FruitScanNextPrune = nowT + 1
            PruneFruitWatchRaw()
        end

        -- "Kilo, Kilo no Mi" / "Kilo Fruit" -> "Kilo Fruit" (de doi chieu balo)
        function NormalizeFruitName(nm)
            nm = tostring(nm)
            if string.find(nm, "Fruit", 1, true) then
                return nm
            end
            local first = string.match(nm, "^([%w%s]+),") or string.match(nm, "^(.-)%s+no%s+Mi") or nm
            first = string.gsub(first, "%s+$", "")
            return first .. " Fruit"
        end

        -- Danh sach trai da co trong balo: chi lam lai moi 2 giay
        function GetOwnedFruitNames()
            local nowT = tick()
            if FruitOwnedCache and (nowT - FruitOwnedCacheTime) < 2 then
                return FruitOwnedCache
            end
            local owned = {}
            pcall(function()
                for id in pairs(ScriptStorage.Backpack or {}) do
                    owned[FruitIdToName(tostring(id))] = true
                end
            end)
            FruitOwnedCache = owned
            FruitOwnedCacheTime = nowT
            return owned
        end

        function FindNearestFruitRaw()
            local best, bestDist
            local now = os.time()
            local ownedNames = GetOwnedFruitNames()
            local hasOwned = false
            for _ in pairs(ownedNames) do
                hasOwned = true
                break
            end

            for obj in pairs(FruitWatch) do
                local blocked = FruitSkipUntil[obj]
                if blocked and blocked <= now then
                    FruitSkipUntil[obj] = nil
                    blocked = nil
                end
                if not blocked then
                    local part = GetFruitPart(obj)
                    if part and not (hasOwned and ownedNames[NormalizeFruitName(obj.Name)]) then
                        local dist = CaculateDistance(part.Position)
                        if dist and dist > 0 and (not bestDist or dist < bestDist) then
                            bestDist = dist
                            best = obj
                        end
                    end
                end
            end
            return best, bestDist
        end

        -- Duoc goi trong CollectDrops.Refresh (moi frame) -> chan lai 0.75s
        function FindNearestFruit()
            local nowT = tick()
            if nowT < FruitScanNextFind then
                return FruitNearestCache
            end
            FruitScanNextFind = nowT + 0.75
            FruitNearestCache = FindNearestFruitRaw()
            return FruitNearestCache
        end

        -- Bat trai moi sinh ra o BAT KI vi tri nao, nhung voi bo loc re tien
        pcall(function()
            workspace.DescendantAdded:Connect(function(obj)
                if not obj then
                    return
                end
                local target = obj
                local cl = target.ClassName
                if cl ~= "Model" and cl ~= "Tool" then
                    -- Part/Sound/Effect... -> chi xem ten CHA, bo qua ngay neu cha khong phai Model/Tool
                    if obj:IsA("BasePart") then
                        target = obj.Parent
                        if not target then
                            return
                        end
                        cl = target.ClassName
                        if cl ~= "Model" and cl ~= "Tool" then
                            return
                        end
                    else
                        return
                    end
                end
                if FruitWatch[target] then
                    return
                end
                if not FruitNameHit(target.Name) and not (cl == "Tool" and target.ToolTip == "Blox Fruit") then
                    return
                end
                TrackFruit(target)
            end)
        end)

        -- Lan dau: in len man hinh de biet game dat ten trai nhu the nao (1 luot duyet, loc re)
        FruitScanDumped = false

        function DumpFruitCandidates()
            local matched = 0
            local namedFruit = 0
            local total = 0

            local okList, list = pcall(function()
                return workspace:GetDescendants()
            end)
            if not okList then
                warn("[FruitDump] GetDescendants loi:", tostring(list))
                return
            end
            total = #(list or {})

            for _, obj in ipairs(list or {}) do
                local cl = obj.ClassName
                if cl == "Model" or cl == "Tool" then
                    local nm = obj.Name
                    if FruitNameHit(nm) then
                        namedFruit = namedFruit + 1
                        if matched < 12 then
                            print(
                                "[FruitDump]", tostring(nm), "| class:", cl, "| cha:",
                                tostring(obj.Parent and obj.Parent.Name), "| part:",
                                tostring(GetFruitPart(obj) and GetFruitPart(obj).Name or "khong co")
                            )
                            matched = matched + 1
                        end
                        TrackFruit(obj)
                    end
                end
            end

            local watching = 0
            for _ in pairs(FruitWatch) do
                watching = watching + 1
            end
            print("[FruitDump] Tong doi tuong:", total, "| trai khop ten:", namedFruit, "| dang theo doi:", watching)
            FruitNotify(
                "FRUIT DUMP",
                string.format("obj: %d | trai khop ten: %d | watch: %d", total, namedFruit, watching)
            )
        end

        -- Liet ke boss that trong map; in it lai de tranh spam log gay nong may
        function DumpBossInfo()
            local lvl = (ScriptStorage.PlayerData and tonumber(ScriptStorage.PlayerData.Level)) or 0
            local enemyCount = 0
            local bossFound = {}

            pcall(function()
                local folder = workspace:FindFirstChild("Enemies")
                if not folder then
                    return
                end
                for _, e in ipairs(folder:GetChildren()) do
                    enemyCount = enemyCount + 1
                    for _, bName in ipairs(BossesOrder or {}) do
                        if e.Name == bName then
                            local hum = e:FindFirstChildOfClass("Humanoid")
                            local hrp = e:FindFirstChild("HumanoidRootPart")
                            local dist = hrp and math.floor(CaculateDistance(hrp.Position)) or -1
                            table.insert(bossFound, string.format("%s hp=%d dist=%d", bName, hum and math.floor(hum.Health) or -1, dist))
                        end
                    end
                end
            end)

            if tick() >= FruitScanNextBossPrint then
                FruitScanNextBossPrint = tick() + 120
                print("[BossScan] Lv:", lvl, "| Enemies:", enemyCount, "| boss trong map:", #bossFound)
                for _, bName in ipairs(BossesOrder or {}) do
                    local req = (BossesOrderLevel and tonumber(BossesOrderLevel[bName])) or 0
                    if req <= lvl then
                        local present = false
                        for _, f in ipairs(bossFound) do
                            if string.find(f, "^" .. bName) then
                                present = true
                            end
                        end
                        print("[BossScan] " .. bName .. " (can lv " .. req .. "): " .. (present and "CO TRONG MAP" or "chua spawn"))
                    end
                end
            end
            return bossFound
        end

        -- vong quet lai dinh ky (nhe: khong con di toan ban do moi luot)
        task.spawn(function()
            task.wait(20)
            while not _G.Stop do
                if not FruitScanDumped then
                    FruitScanDumped = true
                    DumpFruitCandidates()
                end
                local bossFound = DumpBossInfo()
                PruneFruitWatchRaw()
                ScanWorkspaceForFruits()
                if #bossFound > 0 and CurrentTask ~= "BossesTask" then
                    FruitNotify("BOSS SCAN", "Co boss trong map: " .. bossFound[1] .. " | task dang chay: " .. tostring(CurrentTask))
                end
                task.wait(Config.Settings.FruitRescanDelay)
            end
        end)

        FunctionsHandler.CollectDrops:RegisterMethod(
            "Refresh",
            function()
                PruneFruitWatch()
                local now = os.time()

                -- GIU MUC TIEU CU (sticky) de khong bay di bay lai
                if CurrentFruitTarget then
                    if not IsObjAlive(CurrentFruitTarget) then
                        CurrentFruitTarget = nil
                    elseif (now - CurrentFruitTargetTime) >= Config.Settings.FruitReachTimeout then
                        FruitSkipUntil[CurrentFruitTarget] = now + Config.Settings.FruitSkipDuration
                        print("[CollectDrops] Bo qua trai bay qua lau:", tostring(CurrentFruitTarget.Name))
                        CurrentFruitTarget = nil
                    else
                        return CurrentFruitTarget
                    end
                end

                local fruit = FindNearestFruit()
                if fruit then
                    CurrentFruitTarget = fruit
                    CurrentFruitTargetTime = now
                    getgenv().anchored = true
                    return fruit
                end
            end
        )

        FunctionsHandler.CollectDrops:RegisterMethod(
            "Start",
            function(Fruit)
                if not IsObjAlive(Fruit) then
                    CurrentFruitTarget = nil
                    if not FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() then
                        getgenv().anchored = false
                    end
                    return
                end

                local targetCF = nil
                local part = GetFruitPart(Fruit)
                if part then
                    targetCF = part.CFrame
                end
                if not targetCF then
                    pcall(function() targetCF = Fruit:GetModelCFrame() end)
                end

                if targetCF then
                    SetTask("MainTask", "Auto Collect Fruit | " .. tostring(Fruit.Name))
                    SetTask(
                        "SubTask",
                        string.format("Bay toi trai '%s' cach %d stud", tostring(Fruit.Name), math.floor(CaculateDistance(targetCF.Position)))
                    )
                    getgenv().anchored = true
                    TweenController.Create(targetCF)
                else
                    SetTask("SubTask", "Trai " .. tostring(Fruit.Name) .. " khong co part de lay toa do")
                end
            end
        )

        -- ========================================================
        -- [FRUIT GACHA] Quay trai ngau nhien tu xa + tu dong cat vao rương
        -- Bat/tat: Config.Items.FruitGacha
        -- ========================================================
        FruitGachaNextTry = 0

        function FruitNotify(title, text)
            print(">>> [" .. title .. "] " .. tostring(text))
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = title,
                    Text = tostring(text),
                    Duration = 6
                })
            end)
        end

        function StoreAllFruitsToChest()
            local stored = 0
            pcall(function()
                local list = {}
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _, item in ipairs(bp:GetChildren()) do
                        if item:IsA("Tool") and (string.find(item.Name, "Fruit") or string.find(item.Name, "no Mi") or item.ToolTip == "Blox Fruit") then
                            table.insert(list, item)
                        end
                    end
                end
                if LocalPlayer.Character then
                    for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                        if item:IsA("Tool") and (string.find(item.Name, "Fruit") or string.find(item.Name, "no Mi") or item.ToolTip == "Blox Fruit") then
                            table.insert(list, item)
                        end
                    end
                end

                for _, tool in ipairs(list) do
                    local fruitName = tool:GetAttribute("OriginalName") or tool.Name
                    local ok = pcall(function()
                        return Remotes.CommF_:InvokeServer("StoreFruit", fruitName, tool)
                    end)
                    if ok then
                        stored = stored + 1
                        print("[Auto Store] Da cat trai:", tostring(fruitName))
                    end
                    task.wait(0.3)
                end
            end)
            return stored
        end

        -- Doc so Beli hien tai (de do ra bao nhieu tien moi lan quay)
        function GetBeliAmount()
            local amount = 0
            pcall(function()
                local ls = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Leaderstats")
                local stat = ls and (ls:FindFirstChild("Beli") or ls:FindFirstChild("beli"))
                if stat then
                    amount = tonumber(stat.Value) or 0
                end
            end)
            return amount
        end

        function DoFruitGacha()
            -- 1. Dot trai trong balo truoc de tranh xung dot khi trai moi roi ra
            StoreAllFruitsToChest()

            local beliBefore = GetBeliAmount()

            -- 2. Chua du tien thi khoi quay, de im lang cho farm tiep (khong spam remote)
            local cost = tonumber(Config.Items.FruitGachaCost) or 0
            if cost > 0 and beliBefore > 0 and beliBefore < cost then
                print(string.format("[FruitGacha] Chua du Beli: %d < %d -> bo qua lan quay", beliBefore, cost))
                return true, 0, 0, "CHUA DU BELI (" .. beliBefore .. "/" .. cost .. ")", true
            end

            -- 3. Quay: code goc tra ve nil/false VAN la lan quay hop le
            --    nen chi can goi remote khong loi, khong phan dinh qua gia tri tra ve
            local result = nil
            local okCall, callErr = pcall(function()
                result = Remotes.CommF_:InvokeServer("Cousin", "Buy")
            end)
            print("[FruitGacha] Cousin|Buy ->", tostring(result), (okCall and "" or ("LOI: " .. tostring(callErr))))

            -- 4. Neu khong duoc thi thu GachaNetworkRF (dung nhu logic code goc)
            if result == nil then
                pcall(function()
                    local rep = game:GetService("ReplicatedStorage")
                    local mods = rep:FindFirstChild("Modules")
                    local net = mods and mods:FindFirstChild("Net")
                    local rf = net and (net:FindFirstChild("RF/GachaNetworkRF") or net:FindFirstChild("GachaNetworkRF"))
                    if rf then
                        result = rf:InvokeServer({Context = "Purchase", BoxName = Config.Items.FruitGachaBox})
                        print("[FruitGacha] GachaNetworkRF ->", tostring(result))
                    end
                end)
            end

            task.wait(1.5)
            local stored = StoreAllFruitsToChest()
            local beliAfter = GetBeliAmount()
            local spent = math.max(beliBefore - beliAfter, 0)

            print(
                string.format(
                    "[FruitGacha] Beli: %d -> %d (tru %d) | trai cat vao ruong: %d",
                    beliBefore, beliAfter, spent, stored
                )
            )

            -- 5. Lan dau do duoc gia quay -> lu lai de lan sau kiem tra tru
            if spent > 0 and cost <= 0 then
                Config.Items.FruitGachaCost = spent
                print("[FruitGacha] Gia 1 lan quay = " .. spent .. " Beli (da tu ghi vao Config)")
            end

            -- 6. Goi remote thanh cong nhung khong bi tru Beli va khong co trai -> rat co the thieu tien
            local broke = (okCall and spent == 0 and stored == 0 and beliAfter > 0)

            return okCall, spent, stored, tostring(callErr), broke
        end

        task.spawn(function()
            task.wait(15)
            while task.wait(10) do
                if _G.Stop then break end
                if Config.Items.FruitGacha and os.time() >= FruitGachaNextTry then
                    local okWrap, okCall, spent, stored, callErr, broke = pcall(DoFruitGacha)
                    if okWrap and okCall and spent and spent > 0 then
                        -- Quay duoc that (co tru Beli) -> giu nhip 60s nhu code goc
                        FruitGachaNextTry = os.time() + Config.Items.FruitGachaDelay
                        FruitNotify(
                            "FRUIT GACHA",
                            "Da quay trai (het " .. tostring(spent) .. " Beli), lan tiep sau " ..
                                Config.Items.FruitGachaDelay .. "s"
                        )
                    elseif okWrap and okCall and stored and stored > 0 then
                        -- Co trai cat vao ruong thi van tinh la chay binh thuong
                        FruitGachaNextTry = os.time() + Config.Items.FruitGachaDelay
                        FruitNotify("FRUIT GACHA", "Da cat " .. tostring(stored) .. " trai vao ruong")
                    else
                        -- Thieu tien / loi remote -> lui lai, tien van duoc farm binh thuong
                        FruitGachaNextTry = os.time() + Config.Items.FruitGachaFailDelay
                        FruitNotify(
                            "FRUIT GACHA",
                            "[" .. tostring(okWrap and callErr or "LOI") .. "] " ..
                                (broke and "Chua du Beli, bo qua quay" or "Chua quay duoc") ..
                                " | thu lai sau " .. math.floor(Config.Items.FruitGachaFailDelay / 60) .. " phut"
                        )
                    end
                end
            end
        end)


        FunctionsHandler.UtillyItemsActivitation:RegisterMethod(
            "Refresh",
            function()
                if os.time() - StartTime < 20 then
                    return
                end
                if not SpecialItems then
                    SpecialItems = {}
                    local RemoveList = {}
                    IceAdmiralPassed = true

                    if SeaIndex == 2 and Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor") then
                        table.insert(SpecialItems, "Library Key")
                        IceAdmiralPassed = false
                    end

                    if IceAdmiralPassed then
                        table.insert(RemoveList, "Awakened Ice Admiral")
                    end 
                    local Response =
                        not ScriptStorage.Melees["Sharkman Karate"] and
                        Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)
                    SharkmanPassed = typeof(Response) == "string"
                    --   alert("SharkmanPassed", SharkmanPassed)
                    if typeof(Response) == "string" then
                        table.insert(SpecialItems, "Water Key")
                    else
                        TidePassed = true
                        table.insert(RemoveList, "Tide Keeper")
                    end
                    if ScriptStorage.Backpack.Yama then
                        print("Elite")
                        table.insert(RemoveList, "Deandre")
                        table.insert(RemoveList, "Urban")
                        table.insert(RemoveList, "Diablo")
                    end
                    local function GetResult()
                        local Result = {}
                        for _, Value in BossesOrder do
                            local Passed = true
                            for _, Name2 in RemoveList do
                                if Name2 == Value then
                                    Passed = false
                                end
                            end

                            if Passed then
                                table.insert(Result, Value)
                            end
                        end

                        local n = #Result
                        for i = 1, n - 1 do
                            for j = 1, n - i do
                                local a = key and tostring(Result[j][key]):lower() or tostring(Result[j]):lower()
                                local b =
                                    key and tostring(Result[j + 1][key]):lower() or tostring(Result[j + 1]):lower()
                                if a > b then
                                    Result[j], Result[j + 1] = Result[j + 1], Result[j]
                                end
                            end
                        end

                        return Result
                    end
                    BossesOrder = GetResult()
                    if #DropItemData > 0 then 
                    for ItemName, ItemData in DropItemData do
                        if not ScriptStorage.Backpack[ItemName] and SeaIndex == ItemData.Sea then
                            if ScriptStorage.PlayerData.Level >= ItemData.Level then
                                BossesOrderLevel[ItemData.Boss] = ItemData.Level
                                table.insert(BossesOrder, ItemData.Boss)
                            end
                        end
                    end
                end
                    if FunctionsHandler.Trevor:Get("IsCompleted") and not Storage:Get("SwanDefeated") then
                        print("Added Don Swan to boss orser list")
                        BossesOrderLevel["Don Swan"] = 1100
                        table.insert(BossesOrder, "Don Swan")
                        print(ScriptStorage.PlayerData.Level, ScriptStorage.Enemies["Don Swan"])
                        if
                            SeaIndex == 2 and ScriptStorage.PlayerData.Level > 1500 and
                                not ScriptStorage.Enemies["Don Swan"]
                         then
                            print("hop")
                        end
                    end
                end
                for Index, Value in SpecialItems do
                    if ScriptStorage.Tools[Value] then
                        FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", Value)
                        return Value
                    end
                end
                if ScriptStorage.Tools["Red Key"] then
                    FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Red Key")
                    return "Red Key"
                end
                if ScriptStorage.Tools["Hallow Essence"] then
                    FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Soul Reaper Spawner")
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Hallow Essence")
                    return "Soul Reaper Spawner"
                end
                if ScriptStorage.Tools["Fire Essence"] then
                    FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Uzoth")

                    return "Uzoth"
                end
            end
        )

        FunctionsHandler.UtillyItemsActivitation:RegisterMethod(
            "Start",
            function()
                local Type = FunctionsHandler.UtillyItemsActivitation:Get("CurrentProgressLevel")
                if Type == "Hidden Key" then
                    Remotes.CommF_:InvokeServer("OpenRengoku")
                elseif Type == "Water Key" then
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Water Key")
                    Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)
                    Remotes.CommF_:InvokeServer("BuySharkmanKarate")
                elseif Type == "Library Key" then
                    Remotes.CommF_:InvokeServer("OpenLibrary")
                    local PhoeyuDoor = Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor")
                    if PhoeyuDoor then
                        PhoeyuDoor:Destroy()
                    end
                elseif Type == "Red Key" then
                    alert("Red key", "Sumbitting red key to the scienctist.")
                    Remotes.CommF_:InvokeServer("CakeScientist", "Check")
                    if ScriptStorage.Tools["Red Key"] then
                        ScriptStorage.Tools["Red Key"]:Destroy()
                    end
                elseif Type == "Uzoth" then
                    print("Use Fire Essence")
                    Remotes.CommF_:InvokeServer("BuyDragonTalon", true)
                    Remotes.CommF_:InvokeServer("BuyDragonTalon")
                    IsFireEssenceGave = true
                    print("Fire Essence Used")
                elseif Type == "Soul Reaper Spawner" then
                    print("Use Hallow Essence")

                    local HauntedCastle = workspace.Map:FindFirstChild("Haunted Castle")
                    if HauntedCastle and HauntedCastle:FindFirstChild("Summoner") and HauntedCastle.Summoner:FindFirstChild("Detection") then
                        if CaculateDistance(HauntedCastle.Summoner.Detection.CFrame) < 100 then
                            SpecialItems = nil
                        end
                        TweenController.Create(HauntedCastle.Summoner.Detection.CFrame)
                    else
                        print("[Soul Reaper Spawner] Haunted Castle not found or incomplete structure")
                    end
                end
            end
        )

        -- Trevor

        FunctionsHandler.Trevor:RegisterMethod(
            "GetFruit",
            function()
                for _, Fruit in ScriptStorage.Backpack do
                    if string.find(FruitIdToName(Fruit.Name), " Fruit") then
                        if Fruit.Value and Fruit.Value > 1000000 then
                            return Fruit
                        end
                    end
                end
            end
        )

        FunctionsHandler.Trevor:RegisterMethod(
            "Refresh",
            function()
                if FunctionsHandler.Trevor:Get("IsCompleted") or os.time() - StartTime < 1 then
                    return
                end

                if ScriptStorage.PlayerData.Level < 1100 then
                    return
                end

                local Fruit = FunctionsHandler.Trevor.Methods.GetFruit:Call()

                if Fruit then
                    FunctionsHandler.Trevor:Set("Fruit", Fruit)
                end

                TrevorDebounce = os.time()

                if not FunctionsHandler.Trevor:Get("IsCompleted") then
                    print("Update IsCompleted")
                    FunctionsHandler.Trevor:Set("IsCompleted", (Remotes.CommF_:InvokeServer("TalkTrevor", "1") == 0))
                    print(
                        "Update IsCompleted",
                        FunctionsHandler.Trevor:Get("IsCompleted"),
                        Remotes.CommF_:InvokeServer("TalkTrevor", "1"),
                        Remotes.CommF_:InvokeServer("TalkTrevor", "1") == 0
                    )
                end

                return not FunctionsHandler.Trevor:Get("IsCompleted") and Fruit
            end
        )

        FunctionsHandler.Trevor:RegisterMethod(
            "Start",
            function()
                alert("[ Cyndral ]", "Pulling fruit for trevor...")
                local Fruit = FunctionsHandler.Trevor:Get("Fruit")
                FunctionsHandler.Trevor:Set("Fruit", nil)
                if Fruit and not table.find(ScriptStorage.IgnoreStoreFruits, Fruit.Name) then
                    table.insert(ScriptStorage.IgnoreStoreFruits, Fruit.Name)
                end
                
                FunctionsHandler.Trevor:Set("IsLoadingFruit", true)
                
                Remotes.CommF_:InvokeServer("LoadFruit", Fruit.Name)
                task.wait(1) 
                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(FruitIdToName(Fruit.Name))
                task.wait(0.5) 
                FunctionsHandler.Trevor:Set("IsLoadingFruit", false)

                Remotes.CommF_:InvokeServer("TalkTrevor", "1")

                Remotes.CommF_:InvokeServer("TalkTrevor", "2")

                Remotes.CommF_:InvokeServer("TalkTrevor", "3")

                task.wait(1)
                FunctionsHandler.Trevor:Set("IsCompleted", true)
            end
        )

        print(4)
        -- Third Sea Puzzle
        FunctionsHandler.ThirdSeaPuzzle:RegisterMethod(
            "Refresh",
            function()
                if ScriptStorage.PlayerData.Level < 1500 or SeaIndex ~= 2 then
                    return
                end

                if nil == FunctionsHandler.ThirdSeaPuzzle:Get("State") then
                    ZQuestProgress = Remotes.CommF_:InvokeServer("ZQuestProgress", "Check")
                    print("ZQuestProgress", ZQuestProgress)
                    FunctionsHandler.ThirdSeaPuzzle:Set("State", ZQuestProgress == 0)
                end

                return FunctionsHandler.ThirdSeaPuzzle:Get("State")
            end
        )

        FunctionsHandler.ThirdSeaPuzzle:RegisterMethod(
            "Start",
            function()
                local State = FunctionsHandler.ThirdSeaPuzzle:Get("State")

                alert("1093", "start")
                if State then
                    alert("1095", "case test")
                    repeat
                        task.wait(1)
                        alert("1096", "fire")
                        print("StartResponse", Remotes.CommF_:InvokeServer("ZQuestProgress", "Begin"))
                    until CaculateDistance(Vector3.new(0, 0, 0)) > 20000

                    task.spawn(
                        function()
                            alert("1102", "rejoin")
                            task.wait(30)
                            SafeRejoinOrHop("Rejoin")
                       end
                    )

                    alert("attack")
                    while task.wait() do
                        CombatController.Attack("rip_indra")
                    end
                end
            end
        )

        FunctionsHandler.Yama:RegisterMethod(
            "Refresh",
            function()
                if not Config.Items.CursedDualKatana and not Config.Items.Yama then
                    return
                end

                if SeaIndex ~= 3 then
                    return
                end

                if ScriptStorage.Backpack.Yama then
                    return
                end

                if not FunctionsHandler.Yama:Get("EliteCount") then
                    FunctionsHandler.Yama:Set("EliteCount", Remotes.CommF_:InvokeServer("EliteHunter", "Progress"))
                end

                if FunctionsHandler.Yama:Get("EliteCount") >= 30 then
                    return true
                end
            end
        )

        FunctionsHandler.Yama:RegisterMethod(
            "Start",
            function()
                if SeaIndex == 3 then 
                if
                    not workspace.Map:FindFirstChild("Waterfall") then
                         return TweenController.Create(CFrame.new(5251.89990234375, 37.18115234375, 453.6022644042969))
                    else
                        if not workspace.Map.Waterfall:FindFirstChild("SealedKatana") then
                         return TweenController.Create(CFrame.new(5251.89990234375, 37.18115234375, 453.6022644042969))

                        end
                 return                fireclickdetector(workspace.Map.Waterfall.SealedKatana.Hitbox.ClickDetector)

                end
            end
            end
        )

        FunctionsHandler.PirateRaid:RegisterMethod(
            "Refresh",
            function()
                local Senque = FunctionsHandler.PirateRaid:Get("Senque")

                return Senque and os.time() - Senque < 500
            end
        )

        FunctionsHandler.PirateRaid:RegisterMethod(
            "Start",
            function()
                local NearestMon = GetMonAsSortedRange()

                local SeaCastlePosition = Vector3.new(-5543.5327148438, 313.80062866211, -2964.2585449219)

                if NearestMon[1] then
                    local MonHumanoid, MonHumanoidRootPart =
                        NearestMon[1]:FindFirstChild("Humanoid"),
                        NearestMon[1]:FindFirstChild("HumanoidRootPart")

                    if
                        MonHumanoidRootPart and MonHumanoid and MonHumanoid.Health > 0 and
                            CaculateDistance(MonHumanoidRootPart.CFrame, SeaCastlePosition) < 500
                     then
                        CombatController.Attack(NearestMon[1].Name)
                        return
                    end
                end

                TweenController.Create(SeaCastlePosition)
            end
        )

        -- Soul guitar

        function CheckFullMoon()
           
            return Lighting:GetAttribute("MoonPhase") and (Lighting.ClockTime > 18 or Lighting.ClockTime < 5)
        end

        FunctionsHandler.SoulGuitar:RegisterMethod(
            "Refresh",
            function()
                if not Config.Items.SoulGuitar then
                    return
                end

                if ScriptStorage.Backpack["Skull Guitar"] or not ScriptStorage.Backpack["Dark Fragment"] then
                    return
                end

                if ScriptStorage.PlayerData.Level < 2300 then
                    return
                end

                local EctoplasmCount = (ScriptStorage.Backpack["Ectoplasm"] or {Count = 0})["Count"]
                local BonesCount = (ScriptStorage.Backpack["Bones"] or {Count = 0})["Count"]

                if EctoplasmCount < 250 then
                    return 1
                end

                if SeaIndex ~= 3 then
                    return
                end

                SoulGuitarProcess = Remotes.CommF_:InvokeServer("GuitarPuzzleProgress", "Check")

                if not SoulGuitarProcess then
                    Remotes.CommF_:InvokeServer("gravestoneEvent", 2)
                    if not CheckFullMoon() then
                        SetTask("MainTask", "Hopping for full moon ( soul guitar )")
                        -- Hop()
                    end
                    return 7
                end

                if not SoulGuitarProcess.Swamp then
                    return 2
                elseif not SoulGuitarProcess.Gravestones then
                    return 3
                elseif not SoulGuitarProcess.Ghost then
                    return 4
                elseif not SoulGuitarProcess.Trophies then
                    return 5
                elseif not SoulGuitarProcess.Pipes then
                    return 6
                elseif BonesCount >= 500 and not ScriptStorage.Backpack["Skull Guitar"] then
                    return 8
                end
            end
        )

        FunctionsHandler.SoulGuitar:RegisterMethod(
            "Start",
            function(State)
                if State == 7 then
                    while CaculateDistance(CFrame.new(-8654, 140, 6167)) > 5 do
                        task.wait()

                        TweenController.Create(CFrame.new(-8654, 140, 6167))
                    end
                    SoulGuitarProcess = Remotes.CommF_:InvokeServer("gravestoneEvent", 2, true)
                elseif State == 1 then
                    if SeaIndex ~= 2 then
                        SetTask("MainTask", "Teleport to second sea to farm ectoplasm")
                        return Remotes.CommF_:InvokeServer("TravelDressrosa")
                    else
                        SetTask("MainTask", "Farming ectoplasms for soul guitar")
                        CombatController.Attack({"Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer"})
                        return
                    end
                elseif State == 2 then
                    TTL9 = TTL9 or 0
                    if os.time() ~= LastestTime1 then
                        TTL9 = TTL9 + 1
                        LastestTime1 = os.time()
                    end

                    if TTL9 > 60 then
                        return 
                    end

                    local Objects = {}

                    for _, Entity in Services.Workspace.Enemies:GetChildren() do
                        if Entity.name == "Living Zombie" then
                            table.insert(Objects, Entity)
                        end
                    end

                    if #Objects < 6 then
                        SetTask("MainTask", "Soul Guitar task 1 / 5: waiting until entity spawn")
                        TweenController.Create(ScriptStorage.MobRegions["Living Zombie"][1] + Vector3.new(0, 30, 0))
                    else
                        local StartTime19 = os.time()
                        for Idx, Object in Objects do
                            while task.wait() and Object.Humanoid.Health > 7000 do
                                SetTask("MainTask", "Soul Guitar task 1 / 5: Hit mob " .. Idx .. " / 6")
                                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                                if os.time() - StartTime19 > 60 then
                                end

                                TweenController.Create(Object.HumanoidRootPart.CFrame + Vector3.new(0, 50, 0))
                                AttackController:Attack()
                            end
                        end
                        SetTask("MainTask", "Soul Guitar task 1 / 5: Attack")
                        while workspace.Enemies:FindFirstChild("Living Zombie") and task.wait() do
                            if os.time() - StartTime19 > 60 then
                            end

                            CombatController.Attack("Living Zombie")
                        end
                    end
                elseif State == 3 then
                    local HauntedIsland = workspace.Map:FindFirstChild("Haunted Castle")
                    if not HauntedIsland then
                        print("[Soul Guitar] Haunted Castle not found")
                        return
                    end
                    while CaculateDistance(CFrame.new(-8800, 178, 6033)) > 10 do
                        task.wait()
                        SetTask("MainTask", "Soul Guitar task 2 / 5: completing placards")
                        TweenController.Create(CFrame.new(-8800, 178, 6033))
                    end

                    for Placard, Side in {
                        Placard1 = "Right",
                        Placard2 = "Right",
                        Placard3 = "Left",
                        Placard4 = "Right",
                        Placard5 = "Left",
                        Placard6 = "Left",
                        Placard7 = "Left"
                    } do
                        fireclickdetector(HauntedIsland[Placard][Side].ClickDetector)
                    end
                elseif State == 4 then
                    Remotes.CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")
                elseif State == 5 then
                    if CaculateDistance(CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375)) > 30 then
                        TweenController.Create(CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375))
                    else
                        local HauntedCastle = workspace.Map:FindFirstChild("Haunted Castle")
                        if not HauntedCastle or not HauntedCastle:FindFirstChild("Tablet") then
                            print("[Soul Guitar] Haunted Castle or Tablet not found")
                            return
                        end
                        local DepTraiv4 = HauntedCastle.Tablet
                        for i, v in pairs(BlankTablets) do
                            local x = DepTraiv4[v]
                            if x.Line.Rotation.Z ~= 0 then
                                repeat
                                    task.wait()
                                    fireclickdetector(x.ClickDetector)
                                until x.Line.Rotation.Z == 0
                            end
                        end
                        for i, v in pairs(Trophy) do
                            local HauntedCastle = workspace.Map:FindFirstChild("Haunted Castle")
                            if not HauntedCastle or not HauntedCastle:FindFirstChild("Trophies") or not HauntedCastle.Trophies:FindFirstChild("Quest") or not HauntedCastle.Trophies.Quest:FindFirstChild(v) or not HauntedCastle.Trophies.Quest[v]:FindFirstChild("Handle") then
                                print("[Soul Guitar] Trophies structure not found for", v)
                                break
                            end
                            local x = HauntedCastle.Trophies.Quest[v].Handle.CFrame
                            x = tostring(x)
                            x = x:split(", ")[4]
                            local c = "180"
                            if x == "1" or x == "-1" then
                                c = "90"
                            end
                            if not string.find(tostring(DepTraiv4[i].Line.Rotation.Z), c) then
                                repeat
                                    task.wait()
                                    fireclickdetector(DepTraiv4[i].ClickDetector)
                                until string.find(tostring(DepTraiv4[i].Line.Rotation.Z), c)
                            end
                        end
                    end
                elseif State == 6 then
                    local HauntedCastle = workspace.Map:FindFirstChild("Haunted Castle")
                    if not HauntedCastle or not HauntedCastle:FindFirstChild("Lab Puzzle") or not HauntedCastle["Lab Puzzle"]:FindFirstChild("ColorFloor") or not HauntedCastle["Lab Puzzle"].ColorFloor:FindFirstChild("Model") then
                        print("[Soul Guitar] Lab Puzzle structure not found")
                        return
                    end
                    for i, v in pairs(Pipes) do
                        pcall(
                            function()
                                local x = HauntedCastle["Lab Puzzle"].ColorFloor.Model:FindFirstChild(i)
                                if not x then
                                    return
                                end
                                if x.BrickColor.Name ~= v then
                                    repeat
                                        task.wait()
                                        fireclickdetector(x.ClickDetector)
                                    until x.BrickColor.Name == v
                                end
                            end
                        )
                    end
                    Remotes.CommF_:InvokeServer("soulGuitarBuy")
                elseif State == 8 then
                    Remotes.CommF_:InvokeServer("soulGuitarBuy")
                end
            end
        )

        FunctionsHandler.Tushita:RegisterMethod(
            "Refresh",
            function()
                if not Config.Items.CursedDualKatana and not Config.Items.Tushita then
                    return
                end

                if ScriptStorage.Backpack.Tushita then
                    return
                end

                if ScriptStorage.PlayerData.Level < 2000 then
                    return
                end

                if SeaIndex ~= 3 then
                    return
                end

                TushitaProgress = TushitaProgress or Remotes.CommF_:InvokeServer("TushitaProgress")

                if not TushitaProgress.OpenedDoor then
                    if ScriptStorage.Enemies["rip_indra True Form"] then
                        TushitaProgress = nil
                        return 1
                    end
                else
                    if ScriptStorage.Enemies["Longma"] then
                        TushitaProgress = nil
                        return 2
                    end
                end
            end
        )

        FunctionsHandler.Tushita:RegisterMethod(
            "Start",
            function(State)
                if State == 1 then
                    alert("Auto Tushita", "Placing torches...")
                    if not ScriptStorage.Tools["Holy Torch"] then
                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Holy Torch")
                        TweenController.Create(CFrame.new(5714, math.random(19, 21), 256)) -- Portal position
                        return
                    end

                    local TurtleMap = workspace.Map.Turtle.QuestTorches

                    for TorchIndex = 1, 5, 1 do
                        if TurtleMap:FindFirstChild("Torch" .. TorchIndex) then
                            repeat
                                task.wait()
                                TweenController.Create(TurtleMap:FindFirstChild("Torch" .. TorchIndex).CFrame)
                            until TurtleMap:FindFirstChild("Torch" .. TorchIndex).Particles.Main.Enabled
                        end
                    end
                elseif State == 2 then
                    alert("Auto Tushita", "Defeating Longma")
                    CombatController.Attack("Longma")
                end
            end
        )


        local Hooks = {
            Listeners = {}
        }

        TorchEnabledTime = 0
        DoneCdkTick = 0

        getgenv().NotificationCallBack = (function(Content)
            for ListenerContent, Callback in Hooks.Listeners do
                if string.find(string.lower(Content), string.lower(ListenerContent)) then
                    Callback(Content)
                end
            end
        end)

        function Hooks:RegisterNotifyListener(Senque, Callback)
            Hooks.Listeners[Senque] = Callback
        end

        Hooks:RegisterNotifyListener(
            "go!",
            function()
                LastRaidAlert = os.time()
            end
        )
        Hooks:RegisterNotifyListener(
            "oadi",
            function()
                LastRaidAlert2 = os.time()
            end
        )

        Hooks:RegisterNotifyListener(
            "been spotted approaching",
            function()
                FunctionsHandler.PirateRaid:Set("Senque", os.time())
            end
        )

        Hooks:RegisterNotifyListener(
            "job",
            function()
                FunctionsHandler.PirateRaid:Set("Senque", 0)
            end
        )

        Hooks:RegisterNotifyListener(
            "level",
            function()
                AddPoint()
            end
        )

        Hooks:RegisterNotifyListener(
            "torch",
            function()
                TorchEnabledTime = os.time()
            end
        )

        Hooks:RegisterNotifyListener(
            "scroll reacts",
            function()
                DoneCdkTick = os.time()
            end
        )

        Hooks:RegisterNotifyListener(
            "elite",
            function()
                FunctionsHandler.Yama:Set("EliteCount", Remotes.CommF_:InvokeServer("EliteHunter", "Progress"))

                alert(
                    "[ Bocchi Hub ] ",
                    "Elite defeated: " .. tostring(FunctionsHandler.Yama:Get("EliteCount") or "n/a")
                )
            end
        )

        Hooks:RegisterNotifyListener(
            "the raid with",
            function()
                if ScriptStorage.PlayerData.Level < MaxLevel then
                    return
                end
                Remotes.CommF_:InvokeServer("Awakener", "Awaken")
            end
        )

        Hooks:RegisterNotifyListener(
            "quest completed",
            function()
                QuestManager:RefreshQuest()
                task.wait()
                if not QuestManager:GetCurrentClaimQuest() then
                    QuestManager:MarkAsCompleted()
                end
            end
        )

        pcall(function()
            if typeof(hookfunction) == "function" and typeof(newcclosure) == "function" then
                local notifModule = game.ReplicatedStorage:FindFirstChild("Notification")
                if notifModule then
                    local notif = safe_require(notifModule, 1)
                    if notif and notif.new then
                        local old
                        old = hookfunction(notif.new, newcclosure(function(a, b)
                            v21 = tostring(tostring(a or "") .. tostring(b or "")) or ""
                            if typeof(getgenv().NotificationCallBack) == "function" then
                                getgenv().NotificationCallBack(v21)
                            end
                            return {
                                Display = function() end  
                            }
                        end))
                    end
                end
            end
        end)

     
        if SeaIndex ~= 1 then
        end

        function IfTableHaveIndex(j)
            for _ in j do
                return true
            end
        end
        print(1)
        function GetServers()
            if LastServersDataPulled then
                if os.time() - LastServersDataPulled < 60 then
                    return CachedServers or {}
                end
            end

            local browser = game:GetService("ReplicatedStorage"):FindFirstChild("__ServerBrowser") or game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser", 3)
            if not browser then return CachedServers or {} end

            for i = 1, 100, 1 do
                local ok, data = pcall(function() return browser:InvokeServer(i) end)
                if ok and IfTableHaveIndex(data) then
                    LastServersDataPulled = os.time()
                    CachedServers = data
                    return data
                end
            end
            return CachedServers or {}
        end

        spawn(
            function()
                pcall(GetServers)
                while task.wait(180) do
                    pcall(GetServers)
                end
            end
        )

        function Hop(Reason, MaxPlayers, ForcedRegion)
            local Servers = GetServers() or {}
            local ArrayServers = {}

            for i, v in pairs(Servers) do
                table.insert(
                    ArrayServers,
                    {
                        JobId = i,
                        Players = v.Count,
                        LastUpdate = v.__LastUpdate,
                        Region = v.Region
                    }
                )
            end
            print(#ArrayServers, "servers received")

            for i = 1, #ArrayServers do
                while task.wait() do
                    local Index = math.random(1, #ArrayServers)
                    ServerData = ArrayServers[Index]
                    if ServerData then
                        if not MaxPlayers or ServerData.Players < MaxPlayers then
                            if not ForcedRegion or ServerData.Region == ForcedRegion then
                                print(
                                    "Found Server:",
                                    ServerData.JobId,
                                    "Player Count:",
                                    ServerData.Players,
                                    "Region:",
                                    ServerData.Region
                                )
                                break
                            end
                        end
                    end
                end

                print("Teleporting to", ServerData.JobId, "...")
                pcall(function()
                    local browser = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser", 5)
                    if browser then
                        browser:InvokeServer("teleport", ServerData.JobId)
                    end
                end)
            end
        end
        

        LowHop = function(Reason, PlayerLimit)
            local servers = {}
            local Limit = PlayerLimit or 5
            local req =
                game:HttpGet(
                "https://games.roblox.com/v1/games/" ..
                    game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
            )
            local body = game:GetService("HttpService"):JSONDecode(req)
        
            if body and body.data then
                for i, v in next, body.data do
                    if
                        type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < Limit and
                            v.id ~= JobId
                     then
                        table.insert(servers, 1, v.id)
                    end
                end
            end
        
            if #servers > 0 then
                local targetServer = servers[math.random(1, #servers)]
                local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("__ServerBrowser")
                if Remote then
                    local success, err = pcall(function()
                        return Remote:InvokeServer("teleport", targetServer)
                    end)
                    if not success or err == false then
                        return alert("Serverhop", "Couldn't find a server.")
                    end
                -- Đã xóa bỏ phần else chứa code TeleportService ở đây
                else
                    return alert("Serverhop", "Couldn't teleport (No Remote found).")
                end
            else
                return alert("Serverhop", "Couldn't find a server.")
            end
        end



        Storage = {
            WRITE_DELAY = .5,
            Data = {}
        }

        Services = {}

        setmetatable(
            Services,
            {
                __index = function(_, Index)
                    return game:GetService(Index)
                end
            }
        )

        LocalPlayer = game.Players.LocalPlayer

        local StoragePath = ".storage_u_" .. tostring(LocalPlayer)

        function Decode(Content)
            return Services.HttpService:JSONDecode(Content)
        end

        function Encode(Content)
            return Services.HttpService:JSONEncode(Content)
        end

        print(5)
        function Storage.Set(Self, Key, Value)
            Self.Data[Key] = Value
        end

        function Storage.Get(Self, Key)
            --Report("Get: " .. tostring(Key or "n/a") .. " Value: " .. tostring(Self.Data[Key] or "n/") )
            return Self.Data[Key]
        end

        function Storage.Save(Self)
            pcall(function()
                if typeof(writefile) == "function" then
                    writefile(StoragePath, Encode(Self.Data))
                end
            end)
        end

        pcall(function()
            if typeof(isfile) == "function" and typeof(writefile) == "function" then
                if not isfile(StoragePath) then
                    writefile(StoragePath, "{}")
                    task.wait(0.5)
                end
            end
        end)

        Storage.Data = {}

        pcall(
            function()
                if typeof(readfile) == "function" and (typeof(isfile) ~= "function" or isfile(StoragePath)) then
                    Storage.Data = Decode(readfile(StoragePath) or "{}")
                end
            end
        )

        spawn(
            function()
                while task.wait(Storage.WRITE_DELAY) do
                    Storage:Save()
                end
            end
        )
        CreateTraceback("Initalize", "Initalizing script...")
        pcall(function()
            if typeof(getconnections) == "function" then
                local lp = game:GetService("Players").LocalPlayer
                local fastModeBtn = lp and lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("SettingsMenu") and lp.PlayerGui.Main.SettingsMenu:FindFirstChild("Content") and lp.PlayerGui.Main.SettingsMenu.Content:FindFirstChild("ScrollingFrame") and lp.PlayerGui.Main.SettingsMenu.Content.ScrollingFrame:FindFirstChild("FastMode") and lp.PlayerGui.Main.SettingsMenu.Content.ScrollingFrame.FastMode:FindFirstChild("FirstButton")
                if fastModeBtn and fastModeBtn:FindFirstChild("Activated") then
                    for _, Connection in getconnections(fastModeBtn.Activated) do
                        pcall(Connection.Function)
                    end
                end
            end
        end)
      
        function boostfps()
            local Terrain = workspace:FindFirstChildOfClass('Terrain')
            local ReplicatedStorage = game.ReplicatedStorage
            local Players = game.Players
            local Player = Players.LocalPlayer
            local RunService = game:GetService("RunService")
            local Lighting = game:GetService("Lighting")

            -- Tắt nước
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end

            -- Xóa map không cần thiết để tăng FPS
            pcall(function()
                -- Xóa clouds trong workspace
                for _, v in ipairs(workspace:GetChildren()) do
                    if v.Name == "Clouds" or v.Name == "Cloud" then
                        pcall(function() v:Destroy() end)
                    end
                end

                -- Xóa skybox/decoration trong lighting
                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("Sky") or v:IsA("Decal") then
                        pcall(function() v:Destroy() end)
                    end
                end

                -- Xóa map decorations (part nằm trong Map folder)
                local Map = workspace:FindFirstChild("Map")
                if Map then
                    for _, v in ipairs(Map:GetChildren()) do
                        local name = v.Name:lower()
                        if name:find("tree") or name:find("plant") or name:find("rock") or
                           name:find("fence") or name:find("decoration") or name:find("grass") or
                           name:find("bush") or name:find("flower") or name:find("sign") then
                            pcall(function() v:Destroy() end)
                        end
                    end
                end

                -- Xóa spawn location effects
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Sound") then
                        pcall(function() v:Destroy() end)
                    end
                end
            end)

            -- Tắt lighting
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9

            -- Giảm quality level
            pcall(function()
                settings().Rendering.QualityLevel = 1
            end)

            -- Xóa lighting children
            pcall(function()
                Lighting:ClearAllChildren()
            end)

            -- Xóa effect particles cho non-character parts
            pcall(function()
                for _, v in ipairs(game:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        pcall(function() v.Lifetime = NumberRange.new(0) end)
                    elseif v:IsA("AnimationController") then
                        pcall(function() v:Destroy() end)
                    end
                end
            end)

            -- Xử lý existing characters
            for _, player1 in pairs(Players:GetChildren()) do
                if player1.Character then
                    task.spawn(function()
                        task.wait(0.5)
                        for _, part in pairs(player1.Character:GetChildren()) do
                            if part:IsA("Accessory") or part.Name == "Radio" then
                                pcall(function() part:Destroy() end)
                            end
                        end
                    end)
                end
                player1.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("Accessory") or part.Name == "Radio" then
                            pcall(function() part:Destroy() end)
                        end
                    end
                end)
            end

            -- Bug 1 FIX: Chỉ destroy thứ KHÔNG phải Model/Folder trong _WorldOrigin
            workspace._WorldOrigin.ChildAdded:Connect(function(child)
                pcall(function()
                    if not child:IsA("Model") and not child:IsA("Folder") then
                        child:Destroy()
                    end
                end)
            end)

            -- Xóa cache folder trong ReplicatedStorage
            pcall(function()
                local candelete = {"Cache", "Cache2"}
                for _, v in ipairs(ReplicatedStorage:GetChildren()) do
                    if table.find(candelete, v.Name) then
                        pcall(function() v:Destroy() end)
                    end
                end
            end)

            -- Camera và Terrain child cleanup
            workspace.Camera.ChildAdded:Connect(function(child)
                pcall(function() child:Destroy() end)
            end)

            if Terrain then
                Terrain.ChildAdded:Connect(function(child)
                    pcall(function() child:Destroy() end)
                end)
            end

            -- Bug 3 FIX: Thêm pcall cho DescendantAdded, bỏ qua character
            workspace.DescendantAdded:Connect(function(child)
                task.spawn(function()
                    pcall(function()
                        -- Chỉ xử lý effect, KHÔNG transparent player character
                        if child:IsA("ForceField") or child:IsA("Sparkles") or
                           child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                            child:Destroy()
                            return
                        end

                        -- Bỏ qua character parts của player
                        local char = Player.Character
                        if char and (child:IsDescendantOf(char) or child == char) then
                            return
                        end

                        if child:IsA("BasePart") then
                            child.Material = "Plastic"
                            child.Reflectance = 0
                            child.BackSurface = "SmoothNoOutlines"
                            child.BottomSurface = "SmoothNoOutlines"
                            child.FrontSurface = "SmoothNoOutlines"
                            child.LeftSurface = "SmoothNoOutlines"
                            child.RightSurface = "SmoothNoOutlines"
                            child.TopSurface = "SmoothNoOutlines"
                            child.Transparency = 1
                            child.CastShadow = false
                        elseif child:IsA("Decal") then
                            child.Transparency = 1
                        elseif child:IsA("AnimationController") then
                            child:Destroy()
                        end
                    end)
                end)
            end)
        end  
        if Config and Config.Configuration and Config.Configuration.FpsBoost then
            pcall(boostfps)
        end
        local loadedTimeout = tick() + 5
        repeat task.wait(0.2) until game:IsLoaded() or tick() > loadedTimeout 
        spawn(function()
            while wait() do 
                    pcall(function()
                        repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local old = tick()

                    local oldpos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position 
                    repeat wait() 
                    until tick() - old >= 5*60 or oldpos ~= game.Players.LocalPlayer.Character.HumanoidRootPart.Position 
                    if tick() - old >= 5*60 then 
                        Hop("Stuck start Rejoin")
                    end
                end)

            end
        end)
        
        local LogCache = {}
        SetTask("MainTask", "n/a")
        SetTask("SubTask", "n/a")
        ParsingTimes = 0 
        function RefreshTasksData()
            if _G.Stop then
                return
            end
            for _, TaskName in TasksOrder do
                local Task = FunctionsHandler[TaskName]
                if Task then
                    if not Task.Initalized then
                        if not LogCache[TaskName] then
                            print("[ Debug ] Task", TaskName, "is not registered yet")
                            LogCache[TaskName] = true
                        end
                    else
                        local Refresh = Task.Methods and Task.Methods.Refresh
                        local Start = Task.Methods and Task.Methods.Start

                        if Refresh then
                            local ok, RefreshValue = pcall(function()
                                return Refresh:Call(ParsingTimes < 100)
                            end)

                            ParsingTimes = ParsingTimes + 1
                            if ok and RefreshValue then
                                CurrentTask = TaskName
                                if ScriptStorage.Interface and type(ScriptStorage.Interface.SetText) == "function" then
                                    pcall(function() ScriptStorage.Interface.SetText("DebugLine", TaskName) end)
                                end
                                if Start then
                                    pcall(function() Start:Call(RefreshValue) end)
                                end
                                return
                            end
                        end
                    end
                end
            end

            -- Khong task nao duoc chon vong nay -> de CurrentTask = nil,
            -- neu khong cac cho kiem tra (CurrentTask == "...") se dinh mai o task cu
            CurrentTask = nil
        end

        SetText("MainTextLabel", "Refreshing Player Items...")
        pcall(RefreshPlayerData)
        pcall(AddPoint)
        pcall(function() QuestManager:RefreshQuest() end)
        SetText("MainTextLabel", "Loading Inventory...")
        pcall(RefreshInventory)
        SetText("MainTextLabel", "Loading Race...")
        pcall(RefreshRace)
        pcall(function()
            if Remotes and Remotes.CommE and Remotes.CommE.OnClientEvent then
                Remotes.CommE.OnClientEvent:Connect(
                    function(...)
                        local data = {...}
                        if data and data[1] and string.find(tostring(data[1]), "Item") then
                            pcall(RefreshInventory)
                        end
                    end
                )
            end
        end)

        pcall(RefreshRace)

        pcall(function()
            if Players and Players.LocalPlayer and Players.LocalPlayer.Idled then
                Players.LocalPlayer.Idled:Connect(
                    function()
                        pcall(function()
                            if Services and Services.VirtualUser then
                                Services.VirtualUser:CaptureController()
                                Services.VirtualUser:ClickButton2(Vector2.new())
                            end
                        end)
                    end
                )
            end
        end)

        SetText("MainTextLabel", "Loaded In " .. math.floor(tick() - StartTick) .. "ms!")
        Loaded = 1
        QueueList = {}


        function NearbyHopHandler()
        -- Debounce: chỉ cho chạy 1 lần mỗi 10s
            local now = os.time()
            if NearbyHopHandlerDebounce and now - NearbyHopHandlerDebounce < 10 then
                return
            end
            NearbyHopHandlerDebounce = now
        
            -- Kiểm tra xem có đang đánh boss không
            local mainTask = ScriptStorage.Task.MainTask
            if type(mainTask) == "string" and (string.find(mainTask, "Auto Farm Boss") or string.find(mainTask, "Defeating Cake Prince")) then
                -- Đang đánh boss → không hop
                return
            end
        
            local localPlayer = Players.LocalPlayer
        
            for _, player in ipairs(Players:GetPlayers()) do
                -- Bỏ qua chính mình
                if player ~= localPlayer then
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local position = hrp.Position
        
                        local firstSeenTime = QueueList[player.Name]
                        if not firstSeenTime then
                            -- Lần đầu phát hiện player này
                            QueueList[player.Name] = now
                        else
                            -- Nếu đã thấy > 30s thì mới kiểm tra khoảng cách
                            if now - firstSeenTime > 30 then
                                if CaculateDistance(position) < 100 then
                                    -- Có player đứng gần quá 100 studs trong > 30s → hop
                                    LowHop("Nearby plr")
                                    task.wait(5)
                                    return -- hop rồi thì khỏi xử lý tiếp
                                else
                                    -- Không còn gần nữa → xoá khỏi queue
                                    QueueList[player.Name] = nil
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Chạy NearbyHopHandler định kỳ nếu người dùng chủ động bật AutoHop
        task.spawn(function()
            while task.wait(5) do
                if not _G.Stop and Config and Config.Configuration and Config.Configuration.AutoHop then
                    pcall(NearbyHopHandler)
                end
            end
        end)
        
        pcall(function()
            if ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level and ScriptStorage.PlayerData.Level > 2000 then 
                if Remotes and Remotes.CommF_ then
                    Remotes.CommF_:InvokeServer("BuyHaki", "Geppo")
                    Remotes.CommF_:InvokeServer("BuyHaki", "Buso")
                    Remotes.CommF_:InvokeServer("BuyHaki", "Soru")
                    Remotes.CommF_:InvokeServer("KenTalk", "Buy") 
                end
            end
        end)
        
        function getcandies()
            local count = 0
            pcall(function()
                if Remotes and Remotes.CommF_ then
                    local inv = Remotes.CommF_:InvokeServer("getInventory")
                    if type(inv) == "table" then
                        for _, v in pairs(inv) do
                            if v and v.Name == "Candy" then 
                                count = v.Count or 0
                                break
                            end
                        end
                    end
                end
            end)
            return count
        end
        -- Optimized refresh loop with delay to reduce FPS impact
        task.spawn(
            function()
                while task.wait(1) do  -- Changed from task.wait() to task.wait(1) to reduce FPS impact
                    if not _G.Stop then
                        
                        if LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Sit then
                            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end

                        if true or RefreshDebounce ~= os.time() then
                            pcall(RefreshPlayerData)
                            local Elapsed = os.time() - StartTime
                            local TotalElapsed = Elapsed + OldSessionTime

                            writefile(".tdif-" .. game.Players.LocalPlayer.Name, tostring(TotalElapsed))

                            if ScriptStorage.Interface then
                                SetText(
                                    "LiveTime",
                                    "Total Elapsed Time: " ..
                                        DispTime(TotalElapsed, true) .. " Elapsed Time: " .. DispTime(Elapsed, true)
                                )
                            end
                            RefreshDebounce = os.time()
                        end
                    end
                end
            end
            
        )

        -- Cấu hình thời gian
        local CHECK_INTERVAL = 60 -- Kiểm tra mỗi 1 phút để đảm bảo không lỡ nhịp
        local lastBuy = 0

        task.spawn(function()
            while true do
                pcall(function()
                    -- 1. Kiểm tra sự tồn tại của Remotes
                    if Remotes and Remotes.CommF_ then
                        
                        -- 2. Gọi hàm cộng điểm (nếu có)
                        if type(AddPoint) == "function" then
                            AddPoint()
                        end

                        -- 3. Thực hiện mua trái ác quỷ
                        -- Blox Fruits trả về thông tin thời gian nếu chưa đủ 2 tiếng
                        local result = Remotes.CommF_:InvokeServer("Cousin", "Buy")
                        
                        if result then
                            print("[Random Fruit] Kết quả: ", tostring(result))
                            
                            -- Nếu mua thành công hoặc thông báo liên quan đến thời gian
                            -- Bạn có thể thêm logic cất trái ác quỷ vào kho ở đây
                            if string.find(tostring(result), "Unboxed") or string.find(tostring(result), "Eat") then
                                print("success: " .. tostring(result))
                            end
                        end
                    else
                        warn("error: " .. tostring(result))
                    end
                end)
                
                task.wait(CHECK_INTERVAL)
            end
        end)

       
        while task.wait() do
            --[[
            if not SendDataDelay or os.time() - SendDataDelay > Config.Authorize.SendDelay then 
                SendDataDelay = os.time() 
                pcall(SendData)
            end ]]
            local success, response = pcall(RefreshTasksData)
            -- Chi chay MeleesController khi KHONG dang trong raid, KHONG lam Saber,
            -- va KHONG co task khong dang dieu khien chuyen dong (bay di mua vo se
            -- cat ngang cuoc bay di nhat trai / danh boss)
            local IsInRaid = FunctionsHandler.RaidController and FunctionsHandler.RaidController:Get("IsInRaidProcess")
            local isSaberOngoing = (type(IsSaberQuestActive) == "function" and IsSaberQuestActive()) or (CurrentTask == "Saber")
            local meleeAllowed =
                CurrentTask == nil or CurrentTask == "MeleesController" or CurrentTask == "LevelFarm"
            if not IsInRaid and not isSaberOngoing and meleeAllowed then
                pcall(function()
                    if FunctionsHandler.MeleesController and FunctionsHandler.MeleesController.Methods and FunctionsHandler.MeleesController.Methods.Start then
                        FunctionsHandler.MeleesController.Methods.Start:Call()
                    end
                end)
            end
            if not success and response then
                pcall(function() Report(response) end)
            end
        end

    end
    -- Remote kunblox script removed
        
    print("[Bocchi Hub] Starting mmb main function...")
    local success2, response2 = xpcall(mmb, debug.traceback)
    if not success2 then
        pcall(function() print("[Bocchi Hub CRASH]", tostring(response2)) end)
        Report(response2)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Bocchi Hub Error",
                Text = tostring(response2):sub(1, 100),
                Duration = 10
            })
        end)
    else
        print("[Bocchi Hub] Finished or exited.")
    end
