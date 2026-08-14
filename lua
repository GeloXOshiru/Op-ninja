-- =============================================
--   JELO WARFREAK — UNIVERSAL UTILITY SUITE
--   Works on ANY Roblox Game
--   Anti-AFK • Infinite Jump • No-Clip
--   Player ESP • Speed Control (1–300)
--   Foldable Panel • World-Class Design
-- =============================================

local Services = {
    Players = game:GetService("Players"),
    VirtualUser = game:GetService("VirtualUser"),
    StarterGui = game:GetService("StarterGui"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace")
}

local LocalPlayer = Services.Players.LocalPlayer

-- =============================================
-- STATE MANAGEMENT
-- =============================================
local STATE = {
    Toggles = {
        AntiAFK = false,
        InfiniteJump = false,
        NoClip = false,
        ESP = false,
        Speed = false
    },
    Connections = {
        InfiniteJump = nil,
        NoClip = nil,
        ESP = nil
    },
    Cache = {
        OriginalCanCollide = {},
        OriginalMaterials = {},
        OriginalSpeed = 16
    },
    Uptime = 0,
    Folded = false,
    SpeedValue = 16
}

-- =============================================
-- NOTIFICATION
-- =============================================
local function Notify(title, msg, dur)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = msg,
            Duration = dur or 3
        })
    end)
end

