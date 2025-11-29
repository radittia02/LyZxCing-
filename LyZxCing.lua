-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- WINDOW
local Window = Rayfield:CreateWindow({
    Name = "CING PANEL - Player Menu",
    LoadingTitle = "Loading Panel...",
    LoadingSubtitle = "By Bro Jago",
})

----------------------------------------------------------------
-- PLAYER TAB
----------------------------------------------------------------
local PlayerTab = Window:CreateTab("Player", 4483362458)

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local Root = Char:WaitForChild("HumanoidRootPart")

-- JUMP POWER SLIDER
PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {10, 150},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        Humanoid.JumpPower = v
    end,
})

-- WALK SPEED SLIDER
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {10, 150},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        Humanoid.WalkSpeed = v
    end,
})

-- SPIT / DASH
PlayerTab:CreateButton({
    Name = "Spit / Dash",
    Callback = function()
        Root.Velocity = Root.CFrame.LookVector * 150
    end,
})

-- SIT
PlayerTab:CreateButton({
    Name = "Sit",
    Callback = function()
        Humanoid.Sit = true
    end,
})

-- UNSIT
PlayerTab:CreateButton({
    Name = "Un-Sit",
    Callback = function()
        Humanoid.Sit = false
    end,
})

-- INFINITE JUMP
local infjump = false
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        infjump = v
    end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infjump then
        Humanoid:ChangeState("Jumping")
    end
end)

-- NOCLIP
local noclip = false
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        noclip = v
    end,
})

game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        for _, part in ipairs(Char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- FLY
PlayerTab:CreateButton({
    Name = "Fly (E toggle)",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/YSL3xq0Z"))()
    end,
})

-- ANTI AFK
PlayerTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true,
    Callback = function(v)
        if v then
            local vu = game:GetService("VirtualUser")
            Player.Idled:connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end,
})

-- ESP PLAYER
local esp = false
PlayerTab:CreateToggle({
    Name = "ESP Player",
    CurrentValue = false,
    Callback = function(v)
        esp = v
        while esp do
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= Player and p.Character then
                    if not p.Character:FindFirstChild("Highlight") then
                        Instance.new("Highlight", p.Character)
                    end
                end
            end
            wait(1)
        end
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight:Destroy()
            end
        end
    end,
})

-- VIEW PLAYER CAMERA
local playerList = {}
for _, plr in pairs(game.Players:GetPlayers()) do
    table.insert(playerList, plr.Name)
end

PlayerTab:CreateDropdown({
    Name = "View Player Camera",
    Options = playerList,
    Callback = function(selected)
        workspace.CurrentCamera.CameraSubject = game.Players[selected].Character:FindFirstChild("Humanoid")
    end,
})

-- TELEPORT TO PLAYER
PlayerTab:CreateDropdown({
    Name = "Teleport to Player",
    Options = playerList,
    Callback = function(selected)
        local target = game.Players[selected].Character:FindFirstChild("HumanoidRootPart")
        if target then
            Root.CFrame = target.CFrame + Vector3.new(0, 2, 0)
        end
    end,
})

-- TELEPORT WAYPOINTS
local waypoint = Instance.new("Part", workspace)
waypoint.Size = Vector3.new(1,1,1)
waypoint.Transparency = 1
waypoint.Anchored = true

PlayerTab:CreateButton({
    Name = "Save Waypoint",
    Callback = function()
        waypoint.CFrame = Root.CFrame
    end,
})

PlayerTab:CreateButton({
    Name = "Teleport to Waypoint",
    Callback = function()
        Root.CFrame = waypoint.CFrame
    end,
})

-- GODMODE
PlayerTab:CreateButton({
    Name = "God Mode",
    Callback = function()
        pcall(function()
            Humanoid.Name = "1"
            local clone = Humanoid:Clone()
            clone.Parent = Char
            clone.Name = "Humanoid"
            wait()
            Humanoid:Destroy()
            workspace.CurrentCamera.CameraSubject = Char.Humanoid
        end)
    end,
})

----------------------------------------------------------------
-- MOUNTAIN TAB (AUTO CLIMB / ANTI FALL / NO SLIP)
----------------------------------------------------------------

local MountainTab = Window:CreateTab("Mountain", 4483362458)

local NoSlip = false
local AntiFall = false
local AutoClimb = false
local ClimbBoost = false
local SlopeWalk = false

local climbSpeed = 45
local safeHeight = Root.CFrame
local slipFriction = 999999

-- NO SLIP
MountainTab:CreateToggle({
    Name = "No Slip (Anti Licin)",
    CurrentValue = false,
    Callback = function(v)
        NoSlip = v
        if v then
            task.spawn(function()
                while NoSlip do
                    for _, part in pairs(Char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, slipFriction, 0.5)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- AUTO CLIMB
MountainTab:CreateToggle({
    Name = "Auto Climb",
    CurrentValue = false,
    Callback = function(v)
        AutoClimb = v
        if v then
            task.spawn(function()
                while AutoClimb do
                    local rp = RaycastParams.new()
                    rp.FilterDescendantsInstances = {Char}
                    rp.FilterType = Enum.RaycastFilterType.Blacklist

                    local hit = workspace:Raycast(Root.Position, Root.CFrame.LookVector * 3, rp)

                    if hit then
                        Root.Velocity = Vector3.new(Root.Velocity.X, climbSpeed, Root.Velocity.Z)
                    end
                    task.wait()
                end
            end)
        end
    end,
})

-- CLIMB SPEED
MountainTab:CreateSlider({
    Name = "Climb Speed",
    Range = {10, 120},
    Increment = 1,
    CurrentValue = 45,
    Callback = function(v)
        climbSpeed = v
    end,
})

-- BOOST WITH SHIFT
MountainTab:CreateToggle({
    Name = "Climb Boost (Shift)",
    CurrentValue = false,
    Callback = function(v)
        ClimbBoost = v
        if v then
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.LeftShift then
                    climbSpeed += 25
                end
            end)

            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.LeftShift then
                    climbSpeed -= 25
                end
            end)
        end
    end,
})

-- SLOPE WALK
MountainTab:CreateToggle({
    Name = "Slope Walk",
    CurrentValue = false,
    Callback = function(v)
        SlopeWalk = v
        if v then
            Humanoid.MaxSlopeAngle = 90
        else
            Humanoid.MaxSlopeAngle = 45
        end
    end,
})

-- SAVE POSITION AUTO
task.spawn(function()
    while true do
        safeHeight = Root.CFrame
        task.wait(3)
    end
end)

-- ANTI FALL
MountainTab:CreateToggle({
    Name = "Anti Fall",
    CurrentValue = false,
    Callback = function(v)
        AntiFall = v
        if v then
            task.spawn(function()
                while AntiFall do
                    if Root.Velocity.Y < -120 then
                        Root.CFrame = safeHeight
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- SAVE POS MANUAL
MountainTab:CreateButton({
    Name = "Save Position",
    Callback = function()
        safeHeight = Root.CFrame
    end,
})

-- TELEPORT BACK
MountainTab:CreateButton({
    Name = "Return to Save",
    Callback = function()
        Root.CFrame = safeHeight
    end,
})