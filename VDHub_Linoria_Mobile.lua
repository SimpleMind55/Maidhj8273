--[[
  VD Hub — Linoria · Mobile optimized
  Base: SWAGA CRACK logic (AutoParry, ESP, Killer/Survivor)
  Window: ~300x420 phone / 340x460 tablet-touch
  No key · no pastebin loaders
]]
local t1 = {}
local v3, v4
do
    local v2 = unpack or table.unpack

    t1[1] = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
    v3 = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
    v4 = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()
    t1[2] = game:GetService("Players")
    t1[3] = game:GetService("Workspace")
    t1[4] = game:GetService("RunService")
    t1[5] = game:GetService("UserInputService")
    t1[6] = game:GetService("ReplicatedStorage")
    t1[7] = game:GetService("VirtualInputManager")
    t1[8] = t1[3].CurrentCamera
    t1[9] = game:GetService("Lighting")
    t1[10] = game:GetService("TeleportService")
    t1[11] = game:GetService("TweenService")
    t1[12] = game:GetService("VirtualUser")
    game:GetService("ContextActionService")
    game:GetService("StarterGui")
    t1[13] = game:GetService("CoreGui")
    t1[14] = t1[2].LocalPlayer
    t1[15] = 100
    t1[16] = {}
    t1[16].IsPlayerKiller = function(p1)
        if not p1 or not p1.Character then
            return false
        end

        local Character = p1.Character
        local v273 = p1.Name:lower()
        local v274 = v273:find("killer")

        if not v274 then
            v274 = v273:find("hunter")

            if not v274 then
                v274 = v273:find("murderer")

                if not v274 then
                    v274 = v273:find("slasher")
                end
            end
        end

        if v274 then
            return true
        end

        local v275, v276, v277 = ipairs({
			"Knife",
			"Axe",
			"Sword",
			"Parrying Dagger",
			"Machete",
			"Bat",
			"Weapon"
		})

        repeat
            local v278

            v277, v278 = v275(v276, v277)

            if not v277 then
                local n1 = 0
                local GetDescendants = Character.GetDescendants
                local n2 = 0

                for _, v in pairs(GetDescendants(Character)) do
                    if v:IsA("BasePart") then
                        n1 += 1

                        local vColor = v.Color
                        local v285 = vColor.R < 0.3

                        if v285 then
                            v285 = vColor.G < 0.3 and vColor.B < 0.3
                        end

                        if v285 then
                            n2 += 1
                        end
                    end
                end

                return n1 > 0 and n2 / n1 > 0.5
            end

            local v286 = Character:FindFirstChild(v278)

            if not v286 then
                v286 = Character:FindFirstChild(v278:lower())
            end
        until v286

        return true
    end
    t1[16].IsSurvivorTeam = function()
        local Team = t1[14].Team

        if not Team then
            return false
        end

        local v288 = Team.Name:lower()
        local v289 = v288:find("survivor")

        if not v289 then
            v289 = v288 == "survivors" or v288 == "survivor"
        end

        return v289
    end
    t1[16].IsKillerTeam = function()
        local Team = t1[14].Team

        if not Team then
            return false
        end

        local v291 = Team.Name:lower()
        local v292 = v291:find("killer")

        if not v292 then
            v292 = v291 == "killers" or v291 == "killer"
        end

        return v292
    end
    t1[16].SetupTeamListener = function(p2)
        local t2 = {}

        table.insert(t2, t1[14]:GetPropertyChangedSignal("Team"):Connect(p2))
        table.insert(t2, t1[14].CharacterAdded:Connect(function()
            task.wait(0.5)
            p2()
        end))
        task.spawn(p2)

        return t2
    end
    t1[16].SetupCharacterListener = function(p3)
        local connection = t1[14].CharacterAdded:Connect(p3)

        if t1[14].Character then
            p3(t1[14].Character)
        end

        return connection
    end
    t1[16].GetCharacterRoot = function(p4)
        if not p4 then
            return nil
        end

        local HumanoidRootPart = p4:FindFirstChild("HumanoidRootPart")

        if not HumanoidRootPart then
            HumanoidRootPart = p4:FindFirstChild("Torso")

            if not HumanoidRootPart then
                HumanoidRootPart = p4:FindFirstChild("UpperTorso")
            end
        end

        return HumanoidRootPart
    end
    t1[16].GetHumanoid = function(p5)
        if not p5 then
            return nil
        end

        return p5:FindFirstChildOfClass("Humanoid")
    end
    t1[16].PressSpace = function()
        t1[7]:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.02)
        t1[7]:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
    t1[16].EnableNoClipTemp = function(p6)
        local Character = t1[14].Character

        if not Character then
            return
        end

        local t3 = {}

        for _, descendant in ipairs(Character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                t3[descendant] = descendant.CanCollide
                descendant.CanCollide = false
            end
        end

        task.delay(p6, function()
            for k, v in pairs(t3) do
                local v1201 = k

                if v1201 and v1201.Parent then
                    v1201.CanCollide = v
                end
            end
        end)
    end
    t1[16].TeleportToPosition = function(p7, p8)
        local Character = t1[14].Character

        if not Character then
            return
        end

        local v308 = t1[16].GetCharacterRoot(Character)

        if not v308 then
            return
        end

        if p8 then
            t1[11]:Create(v308, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				CFrame = CFrame.new(p7)
			}):Play()

            return
        end

        v308.CFrame = CFrame.new(p7)
    end
    t1[16].FireRemote = function(p9, ...)
        if not p9 then
            return false
        end

        local t4 = { ... }
        local ok, result = pcall(function()
            local v1202 = p9
            local t5 = { unpack(t4) }

            v1202:FireServer(v2(t5))
        end)

        if not ok then
            warn("Remote call failed:", result)
        end

        return ok
    end

    local t6

    do
        local color3 = Color3.fromRGB(0, 255, 0)
        local color3_2 = Color3.fromRGB(255, 0, 0)
        local color3_3 = Color3.fromRGB(0, 255, 255)
        local color3_4 = Color3.fromRGB(127, 0, 255)
        local color3_5 = Color3.fromRGB(255, 255, 255)

        t6 = {
			SurvivorColor = color3,
			KillerColor = color3_2,
			GenColor = color3_3,
			PalletColor = color3_4,
			GenProgressColor = color3_5,
			SurvivorsActive = false,
			KillerActive = false,
			GenActive = false,
			PalletsActive = false,
			TracersActive = false,
			GenProgressActive = false
		}
    end

    local t13

    do
        local t7 = {
			Enabled = false,
			Speed = 60
		}
        local t8 = {
			Enabled = false
		}
        local t9 = {
			Enabled = false
		}
        local t10 = {
			Enabled = false,
			Distance = 50
		}
        local t11 = {
			Enabled = false,
			Speed = 10
		}
        local t12 = {
			Enabled = false,
			HeightOffset = 3
		}

        t13 = {
			Fly = t7,
			NoClip = t8,
			GodMode = t9,
			Teleport = t10,
			Spinbot = t11,
			HeadStalker = t12,
			BackStalker = {
				Enabled = false,
				Distance = 5,
				HeightOffset = 2
			}
		}
    end

    local t16

    do
        local t14 = {
			Enabled = false,
			Smoothness = 10,
			FOV = 50,
			TeamCheck = true,
			VisibleCheck = true
		}
        local color3 = Color3.fromRGB(255, 0, 255)
        local t15 = {
			Enabled = false,
			Color = color3,
			Transparency = 0.3,
			FillMode = "AlwaysOnTop"
		}
        local color3_6 = Color3.fromRGB(255, 0, 0)
        local color3_7 = Color3.fromRGB(0, 0, 0)

        t16 = {
			Aimbot = t14,
			Chams = t15,
			CustomCrosshairs = {
				Enabled = false,
				Type = "Dot",
				Size = 8,
				Color = color3_6,
				Gap = 3,
				Thickness = 1,
				Outline = true,
				OutlineColor = color3_7
			}
		}
    end

    local t24

    do
        local t17 = {
			Enabled = false
		}
        local t18 = {
			Enabled = false
		}
        local t19 = {
			Enabled = false
		}
        local t20 = {
			Enabled = false
		}
        local t21 = {
			Enabled = false
		}
        local t22 = {
			Enabled = false,
			Red = 255,
			Green = 200,
			Blue = 200,
			Brightness = 1
		}
        local t23 = {
			Enabled = false
		}

        t24 = {
			Crosshair = t17,
			Aspect43 = t18,
			ChinaHat = t19,
			ChamsSelf = t20,
			ChamsOthers = t21,
			WorldTint = t22,
			Fullbright = t23,
			NoShadow = {
				Enabled = false
			}
		}
    end

    local t27, t34

    do
        local t25

        do
            local vector3 = Vector3.new(1980, 737, 3811)

            t25 = {
				Enabled = false,
				Coords = vector3
			}
        end

        local t26

        do
            local vector3 = Vector3.new(1980, 737, 3811)
            local vector3_2 = Vector3.new(-943, 153, -7564)
            local vector3_3 = Vector3.new(-1833, 172, -3319)
            local vector3_4 = Vector3.new(1997, 144, -720)
            local vector3_5 = Vector3.new(3022, 454, -5410)
            local vector3_6 = Vector3.new(-1360, 59, -1340)
            local vector3_7 = Vector3.new(761, -20, -78)

            t26 = {
				["Лобби (исходная)"] = vector3,
				["Замок (выход)"] = vector3_2,
				["Аутласт (выход)"] = vector3_3,
				["Клуб"] = vector3_4,
				["Крыша"] = vector3_5,
				["Море"] = vector3_6,
				["Деревня"] = vector3_7
			}
        end

        t27 = {
			TpLobby = t25,
			ExitPoints = t26,
			TPOffset = 3
		}

        local t28 = {
			Enabled = false
		}
        local t29 = {
			Enabled = false
		}
        local t30 = {
			Enabled = false,
			Strength = 10000
		}
        local t31 = {
			Enabled = false
		}
        local t32 = {
			Enabled = false
		}
        local t33 = {
			Enabled = false
		}

        t34 = {
			KillAura = t28,
			AntiFling = t29,
			Fling = t30,
			AutoFling = t31,
			BypassGate = t32,
			AntiAFK = t33,
			Sahura = {
				Enabled = false
			}
		}
    end

    local t46

    do
        local t35 = {
			Enabled = false
		}
        local t36 = {
			Enabled = false
		}
        local t37 = {
			Enabled = false
		}
        local t38 = {
			Enabled = false,
			Range = 10
		}
        local t39 = {
			Enabled = false,
			Range = 20
		}
        local t40 = {
			Enabled = false
		}
        local t41 = {
			Enabled = false
		}
        local t42 = {
			Enabled = false
		}
        local t43 = {
			Enabled = false
		}
        local t44 = {
			Enabled = false,
			Value = 60
		}
        local t45 = {
			Enabled = false,
			Power = 100
		}

        t46 = {
			NoSlowdown = t35,
			NoFall = t36,
			NoHitbox = t37,
			AutoParry = t38,
			AutoParryV2 = t39,
			FakeParry = t40,
			TwistSilentAim = t41,
			ParryCircle = t42,
			AutoSkillcheck = t43,
			SpeedGlitch = t44,
			SuperJump = t45,
			WalkSpeed = 16,
			VaultSpeed = 1,
			EmoteWheel = {
				Enabled = false
			}
		}
    end

    local t47 = {
		Enabled = false
	}
    local t48 = {
		Enabled = false
	}
    local vector3 = Vector3.new(2, 1, 8)
    local t49 = {
		Enabled = false,
		Offset = vector3
	}
    local t50 = {
		Enabled = false
	}
    local t51 = {
		Enabled = false
	}
    local t52 = {
		Enabled = false
	}
    local t53 = {
		Enabled = false
	}
    local t54 = {
		Enabled = false
	}
    local t55 = {
		Enabled = false,
		Range = 12
	}
    local t56 = {
		Enabled = false
	}
    local t57 = {
		Enabled = false
	}
    local t58 = {
		SpearCrosshair = t47,
		NoSlowdown = t48,
		ThirdPerson = t49,
		AntiBlind = t50,
		NoPalletStun = t51,
		BeatGame = t52,
		UseFakeSaw = t53,
		AbysswalkerCorrupt = t54,
		AutoAttack = t55,
		AutoHook = t56,
		KillAll = t57,
		RemovePallet = {
			Enabled = false
		}
	}

    t1[17] = {
		ESP = t6,
		Movement = t13,
		Combat = t16,
		Visual = t24,
		Teleport = t27,
		Fun = t34,
		Survivor = t46,
		Killer = t58,
		ShiftLock = {
			Enabled = false
		}
	}
    t1[18] = {}
    t1[18].__index = t1[18]
    t1[18].new = function()
        local self = setmetatable({}, t1[18])
        local FlySpeed = t1[17].Movement.Fly.Speed

        self.Fly = {
			Enabled = false,
			Speed = FlySpeed,
			Connection = nil,
			Controls = {}
		}
        self.NoClip = {
			Enabled = false,
			Connection = nil
		}
        self.GodMode = {
			Enabled = false,
			Connection = nil,
			OriginalHealth = 100,
			OriginalMaxHealth = 100
		}

        local Distance = t1[17].Movement.Teleport.Distance

        self.Teleport = {
			Enabled = false,
			Distance = Distance
		}

        local SpinbotSpeed = t1[17].Movement.Spinbot.Speed

        self.Spinbot = {
			Enabled = false,
			Speed = SpinbotSpeed,
			Connection = nil
		}

        local HeightOffset = t1[17].Movement.HeadStalker.HeightOffset

        self.HeadStalker = {
			Enabled = false,
			HeightOffset = HeightOffset,
			Target = nil,
			Connection = nil
		}

        local Distance2 = t1[17].Movement.BackStalker.Distance
        local HeightOffset2 = t1[17].Movement.BackStalker.HeightOffset

        self.BackStalker = {
			Enabled = false,
			Distance = Distance2,
			HeightOffset = HeightOffset2,
			Target = nil,
			Connection = nil
		}

        local SpeedGlitchValue = t1[17].Survivor.SpeedGlitch.Value

        self.SpeedGlitch = {
			Enabled = false,
			Value = SpeedGlitchValue,
			Thread = nil
		}

        local Power = t1[17].Survivor.SuperJump.Power

        self.SuperJump = {
			Enabled = false,
			Power = Power,
			Thread = nil
		}
        self.Moonwalk = {
			Enabled = false,
			Connection = nil,
			CurrentYaw = 0
		}
        self.WalkSpeed = t1[17].Survivor.WalkSpeed
        self.VaultSpeed = t1[17].Survivor.VaultSpeed

        return self
    end
    t1[18].ToggleFly = function(p10, p11)
        p10.Fly.Enabled = p11

        if p11 then
            local Character = t1[14].Character

            if not Character then
                return
            end

            local v325 = t1[16].GetHumanoid(Character)
            local v326 = t1[16].GetCharacterRoot(Character)

            if not v325 or not v326 then
                return
            end

            p10.Fly.OriginalPlatformStand = v325.PlatformStand
            v325.PlatformStand = true

            local BodyVelocity = Instance.new("BodyVelocity")

            BodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.P = 10000
            BodyVelocity.Parent = v326

            local BodyGyro = Instance.new("BodyGyro")

            BodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
            BodyGyro.P = 10000
            BodyGyro.D = 1000
            BodyGyro.CFrame = v326.CFrame
            BodyGyro.Parent = v326
            p10.Fly.Controls.BodyVelocity = BodyVelocity
            p10.Fly.Controls.BodyGyro = BodyGyro
            p10.Fly.Connection = t1[4].Heartbeat:Connect(function()
                if not p10.Fly.Enabled then
                    return
                end

                local Character2 = t1[14].Character

                if not Character2 then
                    return
                end

                if not t1[16].GetCharacterRoot(Character2) then
                    return
                end

                local BodyVelocity2 = p10.Fly.Controls.BodyVelocity
                local BodyGyro2 = p10.Fly.Controls.BodyGyro

                if not BodyVelocity2 or not BodyGyro2 then
                    return
                end

                local vector3_8 = Vector3.new(0, 0, 0)
                local CurrentCamera = t1[3].CurrentCamera

                if t1[5]:IsKeyDown(Enum.KeyCode.W) then
                    vector3_8 += CurrentCamera.CFrame.LookVector
                end

                if t1[5]:IsKeyDown(Enum.KeyCode.S) then
                    vector3_8 -= CurrentCamera.CFrame.LookVector
                end

                if t1[5]:IsKeyDown(Enum.KeyCode.A) then
                    vector3_8 -= CurrentCamera.CFrame.RightVector
                end

                if t1[5]:IsKeyDown(Enum.KeyCode.D) then
                    vector3_8 += CurrentCamera.CFrame.RightVector
                end

                if t1[5]:IsKeyDown(Enum.KeyCode.Space) then
                    vector3_8 += Vector3.new(0, 1, 0)
                elseif t1[5]:IsKeyDown(Enum.KeyCode.LeftControl) then
                    vector3_8 += Vector3.new(0, -1, 0)
                end

                if vector3_8.Magnitude > 0 then
                    vector3_8 = vector3_8.Unit * p10.Fly.Speed
                end

                BodyVelocity2.Velocity = vector3_8
                BodyGyro2.CFrame = CurrentCamera.CFrame
                v325:ChangeState(Enum.HumanoidStateType.Flying)
            end)

            return
        end

        if p10.Fly.Connection then
            p10.Fly.Connection:Disconnect()
            p10.Fly.Connection = nil
        end

        local Character = t1[14].Character

        if Character then
            local v330 = t1[16].GetHumanoid(Character)

            if v330 then
                v330.PlatformStand = false
                v330:ChangeState(Enum.HumanoidStateType.Running)
            end

            if p10.Fly.Controls.BodyVelocity then
                p10.Fly.Controls.BodyVelocity:Destroy()
                p10.Fly.Controls.BodyVelocity = nil
            end

            if p10.Fly.Controls.BodyGyro then
                p10.Fly.Controls.BodyGyro:Destroy()
                p10.Fly.Controls.BodyGyro = nil
            end
        end

        p10.Fly.Controls = {}
    end
    t1[18].ToggleNoClip = function(p12, p13)
        p12.NoClip.Enabled = p13

        if p13 then
            p12.NoClip.Connection = t1[4].Stepped:Connect(function()
                local Character = t1[14].Character

                if Character then
                    local GetDescendants = Character.GetDescendants

                    for _, v in pairs(GetDescendants(Character)) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)

            return
        end

        if p12.NoClip.Connection then
            p12.NoClip.Connection:Disconnect()
            p12.NoClip.Connection = nil
        end

        local Character = t1[14].Character

        if Character then
            for _, descendant in pairs(Character:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.CanCollide = true
                end
            end
        end
    end
    t1[18].ToggleGodMode = function(p14, p15)
        p14.GodMode.Enabled = p15

        if p15 then
            local Character = t1[14].Character

            if Character then
                local v339 = t1[16].GetHumanoid(Character)

                if v339 then
                    p14.GodMode.OriginalHealth = v339.Health
                    p14.GodMode.OriginalMaxHealth = v339.MaxHealth
                    v339.MaxHealth = 1e999
                    v339.Health = 1e999
                    p14.GodMode.Connection = v339.HealthChanged:Connect(function()
                        if v339.Health < math.huge then
                            v339.Health = 1e999
                        end
                    end)

                    return
                end
            end
        else
            if p14.GodMode.Connection then
                p14.GodMode.Connection:Disconnect()
                p14.GodMode.Connection = nil
            end

            local Character = t1[14].Character

            if Character then
                local v341 = t1[16].GetHumanoid(Character)

                if v341 then
                    v341.MaxHealth = p14.GodMode.OriginalMaxHealth or 100
                    v341.Health = math.min(p14.GodMode.OriginalHealth or 100, v341.MaxHealth)
                end
            end
        end
    end
    t1[18].ToggleSpinbot = function(p16, p17)
        p16.Spinbot.Enabled = p17

        if p17 then
            p16.Spinbot.Connection = t1[4].Heartbeat:Connect(function()
                if not p16.Spinbot.Enabled then
                    return
                end

                local Character = t1[14].Character

                if not Character then
                    return
                end

                local v1214 = t1[16].GetCharacterRoot(Character)

                if v1214 then
                    v1214.CFrame = v1214.CFrame * CFrame.Angles(0, math.rad(p16.Spinbot.Speed), 0)
                end
            end)

            return
        end

        if p16.Spinbot.Connection then
            p16.Spinbot.Connection:Disconnect()
            p16.Spinbot.Connection = nil
        end
    end
    t1[18].TeleportForward = function(p18)
        local Character = t1[14].Character

        if not Character then
            return
        end

        local v346 = t1[16].GetCharacterRoot(Character)

        if not v346 then
            return
        end

        local LookVector = t1[3].CurrentCamera.CFrame.LookVector
        local v348 = v346.Position + LookVector * p18.Teleport.Distance
        local ray = Ray.new(v346.Position, v348 - v346.Position)
        local part, position = t1[3]:FindPartOnRay(ray, Character)

        if part then
            v348 = position - LookVector * 2
        end

        v346.CFrame = CFrame.new(v348)
    end
    t1[18].ToggleHeadStalker = function(p19, p20)
        p19.HeadStalker.Enabled = p20

        if p20 then
            local function v354()
                local Character = t1[14].Character
                if not Character then
                    return nil
                end
                local v1216 = t1[16].GetCharacterRoot(Character)
                if not v1216 then
                    return nil
                end
                local n3 = 1e999
                local v1218
                for _, player in ipairs(t1[2]:GetPlayers()) do
                    local v1221 = player ~= t1[14]

                    if v1221 then
                        v1221 = t1[16].IsPlayerKiller(player)
                    end

                    if v1221 then
                        local Character3 = player.Character

                        if Character3 then
                            local v1223 = t1[16].GetCharacterRoot(Character3)

                            if v1223 then
                                local Magnitude = (v1216.Position - v1223.Position).Magnitude

                                if Magnitude < n3 then
                                    n3 = Magnitude
                                    v1218 = player
                                end
                            end
                        end
                    end
                end

                return v1218
            end

            p19.HeadStalker.Target = v354()

            if not p19.HeadStalker.Target then
                p19.HeadStalker.Enabled = false

                return
            end

            p19.HeadStalker.Connection = t1[4].Heartbeat:Connect(function()
                if not p19.HeadStalker.Enabled then
                    return
                end

                local Character = t1[14].Character
                local Character4 = p19.HeadStalker.Target.Character

                if not Character or not Character4 then
                    p19.HeadStalker.Target = v354()

                    if not p19.HeadStalker.Target then
                        p19.HeadStalker.Enabled = false

                        return
                    end

                    Character4 = p19.HeadStalker.Target.Character
                end

                local v1227 = t1[16].GetCharacterRoot(Character)
                local v1228 = t1[16].GetCharacterRoot(Character4)
                local Head = Character4:FindFirstChild("Head")

                if v1227 and v1228 then
                    if Head then
                        Head = Head.Position + Vector3.new(0, p19.HeadStalker.HeightOffset, 0)
                    end

                    if not Head then
                        Head = v1228.Position + Vector3.new(0, 6, 0)
                    end

                    v1227.CFrame = CFrame.new(Head)
                end
            end)

            return
        end

        if p19.HeadStalker.Connection then
            p19.HeadStalker.Connection:Disconnect()
            p19.HeadStalker.Connection = nil
        end

        p19.HeadStalker.Target = nil
    end
    t1[18].ToggleBackStalker = function(p21, p22)
        p21.BackStalker.Enabled = p22

        if p22 then
            local function v357()
                local Character = t1[14].Character
                if not Character then
                    return nil
                end
                local v1231 = t1[16].GetCharacterRoot(Character)
                if not v1231 then
                    return nil
                end
                local v1232
                local n4 = 1e999
                for _, player in ipairs(t1[2]:GetPlayers()) do
                    local v1236 = player ~= t1[14]

                    if v1236 then
                        v1236 = t1[16].IsPlayerKiller(player)
                    end

                    if v1236 then
                        local Character5 = player.Character

                        if Character5 then
                            local v1238 = t1[16].GetCharacterRoot(Character5)

                            if v1238 then
                                local Magnitude = (v1231.Position - v1238.Position).Magnitude

                                if Magnitude < n4 then
                                    n4 = Magnitude
                                    v1232 = player
                                end
                            end
                        end
                    end
                end

                return v1232
            end

            p21.BackStalker.Target = v357()

            if not p21.BackStalker.Target then
                p21.BackStalker.Enabled = false

                return
            end

            p21.BackStalker.Connection = t1[4].Heartbeat:Connect(function()
                if not p21.BackStalker.Enabled then
                    return
                end

                local Character = t1[14].Character
                local Character6 = p21.BackStalker.Target.Character

                if not Character or not Character6 then
                    p21.BackStalker.Target = v357()

                    if not p21.BackStalker.Target then
                        p21.BackStalker.Enabled = false

                        return
                    end

                    Character6 = p21.BackStalker.Target.Character
                end

                local v1242 = t1[16].GetCharacterRoot(Character)
                local v1243 = t1[16].GetCharacterRoot(Character6)

                if v1242 and v1243 then
                    local v1244 = -v1243.CFrame.LookVector * p21.BackStalker.Distance + Vector3.new(0, p21.BackStalker.HeightOffset, 0)

                    v1242.CFrame = CFrame.new(v1243.Position + v1244, v1243.Position)
                end
            end)

            return
        end

        if p21.BackStalker.Connection then
            p21.BackStalker.Connection:Disconnect()
            p21.BackStalker.Connection = nil
        end

        p21.BackStalker.Target = nil
    end
    t1[18].ApplySpeedGlitch = function(p23)
        while true do
            local SpeedGlitchEnabled = p23.SpeedGlitch.Enabled

            if SpeedGlitchEnabled then
                SpeedGlitchEnabled = task.wait()
            end

            if not SpeedGlitchEnabled then
                break
            end

            local Character = t1[14].Character

            if Character then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                local v362 = t1[16].GetHumanoid(Character)
                local v363 = HumanoidRootPart
                if HumanoidRootPart then
                    v363 = v362 and v362.MoveDirection.Magnitude > 0
                end
                if v363 then
                    local VelocityY = HumanoidRootPart.Velocity.Y
                    local v365 = v362.MoveDirection * p23.SpeedGlitch.Value

                    HumanoidRootPart.Velocity = Vector3.new(v365.X, VelocityY, v365.Z)
                end
            end
        end
    end
    t1[18].ToggleSpeedGlitch = function(p24, p25)
        p24.SpeedGlitch.Enabled = p25

        if p25 then
            if p24.SpeedGlitch.Thread then
                coroutine.close(p24.SpeedGlitch.Thread)
            end

            p24.SpeedGlitch.Thread = coroutine.create(function()
                p24:ApplySpeedGlitch()
            end)
            coroutine.resume(p24.SpeedGlitch.Thread)

            return
        end

        if p24.SpeedGlitch.Thread then
            coroutine.close(p24.SpeedGlitch.Thread)
            p24.SpeedGlitch.Thread = nil
        end
    end
    t1[18].ApplySuperJump = function(p26)
        while true do
            local SuperJumpEnabled = p26.SuperJump.Enabled

            if SuperJumpEnabled then
                SuperJumpEnabled = task.wait()
            end

            if not SuperJumpEnabled then
                break
            end

            local Character = t1[14].Character

            if Character then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                local v372 = t1[16].GetHumanoid(Character)
                local v373 = HumanoidRootPart

                if HumanoidRootPart then
                    v373 = v372 and v372.Jump
                end

                if v373 then
                    HumanoidRootPart.Velocity = Vector3.new(HumanoidRootPart.Velocity.X, p26.SuperJump.Power, HumanoidRootPart.Velocity.Z)
                end
            end
        end
    end
    t1[18].ToggleSuperJump = function(p27, p28)
        p27.SuperJump.Enabled = p28

        if p28 then
            if p27.SuperJump.Thread then
                coroutine.close(p27.SuperJump.Thread)
            end

            p27.SuperJump.Thread = coroutine.create(function()
                p27:ApplySuperJump()
            end)
            coroutine.resume(p27.SuperJump.Thread)

            return
        end

        if p27.SuperJump.Thread then
            coroutine.close(p27.SuperJump.Thread)
            p27.SuperJump.Thread = nil
        end
    end
    t1[18].ToggleMoonwalk = function(p29, p30)
        p29.Moonwalk.Enabled = p30

        if p29.Moonwalk.Connection then
            p29.Moonwalk.Connection:Disconnect()
            p29.Moonwalk.Connection = nil
        end

        if p30 then
            local Character = t1[14].Character

            if Character then
                local v379 = t1[16].GetCharacterRoot(Character)

                if v379 then
                    local _, v381, _ = v379.CFrame:ToEulerAnglesXYZ()

                    p29.Moonwalk.CurrentYaw = v381
                end
            end

            p29.Moonwalk.Connection = t1[4].RenderStepped:Connect(function(dt)
                if not p29.Moonwalk.Enabled then
                    return
                end

                local Character7 = t1[14].Character

                if not Character7 then
                    return
                end

                local v1247 = t1[16].GetCharacterRoot(Character7)
                local v1248 = t1[16].GetHumanoid(Character7)

                if v1247 and v1248 then
                    v1248.AutoRotate = false

                    if v1248.MoveDirection.Magnitude > 0.1 then
                        local v1249 = -v1248.MoveDirection
                        local v1250 = math.sin(tick() * 35)
                        local _math = math
                        local v1252 = v1250 * 0.8
                        local v1253 = (_math.atan2(-v1249.X, -v1249.Z) + v1252 - p29.Moonwalk.CurrentYaw) % 6.283185307179586

                        if v1253 > math.pi then
                            v1253 -= 6.283185307179586
                        end

                        p29.Moonwalk.CurrentYaw = p29.Moonwalk.CurrentYaw + v1253 * (1 - 0.9) * dt * 60
                        v1247.CFrame = CFrame.new(v1247.Position) * CFrame.Angles(0, p29.Moonwalk.CurrentYaw, 0)
                    end
                end
            end)

            return
        end

        p29.Moonwalk.CurrentYaw = 0

        local Character = t1[14].Character

        if Character then
            local v384 = t1[16].GetHumanoid(Character)

            if v384 then
                v384.AutoRotate = true
            end
        end
    end
    t1[18].SetWalkSpeed = function(p31, p32)
        p31.WalkSpeed = p32

        local Character = t1[14].Character

        if Character then
            local v388 = t1[16].GetHumanoid(Character)

            if v388 then
                v388.WalkSpeed = p32
            end

            Character:SetAttribute("speedboost", p32 / 16)
        end
    end
    t1[18].SetVaultSpeed = function(p33, p34)
        p33.VaultSpeed = p34

        local Character = t1[14].Character

        if Character then
            Character:SetAttribute("vaultspeed", p34)
        end
    end
    t1[18].Cleanup = function(p35)
        if p35.Fly.Connection then
            p35.Fly.Connection:Disconnect()
        end

        if p35.NoClip.Connection then
            p35.NoClip.Connection:Disconnect()
        end

        if p35.GodMode.Connection then
            p35.GodMode.Connection:Disconnect()
        end

        if p35.Spinbot.Connection then
            p35.Spinbot.Connection:Disconnect()
        end

        if p35.HeadStalker.Connection then
            p35.HeadStalker.Connection:Disconnect()
        end

        if p35.BackStalker.Connection then
            p35.BackStalker.Connection:Disconnect()
        end

        if p35.SpeedGlitch.Thread then
            coroutine.close(p35.SpeedGlitch.Thread)
        end

        if p35.SuperJump.Thread then
            coroutine.close(p35.SuperJump.Thread)
        end

        if p35.Moonwalk.Connection then
            p35.Moonwalk.Connection:Disconnect()
        end
    end
    t1[19] = {}
    t1[19].__index = t1[19]
    t1[19].new = function()
        local self = setmetatable({}, t1[19])

        self.Settings = t1[17].ESP
        self.PlayerTrackers = {}
        self.GenProgressBillboards = {}
        self.Connections = {}
        self:SetupEventListeners()

        return self
    end
    t1[19].RefreshHighlights = function(p36)
        for _, player in ipairs(t1[2]:GetPlayers()) do
            if player ~= t1[14] and player.Character then
                local Team = player.Team

                if Team then
                    Team = player.Team.Name == "Survivors"
                end

                local Team2 = player.Team

                if Team2 then
                    Team2 = player.Team.Name == "Killer"
                end

                local v399 = Team
                local CustomESP = player.Character:FindFirstChild("CustomESP")

                if Team then
                    v399 = p36.Settings.SurvivorsActive
                end

                if not v399 then
                    if Team2 then
                        Team2 = p36.Settings.KillerActive
                    end

                    v399 = Team2
                end

                if v399 then
                    if not CustomESP then
                        CustomESP = Instance.new("Highlight")
                        CustomESP.Name = "CustomESP"
                        CustomESP.FillTransparency = 1
                        CustomESP.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        CustomESP.Parent = player.Character
                    end

                    if Team then
                        Team = p36.Settings.SurvivorColor
                    end

                    if not Team then
                        Team = p36.Settings.KillerColor
                    end

                    CustomESP.OutlineColor = Team
                elseif CustomESP then
                    CustomESP:Destroy()
                end
            end
        end
    end
    t1[19].UpdateGenESP = function(p37)
        for _, descendant in ipairs(t1[3]:GetDescendants()) do
            local v404 = descendant.Name:lower():find("generator")

            if v404 then
                v404 = descendant:IsA("Model")

                if not v404 then
                    v404 = descendant:IsA("BasePart")
                end
            end

            if v404 then
                local GenHL = descendant:FindFirstChild("GenHL")

                if p37.Settings.GenActive then
                    if not GenHL then
                        GenHL = Instance.new("Highlight", descendant)
                        GenHL.Name = "GenHL"
                        GenHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end

                    GenHL.FillColor = p37.Settings.GenColor
                    GenHL.OutlineColor = Color3.new(1, 1, 1)
                    GenHL.FillTransparency = 0.5
                elseif GenHL then
                    GenHL:Destroy()
                end
            end
        end
    end
    t1[19].UpdatePalletESP = function(p38)
        for _, descendant in ipairs(t1[3]:GetDescendants()) do
            if descendant.Name == "Palletwrong" then
                local PalletHL = descendant:FindFirstChild("PalletHL")

                if p38.Settings.PalletsActive then
                    if not PalletHL then
                        PalletHL = Instance.new("Highlight", descendant)
                        PalletHL.Name = "PalletHL"
                        PalletHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end

                    PalletHL.FillColor = p38.Settings.PalletColor
                    PalletHL.OutlineColor = p38.Settings.PalletColor
                    PalletHL.FillTransparency = 0.5
                elseif PalletHL then
                    PalletHL:Destroy()
                end
            end
        end
    end
    t1[19].UpdateTracers = function(p39)
        if not p39.Settings.TracersActive then
            return
        end

        local SurvivorsActive = p39.Settings.SurvivorsActive

        if not SurvivorsActive then
            SurvivorsActive = p39.Settings.KillerActive
        end

        if not SurvivorsActive then
            return
        end

        for _, player in ipairs(t1[2]:GetPlayers()) do
            if player ~= t1[14] then
                local Character = player.Character

                if Character then
                    Character = t1[16].GetCharacterRoot(Character)
                end

                local Team = player.Team

                if Team then
                    Team = player.Team.Name == "Survivors"
                end

                local Team3 = player.Team

                if Team3 then
                    Team3 = player.Team.Name == "Killer"
                end

                local v417 = Team

                if Team then
                    v417 = p39.Settings.SurvivorsActive
                end

                if not v417 then
                    if Team3 then
                        Team3 = p39.Settings.KillerActive
                    end

                    v417 = Team3
                end

                if v417 then
                    v417 = Character
                end

                if v417 then
                    local v419, t59Result = t1[8]:WorldToViewportPoint(Character.Position)
                    if t59Result then
                        local v420 = p39.PlayerTrackers[player]
                        local v421 = not v420

                        if not v421 then
                            v421 = type(v420) ~= "userdata"
                        end

                        if v421 then
                            v420 = Drawing.new("Line")
                            p39.PlayerTrackers[player] = v420
                        end

                        if v420 and v420.Visible ~= nil then
                            v420.Visible = true
                            v420.From = Vector2.new(t1[8].ViewportSize.X / 2, 0)
                            v420.To = Vector2.new(v419.X, v419.Y)

                            if Team then
                                Team = p39.Settings.SurvivorColor
                            end

                            if not Team then
                                Team = p39.Settings.KillerColor
                            end

                            v420.Color = Team
                            v420.Thickness = 1.5
                            v420.Transparency = 1
                        end
                    else
                        local v422 = p39.PlayerTrackers[player]
                        local v423 = v422

                        if v422 then
                            v423 = type(v422) == "userdata" and v422.Visible ~= nil
                        end

                        if v423 then
                            v422.Visible = false
                        end
                    end
                else
                    local v424 = p39.PlayerTrackers[player]
                    local v425 = v424

                    if v424 then
                        v425 = type(v424) == "userdata" and v424.Visible ~= nil
                    end

                    if v425 then
                        v424.Visible = false
                    end
                end
            end
        end
    end
    t1[19].GetRepairValue = function(_, p41)
        local v428 = p41:GetAttribute("RepairProgress") or p41:GetAttribute("Progress")

        if v428 ~= nil then
            return v428
        end

        for _, descendant in ipairs(p41:GetDescendants()) do
            local v431 = descendant:GetAttribute("RepairProgress") or descendant:GetAttribute("Progress")

            if v431 ~= nil then
                return v431
            end
        end

        return nil
    end
    t1[19].CreateGenProgressUI = function(p42, p43)
        if p42.GenProgressBillboards[p43] then
            return
        end

        local BillboardGui = Instance.new("BillboardGui", p43)

        BillboardGui.Name = "GenProgressUI"
        BillboardGui.Size = UDim2.new(0, 100, 0, 40)
        BillboardGui.StudsOffset = Vector3.new(0, 8, 0)
        BillboardGui.AlwaysOnTop = true

        local TextLabel = Instance.new("TextLabel", BillboardGui)

        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.TextSize = 16
        TextLabel.TextColor3 = p42.Settings.GenProgressColor
        p42.GenProgressBillboards[p43] = BillboardGui
        task.spawn(function()
            while true do
                local GenProgressActive = p42.Settings.GenProgressActive

                if GenProgressActive then
                    GenProgressActive = BillboardGui

                    if GenProgressActive then
                        GenProgressActive = BillboardGui.Parent
                    end
                end

                if not GenProgressActive then
                    break
                end

                local v1255 = p42:GetRepairValue(p43) or 0

                TextLabel.Text = math.clamp(math.floor(v1255 <= 1.1 and v1255 * 100 or v1255), 0, 100) .. "%"
                TextLabel.TextColor3 = p42.Settings.GenProgressColor
                task.wait(0.5)
            end

            BillboardGui:Destroy()
            p42.GenProgressBillboards[p43] = nil
        end)
    end
    t1[19].UpdateGenProgress = function(p44, p45)
        p44.Settings.GenProgressActive = p45

        if not p45 then
            for _, v in pairs(p44.GenProgressBillboards) do
                if v then
                    v:Destroy()
                end
            end

            p44.GenProgressBillboards = {}

            return
        end

        for _, descendant in ipairs(t1[3]:GetDescendants()) do
            local v442 = descendant:IsA("Model")

            if v442 then
                v442 = descendant.Name:lower():find("generator")
            end

            if v442 and p44:GetRepairValue(descendant) then
                p44:CreateGenProgressUI(descendant)
            end
        end
    end
    t1[19].SetupEventListeners = function(p46)
        p46.Connections.RenderTracers = t1[4].RenderStepped:Connect(function()
            p46:UpdateTracers()
        end)
        p46.Connections.PlayerRemoving = t1[2].PlayerRemoving:Connect(function(player)
            local v1257 = p46.PlayerTrackers[player]
            local v1258 = v1257

            if v1257 then
                v1258 = type(v1257) == "userdata"
            end

            if v1258 then
                v1257:Remove()
            end

            p46.PlayerTrackers[player] = nil
        end)

        local Remotes = t1[6]:FindFirstChild("Remotes")

        if Remotes then
            Remotes = t1[6].Remotes:FindFirstChild("Round")
        end

        if Remotes then
            p46.Connections.Round = Remotes.OnClientEvent:Connect(function()
                task.wait(2)
                p46:RefreshAll()
            end)
        end

        p46.Connections.DescendantAdded = t1[3].DescendantAdded:Connect(function(descendant)
            local GenActive = p46.Settings.GenActive

            if GenActive then
                GenActive = descendant.Name:lower():find("generator")

                if not GenActive then
                    GenActive = descendant.Name:lower():find("gen")
                end
            end

            if GenActive then
                local v1261 = descendant:IsA("BasePart")

                if not v1261 then
                    v1261 = descendant:IsA("Model")
                end

                if v1261 then
                    local GenHL = descendant:FindFirstChild("GenHL")

                    if not GenHL then
                        GenHL = Instance.new("Highlight", descendant)
                        GenHL.Name = "GenHL"
                        GenHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end

                    GenHL.FillColor = p46.Settings.GenColor
                    GenHL.OutlineColor = Color3.new(1, 1, 1)
                    GenHL.FillTransparency = 0.5
                end

                local GenProgressActive = p46.Settings.GenProgressActive

                if GenProgressActive then
                    GenProgressActive = descendant:IsA("Model") and p46:GetRepairValue(descendant)
                end

                if GenProgressActive then
                    p46:CreateGenProgressUI(descendant)
                end
            end

            local PalletsActive = p46.Settings.PalletsActive

            if PalletsActive then
                PalletsActive = descendant.Name == "Palletwrong"
            end

            if PalletsActive then
                local PalletHL = descendant:FindFirstChild("PalletHL")

                if not PalletHL then
                    PalletHL = Instance.new("Highlight", descendant)
                    PalletHL.Name = "PalletHL"
                    PalletHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end

                PalletHL.FillColor = p46.Settings.PalletColor
                PalletHL.OutlineColor = p46.Settings.PalletColor
                PalletHL.FillTransparency = 0.5
            end

            local v1266 = descendant:IsA("Model")

            if v1266 then
                v1266 = descendant:FindFirstChild("Humanoid")

                if v1266 then
                    v1266 = t1[2]:GetPlayerFromCharacter(descendant) and t1[2]:GetPlayerFromCharacter(descendant) ~= t1[14]
                end
            end

            if v1266 then
                task.wait(0.1)
                p46:RefreshHighlights()
            end
        end)
        p46.Connections.PlayerAdded = t1[2].PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                p46:RefreshHighlights()
            end)
        end)
        p46.Connections.LocalCharacterAdded = t1[14].CharacterAdded:Connect(function()
            task.wait(1)
            p46:RefreshAll()
        end)
    end
    t1[19].RefreshAll = function(p47)
        p47:RefreshHighlights()
        p47:UpdateGenESP()
        p47:UpdatePalletESP()

        if p47.Settings.GenProgressActive then
            p47:UpdateGenProgress(true)
        end
    end
    t1[19].ToggleSurvivor = function(p48, p49)
        p48.Settings.SurvivorsActive = p49
        p48:RefreshHighlights()
    end
    t1[19].ToggleKiller = function(p50, p51)
        p50.Settings.KillerActive = p51
        p50:RefreshHighlights()
    end
    t1[19].ToggleGen = function(p52, p53)
        p52.Settings.GenActive = p53
        p52:UpdateGenESP()
    end
    t1[19].TogglePallet = function(p54, p55)
        p54.Settings.PalletsActive = p55
        p54:UpdatePalletESP()
    end
    t1[19].ToggleTracers = function(p56, p57)
        p56.Settings.TracersActive = p57
    end
    t1[19].Cleanup = function(p58)
        for _, v in pairs(p58.Connections) do
            if v then
                v:Disconnect()
            end
        end
        for v461, v462 in pairs(p58.PlayerTrackers) do

            local v463 = v462

            if v462 then
                v463 = type(v462) == "userdata"
            end

            if v463 then
                v462:Remove()
            end
        end
        p58.PlayerTrackers = {}
        for _, v in pairs(p58.GenProgressBillboards) do
            if v then
                v:Destroy()
            end
        end
        p58.GenProgressBillboards = {}
    end
    t1[20] = {}
    t1[20].__index = t1[20]
    t1[20].new = function()
        local self = setmetatable({}, t1[20])
        local AimbotEnabled = t1[17].Combat.Aimbot.Enabled
        local Smoothness = t1[17].Combat.Aimbot.Smoothness
        local FOV = t1[17].Combat.Aimbot.FOV
        local TeamCheck = t1[17].Combat.Aimbot.TeamCheck
        local VisibleCheck = t1[17].Combat.Aimbot.VisibleCheck

        self.Aimbot = {
			Enabled = AimbotEnabled,
			Target = nil,
			Smoothness = Smoothness,
			FOV = FOV,
			TeamCheck = TeamCheck,
			VisibleCheck = VisibleCheck,
			Connection = nil
		}

        local ChamsEnabled = t1[17].Combat.Chams.Enabled
        local ChamsColor = t1[17].Combat.Chams.Color
        local ChamsTransparency = t1[17].Combat.Chams.Transparency
        local FillMode = t1[17].Combat.Chams.FillMode

        self.Chams = {
			Enabled = ChamsEnabled,
			Color = ChamsColor,
			Transparency = ChamsTransparency,
			FillMode = FillMode,
			Players = {}
		}

        local CustomCrosshairsEnabled = t1[17].Combat.CustomCrosshairs.Enabled
        local CustomCrosshairsType = t1[17].Combat.CustomCrosshairs.Type
        local CustomCrosshairsSize = t1[17].Combat.CustomCrosshairs.Size
        local CustomCrosshairsColor = t1[17].Combat.CustomCrosshairs.Color
        local Gap = t1[17].Combat.CustomCrosshairs.Gap
        local CustomCrosshairsThickness = t1[17].Combat.CustomCrosshairs.Thickness
        local Outline = t1[17].Combat.CustomCrosshairs.Outline
        local OutlineColor = t1[17].Combat.CustomCrosshairs.OutlineColor

        self.Crosshair = {
			Enabled = CustomCrosshairsEnabled,
			Type = CustomCrosshairsType,
			Size = CustomCrosshairsSize,
			Color = CustomCrosshairsColor,
			Gap = Gap,
			Thickness = CustomCrosshairsThickness,
			Outline = Outline,
			OutlineColor = OutlineColor,
			ScreenGui = nil
		}
        self.KillAura = {
			Enabled = t1[17].Fun.KillAura.Enabled,
			Connection = nil
		}

        return self
    end
    t1[20].GetClosestPlayerToCursor = function(p59)
        if not p59.Aimbot.Enabled then
            return nil
        end
        local CurrentCamera = t1[3].CurrentCamera
        local MouseLocation = t1[5]:GetMouseLocation()
        local v487
        local FOV = p59.Aimbot.FOV
        for _, player in ipairs(t1[2]:GetPlayers()) do
            if player ~= t1[14] and player.Character then
                local v491 = t1[16].IsPlayerKiller(player)
                local TeamCheck = p59.Aimbot.TeamCheck

                if TeamCheck then
                    TeamCheck = not v491
                end

                if not TeamCheck then
                    local Character = player.Character
                    local Head = Character:FindFirstChild("Head")
                    local v495 = t1[16].GetCharacterRoot(Character)
                    local v496 = Head and Head.Position

                    if not v496 then
                        v496 = v495 and v495.Position
                    end

                    if v496 then
                        local v497, v498 = CurrentCamera:WorldToViewportPoint(v496)

                        if v498 then
                            local Magnitude = (Vector2.new(MouseLocation.X, MouseLocation.Y) - Vector2.new(v497.X, v497.Y)).Magnitude

                            if Magnitude < FOV then
                                if p59.Aimbot.VisibleCheck then
                                    local ray = Ray.new(CurrentCamera.CFrame.Position, (v496 - CurrentCamera.CFrame.Position).Unit * 1000)
                                    local PartOnRayWithIgnoreList = t1[3]:FindPartOnRayWithIgnoreList(ray, {
										t1[14].Character,
										CurrentCamera
									})

                                    if PartOnRayWithIgnoreList and PartOnRayWithIgnoreList:IsDescendantOf(Character) then
                                        FOV = Magnitude
                                        v487 = player
                                    end
                                else
                                    v487 = player
                                    FOV = Magnitude
                                end
                            end
                        end
                    end
                end
            end
        end

        return v487
    end
    t1[20].AimbotUpdate = function(p60)
        if not p60.Aimbot.Enabled then
            return
        end

        local ClosestPlayerToCursor = p60:GetClosestPlayerToCursor()

        p60.Aimbot.Target = ClosestPlayerToCursor

        if not ClosestPlayerToCursor or not ClosestPlayerToCursor.Character then
            return
        end

        local Character = ClosestPlayerToCursor.Character
        local Head = Character:FindFirstChild("Head")
        local v506 = t1[16].GetCharacterRoot(Character)
        local v507 = Head and Head.Position

        if not v507 then
            v507 = v506 and v506.Position
        end

        if not v507 then
            return
        end

        local CurrentCamera = t1[3].CurrentCamera
        local CurrentCameraCFrame = CurrentCamera.CFrame
        local Unit = (v507 - CurrentCameraCFrame.Position).Unit
        local v511 = CurrentCameraCFrame.LookVector:Lerp(Unit, 1 / p60.Aimbot.Smoothness)

        CurrentCamera.CFrame = CFrame.new(CurrentCameraCFrame.Position, CurrentCameraCFrame.Position + v511)
    end
    t1[20].ToggleAimbot = function(p61, p62)
        p61.Aimbot.Enabled = p62

        if p62 then
            if not p61.Aimbot.Connection then
                p61.Aimbot.Connection = t1[4].RenderStepped:Connect(function()
                    p61:AimbotUpdate()
                end)

                return
            end
        else
            if p61.Aimbot.Connection then
                p61.Aimbot.Connection:Disconnect()
                p61.Aimbot.Connection = nil
            end

            p61.Aimbot.Target = nil
        end
    end
    t1[20].ToggleChams = function(p63, p64)
        p63.Chams.Enabled = p64

        if p64 then
            local function v516(p65)
                if p63.Chams.Players[p65] then
                    return
                end

                local Character = p65.Character

                if not Character then
                    return
                end

                local Highlight = Instance.new("Highlight")

                Highlight.Name = p65.Name .. "_Chams"
                Highlight.FillColor = p63.Chams.Color
                Highlight.OutlineColor = p63.Chams.Color
                Highlight.FillTransparency = p63.Chams.Transparency
                Highlight.OutlineTransparency = 0
                Highlight.DepthMode = Enum.HighlightDepthMode[p63.Chams.FillMode]
                Highlight.Adornee = Character
                Highlight.Parent = t1[3]
                p63.Chams.Players[p65] = Highlight
                p65.CharacterAdded:Connect(function(character)
                    task.wait(1)

                    if p63.Chams.Players[p65] then
                        p63.Chams.Players[p65]:Destroy()
                    end

                    local Highlight2 = Instance.new("Highlight")

                    Highlight2.Name = p65.Name .. "_Chams"
                    Highlight2.FillColor = p63.Chams.Color
                    Highlight2.OutlineColor = p63.Chams.Color
                    Highlight2.FillTransparency = p63.Chams.Transparency
                    Highlight2.OutlineTransparency = 0
                    Highlight2.DepthMode = Enum.HighlightDepthMode[p63.Chams.FillMode]
                    Highlight2.Adornee = character
                    Highlight2.Parent = t1[3]
                    p63.Chams.Players[p65] = Highlight2
                end)
            end

            for _, player in ipairs(t1[2]:GetPlayers()) do
                if player ~= t1[14] then
                    v516(player)
                end
            end

            t1[2].PlayerAdded:Connect(function(player)
                task.wait(1)

                if p63.Chams.Enabled then
                    v516(player)
                end
            end)

            return
        end

        for _, v in pairs(p63.Chams.Players) do
            if v then
                v:Destroy()
            end
        end

        p63.Chams.Players = {}
    end
    t1[20].UpdateCrosshair = function(p66)
        if not p66.Crosshair.Enabled then
            return
        end

        if p66.Crosshair.ScreenGui then
            p66.Crosshair.ScreenGui:Destroy()
        end

        local ScreenGui = Instance.new("ScreenGui")

        ScreenGui.Name = "CustomCrosshairGUI"
        ScreenGui.Parent = t1[14]:WaitForChild("PlayerGui")
        ScreenGui.ResetOnSpawn = false

        local n5 = 0.5
        local n6 = 0.5
        local Gap = p66.Crosshair.Gap
        local CrosshairThickness = p66.Crosshair.Thickness
        local CrosshairSize = p66.Crosshair.Size

        if p66.Crosshair.Type == "Dot" then
            local Frame = Instance.new("Frame")

            Frame.Size = UDim2.new(0, CrosshairSize, 0, CrosshairSize)
            Frame.Position = UDim2.new(n5, -CrosshairSize / 2, n6, -CrosshairSize / 2)
            Frame.BackgroundColor3 = p66.Crosshair.Color
            Frame.BorderSizePixel = 0

            if p66.Crosshair.Outline then
                local UIStroke = Instance.new("UIStroke")

                UIStroke.Color = p66.Crosshair.OutlineColor
                UIStroke.Thickness = 2
                UIStroke.Parent = Frame
            end

            local UICorner = Instance.new("UICorner")

            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = Frame
            Frame.Parent = ScreenGui
        elseif p66.Crosshair.Type == "Cross" then
            local t60 = {}
            local Frame = Instance.new("Frame")

            Frame.Size = UDim2.new(0, CrosshairSize, 0, CrosshairThickness)
            Frame.Position = UDim2.new(n5, -CrosshairSize / 2, n6, -CrosshairThickness / 2 - Gap)
            Frame.BackgroundColor3 = p66.Crosshair.Color
            Frame.BorderSizePixel = 0
            table.insert(t60, Frame)

            local Frame2 = Instance.new("Frame")

            Frame2.Size = UDim2.new(0, CrosshairSize, 0, CrosshairThickness)
            Frame2.Position = UDim2.new(n5, -CrosshairSize / 2, n6, CrosshairThickness / 2 + Gap)
            Frame2.BackgroundColor3 = p66.Crosshair.Color
            Frame2.BorderSizePixel = 0
            table.insert(t60, Frame2)

            local Frame3 = Instance.new("Frame")

            Frame3.Size = UDim2.new(0, CrosshairThickness, 0, CrosshairSize)
            Frame3.Position = UDim2.new(n5, -CrosshairThickness / 2 - Gap, n6, -CrosshairSize / 2)
            Frame3.BackgroundColor3 = p66.Crosshair.Color
            Frame3.BorderSizePixel = 0
            table.insert(t60, Frame3)

            local Frame4 = Instance.new("Frame")

            Frame4.Size = UDim2.new(0, CrosshairThickness, 0, CrosshairSize)
            Frame4.Position = UDim2.new(n5, CrosshairThickness / 2 + Gap, n6, -CrosshairSize / 2)
            Frame4.BackgroundColor3 = p66.Crosshair.Color
            Frame4.BorderSizePixel = 0
            table.insert(t60, Frame4)

            if p66.Crosshair.Outline then
                for _, v in ipairs(t60) do
                    local UIStroke = Instance.new("UIStroke")

                    UIStroke.Color = p66.Crosshair.OutlineColor
                    UIStroke.Thickness = 1
                    UIStroke.Parent = v
                end
            end

            for _, v in ipairs(t60) do
                v.Parent = ScreenGui
            end
        elseif p66.Crosshair.Type == "Circle" then
            local Frame = Instance.new("Frame")

            Frame.Size = UDim2.new(0, CrosshairSize, 0, CrosshairSize)
            Frame.Position = UDim2.new(n5, -CrosshairSize / 2, n6, -CrosshairSize / 2)
            Frame.BackgroundTransparency = 1

            local UICorner = Instance.new("UICorner")

            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = Frame

            local UIStroke = Instance.new("UIStroke")

            UIStroke.Color = p66.Crosshair.Color
            UIStroke.Thickness = CrosshairThickness
            UIStroke.Parent = Frame

            if p66.Crosshair.Outline then
                local UIStroke2 = Instance.new("UIStroke")

                UIStroke2.Color = p66.Crosshair.OutlineColor
                UIStroke2.Thickness = CrosshairThickness + 2
                UIStroke2.Parent = Frame
            end

            Frame.Parent = ScreenGui
        elseif p66.Crosshair.Type == "Square" then
            local Frame = Instance.new("Frame")

            Frame.Size = UDim2.new(0, CrosshairSize, 0, CrosshairSize)
            Frame.Position = UDim2.new(n5, -CrosshairSize / 2, n6, -CrosshairSize / 2)
            Frame.BackgroundColor3 = p66.Crosshair.Color
            Frame.BackgroundTransparency = 0.3
            Frame.BorderSizePixel = 0

            if p66.Crosshair.Outline then
                local UIStroke = Instance.new("UIStroke")

                UIStroke.Color = p66.Crosshair.OutlineColor
                UIStroke.Thickness = 1
                UIStroke.Parent = Frame
            end

            Frame.Parent = ScreenGui
        end

        p66.Crosshair.ScreenGui = ScreenGui
    end
    t1[20].ToggleCrosshair = function(p67, p68)
        p67.Crosshair.Enabled = p68

        if p68 then
            p67:UpdateCrosshair()

            return
        end

        if p67.Crosshair.ScreenGui then
            p67.Crosshair.ScreenGui:Destroy()
            p67.Crosshair.ScreenGui = nil
        end
    end
    t1[20].ToggleKillAura = function(p69, p70)
        p69.KillAura.Enabled = p70

        if p70 then
            local Remotes = t1[6]:FindFirstChild("Remotes")

            if Remotes then
                Remotes = t1[6].Remotes:FindFirstChild("Attacks")

                if Remotes then
                    Remotes = t1[6].Remotes.Attacks:FindFirstChild("hit")
                end
            end

            local v552 = Remotes
            local Remotes2 = t1[6]:FindFirstChild("Remotes")

            if Remotes2 then
                Remotes2 = t1[6].Remotes:FindFirstChild("Attacks")

                if Remotes2 then
                    Remotes2 = t1[6].Remotes.Attacks:FindFirstChild("BasicAttack")
                end
            end

            local v554 = Remotes2

            p69.KillAura.Connection = t1[4].Heartbeat:Connect(function()
                if not p69.KillAura.Enabled then
                    return
                end

                if v552 then
                    for _, player in ipairs(t1[2]:GetPlayers()) do
                        local v1274 = player
                        local v1275 = v1274 ~= t1[14]

                        if v1275 then
                            v1275 = v1274.Character
                        end

                        if v1275 then
                            pcall(function()
                                v552:FireServer(v1274.Character)
                            end)
                        end
                    end
                end

                if v554 then
                    pcall(function()
                        v554:FireServer()
                    end)
                end

                local Character = t1[14].Character

                if Character then
                    local v1277 = t1[16].GetHumanoid(Character)

                    if v1277 and v1277.WalkSpeed ~= t1[15] then
                        v1277.WalkSpeed = t1[15]
                    end
                end
            end)

            return
        end

        if p69.KillAura.Connection then
            p69.KillAura.Connection:Disconnect()
            p69.KillAura.Connection = nil
        end
    end
    t1[20].Cleanup = function(p71)
        if p71.Aimbot.Connection then
            p71.Aimbot.Connection:Disconnect()
        end

        if p71.KillAura.Connection then
            p71.KillAura.Connection:Disconnect()
        end

        for _, v in pairs(p71.Chams.Players) do
            if v then
                v:Destroy()
            end
        end

        p71.Chams.Players = {}

        if p71.Crosshair.ScreenGui then
            p71.Crosshair.ScreenGui:Destroy()
        end
    end
    t1[21] = {}
    t1[21].__index = t1[21]
    t1[21].new = function()
        local self = setmetatable({}, t1[21])

        self.NoSlowdown = {
			Enabled = t1[17].Survivor.NoSlowdown.Enabled,
			Connection = nil
		}
        self.NoFall = {
			Enabled = t1[17].Survivor.NoFall.Enabled,
			Hooked = false,
			OriginalNamecall = nil
		}
        self.NoHitbox = {
			Enabled = t1[17].Survivor.NoHitbox.Enabled,
			TeamListeners = {}
		}

        local AutoParryEnabled = t1[17].Survivor.AutoParry.Enabled
        local AutoParryRange = t1[17].Survivor.AutoParry.Range

        self.AutoParry = {
			Enabled = AutoParryEnabled,
			Range = AutoParryRange,
			SpamActive = false,
			AnimConnections = {},
			TeamListeners = {}
		}

        local AutoParryV2Enabled = t1[17].Survivor.AutoParryV2.Enabled
        local AutoParryV2Range = t1[17].Survivor.AutoParryV2.Range

        self.AutoParryV2 = {
			Enabled = AutoParryV2Enabled,
			Range = AutoParryV2Range,
			LastArmPos = nil,
			LastDelta = 0,
			OnCooldown = false,
			Connection = nil,
			TeamListeners = {}
		}
        self.FakeParry = {
			Enabled = t1[17].Survivor.FakeParry.Enabled,
			AnimTrack = nil,
			CharConn = nil,
			TeamListeners = {}
		}
        self.TwistSilentAim = {
			Enabled = t1[17].Survivor.TwistSilentAim.Enabled,
			Hooked = false,
			Remote = nil,
			OriginalNamecall = nil,
			TeamListeners = {}
		}
        self.ParryCircle = {
			Enabled = t1[17].Survivor.ParryCircle.Enabled,
			Circle = nil,
			Connection = nil,
			TeamListeners = {}
		}
        self.AutoSkillcheck = {
			Enabled = t1[17].Survivor.AutoSkillcheck.Enabled
		}
        self.QuickRepair = {
			NoClipActive = false,
			NoClipRestore = {}
		}

        local EmoteWheelEnabled = t1[17].Survivor.EmoteWheel.Enabled
        local Default = Enum.MouseBehavior.Default
        local t61 = {
			name = "The Dab",
			id = 93350677984372
		}
        local t62 = {
			name = "Backflip",
			id = 74705617908505
		}
        local t63 = {
			name = "Rampage",
			id = 79155929355612
		}
        local t64 = {
			name = "Source",
			id = 122615684039120
		}
        local t65 = {
			name = "24 Hour Cinderella",
			id = 137195203725370
		}
        local t66 = {
			name = "Wave",
			id = 99670106766588
		}
        local t67 = {
			name = "Applause",
			id = 96328361165090
		}
        local t68 = {
			name = "Schadenfreude",
			id = 138303785534050
		}
        local t69 = {
			name = "California Girls",
			id = 123552803041500
		}
        local t70 = {
			name = "Kyoufuu",
			id = 137322894494530
		}
        local t71 = {
			name = "Rambunctious",
			id = 81054496834622
		}
        local t72 = {
			name = "Floating Rest",
			id = 114593021219597
		}
        local t73 = {
			name = "Static",
			id = 95096724457263
		}
        local t74 = {
			name = "Arm Swing",
			id = 80552139463944
		}
        local t75 = {
			name = "Griddy",
			id = 75586690784894
		}
        local t76 = {
			name = "Thriller",
			id = 99835792883875
		}
        local t77 = {
			name = "Ghoul",
			id = 130415594909401
		}
        local t78 = {
			name = "Mannrobics",
			id = 134677515695160
		}
        local t79 = {
			name = "Tor Monitor Ketua",
			id = 81792358514569
		}
        local t80 = {
			name = "Christmas Spirit",
			id = 137859761110510
		}
        local t81 = {
			name = "Quick Combo",
			id = 105592621576600
		}
        local t82 = {
			name = "Broken Doll",
			id = 131796630104820
		}
        local t83 = {
			name = "Friday Night",
			id = 83229063951016
		}
        local t84 = {
			name = "OnePlays",
			id = 140625405103470
		}
        local t85 = {
			name = "WarCry",
			id = 82600868380136
		}
        local t86 = {
			name = "Pop Off",
			id = 130933486827090
		}
        local t87 = {
			name = "Kwik Flip",
			id = 73896868179198
		}
        local t88 = {
			name = "Vulnerable",
			id = 121773684313910
		}

        self.EmoteWheel = {
			Enabled = EmoteWheelEnabled,
			Gui = nil,
			bg = nil,
			overlay = nil,
			pageText = nil,
			buttons = {},
			modalButton = nil,
			currentPage = 1,
			currentTrack = nil,
			currentEmoteId = nil,
			isOpen = false,
			cursorLoopConnection = nil,
			restoreTask = nil,
			savedMouseBehavior = Default,
			savedMouseIcon = true,
			Connections = {},
			EMOTES = {
				t61,
				t62,
				t63,
				t64,
				t65,
				t66,
				t67,
				t68,
				t69,
				t70,
				t71,
				t72,
				t73,
				t74,
				t75,
				t76,
				t77,
				t78,
				t79,
				t80,
				t81,
				t82,
				t83,
				t84,
				t85,
				t86,
				t87,
				t88
			}
		}
        self.EmoteWheel.PAGES = {}

        local EMOTES = self.EmoteWheel.EMOTES

        for i = 1, #EMOTES, 7 do
            local t89 = {}
            local min = math.min
            local v597 = #EMOTES

            for j = i, min(i + 6, v597) do
                table.insert(t89, EMOTES[j])
            end

            table.insert(self.EmoteWheel.PAGES, t89)
        end

        return self
    end
    t1[21].StopEmote = function(p72)
        local EmoteWheel = p72.EmoteWheel

        if EmoteWheel.currentTrack then
            pcall(function()
                EmoteWheel.currentTrack:Stop()
            end)
            EmoteWheel.currentTrack = nil
            EmoteWheel.currentEmoteId = nil
        end
    end
    t1[21].StopCursorUnlock = function(p73)
        local EmoteWheel = p73.EmoteWheel

        if EmoteWheel.cursorLoopConnection then
            EmoteWheel.cursorLoopConnection:Disconnect()
            EmoteWheel.cursorLoopConnection = nil
        end
    end
    t1[21].CloseEmoteMenu = function(p74)
        local EmoteWheel = p74.EmoteWheel

        if not EmoteWheel.isOpen then
            return
        end

        EmoteWheel.isOpen = false
        p74:StopCursorUnlock()

        if EmoteWheel.restoreTask then
            task.cancel(EmoteWheel.restoreTask)
            EmoteWheel.restoreTask = nil
        end

        if EmoteWheel.modalButton then
            EmoteWheel.modalButton.Visible = false
            EmoteWheel.modalButton.Modal = false
        end

        if EmoteWheel.bg then
            EmoteWheel.bg.Visible = false
        end

        if EmoteWheel.overlay then
            EmoteWheel.overlay.Visible = false
        end

        if EmoteWheel.pageText then
            EmoteWheel.pageText.Visible = false
        end

        if EmoteWheel.buttons then
            for _, v in ipairs(EmoteWheel.buttons) do
                v.button.Visible = false
            end
        end

        pcall(function()
            t1[5].MouseBehavior = Enum.MouseBehavior.Default
            t1[5].MouseIconEnabled = true
        end)
        EmoteWheel.restoreTask = task.spawn(function()
            task.wait(0.05)
            pcall(function()
                t1[5].MouseBehavior = EmoteWheel.savedMouseBehavior
                t1[5].MouseIconEnabled = EmoteWheel.savedMouseIcon
            end)
            task.wait(0.1)
            pcall(function()
                t1[5].MouseBehavior = EmoteWheel.savedMouseBehavior
                t1[5].MouseIconEnabled = EmoteWheel.savedMouseIcon
            end)
            EmoteWheel.restoreTask = nil
        end)
    end
    t1[21].PlayEmote = function(p75, p76)
        local EmoteWheel = p75.EmoteWheel
        local v610 = p76 == EmoteWheel.currentEmoteId

        if v610 then
            v610 = EmoteWheel.currentTrack

            if v610 then
                v610 = EmoteWheel.currentTrack.IsPlaying
            end
        end

        if v610 then
            p75:StopEmote()
            p75:CloseEmoteMenu()

            return
        end

        p75:StopEmote()

        local Character = t1[14].Character

        if not Character then
            return
        end

        local v612 = t1[16].GetHumanoid(Character)
        local v613 = v612 and v612:FindFirstChildOfClass("Animator")

        if not v613 then
            if v612 then
                v612 = v612:WaitForChild("Animator", 2)
            end

            v613 = v612
        end

        local v614 = v613

        if not v614 then
            return
        end

        local Animation = Instance.new("Animation")

        Animation.AnimationId = "rbxassetid://" .. p76

        local ok, result = pcall(function()
            return v614:LoadAnimation(Animation)
        end)

        if ok and result then
            EmoteWheel.currentTrack = result
            EmoteWheel.currentTrack.Priority = Enum.AnimationPriority.Action4
            EmoteWheel.currentTrack:Play()
            EmoteWheel.currentEmoteId = p76
        end
    end
    t1[21].UpdateEmotePage = function(p77, p78)
        local EmoteWheel = p77.EmoteWheel
        EmoteWheel.currentPage = p78
        local v621 = EmoteWheel.PAGES[p78]
        if not v621 then
            return
        end
        if EmoteWheel.pageText then
            EmoteWheel.pageText.Text = p78 .. "/" .. #EmoteWheel.PAGES
        end
        for v624, v625 in ipairs(EmoteWheel.buttons) do

            v625.button.Visible = false

            if v625.connection then
                v625.connection:Disconnect()
                v625.connection = nil
            end
        end
        for i, v in ipairs(v621) do
            local v628 = v
            local v629 = EmoteWheel.buttons[i]

            if v629 then
                v629.button.Visible = true
                v629.text.Text = v628.name
                v629.connection = v629.button.MouseButton1Click:Connect(function()
                    p77:PlayEmote(v628.id)
                    p77:CloseEmoteMenu()
                end)
            end
        end
    end
    t1[21].StartCursorUnlock = function(p79)
        local EmoteWheel = p79.EmoteWheel

        p79:StopCursorUnlock()
        EmoteWheel.cursorLoopConnection = t1[4].RenderStepped:Connect(function()
            if EmoteWheel.isOpen then
                t1[5].MouseBehavior = Enum.MouseBehavior.Default
                t1[5].MouseIconEnabled = true

                return
            end

            p79:StopCursorUnlock()
        end)
    end
    t1[21].OpenEmoteMenu = function(p80)
        local EmoteWheel = p80.EmoteWheel

        if EmoteWheel.isOpen then
            return
        end

        EmoteWheel.isOpen = true
        EmoteWheel.savedMouseBehavior = t1[5].MouseBehavior
        EmoteWheel.savedMouseIcon = t1[5].MouseIconEnabled

        if EmoteWheel.bg then
            EmoteWheel.bg.Visible = true
        end

        if EmoteWheel.overlay then
            EmoteWheel.overlay.Visible = true
        end

        if EmoteWheel.pageText then
            EmoteWheel.pageText.Visible = true
        end

        if EmoteWheel.modalButton then
            EmoteWheel.modalButton.Visible = true
            EmoteWheel.modalButton.Modal = true
        end

        pcall(function()
            t1[5].MouseBehavior = Enum.MouseBehavior.Default
            t1[5].MouseIconEnabled = true
        end)
        p80:StartCursorUnlock()
        p80:UpdateEmotePage(EmoteWheel.currentPage)
    end
    t1[21].ToggleEmoteMenu = function(p81)
        if p81.EmoteWheel.isOpen then
            p81:CloseEmoteMenu()

            return
        end

        p81:OpenEmoteMenu()
    end
    t1[21].BuildEmoteGUI = function(p82)
        local EmoteWheel = p82.EmoteWheel

        if EmoteWheel.Gui then
            pcall(function()
                EmoteWheel.Gui:Destroy()
            end)
        end

        local ScreenGui = Instance.new("ScreenGui")

        ScreenGui.Name = "EmoteWheelImproved"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = gethui and gethui() or t1[13]
        EmoteWheel.Gui = ScreenGui

        local Frame = Instance.new("Frame")

        Frame.Size = UDim2.new(1, 0, 1, 0)
        Frame.BackgroundTransparency = 1
        Frame.Visible = false
        Frame.Parent = ScreenGui
        EmoteWheel.bg = Frame

        local TextButton = Instance.new("TextButton")

        TextButton.Name = "ModalControl"
        TextButton.Size = UDim2.new(0, 0, 0, 0)
        TextButton.BackgroundTransparency = 1
        TextButton.Text = ""
        TextButton.Visible = false
        TextButton.Modal = true
        TextButton.Parent = Frame
        EmoteWheel.modalButton = TextButton

        local Frame5 = Instance.new("Frame")

        Frame5.Size = UDim2.new(1, 0, 1, 0)
        Frame5.BackgroundColor3 = Color3.new(0, 0, 0)
        Frame5.BackgroundTransparency = 0.6
        Frame5.Visible = false
        Frame5.Parent = Frame
        EmoteWheel.overlay = Frame5

        local TextLabel = Instance.new("TextLabel")

        TextLabel.Size = UDim2.new(0, 200, 0, 40)
        TextLabel.Position = UDim2.new(0.5, -100, 0.9, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextColor3 = Color3.new(1, 1, 1)
        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.TextSize = 28
        TextLabel.Visible = false
        TextLabel.Parent = Frame
        EmoteWheel.pageText = TextLabel
        EmoteWheel.buttons = {}

        for i = 1, 7 do
            local ImageButton = Instance.new("ImageButton")

            ImageButton.Size = UDim2.new(0, 120, 0, 120)
            ImageButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            ImageButton.BackgroundTransparency = 0.3
            ImageButton.Visible = false
            ImageButton.Parent = Frame
            Instance.new("UICorner", ImageButton).CornerRadius = UDim.new(0, 20)

            local UIStroke = Instance.new("UIStroke", ImageButton)

            UIStroke.Color = Color3.fromRGB(100, 100, 120)
            UIStroke.Thickness = 2
            UIStroke.Transparency = 0.5
            ImageButton.MouseEnter:Connect(function()
                local v1278 = t1[11]
                local v1279 = ImageButton
                local tweenInfo = TweenInfo.new(0.2)
                local Create = v1278.Create
                local uDim2 = UDim2.new(0, 132, 0, 132)

                Create(v1278, v1279, tweenInfo, {
					BackgroundTransparency = 0.1,
					Size = uDim2
				}):Play()

                local v1283 = t1[11]
                local v1284 = UIStroke
                local tweenInfo2 = TweenInfo.new(0.2)
                local color3 = Color3.fromRGB(255, 70, 70)

                v1283:Create(v1284, tweenInfo2, {
					Transparency = 0,
					Color = color3
				}):Play()
            end)
            ImageButton.MouseLeave:Connect(function()
                local v1287 = t1[11]
                local v1288 = ImageButton
                local tweenInfo = TweenInfo.new(0.2)
                local Create = v1287.Create
                local uDim2 = UDim2.new(0, 120, 0, 120)

                Create(v1287, v1288, tweenInfo, {
					BackgroundTransparency = 0.3,
					Size = uDim2
				}):Play()

                local v1292 = t1[11]
                local v1293 = UIStroke
                local tweenInfo3 = TweenInfo.new(0.2)
                local Create2 = v1292.Create
                local color3 = Color3.fromRGB(100, 100, 120)

                Create2(v1292, v1293, tweenInfo3, {
					Transparency = 0.5,
					Color = color3
				}):Play()
            end)

            local TextLabel2 = Instance.new("TextLabel", ImageButton)

            TextLabel2.Size = UDim2.new(1, -10, 1, -10)
            TextLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel2.BackgroundTransparency = 1
            TextLabel2.TextColor3 = Color3.new(1, 1, 1)
            TextLabel2.Font = Enum.Font.GothamBold
            TextLabel2.TextSize = 16
            TextLabel2.TextWrapped = true
            TextLabel2.TextXAlignment = Enum.TextXAlignment.Center
            TextLabel2.TextYAlignment = Enum.TextYAlignment.Center

            local v646 = math.rad((i - 1) * 51.42857142857143 - 90)

            ImageButton.Position = UDim2.new(0.5, math.cos(v646) * 220 - 60, 0.5, math.sin(v646) * 220 - 60)
            table.insert(EmoteWheel.buttons, {
				button = ImageButton,
				text = TextLabel2,
				connection = nil
			})
        end

        local connection = t1[5].InputChanged:Connect(function(input, gameProcessed)
            if not gameProcessed then
                gameProcessed = not EmoteWheel.isOpen

                if not gameProcessed then
                    gameProcessed = input.UserInputType ~= Enum.UserInputType.MouseWheel
                end
            end

            if gameProcessed then
                return
            end

            local currentPage = EmoteWheel.currentPage
            local v1301

            if input.Position.Z > 0 then
                local v1300 = currentPage == 1

                if v1300 then
                    v1300 = #EmoteWheel.PAGES
                end

                v1301 = v1300 or currentPage - 1
            else
                v1301 = if currentPage ~= #EmoteWheel.PAGES then currentPage + 1 else 1
            end

            p82:UpdateEmotePage(v1301)
        end)

        table.insert(EmoteWheel.Connections, connection)

        local connection2 = t1[5].InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then
                return
            end

            local v1304 = input.KeyCode == Enum.KeyCode.Escape

            if v1304 then
                v1304 = EmoteWheel.isOpen
            end

            if v1304 then
                p82:CloseEmoteMenu()
            end
        end)

        table.insert(EmoteWheel.Connections, connection2)

        local connection3 = t1[14].CharacterRemoving:Connect(function()
            p82:StopEmote()
            p82:CloseEmoteMenu()
        end)

        table.insert(EmoteWheel.Connections, connection3)

        local connection4 = t1[14].CharacterAdded:Connect(function()
            p82:StopEmote()
            p82:CloseEmoteMenu()
        end)

        table.insert(EmoteWheel.Connections, connection4)
    end
    t1[21].ToggleEmoteWheel = function(p83, p84)
        local EmoteWheel = p83.EmoteWheel

        EmoteWheel.Enabled = p84

        if p84 then
            p83:BuildEmoteGUI()

            return
        end

        p83:CloseEmoteMenu()

        if EmoteWheel.Gui then
            pcall(function()
                EmoteWheel.Gui:Destroy()
            end)
            EmoteWheel.Gui = nil
        end

        for _, v in ipairs(EmoteWheel.Connections) do
            pcall(v.Disconnect, v)
        end

        EmoteWheel.Connections = {}
        EmoteWheel.bg = nil
        EmoteWheel.overlay = nil
        EmoteWheel.pageText = nil
        EmoteWheel.buttons = {}
        EmoteWheel.modalButton = nil
        p83:StopCursorUnlock()
    end
    t1[21].FindNearestGenerator = function(_)
        local Character = t1[14].Character
        if not Character then
            return nil
        end
        local v658 = t1[16].GetCharacterRoot(Character)
        if not v658 then
            return nil
        end
        local Position = v658.Position
        local t90 = {}
        local Map = t1[3]:FindFirstChild("Map")
        if Map then
            local Generators = Map:FindFirstChild("Generators")

            if Generators then
                local GetChildren = Generators.GetChildren

                for _, v in ipairs(GetChildren(Generators)) do
                    local v666 = v:IsA("Model")

                    if v666 then
                        v666 = v.Name:lower():find("generator")
                    end

                    if v666 then
                        local GetDescendants = v.GetDescendants

                        for _, v5 in ipairs(GetDescendants(v)) do
                            local v670 = v5:IsA("BasePart")

                            if v670 then
                                v670 = v5.Name:lower():find("generatorpoint")

                                if not v670 then
                                    v670 = v5.Name:lower():find("generator")
                                end
                            end

                            if v670 then
                                table.insert(t90, v5)
                            end
                        end
                    end
                end
            end
        end
        if #t90 == 0 then
            for _, descendant in ipairs(t1[3]:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    local descendantName = descendant.Name
                    local v674 = descendantName:find("Generator")

                    if not v674 then
                        v674 = descendantName:find("GeneratorPoint")
                    end

                    if v674 then
                        local descendantParent = descendant.Parent

                        if descendantParent then
                            local v676 = descendantParent:IsA("Model")

                            if v676 then
                                v676 = descendantParent.Name:find("Generator")
                            end

                            descendantParent = v676
                        end

                        if descendantParent then
                            table.insert(t90, descendant)
                        end
                    end
                end
            end
        end
        if #t90 == 0 then
            return nil
        end
        local v677
        local n7 = 1e999
        for _, v in ipairs(t90) do
            local Magnitude = (Position - v.Position).Magnitude

            if Magnitude < n7 then
                v677 = v
                n7 = Magnitude
            end
        end

        return v677
    end
    t1[21].EnableNoClip = function(p86)
        if p86.QuickRepair.NoClipActive then
            return
        end

        local Character = t1[14].Character

        if not Character then
            return
        end

        local QuickRepair = p86.QuickRepair
        local GetDescendants = Character.GetDescendants

        QuickRepair.NoClipRestore = {}

        for _, v in ipairs(GetDescendants(Character)) do
            if v:IsA("BasePart") then
                p86.QuickRepair.NoClipRestore[v] = v.CanCollide
                v.CanCollide = false
            end
        end

        p86.QuickRepair.NoClipActive = true
    end
    t1[21].DisableNoClip = function(p87)
        if not p87.QuickRepair.NoClipActive then
            return
        end

        if t1[14].Character then
            for k, v in pairs(p87.QuickRepair.NoClipRestore) do
                local v691 = k

                if v691 and v691.Parent then
                    v691.CanCollide = v
                end
            end
        end

        p87.QuickRepair.NoClipRestore = {}
        p87.QuickRepair.NoClipActive = false
    end
    t1[21].StartRepair = function(_, p89, p90)
        if not p89 then
            return false
        end

        local v695 = p90 or 1
        local Remotes = t1[6]:FindFirstChild("Remotes")

        if Remotes then
            Remotes = Remotes:FindFirstChild("Generator")

            if Remotes then
                Remotes = Remotes:FindFirstChild("RepairEvent")
            end
        end

        if not Remotes then
            return false
        end

        pcall(function()
            Remotes:FireServer(p89, true)
        end)

        local Remotes3 = t1[6]:FindFirstChild("Remotes")

        if Remotes3 then
            Remotes3 = Remotes3:FindFirstChild("Generator")

            if Remotes3 then
                Remotes3 = Remotes3:FindFirstChild("SkillCheckResultEvent")
            end
        end

        if Remotes3 then
            t1[4].Heartbeat:Connect(function()
                pcall(function()
                    Remotes3:FireServer(p89, "Great")
                end)
            end)
            task.delay(v695, function()
            end)
        end

        return true
    end
    t1[21].StopRepair = function(_, p92)
        if not p92 then
            return
        end

        local Remotes = t1[6]:FindFirstChild("Remotes")

        if Remotes then
            Remotes = Remotes:FindFirstChild("Generator")

            if Remotes then
                Remotes = Remotes:FindFirstChild("RepairEvent")
            end
        end

        if Remotes then
            pcall(function()
                Remotes:FireServer(p92, false)
            end)
        end
    end
    t1[21].GetSafePositionNearGenerator = function(_, p94, p95)
        local p94Position = p94.Position
        local Unit = (p94Position - p95).Unit

        if Unit.Magnitude < 0.1 then
            Unit = Vector3.new(1, 0, 0)
        end

        local _Vector3 = Vector3
        local v707 = Unit * 2.5
        local v708 = p94Position + _Vector3.new(0, 1.5, 0) + v707
        local ray = Ray.new(v708 + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0))
        local part, position = t1[3]:FindPartOnRay(ray, t1[14].Character)

        if part and position then
            v708 = position + Vector3.new(0, 1.5, 0)
        end

        return v708
    end
    t1[21].ExecuteQuickRepair = function(p96)
        if not t1[16].IsSurvivorTeam() then
            return
        end

        local Character = t1[14].Character

        if not Character then
            return
        end

        local v714 = t1[16].GetCharacterRoot(Character)

        if not v714 then
            return
        end

        local Position = v714.Position
        local NearestGenerator = p96:FindNearestGenerator()

        if not NearestGenerator then
            return
        end

        p96:EnableNoClip()

        local SafePositionNearGenerator = p96:GetSafePositionNearGenerator(NearestGenerator, Position)

        Character:SetPrimaryPartCFrame(CFrame.new(SafePositionNearGenerator))
        task.wait(0.3)

        local v718 = p96:StartRepair(NearestGenerator, 1)

        task.wait(1)

        if v718 then
            p96:StopRepair(NearestGenerator)
        end

        local t91 = { CFrame.new(Position) }

        Character:SetPrimaryPartCFrame(v2(t91))
        task.wait(0.2)
        p96:DisableNoClip()
    end
    t1[21].ToggleNoSlowdown = function(p97, p98)
        p97.NoSlowdown.Enabled = p98

        if p98 then
            local function u722(p99)
                local v1306 = not p97.NoSlowdown.Enabled

                if not v1306 then
                    v1306 = not t1[16].IsSurvivorTeam()
                end

                if v1306 then
                    return
                end

                task.wait(0.5)

                local v1307 = t1[16].GetHumanoid(p99)

                if v1307 then
                    v1307:SetAttribute("NoSlowdown", true)
                    v1307.WalkSpeed = 16

                    if p97.NoSlowdown.Connection then
                        p97.NoSlowdown.Connection:Disconnect()
                    end

                    p97.NoSlowdown.Connection = v1307:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                        local NoSlowdownEnabled = p97.NoSlowdown.Enabled

                        if NoSlowdownEnabled then
                            NoSlowdownEnabled = t1[16].IsSurvivorTeam()

                            if NoSlowdownEnabled then
                                NoSlowdownEnabled = v1307

                                if NoSlowdownEnabled then
                                    NoSlowdownEnabled = v1307.WalkSpeed ~= 16
                                end
                            end
                        end

                        if NoSlowdownEnabled then
                            v1307.WalkSpeed = 16
                        end
                    end)
                    v1307.Died:Connect(function()
                        if p97.NoSlowdown.Enabled then
                            task.wait(2)

                            local Character = t1[14].Character

                            if Character then
                                u722(Character)
                            end
                        end
                    end)
                end
            end

            if t1[16].IsSurvivorTeam() then
                local Character = t1[14].Character

                if Character then
                    u722(Character)
                end
            end

            p97.NoSlowdown.TeamListeners = t1[16].SetupTeamListener(function()
                local NoSlowdownEnabled = p97.NoSlowdown.Enabled

                if NoSlowdownEnabled then
                    NoSlowdownEnabled = t1[16].IsSurvivorTeam()
                end

                if NoSlowdownEnabled then
                    local Character = t1[14].Character

                    if Character then
                        u722(Character)

                        return
                    end
                elseif p97.NoSlowdown.Connection then
                    p97.NoSlowdown.Connection:Disconnect()
                    p97.NoSlowdown.Connection = nil
                end
            end)

            return
        end

        if p97.NoSlowdown.Connection then
            p97.NoSlowdown.Connection:Disconnect()
            p97.NoSlowdown.Connection = nil
        end

        local Character = t1[14].Character

        if Character then
            local v725 = t1[16].GetHumanoid(Character)

            if v725 then
                v725:SetAttribute("NoSlowdown", nil)
            end
        end

        for _, v in ipairs(p97.NoSlowdown.TeamListeners) do
            pcall(v.Disconnect, v)
        end

        p97.NoSlowdown.TeamListeners = {}
    end
    t1[21].ToggleNoFall = function(p100, p101)
        p100.NoFall.Enabled = p101

        if p101 then
            local function v730()
                if p100.NoFall.Hooked then
                    return true
                end

                local ok, result = pcall(function()
                    return t1[6]:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")
                end)
                local v1314 = ok and result or nil

                if not v1314 then
                    return false
                end

                local v1315 = getrawmetatable(v1314)

                if not v1315 then
                    return false
                end

                p100.NoFall.OriginalNamecall = v1315.__namecall

                local v1316 = isreadonly and isreadonly(v1315)

                if setreadonly then
                    setreadonly(v1315, false)
                end

                v1315.__namecall = newcclosure(function(p102, ...)
                    local v1642 = p102 == v1314

                    if v1642 then
                        v1642 = getnamecallmethod() == "FireServer"

                        if v1642 then
                            v1642 = p100.NoFall.Enabled

                            if v1642 then
                                v1642 = t1[16].IsSurvivorTeam()
                            end
                        end
                    end

                    if v1642 then
                        return nil
                    end

                    return p100.NoFall.OriginalNamecall(p102, ...)
                end)

                if setreadonly and v1316 then
                    setreadonly(v1315, true)
                end

                p100.NoFall.Hooked = true

                return true
            end
            local function v731()
                local NoFallEnabled = p100.NoFall.Enabled

                if NoFallEnabled then
                    NoFallEnabled = t1[16].IsSurvivorTeam()
                end

                if NoFallEnabled then
                    if not v730() then
                        task.spawn(function()
                            for _ = 1, 5 do
                                task.wait(1)

                                local NoFallEnabled2 = p100.NoFall.Enabled

                                if NoFallEnabled2 then
                                    NoFallEnabled2 = t1[16].IsSurvivorTeam()

                                    if NoFallEnabled2 then
                                        NoFallEnabled2 = not p100.NoFall.Hooked
                                    end
                                end

                                if NoFallEnabled2 and v730() then
                                    return
                                end
                            end
                        end)

                        return
                    end
                elseif p100.NoFall.Hooked then
                    local ok, result = pcall(function()
                        return t1[6]:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")
                    end)
                    local v1320 = ok and result or nil

                    if v1320 then
                        local v1321 = getrawmetatable(v1320)
                        local v1322 = v1321

                        if v1321 then
                            v1322 = p100.NoFall.OriginalNamecall
                        end

                        if v1322 then
                            local v1323 = isreadonly and isreadonly(v1321)

                            if setreadonly then
                                setreadonly(v1321, false)
                            end

                            v1321.__namecall = p100.NoFall.OriginalNamecall

                            if setreadonly and v1323 then
                                setreadonly(v1321, true)
                            end

                            p100.NoFall.Hooked = false
                        end
                    end
                end
            end

            v731()
            p100.NoFall.TeamListeners = t1[16].SetupTeamListener(v731)

            return
        end

        if p100.NoFall.Hooked then
            local ok = pcall(function()
                return t1[6]:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")
            end)

            if ok then
                local v733 = getrawmetatable(ok)
                local v734 = v733

                if v733 then
                    v734 = p100.NoFall.OriginalNamecall
                end

                if v734 then
                    local v735 = isreadonly and isreadonly(v733)

                    if setreadonly then
                        setreadonly(v733, false)
                    end

                    v733.__namecall = p100.NoFall.OriginalNamecall

                    if setreadonly and v735 then
                        setreadonly(v733, true)
                    end

                    p100.NoFall.Hooked = false
                end
            end
        end

        for _, v in ipairs(p100.NoFall.TeamListeners) do
            pcall(v.Disconnect, v)
        end

        p100.NoFall.TeamListeners = {}
    end
    t1[21].ToggleNoHitbox = function(p103, p104)
        p103.NoHitbox.Enabled = p104

        local function v740(p105)
            if not t1[16].IsSurvivorTeam() then
                return
            end

            local Character = t1[14].Character

            if not Character then
                return
            end

            for _, descendant in ipairs(Character:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.CanTouch = not p105
                end
            end
        end

        if p104 then
            v740(true)
            p103.NoHitbox.TeamListeners = t1[16].SetupTeamListener(function()
                if p103.NoHitbox.Enabled then
                    v740(true)
                end
            end)

            return
        end

        v740(false)

        for _, v in ipairs(p103.NoHitbox.TeamListeners) do
            pcall(v.Disconnect, v)
        end

        p103.NoHitbox.TeamListeners = {}
    end
    t1[21].ToggleAutoParry = function(p106, p107)
        p106.AutoParry.Enabled = p107

        if p107 then
            local t92 = {}

            for _, v in ipairs({
				"rbxassetid://110355011987939",
				"rbxassetid://139369275981139",
				"rbxassetid://117042998468241",
				"rbxassetid://133963973694098",
				"rbxassetid://113255068724446",
				"rbxassetid://74968262036854",
				"rbxassetid://118907603246885",
				"rbxassetid://78432063483146",
				"rbxassetid://129784271201071",
				"rbxassetid://122812055447896",
				"rbxassetid://138720291317243",
				"rbxassetid://106871536134254",
				"rbxassetid://109402730355822",
				"rbxassetid://111920872708571",
				"rbxassetid://105374834496520"
			}) do
                t92[v] = true
            end

            local function v748()
                if p106.AutoParry.SpamActive then
                    return
                end

                p106.AutoParry.SpamActive = true
                t1[7]:SendMouseButtonEvent(0, 0, 1, true, game, 0)
                task.spawn(function()
                    task.wait()
                    t1[7]:SendMouseButtonEvent(0, 0, 1, false, game, 0)
                    p106.AutoParry.SpamActive = false
                end)
            end
            local function v749(p108)
                if p106.AutoParry.AnimConnections[p108] then
                    for _, v in ipairs(p106.AutoParry.AnimConnections[p108]) do
                        pcall(v.Disconnect, v)
                    end

                    p106.AutoParry.AnimConnections[p108] = nil
                end
            end
            local function u750(p109, p110)
                if p109 == t1[14] then
                    return
                end

                v749(p109)
                p106.AutoParry.AnimConnections[p109] = {}

                local function v1336(p111)
                    local v1646 = not p106.AutoParry.Enabled

                    if not v1646 then
                        v1646 = not t1[16].IsSurvivorTeam()
                    end

                    if v1646 then
                        return
                    end

                    local Animation = p111.Animation

                    if Animation then
                        Animation = p111.Animation.AnimationId
                    end

                    if Animation then
                        Animation = t92[Animation]

                        if Animation then
                            local v1648 = p110
                            local v1649 = t1[16].GetCharacterRoot(t1[14].Character)
                            local v1650 = t1[16].GetCharacterRoot(v1648)

                            Animation = not (not v1649 or not v1650) and (v1649.Position - v1650.Position).Magnitude <= p106.AutoParry.Range
                        end
                    end

                    if Animation then
                        v748()
                    end
                end;

                (function()
                    local v1651 = t1[16].GetHumanoid(p110)

                    if not v1651 then
                        return
                    end

                    local Animator = v1651:FindFirstChildOfClass("Animator")

                    if not Animator then
                        local connection = v1651.ChildAdded:Connect(function(child)
                            if child:IsA("Animator") then
                                waitConn:Disconnect()

                                local connection = child.AnimationPlayed:Connect(v1336)

                                table.insert(p106.AutoParry.AnimConnections[p109], connection)
                            end
                        end)

                        table.insert(p106.AutoParry.AnimConnections[p109], connection)

                        return
                    end

                    local connection = Animator.AnimationPlayed:Connect(v1336)

                    table.insert(p106.AutoParry.AnimConnections[p109], connection)
                end)()

                local connection = p109.CharacterAdded:Connect(function(character)
                    task.wait(0.1)

                    if p106.AutoParry.Enabled then
                        u750(p109, character)
                    end
                end)

                table.insert(p106.AutoParry.AnimConnections[p109], connection)
            end
            local function v751()
                for _, player in ipairs(t1[2]:GetPlayers()) do
                    local v1340 = player

                    if v1340 ~= t1[14] then
                        if v1340.Character then
                            u750(v1340, v1340.Character)
                        else
                            p106.AutoParry.AnimConnections[v1340] = {}

                            local connection = v1340.CharacterAdded:Connect(function(character)
                                task.wait(0.1)
                                u750(v1340, character)
                            end)

                            table.insert(p106.AutoParry.AnimConnections[v1340], connection)
                        end
                    end
                end

                p106.AutoParry.PlayerAddedConn = t1[2].PlayerAdded:Connect(function(player)
                    p106.AutoParry.AnimConnections[player] = {}

                    local connection = player.CharacterAdded:Connect(function(character)
                        task.wait(0.1)
                        u750(player, character)
                    end)

                    table.insert(p106.AutoParry.AnimConnections[player], connection)
                end)
                p106.AutoParry.PlayerRemovingConn = t1[2].PlayerRemoving:Connect(v749)
            end
            local function v752()
                for k, _ in pairs(p106.AutoParry.AnimConnections) do
                    v749(k)
                end

                if p106.AutoParry.PlayerAddedConn then
                    p106.AutoParry.PlayerAddedConn:Disconnect()
                    p106.AutoParry.PlayerAddedConn = nil
                end

                if p106.AutoParry.PlayerRemovingConn then
                    p106.AutoParry.PlayerRemovingConn:Disconnect()
                    p106.AutoParry.PlayerRemovingConn = nil
                end
            end
            local function v753()
                v752()

                local AutoParryEnabled = p106.AutoParry.Enabled

                if AutoParryEnabled then
                    AutoParryEnabled = t1[16].IsSurvivorTeam()
                end

                if AutoParryEnabled then
                    v751()
                end
            end

            p106.AutoParry.TeamListeners = t1[16].SetupTeamListener(v753)
            v753()

            return
        end

        p106.AutoParry.SpamActive = false

        for k, _ in pairs(p106.AutoParry.AnimConnections) do
            for _, v in ipairs(p106.AutoParry.AnimConnections[k]) do
                pcall(v.Disconnect, v)
            end
        end

        p106.AutoParry.AnimConnections = {}

        if p106.AutoParry.PlayerAddedConn then
            p106.AutoParry.PlayerAddedConn:Disconnect()
            p106.AutoParry.PlayerAddedConn = nil
        end

        if p106.AutoParry.PlayerRemovingConn then
            p106.AutoParry.PlayerRemovingConn:Disconnect()
            p106.AutoParry.PlayerRemovingConn = nil
        end

        for _, v in ipairs(p106.AutoParry.TeamListeners) do
            pcall(v.Disconnect, v)
        end

        p106.AutoParry.TeamListeners = {}
    end
    t1[21].ToggleAutoParryV2 = function(p112, p113)
        p112.AutoParryV2.Enabled = p113

        if p113 then
            local function v762()
                local ViewportSize = t1[3].CurrentCamera.ViewportSize

                t1[7]:SendMouseButtonEvent(ViewportSize.X / 2, ViewportSize.Y / 2, 1, true, game, 1)
                task.delay(0.1, function()
                    t1[7]:SendMouseButtonEvent(ViewportSize.X / 2, ViewportSize.Y / 2, 1, false, game, 1)
                end)
            end
            local function v763()
                local v1346 = not p112.AutoParryV2.Enabled
                if not v1346 then
                    v1346 = not t1[16].IsSurvivorTeam()
                end
                if v1346 then
                    return
                end
                local timestamp = tick()
                if timestamp - (p112.AutoParryV2.LastCheckTime or 0) < 0.05 then
                    return
                end
                p112.AutoParryV2.LastCheckTime = timestamp
                local v1348 = t1[16].GetCharacterRoot(t1[14].Character)
                if not v1348 then
                    p112.AutoParryV2.LastArmPos = nil

                    return
                end
                local n8 = 1e999
                local v1350
                for v1353, v1354 in ipairs(t1[2]:GetPlayers()) do

                    local v1355 = v1354 ~= t1[14]

                    if v1355 then
                        v1355 = v1354.Character

                        if v1355 then
                            v1355 = t1[16].IsPlayerKiller(v1354)
                        end
                    end

                    if v1355 then
                        local v1356 = t1[16].GetCharacterRoot(v1354.Character)

                        if v1356 then
                            local Magnitude = (v1356.Position - v1348.Position).Magnitude

                            if Magnitude < n8 then
                                v1350 = v1354
                                n8 = Magnitude
                            end
                        end
                    end
                end
                if not v1350 or not v1350.Character then
                    p112.AutoParryV2.LastArmPos = nil

                    return
                end
                if n8 > p112.AutoParryV2.Range then
                    p112.AutoParryV2.LastArmPos = nil

                    return
                end
                local RightUpperArm = v1350.Character:FindFirstChild("RightUpperArm")
                if not RightUpperArm then
                    RightUpperArm = v1350.Character:FindFirstChild("Right Arm")
                end
                if not RightUpperArm then
                    p112.AutoParryV2.LastArmPos = nil

                    return
                end
                local RightUpperArmPosition = RightUpperArm.Position
                if p112.AutoParryV2.LastArmPos then
                    local Magnitude = (RightUpperArmPosition - p112.AutoParryV2.LastArmPos).Magnitude
                    local v1361 = Magnitude - p112.AutoParryV2.LastDelta
                    local v1362 = Magnitude > 0.01

                    if v1362 then
                        v1362 = v1361 > 0.3

                        if v1362 then
                            v1362 = not p112.AutoParryV2.OnCooldown
                        end
                    end

                    if v1362 then
                        p112.AutoParryV2.OnCooldown = true
                        v762()
                        task.delay(0.5, function()
                            p112.AutoParryV2.OnCooldown = false
                        end)
                    end

                    p112.AutoParryV2.LastDelta = Magnitude
                else
                    p112.AutoParryV2.LastDelta = 0
                end
                p112.AutoParryV2.LastArmPos = RightUpperArmPosition
            end
            local function v764()
                if p112.AutoParryV2.Connection then
                    p112.AutoParryV2.Connection:Disconnect()
                end

                local AutoParryV2Enabled = p112.AutoParryV2.Enabled

                if AutoParryV2Enabled then
                    AutoParryV2Enabled = t1[16].IsSurvivorTeam()
                end

                if AutoParryV2Enabled then
                    p112.AutoParryV2.Connection = t1[4].Heartbeat:Connect(v763)
                end
            end

            p112.AutoParryV2.TeamListeners = t1[16].SetupTeamListener(v764)
            v764()

            return
        end

        if p112.AutoParryV2.Connection then
            p112.AutoParryV2.Connection:Disconnect()
            p112.AutoParryV2.Connection = nil
        end

        p112.AutoParryV2.LastArmPos = nil

        for _, v in ipairs(p112.AutoParryV2.TeamListeners) do
            pcall(v.Disconnect, v)
        end

        p112.AutoParryV2.TeamListeners = {}
    end
    t1[21].ToggleFakeParry = function(p114, p115)
        p114.FakeParry.Enabled = p115

        local function v769()
            if p114.FakeParry.AnimTrack then
                p114.FakeParry.AnimTrack:Stop()
                p114.FakeParry.AnimTrack = nil
            end
        end
        local function v770()
            if not t1[16].IsSurvivorTeam() then
                return false
            end

            local Character = t1[14].Character

            if not Character then
                return false
            end

            local v1365 = t1[16].GetHumanoid(Character)

            if not v1365 then
                return false
            end

            local Animation = Instance.new("Animation")

            Animation.AnimationId = "rbxassetid://127096285501517"
            p114.FakeParry.AnimTrack = v1365:LoadAnimation(Animation)

            if p114.FakeParry.AnimTrack then
                p114.FakeParry.AnimTrack:Play()
                p114.FakeParry.AnimTrack.Stopped:Connect(function()
                    p114.FakeParry.AnimTrack = nil
                end)

                return true
            end

            return false
        end
        local function v771()
            local FakeParryEnabled = p114.FakeParry.Enabled

            if FakeParryEnabled then
                FakeParryEnabled = t1[16].IsSurvivorTeam()
            end

            if FakeParryEnabled then
                if not p114.FakeParry.CharConn then
                    p114.FakeParry.CharConn = t1[14].CharacterAdded:Connect(function(character)
                        local FakeParryEnabled2 = p114.FakeParry.Enabled

                        if FakeParryEnabled2 then
                            FakeParryEnabled2 = t1[16].IsSurvivorTeam()
                        end

                        if FakeParryEnabled2 then
                            task.wait(1)

                            local v1661 = t1[16].GetHumanoid(character)

                            if v1661 then
                                v1661.Died:Connect(v769)
                            end

                            task.wait(0.5)
                            v770()
                        end
                    end)
                end

                v770()

                return
            end

            if p114.FakeParry.AnimTrack then
                p114.FakeParry.AnimTrack:Stop()
                p114.FakeParry.AnimTrack = nil
            end

            if p114.FakeParry.CharConn then
                p114.FakeParry.CharConn:Disconnect()
                p114.FakeParry.CharConn = nil
            end
        end

        p114.FakeParry.TeamListeners = t1[16].SetupTeamListener(v771)
        v771()
    end
    t1[21].ToggleTwistSilentAim = function(p116, p117)
        p116.TwistSilentAim.Enabled = p117

        if p117 then
            local function v774()
                local n9 = 1e999
                local v1371
                local CFramePosition = t1[3].CurrentCamera.CFrame.Position
                for _, player in ipairs(t1[2]:GetPlayers()) do
                    if player ~= t1[14] and player.Character then
                        local v1375 = t1[16].GetCharacterRoot(player.Character)
                        local v1376 = t1[16].GetHumanoid(player.Character)
                        local v1377 = v1375

                        if v1375 then
                            v1377 = v1376 and v1376.Health > 0
                        end

                        if v1377 then
                            local Magnitude = (v1375.Position - CFramePosition).Magnitude

                            if Magnitude < n9 then
                                n9 = Magnitude
                                v1371 = player
                            end
                        end
                    end
                end

                return v1371
            end
            local function v775()
                if p116.TwistSilentAim.Hooked then
                    return true
                end

                local ok, result = pcall(function()
                    return t1[6]:WaitForChild("Remotes", 5):WaitForChild("Items", 5):WaitForChild("Twist of Fate", 5):WaitForChild("Fire", 5)
                end)
                local v1381 = ok and result or nil

                if not v1381 then
                    return false
                end

                p116.TwistSilentAim.Remote = v1381
                p116.TwistSilentAim.OriginalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(p118, ...)
                    local t93 = { ... }
                    local v1664 = getnamecallmethod() == "FireServer"

                    if v1664 then
                        v1664 = p118 == v1381

                        if v1664 then
                            v1664 = p116.TwistSilentAim.Enabled

                            if v1664 then
                                v1664 = t1[16].IsSurvivorTeam()
                            end
                        end
                    end

                    if v1664 then
                        local v1665 = t93[2]
                        local v1666 = t93[1]
                        local v1667 = v1666

                        if v1666 then
                            v1667 = typeof(v1666) == "Instance" and v1665
                        end

                        if v1667 then
                            local v1668 = v774()

                            if v1668 and v1668.Character then
                                local v1669 = t1[16].GetCharacterRoot(v1668.Character)

                                if v1669 then
                                    local Unit = (v1669.Position - t1[3].CurrentCamera.CFrame.Position).Unit

                                    v1381:FireServer(v1666, Unit)

                                    return nil
                                end
                            end
                        end
                    end

                    return p116.TwistSilentAim.OriginalNamecall(p118, v2(t93))
                end))
                p116.TwistSilentAim.Hooked = true

                return true
            end
            local function v776()
                local TwistSilentAimEnabled = p116.TwistSilentAim.Enabled

                if TwistSilentAimEnabled then
                    TwistSilentAimEnabled = t1[16].IsSurvivorTeam()
                end

                if TwistSilentAimEnabled then
                    if not v775() then
                        task.spawn(function()
                            for _ = 1, 5 do
                                task.wait(1)

                                local TwistSilentAimEnabled2 = p116.TwistSilentAim.Enabled

                                if TwistSilentAimEnabled2 then
                                    TwistSilentAimEnabled2 = t1[16].IsSurvivorTeam()

                                    if TwistSilentAimEnabled2 then
                                        TwistSilentAimEnabled2 = not p116.TwistSilentAim.Hooked
                                    end
                                end

                                if TwistSilentAimEnabled2 and v775() then
                                    return
                                end
                            end
                        end)

                        return
                    end
                elseif p116.TwistSilentAim.Hooked then
                    local Remote = p116.TwistSilentAim.Remote

                    if Remote then
                        local v1384 = getrawmetatable(Remote)

                        if v1384 then
                            local v1385 = isreadonly and isreadonly(v1384)

                            if setreadonly then
                                setreadonly(v1384, false)
                            end

                            v1384.__namecall = p116.TwistSilentAim.OriginalNamecall

                            if setreadonly and v1385 then
                                setreadonly(v1384, true)
                            end

                            p116.TwistSilentAim.Hooked = false
                        end
                    end
                end
            end

            p116.TwistSilentAim.TeamListeners = t1[16].SetupTeamListener(v776)
            v776()

            return
        end

        if p116.TwistSilentAim.Hooked then
            local Remote = p116.TwistSilentAim.Remote

            if Remote then
                local v778 = getrawmetatable(Remote)

                if v778 then
                    local v779 = isreadonly and isreadonly(v778)

                    if setreadonly then
                        setreadonly(v778, false)
                    end

                    v778.__namecall = p116.TwistSilentAim.OriginalNamecall

                    if setreadonly and v779 then
                        setreadonly(v778, true)
                    end

                    p116.TwistSilentAim.Hooked = false
                end
            end
        end

        for _, v in ipairs(p116.TwistSilentAim.TeamListeners) do
            pcall(v.Disconnect, v)
        end

        p116.TwistSilentAim.TeamListeners = {}
    end