-- =============================================
-- ANTI-AFK — UNIVERSAL
-- =============================================
local AntiAFKConn = nil
local function EnableAntiAFK()
    AntiAFKConn = LocalPlayer.Idled:Connect(function()
        pcall(function()
            Services.VirtualUser:CaptureController()
            Services.VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end
local function DisableAntiAFK()
    if AntiAFKConn then AntiAFKConn:Disconnect() AntiAFKConn = nil end
end

task.spawn(function()
    while task.wait(240) do
        if STATE.Toggles.AntiAFK then
            pcall(function()
                Services.VirtualUser:CaptureController()
                Services.VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- =============================================
-- INFINITE JUMP — UNIVERSAL
-- =============================================
local function UpdateInfiniteJump()
    if STATE.Connections.InfiniteJump then
        STATE.Connections.InfiniteJump:Disconnect()
        STATE.Connections.InfiniteJump = nil
    end

    if STATE.Toggles.InfiniteJump then
        STATE.Connections.InfiniteJump = Services.UserInputService.JumpRequest:Connect(function()
            if not STATE.Toggles.InfiniteJump then return end
            local Char = LocalPlayer.Character
            if Char and Char:FindFirstChild("Humanoid") then
                Char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        Notify("Infinite Jump", "Enabled", 3)
    else
        Notify("Infinite Jump", "Disabled", 3)
    end
end

-- =============================================
-- NO-CLIP — UNIVERSAL
-- =============================================
local function UpdateNoClip()
    if STATE.Connections.NoClip then
        STATE.Connections.NoClip:Disconnect()
        STATE.Connections.NoClip = nil
    end
    STATE.Cache.OriginalCanCollide = {}

    if STATE.Toggles.NoClip then
        STATE.Connections.NoClip = Services.RunService.Stepped:Connect(function()
            if not STATE.Toggles.NoClip then return end
            local Char = LocalPlayer.Character
            if Char then
                for _, Part in ipairs(Char:GetChildren()) do
                    if Part:IsA("BasePart") then
                        if STATE.Cache.OriginalCanCollide[Part] == nil then
                            STATE.Cache.OriginalCanCollide[Part] = Part.CanCollide
                        end
                        Part.CanCollide = false
                    end
                end
            end
        end)
        Notify("No-Clip", "Enabled", 3)
    else
        task.wait(0.1)
        local Char = LocalPlayer.Character
        if Char then
            for _, Part in ipairs(Char:GetChildren()) do
                if Part:IsA("BasePart") and STATE.Cache.OriginalCanCollide[Part] ~= nil then
                    Part.CanCollide = STATE.Cache.OriginalCanCollide[Part]
                end
            end
        end
        STATE.Cache.OriginalCanCollide = {}
        Notify("No-Clip", "Disabled", 3)
    end
end

-- =============================================
-- PLAYER ESP — SEE THROUGH WALLS (RED)
-- =============================================
local function RestorePlayerAppearance(Player)
    local Char = Player.Character
    if Char then
        for _, Part in ipairs(Char:GetChildren()) do
            if Part:IsA("BasePart") and STATE.Cache.OriginalMaterials[Part] then
                Part.Material = STATE.Cache.OriginalMaterials[Part].Material
                Part.BrickColor = STATE.Cache.OriginalMaterials[Part].BrickColor
                Part.Transparency = STATE.Cache.OriginalMaterials[Part].Transparency
            end
        end
    end
end

local function UpdateESP()
    if STATE.Connections.ESP then
        STATE.Connections.ESP:Disconnect()
        STATE.Connections.ESP = nil
    end
    STATE.Cache.OriginalMaterials = {}

    if STATE.Toggles.ESP then
        STATE.Connections.ESP = Services.RunService.RenderStepped:Connect(function()
            if not STATE.Toggles.ESP then return end
            for _, Player in ipairs(Services.Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character then
                    local Char = Player.Character
                    local Humanoid = Char:FindFirstChild("Humanoid")
                    if Humanoid and Humanoid.Health > 0 then
                        for _, Part in ipairs(Char:GetChildren()) do
                            if Part:IsA("BasePart") then
                                if not STATE.Cache.OriginalMaterials[Part] then
                                    STATE.Cache.OriginalMaterials[Part] = {
                                        Material = Part.Material,
                                        BrickColor = Part.BrickColor,
                                        Transparency = Part.Transparency
                                    }
                                end
                                Part.Material = Enum.Material.Neon
                                Part.BrickColor = BrickColor.new("Really red")
                                Part.Transparency = 0
                            end
                        end
                    end
                end
            end
        end)
        Notify("Player ESP", "See everyone in RED!", 3)
    else
        for _, Player in ipairs(Services.Players:GetPlayers()) do
            task.spawn(function() RestorePlayerAppearance(Player) end)
        end
        STATE.Cache.OriginalMaterials = {}
        Notify("Player ESP", "Disabled", 3)
    end
end

-- =============================================
-- SPEED CONTROL — 1 TO 300 (UNIVERSAL)
-- =============================================
task.spawn(function()
    while task.wait(0.3) do
        local Char = LocalPlayer.Character
        if Char and Char:FindFirstChild("Humanoid") then
            STATE.Cache.OriginalSpeed = STATE.Cache.OriginalSpeed or Char.Humanoid.WalkSpeed
            if STATE.Toggles.Speed then
                Char.Humanoid.WalkSpeed = STATE.SpeedValue
            else
                Char.Humanoid.WalkSpeed = STATE.Cache.OriginalSpeed
            end
        end
    end
end)

-- =============================================
-- UI — FOLDABLE PANEL
-- =============================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "JeloWarfreakHub"
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
Main.Position = UDim2.new(0.02, 0, 0.02, 0)
Main.Size = UDim2.new(0, 240, 0, 300)
Main.Active = true
Main.Draggable = true
Main.Parent = Gui

-- Style
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2.5
Stroke.Color = Color3.fromRGB(0, 255, 140)
Stroke.Transparency = 0.08

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.BackgroundTransparency = 1
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 8)
Title.Size = UDim2.new(1, -50, 0, 32)
Title.Font = Enum.Font.GothamBold
Title.Text = "JELO WARFREAK"
Title.TextColor3 = Color3.fromRGB(0, 255, 140)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Fold Button
local FoldBtn = Instance.new("TextButton")
FoldBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
FoldBtn.Position = UDim2.new(1, -40, 0, 8)
FoldBtn.Size = UDim2.new(0, 28, 0, 28)
FoldBtn.Font = Enum.Font.GothamBold
FoldBtn.Text = "−"
FoldBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
FoldBtn.TextSize = 14
Instance.new("UICorner", FoldBtn).CornerRadius = UDim.new(0, 8)
FoldBtn.Parent = TitleBar

-- Content Area
local Content = Instance.new("Frame")
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 48)
Content.Size = UDim2.new(1, 0, 0, 252)
Content.Parent = Main

-- Timer
local Timer = Instance.new("TextLabel")
Timer.BackgroundTransparency = 1
Timer.Position = UDim2.new(0, 0, 0, 4)
Timer.Size = UDim2.new(1, 0, 0, 32)
Timer.Font = Enum.Font.GothamBold
Timer.Text = "00:00:00"
Timer.TextColor3 = Color3.fromRGB(255, 255, 255)
Timer.TextSize = 22
Timer.Parent = Content

task.spawn(function()
    while task.wait(1) do
        STATE.Uptime += 1
        local H = math.floor(STATE.Uptime / 3600)
        local M = math.floor((STATE.Uptime % 3600) / 60)
        local S = STATE.Uptime % 60
        Timer.Text = string.format("%02d:%02d:%02d", H, M, S)
    end
end)

-- Button Template
local function MakeButton(Name, PosY, Callback)
    local Btn = Instance.new("TextButton")
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Btn.Position = UDim2.new(0, 12, 0, PosY)
    Btn.Size = UDim2.new(1, -24, 0, 34)
    Btn.Font = Enum.Font.Gotham
    Btn.Text = Name .. " — OFFLINE"
    Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.Parent = Content
    Btn.MouseButton1Click:Connect(function() Callback(Btn) end)
    return Btn
end

-- Buttons
MakeButton("ANTI-AFK", 46, function(Btn)
    STATE.Toggles.AntiAFK = not STATE.Toggles.AntiAFK
    if STATE.Toggles.AntiAFK then
        Btn.Text = "ANTI-AFK — ACTIVE"
        Btn.BackgroundColor3 = Color3.fromRGB(15, 130, 60)
        EnableAntiAFK()
        Notify("Anti-AFK", "Enabled", 2)
    else
        Btn.Text = "ANTI-AFK — OFFLINE"
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        DisableAntiAFK()
        Notify("Anti-AFK", "Disabled", 2)
    end
end)

MakeButton("INFINITE JUMP", 86, function(Btn)
    STATE.Toggles.InfiniteJump = not STATE.Toggles.InfiniteJump
    if STATE.Toggles.InfiniteJump then
        Btn.Text = "INFINITE JUMP — ACTIVE"
        Btn.BackgroundColor3 = Color3.fromRGB(15, 130, 60)
    else
        Btn.Text = "INFINITE JUMP — OFFLINE"
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    end
    UpdateInfiniteJump()
end)

MakeButton("NO-CLIP", 126, function(Btn)
    STATE.Toggles.NoClip = not STATE.Toggles.NoClip
    if STATE.Toggles.NoClip then
        Btn.Text = "NO-CLIP — ACTIVE"
        Btn.BackgroundColor3 = Color3.fromRGB(15, 130, 60)
    else
        Btn.Text = "NO-CLIP — OFFLINE"
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    end
    UpdateNoClip()
end)

MakeButton("PLAYER ESP", 166, function(Btn)
    STATE.Toggles.ESP = not STATE.Toggles.ESP
    if STATE.Toggles.ESP then
        Btn.Text = "PLAYER ESP — ACTIVE"
        Btn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
    else
        Btn.Text = "PLAYER ESP — OFFLINE"
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    end
    UpdateESP()
end)

-- Speed Button
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SpeedBtn.Position = UDim2.new(0, 12, 0, 206)
SpeedBtn.Size = UDim2.new(1, -24, 0, 34)
SpeedBtn.Font = Enum.Font.Gotham
SpeedBtn.Text = "SPEED — OFFLINE [16]"
SpeedBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
SpeedBtn.TextSize = 12
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 8)
SpeedBtn.Parent = Content

SpeedBtn.MouseButton1Click:Connect(function()
    STATE.Toggles.Speed = not STATE.Toggles.Speed
    if STATE.Toggles.Speed then
        SpeedBtn.Text = "SPEED — ACTIVE [" .. STATE.SpeedValue .. "]"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(15, 130, 60)
        Notify("Speed", "Set to " .. STATE.SpeedValue, 2)
    else
        SpeedBtn.Text = "SPEED — OFFLINE [" .. STATE.SpeedValue .. "]"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        Notify("Speed", "Restored", 2)
    end
end)

-- Speed Input Box
local SpeedBox = Instance.new("TextBox")
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SpeedBox.Position = UDim2.new(0, 12, 0, 246)
SpeedBox.Size = UDim2.new(1, -24, 0, 28)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.Text = "16"
SpeedBox.PlaceholderText = "Speed: 1–300"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 11
SpeedBox.ClearTextOnFocus = true
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 8)
SpeedBox.Parent = Content

SpeedBox.FocusLost:Connect(function(EnterPressed)
    local Val = tonumber(SpeedBox.Text)
    if Val then
        Val = math.clamp(Val, 1, 300)
        STATE.SpeedValue = Val
        SpeedBox.Text = tostring(Val)
        SpeedBtn.Text = STATE.Toggles.Speed and "SPEED — ACTIVE [" .. Val .. "]" or "SPEED — OFFLINE [" .. Val .. "]"
        Notify("Speed", "Set: " .. Val, 2)
    end
end)

-- Fold / Unfold
local OriginalHeight = 300
local FoldedHeight = 48

FoldBtn.MouseButton1Click:Connect(function()
    STATE.Folded = not STATE.Folded
    if STATE.Folded then
        Main.Size = UDim2.new(0, 240, 0, FoldedHeight)
        Content.Visible = false
        FoldBtn.Text = "+"
    else
        Main.Size = UDim2.new(0, 240, 0, OriginalHeight)
        Content.Visible = true
        FoldBtn.Text = "−"
    end
end)

print("==========================================")
print("  JELO WARFREAK — UNIVERSAL SUITE")
print("  Works on ANY Roblox Game")
print("==========================================")
Notify("Jelo Warfreak", "Universal Suite Loaded!", 4)
