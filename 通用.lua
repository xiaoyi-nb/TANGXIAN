local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local CoreGui = cloneref(game:GetService("CoreGui"))
local Lighting = cloneref(game:GetService("Lighting"))
local Camera = workspace.CurrentCamera
local TweenService = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))

local FlyTable = {
    mobile = {
        Speed = 300,
    },
    vfly = {
        Enabled = false,
        Speed = 50
    },
    desktop = {
        Enabled = false,
        Speed = 50,
        Active = false,
        Connections = {},
        Controls = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0},
        LastControls = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    }
}

local SelectTable = {
    list = {},
    select = "",
    teleport = false,
    look = false,
    fling = false,
    suck = false,
    freeze = false
}

local TeleportTable = {
    location = {},
    names = {},
    select = "",
}

local PlayerTable = {
    list = {},
    selectmethod = "",
    select = "",
    distance = 16,
    loop = false
}

local AimbotTable = {
    Enabled = false,
    TargetPart = "Head",
    TargetType = "Player",
    FriendCheck = false,
    TeamCheck = false,
    WallCheck = false,
    AliveCheck = false
}

local ESPTable = {
    ShowNPC = false,
    ShowBox = false,
    ShowHealth = false,
    ShowName = false,
    ShowDistance = false,
    ShowTracer = false,
    TeamCheck = false,
    FriendCheck = false
}

local HitboxTable = {
    Enabled = false,
    Size = 5,
    Color = Color3.new(1, 0, 0),
    Target = "Player",
    FriendCheck = false,
    TeamCheck = false,
    OriginalSizes = {},
    Loop = nil,
    
    ColorOptions = {"Red(红色)", "Green(绿色)", "Blue(蓝色)", "Yellow(黄色)", "Purple(紫色)"},
    
    ColorMap = {
        ["Red(红色)"] = Color3.new(1, 0, 0),
        ["Green(绿色)"] = Color3.new(0, 1, 0),
        ["Blue(蓝色)"] = Color3.new(0, 0, 1),
        ["Yellow(黄色)"] = Color3.new(1, 1, 0),
        ["Purple(紫色)"] = Color3.new(0.5, 0, 0.5)
    }
}

local old
local SilentAim = {
    enable = false,
    teamcheck = false,
    friendcheck = false,
    enablenpc = false
}

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
end)

local function cleanupConnections()
    for _, conn in pairs(FlyTable.desktop.Connections) do
        if conn then
            conn:Disconnect()
        end
    end
    FlyTable.desktop.Connections = {}
end

local function setPlatformStand(state)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = state
    end
end

local function startDesktopFly()
    cleanupConnections()
    
    local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local bg = Instance.new("BodyGyro")
    local bv = Instance.new("BodyVelocity")
    
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = root.CFrame
    bg.Parent = root
    
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = root
    
    FlyTable.desktop.Connections.inputBegan = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name
            if key == "W" then FlyTable.desktop.Controls.F = FlyTable.desktop.Speed
            elseif key == "S" then FlyTable.desktop.Controls.B = -FlyTable.desktop.Speed
            elseif key == "A" then FlyTable.desktop.Controls.L = -FlyTable.desktop.Speed
            elseif key == "D" then FlyTable.desktop.Controls.R = FlyTable.desktop.Speed
            elseif key == "E" then FlyTable.desktop.Controls.Q = FlyTable.desktop.Speed * 2
            elseif key == "Q" then FlyTable.desktop.Controls.E = -FlyTable.desktop.Speed * 2
            end
        end
    end)
    
    FlyTable.desktop.Connections.inputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name
            if key == "W" then FlyTable.desktop.Controls.F = 0
            elseif key == "S" then FlyTable.desktop.Controls.B = 0
            elseif key == "A" then FlyTable.desktop.Controls.L = 0
            elseif key == "D" then FlyTable.desktop.Controls.R = 0
            elseif key == "E" then FlyTable.desktop.Controls.Q = 0
            elseif key == "Q" then FlyTable.desktop.Controls.E = 0
            end
        end
    end)
    
    FlyTable.desktop.Connections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart")
        startDesktopFly()
    end)
    
    FlyTable.desktop.Connections.renderStep = RunService.RenderStepped:Connect(function()
        if not FlyTable.desktop.Active then return end
        
        setPlatformStand(true)
        
        local moving = (FlyTable.desktop.Controls.L + FlyTable.desktop.Controls.R) ~= 0 or 
                      (FlyTable.desktop.Controls.F + FlyTable.desktop.Controls.B) ~= 0 or 
                      (FlyTable.desktop.Controls.Q + FlyTable.desktop.Controls.E) ~= 0
        
        if moving then
            FlyTable.desktop.LastControls = {
                F = FlyTable.desktop.Controls.F,
                B = FlyTable.desktop.Controls.B,
                L = FlyTable.desktop.Controls.L,
                R = FlyTable.desktop.Controls.R
            }
            
            bv.Velocity = ((Camera.CFrame.LookVector * (FlyTable.desktop.Controls.F + FlyTable.desktop.Controls.B)) + 
                          ((Camera.CFrame * CFrame.new(FlyTable.desktop.Controls.L + FlyTable.desktop.Controls.R, 
                          (FlyTable.desktop.Controls.F + FlyTable.desktop.Controls.B + FlyTable.desktop.Controls.Q + FlyTable.desktop.Controls.E) * 0.2, 0).p) - 
                          Camera.CFrame.p)) * FlyTable.desktop.Speed
        elseif FlyTable.desktop.Speed ~= 0 then
            bv.Velocity = ((Camera.CFrame.LookVector * (FlyTable.desktop.LastControls.F + FlyTable.desktop.LastControls.B)) + 
                          ((Camera.CFrame * CFrame.new(FlyTable.desktop.LastControls.L + FlyTable.desktop.LastControls.R, 
                          (FlyTable.desktop.LastControls.F + FlyTable.desktop.LastControls.B) * 0.2, 0).p) - 
                          Camera.CFrame.p)) * FlyTable.desktop.Speed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        
        bg.CFrame = Camera.CFrame
    end)
    
    FlyTable.desktop.Active = true
end

local function startMobileFly()
    cleanupConnections()
    
    local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    
    bv.Name = "FlyVelocity"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 1000
    bg.D = 50
    bg.Parent = root
    
    local Control = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    
    FlyTable.desktop.Connections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart")
        startMobileFly()
    end)
    
    FlyTable.desktop.Connections.renderStep = RunService.RenderStepped:Connect(function()
        if not FlyTable.desktop.Active then return end
        
        setPlatformStand(true)
        
        local direction = Control:GetMoveVector()
        bg.CFrame = Camera.CFrame
        bv.Velocity = Vector3.new(0, 0, 0)
        
        if direction.X ~= 0 then
            bv.Velocity = bv.Velocity + (Camera.CFrame.RightVector * (direction.X * FlyTable.desktop.Speed))
        end
        if direction.Z ~= 0 then
            bv.Velocity = bv.Velocity - (Camera.CFrame.LookVector * (direction.Z * FlyTable.desktop.Speed))
        end
    end)
    
    FlyTable.desktop.Active = true
end

local function stopFly()
    FlyTable.desktop.Active = false
    cleanupConnections()
    setPlatformStand(false)
    
    if LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, obj in ipairs(root:GetChildren()) do
                if obj.Name == "FlyVelocity" or obj.Name == "FlyGyro" then
                    obj:Destroy()
                end
            end
        end
    end
end

local function toggleFly(state)
    FlyTable.desktop.Enabled = state
    
    if FlyTable.desktop.Enabled then
        if UserInputService.TouchEnabled then
            startMobileFly()
        else
            startDesktopFly()
        end
    else
        stopFly()
    end
end

local function setFlySpeed(speed)
    FlyTable.desktop.Speed = speed
end