end
t1[21].ToggleParryCircle = function(p119, p120)
    p119.ParryCircle.Enabled = p120

    if p120 then
        local function v784()
            local Character = t1[14].Character

            if not Character then
                return 1e999
            end

            local v1387 = t1[16].GetCharacterRoot(Character)

            if not v1387 then
                return 1e999
            end

            local Position = v1387.Position
            local n10 = 1e999

            for _, player in ipairs(t1[2]:GetPlayers()) do
                if player ~= t1[14] and player.Character then
                    local v1392 = t1[16].GetCharacterRoot(player.Character)
                    local v1393 = t1[16].GetHumanoid(player.Character)
                    local v1394 = v1392

                    if v1392 then
                        v1394 = v1393 and v1393.Health > 0
                    end

                    if v1394 and t1[16].IsPlayerKiller(player) then
                        local Magnitude = (v1392.Position - Position).Magnitude

                        if Magnitude < n10 then
                            n10 = Magnitude
                        end
                    end
                end
            end

            return n10
        end
        local function v785()
            if p119.ParryCircle.Circle then
                p119.ParryCircle.Circle:Destroy()
            end

            local Part = Instance.new("Part")

            Part.Name = "ParryCircle"
            Part.Anchored = true
            Part.CanCollide = false
            Part.CastShadow = false
            Part.Material = Enum.Material.Neon
            Part.Color = Color3.fromRGB(0, 255, 80)
            Part.Transparency = 0.58
            Part.Shape = Enum.PartType.Cylinder
            Part.Parent = t1[3]

            local BillboardGui = Instance.new("BillboardGui")

            BillboardGui.Size = UDim2.new(0, 200, 0, 32)
            BillboardGui.StudsOffset = Vector3.new(0, 4, 0)
            BillboardGui.AlwaysOnTop = true
            BillboardGui.Parent = Part

            local TextLabel = Instance.new("TextLabel", BillboardGui)

            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
            TextLabel.TextStrokeTransparency = 0
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.TextSize = 14
            TextLabel.Text = "Parry Distance"
            p119.ParryCircle.Circle = Part
            p119.ParryCircle.Label = TextLabel

            return Part
        end
        local function v786()
            local v1399 = not p119.ParryCircle.Enabled

            if not v1399 then
                v1399 = not t1[16].IsSurvivorTeam()
            end

            if v1399 then
                if p119.ParryCircle.Circle then
                    p119.ParryCircle.Circle:Destroy()
                    p119.ParryCircle.Circle = nil
                end

                return
            end

            local Character = t1[14].Character

            if not Character then
                return
            end

            local v1401 = t1[16].GetCharacterRoot(Character)

            if not v1401 then
                return
            end

            local v1402 = not p119.ParryCircle.Circle

            if not v1402 then
                v1402 = not p119.ParryCircle.Circle.Parent
            end

            if v1402 then
                p119.ParryCircle.Circle = v785()
            end

            local v1403 = p119.AutoParry.Range or 10
            local v1404 = v784()
            local v1405 = v1403 * 2
            local PositionY = v1401.Position.Y
            local v1407 = p119
            local v1408 = PositionY - 2.9

            v1407.ParryCircle.Circle.CFrame = CFrame.new(v1401.Position.X, v1408, v1401.Position.Z) * CFrame.Angles(0, 0, 1.5707963267948966)
            p119.ParryCircle.Circle.Size = Vector3.new(0.2, v1405, v1405)

            if v1404 <= v1403 then
                p119.ParryCircle.Circle.Color = Color3.fromRGB(255, 50, 50)
            else
                p119.ParryCircle.Circle.Color = Color3.fromRGB(0, 255, 80)
            end

            if p119.ParryCircle.Label then
                local v1409 = v1404 == 1e999 and "---"

                if not v1409 then
                    v1409 = string.format("%.1f", v1404)
                end

                p119.ParryCircle.Label.Text = string.format("r: %.1f  |  killer: %s", v1403, v1409)

                if v1404 <= v1403 then
                    p119.ParryCircle.Label.TextColor3 = Color3.fromRGB(255, 80, 80)

                    return
                end

                p119.ParryCircle.Label.TextColor3 = Color3.fromRGB(0, 255, 80)
            end
        end
        local function v787()
            if p119.ParryCircle.Connection then
                p119.ParryCircle.Connection:Disconnect()
            end

            local ParryCircleEnabled = p119.ParryCircle.Enabled

            if ParryCircleEnabled then
                ParryCircleEnabled = t1[16].IsSurvivorTeam()
            end

            if ParryCircleEnabled then
                p119.ParryCircle.Connection = t1[4].Heartbeat:Connect(v786)
            end
        end

        p119.ParryCircle.TeamListeners = t1[16].SetupTeamListener(v787)
        v787()

        return
    end

    if p119.ParryCircle.Connection then
        p119.ParryCircle.Connection:Disconnect()
        p119.ParryCircle.Connection = nil
    end

    if p119.ParryCircle.Circle then
        p119.ParryCircle.Circle:Destroy()
        p119.ParryCircle.Circle = nil
    end

    for _, v in ipairs(p119.ParryCircle.TeamListeners) do
        pcall(v.Disconnect, v)
    end

    p119.ParryCircle.TeamListeners = {}
