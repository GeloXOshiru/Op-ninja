-- =============================================
--   JELO WARFREAK — PREMIUM UTILITY SUITE
--   Anti-AFK • Infinite Jump • No-Clip
--   PLAYER ESP • SPEED CONTROL (1–300)
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
    Cache = {OriginalCanCollide = {}, OriginalMaterials = {}, OriginalSpeed = 16},
    Uptime = 0,
    Folded = false,
    SpeedValue = 16 -- Default na bilis
}

-- =============================================
-- NOTIFICATION
-- =============================================
local function Notify(title, msg, dur)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {Title=title, Text=msg, Duration=dur or 3})
    end)
end

-- =============================================
-- ANTI-AFK
-- =============================================
local AntiAFKConn = nil
local function EnableAntiAFK()
    AntiAFKConn = LocalPlayer.Idled:Connect(function()
        pcall(function() Services.VirtualUser:CaptureController() Services.VirtualUser:ClickButton2(Vector2.new()) end)
    end)
end
local function DisableAntiAFK() if AntiAFKConn then AntiAFKConn:Disconnect() AntiAFKConn=nil end end
task.spawn(function() while task.wait(240) do if STATE.Toggles.AntiAFK then pcall(function() Services.VirtualUser:CaptureController() Services.VirtualUser:ClickButton2(Vector2.new()) end) end end end)