pcall(function()
    local Signal1, Signal2
    
    function mobilefly(speed)
    	local controlModule = require(LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'):WaitForChild("ControlModule"))
    	if not Character or not HumanoidRootPart then return end
    
    	local bv = Instance.new("BodyVelocity")
    	bv.Name = "VelocityHandler"
    	bv.Parent = HumanoidRootPart
    	bv.MaxForce = Vector3.new(0, 0, 0)
    	bv.Velocity = Vector3.new(0, 0, 0)
    
    	local bg = Instance.new("BodyGyro")
    	bg.Name = "GyroHandler"
    	bg.Parent = HumanoidRootPart
    	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    	bg.P = 1000
    	bg.D = 50
    
    	Signal1 = LocalPlayer.CharacterAdded:Connect(function(NewChar)
    		local bv = Instance.new("BodyVelocity")
    		bv.Name = "VelocityHandler"
    		bv.Parent = NewChar:WaitForChild("HumanoidRootPart")
    		bv.MaxForce = Vector3.new(0, 0, 0)
    		bv.Velocity = Vector3.new(0, 0, 0)
    
    		local bg = Instance.new("BodyGyro")
    		bg.Name = "GyroHandler"
    		bg.Parent = NewChar:WaitForChild("HumanoidRootPart")
    		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    		bg.P = 1000
    		bg.D = 50
    	end)
        
    	Signal2 = RunService.RenderStepped:Connect(function()
    		if Character and HumanoidRootPart and HumanoidRootPart:FindFirstChild("VelocityHandler") and HumanoidRootPart:FindFirstChild("GyroHandler") then
    			HumanoidRootPart.VelocityHandler.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    			HumanoidRootPart.GyroHandler.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    			Humanoid.PlatformStand = true
    
    			HumanoidRootPart.GyroHandler.CFrame = Camera.CFrame
    			local direction = controlModule:GetMoveVector()
    			HumanoidRootPart.VelocityHandler.Velocity = Vector3.new()
    			if direction.X ~= 0 then
    				HumanoidRootPart.VelocityHandler.Velocity = HumanoidRootPart.VelocityHandler.Velocity + Camera.CFrame.RightVector * (direction.X * speed)
    			end
    			if direction.Z ~= 0 then
    				HumanoidRootPart.VelocityHandler.Velocity = HumanoidRootPart.VelocityHandler.Velocity - Camera.CFrame.LookVector * (direction.Z * speed)
    			end
    		end
    	end)
    end
    
    function unmobilefly()
    	if Character and HumanoidRootPart then
    		if HumanoidRootPart:FindFirstChild("VelocityHandler") then HumanoidRootPart.VelocityHandler:Destroy() end
    		if HumanoidRootPart:FindFirstChild("GyroHandler") then HumanoidRootPart.GyroHandler:Destroy() end
    		Humanoid.PlatformStand = false
    	end
    	if Signal1 then Signal1:Disconnect() end
    	if Signal2 then Signal2:Disconnect() end
    end
end)

local H = Instance.new("ScreenGui")
H.Name = "FlyControls"
H.Parent = CoreGui
H.Enabled = FlyTable.vfly.Enabled
H.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local I = Instance.new("TextButton")
I.Name = "ForwardBtn"
I.Size = UDim2.new(0, 50, 0, 50)
I.Position = UDim2.new(0, 50, 1, -120)
I.AnchorPoint = Vector2.new(0, 1)
I.BackgroundTransparency = 1
I.Text = "^"
I.TextColor3 = Color3.new(1, 1, 1)
I.TextScaled = true
I.Parent = H

local J = Instance.new("TextButton")
J.Name = "BackwardBtn"
J.Size = UDim2.new(0, 50, 0, 50)
J.Position = UDim2.new(0, 50, 1, -60)
J.AnchorPoint = Vector2.new(0, 1)
J.BackgroundTransparency = 1
J.Text = "v"
J.TextColor3 = Color3.new(1, 1, 1)
J.TextScaled = true
J.Parent = H

local K = nil
local L = nil
local M = false

function enableVfly()
    if M then
        return
    end
    if not Character then
        return
    end
    if not HumanoidRootPart then
        return
    end
    K = Instance.new("BodyVelocity")
    K.Name = "FlyVelocity"
    K.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    K.Velocity = Vector3.new(0, 0, 0)
    K.Parent = HumanoidRootPart
    L = Instance.new("BodyGyro")
    L.Name = "FlyGyro"
    L.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    L.D = 5000
    L.P = 100000
    L.CFrame = Camera.CFrame
    L.Parent = HumanoidRootPart
    M = true
    local O
    O = RunService.RenderStepped:Connect(function()
        if not M or not L then
            O:Disconnect()
            return
        end
        L.CFrame = Camera.CFrame
    end)
    I.MouseButton1Down:Connect(function()
        if not M then
            return
        end
        K.Velocity = Camera.CFrame.LookVector * FlyTable.vfly.Speed
    end)
    I.MouseButton1Up:Connect(function()
        if not M then
            return
        end
        K.Velocity = Vector3.new(0, 0, 0)
    end)
    J.MouseButton1Down:Connect(function()
        if not M then
            return
        end
        K.Velocity = Camera.CFrame.LookVector * - FlyTable.vfly.Speed
    end)
    J.MouseButton1Up:Connect(function()
        if not M then
            return
        end
        K.Velocity = Vector3.new(0, 0, 0)
    end)
end

function disableVfly()
    M = false
    if Character then
        if HumanoidRootPart then
            local B = HumanoidRootPart:FindFirstChild("FlyVelocity")
            local C = HumanoidRootPart:FindFirstChild("FlyGyro")
            if B then
                B:Destroy()
            end
            if C then
                C:Destroy()
            end
        end
    end
    H.Enabled = false
end

for _, v in next, Players:GetPlayers() do
    if v ~= LocalPlayer then
        table.insert(PlayerTable.list, v.Name)
        table.insert(SelectTable.list, v.Name)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v ~= LocalPlayer then
        table.insert(PlayerTable.list, v.Name)
        table.insert(SelectTable.list, v.Name)
    end
end)

if not CoreGui:FindFirstChild("ESPHolder") then
    local X = Instance.new("Folder")
    X.Name = "ESPHolder"
    X.Parent = CoreGui
end

local function AddESP(v)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1, 1, 1)
    box.Thickness = 1
    box.Filled = false
    
    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Color = Color3.new(0, 1, 0)
    healthText.Size = 16
    
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = Color3.new(1, 1, 1)
    nameText.Size = 16
    
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = Color3.new(1, 1, 0)
    distanceText.Size = 16
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.new(1, 0, 0)
    tracer.Thickness = 1
    
    RunService.RenderStepped:Connect(function()
        if not v.Character or not v.Character:FindFirstChild("HumanoidRootPart") or
           not v.Character:FindFirstChild("Humanoid") or v == LocalPlayer then
            box.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            tracer.Visible = false
            return
        end
        
        if ESPTable.TeamCheck and v.Team == LocalPlayer.Team then
            box.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            tracer.Visible = false
            return
        end
        
        if ESPTable.FriendCheck and LocalPlayer:IsFriendsWith(v.UserId) then
            box.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            tracer.Visible = false
            return
        end
        
        local character = v.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if rootPart and humanoid and humanoid.Health > 0 then
            local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local topPosition = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            local bottomPosition = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
            
            if ESPTable.ShowBox and onScreen then
                box.Size = Vector2.new(1000 / position.Z, topPosition.Y - bottomPosition.Y)
                box.Position = Vector2.new(position.X - box.Size.X / 2, position.Y - box.Size.Y / 2)
                box.Visible = true
            else
                box.Visible = false
            end
            
            if ESPTable.ShowHealth and onScreen then
                healthText.Position = Vector2.new(position.X, position.Y - box.Size.Y / 2 - 20)
                healthText.Text = "Health: " .. math.floor(humanoid.Health)
                healthText.Visible = true
            else
                healthText.Visible = false
            end
            
            if ESPTable.ShowName and onScreen then
                nameText.Position = Vector2.new(position.X, position.Y - box.Size.Y / 2 - 40)
                nameText.Text = "UserName: " .. v.Name
                nameText.Visible = true
            else
                nameText.Visible = false
            end
            
            if ESPTable.ShowDistance and onScreen then
                local distance = (HumanoidRootPart.Position - rootPart.Position).Magnitude
                distanceText.Position = Vector2.new(position.X, position.Y + box.Size.Y / 2 + 20)
                distanceText.Text = "Distance: " .. math.floor(distance) .. " studs"
                distanceText.Visible = true
            else
                distanceText.Visible = false
            end
            
            if ESPTable.ShowTracer and onScreen then
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(position.X, position.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            box.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            tracer.Visible = false
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        AddESP(v)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v ~= LocalPlayer then
        AddESP(v)
    end
end)

local function getClosestHead()
    local closestHead
    local closestDistance = math.huge
    
    if not LocalPlayer.Character then return end
    if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local skip = false
            
            if SilentAim.teamcheck then
                if v.Team == LocalPlayer.Team then
                    skip = true
                end
            end
            
            if not skip and SilentAim.friendcheck then
                if LocalPlayer:IsFriendsWith(v.UserId) then
                    skip = true
                end
            end
            
            if not skip then
                local character = v.Character
                local root = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local forcefield = character:FindFirstChild("ForceField")
                
                if root and head and humanoid and not forcefield and humanoid.Health > 0 then
                    local distance = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestHead = head
                        closestDistance = distance
                    end
                end
            end
        end
    end
    return closestHead
end

local function getClosestNpcHead()
    local closestNPCHead = nil
    local closestDistance = math.huge
    for _,v in next,workspace:GetDescendants() do
        if not Players:GetPlayerFromCharacter(v) then
            if (v.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude < closestDistance then
                closestDistance = distance
                closestNPCHead = head
            end
        end
    end
    return closestNPCHead
end

old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if SilentAim.enable and method == "Raycast" and not checkcaller() then
        local origin = args[1] or Camera.CFrame.Position
        local closestHead = getClosestHead()
        if closestHead then
            return {
                Instance = closestHead,
                Position = closestHead.Position,
                Normal = (origin - closestHead.Position).Unit,
                Material = Enum.Material.Plastic,
                Distance = (closestHead.Position - origin).Magnitude
            }
        end
    elseif SilentAim.enablenpc and method == "Raycast" and not checkcaller() then
        local origin = args[1] or Camera.CFrame.Position
        local closestNpcHead = getClosestNpcHead()
        if closestNpcHead then
            return {
                Instance = closestNpcHead,
                Position = closestNpcHead.Position,
                Normal = (origin - closestNpcHead.Position).Unit,
                Material = Enum.Material.Plastic,
                Distance = (closestNpcHead.Position - origin).Magnitude
            }
        end
    end
    return old(self, ...)
end))