end
t1[21].ToggleAutoSkillcheck = function(p121, p122)
    p121.AutoSkillcheck.Enabled = p122

    if p122 then
        task.spawn(function()
            while p121.AutoSkillcheck.Enabled do
                task.wait()

                local PlayerGui = t1[14]:FindFirstChild("PlayerGui")

                if PlayerGui then
                    PlayerGui = PlayerGui:FindFirstChild("SkillCheckPromptGui")
                end

                local v1412 = PlayerGui

                if PlayerGui then
                    v1412 = PlayerGui:FindFirstChild("Check")

                    if v1412 then
                        v1412 = PlayerGui.Check.Visible
                    end
                end

                if v1412 then
                    local Line = PlayerGui.Check:FindFirstChild("Line")
                    local Goal = PlayerGui.Check:FindFirstChild("Goal")

                    if Line and Goal then
                        local LineRotation = Line.Rotation

                        if LineRotation >= 104 + Goal.Rotation and LineRotation <= 114 + Goal.Rotation then
                            t1[16].PressSpace()

                            if PlayerGui.Check.Visible then
                                local _ = p121.AutoSkillcheck.Enabled
                            end

                            repeat
                                task.wait()

                                local v1417 = not PlayerGui.Check.Visible

                                if not v1417 then
                                    v1417 = not p121.AutoSkillcheck.Enabled
                                end
                            until v1417
                        end
                    end
                end
            end
        end)
    end
