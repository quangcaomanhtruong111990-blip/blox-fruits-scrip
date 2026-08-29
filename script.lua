local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local data = player:WaitForChild("Data", 20)
if not data then return end

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 20)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 20)

local Modules = ReplicatedStorage:WaitForChild("Modules", 20)
local Net = Modules and Modules:WaitForChild("Net", 20)
local RegisterAttack = Net and (Net:FindFirstChild("RE/RegisterAttack") or Net:FindFirstChild("RegisterAttack"))
local RegisterHit = Net and (Net:FindFirstChild("RE/RegisterHit") or Net:FindFirstChild("RegisterHit"))

-- Anti AFK
pcall(function()
    if getconnections then
        for _, conn in pairs(getconnections(player.Idled)) do
            if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
        end
    end
end)

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
end)

-- Hệ thống Noclip
local noclipConnection = nil
local function setNoclip(enabled)
    if enabled then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

local CHOOSE_TEAM = "Pirates"
local isScriptEnabled = true
local isTweening = false
local currentTween = nil
local lastStatUpdate = 0
local lastAttackTime = 0
local isDoingGacha = false
local activeQuest = nil

local gachaTargetPos = Vector3.new(-1441.9, 61.9, 3.1)
local TARGET_MASTERY = 200
local FLY_SPEED_LONG = 110
local FLY_SPEED_SHORT = 85

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
                                                game.Players.LocalPlayer:Kick("Rejoining...")
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
                        -- warn(RemoteAction, IsValidate,string.gsub(RemoteAction, "Buy", ''))
                        -- if string.find(RemoteAction, "Buy") == 1 then 
                        --     warn(string.gsub(RemoteAction, "Buy", '')) 
                        -- end
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
                        -- FIX Bug #4: Try to get value from Value property first, then fall back to Attribute
                        local val = nil
                        if ChildInstance:IsA("IntValue") or ChildInstance:IsA("NumberValue") then
                            val = ChildInstance.Value
                        elseif ChildInstance:IsA("StringValue") then
                            val = ChildInstance.Value
                        elseif ChildInstance:IsA("BoolValue") then
                            val = ChildInstance.Value
                        end
                        -- If Value is nil/0 but Fragments attribute exists, use attribute
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
    --    if ScriptStorage.PlayerData.Level >= 1500 and (SeaIndex == 2) then
                               
    --         elseif ScriptStorage.PlayerData.Level >= 700 and (SeaIndex == 1 ) then
    --                            print("B")
    --                             game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
    --                     end   
        
    
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

            --print(Self.CurrentQuests[QuestIndex], Self.CurrentQuests[QuestIndex].NameMon)

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
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
        end
        
        -- TweenController
        
        function TweenController.Create(Position)
            -- 1. KIỂM TRA CƠ BẢN
            local Character = game.Players.LocalPlayer.Character
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
            if not Position or TweenDebounce or TweenController._isCreating then return end
        
            -- Chuyển đổi Position sang CFrame nếu cần
            local TargetCFrame = typeof(Position) ~= "CFrame" and CFrame.new(Position) or Position
            -- Chỉ giữ lại tọa độ Position, loại bỏ Rotation để tránh xoay người ảo
            TargetCFrame = CFrame.new(TargetCFrame.Position)
        
            local RootPart = Character.HumanoidRootPart
            local CurrentDist = (RootPart.Position - TargetCFrame.Position).Magnitude
        
            -- 2. CHỐNG GIẬT (Smarter Check)
            -- Nếu đang có Tween chạy và mục tiêu mới quá gần mục tiêu cũ, hoặc nhân vật đã gần đích -> Bỏ qua
            if TweenInstance and TweenInstance.PlaybackState == Enum.PlaybackState.Playing then
                if CurrentDist < 5 then return end -- Đã đủ gần, không cần tạo thêm
            end
        
            TweenController._isCreating = true
        
            -- 3. XỬ LÝ NOCLIP (Mượt hơn)
            pcall(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        
            -- 4. GIỮ NHÂN VẬT TRÊN KHÔNG (BodyVelocity)
            local head = Character:FindFirstChild("Head")
            if head and not head:FindFirstChild("eltrul") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "eltrul"
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                bv.Velocity = Vector3.zero
                bv.Parent = head
            end
        
            -- 5. LOGIC DI CHUYỂN ĐẶC BIỆT (Sea 3 Submarine / Portals)
            if CurrentDist > 500 then
                if SeaIndex ~= 3 then
                    GetPortal(TargetCFrame)
                end
            end
        
            -- Kiểm tra di chuyển sang Submerged Island (Sea 3)
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
        
            -- 6. THỰC THI TWEEN
            -- Hủy Tween cũ trước khi tạo mới
            if TweenInstance then
                TweenInstance:Cancel()
            end
        
            -- Tính toán tốc độ: Nếu gần thì đi chậm (25), nếu xa thì đi nhanh (330)
            local Speed = (CurrentDist < 18) and 25 or 330
            local Time = CurrentDist / Speed
        
            TweenInstance = Services.TweenService:Create(
                RootPart,
                TweenInfo.new(Time, Enum.EasingStyle.Linear),
                {CFrame = TargetCFrame}
            )
            
            TweenInstance:Play()
        
            -- Reset flag sau một khoảng thời gian ngắn để tránh spam
            task.delay(0.1, function()
                TweenController._isCreating = false
            end)
        end



        local AttackController = {}
        function BuyMelee(M1, Check, NPCName)
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

        -- Optimized FastAttack loop with Volt Actor support
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

        CombatController = {
            GRAB = true,
            GRAB_DISTANCE = SeaIndex == 1 and 250 or 350,
            MAX_ATTACK_DURATION = 3,
            MAX_ATTACK_DURATION_2 = 60,
            LEVITATE_TIME = 1,
            CurrentIndex = 1
        }
        
        LastFound = os.time()
        -- save center pos vao attribute cua con mob r set de cho do bi move idk

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
                    if --not Mon:GetAttribute("IsGrabbedreci") and
                        Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and
                            Mon.Humanoid.Health > 0 then
                        local MonPosition = Mon.HumanoidRootPart.Position
                        --print("isnetworkowner", isnetworkowner(Mon.PrimaryPart))
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
            -- Cache GuideModule env để tránh gọi getsenv nhiều lần
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
                    -- Optimize: Add delay to reduce FPS impact
                    while task.wait(0.1) do
                        if _G.Stop then
                            return
                        end

                        -- Cache lại InCombat mỗi lần loop để kiểm tra trạng thái combat
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
                        Report("[ Game data error ] Mob with name " .. tostring(Child) .. " have no spawn region datas")
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
                --Report("Typeof: " .. typeof(Storage))

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
                -- Don't run LevelFarm if currently in raid process
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
                    
                -- Don't buy bones if currently in raid process
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
                                Report("NPC HauntedQuest2 not found")
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
                            Report("NPC HauntedQuest2 not found")
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
                            return QuestManager:RefreshQuest() and Report("failed to get npc position quest 528")
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
                    if LevelFarmTTL > 160 then
                    -- Hop("Level TTL is bigger than 160, hop")
                    end
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

        FunctionsHandler.Saber:RegisterMethod(
            "Refresh",
            function()
                if not Config.Items.Saber then
                    return
                end

                if not Config.Items.Saber then
                    return
                end
                if SeaIndex ~= 1 then
                    return
                end

                local Result
                if ScriptStorage.Backpack.Saber then
                    return
                end

                if ScriptStorage.PlayerData.Level < 200 then
                    return
                end

                local Tasks = Remotes.CommF_:InvokeServer("ProQuestProgress")
                for _, Value in Tasks.Plates do
                    if Value == false then
                        Result = 1
                    end
                end

                if not Result then
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
                    elseif not Tasks.KilledShanks and ScriptStorage.Enemies["Saber Expert"] then
                        Result = 7
                    end
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

                if CachedData then
                    return CachedData
                end

                local Jungle = Services.Workspace.Map.Jungle
                local Result = {}

                table.foreach(
                    Jungle.QuestPlates:GetChildren(),
                    function(_, Inst)
                        _ = Inst:FindFirstChild("Button") and table.insert(Result, Inst)
                    end
                )

                FunctionsHandler.Saber:Get("QuestplatesCache", Result)

                return Result
            end
        )

        FunctionsHandler.Saber:RegisterMethod(
            "Start",
            function()
                local Progress, LastestRefreshSenque =
                    FunctionsHandler.Saber:Get("CurrentProgressLevel"),
                    FunctionsHandler.Saber:Get("LastestRefreshSenque")

                print("[ Debug ] Saber quest indexes", Progress)
                if not Progress then
                    FunctionsHandler.Saber.Methods.Refresh:Call()
                    return FunctionsHandler.Saber.Methods.Start:Call()
                elseif Progress == 0 then
                elseif os.time() - LastestRefreshSenque > 60 then
                    FunctionsHandler.Saber.Methods.Refresh:Call()

                    return FunctionsHandler.Saber.Methods.Start:Call()
                else
                    if Progress == 1 then
                        local Questplates = FunctionsHandler.Saber.Methods.GetQuestplates:Call()

                        for Index, Questplate in Questplates do
                            SetTask("MainTask", "Saber Quest | Quest Plates | Touching " .. Index .. "/5")
                            -- Safety check: Ensure Questplate and Button exist before loop
                            if Questplate and Questplate:FindFirstChild("Button") then
                                local LoopStartTime = os.time()
                                local MaxLoopDuration = 60  -- 1 minute max
                                while CaculateDistance(Questplate.Button.CFrame) > 20 do
                                    -- Timeout check to prevent infinite loop
                                    if os.time() - LoopStartTime > MaxLoopDuration then
                                        print("[Saber Quest] Loop timeout, breaking")
                                        break
                                    end
                                    
                                    -- Re-check Questplate exists
                                    if not Questplate or not Questplate:FindFirstChild("Button") then
                                        break
                                    end
                                    
                                    task.wait(0.5)  -- Added delay to reduce FPS impact
                                    TweenController.Create(Questplate.Button.CFrame)
                                end
                            else
                                print("[Saber Quest] Questplate.Button not found")
                            end
                            task.wait(1)
                        end
                    elseif Progress == 2 then
                        SetTask("MainTask", "Saber Quest | Torch Puzzle | Using Torch")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "GetTorch")
                        task.wait(1)
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "DestroyTorch")
                    elseif Progress == 3 then
                        SetTask("MainTask", "Saber Quest | Sick Man | Helping with Cup")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "GetCup")

                        if ScriptStorage.Tools.Cup then
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Cup")
                            task.wait(1)
                            Remotes.CommF_:InvokeServer("ProQuestProgress", "FillCup", LocalPlayer.Character.Cup)
                        end

                        Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan")
                    elseif Progress == 4 then
                        SetTask("MainTask", "Saber Quest | Rich Son | Getting Information")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                    elseif Progress == 5 then
                        SetTask("MainTask", "Saber Quest | Mob Leader | Defeating Boss")
                        CombatController.Attack("Mob Leader")
                    elseif Progress == 6 then
                        SetTask("MainTask", "Saber Quest | Relic | Placing at Location")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "PlaceRelic")
                    elseif Progress == 7 then
                        SetTask("MainTask", "Saber Quest | Saber Expert | Final Battle")
                        CombatController.Attack("Saber Expert")
                    end
                end
            end
        )

        Remotes.RefreshQuestPro.OnClientEvent:Connect(function(...) if FunctionsHandler.Saber.Methods.Refresh then FunctionsHandler.Saber.Methods.Refresh.Callback(...) end end)

        -- Auto Melees

        local MT = getrawmetatable(game)
        local OldNameCall = MT.__namecall
        setreadonly(MT, false)
        MT.__namecall =
            newcclosure(
            function(self, ...)
                local Method = getnamecallmethod()
                local Args = {...}
                if Method == "FireServer" and self.Name == "RemoteEvent" then
                    if getgenv().LastestLockDate and os.time() - LastestLockDate < 3 then
                        Args[1] = getgenv().LockPosition
                    end
                end

                return OldNameCall(self, unpack(Args))
            end
        )

        function LockAimPositionTo(LockedPosition)
            getgenv().LastestLockDate = os.time()
            getgenv().LockPosition = LockedPosition
        end

        MeleeLastCursor = 1
        FirstCall = true
        CanPurchase = {}
        FruitDataCache = {}
        function GetCurrentFruitMastery()
            local CurrentPlayer = game.Players.LocalPlayer
            local CurrentFruit = CurrentPlayer.Data.DevilFruit.Value
            local DF =
                CurrentPlayer.Character and
                (CurrentPlayer.Character:FindFirstChild(CurrentFruit) or
                    CurrentPlayer.Backpack:FindFirstChild(CurrentFruit))
            local bfMaxLevel = 0

            if DF then
                if CurrentFruit ~= "" then
                    local Data = FruitDataCache[CurrentFruit] or require(DF.Data)
                    FruitDataCache[CurrentFruit] = Data
                    for _, v in {"V", "C", "X", "F", "Z"} do
                        if Data.Lvl[v] then
                            bfMaxLevel = Data.Lvl[v]
                            break
                        end
                    end
                end

                return DF.Level.Value, bfMaxLevel
            end
            return 0, bfMaxLevel
        end

        Remotes.Redeem:InvokeServer("KITT_RESET")
        Remotes.Redeem:InvokeServer("Sub2UncleKizaru")
        Remotes.Redeem:InvokeServer("SUB2GAMERROBOT_RESET1")

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
 
        print(GetCurrentFruitMastery())
        FunctionsHandler.MeleesController:RegisterMethod(
            "Refresh",
            function()
                return Config.Items.AutoFullyMelees
            end
        )

        FunctionsHandler.MeleesController:RegisterMethod(
            "Start",
            function()
                ScriptStorage.IsGettingMelee = false  -- luôn reset flag trước khi bắt đầu

                for Cursor, Melee in MeleesTable do
                    if Melee ~= "SanguineArt" then
                        if not Config.Items.AutoFullyMelees then
                            break
                        end
                        Data = MeleePrices[Melee]
                        local CanMeleePurchaseable = CanPurchase[Melee]
                        if not CanMeleePurchaseable then
                            CanPurchase[Melee] = Data.Buy(1)
                            print("CanBuy", Melee, Data.Buy(1))
                        end
                        local CanMeleePurchaseable = CanPurchase[Melee]

                        if not Data then
                            print("no m1 data")
                            Data.Buy()
                            break
                        end

                        if Melee == "Dragon Talon" then
                            IsFireEssenceGave = (function()
                                if IsFireEssenceGave ~= nil then
                                    return IsFireEssenceGave
                                end

                                local PurchaseTestResult = Remotes.CommF_:InvokeServer("BuyDragonTalon", true)
                                alert("Dragon Talon Purchased", tostring(typeof(PurchaseTestResult) ~= "string"))
                                return typeof(PurchaseTestResult) ~= "string" and true or false
                            end)()

                            print("IsFireEssenceGave", IsFireEssenceGave)

                            if not IsFireEssenceGave then
                                print("no fire essence provided")
                                ScriptStorage.IsGettingMelee = false
                                break
                            end
                        end
                        if Melee == "Godhuman" then
                            if (ScriptStorage.Melees["Dragon Talon"] or 0) > 399 then
                                if not ScriptStorage.Melees.Godhuman then
                                    if SeaIndex == 3 then
                                        BuyMelee("Godhuman", true,"Ancient Monk")
                                    end
                                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")

                                    if not ScriptStorage.Melees.Godhuman and type(game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyGodhuman", true)) == "string" then
                                        GodHumanFlag = true
                                        ScriptStorage.IsGettingMelee = false
                                        return
                                    end
                                end
                            end
                        end

                        if
                            not ScriptStorage.Melees[Melee] or
                                (ScriptStorage.Melees[Melee] or 0) < Data.NextLevelRequirement
                         then
                            local MeleeId = GetMeleeIdByName(Melee)
                            local PlayerData = ScriptStorage.PlayerData
                            local ValuementPassed = true

                            if not MeleeId then
                                ScriptStorage.IsGettingMelee = false
                                return print("[ Debug ] Failed to get melee id of", Melee)
                            end

                            MSet = false
                            if not CanMeleePurchaseable then
                                for Index, Value in Data.Price do
                                    if PlayerData[Index] < Value and not FirstCall then
                                        ValuementPassed = false

                                        if not ScriptStorage.Melees[Melee] then
                                            MSet = true
                                            SetTask(
                                                "SubTask",
                                                "Farming Until Enough " .. Index .. " ( " .. Value .. " ) For " .. Melee
                                            )
                                        end
                                        ScriptStorage.IsGettingMelee = false
                                        return
                                    end
                                end
                            end

                            if
                                not MSet and ScriptStorage.Melees[Melee] and
                                    ScriptStorage.Melees[Melee] < Data.NextLevelRequirement
                             then
                                SetTask(
                                    "SubTask",
                                    "Farming Until Enough Mastery For " ..
                                        Melee ..
                                            " ( " ..
                                                ScriptStorage.Melees[Melee] ..
                                                    " / " .. Data.NextLevelRequirement .. " )."
                                )
                                -- Luôn attack ĐỂ TĂNG MASTERY, bất kể đã sở hữu melee chưa
                                CombatController.Attack(Melee)
                                -- Chỉ mua nếu chưa có — KHÔNG block raid khi farm mastery
                                if not ScriptStorage.Tools[Melee] then
                                    print("no m1 found, buy")
                                    ScriptStorage.IsGettingMelee = true  -- block raid CHỈ khi đang mua
                                    Data.Buy()
                                    ScriptStorage.IsGettingMelee = false  -- clear ngay sau khi mua xong
                                end
                                -- KHÔNG set IsGettingMelee khi chỉ farm mastery — raid vẫn chạy bình thường
                                return
                            end

                            if not FirstCall then
                                if ValuementPassed and Data.Requirements() and not ScriptStorage.Tools[Melee] then
                                    if Melee == "Dragon Talon" and not IsFireEssenceGave then
                                        alert("IsFireEssenceGave", tostring(IsFireEssenceGave))
                                        ScriptStorage.IsGettingMelee = false
                                        return SetTask("SubTask", "Waiting until have fire essence for dragon talon.")
                                    end

                                    ScriptStorage.IsGettingMelee = true  -- Set flag to block raid
                                    Data.Buy()
                                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                                    if not ScriptStorage.Tools[Melee] then
                                        task.wait()
                                        if not ScriptStorage.Tools[Melee] then
                                            if ((Melee == "Death Step" and game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDeathStep", true) ==  3)  or
                                            (Melee == "Sharkman Karate" and
                                            type(game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)) == "string" or (
                                            type(game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)) == "number" and game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true) == 3 ))) and SeaIndex ~= 2 then
                                                alert("Go Back To Second Sea", "Water Key / Library Key")

                                                Remotes.CommF_:InvokeServer("TravelDressrosa")
                                            end
                                            ScriptStorage.IsGettingMelee = false  -- Clear flag if failed
                                        else
                                            MeleeLastCursor = Cursor + 1
                                            ScriptStorage.IsGettingMelee = false  -- Clear flag on success
                                            return
                                        end
                                    else
                                        MeleeLastCursor = Cursor + 1
                                        ScriptStorage.IsGettingMelee = false  -- Clear flag on success
                                        return
                                    end
                                end
                            end
                        elseif not FirstCall then
                            MeleeLastCursor = Cursor + 1
                        end
                    end
                end
                if FirstCall then
                    FirstCall = false
                    return
                end

                checkdone = true
                ScriptStorage.IsGettingMelee = false  -- reset khi loop xong

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

                local Response = Remotes.CommF_:InvokeServer("DressrosaQuestProgress")
                print(959, Response.TalkedDetective, Response.KilledIceBoss)
                if not Response.TalkedDetective then
                    Result = 1
                elseif not Response.KilledIceBoss then
                    Result = 2
                else
                    FunctionsHandler.SecondSeaPuzzle:Set("IsCompleted", true)
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
                    FunctionsHandler.SecondSeaPuzzle.Methods.Refresh:Call()
                    return FunctionsHandler.SecondSeaPuzzle.Methods.Start:Call()
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

                if ScriptStorage.PlayerData.Level < 850 or ScriptStorage.Backpack["Warrior Helmet"] then
                    return
                end

                local Response = Remotes.CommF_:InvokeServer("BartiloQuestProgress")

                if not Response.KilledBandits then
                    Result = 1
                elseif not Response.KilledSpring then
                    if ScriptStorage.Enemies.Jeremy then
                        Result = 2
                    end
                elseif not Response.DidPlates then
                    Result = 3
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
                    FunctionsHandler.ColosseumPuzzle.Methods.Refresh:Call()
                    return FunctionsHandler.ColosseumPuzzle.Methods.Start:Call()
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
                    getsenv(game.ReplicatedStorage.GuideModule)._G.ServerData.ExpBoost ~= 0 or
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
                for _, Raid in require(game.ReplicatedStorage.Raids).raids do
                    if string.find(ScriptStorage.PlayerData.DevilFruit, Raid) then
                        FunctionsHandler.RaidController:Set("CurrentChip", Raid)
                        return
                    end
                end
                FunctionsHandler.RaidController:Set("CurrentChip", "Flame")
            end
        )

        FunctionsHandler.RaidController:RegisterMethod(
            "GetRaidableFruit",
            function()
                for _, Fruit in ScriptStorage.Backpack do
                    if string.find(FruitIdToName(Fruit.Name), " Fruit") then
                        if Fruit.Value and Fruit.Value < 1000000 then
                            return Fruit
                        end
                    end
                end
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
        
            local Level = ScriptStorage.PlayerData.Level
            local Fragments = ScriptStorage.PlayerData.Fragments
        
            -- Điều kiện cơ bản
            if Level < 1300 or SeaIndex == 1 then return end
            if ScriptStorage.IsGettingMelee then return end
        
            -- 1. Check Melee: Chỉ chặn Raid nếu thực sự có thể mua NGAY LẬP TỨC
            if Config.Items.AutoFullyMelees then
                for Cursor, Melee in MeleesTable do
                    if Melee == "SanguineArt" then
                        -- SanguineArt không mua được qua remote, lấy qua quest
                    else
                        local Data = MeleePrices[Melee]
                        if Data then
                            local CanMeleePurchaseable = CanPurchase[Melee]
                            if not CanMeleePurchaseable then
                                CanMeleePurchaseable = Data.Buy(1)
                            end

                            local RequiredFragments = (Data.Price and Data.Price.Fragments) or 0
                            local CurrentFragments = ScriptStorage.PlayerData.Fragments or 0

                            -- LOGIC: Chỉ block raid khi đủ ALL điều kiện (tiền + mastery + fragments + chưa sở hữu)
                            -- Nếu thiếu Fragments → đi raid tích trữ, không block
                            if CanMeleePurchaseable and Data.Requirements() and
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

            -- 2. Logic tich luy Fragments (Neu khong mua Melee thi di Raid tich tru)
            -- Neu Level chua Max, tich du 10k thi nghi
            -- Neu da Max Level, phai tich du 15k moi duoc nghi. Duoi 15k se tu di Raid tiep.
            if Level < MaxLevel then
                if Fragments >= 10000 then return end 
            else
                if Fragments >= 15000 then return end 
            end
        
            -- 3. Thực hiện đi Raid (Phần này chỉ chạy khi 2 điều kiện trên không chặn)
            local RaidFruit = FunctionsHandler.RaidController.Methods.GetRaidableFruit:Call()
        
            if RaidFruit then
                FunctionsHandler.RaidController:Set("CurrentProgressLevel", RaidFruit)
            end
        
            return RaidFruit
                or FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                or CheckSpecialMicrochip()
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
                            if not cRaidFruit then
                                warn("No raidable fruit found")
                                return
                            end

                            -- Chỉ thêm vào IgnoreStoreFruits nếu chưa có
                            if not table.find(ScriptStorage.IgnoreStoreFruits, cRaidFruit.Name) then
                                table.insert(ScriptStorage.IgnoreStoreFruits, cRaidFruit.Name)
                            end

                            -- Luôn lấy Fruit vật lý ra khỏi rương (LoadFruit)
                            if getgenv().LastLoadedFruit ~= cRaidFruit.Name then
                                getgenv().LastLoadedFruit = cRaidFruit.Name
                                alert("Load Fruit", cRaidFruit.Name)
                                Remotes.CommF_:InvokeServer("LoadFruit", cRaidFruit.Name)
                                task.wait(1.5)
                            end

                            Remotes.CommF_:InvokeServer(
                                "RaidsNpc",
                                "Select",
                                FunctionsHandler.RaidController:Get("CurrentChip")
                            )

                            -- Game tự cất fruit khi chọn chip → load lại fruit
                            task.wait(1)
                            Remotes.CommF_:InvokeServer("LoadFruit", cRaidFruit.Name)
                            task.wait(1)
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

        FunctionsHandler.CollectDrops:RegisterMethod(
            "Refresh",
            function()
                local FruitNames = {}

                for i in ScriptStorage.Backpack do
                    FruitNames[FruitIdToName(i)] = i
                end

                for _, Fruit in workspace:GetChildren() do
                    if
                        string.find(Fruit.Name, "Fruit") and not Players:FindFirstChild(Fruit.Name) and
                            Fruit:FindFirstChild("Handle") and
                            not FruitNames[tostring(Fruit)] and
                            not ScriptStorage.Backpack[FruitNameToId(tostring(Fruit))]
                     then
                        FunctionsHandler.CollectDrops:Set("CurrentProgressLevel", Fruit)
                        getgenv().anchored = true  
                        return Fruit
                    end
                end
            end
        )

        FunctionsHandler.CollectDrops:RegisterMethod(
            "Start",
            function()
                local Fruit = FunctionsHandler.CollectDrops:Get("CurrentProgressLevel")
                FunctionsHandler.CollectDrops:Set("CurrentProgressLevel", nil)
                if Fruit then
                    SetTask("MainTask", "Auto Collect Drop Items - " .. tostring(Fruit))
                    getgenv().anchored = true  
                    TweenController.Create(Fruit:GetModelCFrame())
                else
                    if not FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() and 
                       not FunctionsHandler.RaidController.Methods.GetRaidableFruit:Call() then
                        getgenv().anchored = false
                    end
                end
            end
        )

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
                if
                    SeaIndex == 3 and (ScriptStorage.Melees["Death Step"] or 0) >= 400 and
                        (ScriptStorage.Melees["Black Leg"] or 0) >= 400 and
                        ScriptStorage.PlayerData.Beli >= 2500000 and
                        ScriptStorage.PlayerData.Fragments >= 5000 and
                        not ScriptStorage.Melees["Electric Claw"]
                 then
                    FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Previous Hero")
                    return "Previous Hero"
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
                elseif Type == "Previous Hero" then
                    Remotes.CommF_:InvokeServer("BuyElectricClaw", "Start")
                    task.wait(3)
                    repeat
                        task.wait()
                        TweenController.Create(CFrame.new(-12548, 332.378 + math.random(-2, 2), -7617))
                    until game.Players.LocalPlayer:DistanceFromCharacter(Vector3.new(-12548, 332.378, -7617)) < 30

                    Data = MeleePrices["Electric Claw"]
                    Data.Buy(1)
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
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
                            game.Players.LocalPlayer:Kick("Rejoining...")
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

        local old

        old =
            hookfunction(
            require(game.ReplicatedStorage.Notification).new,
           newcclosure(function(a, b)
                v21 = tostring(tostring(a or "") .. tostring(b or "")) or ""

                getgenv().NotificationCallBack(v21)

                return {
                    Display = function() end  
                }
                --return old(a, b)
            end
        ))

     
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
                    return CachedServers
                end
            end

            for i = 1, 100, 1 do
                local data = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer(i)
                if IfTableHaveIndex(data) then
                    LastServersDataPulled = os.time()
                    CachedServers = data
                    return data
                end
            end
        end

        spawn(
            function()
                GetServers()
                while task.wait(180) do
                    GetServers()
                end
            end
        )

        function Hop(Reason, MaxPlayers, ForcedRegion)
            local Servers = GetServers()
            local ArrayServers = {}

            for i, v in Servers do
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
                            if not ForcedRegion or ServerData.Regoin == ForcedRegion then
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
                game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer(
                    "teleport",
                    ServerData.JobId
                )
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
            writefile(StoragePath, Encode(Self.Data))
        end

        if not isfile(StoragePath) then
            writefile(StoragePath, "{}")
            task.wait(1)
        end

        Storage.Data = {}

        --Report(readfile(StoragePath))
        pcall(
            function()
                Storage.Data = Decode(readfile(StoragePath) or "{}")
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
        for _, Connection in getconnections(game:GetService("Players").LocalPlayer.PlayerGui.Main.SettingsMenu.Content.ScrollingFrame.FastMode.FirstButton.Activated
        ) do
            Connection.Function()
        end
      
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
        if Config.Configuration.FpsBoost then
            boostfps()
        end
        repeat wait() until game:IsLoaded() 
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
                if not Task.Initalized then
                    if not LogCache[TaskName] then
                        print("[ Debug ] Task", Name, "is not registered yet")
                        LogCache[TaskName] = true
                    end
                else
                    local Refresh = Task.Methods.Refresh
                    local Start = Task.Methods.Start

                    if Refresh then
                        local RefreshValue = Refresh:Call(ParsingTimes < 100)

                        ParsingTimes = ParsingTimes + 1
                        if RefreshValue and ParsingTimes > 100 then
                            CurrentTask = CurrentTask ~= TaskName

                            CurrentTask = TaskName
                            ScriptStorage.Interface.SetText("DebugLine", TaskName)
                            Start:Call(RefreshValue)
                            return
                        end
                    end
                end
            end
        end

        SetText("MainTextLabel", "Refreshing Player Items...")
        AddPoint()

        QuestManager:RefreshQuest()
        SetText("MainTextLabel", "A")

        RefreshInventory()
                SetText("MainTextLabel", "B")

        Remotes.CommE.OnClientEvent:Connect(
            function(...)
                local data = {...}
                -- print(..., "additem")
                if string.find(data[1], "Item") then
                    RefreshInventory()
                end
            end
        )

        RefreshRace()

        Players.LocalPlayer.Idled:Connect(
            function()
                Services.VirtualUser:CaptureController()
                Services.VirtualUser:ClickButton2(Vector2.new())
            end
        )

        SetText("MainTextLabel", "Loaded In " .. tick() - StartTick .. "ms!")
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

        -- Chạy NearbyHopHandler định kỳ để check players gần
        task.spawn(function()
            while task.wait(5) do
                if not _G.Stop then
                    pcall(NearbyHopHandler)
                end
            end
        end)
        
        if ScriptStorage.PlayerData.Level > 2000 then 
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo")
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Buso")
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Soru")
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Buy") 
        end
        
         function getcandies()
            for i,v in game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("getInventory") do
                if v.Name ==  "Candy" then 
                    return v.Count
                end
            end
            return 0
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
             print(0)
            local success, response = xpcall(RefreshTasksData, debug.traceback)
            print(1)
            -- Chỉ chạy MeleesController khi KHÔNG đang trong raid
            local IsInRaid = FunctionsHandler.RaidController and FunctionsHandler.RaidController:Get("IsInRaidProcess")
            if not IsInRaid then
                FunctionsHandler.MeleesController.Methods.Start:Call()
            end
            print(2)
            if not success then
                Report(response)
            end
        end

    end
