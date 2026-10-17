local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local aimEnabled = false
local espEnabled = false
local isAiming = false
local espObjects = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CurseurMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.new(0, 280, 0, 180)
MenuFrame.Position = UDim2.new(0.5, -140, 0.1, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MenuFrame.BorderSizePixel = 2
MenuFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MenuFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MenuFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.BorderSizePixel = 0
Title.Text = "AIMBOT & ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MenuFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 2.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = MenuFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

local AimButton = Instance.new("TextButton")
AimButton.Name = "AimButton"
AimButton.Size = UDim2.new(0, 240, 0, 40)
AimButton.Position = UDim2.new(0, 20, 0, 55)
AimButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
AimButton.BorderSizePixel = 0
AimButton.Text = "AIMBOT: OFF"
AimButton.TextColor3 = Color3.fromRGB(255, 100, 100)
AimButton.Font = Enum.Font.GothamBold
AimButton.TextSize = 16
AimButton.Parent = MenuFrame

local AimCorner = Instance.new("UICorner")
AimCorner.CornerRadius = UDim.new(0, 8)
AimCorner.Parent = AimButton

local ESPButton = Instance.new("TextButton")
ESPButton.Name = "ESPButton"
ESPButton.Size = UDim2.new(0, 240, 0, 40)
ESPButton.Position = UDim2.new(0, 20, 0, 105)
ESPButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ESPButton.BorderSizePixel = 0
ESPButton.Text = "ESP: OFF"
ESPButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ESPButton.Font = Enum.Font.GothamBold
ESPButton.TextSize = 16
ESPButton.Parent = MenuFrame

local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0, 8)
ESPCorner.Parent = ESPButton

local Instructions = Instance.new("TextLabel")
Instructions.Name = "Instructions"
Instructions.Size = UDim2.new(1, -20, 0, 20)
Instructions.Position = UDim2.new(0, 10, 0, 155)
Instructions.BackgroundTransparency = 1
Instructions.Text = "Right click for aimbot"
Instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
Instructions.Font = Enum.Font.Gotham
Instructions.TextSize = 11
Instructions.Parent = MenuFrame

CloseButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = false
end)

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if head and humanoid and humanoid.Health > 0 then
                local screenPoint = Camera:WorldToScreenPoint(head.Position)
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

local function createLine(partA, partB, parent)
    local attachment0 = Instance.new("Attachment")
    attachment0.Parent = partA
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = partB
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    beam.Width0 = 0.05
    beam.Width1 = 0.05
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Transparency = NumberSequence.new(0)
    beam.Parent = parent
    
    return {beam, attachment0, attachment1}
end