end
t1[21].Cleanup = function(p123)
    if p123.NoSlowdown.Connection then
        p123.NoSlowdown.Connection:Disconnect()
    end

    if p123.NoFall.Hooked then
        local ok = pcall(function()
            return t1[6]:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")
        end)

        if ok then
            local v794 = getrawmetatable(ok)

            if v794 then
                local v795 = isreadonly and isreadonly(v794)

                if setreadonly then
                    setreadonly(v794, false)
                end

                v794.__namecall = p123.NoFall.OriginalNamecall

                if setreadonly and v795 then
                    setreadonly(v794, true)
                end
            end
        end
    end

    if p123.AutoParry.SpamActive then
        t1[7]:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        p123.AutoParry.SpamActive = false
    end

    for _, v in ipairs({
		p123.AutoParry.AnimConnections,
		p123.AutoParryV2.TeamListeners,
		p123.FakeParry.TeamListeners,
		p123.TwistSilentAim.TeamListeners,
		p123.ParryCircle.TeamListeners
	}) do
        if type(v) == "table" then
            for _, v6 in ipairs(v) do
                pcall(v6.Disconnect, v6)
            end
        end
    end

    if p123.AutoParryV2.Connection then
        p123.AutoParryV2.Connection:Disconnect()
    end

    if p123.FakeParry.AnimTrack then
        p123.FakeParry.AnimTrack:Stop()
    end

    if p123.FakeParry.CharConn then
        p123.FakeParry.CharConn:Disconnect()
    end

    if p123.ParryCircle.Circle then
        p123.ParryCircle.Circle:Destroy()
    end

    if p123.ParryCircle.Connection then
        p123.ParryCircle.Connection:Disconnect()
    end

    if p123.QuickRepair.NoClipActive then
        p123:DisableNoClip()
    end

    p123:ToggleEmoteWheel(false)
end
t1[22] = {}
t1[22].__index = t1[22]
t1[22].new = function()
    local self = setmetatable({}, t1[22])

    self.SpearCrosshair = {
		Enabled = t1[17].Killer.SpearCrosshair.Enabled,
		Frame = nil,
		AttributeListener = nil,
		RenderConn = nil,
		TeamListeners = {}
	}
    self.NoSlowdown = {
		Enabled = t1[17].Killer.NoSlowdown.Enabled,
		Connection = nil,
		OriginalSpeed = nil,
		TeamListeners = {}
	}

    local ThirdPersonEnabled = t1[17].Killer.ThirdPerson.Enabled
    local ThirdPersonOffset = t1[17].Killer.ThirdPerson.Offset

    self.ThirdPerson = {
		Enabled = ThirdPersonEnabled,
		Offset = ThirdPersonOffset,
		OriginalCameraType = nil,
		Active = false,
		Connection = nil,
		TeamListeners = {}
	}
    self.AntiBlind = {
		Enabled = t1[17].Killer.AntiBlind.Enabled,
		Hooked = false,
		OriginalNamecall = nil,
		TeamListeners = {}
	}
    self.NoPalletStun = {
		Enabled = t1[17].Killer.NoPalletStun.Enabled,
		Hooked = false,
		OriginalNamecall = nil,
		TeamListeners = {}
	}
    self.BeatGame = {
		Enabled = t1[17].Killer.BeatGame.Enabled,
		Target = nil,
		Connection = nil,
		TeamListeners = {}
	}
    self.UseFakeSaw = {
		Enabled = t1[17].Killer.UseFakeSaw.Enabled,
		Connection = nil,
		TeamListeners = {}
	}
    self.AbysswalkerCorrupt = {
		Enabled = t1[17].Killer.AbysswalkerCorrupt.Enabled,
		InputConn = nil,
		TeamListeners = {}
	}

    local AutoAttackEnabled = t1[17].Killer.AutoAttack.Enabled
    local AutoAttackRange = t1[17].Killer.AutoAttack.Range

    self.AutoAttack = {
		Enabled = AutoAttackEnabled,
		Range = AutoAttackRange
	}
    self.AutoHook = {
		Enabled = t1[17].Killer.AutoHook.Enabled
	}
    self.KillAll = {
		Enabled = t1[17].Killer.KillAll.Enabled,
		Thread = nil
	}
    self.RemovePallet = {
		Enabled = t1[17].Killer.RemovePallet.Enabled,
		Thread = nil
	}

    return self