local function fetchEmoteIds()
    local baseUrl = "https://catalog.roblox.com/v1/search/items?category=12&subcategory=39&limit=100"
    local cursor = nil
    local ids = {}

    while true do
        local url = baseUrl
        if cursor then
            url = url .. "&cursor=" .. cursor
        end

        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGetAsync(url))
        end)

        if not success or not response or not response.data then
            WindUI:Notify({
                Title = "Error (错误)",
                Content = "Failed to fetch emotes (无法获取表情符号)",
                Duration = 3,
                Icon = "error"
            })
            break
        end

        for _, item in response.data do
            table.insert(ids, item.id)
        end

        if response.nextPageCursor then
            cursor = response.nextPageCursor
        else
            break
        end
    end

    return ids
end

local function fetchEmoteDetails(ids)
    local url = "https://catalog.roblox.com/v1/catalog/items/details"
    local emotes = {}

    for i = 1, #ids, 50 do
        local batch = {}
        for j = i, math.min(i + 49, #ids) do
            table.insert(batch, { itemType = 1, id = ids[j] })
        end

        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpPostAsync(url, HttpService:JSONEncode({ items = batch })))
        end)

        if success and response and response.data then
            for _, item in response.data do
                table.insert(emotes, { name = item.name, id = item.id, creator = item.creatorName })
            end
        else
            WindUI:Notify({
                Title = "Warning (警告)",
                Content = "Failed to fetch some emote details (未能获取某些表情详细信息)",
                Duration = 3,
                Icon = "warning"
            })
        end
    end

    return emotes
end

local function playEmote(emoteId)
    if not Humanoid then return end
    local animation = Humanoid:PlayEmoteAndGetAnimTrackById(emoteId)
    currentAnimation = animation
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Localization = WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "cn",
    Translations = {
        ["en"] = {
            ["UI_NAME"] = "  Nova Hub Universal",
            ["AUTHOR_NAME"] = "  Author: Nova",
            ["OPEN_UI"] = "  Open UI",
            ["PLAYER_AND_MAP"] = "Player and Map",
            ["COMBAT"] = "Combat",
            ["SERVER"] = "Server",
            ["ENTERTAINMENT"] = "Entertainment",
            ["PLAYER"] = "Player",
            ["WALK_SPEED"] = "Walk Speed",
            ["ENABLE_WALKSPEED"] = "Enable Walkspeed",
            ["WALKFLING"] = "Fling Player",
            ["ANTIFLING"] = "Anti Fling",
            ["JUMP_POWER"] = "Jump Power",
            ["LOW_GRAVITY"] = "Low Gravity",
            ["CUSTOM_GRAVITY"] = "Custom Gravity",
            ["INFINITE_JUMP"] = "Infinite Jump",
            ["NO_CLIP"] = "No Clip",
            ["FLY"] = "Fly",
            ["SELECT"] = "Select",
            ["OTHER"] = "Other",
            ["MOBILE_FLY"] = "Mobile Flying",
            ["PC_FLY"] = "PC Flying (Mobile Compatible)",
            ["VEHICLE_FLY"] = "Vehicle Flying",
            ["MOBILE_FLY_SPEED"] = "Fly Speed (Mobile)",
            ["PC_FLY_SPEED"] = "Fly Speed (PC)",
            ["VEHICLE_FLY_SPEED"] = "Fly Speed (Vehicle)",
            ["MAIN"] = "Main",
            ["AUTO_INTERACT"] = "Auto Interact",
            ["CHAT_VISIBILITY"] = "Chat Visibility",
            ["CAMERA_NOCLIP"] = "Camera Noclip",
            ["AIR_WALK"] = "Air Walk",
            ["INSTANT_INTERACT"] = "Instant Interact",
            ["CAMERA_MODE"] = "Camera Mode",
            ["LOCK_FIRST_PERSON"] = "Lock First Person",
            ["CLASSIC"] = "Classic",
            ["RESPAWN_IN_PLACE"] = "Respawn In Place",
            ["TOOLS"] = "Tools",
            ["GET_TELEPORT_TOOL"] = "Get Teleport Tool",
            ["STEAL_TOOLS"] = "Steal Other Players' Tools",
            ["TELEPORT_ITEM_DISTANCE"] = "Teleport Tool (Distance)",
            ["MAP"] = "Map",
            ["X_RAY"] = "X Ray",
            ["NO_FOG"] = "No Fog",
            ["FULL_BRIGHT"] = "Full Bright",
            ["NO_SHADOW"] = "No Shadow",
            ["TELEPORT"] = "Teleport",
            ["CUSTOM_TELEPORT"] = "Custom Teleport",
            ["SELECT_LOCATION"] = "Select Location",
            ["SAVE_LOCATIONS"] = "Saved Locations",
            ["NO_SAVED"] = "Not Saved",
            ["SAVE_CURRENT"] = "Save Current Location",
            ["DELETE_SELECTED"] = "Delete Selected",
            ["TELEPORT_TO"] = "Teleport To",
            ["LOCATION_NAME"] = "Location Name",
            ["SELECT_PLAYER"] = "Select Player",
            ["SELECT_DIRECTION"] = "Select Direction",
            ["TELEPORT_PLAYER"] = "Teleport Player",
            ["LOOP_TELEPORT"] = "Loop Teleport",
            ["TELEPORT_DISTANCE"] = "Teleport Distance",
            ["UNNAMED_LOCATION"] = "Unnamed Location #",
            ["AIMBOT"] = "Enable Aimbot",
            ["AIMBOT_TARGET_PART"] = "Target Part",
            ["AIMBOT_TARGET_TYPE"] = "Target",
            ["FRIEND_CHECK"] = "Friend Check",
            ["TEAM_CHECK"] = "Team Check",
            ["WALL_CHECK"] = "Wall Check",
            ["ALIVE_CHECK"] = "Alive Check",
            ["HEAD"] = "Head",
            ["HUMANOID_ROOT_PART"] = "HumanoidRootPart",
            ["ESP"] = "ESP",
            ["NPC"] = "NPC",
            ["PLAYER"] = "Player",
            ["NPC_ESP"] = "NPC ESP",
            ["SHOW_BOX"] = "Box",
            ["SHOW_HEALTH"] = "Health",
            ["SHOW_NAME"] = "Name",
            ["SHOW_DISTANCE"] = "Distance",
            ["SHOW_TRACER"] = "Tracer",
            ["TEAM_CHECK"] = "Team Check",
            ["SILENT_AIM"] = "Silent Aim",
            ["ENABLE_BULLET_TRACKING"] = "Enable Bullet Tracking",
            ["TEAM_CHECK"] = "Team Check",
            ["FRIEND_CHECK"] = "Friend Check",
            ["NPC_BULLET_TRACKING"] = "NPC Bullet Tracking",
            ["HITBOX"] = "Hitbox",
            ["ENABLE_HITBOX"] = "Enable Hitbox",
            ["COLLISION_ENABLED"] = "Enable Hitbox CanCollide",
            ["HITBOX_SIZE"] = "Hitbox Size",
            ["HITBOX_COLOR"] = "Hitbox Color",
            ["TARGET"] = "Target",
            ["SERVER"] = "Server",
            ["COPY_SERVER_CODE"] = "Copy Server Join Code (For your friends :) )",
            ["REJOIN_SERVER"] = "Rejoin Server",
            ["JOIN_LOW_POP_SERVER"] = "Join Low Server",
            ["SERVER_HOP"] = "Server Hop",
            ["CREATE_PRIVATE_SERVER"] = "Create and Join Free vip Server",
            ["COPY_PRIVATE_SERVER"] = "Copy Bip Server Code",
            ["EMOTE"] = "Emotes",
            ["EMOTE_PREVIEW"] = "Emote Preview",
            ["PLAY_EMOTE"] = "Play Emote"
        },
        ["cn"] = {
            ["UI_NAME"] = "  Nova Hub通用",
            ["AUTHOR_NAME"] = "  作者: Nova",
            ["OPEN_UI"] = "  打开UI",
            ["PLAYER_AND_MAP"] = "玩家和地图",
            ["COMBAT"] = "战斗",
            ["SERVER"] = "服务器",
            ["ENTERTAINMENT"] = "娱乐",
            ["PLAYER"] = "玩家",
            ["WALK_SPEED"] = "移动速度",
            ["ENABLE_WALKSPEED"] = "启用速度",
            ["WALKFLING"] = "触碰甩飞",
            ["ANTIFLING"] = "反甩飞",
            ["JUMP_POWER"] = "跳跃高度",
            ["LOW_GRAVITY"] = "低重力",
            ["CUSTOM_GRAVITY"] = "自定义重力",
            ["INFINITE_JUMP"] = "无限跳跃",
            ["NO_CLIP"] = "穿墙",
            ["FLY"] = "飞行",
            ["SELECT"] = "选择",
            ["OTHER"] = "其他",
            ["MOBILE_FLY"] = "手机飞行",
            ["PC_FLY"] = "电脑飞行(手机通用)",
            ["VEHICLE_FLY"] = "载具飞行",
            ["MOBILE_FLY_SPEED"] = "飞行速度(手机)",
            ["PC_FLY_SPEED"] = "飞行速度(电脑)",
            ["VEHICLE_FLY_SPEED"] = "飞行速度(载具)",
            ["MAIN"] = "主要",
            ["AUTO_INTERACT"] = "自动互动",
            ["CHAT_VISIBILITY"] = "聊天框显示",
            ["CAMERA_NOCLIP"] = "视角穿墙",
            ["AIR_WALK"] = "踏空行走",
            ["INSTANT_INTERACT"] = "秒互动",
            ["CAMERA_MODE"] = "人称",
            ["LOCK_FIRST_PERSON"] = "第一人称锁定",
            ["CLASSIC"] = "经典",
            ["RESPAWN_IN_PLACE"] = "原地复活",
            ["TOOLS"] = "工具",
            ["GET_TELEPORT_TOOL"] = "获取点击传送工具",
            ["STEAL_TOOLS"] = "偷其他玩家工具",
            ["TELEPORT_ITEM_DISTANCE"] = "瞬移道具(距离)",
            ["MAP"] = "地图",
            ["X_RAY"] = "X光透视",
            ["NO_FOG"] = "移除雾气",
            ["FULL_BRIGHT"] = "高亮模式",
            ["NO_SHADOW"] = "无阴影",
            ["TELEPORT"] = "传送",
            ["CUSTOM_TELEPORT"] = "自定义传送",
            ["SELECT_LOCATION"] = "选择传送地点",
            ["SAVE_LOCATIONS"] = "保存的地点",
            ["NO_SAVED"] = "未保存",
            ["SAVE_CURRENT"] = "保存当前位置",
            ["DELETE_SELECTED"] = "删除地点",
            ["TELEPORT_TO"] = "传送地点",
            ["LOCATION_NAME"] = "传送地点名称",
            ["SELECT_PLAYER"] = "选择玩家",
            ["SELECT_DIRECTION"] = "选择传送方向",
            ["TELEPORT_PLAYER"] = "传送玩家",
            ["LOOP_TELEPORT"] = "循环传送",
            ["TELEPORT_DISTANCE"] = "传送距离",
            ["UNNAMED_LOCATION"] = "未命名位置 #",
            ["AIMBOT"] = "自瞄",
            ["AIMBOT_TARGET_PART"] = "瞄准部位",
            ["AIMBOT_TARGET_TYPE"] = "启用目标",
            ["FRIEND_CHECK"] = "好友验证",
            ["TEAM_CHECK"] = "队伍验证",
            ["WALL_CHECK"] = "墙体检测",
            ["ALIVE_CHECK"] = "存活检测",
            ["HEAD"] = "头部",
            ["HUMANOID_ROOT_PART"] = "身体",
            ["ESP"] = "透视",
            ["NPC"] = "NPC",
            ["PLAYER"] = "玩家",
            ["NPC_ESP"] = "NPC透视",
            ["SHOW_BOX"] = "显示方框",
            ["SHOW_HEALTH"] = "显示血量",
            ["SHOW_NAME"] = "显示名字",
            ["SHOW_DISTANCE"] = "显示距离",
            ["SHOW_TRACER"] = "显示追踪线",
            ["TEAM_CHECK"] = "队伍检测",
            ["SILENT_AIM"] = "子弹追踪",
            ["ENABLE_BULLET_TRACKING"] = "开启子弹追踪",
            ["TEAM_CHECK"] = "开启队伍验证",
            ["FRIEND_CHECK"] = "开启好友验证",
            ["NPC_BULLET_TRACKING"] = "开启NPC子弹追踪",
            ["HITBOX"] = "Hitbox",
            ["ENABLE_HITBOX"] = "开启Hitbox",
            ["COLLISION_ENABLED"] = "Hitbox碰撞",
            ["HITBOX_SIZE"] = "Hitbox大小",
            ["HITBOX_COLOR"] = "Hitbox颜色",
            ["TARGET"] = "目标",
            ["SERVER"] = "服务器",
            ["COPY_SERVER_CODE"] = "复制加入该服务器代码(给你的朋友 :) )",
            ["REJOIN_SERVER"] = "重新加入",
            ["JOIN_LOW_POP_SERVER"] = "加入人数较少的服务器",
            ["SERVER_HOP"] = "服务器跳转",
            ["CREATE_PRIVATE_SERVER"] = "创建并加入免费私人服务器",
            ["COPY_PRIVATE_SERVER"] = "复制进入私服Code(给你好友让他进入)",
            ["EMOTE"] = "表情",
            ["EMOTE_PREVIEW"] = "表情预览",
            ["PLAY_EMOTE"] = "播放表情"
        }
    }
})