-- =============================================
-- INFINITE JUMP
-- =============================================
local function UpdateInfiniteJump()
    if STATE.Toggles.InfiniteJump then
        if STATE.Connections.InfiniteJump then STATE.Connections.InfiniteJump:Disconnect() end
        STATE.Connections.InfiniteJump = Services.UserInputService.JumpRequest:Connect(function()
            if not STATE.Toggles.InfiniteJump then STATE.Connections.InfiniteJump:Disconnect(); return end
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
        Notify("Infinite Jump","Enabled",3)
    else
        if STATE.Connections.InfiniteJump then STATE.Connections.InfiniteJump:Disconnect() end
        Notify("Infinite Jump","Disabled",3)
    end
end

-- =============================================
-- NO-CLIP
-- =============================================
local function UpdateNoClip()
    if STATE.Toggles.NoClip then
        STATE.Cache.OriginalCanCollide = {}
        if STATE.Connections.NoClip then STATE.Connections.NoClip:Disconnect() end
        STATE.Connections.NoClip = Services.RunService.Stepped:Connect(function()
            if not STATE.Toggles.NoClip then STATE.Connections.NoClip:Disconnect(); return end
            local c = LocalPlayer.Character
            if c then for _,p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then if STATE.Cache.OriginalCanCollide[p]==nil then STATE.Cache.OriginalCanCollide[p]=p.CanCollide end p.CanCollide=false end end end
        end)
        Notify("No-Clip","Enabled",3)
    else
        if STATE.Connections.NoClip then STATE.Connections.NoClip:Disconnect() end
        local c=LocalPlayer.Character
        if c then for _,p in ipairs(c:GetChildren()) do if p:IsA("BasePart") and STATE.Cache.OriginalCanCollide[p]~=nil then p.CanCollide=STATE.Cache.OriginalCanCollide[p] end end end
        STATE.Cache.OriginalCanCollide={}
        Notify("No-Clip","Disabled",3)
    end
end

-- =============================================
-- PLAYER ESP — SEE THROUGH WALLS (RED)
-- =============================================
local function RestorePlayerAppearance(player)
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and STATE.Cache.OriginalMaterials[part] then
                part.Material = STATE.Cache.OriginalMaterials[part].Material
                part.BrickColor = STATE.Cache.OriginalMaterials[part].BrickColor
                part.Transparency = STATE.Cache.OriginalMaterials[part].Transparency
            end
        end
    end
end

local function UpdateESP()
    if STATE.Toggles.ESP then
        STATE.Cache.OriginalMaterials = {}
        if STATE.Connections.ESP then STATE.Connections.ESP:Disconnect() end
        STATE.Connections.ESP = Services.RunService.RenderStepped:Connect(function()
            if not STATE.Toggles.ESP then STATE.Connections.ESP:Disconnect(); return end
            for _, player in ipairs(Services.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        for _, part in ipairs(char:GetChildren()) do
                            if part:IsA("BasePart") then
                                if not STATE.Cache.OriginalMaterials[part] then
                                    STATE.Cache.OriginalMaterials[part] = {
                                        Material = part.Material,
                                        BrickColor = part.BrickColor,
                                        Transparency = part.Transparency
                                    }
                                end
                                part.Material = Enum.Material.Neon
                                part.BrickColor = BrickColor.new("Really red")
                                part.Transparency = 0
                            end
                        end
                    end
                end
            end
        end)
        Notify("Player ESP","See everyone in RED!",3)
    else
        if STATE.Connections.ESP then STATE.Connections.ESP:Disconnect() end
        for _, player in ipairs(Services.Players:GetPlayers()) do
            task.spawn(function() RestorePlayerAppearance(player) end)
        end
        STATE.Cache.OriginalMaterials = {}
        Notify("Player ESP","Disabled",3)
    end
end

-- =============================================
-- SPEED CONTROL — 1 HANGGANG 300
-- =============================================
local function UpdateSpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if STATE.Toggles.Speed then
            char.Humanoid.WalkSpeed = STATE.SpeedValue
        else
            char.Humanoid.WalkSpeed = STATE.Cache.OriginalSpeed
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if STATE.Toggles.Speed then
            UpdateSpeed()
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
Main.BackgroundColor3 = Color3.fromRGB(8,8,15)
Main.Position = UDim2.new(0.02,0,0.02,0)
Main.Size = UDim2.new(0,240,0,300)
Main.Active = true; Main.Draggable = true
Main.Parent = Gui

-- Style
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,16)
local Stroke=Instance.new("UIStroke",Main)
Stroke.Thickness=2.5; Stroke.Color=Color3.fromRGB(0,255,140); Stroke.Transparency=0.08

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.BackgroundTransparency=1
TitleBar.Position=UDim2.new(0,0,0,0)
TitleBar.Size=UDim2.new(1,0,0,48)
TitleBar.Parent=Main

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency=1
Title.Position=UDim2.new(0,12,0,8)
Title.Size=UDim2.new(1,-50,0,32)
Title.Font=Enum.Font.GothamBold
Title.Text="JELO WARFREAK"
Title.TextColor3=Color3.fromRGB(0,255,140)
Title.TextSize=16
Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Parent=TitleBar

-- FOLD BUTTON
local FoldBtn = Instance.new("TextButton")
FoldBtn.BackgroundColor3=Color3.fromRGB(30,30,45)
FoldBtn.Position=UDim2.new(1,-40,0,8)
FoldBtn.Size=UDim2.new(0,28,0,28)
FoldBtn.Font=Enum.Font.GothamBold
FoldBtn.Text="−"
FoldBtn.TextColor3=Color3.fromRGB(200,200,200)
FoldBtn.TextSize=14
Instance.new("UICorner",FoldBtn).CornerRadius=UDim.new(0,8)
FoldBtn.Parent=TitleBar

-- CONTENT AREA
local Content = Instance.new("Frame")
Content.BackgroundTransparency=1
Content.Position=UDim2.new(0,0,0,48)
Content.Size=UDim2.new(1,0,0,252)
Content.Parent=Main

local Timer = Instance.new("TextLabel")
Timer.BackgroundTransparency=1
Timer.Position=UDim2.new(0,0,0,4)
Timer.Size=UDim2.new(1,0,0,32)
Timer.Font=Enum.Font.GothamBold
Timer.Text="00:00:00"
Timer.TextColor3=Color3.fromRGB(255,255,255)
Timer.TextSize=22
Timer.Parent=Content

-- Timer Loop
task.spawn(function() while task.wait(1) do STATE.Uptime+=1 local h=math.floor(STATE.Uptime/3600) local m=math.floor((STATE.Uptime%3600)/60) local s=STATE.Uptime%60 Timer.Text=string.format("%02d:%02d:%02d",h,m,s) end end)

-- BUTTON TEMPLATE
local function MakeButton(name,posY,callback)
    local btn=Instance.new("TextButton")
    btn.BackgroundColor3=Color3.fromRGB(40,40,55)
    btn.Position=UDim2.new(0,12,0,posY)
    btn.Size=UDim2.new(1,-24,0,34)
    btn.Font=Enum.Font.Gotham
    btn.Text=name.." — OFFLINE"
    btn.TextColor3=Color3.fromRGB(220,220,220)
    btn.TextSize=12
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    btn.Parent=Content
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- CREATE BUTTONS
MakeButton("ANTI-AFK",46,function(btn)
    STATE.Toggles.AntiAFK=not STATE.Toggles.AntiAFK
    if STATE.Toggles.AntiAFK then btn.Text="ANTI-AFK — ACTIVE"; btn.BackgroundColor3=Color3.fromRGB(15,130,60); EnableAntiAFK(); Notify("Anti-AFK","Enabled",2)
    else btn.Text="ANTI-AFK — OFFLINE"; btn.BackgroundColor3=Color3.fromRGB(40,40,55); DisableAntiAFK(); Notify("Anti-AFK","Disabled",2) end
end)

MakeButton("INFINITE JUMP",86,function(btn)
    STATE.Toggles.InfiniteJump=not STATE.Toggles.InfiniteJump
    if STATE.Toggles.InfiniteJump then btn.Text="INFINITE JUMP — ACTIVE"; btn.BackgroundColor3=Color3.fromRGB(15,130,60)
    else btn.Text="INFINITE JUMP — OFFLINE"; btn.BackgroundColor3=Color3.fromRGB(40,40,55) end
    UpdateInfiniteJump()
end)

MakeButton("NO-CLIP",126,function(btn)
    STATE.Toggles.NoClip=not STATE.Toggles.NoClip
    if STATE.Toggles.NoClip then btn.Text="NO-CLIP — ACTIVE"; btn.BackgroundColor3=Color3.fromRGB(15,130,60)
    else btn.Text="NO-CLIP — OFFLINE"; btn.BackgroundColor3=Color3.fromRGB(40,40,55) end
    UpdateNoClip()
end)

MakeButton("PLAYER ESP",166,function(btn)
    STATE.Toggles.ESP=not STATE.Toggles.ESP
    if STATE.Toggles.ESP then btn.Text="PLAYER ESP — ACTIVE"; btn.BackgroundColor3=Color3.fromRGB(180,20,20)
    else btn.Text="PLAYER ESP — OFFLINE"; btn.BackgroundColor3=Color3.fromRGB(40,40,55) end
    UpdateESP()
end)

-- SPEED BUTTON + INPUT BOX
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.BackgroundColor3=Color3.fromRGB(40,40,55)
SpeedBtn.Position=UDim2.new(0,12,0,206)
SpeedBtn.Size=UDim2.new(1,-24,0,34)
SpeedBtn.Font=Enum.Font.Gotham
SpeedBtn.Text="SPEED — OFFLINE [16]"
SpeedBtn.TextColor3=Color3.fromRGB(220,220,220)
SpeedBtn.TextSize=12
Instance.new("UICorner",SpeedBtn).CornerRadius=UDim.new(0,8)
SpeedBtn.Parent=Content

SpeedBtn.MouseButton1Click:Connect(function()
    STATE.Toggles.Speed=not STATE.Toggles.Speed
    if STATE.Toggles.Speed then
        SpeedBtn.Text="SPEED — ACTIVE ["..STATE.SpeedValue.."]"
        SpeedBtn.BackgroundColor3=Color3.fromRGB(15,130,60)
        UpdateSpeed()
        Notify("Speed","Set to "..STATE.SpeedValue,2)
    else
        SpeedBtn.Text="SPEED — OFFLINE ["..STATE.SpeedValue.."]"
        SpeedBtn.BackgroundColor3=Color3.fromRGB(40,40,55)
        UpdateSpeed()
        Notify("Speed","Restored",2)
    end
end)

-- SPEED INPUT — ILAGAY MO ANG BILIS (1–300)
local SpeedBox = Instance.new("TextBox")
SpeedBox.BackgroundColor3=Color3.fromRGB(30,30,45)
SpeedBox.Position=UDim2.new(0,12,0,246)
SpeedBox.Size=UDim2.new(1,-24,0,28)
SpeedBox.Font=Enum.Font.Gotham
SpeedBox.Text="16"
SpeedBox.PlaceholderText="Ilagay ang bilis (1–300)"
SpeedBox.TextColor3=Color3.fromRGB(255,255,255)
SpeedBox.TextSize=11
SpeedBox.ClearTextOnFocus=true
Instance.new("UICorner",SpeedBox).CornerRadius=UDim.new(0,8)
SpeedBox.Parent=Content

SpeedBox.FocusLost:Connect(function(enterPressed)
    local val = tonumber(SpeedBox.Text)
    if val then
        val = math.clamp(val, 1, 300) -- HINDI LALAMPAS SA 1–300
        STATE.SpeedValue = val
        SpeedBox.Text = tostring(val)
        SpeedBtn.Text = STATE.Toggles.Speed and "SPEED — ACTIVE ["..val.."]" or "SPEED — OFFLINE ["..val.."]"
        if STATE.Toggles.Speed then UpdateSpeed() end
        Notify("Speed","Set: "..val,2)
    end
end)

-- FOLD / UNFOLD
local OriginalHeight = 300
local FoldedHeight = 48

FoldBtn.MouseButton1Click:Connect(function()
    STATE.Folded = not STATE.Folded
    if STATE.Folded then
        Main.Size = UDim2.new(0,240,0,FoldedHeight)
        Content.Visible = false
        FoldBtn.Text = "+"
    else
        Main.Size = UDim2.new(0,240,0,OriginalHeight)
        Content.Visible = true
        FoldBtn.Text = "−"
    end
end)

print("✅ JELO WARFREAK — SPEED CONTROL ADDED (1–300)")
Notify("Jelo Warfreak","Speed: 1–300 • Ilagay sa box!",4)