end
t1[22].ToggleSpearCrosshair = function(p124, p125)
    p124.SpearCrosshair.Enabled = p125

    if p125 then
        local function v807()
            if not p124.SpearCrosshair.Frame then
                return
            end

            local Character = t1[14].Character
            local v1423 = false
            local SpearCrosshairEnabled = p124.SpearCrosshair.Enabled

            if SpearCrosshairEnabled then
                SpearCrosshairEnabled = t1[16].IsKillerTeam() and Character
            end

            if SpearCrosshairEnabled then
                v1423 = Character:GetAttribute("spearmode") == "spearing"
            end

            p124.SpearCrosshair.Frame.Visible = v1423
        end
        local function v808()
            if p124.SpearCrosshair.AttributeListener then
                p124.SpearCrosshair.AttributeListener:Disconnect()
            end

            local SpearCrosshairEnabled = p124.SpearCrosshair.Enabled

            if SpearCrosshairEnabled then
                SpearCrosshairEnabled = t1[16].IsKillerTeam()
            end

            if SpearCrosshairEnabled then
                local Character = t1[14].Character

                if Character then
                    p124.SpearCrosshair.AttributeListener = Character:GetAttributeChangedSignal("spearmode"):Connect(v807)
                    v807()
                end
            end
        end;

        (function()
            if p124.SpearCrosshair.Frame then
                return
            end

            local ScreenGui = Instance.new("ScreenGui")

            ScreenGui.Name = "SpearCrosshair"
            ScreenGui.ResetOnSpawn = false
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ScreenGui.Parent = t1[14]:WaitForChild("PlayerGui")

            local Frame = Instance.new("Frame")

            Frame.Name = "CrosshairFrame"
            Frame.BackgroundTransparency = 1
            Frame.Size = UDim2.new(0, 40, 0, 40)
            Frame.Position = UDim2.new(0.5, -20, 0.5, -20)
            Frame.Visible = false
            Frame.Parent = ScreenGui

            local Frame6 = Instance.new("Frame")

            Frame6.Name = "CrosshairX"
            Frame6.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            Frame6.BorderSizePixel = 0
            Frame6.Size = UDim2.new(1, 0, 0, 2)
            Frame6.Position = UDim2.new(0, 0, 0.5, -1)
            Frame6.Parent = Frame

            local Frame7 = Instance.new("Frame")

            Frame7.Name = "CrosshairY"
            Frame7.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            Frame7.BorderSizePixel = 0
            Frame7.Size = UDim2.new(0, 2, 1, 0)
            Frame7.Position = UDim2.new(0.5, -1, 0, 0)
            Frame7.Parent = Frame
            p124.SpearCrosshair.Frame = Frame
        end)()
        v808()

        if not p124.SpearCrosshair.RenderConn then
            p124.SpearCrosshair.RenderConn = t1[4].RenderStepped:Connect(function()
                if p124.SpearCrosshair.Frame then
                    p124.SpearCrosshair.Frame.Position = UDim2.new(0.5, -20, 0.5, -20)
                end
            end)
        end

        p124.SpearCrosshair.TeamListeners = t1[16].SetupTeamListener(function()
            local SpearCrosshairEnabled = p124.SpearCrosshair.Enabled

            if SpearCrosshairEnabled then
                SpearCrosshairEnabled = t1[16].IsKillerTeam()
            end

            if SpearCrosshairEnabled then
                v808()

                return
            end

            if p124.SpearCrosshair.Frame then
                p124.SpearCrosshair.Frame.Visible = false
            end

            if p124.SpearCrosshair.AttributeListener then
                p124.SpearCrosshair.AttributeListener:Disconnect()
                p124.SpearCrosshair.AttributeListener = nil
            end
        end)

        return
    end

    if p124.SpearCrosshair.Frame then
        local FrameParent = p124.SpearCrosshair.Frame.Parent

        if FrameParent then
            FrameParent:Destroy()
        end

        p124.SpearCrosshair.Frame = nil
    end

    if p124.SpearCrosshair.AttributeListener then
        p124.SpearCrosshair.AttributeListener:Disconnect()
        p124.SpearCrosshair.AttributeListener = nil
    end

    if p124.SpearCrosshair.RenderConn then
        p124.SpearCrosshair.RenderConn:Disconnect()
        p124.SpearCrosshair.RenderConn = nil
    end

    for _, v in ipairs(p124.SpearCrosshair.TeamListeners) do
        pcall(v.Disconnect, v)
    end

    p124.SpearCrosshair.TeamListeners = {}
end
t1[22].ToggleNoSlowdown = function(p126, p127)
    p126.NoSlowdown.Enabled = p127

    if p127 then
        local function v814()
            local Character = t1[14].Character

            if Character then
                local v1429 = t1[16].GetHumanoid(Character)

                if v1429 then
                    p126.NoSlowdown.OriginalSpeed = v1429.WalkSpeed
                end
            end
        end
        local function v815()
            if p126.NoSlowdown.Connection then
                p126.NoSlowdown.Connection:Disconnect()
            end

            local NoSlowdownEnabled = p126.NoSlowdown.Enabled

            if NoSlowdownEnabled then
                NoSlowdownEnabled = t1[16].IsKillerTeam()
            end

            if NoSlowdownEnabled then
                v814()
                p126.NoSlowdown.Connection = t1[4].Heartbeat:Connect(function()
                    local v1673 = not p126.NoSlowdown.Enabled

                    if not v1673 then
                        v1673 = not t1[16].IsKillerTeam()
                    end

                    if v1673 then
                        return
                    end

                    local Character = t1[14].Character

                    if not Character then
                        return
                    end

                    local v1675 = t1[16].GetHumanoid(Character)

                    if not v1675 then
                        return
                    end

                    if v1675.WalkSpeed < 16 then
                        v1675.WalkSpeed = p126.NoSlowdown.OriginalSpeed or 16

                        return
                    end

                    if v1675.WalkSpeed > (p126.NoSlowdown.OriginalSpeed or 16) then
                        p126.NoSlowdown.OriginalSpeed = v1675.WalkSpeed
                    end
                end)

                return
            end

            local Character = t1[14].Character

            if Character then
                local v1435 = t1[16].GetHumanoid(Character)
                local v1436 = v1435

                if v1435 then
                    v1436 = p126.NoSlowdown.OriginalSpeed
                end

                if v1436 then
                    v1435.WalkSpeed = p126.NoSlowdown.OriginalSpeed
                end
            end
        end

        p126.NoSlowdown.TeamListeners = t1[16].SetupTeamListener(v815)
        v815()

        return
    end

    if p126.NoSlowdown.Connection then
        p126.NoSlowdown.Connection:Disconnect()
        p126.NoSlowdown.Connection = nil
    end

    local Character = t1[14].Character

    if Character then
        local v817 = t1[16].GetHumanoid(Character)
        local v818 = v817

        if v817 then
            v818 = p126.NoSlowdown.OriginalSpeed
        end

        if v818 then
            v817.WalkSpeed = p126.NoSlowdown.OriginalSpeed
        end
    end

    for _, v in ipairs(p126.NoSlowdown.TeamListeners) do
        pcall(v.Disconnect, v)
    end

    p126.NoSlowdown.TeamListeners = {}
end
t1[22].ToggleThirdPerson = function(p128, p129)
    p128.ThirdPerson.Enabled = p129

    if p129 then
        local function v823()
            local CurrentCamera = t1[3].CurrentCamera

            if not CurrentCamera then
                return
            end

            local ThirdPersonEnabled = p128.ThirdPerson.Enabled

            if ThirdPersonEnabled then
                ThirdPersonEnabled = t1[16].IsKillerTeam()
            end

            if ThirdPersonEnabled then
                if not p128.ThirdPerson.Active then
                    p128.ThirdPerson.OriginalCameraType = CurrentCamera.CameraType
                end

                CurrentCamera.CameraType = Enum.CameraType.Custom

                local Character = t1[14].Character

                if Character then
                    local v1440 = t1[16].GetHumanoid(Character)

                    if v1440 then
                        v1440.CameraOffset = p128.ThirdPerson.Offset
                    end
                end

                p128.ThirdPerson.Active = true

                return
            end

            if p128.ThirdPerson.Active then
                if p128.ThirdPerson.OriginalCameraType then
                    CurrentCamera.CameraType = p128.ThirdPerson.OriginalCameraType
                    p128.ThirdPerson.OriginalCameraType = nil
                end

                local Character = t1[14].Character

                if Character then
                    local v1442 = t1[16].GetHumanoid(Character)

                    if v1442 then
                        v1442.CameraOffset = Vector3.zero
                    end
                end

                p128.ThirdPerson.Active = false
            end
        end
        local function v824()
            if p128.ThirdPerson.Connection then
                p128.ThirdPerson.Connection:Disconnect()
            end

            local ThirdPersonEnabled = p128.ThirdPerson.Enabled

            if ThirdPersonEnabled then
                ThirdPersonEnabled = t1[16].IsKillerTeam()
            end

            if ThirdPersonEnabled then
                p128.ThirdPerson.Connection = t1[4].Heartbeat:Connect(v823)

                return
            end

            if p128.ThirdPerson.Connection then
                p128.ThirdPerson.Connection:Disconnect()
                p128.ThirdPerson.Connection = nil
            end

            local CurrentCamera = t1[3].CurrentCamera
            local v1445 = CurrentCamera

            if CurrentCamera then
                v1445 = p128.ThirdPerson.OriginalCameraType
            end

            if v1445 then
                CurrentCamera.CameraType = p128.ThirdPerson.OriginalCameraType
                p128.ThirdPerson.OriginalCameraType = nil
            end

            local Character = t1[14].Character

            if Character then
                local v1447 = t1[16].GetHumanoid(Character)

                if v1447 then
                    v1447.CameraOffset = Vector3.zero
                end
            end

            p128.ThirdPerson.Active = false
        end

        p128.ThirdPerson.TeamListeners = t1[16].SetupTeamListener(v824)
        v824()

        return
    end

    if p128.ThirdPerson.Connection then
        p128.ThirdPerson.Connection:Disconnect()
        p128.ThirdPerson.Connection = nil
    end

    local CurrentCamera = t1[3].CurrentCamera
    local v826 = CurrentCamera

    if CurrentCamera then
        v826 = p128.ThirdPerson.OriginalCameraType
    end

    if v826 then
        CurrentCamera.CameraType = p128.ThirdPerson.OriginalCameraType
        p128.ThirdPerson.OriginalCameraType = nil
    end

    local Character = t1[14].Character

    if Character then
        local v828 = t1[16].GetHumanoid(Character)

        if v828 then
            v828.CameraOffset = Vector3.zero
        end
    end

    p128.ThirdPerson.Active = false

    for _, v in ipairs(p128.ThirdPerson.TeamListeners) do
        pcall(v.Disconnect, v)
    end

    p128.ThirdPerson.TeamListeners = {}
end
t1[22].ToggleAntiBlind = function(p130, p131)
    p130.AntiBlind.Enabled = p131

    if p131 then
        local function v833()
            local t94 = {}

            local function v1449(p132)
                if not p132 then
                    return
                end

                local GetDescendants = p132.GetDescendants

                for _, v in ipairs(GetDescendants(p132)) do
                    if v:IsA("RemoteEvent") then
                        local v1680 = v.Name:lower()
                        local v1681 = v1680:find("blind")

                        if not v1681 then
                            v1681 = v1680:find("flash")

                            if not v1681 then
                                v1681 = v1680:find("gotblinded")

                                if not v1681 then
                                    v1681 = v1680:find("blinded")
                                end
                            end
                        end

                        if v1681 then
                            table.insert(t94, v)
                        end
                    end
                end
            end

            v1449(t1[6]:FindFirstChild("Remotes"))
            v1449(t1[6]:FindFirstChild("Events"))

            for _, descendant in ipairs(t1[6]:GetDescendants()) do
                if descendant:IsA("RemoteEvent") then
                    local v1452 = descendant.Name:lower()
                    local v1453 = v1452:find("blind")

                    if not v1453 then
                        v1453 = v1452:find("flash")
                    end

                    if v1453 then
                        table.insert(t94, descendant)
                    end
                end
            end

            return t94
        end
        local function v834()
            if p130.AntiBlind.Hooked then
                return true
            end

            local v1454 = v833()

            if #v1454 == 0 then
                return false
            end

            local v1455 = getrawmetatable(game)

            if not v1455 then
                return false
            end

            p130.AntiBlind.OriginalNamecall = v1455.__namecall

            local v1456 = isreadonly and isreadonly(v1455)

            if setreadonly then
                setreadonly(v1455, false)
            end

            v1455.__namecall = newcclosure(function(p133, ...)
                local v1683 = getnamecallmethod() == "FireServer"

                if v1683 then
                    v1683 = p130.AntiBlind.Enabled

                    if v1683 then
                        v1683 = t1[16].IsKillerTeam()
                    end
                end

                if v1683 then
                    local v1684, v1685, v1686 = ipairs(v1454)

                    repeat
                        local v1687

                        v1686, v1687 = v1684(v1685, v1686)

                        if not v1686 then
                            local v1688 = tostring(p133):lower()
                            local v1689 = v1688:find("blind")

                            if not v1689 then
                                v1689 = v1688:find("flash")

                                if not v1689 then
                                    v1689 = v1688:find("gotblinded")

                                    if not v1689 then
                                        v1689 = v1688:find("blinded")
                                    end
                                end
                            end

                            if not v1689 then
                                return p130.AntiBlind.OriginalNamecall(p133, ...)
                            end

                            return nil
                        end
                    until p133 == v1687

                    return nil
                end

                return p130.AntiBlind.OriginalNamecall(p133, ...)
            end)

            if setreadonly and v1456 then
                setreadonly(v1455, true)
            end

            p130.AntiBlind.Hooked = true

            return true
        end
        local function v835()
            local AntiBlindEnabled = p130.AntiBlind.Enabled

            if AntiBlindEnabled then
                AntiBlindEnabled = t1[16].IsKillerTeam()
            end

            if AntiBlindEnabled then
                if not v834() then
                    task.spawn(function()
                        for _ = 1, 5 do
                            task.wait(1)

                            local AntiBlindEnabled2 = p130.AntiBlind.Enabled

                            if AntiBlindEnabled2 then
                                AntiBlindEnabled2 = t1[16].IsKillerTeam()

                                if AntiBlindEnabled2 then
                                    AntiBlindEnabled2 = not p130.AntiBlind.Hooked
                                end
                            end

                            if AntiBlindEnabled2 and v834() then
                                return
                            end
                        end
                    end)

                    return
                end
            elseif p130.AntiBlind.Hooked then
                local v1458 = getrawmetatable(game)
                local v1459 = v1458

                if v1458 then
                    v1459 = p130.AntiBlind.OriginalNamecall
                end

                if v1459 then
                    local v1460 = isreadonly and isreadonly(v1458)

                    if setreadonly then
                        setreadonly(v1458, false)
                    end

                    v1458.__namecall = p130.AntiBlind.OriginalNamecall

                    if setreadonly and v1460 then
                        setreadonly(v1458, true)
                    end

                    p130.AntiBlind.Hooked = false
                end
            end
        end

        p130.AntiBlind.TeamListeners = t1[16].SetupTeamListener(v835)
        v835()

        return
    end

    if p130.AntiBlind.Hooked then
        local v836 = getrawmetatable(game)
        local v837 = v836

        if v836 then
            v837 = p130.AntiBlind.OriginalNamecall
        end

        if v837 then
            local v838 = isreadonly and isreadonly(v836)

            if setreadonly then
                setreadonly(v836, false)
            end

            v836.__namecall = p130.AntiBlind.OriginalNamecall

            if setreadonly and v838 then
                setreadonly(v836, true)
            end

            p130.AntiBlind.Hooked = false
        end
    end

    for _, v in ipairs(p130.AntiBlind.TeamListeners) do
        pcall(v.Disconnect, v)
    end

    p130.AntiBlind.TeamListeners = {}
end
t1[22].ToggleNoPalletStun = function(p134, p135)
    p134.NoPalletStun.Enabled = p135

    if p135 then
        local function v843()
            local ok, result = pcall(function()
                return t1[6]:WaitForChild("Remotes", 5):WaitForChild("Pallet", 5):WaitForChild("Jason", 5):WaitForChild("Stun", 5)
            end)
            local ok2, result2 = pcall(function()
                return t1[6]:WaitForChild("Remotes", 5):WaitForChild("Pallet", 5):WaitForChild("Jason", 5):WaitForChild("Stunover", 5)
            end)

            return ok and result, ok2 and result2
        end
        local function v844()
            local _, v1466 = v843()

            if v1466 then
                pcall(v1466.FireServer, v1466)
            end
        end
        local function v845()
            if p134.NoPalletStun.Hooked then
                return true
            end

            local v1467, _ = v843()
            local v1469 = v1467

            if not v1469 then
                return false
            end

            local v1470 = getrawmetatable(v1469)

            if not v1470 then
                return false
            end

            p134.NoPalletStun.OriginalNamecall = v1470.__namecall

            local v1471 = isreadonly and isreadonly(v1470)

            if setreadonly then
                setreadonly(v1470, false)
            end

            v1470.__namecall = newcclosure(function(p136, ...)
                local v1693 = getnamecallmethod()
                local v1694 = p136 == v1469

                if v1694 then
                    v1694 = v1693 == "FireServer"

                    if v1694 then
                        v1694 = p134.NoPalletStun.Enabled

                        if v1694 then
                            v1694 = t1[16].IsKillerTeam()
                        end
                    end
                end

                if v1694 then
                    local v1695 = p134.NoPalletStun.OriginalNamecall(p136, ...)

                    task.spawn(v844)

                    return v1695
                end

                return p134.NoPalletStun.OriginalNamecall(p136, ...)
            end)

            if setreadonly and v1471 then
                setreadonly(v1470, true)
            end

            p134.NoPalletStun.Hooked = true

            return true
        end
        local function v846()
            local NoPalletStunEnabled = p134.NoPalletStun.Enabled

            if NoPalletStunEnabled then
                NoPalletStunEnabled = t1[16].IsKillerTeam()
            end

            if NoPalletStunEnabled then
                if not v845() then
                    task.spawn(function()
                        for _ = 1, 5 do
                            task.wait(1)

                            local NoPalletStunEnabled2 = p134.NoPalletStun.Enabled

                            if NoPalletStunEnabled2 then
                                NoPalletStunEnabled2 = t1[16].IsKillerTeam()

                                if NoPalletStunEnabled2 then
                                    NoPalletStunEnabled2 = not p134.NoPalletStun.Hooked
                                end
                            end

                            if NoPalletStunEnabled2 and v845() then
                                return
                            end
                        end
                    end)

                    return
                end
            elseif p134.NoPalletStun.Hooked then
                local v1473, _ = v843()

                if v1473 then
                    local v1475 = getrawmetatable(v1473)
                    local v1476 = v1475

                    if v1475 then
                        v1476 = p134.NoPalletStun.OriginalNamecall
                    end

                    if v1476 then
                        local v1477 = isreadonly and isreadonly(v1475)

                        if setreadonly then
                            setreadonly(v1475, false)
                        end

                        v1475.__namecall = p134.NoPalletStun.OriginalNamecall

                        if setreadonly and v1477 then
                            setreadonly(v1475, true)
                        end

                        p134.NoPalletStun.Hooked = false
                    end
                end
            end
        end

        p134.NoPalletStun.TeamListeners = t1[16].SetupTeamListener(v846)
        v846()

        return
    end

    if p134.NoPalletStun.Hooked then
        local ok, _ = pcall(function()
            return t1[6]:WaitForChild("Remotes", 5):WaitForChild("Pallet", 5):WaitForChild("Jason", 5):WaitForChild("Stun", 5)
        end)

        if ok then
            local v849 = getrawmetatable(ok)
            local v850 = v849

            if v849 then
                v850 = p134.NoPalletStun.OriginalNamecall
            end

            if v850 then
                local v851 = isreadonly and isreadonly(v849)

                if setreadonly then
                    setreadonly(v849, false)
                end

                v849.__namecall = p134.NoPalletStun.OriginalNamecall

                if setreadonly and v851 then
                    setreadonly(v849, true)
                end

                p134.NoPalletStun.Hooked = false
            end
        end
    end

    for _, v in ipairs(p134.NoPalletStun.TeamListeners) do
        pcall(v.Disconnect, v)
    end

    p134.NoPalletStun.TeamListeners = {}