local Window = WindUI:CreateWindow({
    Title = "loc:UI_NAME",
    Icon = "scan-eye",
    Author = "loc:AUTHOR_NAME",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(400, 400),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = true
})

Window:EditOpenButton({
    Title = "loc:OPEN_UI",
    Icon = "eye",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( 
        Color3.fromHex("FF00FF"), 
        Color3.fromHex("00FFFF"), 
        Color3.fromHex("800080")   
    ),
    Draggable = true,
})

printidentity()

game:GetService("LogService").MessageOut:Connect(function(message, messageType)
    if string.find(message, "Current identity is") then
        local identityNumber = string.match(message, "Current identity is (%d+)")
        if identityNumber then
            Window:Tag({ 
                Title = "Exec Level : "..identityNumber,
                Color = Color3.fromHex("#808080"),
                Radius = 10,
            })
        end
    end
end)

WindUI:SetLanguage("cn")

local PlayerSection = Window:Section({
    Title = "loc:PLAYER_AND_MAP",
    Opened = true
})

local CombatSection = Window:Section({
    Title = "loc:COMBAT",
    Opened = true
})

local ServerSection = Window:Section({
    Title = "loc:SERVER",
    Opened = true
})

local EntertainmentSection = Window:Section({
    Title = "loc:ENTERTAINMENT",
    Opened = true
})

local PlayerTab = PlayerSection:Tab({Title = "loc:PLAYER", Icon = ""})
local FlyTab = PlayerSection:Tab({Title = "loc:FLY", Icon = ""})
local SelectTab = PlayerSection:Tab({Title = "loc:SELECT", Icon = ""})
local OtherTab = PlayerSection:Tab({Title = "loc:OTHER", Icon = ""})
local MapTab = PlayerSection:Tab({Title = "loc:MAP", Icon = ""})
local TeleportTab = PlayerSection:Tab({Title = "loc:TELEPORT", Icon = ""})
local AimbotTab = CombatSection:Tab({Title = "loc:AIMBOT", Icon = ""})
local ESPTab = CombatSection:Tab({Title = "loc:ESP", Icon = ""})
local BulletTab = CombatSection:Tab({Title = "loc:SILENT_AIM", Icon = ""})
local HitboxTab = CombatSection:Tab({Title = "loc:HITBOX", Icon = ""})
local ServerTab = ServerSection:Tab({Title = "loc:SERVER", Icon = ""})
local EmoteTab = EntertainmentSection:Tab({Title = "loc:EMOTE", Icon = ""})

speed = 0

PlayerTab:Slider({
    Title = "loc:WALK_SPEED",
    Value = {
        Min = 16,
        Max = 1000,
        Default = 16,
    },
    Callback = function(value)
        speed = value
    end
})

PlayerTab:Toggle({
    Title = "loc:ENABLE_WALKSPEED",
    Value = false,
    Callback = function(v)
        if v then
            sd = game:GetService("RunService").Heartbeat:Connect(function()
                if Character and Humanoid then
                    if Humanoid.MoveDirection.Magnitude > 0 then
                        Character:TranslateBy(Humanoid.MoveDirection * speed / 20)
                    end
                end
            end)
        elseif sd then
            sd:Disconnect()
            sd = nil
        end
    end
})

PlayerTab:Toggle({
    Title = "loc:WALKFLING",
    Value = false,
    Callback = function(v)
        local hiddenfling = v
        local flingConnection
        if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
            local detection = Instance.new("Decal")
            detection.Name = "juisdfj0i32i0eidsuf0iok"
            detection.Parent = ReplicatedStorage
        end
        hiddenfling = v
        if hiddenfling then
            if HumanoidRootPart then
                local originalVelocity = Vector3.new(0, 0, 0)
                local moveDirection = 0.1
                
                flingConnection = RunService.Heartbeat:Connect(function()
                    if not hiddenfling then
                        flingConnection:Disconnect()
                        return
                    end
                    if HumanoidRootPart then
                        originalVelocity = HumanoidRootPart.Velocity
                        HumanoidRootPart.Velocity = originalVelocity * 10000 + Vector3.new(0, 10000, 0)
                        RunService.RenderStepped:Wait()
                        HumanoidRootPart.Velocity = originalVelocity
                        RunService.Stepped:Wait()
                        HumanoidRootPart.Velocity = originalVelocity + Vector3.new(0, moveDirection, 0)
                        moveDirection = -moveDirection
                    end
                end)
            end
        else
            hiddenfling = false
            if flingConnection then
                flingConnection:Disconnect()
                flingConnection = nil
            end
        end

        Players.PlayerRemoving:Connect(function(v)
            if v == Players.LocalPlayer then
                hiddenfling = false
                if flingConnection then
                    flingConnection:Disconnect()
                    flingConnection = nil
                end
            end
        end)
    end
})

