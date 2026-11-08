LPH_INTRO(function()
    _G.ExecuteTime = tick()
    if _G.ExecuteCooldown then
        pcall(
            function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "h4xscripts", Text = "This script is already loading, please wait.", Duration = 5, }) end
        )
        return
    end
    _G.ExecuteCooldown = true

    local TweenService = game:GetService("TweenService")
    local SoundService = game:GetService("SoundService")
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://4590657391"
    sound.Volume = 10
    sound.Parent = workspace
    sound:Play()

    task.delay(10, function() sound:Destroy() end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FluentNotificationGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local targetParent = CoreGui
    pcall(function() if gethui then targetParent = gethui() end end)
    ScreenGui.Parent = targetParent

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local Frame = Instance.new("Frame")
    Frame.Name = "NotificationFrame"
    Frame.Size = isMobile and UDim2.new(0.9, 0, 0, 95) or UDim2.new(0, 380, 0, 90)
    Frame.Position = isMobile and UDim2.new(0.5, 0, 1, 50) or UDim2.new(1, 30, 1, -30)
    Frame.AnchorPoint = isMobile and Vector2.new(0.5, 1) or Vector2.new(1, 1)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 14, 15)
    Frame.BackgroundTransparency = 0.05
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Frame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(235, 60, 70)
    UIStroke.Transparency = 0.8
    UIStroke.Thickness = 1
    UIStroke.Parent = Frame

    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Size = UDim2.new(0, 4, 0, 46)
    AccentBar.Position = UDim2.new(0, 0, 0.5, 0)
    AccentBar.AnchorPoint = Vector2.new(0, 0.5)
    AccentBar.BackgroundColor3 = Color3.fromRGB(235, 60, 70)
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = Frame

    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 2)
    AccentCorner.Parent = AccentBar

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 16, 0, 16)
    Icon.Position = UDim2.new(0, 16, 0, 16)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://10723415903"
    Icon.ImageColor3 = Color3.fromRGB(235, 60, 70)
    Icon.Parent = Frame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -50, 0, 20)
    TitleLabel.Position = UDim2.new(0, 38, 0, 14)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.Text = "h4xscripts"
    TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Frame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "Text"
    TextLabel.Size = UDim2.new(1, -38, 0, 40)
    TextLabel.Position = UDim2.new(0, 16, 0, 38)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.Text = "Script is loading. The game might lag for 1-2min but after that it should be smooth"
    TextLabel.TextColor3 = Color3.fromRGB(175, 170, 172)
    TextLabel.TextSize = 12
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextYAlignment = Enum.TextYAlignment.Top
    TextLabel.Parent = Frame

    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local targetPos = isMobile and UDim2.new(0.5, 0, 1, -20) or UDim2.new(1, -20, 1, -20)
    TweenService:Create(Frame, tweenInfo, { Position = targetPos }):Play()

    task.delay(10, function()
        local hidePos = isMobile and UDim2.new(0.5, 0, 1, 50) or UDim2.new(1, 30, 1, -20)
        local hideTween = TweenService:Create(Frame, tweenInfo, { Position = hidePos })
        hideTween:Play()
        hideTween.Completed:Connect(function() ScreenGui:Destroy() end)
    end)

    task.delay(30, function() _G.ExecuteCooldown = nil end)
end)