end
t1[22].ToggleBeatGame = function(p137, p138)
    p137.BeatGame.Enabled = p138

    if p138 then
        local function v856(p139)
            return ((if not (not p139 or p139.MaxHealth <= 0) then p139.Health / p139.MaxHealth else 0)) > 0.25
        end
        local function v857(p140)
            if not p140 or not p140.Character then
                return false
            end

            local Character = p140.Character
            local v1485 = t1[16].GetHumanoid(Character)

            if v1485 then
                local GetPlayingAnimationTracks = v1485.GetPlayingAnimationTracks

                for _, v in ipairs(GetPlayingAnimationTracks(v1485)) do
                    local Animation = v.Animation

                    if Animation then
                        Animation = v.Animation.AnimationId:lower():find("hook")
                    end

                    if Animation then
                        return true
                    end
                end
            end

            local IsOnHook = Character:GetAttribute("IsOnHook")

            if not IsOnHook then
                IsOnHook = Character:GetAttribute("IsTrapped")
            end

            if IsOnHook then
                return true
            end

            return false
        end
        local function v858()
            local v1491 = not p137.BeatGame.Enabled

            if not v1491 then
                v1491 = not t1[16].IsKillerTeam()
            end

            if v1491 then
                p137.BeatGame.Target = nil

                return
            end

            local v1492 = t1[16].GetCharacterRoot(t1[14].Character)

            if not v1492 then
                return
            end

            local v1493 = true
            local BeatGameTarget = p137.BeatGame.Target

            if BeatGameTarget then
                BeatGameTarget = p137.BeatGame.Target.Character
            end

            if BeatGameTarget then
                local v1495 = t1[16].GetCharacterRoot(p137.BeatGame.Target.Character)
                local v1496 = t1[16].GetHumanoid(p137.BeatGame.Target.Character)

                if v1495 then
                    if v1496 then
                        v1496 = v856(v1496)

                        if v1496 then
                            local BeatGameTarget2 = p137.BeatGame.Target

                            if not BeatGameTarget2 or not BeatGameTarget2.Team then
                                v1496 = false
                            else
                                local v1498 = BeatGameTarget2.Team.Name:lower()

                                v1496 = v1498:find("survivor")

                                if not v1496 then
                                    v1496 = v1498 == "survivors" or v1498 == "survivor"
                                end
                            end

                            if v1496 then
                                v1496 = not v857(p137.BeatGame.Target)
                            end
                        end
                    end

                    v1495 = v1496
                end

                if v1495 then
                    v1493 = false
                else
                    p137.BeatGame.Target = nil
                end
            end

            if v1493 then
                local t95 = {}
                for v1502, v1503 in ipairs(t1[2]:GetPlayers()) do

                    local v1504 = v1503 ~= t1[14]

                    if v1504 then
                        if not v1503 or not v1503.Team then
                            v1504 = false
                        else
                            local v1505 = v1503.Team.Name:lower()

                            v1504 = v1505:find("survivor")

                            if not v1504 then
                                v1504 = v1505 == "survivors" or v1505 == "survivor"
                            end
                        end

                        if v1504 then
                            v1504 = v1503.Character
                        end
                    end

                    if v1504 then
                        local v1506 = t1[16].GetCharacterRoot(v1503.Character)
                        local v1507 = t1[16].GetHumanoid(v1503.Character)

                        if v1506 then
                            if v1507 then
                                v1507 = v856(v1507) and not v857(v1503)
                            end

                            v1506 = v1507
                        end

                        if v1506 then
                            table.insert(t95, v1503)
                        end
                    end
                end
                if not (#t95 > 0) then
                    p137.BeatGame.Target = nil

                    return
                end
                local n11 = 1e999
                local v1509
                for _, v in ipairs(t95) do
                    local Magnitude = (t1[16].GetCharacterRoot(v.Character).Position - v1492.Position).Magnitude

                    if Magnitude < n11 then
                        n11 = Magnitude
                        v1509 = v
                    end
                end
                p137.BeatGame.Target = v1509
            end

            local v1513 = not p137.BeatGame.Target

            if not v1513 then
                v1513 = not p137.BeatGame.Target.Character
            end

            if v1513 then
                return
            end

            local v1514 = t1[16].GetCharacterRoot(p137.BeatGame.Target.Character)
            local v1515 = t1[16].GetHumanoid(p137.BeatGame.Target.Character)
            local v1516 = not v1514

            if not v1516 then
                v1516 = not v1515

                if not v1516 then
                    v1516 = not v856(v1515)

                    if not v1516 then
                        v1516 = v857(p137.BeatGame.Target)
                    end
                end
            end

            if v1516 then
                p137.BeatGame.Target = nil

                return
            end

            local Character = t1[14].Character

            if Character then
                for _, descendant in ipairs(Character:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        descendant.CanCollide = false
                    end
                end
            end

            local Unit = (v1492.Position - v1514.Position).Unit
            local v1521 = v1514.Position + Unit * 3 + Vector3.new(0, 1, 0)

            v1492.CFrame = CFrame.new(v1521, v1514.Position)

            local Remotes = t1[6]:FindFirstChild("Remotes")

            if Remotes then
                Remotes = t1[6].Remotes:FindFirstChild("Attacks")

                if Remotes then
                    Remotes = t1[6].Remotes.Attacks:FindFirstChild("BasicAttack")
                end
            end

            if Remotes then
                pcall(Remotes.FireServer, Remotes, false)
            end
        end
        local function v859()
            if p137.BeatGame.Connection then
                p137.BeatGame.Connection:Disconnect()
            end

            local BeatGameEnabled = p137.BeatGame.Enabled

            if BeatGameEnabled then
                BeatGameEnabled = t1[16].IsKillerTeam()
            end

            if BeatGameEnabled then
                p137.BeatGame.Connection = t1[4].Heartbeat:Connect(v858)

                return
            end

            if p137.BeatGame.Connection then
                p137.BeatGame.Connection:Disconnect()
                p137.BeatGame.Connection = nil
            end

            p137.BeatGame.Target = nil
        end

        p137.BeatGame.TeamListeners = t1[16].SetupTeamListener(v859)
        v859()

        return
    end

    if p137.BeatGame.Connection then
        p137.BeatGame.Connection:Disconnect()
        p137.BeatGame.Connection = nil
    end

    p137.BeatGame.Target = nil

    for _, v in ipairs(p137.BeatGame.TeamListeners) do
        pcall(v.Disconnect, v)
    end

    p137.BeatGame.TeamListeners = {}
end
t1[22].ToggleUseFakeSaw = function(p141, p142)
    p141.UseFakeSaw.Enabled = p142

    if p142 then
        local function v864()
            local ok, result = pcall(function()
                return t1[6]:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Masked"):WaitForChild("alexattack")
            end)

            return ok and result or nil
        end
        local function v865()
            if p141.UseFakeSaw.Connection then
                p141.UseFakeSaw.Connection:Disconnect()
            end

            local UseFakeSawEnabled = p141.UseFakeSaw.Enabled

            if UseFakeSawEnabled then
                UseFakeSawEnabled = t1[16].IsKillerTeam()
            end

            if UseFakeSawEnabled then
                p141.UseFakeSaw.Connection = t1[4].Heartbeat:Connect(function()
                    local UseFakeSawEnabled2 = p141.UseFakeSaw.Enabled

                    if UseFakeSawEnabled2 then
                        UseFakeSawEnabled2 = t1[16].IsKillerTeam()
                    end

                    if UseFakeSawEnabled2 then
                        local v1699 = not p141.UseFakeSaw.Enabled

                        if not v1699 then
                            v1699 = not t1[16].IsKillerTeam()
                        end

                        if not v1699 then
                            local v1700 = v864()

                            if v1700 then
                                pcall(v1700.FireServer, v1700)
                            end
                        end

                        task.wait(35)
                    end
                end)
            end
        end

        p141.UseFakeSaw.TeamListeners = t1[16].SetupTeamListener(v865)
        v865()

        return
    end

    if p141.UseFakeSaw.Connection then
        p141.UseFakeSaw.Connection:Disconnect()
        p141.UseFakeSaw.Connection = nil
    end

    for _, v in ipairs(p141.UseFakeSaw.TeamListeners) do
        pcall(v.Disconnect, v)
    end

    p141.UseFakeSaw.TeamListeners = {}
end
t1[22].ToggleAbysswalkerCorrupt = function(p143, p144)
    p143.AbysswalkerCorrupt.Enabled = p144

    if p144 then
        local function v870()
            local v1529 = not p143.AbysswalkerCorrupt.Enabled

            if not v1529 then
                v1529 = not t1[16].IsKillerTeam()
            end

            if v1529 then
                return
            end

            pcall(function()
                t1[6]:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Abysswalker"):WaitForChild("corrupt"):FireServer()
            end)
        end
        local function v871()
            if p143.AbysswalkerCorrupt.InputConn then
                p143.AbysswalkerCorrupt.InputConn:Disconnect()
            end

            local AbysswalkerCorruptEnabled = p143.AbysswalkerCorrupt.Enabled

            if AbysswalkerCorruptEnabled then
                AbysswalkerCorruptEnabled = t1[16].IsKillerTeam()
            end

            if AbysswalkerCorruptEnabled then
                p143.AbysswalkerCorrupt.InputConn = t1[5].InputBegan:Connect(function(input, gameProcessed)
                    local v1703 = not gameProcessed

                    if v1703 then
                        v1703 = input.KeyCode == Enum.KeyCode.Q
                    end

                    if v1703 then
                        v870()
                    end
                end)
            end
        end

        p143.AbysswalkerCorrupt.TeamListeners = t1[16].SetupTeamListener(v871)
        v871()

        return
    end

    if p143.AbysswalkerCorrupt.InputConn then
        p143.AbysswalkerCorrupt.InputConn:Disconnect()
        p143.AbysswalkerCorrupt.InputConn = nil
    end

    for _, v in ipairs(p143.AbysswalkerCorrupt.TeamListeners) do
        pcall(v.Disconnect, v)
    end

    p143.AbysswalkerCorrupt.TeamListeners = {}
end
t1[22].ToggleAutoAttack = function(p145, p146)
    p145.AutoAttack.Enabled = p146
    task.spawn(function()
        while p145.AutoAttack.Enabled do
            if t1[16].IsKillerTeam() then
                local v1531 = t1[16].GetCharacterRoot(t1[14].Character)

                if v1531 then
                    for _, player in ipairs(t1[2]:GetPlayers()) do
                        if not (player ~= t1[14] and player.Character) then
                            continue
                        end

                        local v1534 = t1[16].GetCharacterRoot(player.Character)

                        if v1534 then
                            v1534 = (v1534.Position - v1531.Position).Magnitude <= p145.AutoAttack.Range
                        end

                        if v1534 then
                            local Remotes = t1[6]:FindFirstChild("Remotes")

                            if Remotes then
                                Remotes = t1[6].Remotes:FindFirstChild("Attacks")

                                if Remotes then
                                    Remotes = t1[6].Remotes.Attacks:FindFirstChild("BasicAttack")
                                end
                            end

                            if not Remotes then
                                break
                            end

                            pcall(Remotes.FireServer, Remotes, false)

                            break
                        end
                    end
                end
            end

            task.wait(0.2)
        end
    end)
end
t1[22].ToggleAutoHook = function(p147, p148)
    p147.AutoHook.Enabled = p148
    task.spawn(function()
        local g1542
        while p147.AutoHook.Enabled do
            if t1[16].IsKillerTeam() then
                local v1536 = t1[16].GetCharacterRoot(t1[14].Character)

                if v1536 then
                    local v1537
                    local v1538, v1539, v1540 = ipairs(t1[2]:GetPlayers())
                    local v1541
                    repeat
                        repeat
                            v1540, v1541 = v1538(v1539, v1540)

                            if not v1540 then
                                g1542 = true
                            end

                            if g1542 then
                                break
                            end
                        until v1541 ~= t1[14] and v1541.Character

                        if g1542 then
                            break
                        end

                        local v1543 = t1[16].GetHumanoid(v1541.Character)

                        if v1543 then
                            v1543 = v1543.Health <= v1543.MaxHealth * 0.25
                        end
                    until v1543
                    if not g1542 then
                        v1537 = v1541
                    end
                    g1542 = false
                    if v1537 and v1537.Character then
                        local v1544 = t1[16].GetCharacterRoot(v1537.Character)

                        if v1544 then
                            v1536.CFrame = CFrame.new(v1544.Position + Vector3.new(0, 3, 0), v1544.Position)

                            for _ = 1, 10 do
                                t1[7]:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                task.wait(0.05)
                                t1[7]:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end

            task.wait(0.5)
        end
    end)
end
t1[22].ToggleKillAll = function(p149, p150)
    p149.KillAll.Enabled = p150

    if p150 then
        if p149.KillAll.Thread then
            coroutine.close(p149.KillAll.Thread)
        end

        p149.KillAll.Thread = coroutine.create(function()
            local Remotes = t1[6]:FindFirstChild("Remotes")
            local g1569
            if Remotes then
                Remotes = t1[6].Remotes:FindFirstChild("Attacks")

                if Remotes then
                    Remotes = t1[6].Remotes.Attacks:FindFirstChild("BasicAttack")
                end
            end
            local v1547 = Remotes
            local CFrame2
            while p149.KillAll.Enabled do
                task.wait(0.2)

                local Character = t1[14].Character
                local v1550 = t1[16].GetCharacterRoot(Character)

                if v1550 then
                    if not CFrame2 then
                        CFrame2 = v1550.CFrame
                    end
                    local t96 = {}
                    for v1554, v1555 in ipairs(t1[2]:GetPlayers()) do

                        if v1555 ~= t1[14] and v1555.Character then
                            local v1556 = t1[16].GetCharacterRoot(v1555.Character)
                            local v1557 = t1[16].GetHumanoid(v1555.Character)
                            local v1558 = v1556

                            if v1556 then
                                v1558 = v1557 and v1557.Health > 20
                            end

                            if v1558 then
                                table.insert(t96, {
									root = v1556,
									humanoid = v1557
								})
                            end
                        end
                    end
                    for v1561, v1562 in ipairs(t96) do

                        local v1563 = v1562

                        if not p149.KillAll.Enabled then
                            break
                        end

                        if v1563.humanoid.Health > 20 then
                            pcall(function()
                                v1550.CFrame = v1563.root.CFrame * CFrame.new(0, 0, 2)

                                if v1547 then
                                    v1547:FireServer()
                                end
                            end)
                            task.wait(0.15)
                        end
                    end
                    local v1564 = true
                    local v1565, v1566, v1567 = ipairs(t96)
                    repeat
                        local v1568

                        v1567, v1568 = v1565(v1566, v1567)

                        if not v1567 then
                            g1569 = true
                        end

                        if g1569 then
                            break
                        end
                    until v1568.humanoid.Health > 20
                    if not g1569 then
                        v1564 = false
                    end
                    g1569 = false
                    if v1564 and CFrame2 then
                        v1550.CFrame = CFrame2
                        task.wait(1)
                    end
                end
            end
        end)
        coroutine.resume(p149.KillAll.Thread)

        return
    end

    if p149.KillAll.Thread then
        coroutine.close(p149.KillAll.Thread)
        p149.KillAll.Thread = nil
    end
end
t1[22].ToggleRemovePallet = function(p151, p152)
    p151.RemovePallet.Enabled = p152

    if p152 then
        if p151.RemovePallet.Thread then
            coroutine.close(p151.RemovePallet.Thread)
        end

        p151.RemovePallet.Thread = coroutine.create(function()
            while p151.RemovePallet.Enabled do
                for _, descendant in ipairs(t1[3]:GetDescendants()) do
                    local v1572 = descendant
                    local v1573 = v1572:IsA("Model")

                    if v1573 then
                        v1573 = v1572.Name == "Palletwrong"
                    end

                    if v1573 then
                        pcall(function()
                            v1572:Destroy()
                        end)
                    end
                end

                task.wait(1)
            end
        end)
        coroutine.resume(p151.RemovePallet.Thread)

        return
    end

    if p151.RemovePallet.Thread then
        coroutine.close(p151.RemovePallet.Thread)
        p151.RemovePallet.Thread = nil
    end
end
t1[22].ActivateMaskPower = function(_, p154)
    if not t1[16].IsKillerTeam() then
        return false
    end

    return pcall(function()
        t1[6]:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Masked"):WaitForChild("Activatepower"):FireServer(p154)
    end)
end
t1[22].Cleanup = function(p155)
    if p155.SpearCrosshair.Frame then
        p155.SpearCrosshair.Frame.Parent:Destroy()
    end

    if p155.SpearCrosshair.AttributeListener then
        p155.SpearCrosshair.AttributeListener:Disconnect()
    end

    if p155.SpearCrosshair.RenderConn then
        p155.SpearCrosshair.RenderConn:Disconnect()
    end

    if p155.NoSlowdown.Connection then
        p155.NoSlowdown.Connection:Disconnect()
    end

    if p155.ThirdPerson.Connection then
        p155.ThirdPerson.Connection:Disconnect()
    end

    if p155.AntiBlind.Hooked then
        local v885 = getrawmetatable(game)

        if v885 then
            local v886 = isreadonly and isreadonly(v885)

            if setreadonly then
                setreadonly(v885, false)
            end

            v885.__namecall = p155.AntiBlind.OriginalNamecall

            if setreadonly and v886 then
                setreadonly(v885, true)
            end
        end
    end

    if p155.NoPalletStun.Hooked then
        local ok = pcall(function()
            return t1[6]:WaitForChild("Remotes", 5):WaitForChild("Pallet", 5):WaitForChild("Jason", 5):WaitForChild("Stun", 5)
        end)

        if ok then
            local v888 = getrawmetatable(ok)

            if v888 then
                local v889 = isreadonly and isreadonly(v888)

                if setreadonly then
                    setreadonly(v888, false)
                end

                v888.__namecall = p155.NoPalletStun.OriginalNamecall

                if setreadonly and v889 then
                    setreadonly(v888, true)
                end
            end
        end
    end

    if p155.BeatGame.Connection then
        p155.BeatGame.Connection:Disconnect()
    end

    if p155.UseFakeSaw.Connection then
        p155.UseFakeSaw.Connection:Disconnect()
    end

    if p155.AbysswalkerCorrupt.InputConn then
        p155.AbysswalkerCorrupt.InputConn:Disconnect()
    end

    if p155.KillAll.Thread then
        coroutine.close(p155.KillAll.Thread)
    end

    if p155.RemovePallet.Thread then
        coroutine.close(p155.RemovePallet.Thread)
    end

    for _, v in ipairs({
		p155.SpearCrosshair.TeamListeners,
		p155.NoSlowdown.TeamListeners,
		p155.ThirdPerson.TeamListeners,
		p155.AntiBlind.TeamListeners,
		p155.NoPalletStun.TeamListeners,
		p155.BeatGame.TeamListeners,
		p155.UseFakeSaw.TeamListeners,
		p155.AbysswalkerCorrupt.TeamListeners
	}) do
        for _, v7 in ipairs(v) do
            pcall(v7.Disconnect, v7)
        end
    end
end
t1[23] = {}
t1[23].__index = t1[23]
t1[23].new = function()
    local self = setmetatable({}, t1[23])

    self.Crosshair = {
		Enabled = t1[17].Visual.Crosshair.Enabled,
		Gui = nil
	}
    self.Aspect43 = {
		Enabled = t1[17].Visual.Aspect43.Enabled,
		Connection = nil
	}
    self.ChinaHat = {
		Enabled = t1[17].Visual.ChinaHat.Enabled,
		Part = nil,
		Weld = nil,
		Conn = nil,
		CharConn = nil
	}
    self.ChamsSelf = {
		Enabled = t1[17].Visual.ChamsSelf.Enabled
	}
    self.ChamsOthers = {
		Enabled = t1[17].Visual.ChamsOthers.Enabled
	}

    local WorldTintEnabled = t1[17].Visual.WorldTint.Enabled
    local Red = t1[17].Visual.WorldTint.Red
    local Green = t1[17].Visual.WorldTint.Green
    local Blue = t1[17].Visual.WorldTint.Blue
    local WorldTintBrightness = t1[17].Visual.WorldTint.Brightness

    self.WorldTint = {
		Enabled = WorldTintEnabled,
		Red = Red,
		Green = Green,
		Blue = Blue,
		Brightness = WorldTintBrightness,
		CC = nil,
		LightingConn = nil
	}
    self.Fullbright = {
		Enabled = t1[17].Visual.Fullbright.Enabled
	}
    self.NoShadow = {
		Enabled = t1[17].Visual.NoShadow.Enabled
	}
    self.Connections = {}
    self.ChamsConnections = {}

    return self
end
t1[23].IsChamsEnabledForPlayer = function(p156, p157)
    if p157 == t1[14] then
        return p156.ChamsSelf.Enabled
    end

    return p156.ChamsOthers.Enabled
end
t1[23].ApplyChamsToPlayer = function(_, p159, p160)
    if not p159 or not p159.Character then
        return
    end

    for _, descendant in ipairs(p159.Character:GetDescendants()) do
        local v907 = descendant:IsA("BasePart")

        if v907 then
            v907 = descendant.Name ~= "ChinaHat"
        end

        if v907 then
            if p160 then
                descendant.Material = Enum.Material.ForceField
                descendant.Color = Color3.fromRGB(255, 0, 255)
            else
                descendant.Material = Enum.Material.Plastic
                descendant.Color = Color3.new(1, 1, 1)
            end
        end
    end
end
t1[23].UpdateChams = function(p161)

    for v911, v912 in ipairs(p161.ChamsConnections) do

        pcall(v912.Disconnect, v912)
    end
    p161.ChamsConnections = {}
    for _, player in ipairs(t1[2]:GetPlayers()) do
        p161:ApplyChamsToPlayer(player, false)
    end
    local v915 = not p161.ChamsSelf.Enabled
    if v915 then
        v915 = not p161.ChamsOthers.Enabled
    end
    if v915 then
        return
    end
    local function v916(p162, p163)
        if not p163 or not p163.Parent then
            return
        end

        p161:ApplyChamsToPlayer(p162, true)

        local connection = p163.DescendantAdded:Connect(function(descendant)
            local v1705 = descendant:IsA("BasePart")

            if v1705 then
                v1705 = descendant.Name ~= "ChinaHat"
            end

            if v1705 and p161:IsChamsEnabledForPlayer(p162) then
                descendant.Material = Enum.Material.ForceField
                descendant.Color = Color3.fromRGB(255, 0, 255)
            end
        end)

        table.insert(p161.ChamsConnections, connection)
    end
    local function v917(p164)
        local connection = p164.CharacterAdded:Connect(function(character)
            local HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

            task.wait(0.5)

            if HumanoidRootPart and p161:IsChamsEnabledForPlayer(p164) then
                v916(p164, character)
            end
        end)

        table.insert(p161.ChamsConnections, connection)

        if p164.Character then
            task.wait(0.5)

            if p161:IsChamsEnabledForPlayer(p164) then
                v916(p164, p164.Character)
            end
        end
    end
    for _, player in ipairs(t1[2]:GetPlayers()) do
        v917(player)
    end
    local connection = t1[2].PlayerAdded:Connect(v917)
    table.insert(p161.ChamsConnections, connection)
end
t1[23].ToggleChamsSelf = function(p165, p166)
    p165.ChamsSelf.Enabled = p166
    p165:UpdateChams()
end
t1[23].ToggleChamsOthers = function(p167, p168)
    p167.ChamsOthers.Enabled = p168
    p167:UpdateChams()
end
t1[23].ToggleCrosshair = function(p169, p170)
    p169.Crosshair.Enabled = p170

    if p170 then
        if p169.Crosshair.Gui then
            p169.Crosshair.Gui:Destroy()
        end

        local ScreenGui = Instance.new("ScreenGui")

        ScreenGui.Name = "CrosshairGUI"
        ScreenGui.Parent = t1[14]:WaitForChild("PlayerGui")
        ScreenGui.ResetOnSpawn = false

        local Frame = Instance.new("Frame")

        Frame.Size = UDim2.new(0, 8, 0, 8)
        Frame.Position = UDim2.new(0.5, -4, 0.5, -4)
        Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        Frame.BorderSizePixel = 0
        Frame.BackgroundTransparency = 0.3

        local UICorner = Instance.new("UICorner")

        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = Frame
        Frame.Parent = ScreenGui
        p169.Crosshair.Gui = ScreenGui

        return
    end

    if p169.Crosshair.Gui then
        p169.Crosshair.Gui:Destroy()
        p169.Crosshair.Gui = nil
    end
end
t1[23].ToggleAspect43 = function(p171, p172)
    p171.Aspect43.Enabled = p172

    if p172 then
        p171.Aspect43.Connection = t1[4].RenderStepped:Connect(function()
            if not p171.Aspect43.Enabled then
                return
            end

            local CurrentCamera = t1[3].CurrentCamera

            CurrentCamera.CFrame = CurrentCamera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.65, 0, 0, 0, 1)
        end)

        return
    end

    if p171.Aspect43.Connection then
        p171.Aspect43.Connection:Disconnect()
        p171.Aspect43.Connection = nil
    end
end
t1[23].ToggleChinaHat = function(p173, p174)
    p173.ChinaHat.Enabled = p174

    if p174 then
        local function v934()
            if p173.ChinaHat.Part then
                p173.ChinaHat.Part:Destroy()
            end

            if p173.ChinaHat.Conn then
                p173.ChinaHat.Conn:Disconnect()
            end

            local Character = t1[14].Character

            if not Character then
                return
            end

            local Head = Character:FindFirstChild("Head")

            if not Head then
                return
            end

            local Part = Instance.new("Part")

            Part.Name = "ChinaHat"
            Part.Size = Vector3.new(2, 0.25, 2)
            Part.CanCollide = false
            Part.Anchored = false
            Part.Material = Enum.Material.ForceField
            Part.Color = Color3.fromRGB(255, 0, 255)

            local SpecialMesh = Instance.new("SpecialMesh")

            SpecialMesh.MeshId = "rbxassetid://84530303562911"
            SpecialMesh.TextureId = "rbxassetid://89342168321397"
            SpecialMesh.MeshType = Enum.MeshType.FileMesh
            SpecialMesh.Parent = Part

            local Weld = Instance.new("Weld")

            Weld.Part0 = Head
            Weld.Part1 = Part
            Weld.C0 = CFrame.new(0, 0.35, 0)
            Weld.Parent = Part
            p173.ChinaHat.Weld = Weld
            Part.Parent = Character
            p173.ChinaHat.Part = Part

            local n12 = 0

            p173.ChinaHat.Conn = t1[4].RenderStepped:Connect(function()
                local Part2 = p173.ChinaHat.Part

                if Part2 then
                    Part2 = p173.ChinaHat.Part.Parent
                end

                if Part2 then
                    n12 = (n12 + 3) % 360
                    Weld.C0 = CFrame.new(0, 0.35, 0) * CFrame.Angles(0, math.rad(n12), 0)
                end
            end)
        end

        v934()

        if p173.ChinaHat.CharConn then
            p173.ChinaHat.CharConn:Disconnect()
        end

        p173.ChinaHat.CharConn = t1[14].CharacterAdded:Connect(function()
            if p173.ChinaHat.Enabled then
                task.wait(0.2)
                v934()
            end
        end)

        return
    end

    if p173.ChinaHat.Conn then
        p173.ChinaHat.Conn:Disconnect()
        p173.ChinaHat.Conn = nil
    end

    if p173.ChinaHat.Part then
        p173.ChinaHat.Part:Destroy()
        p173.ChinaHat.Part = nil
    end

    if p173.ChinaHat.CharConn then
        p173.ChinaHat.CharConn:Disconnect()
        p173.ChinaHat.CharConn = nil
    end
end
t1[23].ToggleWorldTint = function(p175, p176)
    p175.WorldTint.Enabled = p176

    if p176 then
        if not p175.WorldTint.LightingConn then
            p175.WorldTint.LightingConn = t1[9]:GetPropertyChangedSignal("Brightness"):Connect(function()
                if p175.WorldTint.Enabled then
                    p175:UpdateTint()
                end
            end)
        end

        p175:UpdateTint()

        return
    end

    if p175.WorldTint.LightingConn then
        p175.WorldTint.LightingConn:Disconnect()
        p175.WorldTint.LightingConn = nil
    end

    if p175.WorldTint.CC then
        p175.WorldTint.CC:Destroy()
        p175.WorldTint.CC = nil
    end
end
t1[23].UpdateTint = function(p177)
    if p177.WorldTint.Enabled then
        local v938 = not p177.WorldTint.CC

        if not v938 then
            v938 = p177.WorldTint.CC.Parent ~= t1[9]
        end

        if v938 then
            p177.WorldTint.CC = Instance.new("ColorCorrectionEffect")
            p177.WorldTint.CC.Parent = t1[9]
        end

        p177.WorldTint.CC.Enabled = true

        local v939 = math.min(p177.WorldTint.Red / 255 * p177.WorldTint.Brightness, 1)
        local v940 = math.min(p177.WorldTint.Green / 255 * p177.WorldTint.Brightness, 1)
        local v941 = math.min(p177.WorldTint.Blue / 255 * p177.WorldTint.Brightness, 1)

        p177.WorldTint.CC.TintColor = Color3.new(v939, v940, v941)

        return
    end

    if p177.WorldTint.CC then
        p177.WorldTint.CC:Destroy()
        p177.WorldTint.CC = nil
    end
end
t1[23].SetTintParams = function(p178, p179, p180, p181, p182)
    local WorldTint = p178.WorldTint

    if not p179 then
        p179 = p178.WorldTint.Red
    end

    WorldTint.Red = p179

    local WorldTint2 = p178.WorldTint

    if not p180 then
        p180 = p178.WorldTint.Green
    end

    WorldTint2.Green = p180

    local WorldTint3 = p178.WorldTint

    if not p181 then
        p181 = p178.WorldTint.Blue
    end

    WorldTint3.Blue = p181

    local WorldTint4 = p178.WorldTint

    if not p182 then
        p182 = p178.WorldTint.Brightness
    end

    WorldTint4.Brightness = p182
    p178:UpdateTint()
end
t1[23].ToggleFullbright = function(p183, p184)
    p183.Fullbright.Enabled = p184
end
t1[23].ToggleNoShadow = function(p185, p186)
    p185.NoShadow.Enabled = p186
end
t1[23].StartBackgroundLoops = function(p187)
    task.spawn(function()
        while true do
            if p187.Fullbright.Enabled then
                t1[9].Brightness = 2
                t1[9].ClockTime = 14
                t1[9].Ambient = Color3.fromRGB(255, 255, 255)
            else
                t1[9].Brightness = 1
                t1[9].ClockTime = 12
                t1[9].Ambient = Color3.fromRGB(128, 128, 128)
            end

            if p187.NoShadow.Enabled then
                t1[9].GlobalShadows = false

                for _, descendant in ipairs(t1[9]:GetDescendants()) do
                    if descendant:IsA("Light") then
                        descendant.Shadows = false
                    end
                end
            else
                t1[9].GlobalShadows = true
            end

            task.wait(2)
        end
    end)
end
t1[23].Cleanup = function(p188)
    if p188.Crosshair.Gui then
        p188.Crosshair.Gui:Destroy()
    end
    if p188.Aspect43.Connection then
        p188.Aspect43.Connection:Disconnect()
    end
    if p188.ChinaHat.Conn then
        p188.ChinaHat.Conn:Disconnect()
    end
    if p188.ChinaHat.Part then
        p188.ChinaHat.Part:Destroy()
    end
    if p188.ChinaHat.CharConn then
        p188.ChinaHat.CharConn:Disconnect()
    end
    if p188.WorldTint.CC then
        p188.WorldTint.CC:Destroy()
    end
    if p188.WorldTint.LightingConn then
        p188.WorldTint.LightingConn:Disconnect()
    end
    for v959, v960 in ipairs(p188.ChamsConnections) do

        pcall(v960.Disconnect, v960)
    end
    p188.ChamsConnections = {}
    for _, player in ipairs(t1[2]:GetPlayers()) do
        p188:ApplyChamsToPlayer(player, false)
    end
end
t1[24] = {}
t1[24].__index = t1[24]
t1[24].new = function()
    local self = setmetatable({}, t1[24])
    local TpLobbyEnabled = t1[17].Teleport.TpLobby.Enabled
    local Coords = t1[17].Teleport.TpLobby.Coords

    self.TpLobby = {
		Enabled = TpLobbyEnabled,
		Coords = Coords,
		LastPosition = nil
	}
    self.ExitPoints = t1[17].Teleport.ExitPoints
    self.TPOffset = t1[17].Teleport.TPOffset
    self.Cache = {
		generators = {},
		gates = {},
		hooks = {}
	}
    self:UpdateCache()
    task.spawn(function()
        while true do
            self:UpdateCache()
            task.wait(5)
        end
    end)

    return self
end
t1[24].UpdateCache = function(p189)
    p189.Cache = {
		generators = {},
		gates = {},
		hooks = {}
	}

    local Map = t1[3]:FindFirstChild("Map")

    if not Map then
        return
    end

    local GetDescendants = Map.GetDescendants

    for _, v in ipairs(GetDescendants(Map)) do
        if v:IsA("Model") then
            local BasePart = v:FindFirstChildWhichIsA("BasePart")

            if BasePart then
                if v.Name == "Generator" then
                    table.insert(p189.Cache.generators, {
						model = v,
						part = BasePart
					})
                elseif v.Name == "Gate" then
                    table.insert(p189.Cache.gates, {
						model = v,
						part = BasePart
					})
                elseif v.Name == "Hook" then
                    table.insert(p189.Cache.hooks, {
						model = v,
						part = BasePart
					})
                end
            end
        end
    end
end
t1[24].TeleportToPlayer = function(_, p191)
    for _, player in ipairs(t1[2]:GetPlayers()) do
        if not (p191 == player.Name or p191 == player.DisplayName) then
            continue
        end

        local Character = player.Character
        local Character8 = t1[14].Character

        if Character and Character8 then
            local v978 = t1[16].GetCharacterRoot(Character)
            local v979 = t1[16].GetCharacterRoot(Character8)

            if not (v978 and v979) then
                continue
            end

            v979.CFrame = CFrame.new(v978.Position + Vector3.new(0, 3, 0))

            return true
        end
    end

    return false
end
t1[24].ToggleTpLobby = function(p192, p193)
    p192.TpLobby.Enabled = p193

    if p193 then
        local Character = t1[14].Character

        if Character then
            local v983 = t1[16].GetCharacterRoot(Character)

            if v983 then
                p192.TpLobby.LastPosition = v983.Position
                v983.CFrame = CFrame.new(p192.TpLobby.Coords)
                t1[1]:Notify("Телепорт в лобби", 2)

                return
            end
        end
    elseif p192.TpLobby.LastPosition then
        local Character = t1[14].Character

        if Character then
            local v985 = t1[16].GetCharacterRoot(Character)

            if v985 then
                v985.CFrame = CFrame.new(p192.TpLobby.LastPosition)
                t1[1]:Notify("Возврат на исходную", 2)
            end
        end

        p192.TpLobby.LastPosition = nil
    end
end
t1[24].TeleportToExitPoint = function(p194, p195)
    local v988 = p194.ExitPoints[p195]

    if v988 then
        t1[16].TeleportToPosition(v988)
        t1[16].EnableNoClipTemp(10)

        return true
    end

    return false
end
t1[24].TeleportToNearestGenerator = function(p196)
    local v990 = t1[16].GetCharacterRoot(t1[14].Character)
    local v991 = not v990
    if not v991 then
        v991 = #p196.Cache.generators == 0
    end
    if v991 then
        return
    end
    local t97 = {}
    for v995, v996 in ipairs(p196.Cache.generators) do

        local insert = table.insert
        local Magnitude = (v996.part.Position - v990.Position).Magnitude

        insert(t97, {
			gen = v996,
			dist = Magnitude
		})
    end
    table.sort(t97, function(p197, p198)
        return p197.dist < p198.dist
    end)
    local v999 = t97[1]
    if v999 then
        t1[16].EnableNoClipTemp(1)
        v990.CFrame = v999.gen.part.CFrame + Vector3.new(0, p196.TPOffset, 0)
    end
end
t1[24].TeleportToNearestGate = function(p199)
    local v1001 = t1[16].GetCharacterRoot(t1[14].Character)
    local v1002 = not v1001
    if not v1002 then
        v1002 = #p199.Cache.gates == 0
    end
    if v1002 then
        return
    end
    local n13 = 1e999
    local v1004
    for v1007, v1008 in ipairs(p199.Cache.gates) do

        local Magnitude = (v1008.part.Position - v1001.Position).Magnitude

        if Magnitude < n13 then
            v1004 = v1008
            n13 = Magnitude
        end
    end
    if v1004 then
        t1[16].EnableNoClipTemp(1)
        v1001.CFrame = v1004.part.CFrame + Vector3.new(0, p199.TPOffset, 0)
    end
end
t1[24].TeleportToNearestHook = function(p200)
    local v1011 = t1[16].GetCharacterRoot(t1[14].Character)
    local v1012 = not v1011
    if not v1012 then
        v1012 = #p200.Cache.hooks == 0
    end
    if v1012 then
        return
    end
    local n14 = 1e999
    local v1014
    for v1017, v1018 in ipairs(p200.Cache.hooks) do

        local Magnitude = (v1018.part.Position - v1011.Position).Magnitude

        if Magnitude < n14 then
            v1014 = v1018
            n14 = Magnitude
        end
    end
    if v1014 then
        t1[16].EnableNoClipTemp(1)
        v1011.CFrame = v1014.part.CFrame + Vector3.new(0, p200.TPOffset, 0)
    end
end
t1[24].Cleanup = function(_)
end
t1[25] = {}
t1[25].__index = t1[25]
t1[25].new = function()
    local self = setmetatable({}, t1[25])
    local FlingEnabled = t1[17].Fun.Fling.Enabled
    local Strength = t1[17].Fun.Fling.Strength

    self.Fling = {
		Enabled = FlingEnabled,
		Strength = Strength
	}
    self.AutoFling = {
		Enabled = t1[17].Fun.AutoFling.Enabled,
		Thread = nil
	}

    local AntiFlingEnabled = t1[17].Fun.AntiFling.Enabled
    local vector3 = Vector3.new()

    self.AntiFling = {
		Enabled = AntiFlingEnabled,
		Connection = nil,
		LastVelocity = vector3
	}
    self.BypassGate = {
		Enabled = t1[17].Fun.BypassGate.Enabled
	}
    self.AntiAFK = {
		Enabled = t1[17].Fun.AntiAFK.Enabled,
		Thread = nil
	}
    self.Sahura = {
		Enabled = t1[17].Fun.Sahura.Enabled,
		Model = nil,
		Connection = nil,
		CharConn = nil
	}
    self.HomelanderLoaded = false

    return self
end
t1[25].FlingNearest = function(p202)
    if not p202.Fling.Enabled then
        return
    end
    local v1027 = t1[16].GetCharacterRoot(t1[14].Character)
    if not v1027 then
        return
    end
    local n15 = 1e999
    local v1029
    for v1032, v1033 in ipairs(t1[2]:GetPlayers()) do

        if v1033 ~= t1[14] and v1033.Character then
            local v1034 = t1[16].GetCharacterRoot(v1033.Character)

            if v1034 then
                local Magnitude = (v1034.Position - v1027.Position).Magnitude

                if Magnitude < n15 then
                    n15 = Magnitude
                    v1029 = v1034
                end
            end
        end
    end
    if v1029 then
        local CFrame3 = v1027.CFrame

        for _ = 1, 10 do
            v1027.CFrame = v1029.CFrame
            v1029.AssemblyLinearVelocity = Vector3.new(math.random(-p202.Fling.Strength, p202.Fling.Strength), math.random(1500, 3000), math.random(-p202.Fling.Strength, p202.Fling.Strength))
            task.wait()
        end

        v1027.CFrame = CFrame3
    end
end
t1[25].FlingAll = function(p203)
    if not p203.Fling.Enabled then
        return
    end

    local v1039 = t1[16].GetCharacterRoot(t1[14].Character)

    if not v1039 then
        return
    end

    local CFrame4 = v1039.CFrame

    for _, player in ipairs(t1[2]:GetPlayers()) do
        if player ~= t1[14] and player.Character then
            local v1043 = t1[16].GetCharacterRoot(player.Character)

            if v1043 then
                for _ = 1, 5 do
                    v1039.CFrame = v1043.CFrame
                    v1043.AssemblyLinearVelocity = Vector3.new(math.random(-p203.Fling.Strength, p203.Fling.Strength), math.random(1500, 3000), math.random(-p203.Fling.Strength, p203.Fling.Strength))
                    task.wait()
                end
            end
        end
    end

    v1039.CFrame = CFrame4
end
t1[25].ToggleAutoFling = function(p204, p205)
    p204.AutoFling.Enabled = p205

    if p205 then
        if p204.AutoFling.Thread then
            coroutine.close(p204.AutoFling.Thread)
        end

        p204.AutoFling.Thread = coroutine.create(function()
            while p204.AutoFling.Enabled do
                p204:FlingNearest()
                task.wait(0.5)
            end
        end)
        coroutine.resume(p204.AutoFling.Thread)

        return
    end

    if p204.AutoFling.Thread then
        coroutine.close(p204.AutoFling.Thread)
        p204.AutoFling.Thread = nil
    end
end
t1[25].ToggleAntiFling = function(p206, p207)
    p206.AntiFling.Enabled = p207

    if p207 then
        p206.AntiFling.Connection = t1[4].Stepped:Connect(function()
            local Character = t1[14].Character

            if Character then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

                if HumanoidRootPart then
                    local HumanoidRootPartVelocity = HumanoidRootPart.Velocity

                    if (HumanoidRootPartVelocity - p206.AntiFling.LastVelocity).Magnitude > 100 then
                        HumanoidRootPart.Velocity = p206.AntiFling.LastVelocity

                        return
                    end

                    p206.AntiFling.LastVelocity = HumanoidRootPartVelocity
                end
            end
        end)

        return
    end

    if p206.AntiFling.Connection then
        p206.AntiFling.Connection:Disconnect()
        p206.AntiFling.Connection = nil
    end

    p206.AntiFling.LastVelocity = Vector3.new()
end
t1[25].ToggleBypassGate = function(p208, p209)
    p208.BypassGate.Enabled = p209

    local function v1051()
        local t98 = {}

        for _, descendant in ipairs(t1[3]:GetDescendants()) do
            if descendant.Name == "Gate" and descendant:IsA("Model") then
                t98[#t98 + 1] = descendant
            end
        end

        return t98
    end;

    (function(p210)
        for _, v in pairs(v1051()) do
            local LeftGate = v:FindFirstChild("LeftGate")
            local RightGate = v:FindFirstChild("RightGate")
            local v1601 = v:FindFirstChild("LeftGate-end")
            local v1602 = v:FindFirstChild("RightGate-end")
            local Box = v:FindFirstChild("Box")

            if p210 then
                if LeftGate then
                    LeftGate.Transparency = 1
                    LeftGate.CanCollide = false
                end

                if RightGate then
                    RightGate.Transparency = 1
                    RightGate.CanCollide = false
                end

                if v1601 then
                    v1601.Transparency = 0
                    v1601.CanCollide = true
                end

                if v1602 then
                    v1602.Transparency = 0
                    v1602.CanCollide = true
                end

                if Box then
                    Box.CanCollide = false
                end
            else
                if LeftGate then
                    LeftGate.Transparency = 0
                    LeftGate.CanCollide = true
                end

                if RightGate then
                    RightGate.Transparency = 0
                    RightGate.CanCollide = true
                end

                if v1601 then
                    v1601.Transparency = 1
                    v1601.CanCollide = true
                end

                if v1602 then
                    v1602.Transparency = 1
                    v1602.CanCollide = true
                end

                if Box then
                    Box.CanCollide = true
                end
            end
        end
    end)(p209)
end
t1[25].ToggleAntiAFK = function(p211, p212)
    p211.AntiAFK.Enabled = p212

    if p212 then
        if p211.AntiAFK.Thread then
            task.cancel(p211.AntiAFK.Thread)
        end

        p211.AntiAFK.Thread = task.spawn(function()
            while p211.AntiAFK.Enabled do
                pcall(function()
                    t1[12]:Button2Down(Vector2.new(0, 0), t1[3].CurrentCamera.CFrame)
                    task.wait(math.random(150, 270))
                    t1[12]:Button2Up(Vector2.new(0, 0), t1[3].CurrentCamera.CFrame)
                    task.wait(math.random(150, 270))
                end)
            end
        end)

        return
    end

    if p211.AntiAFK.Thread then
        task.cancel(p211.AntiAFK.Thread)
        p211.AntiAFK.Thread = nil
    end
end
t1[25].ToggleSahura = function(p213, p214)
    p213.Sahura.Enabled = p214

    if p214 then
        local function v1056(p215)
            local HumanoidRootPart = p215:WaitForChild("HumanoidRootPart")
            local Model = Instance.new("Model")

            Model.Name = "SahuraModel"
            Model.Parent = workspace

            local Part = Instance.new("Part")

            Part.Name = "SahuraVisualPart"
            Part.Size = Vector3.new(0.01, 0.01, 0.01)
            Part.Transparency = 0
            Part.CanCollide = false
            Part.CFrame = HumanoidRootPart.CFrame
            Part.Parent = Model

            local SpecialMesh = Instance.new("SpecialMesh")

            SpecialMesh.MeshType = Enum.MeshType.FileMesh
            SpecialMesh.MeshId = "rbxassetid://82464974337955"
            SpecialMesh.TextureId = "rbxassetid://105445253181063"
            SpecialMesh.Scale = Vector3.new(6.5, 6.5, 6.5)
            SpecialMesh.Parent = Part

            local Weld = Instance.new("Weld")

            Weld.Name = "AnimWeld"
            Weld.Part0 = HumanoidRootPart
            Weld.Part1 = Part
            Weld.C0 = CFrame.new(0, 0.4, 0)
            Weld.Parent = Part

            return Model
        end
        local function v1057()
            local v1610 = not p213.Sahura.Enabled

            if not v1610 then
                v1610 = not p213.Sahura.Model
            end

            if v1610 then
                return
            end

            local SahuraVisualPart = p213.Sahura.Model:FindFirstChild("SahuraVisualPart")
            local v1612 = SahuraVisualPart

            if SahuraVisualPart then
                v1612 = SahuraVisualPart:FindFirstChild("AnimWeld")
            end

            local Character = t1[14].Character
            local v1614 = t1[16].GetCharacterRoot(Character)
            local v1615 = not SahuraVisualPart
            local v1616 = t1[16].GetHumanoid(Character)

            if not v1615 then
                v1615 = not v1612

                if not v1615 then
                    v1615 = not v1614 or not v1616
                end
            end

            if v1615 then
                return
            end

            local AssemblyLinearVelocity = v1614.AssemblyLinearVelocity
            local Magnitude = Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude
            local AssemblyLinearVelocityY = AssemblyLinearVelocity.Y
            local timestamp = tick()

            CFrame.new(0, 0.4, 0)

            local v1622

            if v1616.FloorMaterial == Enum.Material.Air then
                local v1621 = math.clamp(AssemblyLinearVelocityY * 0.02, -0.4, 0.4)

                v1622 = CFrame.new(0, 0.4 + v1621 * 0.5, 0) * CFrame.Angles(math.rad(AssemblyLinearVelocityY * -1.5), 0, 0)
            elseif Magnitude > 1 then
                local v1623 = math.sin(timestamp * 14) * 0.15
                local v1624 = math.cos(timestamp * 14) * 0.12
                local v1625 = math.sin(timestamp * 7) * 0.2

                v1622 = CFrame.new(0, math.abs(v1623) + 0.4, 0) * CFrame.Angles(math.rad(Magnitude * 0.6), v1625, v1624)
            else
                local v1626 = math.sin(timestamp * 3) * 0.05

                v1622 = CFrame.new(0, 0.4 + v1626, 0) * CFrame.Angles(math.sin(timestamp * 1.5) * 0.015, 0, 0)
            end

            v1612.C0 = v1612.C0:Lerp(v1622, 0.25)
        end
        local function v1058(p216)
            if not p216 then
                return
            end

            if p213.Sahura.Model then
                p213.Sahura.Model:Destroy()
            end

            if p213.Sahura.Connection then
                p213.Sahura.Connection:Disconnect()
            end

            local GetDescendants = p216.GetDescendants

            for _, v in pairs(GetDescendants(p216)) do
                local v1631 = v:IsA("BasePart")

                if not v1631 then
                    v1631 = v:IsA("Decal")
                end

                if v1631 and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 1
                end
            end

            p213.Sahura.Model = v1056(p216)
            p213.Sahura.Connection = t1[4].RenderStepped:Connect(v1057)
        end

        local Character = t1[14].Character

        if Character then
            v1058(Character)
        end

        if not p213.Sahura.CharConn then
            p213.Sahura.CharConn = t1[14].CharacterAdded:Connect(function(character)
                if p213.Sahura.Enabled then
                    task.wait(0.5)
                    v1058(character)
                end
            end)

            return
        end
    else
        if p213.Sahura.Connection then
            p213.Sahura.Connection:Disconnect()
            p213.Sahura.Connection = nil
        end

        if p213.Sahura.Model then
            p213.Sahura.Model:Destroy()
            p213.Sahura.Model = nil
        end

        if p213.Sahura.CharConn then
            p213.Sahura.CharConn:Disconnect()
            p213.Sahura.CharConn = nil
        end

        local Character = t1[14].Character

        if Character then
            local GetDescendants = Character.GetDescendants

            for _, v in pairs(GetDescendants(Character)) do
                if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 0
                end
            end
        end
    end
end
t1[25].LoadHomelander = function(p217)
    if p217.HomelanderLoaded then
        return
    end

    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Wistexa/homelanderf/refs/heads/main/script"))()
        p217.HomelanderLoaded = true
        t1[1]:Notify("Homelander загружен!", 4)
    end)
end
t1[25].Cleanup = function(p218)
    if p218.AntiFling.Connection then
        p218.AntiFling.Connection:Disconnect()
    end

    if p218.AutoFling.Thread then
        coroutine.close(p218.AutoFling.Thread)
    end

    if p218.AntiAFK.Thread then
        task.cancel(p218.AntiAFK.Thread)
    end

    if p218.Sahura.Connection then
        p218.Sahura.Connection:Disconnect()
    end

    if p218.Sahura.Model then
        p218.Sahura.Model:Destroy()
    end

    if p218.Sahura.CharConn then
        p218.Sahura.CharConn:Disconnect()
    end
end
t1[26] = {}
t1[26].__index = t1[26]
t1[26].new = function()
    local self = setmetatable({}, t1[26])

    self.Binds = {}

    return self
end
t1[26].Register = function(p219, p220, p221, p222, p223)
    local Binds = p219.Binds

    if not p223 then
        p223 = "Press"
    end

    Binds[p220] = {
		Key = p221,
		Callback = p222,
		Mode = p223
	}
end
t1[26].Setup = function(p224)
    t1[5].InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        for _, v in pairs(p224.Binds) do
            if input.KeyCode.Name == v.Key then
                if v.Mode == "Press" then
                    v.Callback()
                elseif v.Mode == "Toggle" then
                    v.Callback()
                end
            end
        end
    end)