PlayerTab:Toggle({
    Title = "loc:ANTIFLING",
    Value = false,
    Callback = function(v)
        local maxVelocityChange = 50
        local Enabled = state
        local lastVelocity = Vector3.new(0, 0, 0)
        local lastSafePosition = Vector3.new(0, 5, 0)
    
        while Enabled and wait() do
            if HumanoidRootPart and Humanoid then
                local currentVelocity = HumanoidRootPart.Velocity
                local velocityChange = (currentVelocity - lastVelocity).Magnitude
    
                if velocityChange > maxVelocityChange then
                    local antiFlingBP = Instance.new("BodyPosition", HumanoidRootPart)
                    antiFlingBP.Position = lastSafePosition
                    antiFlingBP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    antiFlingBP.P = 10000
                    
                    wait(0.1)
                    
                    antiFlingBP:Destroy()
                else
                    lastSafePosition = HumanoidRootPart.Position
                end
    
                lastVelocity = currentVelocity
            end
        end
    end
})

PlayerTab:Slider({
    Title = "loc:JUMP_POWER",
    Value = {
        Min = 50,
        Max = 200,
        Default = 50,
    },
    Callback = function(value)
        Humanoid.JumpPower = value
    end
})

PlayerTab:Input({
    Title = "loc:CUSTOM_GRAVITY",
    Callback = function(value)
        workspace.Gravity = tonumber(value) or 196.5
    end
})

local infjump = false

PlayerTab:Toggle({
    Title = "loc:INFINITE_JUMP",
    Image = "",
    Value = false,
    Callback = function(state)
        infjump = state
        UserInputService.JumpRequest:Connect(function()
            if infjump and LocalPlayer.Character then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
})

PlayerTab:Toggle({
    Title = "loc:NO_CLIP",
    Image = "",
    Value = false,
    Callback = function(state)
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not state
                end
            end
        end
    end
})

FlyTab:Toggle({
    Title = "loc:MOBILE_FLY",
    Image = "",
    Value = false,
    Callback = function(state)
        if state then
            mobilefly(FlyTable.mobile.Speed)
        else
            unmobilefly()
        end
    end
})

FlyTab:Toggle({
    Title = "loc:PC_FLY",
    Image = "",
    Value = false,
    Callback = function(state)
        toggleFly(state)
    end
})

FlyTab:Toggle({
    Title = "loc:VEHICLE_FLY",
    Image = "",
    Value = false,
    Callback = function(state)
        FlyTable.vfly.Enabled = state
        if state then
            enableVfly()
        else
            disableVfly()
        end
    end
})

FlyTab:Slider({
    Title = "loc:MOBILE_FLY_SPEED",
    Value = {
        Min = 50,
        Max = 1000,
        Default = 50,
    },
    Callback = function(value)
        FlyTable.mobile.Speed = tonumber(value) or 300
    end
})

FlyTab:Slider({
    Title = "loc:PC_FLY_SPEED",
    Value = {
        Min = 50,
        Max = 200,
        Default = 50,
    },
    Callback = function(value)
        setFlySpeed(tonumber(value) or 50)
    end
})

FlyTab:Slider({
    Title = "loc:VEHICLE_FLY_SPEED",
    Value = {
        Min = 50,
        Max = 200,
        Default = 50,
    },
    Callback = function(value)
        FlyTable.vfly.Speed = tonumber(value) or 50
    end
})

local MainOtherSection = OtherTab:Section({ 
    Title = "loc:MAIN",
})

autoprox = false

MainOtherSection:Toggle({
    Title = "loc:AUTO_INTERACT",
    Value = false,
    Callback = function(v)
    autoprox = state
        spawn(function()
            while autoprox and wait() do
                pcall(function()
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            fireproximityprompt(v)
                        end
                    end
                end)
            end
        end)
    end
})

MainOtherSection:Toggle({
    Title = "loc:CHAT_VISIBILITY",
    Value = false,
    Callback = function(v)
        game:GetService("TextChatService").ChatWindowConfiguration.Enabled = v
        game:GetService("TextChatService").ChatWindowConfiguration:GetPropertyChangedSignal("Enabled"):Connect(function()
            if v then
                game:GetService("TextChatService").ChatWindowConfiguration.Enabled = v
            end
        end)
    end
})

CameraNoclip = false

MainOtherSection:Toggle({
    Title = "loc:CAMERA_NOCLIP",
    Value = false,
    Callback = function(v)
        CameraNoclip = v
        for _, func in pairs(getgc()) do
            if type(func) == 'function' and getfenv(func).script == LocalPlayer.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper then
                for i, constant in pairs(debug.getconstants(func)) do
                    if tonumber(constant) == 0.25 then
                        debug.setconstant(func, i, 0)
                    elseif tonumber(constant) == 0 then
                        debug.setconstant(func, i, 0.25)
                    end
                end
            end
        end
    end
})

FloatToggle = false

MainOtherSection:Toggle({
    Title = "loc:AIR_WALK",
    Value = false,
    Callback = function(state)
        FloatToggle = state
        if FloatToggle then
            if Character and not Character:FindFirstChild("Float_Part") then
                task.spawn(function()
                    local Float = Instance.new('Part')
                    Float.Name = "Float_Part"
                    Float.Parent = Character
                    Float.Transparency = 1
                    Float.Size = Vector3.new(2, 0.2, 1.5)
                    Float.Anchored = true
                    local FloatValue = -3.1
                    Float.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, FloatValue, 0)
                    local qUp, eUp, qDown, eDown, floatDied, FloatingFunc
                    
                    qUp = LocalPlayer:GetMouse().KeyUp:Connect(function(KEY)
                        if KEY == 'q' then
                            FloatValue = FloatValue + 0.5
                        end
                    end)
                    
                    eUp = LocalPlayer:GetMouse().KeyUp:Connect(function(KEY)
                        if KEY == 'e' then
                            FloatValue = FloatValue - 1.5
                        end
                    end)
                    
                    qDown = LocalPlayer:GetMouse().KeyDown:Connect(function(KEY)
                        if KEY == 'q' then
                            FloatValue = FloatValue - 0.5
                        end
                    end)
                    
                    eDown = LocalPlayer:GetMouse().KeyDown:Connect(function(KEY)
                        if KEY == 'e' then
                            FloatValue = FloatValue + 1.5
                        end
                    end)
                    
                    floatDied = Humanoid.Died:Connect(function()
                        if FloatingFunc then FloatingFunc:Disconnect() end
                        Float:Destroy()
                        if qUp then qUp:Disconnect() end
                        if eUp then eUp:Disconnect() end
                        if qDown then qDown:Disconnect() end
                        if eDown then eDown:Disconnect() end
                        if floatDied then floatDied:Disconnect() end
                    end)
                    
                    local function FloatPadLoop()
                        if Character and Character:FindFirstChild("Float_Part") and HumanoidRootPart then
                            Float.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, FloatValue, 0)
                        else
                            if FloatingFunc then FloatingFunc:Disconnect() end
                            if Float then Float:Destroy() end
                            if qUp then qUp:Disconnect() end
                            if eUp then eUp:Disconnect() end
                            if qDown then qDown:Disconnect() end
                            if eDown then eDown:Disconnect() end
                            if floatDied then floatDied:Disconnect() end
                        end
                    end
                    
                    FloatingFunc = RunService.Heartbeat:Connect(FloatPadLoop)
                end)
            end
        else
            Character:FindFirstChild("Float_Part"):Destroy()
        	if pchar:FindFirstChild("Float_Part") then
        		pchar:FindFirstChild("Float_Part"):Destroy()
        	end
        	if floatDied then
        		FloatingFunc:Disconnect()
        		qUp:Disconnect()
        		eUp:Disconnect()
        		qDown:Disconnect()
        		eDown:Disconnect()
        		floatDied:Disconnect()
        	end
        end
    end
})

MainOtherSection:Toggle({
    Title = "loc:INSTANT_INTERACT",
    Value = false,
    Callback = function(state)
        game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
            if state then
                fireproximityprompt(prompt)
            end
        end)
    end
})

MainOtherSection:Dropdown({
    Title = "loc:CAMERA_MODE",
    Values = {"LockFirstPerson", "Classic"},
    Value = "",
    Callback = function(value)
        LocalPlayer.CameraMode = value
    end
})