local function createESP(player)
    if espObjects[player] then return end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name
    espObjects[player] = espFolder
    
    local function updateESP()
        if not player.Character then return end
        
        for _, v in pairs(espFolder:GetChildren()) do
            v:Destroy()
        end
        
        local character = player.Character
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart then return end
        
        local head = character:FindFirstChild("Head")
        local upperTorso = character:FindFirstChild("UpperTorso")
        local lowerTorso = character:FindFirstChild("LowerTorso")
        local leftUpperArm = character:FindFirstChild("LeftUpperArm")
        local leftLowerArm = character:FindFirstChild("LeftLowerArm")
        local leftHand = character:FindFirstChild("LeftHand")
        local rightUpperArm = character:FindFirstChild("RightUpperArm")
        local rightLowerArm = character:FindFirstChild("RightLowerArm")
        local rightHand = character:FindFirstChild("RightHand")
        local leftUpperLeg = character:FindFirstChild("LeftUpperLeg")
        local leftLowerLeg = character:FindFirstChild("LeftLowerLeg")
        local leftFoot = character:FindFirstChild("LeftFoot")
        local rightUpperLeg = character:FindFirstChild("RightUpperLeg")
        local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
        local rightFoot = character:FindFirstChild("RightFoot")
        
        if head and upperTorso then createLine(head, upperTorso, espFolder) end
        if upperTorso and lowerTorso then createLine(upperTorso, lowerTorso, espFolder) end
        
        if upperTorso and leftUpperArm then createLine(upperTorso, leftUpperArm, espFolder) end
        if leftUpperArm and leftLowerArm then createLine(leftUpperArm, leftLowerArm, espFolder) end
        if leftLowerArm and leftHand then createLine(leftLowerArm, leftHand, espFolder) end
        
        if upperTorso and rightUpperArm then createLine(upperTorso, rightUpperArm, espFolder) end
        if rightUpperArm and rightLowerArm then createLine(rightUpperArm, rightLowerArm, espFolder) end
        if rightLowerArm and rightHand then createLine(rightLowerArm, rightHand, espFolder) end
        
        if lowerTorso and leftUpperLeg then createLine(lowerTorso, leftUpperLeg, espFolder) end
        if leftUpperLeg and leftLowerLeg then createLine(leftUpperLeg, leftLowerLeg, espFolder) end
        if leftLowerLeg and leftFoot then createLine(leftLowerLeg, leftFoot, espFolder) end
        
        if lowerTorso and rightUpperLeg then createLine(lowerTorso, rightUpperLeg, espFolder) end
        if rightUpperLeg and rightLowerLeg then createLine(rightUpperLeg, rightLowerLeg, espFolder) end
        if rightLowerLeg and rightFoot then createLine(rightLowerLeg, rightFoot, espFolder) end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = rootPart
        billboard.Size = UDim2.new(0, 50, 0, 100)
        billboard.StudsOffset = Vector3.new(-2.5, 0, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = espFolder
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(2, 0, 0, 20)
        nameLabel.Position = UDim2.new(-0.5, 0, 0, -25)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Parent = billboard
        
        local healthBarBG = Instance.new("Frame")
        healthBarBG.Size = UDim2.new(0, 4, 1, 0)
        healthBarBG.Position = UDim2.new(0, 0, 0, 0)
        healthBarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        healthBarBG.BorderSizePixel = 1
        healthBarBG.BorderColor3 = Color3.fromRGB(0, 0, 0)
        healthBarBG.Parent = billboard
        
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(1, 0, humanoid.Health / humanoid.MaxHealth, 0)
        healthBar.Position = UDim2.new(0, 0, 1, 0)
        healthBar.AnchorPoint = Vector2.new(0, 1)
        healthBar.BorderSizePixel = 0
        
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        if healthPercent > 0.5 then
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif healthPercent > 0.25 then
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        else
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        
        healthBar.Parent = healthBarBG
    end
    
    updateESP()
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if espEnabled and player.Character then
            updateESP()
        end
    end)
    
    espFolder.Parent = workspace
end

local function removeESP(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
end

local function removeAllESP()
    for player, _ in pairs(espObjects) do
        removeESP(player)
    end
end

local function updateAllESP()
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
    else
        removeAllESP()
    end
end

AimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    
    if aimEnabled then
        AimButton.Text = "AIMBOT: ON"
        AimButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        AimButton.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    else
        AimButton.Text = "AIMBOT: OFF"
        AimButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        AimButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        isAiming = false
    end
end)

ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    
    if espEnabled then
        ESPButton.Text = "ESP: ON"
        ESPButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        ESPButton.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    else
        ESPButton.Text = "ESP: OFF"
        ESPButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        ESPButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
    
    updateAllESP()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimEnabled then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if isAiming and aimEnabled then
        local target = getClosestPlayer()
        
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            
            if head then
                local headPosition = head.Position
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPosition)
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    if espEnabled and player ~= LocalPlayer then
        player.CharacterAdded:Wait()
        wait(0.5)
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

local dragging = false
local dragInput, mousePos, framePos

MenuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MenuFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - mousePos
        MenuFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