end
local t99
do
    local v113, v114, v115, v116

    do
        local v87, v88, v89, v90

        do
            -- Mobile-first window size
            local UIS = game:GetService("UserInputService")
            local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
            local winW, winH = 340, 460
            if isMobile then
                winW, winH = 300, 420
            end
            local v75 = t1[1]:CreateWindow({
				Title = "VD Hub",
				Center = true,
				AutoShow = true,
				TabPadding = 1.2,
				MenuFadeTime = 0.05,
				Size = UDim2.fromOffset(winW, winH)
			})
            local v76 = v75:AddTab("ESP")
            local v77 = v75:AddTab("Выживший")
            local v78 = v75:AddTab("Киллер")
            local v79 = v75:AddTab("Функции")
            local v80 = v75:AddTab("Visual")
            local v81 = v75:AddTab("Teleport")
            local v82 = v75:AddTab("Combat")
            local v83 = v75:AddTab("Fun")
            local v84 = v75:AddTab("UI")

            t99 = {
				ESP = v76,
				Survivor = v77,
				Killer = v78,
				Functions = v79,
				Visual = v80,
				TeleportTroll = v81,
				Combat = v82,
				Fun = v83,
				SettingsUI = v84
			}
            t1[27] = t1[18].new()
            t1[28] = t1[19].new()
            t1[29] = t1[20].new()
            t1[30] = t1[21].new()
            t1[31] = t1[22].new()
            t1[32] = t1[23].new()
            t1[33] = t1[24].new()
            t1[34] = t1[25].new()
            t1[26].new()
            t1[32]:StartBackgroundLoops()

            local v86 = t99.Survivor:AddLeftGroupbox("Защита")

            v87 = t99.Survivor:AddRightGroupbox("Парри")
            v88 = t99.Survivor:AddRightGroupbox("Прочее")
            v89 = t99.Survivor:AddLeftGroupbox("Быстрый ремонт")
            v90 = t99.Survivor:AddLeftGroupbox("Эмоции")

            local Survivor = t1[17].Survivor
            local AddToggle = v86.AddToggle
            local NoSlowdownEnabled = Survivor.NoSlowdown.Enabled

            AddToggle(v86, "NoSlowdownSurvivor_Toggle", {
				Text = "No Slowdown",
				Default = NoSlowdownEnabled,
				Callback = function(p225)
                t1[30]:ToggleNoSlowdown(p225)
            end
			})

            local Survivor2 = t1[17].Survivor
            local AddToggle2 = v86.AddToggle
            local NoFallEnabled = Survivor2.NoFall.Enabled

            AddToggle2(v86, "NoFall_Toggle", {
				Text = "No Fall",
				Default = NoFallEnabled,
				Callback = function(p226)
                t1[30]:ToggleNoFall(p226)
            end
			})

            local NoHitboxEnabled = t1[17].Survivor.NoHitbox.Enabled

            v86:AddToggle("NoHitboxSurvivor_Toggle", {
				Text = "No Hitbox",
				Default = NoHitboxEnabled,
				Callback = function(p227)
                t1[30]:ToggleNoHitbox(p227)
            end
			})

            local AutoParryEnabled = t1[17].Survivor.AutoParry.Enabled

            v87:AddToggle("AutoParry_Toggle", {
				Text = "Авто-парри",
				Default = AutoParryEnabled,
				Callback = function(p228)
                t1[30]:ToggleAutoParry(p228)
            end
			})

            local AutoParryRange = t1[17].Survivor.AutoParry.Range

            v87:AddSlider("AutoParry_Range", {
				Text = "Дальность парри",
				Default = AutoParryRange,
				Min = 0,
				Max = 20,
				Rounding = 1,
				Callback = function(p229)
                t1[30].AutoParry.Range = p229
            end
			})

            local AutoParryV2Enabled = t1[17].Survivor.AutoParryV2.Enabled

            v87:AddToggle("AutoParryV2_Toggle", {
				Text = "Авто-парри V2",
				Default = AutoParryV2Enabled,
				Callback = function(p230)
                t1[30]:ToggleAutoParryV2(p230)
            end
			})

            local AutoParryV2Range = t1[17].Survivor.AutoParryV2.Range

            v87:AddSlider("AutoParryV2_Range", {
				Text = "Дальность V2",
				Default = AutoParryV2Range,
				Min = 0,
				Max = 30,
				Rounding = 1,
				Callback = function(p231)
                t1[30].AutoParryV2.Range = p231
            end
			})
        end

        local Survivor = t1[17].Survivor
        local AddToggle = v87.AddToggle
        local FakeParryEnabled = Survivor.FakeParry.Enabled

        AddToggle(v87, "FakeParry_Toggle", {
			Text = "Фейк-парри",
			Default = FakeParryEnabled,
			Callback = function(p232)
            t1[30]:ToggleFakeParry(p232)
        end
		}):AddKeyPicker("FakeParryKey", {
			Default = "G",
			Mode = "Press",
			SyncToggleState = false,
			Text = "Клавиша фейк-парри",
			NoUI = true
		})

        local AddToggle3 = v88.AddToggle
        local TwistSilentAimEnabled = t1[17].Survivor.TwistSilentAim.Enabled

        AddToggle3(v88, "TwistSilentAim_Toggle", {
			Text = "Twist Silent Aim",
			Default = TwistSilentAimEnabled,
			Callback = function(p233)
            t1[30]:ToggleTwistSilentAim(p233)
        end
		})

        local ParryCircleEnabled = t1[17].Survivor.ParryCircle.Enabled

        v88:AddToggle("ParryCircleVisual_Toggle", {
			Text = "Визуальная дальность парри",
			Default = ParryCircleEnabled,
			Callback = function(p234)
            t1[30]:ToggleParryCircle(p234)
        end
		})

        local AddToggle4 = v88.AddToggle
        local AutoSkillcheckEnabled = t1[17].Survivor.AutoSkillcheck.Enabled

        AddToggle4(v88, "AutoSkillcheck", {
			Text = "Auto Skillcheck",
			Default = AutoSkillcheckEnabled,
			Callback = function(p235)
            t1[30]:ToggleAutoSkillcheck(p235)
        end
		})
        v89:AddToggle("QuickRepair_Toggle", {
			Text = "Выбраться с повеса",
			Default = false,
			Callback = function(_)
        end
		}):AddKeyPicker("QuickRepairKey", {
			Default = "R",
			Mode = "Press",
			SyncToggleState = false,
			Text = "Клавиша ремонта",
			NoUI = true
		})

        local AddToggle5 = v90.AddToggle
        local EmoteWheelEnabled = t1[17].Survivor.EmoteWheel.Enabled

        AddToggle5(v90, "EmoteWheel_Toggle", {
			Text = "Emote Wheel",
			Default = EmoteWheelEnabled,
			Callback = function(p237)
            t1[30]:ToggleEmoteWheel(p237)
        end
		}):AddKeyPicker("EmoteWheelKey", {
			Default = "B",
			Mode = "Press",
			SyncToggleState = false,
			Text = "Клавиша эмоций",
			NoUI = true
		})
        t99.Survivor:AddLeftGroupbox("Cheat"):AddButton("Invisible", function()
        end)

        local v112 = t99.Killer:AddLeftGroupbox("Основное")

        v113 = t99.Killer:AddRightGroupbox("Бой и способности")
        v114 = t99.Killer:AddLeftGroupbox("Утилиты")
        v115 = t99.Killer:AddRightGroupbox("Маски (Masked)")
        v116 = t99.Killer:AddLeftGroupbox("Fun Features")

        local SpearCrosshairEnabled = t1[17].Killer.SpearCrosshair.Enabled

        v112:AddToggle("SpearCrosshair_Toggle", {
			Text = "Прицел для копья",
			Default = SpearCrosshairEnabled,
			Callback = function(p238)
            t1[31]:ToggleSpearCrosshair(p238)
        end
		})

        local NoSlowdownEnabled = t1[17].Killer.NoSlowdown.Enabled

        v112:AddToggle("NoSlowdownKiller_Toggle", {
			Text = "No Slowdown",
			Default = NoSlowdownEnabled,
			Callback = function(p239)
            t1[31]:ToggleNoSlowdown(p239)
        end
		})

        local ThirdPersonEnabled = t1[17].Killer.ThirdPerson.Enabled

        v112:AddToggle("ThirdPersonKiller_Toggle", {
			Text = "Третье лицо",
			Default = ThirdPersonEnabled,
			Callback = function(p240)
            t1[31]:ToggleThirdPerson(p240)
        end
		})

        local AntiBlindEnabled = t1[17].Killer.AntiBlind.Enabled

        v112:AddToggle("AntiBlind_Toggle", {
			Text = "Анти-ослепление",
			Default = AntiBlindEnabled,
			Callback = function(p241)
            t1[31]:ToggleAntiBlind(p241)
        end
		})

        local NoPalletStun = t1[17].Killer.NoPalletStun
        local AddToggle6 = v113.AddToggle
        local NoPalletStunEnabled = NoPalletStun.Enabled

        AddToggle6(v113, "NoPalletStun_Toggle", {
			Text = "Нет оглушения от паллет",
			Default = NoPalletStunEnabled,
			Callback = function(p242)
            t1[31]:ToggleNoPalletStun(p242)
        end
		})

        local AddToggle7 = v113.AddToggle
        local BeatGameEnabled = t1[17].Killer.BeatGame.Enabled

        AddToggle7(v113, "BeatGame_Toggle", {
			Text = "Beat Game",
			Default = BeatGameEnabled,
			Callback = function(p243)
            t1[31]:ToggleBeatGame(p243)
        end
		})

        local AutoAttack = t1[17].Killer.AutoAttack
        local AddToggle8 = v113.AddToggle
        local AutoAttackEnabled = AutoAttack.Enabled

        AddToggle8(v113, "AutoAttack_Toggle", {
			Text = "Auto Attack",
			Default = AutoAttackEnabled,
			Callback = function(p244)
            t1[31]:ToggleAutoAttack(p244)
        end
		})
    end

    local AutoAttackRange = t1[17].Killer.AutoAttack.Range

    v113:AddSlider("AutoAttackRange", {
		Text = "Дальность атаки",
		Default = AutoAttackRange,
		Min = 5,
		Max = 25,
		Rounding = 1,
		Callback = function(p245)
        t1[31].AutoAttack.Range = p245
    end
	})

    local Killer = t1[17].Killer
    local AddToggle = v113.AddToggle
    local AutoHookEnabled = Killer.AutoHook.Enabled

    AddToggle(v113, "AutoHook_Toggle", {
		Text = "Auto Hook",
		Default = AutoHookEnabled,
		Callback = function(p246)
        t1[31]:ToggleAutoHook(p246)
    end
	})

    local UseFakeSawEnabled = t1[17].Killer.UseFakeSaw.Enabled

    v114:AddToggle("UseFakeSaw_Toggle", {
		Text = "Фейковая пила",
		Default = UseFakeSawEnabled,
		Callback = function(p247)
        t1[31]:ToggleUseFakeSaw(p247)
    end
	})

    local AbysswalkerCorrupt = t1[17].Killer.AbysswalkerCorrupt
    local AddToggle9 = v114.AddToggle
    local AbysswalkerCorruptEnabled = AbysswalkerCorrupt.Enabled

    AddToggle9(v114, "AbysswalkerCorrupt_Toggle", {
		Text = "Abysswalker Corrupt",
		Default = AbysswalkerCorruptEnabled,
		Callback = function(p248)
        t1[31]:ToggleAbysswalkerCorrupt(p248)
    end
	})
    v115:AddButton("Alex (бензопила)", function()
        t1[31]:ActivateMaskPower("Alex")
    end)
    v115:AddButton("Tony (кулаки)", function()
        t1[31]:ActivateMaskPower("Tony")
    end)
    v115:AddButton("Brandon (скорость)", function()
        t1[31]:ActivateMaskPower("Brandon")
    end)
    v115:AddButton("Jake (дальний рывок)", function()
        t1[31]:ActivateMaskPower("Jake")
    end)
    v115:AddButton("Richter (невидимость)", function()
        t1[31]:ActivateMaskPower("Richter")
    end)
    v115:AddButton("Graham (быстрые перелезания)", function()
        t1[31]:ActivateMaskPower("Graham")
    end)
    v115:AddButton("Richard (стандартная маска)", function()
        t1[31]:ActivateMaskPower("Richard")
    end)

    local Killer2 = t1[17].Killer
    local AddToggle10 = v116.AddToggle
    local KillAllEnabled = Killer2.KillAll.Enabled

    AddToggle10(v116, "KillAll_Toggle", {
		Text = "Kill All",
		Default = KillAllEnabled,
		Callback = function(p249)
        t1[31]:ToggleKillAll(p249)
    end
	})

    local RemovePalletEnabled = t1[17].Killer.RemovePallet.Enabled

    v116:AddToggle("RemovePallet_Toggle", {
		Text = "Remove Palletwrong",
		Default = RemovePalletEnabled,
		Callback = function(p250)
        t1[31]:ToggleRemovePallet(p250)
    end
	})

    local v141 = t99.ESP:AddLeftGroupbox("Настройки ESP")
    local v142 = t99.ESP:AddRightGroupbox("Объекты ESP")
    local v143 = t99.ESP:AddLeftGroupbox("Цвета")
    local AddToggle11 = v141.AddToggle
    local SurvivorsActive = t1[17].ESP.SurvivorsActive

    AddToggle11(v141, "SurvivorESP", {
		Text = "ESP Выживших",
		Default = SurvivorsActive,
		Callback = function(p251)
        t1[28]:ToggleSurvivor(p251)
    end
	})

    local KillerActive = t1[17].ESP.KillerActive

    v141:AddToggle("KillerESP", {
		Text = "ESP Убийцы",
		Default = KillerActive,
		Callback = function(p252)
        t1[28]:ToggleKiller(p252)
    end
	})

    local TracersActive = t1[17].ESP.TracersActive

    v141:AddToggle("Tracers", {
		Text = "Трейсеры",
		Default = TracersActive,
		Callback = function(p253)
        t1[28]:ToggleTracers(p253)
    end
	})

    local ESP = t1[17].ESP
    local AddToggle12 = v142.AddToggle
    local GenActive = ESP.GenActive

    AddToggle12(v142, "GeneratorESP", {
		Text = "Подсветка генераторов",
		Default = GenActive,
		Callback = function(p254)
        t1[28]:ToggleGen(p254)
    end
	})

    local ESP2 = t1[17].ESP
    local AddToggle13 = v142.AddToggle
    local PalletsActive = ESP2.PalletsActive

    AddToggle13(v142, "PalletESP", {
		Text = "Подсветка паллет",
		Default = PalletsActive,
		Callback = function(p255)
        t1[28]:TogglePallet(p255)
    end
	})

    local GenProgressActive = t1[17].ESP.GenProgressActive

    v142:AddToggle("GenProgress", {
		Text = "Показывать % ремонта генераторов",
		Default = GenProgressActive,
		Callback = function(p256)
        t1[28]:UpdateGenProgress(p256)
    end
	})
    v143:AddLabel("Цвет выживших"):AddColorPicker("SurvivorColorPicker", {
		Default = t1[17].ESP.SurvivorColor,
		Title = "Цвет выживших",
		Callback = function(p257)
        t1[17].ESP.SurvivorColor = p257
        t1[28]:RefreshHighlights()
    end
	})
    v143:AddLabel("Цвет убийцы"):AddColorPicker("KillerColorPicker", {
		Default = t1[17].ESP.KillerColor,
		Title = "Цвет убийцы",
		Callback = function(p258)
        t1[17].ESP.KillerColor = p258
        t1[28]:RefreshHighlights()
    end
	})
    v143:AddLabel("Цвет генераторов"):AddColorPicker("GenColorPicker", {
		Default = t1[17].ESP.GenColor,
		Title = "Цвет генераторов",
		Callback = function(p259)
        t1[17].ESP.GenColor = p259
        t1[28]:UpdateGenESP()
    end
	})
    v143:AddLabel("Цвет паллет"):AddColorPicker("PalletColorPicker", {
		Default = t1[17].ESP.PalletColor,
		Title = "Цвет паллет",
		Callback = function(p260)
        t1[17].ESP.PalletColor = p260
        t1[28]:UpdatePalletESP()
    end
	})
    v143:AddLabel("Цвет процентов"):AddColorPicker("ProgressColorPicker", {
		Default = t1[17].ESP.GenProgressColor,
		Title = "Цвет процентов",
		Callback = function(p261)
        t1[17].ESP.GenProgressColor = p261
        t1[28]:UpdateGenProgress(t1[17].ESP.GenProgressActive)
    end
	})