MainOtherSection:Toggle({
    Title = "loc:RESPAWN_IN_PLACE",
    Value = false,
    Callback = function(state)
        if Character then
            if Humanoid then
                if Humanoid._respawnConnection then
                    Humanoid._respawnConnection:Disconnect()
                    Humanoid._respawnConnection = nil
                end
                if state then
                    Humanoid._respawnConnection = Humanoid.Died:Connect(function()
                        local lastCFrame = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame
                        if lastCFrame then
                            LocalPlayer.CharacterAdded:Wait()
                            task.wait(0.5)
                            local newRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if newRootPart then
                                newRootPart.CFrame = lastCFrame
                            end
                        end
                    end)
                end
            end
        end
    end
})


local ToolSection = OtherTab:Section({ 
    Title = "loc:TOOLS",
})

ToolSection:Button({
    Title = "loc:GET_TELEPORT_TOOL",
    Callback = function()
    	local TpTool = Instance.new("Tool")
    	TpTool.Name = "Teleport Tool(传送工具)"
    	TpTool.RequiresHandle = false
    	TpTool.Parent = LocalPlayer:FindFirstChildOfClass("Backpack")
    	TpTool.Activated:Connect(function()
    		HumanoidRootPart.CFrame = CFrame.new(LocalPlayer:GetMouse().Hit.X, LocalPlayer:GetMouse().Hit.Y + 3, LocalPlayer:GetMouse().Hit.Z, select(4, HumanoidRootPart.CFrame:components()))
    	end)
    end
})

ToolSection:Button({
    Title = "loc:STEAL_TOOLS",
    Callback = function()
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer then
                local tb = v:FindFirstChildOfClass("Backpack")
                if tb then
                    for _, b in ipairs(tb:GetChildren()) do
                        if b:IsA("Tool") then
                            local mb = LocalPlayer:FindFirstChildOfClass("Backpack")
                            if mb and not mb:FindFirstChild(b.Name) then
                                b.Parent = mb
                            end
                        end
                    end
                end
            end
        end
    end
})

ToolSection:Input({
    Title = "loc:TELEPORT_ITEM_DISTANCE",
    Callback = function(value)
        if value and tonumber(value) then
            local distance = tonumber(value) or 5
            local TpTool = Instance.new("Tool")
            TpTool.Name = tonumber(value) or ""
            TpTool.RequiresHandle = false
            TpTool.Parent = LocalPlayer:FindFirstChildOfClass("Backpack")
            
            TpTool.Activated:Connect(function()
                if not Character or not HumanoidRootPart then return end
                
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {Character}
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                
                local rayOrigin = HumanoidRootPart.Position
                local rayDirection = HumanoidRootPart.CFrame.LookVector * distance
                local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                
                local tagpos
                if raycastResult then
                    tagpos = raycastResult.Position - (HumanoidRootPart.CFrame.LookVector * 2)
                else
                    tagpos = rayOrigin + rayDirection
                end
                
                local _, gropos = workspace:FindPartOnRay(
                    Ray.new(
                        tagpos + Vector3.new(0, 3, 0),
                        Vector3.new(0, -6, 0)
                    ),
                    Character
                )
                
                if gropos then
                    tagpos = Vector3.new(
                        tagpos.X,
                        gropos.Y + HumanoidRootPart.Size.Y/2,
                        tagpos.Z
                    )
                end
                
                HumanoidRootPart.CFrame = CFrame.new(
                    tagpos,
                    tagpos + HumanoidRootPart.CFrame.LookVector
                )
            end)
        end
    end
})

MapTab:Toggle({
    Title = "loc:X_RAY",
    Image = "",
    Value = false,
    Callback = function(state)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
                v.LocalTransparencyModifier = state and 0.5 or 0
            end
        end
    end
})

MapTab:Toggle({
    Title = "loc:FULL_BRIGHT",
    Image = "",
    Value = false,
    Callback = function(state)
        Lighting.Ambient = state and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
    end
})

MapTab:Toggle({
    Title = "loc:NO_SHADOW",
    Image = "",
    Value = false,
    Callback = function(state)
        Lighting.GlobalShadows = not state and true or false
    end
})

local CustomTeleport = TeleportTab:Section({ 
    Title = "loc:CUSTOM_TELEPORT",
})
local PlayerTeleport = TeleportTab:Section({ 
    Title = "loc:TELEPORT_PLAYER",
})

local TeleportDropDown = CustomTeleport:Dropdown({
    Title = "loc:SELECT_LOCATION",
    Values = {},
    Value = "",
    Callback = function(value)
        TeleportTable.select = value
    end
})

local save = CustomTeleport:Paragraph({
    Title = "loc:SAVE_LOCATIONS",
    Desc = "loc:NO_SAVED",
    Color = "White"
})

task.spawn(function()
    while wait() do
        pcall(function()
            if #TeleportTable.names == 0 then
                return
            else
                local descText = ""
                for i, name in ipairs(TeleportTable.names) do
                    descText = descText .. i .. ". " .. name .. "\n"
                end
                save:SetDesc(descText)
            end
        end)
    end
end)

local locationname = ""

CustomTeleport:Input({
    Title = "loc:LOCATION_NAME",
    Callback = function(value)
        locationname = value
    end
})