end
local v228, v229
do
    local v188, v189, v190

    do
        local v155 = t99.Functions:AddLeftGroupbox("Движение")
        local v156 = t99.Functions:AddRightGroupbox("Боевые функции")
        local v157 = t99.Functions:AddRightGroupbox("Утилиты")
        local v158 = t99.Functions:AddLeftGroupbox("Камера")
        local v159 = t99.Functions:AddLeftGroupbox("Модель персонажа")
        local v160 = t99.Functions:AddLeftGroupbox("Дополнительные модели")
        local FlyEnabled = t1[17].Movement.Fly.Enabled

        v155:AddToggle("FlyToggle", {
			Text = "Полёт",
			Default = FlyEnabled,
			Callback = function(p262)
            t1[17].Movement.Fly.Enabled = p262
            t1[27]:ToggleFly(p262)
        end
		})

        local AddSlider = v155.AddSlider
        local FlySpeed = t1[17].Movement.Fly.Speed

        AddSlider(v155, "FlySpeedSlider", {
			Text = "Скорость полёта: %s",
			Default = FlySpeed,
			Min = 20,
			Max = 200,
			Rounding = 1,
			Callback = function(p263)
            t1[17].Movement.Fly.Speed = p263
            t1[27].Fly.Speed = p263
        end
		})

        local NoClipEnabled = t1[17].Movement.NoClip.Enabled

        v155:AddToggle("NoClipToggle", {
			Text = "NoClip",
			Default = NoClipEnabled,
			Callback = function(p264)
            t1[17].Movement.NoClip.Enabled = p264
            t1[27]:ToggleNoClip(p264)
        end
		}):AddKeyPicker("NoClipKey", {
			Default = "V",
			Mode = "Toggle",
			SyncToggleState = true,
			Text = "Клавиша NoClip"
		})

        local Spinbot = t1[17].Movement.Spinbot
        local AddToggle = v155.AddToggle
        local SpinbotEnabled = Spinbot.Enabled

        AddToggle(v155, "SpinbotToggle", {
			Text = "Spinbot",
			Default = SpinbotEnabled,
			Callback = function(p265)
            t1[17].Movement.Spinbot.Enabled = p265
            t1[27]:ToggleSpinbot(p265)
        end
		})

        local SpinbotSpeed = t1[17].Movement.Spinbot.Speed

        v155:AddSlider("SpinbotSpeed", {
			Text = "Скорость вращения: %s",
			Default = SpinbotSpeed,
			Min = 1,
			Max = 50,
			Rounding = 1,
			Callback = function(p266)
            t1[17].Movement.Spinbot.Speed = p266
            t1[27].Spinbot.Speed = p266
        end
		})

        local AddToggle14 = v155.AddToggle
        local SpeedGlitchEnabled = t1[17].Survivor.SpeedGlitch.Enabled

        AddToggle14(v155, "SpeedGlitchToggle", {
			Text = "Speed Glitch",
			Default = SpeedGlitchEnabled,
			Callback = function(p267)
            t1[17].Survivor.SpeedGlitch.Enabled = p267
            t1[27]:ToggleSpeedGlitch(p267)
        end
		})

        local SpeedGlitchValue = t1[17].Survivor.SpeedGlitch.Value

        v155:AddSlider("SpeedGlitchValue", {
			Text = "Скорость Glitch: %s",
			Default = SpeedGlitchValue,
			Min = 16,
			Max = 300,
			Rounding = 1,
			Callback = function(p268)
            t1[17].Survivor.SpeedGlitch.Value = p268
            t1[27].SpeedGlitch.Value = p268
        end
		})

        local AddToggle15 = v155.AddToggle
        local SuperJumpEnabled = t1[17].Survivor.SuperJump.Enabled

        AddToggle15(v155, "SuperJumpToggle", {
			Text = "Super Jump",
			Default = SuperJumpEnabled,
			Callback = function(p269)
            t1[17].Survivor.SuperJump.Enabled = p269
            t1[27]:ToggleSuperJump(p269)
        end
		})

        local Survivor = t1[17].Survivor
        local AddSlider2 = v155.AddSlider
        local Power = Survivor.SuperJump.Power

        AddSlider2(v155, "SuperJumpPower", {
			Text = "Сила прыжка: %s",
			Default = Power,
			Min = 50,
			Max = 500,
			Rounding = 1,
			Callback = function(p270)
            t1[17].Survivor.SuperJump.Power = p270
            t1[27].SuperJump.Power = p270
        end
		})
        v155:AddToggle("MoonwalkToggle", {
			Text = "Auto-Moonwalk",
			Default = false,
			Callback = function(p271)
            t1[27]:ToggleMoonwalk(p271)
        end
		}):AddKeyPicker("MoonwalkKey", {
			Default = "Z",
			Mode = "Toggle",
			SyncToggleState = true,
			Text = "Клавиша Moonwalk"
		})

        local v177 = t1[17]
        local AddToggle16 = v156.AddToggle
        local GodModeEnabled = v177.Movement.GodMode.Enabled

        AddToggle16(v156, "GodModeToggle", {
			Text = "GodMode",
			Default = GodModeEnabled,
			Callback = function(p272)
            t1[17].Movement.GodMode.Enabled = p272
            t1[27]:ToggleGodMode(p272)
        end
		})
        v156:AddButton("Восстановить здоровье", function()
            local Character = t1[14].Character

            if Character then
                local v1123 = t1[16].GetHumanoid(Character)

                if v1123 then
                    v1123.Health = v1123.MaxHealth
                    t1[1]:Notify("Здоровье восстановлено", 2)
                end
            end
        end)

        local TeleportEnabled = t1[17].Movement.Teleport.Enabled

        v157:AddToggle("TeleportToggle", {
			Text = "Телепорт вперед",
			Default = TeleportEnabled,
			Callback = function(p273)
            t1[17].Movement.Teleport.Enabled = p273
            t1[27].Teleport.Enabled = p273
        end
		}):AddKeyPicker("TeleportKey", {
			Default = "T",
			Mode = "Press",
			SyncToggleState = false,
			Text = "Клавиша телепорта"
		})

        local Distance = t1[17].Movement.Teleport.Distance

        v157:AddSlider("TeleportDistance", {
			Text = "Дистанция: %s",
			Default = Distance,
			Min = 10,
			Max = 200,
			Rounding = 1,
			Callback = function(p274)
            t1[17].Movement.Teleport.Distance = p274
            t1[27].Teleport.Distance = p274
        end
		})

        local WalkSpeed = t1[17].Survivor.WalkSpeed

        v157:AddSlider("WalkSpeedSlider", {
			Text = "Скорость бега: %s",
			Default = WalkSpeed,
			Min = 16,
			Max = 500,
			Rounding = 1,
			Callback = function(p275)
            t1[17].Survivor.WalkSpeed = p275
            t1[27]:SetWalkSpeed(p275)
        end
		})

        local VaultSpeed = t1[17].Survivor.VaultSpeed

        v157:AddSlider("VaultSpeedSlider", {
			Text = "Скорость перепрыгивания окон: %s",
			Default = VaultSpeed,
			Min = 1,
			Max = 20,
			Rounding = 1,
			Callback = function(p276)
            t1[17].Survivor.VaultSpeed = p276
            t1[27]:SetVaultSpeed(p276)
        end
		})
        v157:AddButton("Установка всех бустов в 100", function()
            local Character = t1[14].Character

            if Character then
                Character:SetAttribute("repairboost", 100)
                Character:SetAttribute("speedboost", 100)
                Character:SetAttribute("healboost", 100)
                Character:SetAttribute("bleedboost", 100)
                t1[1]:Notify("Все бусты установлены в 100", 2)

                return
            end

            t1[1]:Notify("Персонаж не найден", 3)
        end)

        local v184 = t1[17]
        local AddToggle17 = v158.AddToggle
        local ShiftLockEnabled = v184.ShiftLock.Enabled

        AddToggle17(v158, "ShiftLock_Toggle", {
			Text = "Shift Lock",
			Default = ShiftLockEnabled,
			Callback = function(p277)
            t1[17].ShiftLock.Enabled = p277
        end
		}):AddKeyPicker("ShiftLockKey", {
			Default = "LeftShift",
			Mode = "Toggle",
			SyncToggleState = true,
			Text = "Клавиша Shift Lock"
		})

        local SahuraEnabled = t1[17].Fun.Sahura.Enabled

        v159:AddToggle("Sahura_Toggle", {
			Text = "Tung Tung Sahur",
			Default = SahuraEnabled,
			Callback = function(p278)
            t1[17].Fun.Sahura.Enabled = p278
            t1[34]:ToggleSahura(p278)
        end
		})
        v160:AddButton("Homelander", function()
            t1[34]:LoadHomelander()
        end)
        v188 = t99.Visual:AddLeftGroupbox("Визуальные эффекты")
        v189 = t99.Visual:AddRightGroupbox("Окружение")
        v190 = t99.Visual:AddLeftGroupbox("Прочие визуалы")

        local Crosshair = t1[17].Visual.Crosshair
        local AddToggle18 = v188.AddToggle
        local CrosshairEnabled = Crosshair.Enabled

        AddToggle18(v188, "CrosshairToggle", {
			Text = "Прицел",
			Default = CrosshairEnabled,
			Callback = function(p279)
            t1[17].Visual.Crosshair.Enabled = p279
            t1[32]:ToggleCrosshair(p279)
        end
		})
    end

    local Aspect43Enabled = t1[17].Visual.Aspect43.Enabled

    v188:AddToggle("Aspect43Toggle", {
		Text = "Режим 4:3",
		Default = Aspect43Enabled,
		Callback = function(p280)
        t1[17].Visual.Aspect43.Enabled = p280
        t1[32]:ToggleAspect43(p280)
    end
	})

    local AddToggle = v189.AddToggle
    local FullbrightEnabled = t1[17].Visual.Fullbright.Enabled

    AddToggle(v189, "Fullbright_Toggle", {
		Text = "Fullbright",
		Default = FullbrightEnabled,
		Callback = function(p281)
        t1[17].Visual.Fullbright.Enabled = p281
        t1[32]:ToggleFullbright(p281)
    end
	})

    local AddToggle19 = v189.AddToggle
    local NoShadowEnabled = t1[17].Visual.NoShadow.Enabled

    AddToggle19(v189, "NoShadow_Toggle", {
		Text = "No Shadow",
		Default = NoShadowEnabled,
		Callback = function(p282)
        t1[17].Visual.NoShadow.Enabled = p282
        t1[32]:ToggleNoShadow(p282)
    end
	})

    local AddToggle20 = v190.AddToggle
    local ChinaHatEnabled = t1[17].Visual.ChinaHat.Enabled

    AddToggle20(v190, "ChinaHat_Toggle", {
		Text = "China Hat",
		Default = ChinaHatEnabled,
		Callback = function(p283)
        t1[17].Visual.ChinaHat.Enabled = p283
        t1[32]:ToggleChinaHat(p283)
    end
	})

    local Visual = t1[17].Visual
    local AddToggle21 = v190.AddToggle
    local ChamsSelfEnabled = Visual.ChamsSelf.Enabled

    AddToggle21(v190, "ChamsSelf_Toggle", {
		Text = "Chams свой",
		Default = ChamsSelfEnabled,
		Callback = function(p284)
        t1[17].Visual.ChamsSelf.Enabled = p284
        t1[32]:ToggleChamsSelf(p284)
    end
	})

    local ChamsOthersEnabled = t1[17].Visual.ChamsOthers.Enabled

    v190:AddToggle("ChamsOthers_Toggle", {
		Text = "Chams другие",
		Default = ChamsOthersEnabled,
		Callback = function(p285)
        t1[17].Visual.ChamsOthers.Enabled = p285
        t1[32]:ToggleChamsOthers(p285)
    end
	})

    local WorldTintEnabled = t1[17].Visual.WorldTint.Enabled

    v190:AddToggle("WorldTint_Toggle", {
		Text = "World Tint",
		Default = WorldTintEnabled,
		Callback = function(p286)
        t1[17].Visual.WorldTint.Enabled = p286
        t1[32]:ToggleWorldTint(p286)
    end
	})

    local AddSlider = v190.AddSlider
    local Red = t1[17].Visual.WorldTint.Red

    AddSlider(v190, "TintRed", {
		Text = "Красный",
		Default = Red,
		Min = 0,
		Max = 255,
		Rounding = 0,
		Callback = function(p287)
        t1[17].Visual.WorldTint.Red = p287
        t1[32]:SetTintParams(p287, nil, nil, nil)
    end
	})

    local AddSlider3 = v190.AddSlider
    local Green = t1[17].Visual.WorldTint.Green

    AddSlider3(v190, "TintGreen", {
		Text = "Зелёный",
		Default = Green,
		Min = 0,
		Max = 255,
		Rounding = 0,
		Callback = function(p288)
        t1[17].Visual.WorldTint.Green = p288
        t1[32]:SetTintParams(nil, p288, nil, nil)
    end
	})

    local Blue = t1[17].Visual.WorldTint.Blue

    v190:AddSlider("TintBlue", {
		Text = "Синий",
		Default = Blue,
		Min = 0,
		Max = 255,
		Rounding = 0,
		Callback = function(p289)
        t1[17].Visual.WorldTint.Blue = p289
        t1[32]:SetTintParams(nil, nil, p289, nil)
    end
	})

    local WorldTintBrightness = t1[17].Visual.WorldTint.Brightness

    v190:AddSlider("TintBrightness", {
		Text = "Яркость",
		Default = WorldTintBrightness,
		Min = 0,
		Max = 5,
		Rounding = 1,
		Callback = function(p290)
        t1[17].Visual.WorldTint.Brightness = p290
        t1[32]:SetTintParams(nil, nil, nil, p290)
    end
	})

    local v212 = t99.TeleportTroll:AddLeftGroupbox("Телепорт к игрокам")
    local v213 = t99.TeleportTroll:AddLeftGroupbox("Быстрые телепорты")
    local v214 = t99.TeleportTroll:AddRightGroupbox("Телепорт к объектам")
    local v215 = t99.TeleportTroll:AddRightGroupbox("Троллинг функции")

    t1[35] = v212:AddDropdown("PlayerList", {
		Values = {},
		Default = 1,
		Multi = false,
		Text = "Выберите игрока"
	})
    t1[36] = function()
        local t100 = {}
        for v1146, v1147 in ipairs(t1[2]:GetPlayers()) do

            if v1147 ~= t1[14] then
                table.insert(t100, v1147.Name)
            end
        end
        t1[35]:SetValues(t100)
        if #t100 == 0 then
            t1[35]:SetValues({ "Нет игроков" })
            t1[35]:SetValue(1)
        end
    end
    v212:AddButton("Телепорт к игроку", function()
        local PlayerListValue = getgenv().Options.PlayerList.Value

        if PlayerListValue and PlayerListValue ~= "Нет игроков" then
            t1[33]:TeleportToPlayer(PlayerListValue)

            return
        end

        t1[1]:Notify("Выберите игрока", 2)
    end)
    v212:AddButton("Обновить список", function()
        t1[36]()
        t1[1]:Notify("Список игроков обновлен", 2)
    end)

    local TpLobby = t1[17].Teleport.TpLobby
    local AddToggle22 = v213.AddToggle
    local TpLobbyEnabled = TpLobby.Enabled

    AddToggle22(v213, "TpLobbyToggle", {
		Text = "TP Lobby (с возвратом)",
		Default = TpLobbyEnabled,
		Callback = function(p291)
        t1[17].Teleport.TpLobby.Enabled = p291
        t1[33]:ToggleTpLobby(p291)
    end
	})
    v213:AddDropdown("ExitPointDropdown", {
		Values = {
			"Лобби (исходная)",
			"Замок (выход)",
			"Аутласт (выход)",
			"Клуб",
			"Крыша",
			"Море",
			"Деревня"
		},
		Default = 1,
		Text = "Выберите точку выхода"
	})
    v213:AddButton("Телепорт на выбранную точку", function()
        local ExitPointDropdownValue = getgenv().Options.ExitPointDropdown.Value

        if ExitPointDropdownValue then
            t1[33]:TeleportToExitPoint(ExitPointDropdownValue)
        end
    end)
    v214:AddButton("Teleport to Nearest Generator", function()
        t1[33]:TeleportToNearestGenerator()
    end)
    v214:AddButton("Teleport to Nearest Gate", function()
        t1[33]:TeleportToNearestGate()
    end)
    v214:AddButton("Teleport to Nearest Hook", function()
        t1[33]:TeleportToNearestHook()
    end)

    local TPOffset = t1[17].Teleport.TPOffset

    v214:AddSlider("TP_Offset", {
		Text = "Высота телепортации",
		Default = TPOffset,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Callback = function(p292)
        t1[17].Teleport.TPOffset = p292
        t1[33].TPOffset = p292
    end
	})

    local HeadStalkerEnabled = t1[17].Movement.HeadStalker.Enabled

    v215:AddToggle("HeadStalkerToggle", {
		Text = "HeadStalker",
		Default = HeadStalkerEnabled,
		Callback = function(p293)
        t1[17].Movement.HeadStalker.Enabled = p293
        t1[27]:ToggleHeadStalker(p293)
    end
	})

    local HeightOffset = t1[17].Movement.HeadStalker.HeightOffset

    v215:AddSlider("HeadStalkerHeight", {
		Text = "Высота над головой: %s",
		Default = HeightOffset,
		Min = 1,
		Max = 10,
		Rounding = 1,
		Callback = function(p294)
        t1[17].Movement.HeadStalker.HeightOffset = p294
        t1[27].HeadStalker.HeightOffset = p294
    end
	})

    local BackStalker = t1[17].Movement.BackStalker
    local AddToggle23 = v215.AddToggle
    local BackStalkerEnabled = BackStalker.Enabled

    AddToggle23(v215, "BackStalkerToggle", {
		Text = "BackStalker",
		Default = BackStalkerEnabled,
		Callback = function(p295)
        t1[17].Movement.BackStalker.Enabled = p295
        t1[27]:ToggleBackStalker(p295)
    end
	})

    local AddSlider4 = v215.AddSlider
    local Distance = t1[17].Movement.BackStalker.Distance

    AddSlider4(v215, "BackStalkerDistance", {
		Text = "Дистанция от маньяка: %s",
		Default = Distance,
		Min = 2,
		Max = 10,
		Rounding = 1,
		Callback = function(p296)
        t1[17].Movement.BackStalker.Distance = p296
        t1[27].BackStalker.Distance = p296
    end
	})

    local HeightOffset3 = t1[17].Movement.BackStalker.HeightOffset

    v215:AddSlider("BackStalkerHeight", {
		Text = "Высота от маньяка: %s",
		Default = HeightOffset3,
		Min = 0,
		Max = 5,
		Rounding = 1,
		Callback = function(p297)
        t1[17].Movement.BackStalker.HeightOffset = p297
        t1[27].BackStalker.HeightOffset = p297
    end
	})
    v228 = t99.Combat:AddLeftGroupbox("Aimbot & Combat")
    v229 = t99.Combat:AddRightGroupbox("Visual Combat")

    local AimbotEnabled = t1[17].Combat.Aimbot.Enabled

    v228:AddToggle("AimbotToggle", {
		Text = "Aimbot",
		Default = AimbotEnabled,
		Callback = function(p298)
        t1[17].Combat.Aimbot.Enabled = p298
        t1[29]:ToggleAimbot(p298)
    end
	})

    local Smoothness = t1[17].Combat.Aimbot.Smoothness

    v228:AddSlider("AimbotSmoothness", {
		Text = "Плавность: %s",
		Default = Smoothness,
		Min = 1,
		Max = 50,
		Rounding = 1,
		Callback = function(p299)
        t1[17].Combat.Aimbot.Smoothness = p299
        t1[29].Aimbot.Smoothness = p299
    end
	})
end
local FOV = t1[17].Combat.Aimbot.FOV
v228:AddSlider("AimbotFOV", {
	Text = "FOV: %s",
	Default = FOV,
	Min = 10,
	Max = 300,
	Rounding = 1,
	Callback = function(p300)
    t1[17].Combat.Aimbot.FOV = p300
    t1[29].Aimbot.FOV = p300
end
})
local AddToggle = v228.AddToggle
local TeamCheck = t1[17].Combat.Aimbot.TeamCheck
AddToggle(v228, "AimbotTeamCheck", {
	Text = "Только маньяки",
	Default = TeamCheck,
	Callback = function(p301)
    t1[17].Combat.Aimbot.TeamCheck = p301
    t1[29].Aimbot.TeamCheck = p301
end
})
local AddToggle24 = v228.AddToggle
local VisibleCheck = t1[17].Combat.Aimbot.VisibleCheck
AddToggle24(v228, "AimbotVisibleCheck", {
	Text = "Проверка видимости",
	Default = VisibleCheck,
	Callback = function(p302)
    t1[17].Combat.Aimbot.VisibleCheck = p302
    t1[29].Aimbot.VisibleCheck = p302
end
})
local v237 = t1[17]
local AddToggle25 = v229.AddToggle
local ChamsEnabled = v237.Combat.Chams.Enabled
AddToggle25(v229, "ChamsToggle", {
	Text = "Chams (Highlight)",
	Default = ChamsEnabled,
	Callback = function(p303)
    t1[17].Combat.Chams.Enabled = p303
    t1[29]:ToggleChams(p303)
end
})
v229:AddLabel("Цвет Chams"):AddColorPicker("ChamsColor", {
	Default = t1[17].Combat.Chams.Color,
	Title = "Цвет Chams",
	Callback = function(p304)
    t1[17].Combat.Chams.Color = p304
    t1[29].Chams.Color = p304

    for _, v in pairs(t1[29].Chams.Players) do
        if v then
            v.FillColor = p304
            v.OutlineColor = p304
        end
    end
end
})
local ChamsTransparency = t1[17].Combat.Chams.Transparency
v229:AddSlider("ChamsTransparency", {
	Text = "Прозрачность: %s",
	Default = ChamsTransparency,
	Min = 0,
	Max = 1,
	Rounding = 2,
	Callback = function(p305)
    t1[17].Combat.Chams.Transparency = p305
    t1[29].Chams.Transparency = p305

    for _, v in pairs(t1[29].Chams.Players) do
        if v then
            v.FillTransparency = p305
        end
    end
end
})
local CustomCrosshairsEnabled = t1[17].Combat.CustomCrosshairs.Enabled
v229:AddToggle("CustomCrosshairToggle", {
	Text = "Custom Crosshair",
	Default = CustomCrosshairsEnabled,
	Callback = function(p306)
    t1[17].Combat.CustomCrosshairs.Enabled = p306
    t1[29]:ToggleCrosshair(p306)
end
})
local AddDropdown = v229.AddDropdown
local CustomCrosshairsType = t1[17].Combat.CustomCrosshairs.Type
AddDropdown(v229, "CrosshairType", {
	Values = {
		"Dot",
		"Cross",
		"Circle",
		"Square"
	},
	Default = CustomCrosshairsType,
	Multi = false,
	Text = "Тип прицела",
	Callback = function(p307)
    t1[17].Combat.CustomCrosshairs.Type = p307
    t1[29].Crosshair.Type = p307
    t1[29]:UpdateCrosshair()
end
})
local Combat = t1[17].Combat
local AddSlider = v229.AddSlider
local CustomCrosshairsSize = Combat.CustomCrosshairs.Size
AddSlider(v229, "CrosshairSize", {
	Text = "Размер: %s",
	Default = CustomCrosshairsSize,
	Min = 4,
	Max = 20,
	Rounding = 1,
	Callback = function(p308)
    t1[17].Combat.CustomCrosshairs.Size = p308
    t1[29].Crosshair.Size = p308
    t1[29]:UpdateCrosshair()
end
})
v229:AddLabel("Цвет прицела"):AddColorPicker("CrosshairColor", {
	Default = t1[17].Combat.CustomCrosshairs.Color,
	Title = "Цвет прицела",
	Callback = function(p309)
    t1[17].Combat.CustomCrosshairs.Color = p309
    t1[29].Crosshair.Color = p309
    t1[29]:UpdateCrosshair()
end
})
local Outline = t1[17].Combat.CustomCrosshairs.Outline
v229:AddToggle("CrosshairOutline", {
	Text = "Обводка",
	Default = Outline,
	Callback = function(p310)
    t1[17].Combat.CustomCrosshairs.Outline = p310
    t1[29].Crosshair.Outline = p310
    t1[29]:UpdateCrosshair()
end
})
v229:AddLabel("Цвет обводки"):AddColorPicker("CrosshairOutlineColor", {
	Default = t1[17].Combat.CustomCrosshairs.OutlineColor,
	Title = "Цвет обводки",
	Callback = function(p311)
    t1[17].Combat.CustomCrosshairs.OutlineColor = p311
    t1[29].Crosshair.OutlineColor = p311
    t1[29]:UpdateCrosshair()
end
})
local Gap = t1[17].Combat.CustomCrosshairs.Gap
v229:AddSlider("CrosshairGap", {
	Text = "Зазор: %s",
	Default = Gap,
	Min = 0,
	Max = 10,
	Rounding = 1,
	Callback = function(p312)
    t1[17].Combat.CustomCrosshairs.Gap = p312
    t1[29].Crosshair.Gap = p312
    t1[29]:UpdateCrosshair()
end
})
local CustomCrosshairsThickness = t1[17].Combat.CustomCrosshairs.Thickness
v229:AddSlider("CrosshairThickness", {
	Text = "Толщина: %s",
	Default = CustomCrosshairsThickness,
	Min = 1,
	Max = 5,
	Rounding = 1,
	Callback = function(p313)
    t1[17].Combat.CustomCrosshairs.Thickness = p313
    t1[29].Crosshair.Thickness = p313
    t1[29]:UpdateCrosshair()
end
})
v229:AddButton("Сбросить настройки", function()
    t1[17].Combat.Aimbot.Enabled = false
    t1[17].Combat.Chams.Enabled = false
    t1[17].Combat.CustomCrosshairs.Enabled = false
    t1[29]:ToggleAimbot(false)
    t1[29]:ToggleChams(false)
    t1[29]:ToggleCrosshair(false)
    t1[1]:Notify("Все боевые настройки сброшены", 3)
end)

local v250 = t99.Fun:AddLeftGroupbox("Основные функции")
local v251 = t99.Fun:AddLeftGroupbox("Флинг и защита")
local v252 = t99.Fun:AddRightGroupbox("Разное")
local v253 = t99.Fun:AddLeftGroupbox("Bypass")
local v254 = t99.Fun:AddRightGroupbox("Anti AFK")
local KillAura = t1[17].Fun.KillAura
local AddToggle26 = v250.AddToggle
local KillAuraEnabled = KillAura.Enabled
AddToggle26(v250, "KillAuraToggle", {
	Text = "Kill Aura",
	Default = KillAuraEnabled,
	Callback = function(p314)
    t1[17].Fun.KillAura.Enabled = p314
    t1[29]:ToggleKillAura(p314)
end
})
local v258 = t1[17]
local AddToggle27 = v250.AddToggle
local AntiFlingEnabled = v258.Fun.AntiFling.Enabled
AddToggle27(v250, "AntiFlingToggle", {
	Text = "Анти-флинг (защита)",
	Default = AntiFlingEnabled,
	Callback = function(p315)
    t1[17].Fun.AntiFling.Enabled = p315
    t1[34]:ToggleAntiFling(p315)
end
})
v251:AddButton("Fling Nearest Player", function()
    t1[34]:FlingNearest()
end)
v251:AddButton("Fling All", function()
    t1[34]:FlingAll()
end)

local FlingEnabled = t1[17].Fun.Fling.Enabled
v251:AddToggle("Fling_Toggle", {
	Text = "Включить флинг (для кнопок)",
	Default = FlingEnabled,
	Callback = function(p316)
    t1[17].Fun.Fling.Enabled = p316
    t1[34].Fling.Enabled = p316
end
})
local Strength = t1[17].Fun.Fling.Strength
v251:AddSlider("FlingStrength", {
	Text = "Сила флинга",
	Default = Strength,
	Min = 1000,
	Max = 50000,
	Rounding = 100,
	Callback = function(p317)
    t1[17].Fun.Fling.Strength = p317
    t1[34].Fling.Strength = p317
end
})
local Fun = t1[17].Fun
local AddToggle28 = v251.AddToggle
local AutoFlingEnabled = Fun.AutoFling.Enabled
AddToggle28(v251, "AutoFling_Toggle", {
	Text = "Auto Fling (авто-кидание)",
	Default = AutoFlingEnabled,
	Callback = function(p318)
    t1[17].Fun.AutoFling.Enabled = p318
    t1[34]:ToggleAutoFling(p318)
end
})
v252:AddButton("Rejoin Game (перезаход)", function()
    t1[10]:TeleportToPlaceInstance(game.PlaceId, game.JobId, t1[14])
end)
v252:AddButton("Suicide (убиться)", function()
    local v1182 = t1[16].GetHumanoid(t1[14].Character)

    if v1182 then
        v1182.Health = 0
    end
end)
v252:AddButton("Дрочка", function()
    pcall(function()
    end)
    t1[1]:Notify("Скрипт \"Дрочка\" загружен", 2)
end)

local BypassGateEnabled = t1[17].Fun.BypassGate.Enabled
v253:AddToggle("BypassGateToggle", {
	Text = "Bypass Gate (Open Gate)",
	Default = BypassGateEnabled,
	Callback = function(p319)
    t1[17].Fun.BypassGate.Enabled = p319
    t1[34]:ToggleBypassGate(p319)
end
})
local AntiAFK = t1[17].Fun.AntiAFK
local AddToggle29 = v254.AddToggle
local AntiAFKEnabled = AntiAFK.Enabled
AddToggle29(v254, "AntiAFK_Toggle", {
	Text = "Anti AFK",
	Default = AntiAFKEnabled,
	Callback = function(p320)
    t1[17].Fun.AntiAFK.Enabled = p320
    t1[34]:ToggleAntiAFK(p320)
end
})
local v270 = t99.SettingsUI:AddLeftGroupbox("Меню")

v270:AddButton("Выгрузить", function()
    t1[1]:Unload()
end)
v270:AddLabel("Клавиша меню"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Клавиша меню"
})
t1[1].ToggleKeybind = getgenv().Options.MenuKeybind
v3:SetLibrary(t1[1])
v4:SetLibrary(t1[1])
v4:IgnoreThemeSettings()
v4:SetIgnoreIndexes({ "MenuKeybind" })
v3:SetFolder("Swaga")
v4:SetFolder("Swagas/config")
v4:BuildConfigSection(t99.SettingsUI)
v3:ApplyToTab(t99.SettingsUI)
t1[1]:SetWatermark("VD Hub")
t1[1].KeybindFrame.Visible = true
t1[4].RenderStepped:Connect(function()
    if not t1[17].ShiftLock.Enabled then
        return
    end

    local Character = t1[14].Character

    if not Character then
        return
    end

    local v1186 = t1[16].GetCharacterRoot(Character)
    local CurrentCamera = t1[3].CurrentCamera

    if v1186 and CurrentCamera then
        local LookVector = CurrentCamera.CFrame.LookVector
        local Unit = Vector3.new(LookVector.X, 0, LookVector.Z).Unit

        v1186.CFrame = CFrame.new(v1186.Position, v1186.Position + Unit)
    end
end)
t1[5].InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    local Options2 = getgenv().Options

    if not Options2 then
        return
    end

    local TeleportKey = Options2.TeleportKey

    if TeleportKey then
        TeleportKey = Options2.TeleportKey.Value
    end

    if TeleportKey then
        TeleportKey = TeleportKey == input.KeyCode.Name

        if TeleportKey then
            TeleportKey = t1[17].Movement.Teleport.Enabled
        end
    end

    if TeleportKey then
        t1[27]:TeleportForward()
    end

    local FakeParryKey = Options2.FakeParryKey

    if FakeParryKey then
        FakeParryKey = Options2.FakeParryKey.Value
    end

    if FakeParryKey then
        FakeParryKey = FakeParryKey == input.KeyCode.Name
    end

    if FakeParryKey then
        if not t1[17].Survivor.FakeParry.Enabled then
            t1[30]:ToggleFakeParry(true)
            task.delay(1, function()
                t1[30]:ToggleFakeParry(false)
            end)
        else
            t1[30]:ToggleFakeParry(false)
            t1[30]:ToggleFakeParry(true)
            task.delay(1, function()
                if not t1[17].Survivor.FakeParry.Enabled then
                    t1[30]:ToggleFakeParry(false)
                end
            end)
        end
    end

    local QuickRepairKey = Options2.QuickRepairKey

    if QuickRepairKey then
        QuickRepairKey = Options2.QuickRepairKey.Value
    end

    if QuickRepairKey then
        QuickRepairKey = QuickRepairKey == input.KeyCode.Name
    end

    if QuickRepairKey then
        t1[30]:ExecuteQuickRepair()
    end

    local EmoteWheelKey = Options2.EmoteWheelKey

    if EmoteWheelKey then
        EmoteWheelKey = Options2.EmoteWheelKey.Value
    end

    if EmoteWheelKey then
        EmoteWheelKey = EmoteWheelKey == input.KeyCode.Name

        if EmoteWheelKey then
            EmoteWheelKey = t1[30].EmoteWheel.Enabled
        end
    end

    if EmoteWheelKey then
        t1[30]:ToggleEmoteMenu()
    end
end)
task.spawn(function()
    local Map = t1[3]:FindFirstChild("Map")

    if not Map then
        Map = t1[3]:FindFirstChild("GameMap")

        if not Map then
            Map = t1[3]:FindFirstChild("Arena")
        end
    end

    if not Map then
        if not t1[3]:FindFirstChild("Map") and not t1[3]:FindFirstChild("GameMap") then
            t1[3]:FindFirstChild("Arena")
        end

        repeat
            task.wait(1)

            local Map2 = t1[3]:FindFirstChild("Map")

            if not Map2 then
                Map2 = t1[3]:FindFirstChild("GameMap")

                if not Map2 then
                    Map2 = t1[3]:FindFirstChild("Arena")
                end
            end
        until Map2
    end

    t1[1]:Notify("Карта загружена", 3)
end)
t1[36]()
v4:LoadAutoloadConfig()
t1[1]:Notify("SWAGA загружен!", 8)
t1[1].OnUnload = function()
    t1[27]:Cleanup()
    t1[28]:Cleanup()
    t1[29]:Cleanup()
    t1[30]:Cleanup()
    t1[31]:Cleanup()
    t1[32]:Cleanup()
    t1[33]:Cleanup()
    t1[34]:Cleanup()
end
getgenv().Options = Options
getgenv().Toggles = Toggles