CustomTeleport:Button({
    Title = "loc:SAVE_CURRENT",
    Callback = function()
        if locationname == "" then
            locationname = "Nameless" .. (#TeleportTable.location + 1)
        end
        table.insert(TeleportTable.location, HumanoidRootPart.CFrame)
        table.insert(TeleportTable.names, locationname)
        TeleportDropDown:Refresh(TeleportTable.names)
        locationname = ""
    end
})

CustomTeleport:Button({
    Title = "loc:DELETE_SELECTED",
    Callback = function()
        if TeleportTable.select ~= "" then
            local index = table.find(TeleportTable.names, TeleportTable.select)
            if index then
                table.remove(TeleportTable.location, index)
                table.remove(TeleportTable.names, index)
                TeleportDropDown:Refresh(TeleportTable.names)
            end
        end
    end
})

CustomTeleport:Button({
    Title = "loc:TELEPORT_TO",
    Callback = function()
        if TeleportTable.select ~= "" then
            local index = table.find(TeleportTable.names, TeleportTable.select)
            if index and TeleportTable.location[index] then
                HumanoidRootPart.CFrame = TeleportTable.location[index]
            end
        end
    end
})

local SelectPlayerList = PlayerTeleport:Dropdown({
    Title = "loc:SELECT_PLAYER",
    Values = PlayerTable.list,
    Value = "",
    Callback = function(value)
        PlayerTable.select = value 
    end
})

Players.PlayerAdded:Connect(function()
    PlayerTable.list = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            table.insert(PlayerTable.list, v.Name)
        end
    end
    SelectPlayerList:Refresh(PlayerTable.list)
end)

Players.PlayerRemoving:Connect(function()
    PlayerTable.list = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            table.insert(PlayerTable.list, v.Name)
        end
    end
    SelectPlayerList:Refresh(PlayerTable.list)
end)

PlayerTeleport:Dropdown({
    Title = "loc:SELECT_DIRECTION",
    Values = {
        "Front(前面)",
        "Back(后面)",
        "Left(左面)",
        "Right(右面)",
        "Up(上面)",
        "Down(下面)"
    },
    Value = "",
    Callback = function(value)
        PlayerTable.selectmethod = value 
    end
})

PlayerTeleport:Button({
    Title = "loc:TELEPORT",
    Desc = "loc:TELEPORT_PLAYER",
    Callback = function()
        if PlayerTable.select == "" or PlayerTable.selectmethod == "" then
            return
        end
        if not Players:FindFirstChild(PlayerTable.select) or not Players:FindFirstChild(PlayerTable.select).Character then return end
        if not Players:FindFirstChild(PlayerTable.select).Character:FindFirstChild("HumanoidRootPart") then return end
        local offset = Vector3.new(0, 0, 0)
        if PlayerTable.selectmethod == "Front(前面)" then
            offset = Vector3.new(0, 0, -PlayerTable.distance)
        elseif PlayerTable.selectmethod == "Back(后面)" then
            offset = Vector3.new(0, 0, PlayerTable.distance)
        elseif PlayerTable.selectmethod == "Left(左面)" then
            offset = Vector3.new(-PlayerTable.distance, 0, 0)
        elseif PlayerTable.selectmethod == "Right(右面)" then
            offset = Vector3.new(PlayerTable.distance, 0, 0)
        elseif PlayerTable.selectmethod == "Up(上面)" then
            offset = Vector3.new(0, PlayerTable.distance, 0)
        elseif PlayerTable.selectmethod == "Down(下面)" then
            offset = Vector3.new(0, -PlayerTable.distance, 0)
        end
        HumanoidRootPart.CFrame = Players:FindFirstChild(PlayerTable.select).Character.HumanoidRootPart.CFrame + offset
    end
})

PlayerTeleport:Toggle({
    Title = "loc:LOOP_TELEPORT",
    Image = "",
    Value = false,
    Callback = function(state)
        PlayerTable.loop = state
        while PlayerTable.loop and wait() do
            if PlayerTable.select == "" or PlayerTable.selectmethod == "" then
                return
            end
            
            if not Players:FindFirstChild(PlayerTable.select) or not Players:FindFirstChild(PlayerTable.select).Character then return end
            if not Players:FindFirstChild(PlayerTable.select).Character:FindFirstChild("HumanoidRootPart") then return end
            local offset = Vector3.new(0, 0, 0)
            if PlayerTable.selectmethod == "Front(前面)" then
                offset = Vector3.new(0, 0, -PlayerTable.distance)
            elseif PlayerTable.selectmethod == "Back(后面)" then
                offset = Vector3.new(0, 0, PlayerTable.distance)
            elseif PlayerTable.selectmethod == "Left(左面)" then
                offset = Vector3.new(-PlayerTable.distance, 0, 0)
            elseif PlayerTable.selectmethod == "Right(右面)" then
                offset = Vector3.new(PlayerTable.distance, 0, 0)
            elseif PlayerTable.selectmethod == "Up(上面)" then
                offset = Vector3.new(0, PlayerTable.distance, 0)
            elseif PlayerTable.selectmethod == "Down(下面)" then
                offset = Vector3.new(0, -PlayerTable.distance, 0)
            end
            HumanoidRootPart.Anchored = PlayerTable.loop
            HumanoidRootPart.CFrame = Players:FindFirstChild(PlayerTable.select).Character.HumanoidRootPart.CFrame + offset
        end
    end
})

PlayerTeleport:Slider({
    Title = "loc:TELEPORT_DISTANCE",
    Value = {
        Min = 0,
        Max = 50,
        Default = 16,
    },
    Callback = function(value)
        PlayerTable.distance = value
    end
})

AimbotTab:Toggle({
    Title = "loc:AIMBOT",
    Image = "bird",
    Value = AimbotTable.Enabled,
    Callback = function(state)
        AimbotTable.Enabled = state
        if AimbotTable.Enabled then
            RunService.RenderStepped:Connect(function()
                local Character = LocalPlayer.Character
                if not Character then return end
                
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                if not HumanoidRootPart then return end
                
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if not Humanoid then return end
                
                if not AimbotTable.Enabled then return end

                local closestTarget = nil
                local closestDistance = math.huge
                
                if AimbotTable.TargetType == "Player" then
                    for _, v in ipairs(Players:GetPlayers()) do
                        if v == LocalPlayer then continue end
                        if AimbotTable.FriendCheck and LocalPlayer:IsFriendsWith(v.UserId) then continue end
                        if AimbotTable.TeamCheck and v.Team == LocalPlayer.Team then continue end
                        
                        local targetCharacter = v.Character
                        if not targetCharacter then continue end
                        
                        if AimbotTable.AliveCheck then
                            local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                            if not targetHumanoid or targetHumanoid.Health <= 0 then continue end
                        end
                        
                        local targetPart = targetCharacter:FindFirstChild(AimbotTable.TargetPart)
                        if not targetPart then continue end
                        
                        if AimbotTable.WallCheck then
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterDescendantsInstances = {Character, targetCharacter}
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            
                            local raycastResult = workspace:Raycast(HumanoidRootPart.Position, (targetPart.Position - HumanoidRootPart.Position).Unit * 1000, raycastParams)
                            if raycastResult and raycastResult.Instance ~= targetPart then continue end
                        end
                        
                        local distance = (targetPart.Position - HumanoidRootPart.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestTarget = targetPart
                        end
                    end
                else
                    for _, npc in ipairs(workspace:GetDescendants()) do
                        if npc:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(npc) then
                            local targetCharacter = npc
                            local targetPart = targetCharacter:FindFirstChild(AimbotTable.TargetPart)
                            if not targetPart then continue end
                            
                            if AimbotTable.WallCheck then
                                local raycastParams = RaycastParams.new()
                                raycastParams.FilterDescendantsInstances = {Character, targetCharacter}
                                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                
                                local raycastResult = workspace:Raycast(HumanoidRootPart.Position, (targetPart.Position - HumanoidRootPart.Position).Unit * 1000, raycastParams)
                                if raycastResult and raycastResult.Instance ~= targetPart then continue end
                            end
                            
                            local distance = (targetPart.Position - HumanoidRootPart.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestTarget = targetPart
                            end
                        end
                    end
                end
                
                if closestTarget then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
                end
            end)
        end
    end
})

AimbotTab:Dropdown({
    Title = "loc:AIMBOT_TARGET_PART",
    Values = {"Head", "HumanoidRootPart"},
    Value = "No Select",
    Callback = function(value)
        AimbotTable.TargetPart = value
    end
})

AimbotTab:Dropdown({
    Title = "loc:AIMBOT_TARGET_TYPE",
    Values = {"NPC", "Player"},
    Value = "No Select",
    Callback = function(value)
        AimbotTable.TargetType = value
    end
})

AimbotTab:Toggle({
    Title = "loc:FRIEND_CHECK",
    Image = "bird",
    Value = AimbotTable.FriendCheck,
    Callback = function(state)
        AimbotTable.FriendCheck = state
    end
})

AimbotTab:Toggle({
    Title = "loc:TEAM_CHECK",
    Image = "bird",
    Value = AimbotTable.TeamCheck,
    Callback = function(state)
        AimbotTable.TeamCheck = state
    end
})

AimbotTab:Toggle({
    Title = "loc:WALL_CHECK",
    Image = "bird",
    Value = AimbotTable.WallCheck,
    Callback = function(state)
        AimbotTable.WallCheck = state
    end
})

AimbotTab:Toggle({
    Title = "loc:ALIVE_CHECK",
    Image = "bird",
    Value = AimbotTable.AliveCheck,
    Callback = function(state)
        AimbotTable.AliveCheck = state
    end
})

ESPTab:Toggle({
    Title = "loc:NPC_ESP",
    Default = false,
    Callback = function(state)
        getgenv().ShowNPC = state
        if getgenv().ShowNPC then
            for _, v in next, workspace:GetChildren() do
                if (v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Head")) and not Players:GetPlayerFromCharacter(v) then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = v.Name
                    billboard.Adornee = v
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.AlwaysOnTop = true
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.Parent = CoreGui.ESPHolder
                    
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.TextColor3 = Color3.new(1, 0, 0)
                    text.TextStrokeTransparency = 0.5
                    text.TextScaled = true
                    text.Text = v.Name
                    text.Parent = billboard
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Name = v.Name .. "Highlight"
                    highlight.Adornee = v
                    highlight.FillColor = Color3.new(1, 0, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = v
                else
                    if CoreGui.ESPHolder:FindFirstChild(v.Name) then
                        CoreGui.ESPHolder:FindFirstChild(v.Name):Destroy()
                    end
                    if v:FindFirstChild(v.Name .. "Highlight") then
                        v:FindFirstChild(v.Name .. "Highlight"):Destroy()
                    end
                end
            end
        end
        workspace.DescendantAdded:Connect(function(v)
            if getgenv().ShowNPC and (v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Head")) and not Players:GetPlayerFromCharacter(v) then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = v.Name
                billboard.Adornee = v
                billboard.Size = UDim2.new(0, 100, 0, 40)
                billboard.AlwaysOnTop = true
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.Parent = CoreGui.ESPHolder
                
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.new(1, 0, 0)
                text.TextStrokeTransparency = 0.5
                text.TextScaled = true
                text.Text = v.Name
                text.Parent = billboard
                
                local highlight = Instance.new("Highlight")
                highlight.Name = v.Name .. "Highlight"
                highlight.Adornee = v
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.5
                highlight.Parent = v
            end
        end)
    end
})
ESPTab:Toggle({
     Title = "loc:SHOW_BOX",
     Default = false,
     Callback = function(state)
        getgenv().ShowBox = state
    end
})
ESPTab:Toggle({
     Title = "loc:SHOW_HEALTH",
     Default = false,
     Callback = function(state)
        getgenv().ShowHealth = state
    end
})
ESPTab:Toggle({
     Title = "loc:SHOW_NAME",
     Default = false,
     Callback = function(state)
        getgenv().ShowName = state
    end
})
ESPTab:Toggle({
     Title = "loc:SHOW_DISTANCE",
     Default = false,
     Callback = function(state)
        getgenv().ShowDistance = state
    end
})
ESPTab:Toggle({
     Title = "loc:SHOW_TRACER",
     Default = false,
     Callback = function(state)
        getgenv().ShowTracer = state
    end
})
ESPTab:Toggle({
     Title = "loc:TEAM_CHECK",
     Default = false,
     Callback = function(state)
        getgenv().TeamCheck = state
    end
})
ESPTab:Toggle({
     Title = "loc:FRIEND_CHECK",
     Default = false,
     Callback = function(state)
        getgenv().FriendCheck = state
    end
})
BulletTab:Toggle({
    Title = "loc:ENABLE_BULLET_TRACKING",
    Image = "bird",
    Value = false,
    Callback = function(state)
        SilentAim.enable = state
    end
})

BulletTab:Toggle({
    Title = "loc:TEAM_CHECK",
    Image = "bird",
    Value = false,
    Callback = function(state)
        SilentAim.teamcheck = state
    end
})

BulletTab:Toggle({
    Title = "loc:FRIEND_CHECK",
    Image = "bird",
    Value = false,
    Callback = function(state)
        SilentAim.friendcheck = state
    end
})

BulletTab:Toggle({
    Title = "loc:NPC_BULLET_TRACKING",
    Image = "bird",
    Value = false,
    Callback = function(state)
        SilentAim.enablenpc = state
    end
})

HitboxTab:Toggle({
    Title = "loc:ENABLE_HITBOX",
    Image = "bird",
    Value = HitboxTable.Enabled,
    Callback = function(state)
        HitboxTable.Enabled = state
        if state then
            HitboxTable.Loop = RunService.Heartbeat:Connect(function()
                if not HitboxTable.Enabled then return end
                
                local targets = {}
                if HitboxTable.Target == "Player" then
                    for _, v in ipairs(Players:GetPlayers()) do
                        if v ~= LocalPlayer then
                            if HitboxTable.FriendCheck and LocalPlayer:IsFriendsWith(v.UserId) then
                                continue
                            end
                            if HitboxTable.TeamCheck and v.Team == LocalPlayer.Team then
                                continue
                            end
                            
                            if v.Character then
                                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    table.insert(targets, hrp)
                                end
                            end
                        end
                    end
                else
                    for _, npc in ipairs(workspace:GetDescendants()) do
                        if npc:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(npc) then
                            table.insert(targets, npc.HumanoidRootPart)
                        end
                    end
                end
                
                for _, hrp in ipairs(targets) do
                    if not HitboxTable.OriginalSizes[hrp] then
                        HitboxTable.OriginalSizes[hrp] = {
                            Size = hrp.Size,
                            CanCollide = hrp.CanCollide
                        }
                    end
                    
                    local box = hrp:FindFirstChild("HitboxVisual")
                    if not box then
                        box = Instance.new("Part")
                        box.Name = "HitboxVisual"
                        box.Size = Vector3.new(HitboxTable.Size, HitboxTable.Size, HitboxTable.Size)
                        box.Transparency = 0.7
                        box.Color = HitboxTable.Color
                        box.Anchored = true
                        box.CanCollide = false
                        box.Parent = hrp
                    end
                    
                    box.Size = Vector3.new(HitboxTable.Size, HitboxTable.Size, HitboxTable.Size)
                    box.Position = hrp.Position
                    box.Color = HitboxTable.Color
                    
                    hrp.Size = Vector3.new(HitboxTable.Size, HitboxTable.Size, HitboxTable.Size)
                    hrp.CanCollide = HitboxTable.CanCollideEnabled
                end
            end)
        else
            if HitboxTable.Loop then
                HitboxTable.Loop:Disconnect()
            end
            for hrp, data in pairs(HitboxTable.OriginalSizes) do
                if hrp and hrp.Parent then
                    hrp.Size = data.Size
                    hrp.CanCollide = data.CanCollide
                    local box = hrp:FindFirstChild("HitboxVisual")
                    if box then
                        box:Destroy()
                    end
                end
            end
            HitboxTable.OriginalSizes = {}
        end
    end
})

HitboxTab:Toggle({
    Title = "loc:COLLISION_ENABLED",
    Value = HitboxTable.CanCollideEnabled,
    Callback = function(state)
        HitboxTable.CanCollideEnabled = state
    end
})

HitboxTab:Input({
    Title = "loc:HITBOX_SIZE",
    Callback = function(value)
        HitboxTable.Size = tonumber(value) or 5
    end
})

HitboxTab:Dropdown({
    Title = "loc:HITBOX_COLOR",
    Values = HitboxTable.ColorOptions,
    Value = "红色",
    Callback = function(value)
        HitboxTable.Color = HitboxTable.ColorMap[value] or Color3.new(1, 0, 0)
    end
})

HitboxTab:Dropdown({
    Title = "loc:TARGET",
    Values = {"NPC", "Player"},
    Value = HitboxTable.Target,
    Callback = function(value)
        HitboxTable.Target = value
    end
})

HitboxTab:Toggle({
    Title = "loc:FRIEND_CHECK",
    Image = "bird",
    Value = HitboxTable.FriendCheck,
    Callback = function(state)
        HitboxTable.FriendCheck = state
    end
})

HitboxTab:Toggle({
    Title = "loc:TEAM_CHECK",
    Image = "bird",
    Value = HitboxTable.TeamCheck,
    Callback = function(state)
        HitboxTable.TeamCheck = state
    end
})


ServerTab:Button({
    Title = "loc:COPY_SERVER_CODE",
    Callback = function()
        setclipboard("game:GetService('TeleportService'):TeleportToPlaceInstance(" .. game.PlaceId .. ", '" .. game.JobId .. "', game:GetService('Players').LocalPlayer)")
    end
})

ServerTab:Button({
    Title = "loc:REJOIN_SERVER",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
    end
})

ServerTab:Button({
    Title = "loc:JOIN_LOW_POP_SERVER",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        
        local _place = game.PlaceId
        local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
        function ListServers(cursor)
           local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
           return Http:JSONDecode(Raw)
        end
        
        local Server, Next; repeat
           local Servers = ListServers(Next)
           Server = Servers.data[1]
           Next = Servers.nextPageCursor
        until Server
        
        TPS:TeleportToPlaceInstance(_place,Server.id,game.Players.LocalPlayer)
    end
})

ServerTab:Button({
    Title = "loc:SERVER_HOP",
    Callback = function()
        local PlaceID = game.PlaceId
        local AllIDs = {}
        local foundAnything = ""
        local actualHour = os.date("!*t").hour
        local Deleted = false
        local File = pcall(function()
            AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
        end)
        if not File then
            table.insert(AllIDs, actualHour)
            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
        end
        function TPReturner()
            local Site;
            if foundAnything == "" then
                Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
            else
                Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
            end
            local ID = ""
            if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
                foundAnything = Site.nextPageCursor
            end
            local num = 0;
            for i,v in pairs(Site.data) do
                local Possible = true
                ID = tostring(v.id)
                if tonumber(v.maxPlayers) > tonumber(v.playing) then
                    for _,Existing in pairs(AllIDs) do
                        if num ~= 0 then
                            if ID == tostring(Existing) then
                                Possible = false
                            end
                        else
                            if tonumber(actualHour) ~= tonumber(Existing) then
                                local delFile = pcall(function()
                                    delfile("NotSameServers.json")
                                    AllIDs = {}
                                    table.insert(AllIDs, actualHour)
                                end)
                            end
                        end
                        num = num + 1
                    end
                    if Possible == true then
                        table.insert(AllIDs, ID)
                        wait()
                        pcall(function()
                            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                            wait()
                            game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                        end)
                        wait(4)
                    end
                end
            end
        end
        
        function Teleport()
            while wait() do
                pcall(function()
                    TPReturner()
                    if foundAnything ~= "" then
                        TPReturner()
                    end
                end)
            end
        end
        Teleport()
    end
})

local EmoteList = EmoteTab:Dropdown({
    Title = "loc:EMOTES",
    Values = {},
    Value = "",
    Callback = function(value)
        local data = EmoteList._emoteMap and EmoteList._emoteMap[value]
        if not data then return end

        local thumbUrl = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", data.id)
        Paragraph:SetThumbnail(thumbUrl)
        ShowEmote:SetDesc(string.format("Creator: %s", data.creator))
    end
})

local ShowEmote = EmoteTab:Paragraph({
    Title = "loc:EMOTE_PREVIEW",
    Desc = "Select an emote to view details",
    Thumbnail = "rbxthumb://type=Asset&id=000000000&w=150&h=150",
    ThumbnailSize = 130
})

EmoteTab:Button({
    Title = "loc:PLAY_EMOTE",
    Callback = function()
        local selectedName = EmoteList.Value
        local data = EmoteList._emoteMap and EmoteList._emoteMap[selectedName]

        if data and data.id then
            playEmote(data.id)
            WindUI:Notify({
                Title = "Emote (表情)",
                Content = string.format("Playing: %s (正在播放: %s)", data.name, data.name),
                Duration = 3,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = "Error (错误)",
                Content = "No emote selected (未选择表情)",
                Duration = 3,
                Icon = "error"
            })
        end
    end
})

WindUI:Notify({
    Title = "Loading (加载中)",
    Content = "Fetching all emotes... (正在获取所有表情...)",
    Duration = 3,
    Icon = "loading"
})

local ids = fetchEmoteIds()
if #ids > 0 then
    local emotes = fetchEmoteDetails(ids)
    if #emotes > 0 then
        local dropdownValues = {}
        local emoteMap = {}
        for _, emote in emotes do
            table.insert(dropdownValues, emote.name)
            emoteMap[emote.name] = emote
        end

        EmoteList:Refresh(dropdownValues)
        EmoteList._emoteMap = emoteMap
        
        WindUI:Notify({
            Title = "Success (成功)",
            Content = string.format("Loaded %d emotes (已加载 %d 个表情)", #emotes, #emotes),
            Duration = 3,
            Icon = "check"
        })
    end
end