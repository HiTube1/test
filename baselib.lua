-- Xeno Executor UI Library v4 (Hub Added, Auto-Scrolling, Animated & Dark Theme)
local Xeno = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Colors = {
    Background = Color3.fromRGB(15, 15, 15),
    Section = Color3.fromRGB(22, 22, 22),
    Hover = Color3.fromRGB(32, 32, 32),
    Click = Color3.fromRGB(45, 45, 45),
    Accent = Color3.fromRGB(65, 130, 220),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(140, 140, 140)
}

local function Create(class, properties)
    local inst = Instance.new(class)
    for k, v in pairs(properties or {}) do inst[k] = v end
    return inst
end

local function Tween(instance, properties, duration)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- Глобальный контейнер для уведомлений (чтобы окна делили его)
local globalNotifContainer

local function SetupNotifications(parentGui)
    if not globalNotifContainer then
        globalNotifContainer = Create("Frame", {
            Parent = parentGui, Size = UDim2.new(0, 250, 1, -20), Position = UDim2.new(1, -270, 0, 10),
            BackgroundTransparency = 1, ZIndex = 100
        })
        Create("UIListLayout", {Parent = globalNotifContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})
    end
end

function Xeno:Notify(opts)
    opts = opts or {}
    local title = opts.Title or "Уведомление"
    local text = opts.Content or ""
    local duration = opts.Duration or 3

    if not globalNotifContainer then return end

    local NotifFrame = Create("Frame", {
        Parent = globalNotifContainer, Size = UDim2.new(1, 50, 0, 60), BackgroundColor3 = Colors.Section, BackgroundTransparency = 1
    })
    Create("UICorner", {Parent = NotifFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = NotifFrame, Color = Colors.Accent, Thickness = 1, Transparency = 1})

    local NotifTitle = Create("TextLabel", {
        Parent = NotifFrame, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1, Text = title, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
    })
    local NotifText = Create("TextLabel", {
        Parent = NotifFrame, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 25),
        BackgroundTransparency = 1, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1
    })

    Tween(NotifFrame, {BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 60)}, 0.3)
    Tween(NotifFrame.UIStroke, {Transparency = 0}, 0.3)
    Tween(NotifTitle, {TextTransparency = 0}, 0.3)
    Tween(NotifText, {TextTransparency = 0}, 0.3)

    task.spawn(function()
        task.wait(duration)
        Tween(NotifFrame, {BackgroundTransparency = 1, Size = UDim2.new(1, 50, 0, 60)}, 0.3)
        Tween(NotifFrame.UIStroke, {Transparency = 1}, 0.3)
        Tween(NotifTitle, {TextTransparency = 1}, 0.3)
        Tween(NotifText, {TextTransparency = 1}, 0.3)
        task.wait(0.3)
        NotifFrame:Destroy()
    end)
end

-- ==========================================
-- ОСНОВНОЕ ОКНО С ВКЛАДКАМИ
-- ==========================================
function Xeno:CreateWindow(config)
    config = config or {}
    local TitleText = config.Name or "Xeno Executor"
    
    local XenoGui = Create("ScreenGui", {Name = "XenoLib", ResetOnSpawn = false})
    local parent = (getgenv and gethui) and gethui() or game:GetService("CoreGui")
    pcall(function() XenoGui.Parent = parent end)
    if not XenoGui.Parent then XenoGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    SetupNotifications(XenoGui)

    local MainFrame = Create("Frame", {
        Parent = XenoGui, Size = UDim2.new(0, 600, 0, 420), Position = UDim2.new(0.5, -300, 0.5, -210),
        BackgroundColor3 = Colors.Background, ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = MainFrame, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})
    
    local Topbar = Create("Frame", { Parent = MainFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 })
    local Title = Create("TextLabel", { Parent = Topbar, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = TitleText, TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left })
    
    local CloseBtn = Create("TextButton", { Parent = Topbar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5), BackgroundTransparency = 1, Text = "✕", TextColor3 = Colors.TextDark, TextSize = 16, Font = Enum.Font.GothamMedium })
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {TextColor3 = Color3.fromRGB(255, 80, 80)}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {TextColor3 = Colors.TextDark}) end)

    local MinBtn = Create("TextButton", { Parent = Topbar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -70, 0, 5), BackgroundTransparency = 1, Text = "−", TextColor3 = Colors.TextDark, TextSize = 22, Font = Enum.Font.GothamMedium })
    MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {TextColor3 = Colors.Text}) end)
    MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {TextColor3 = Colors.TextDark}) end)

    -- Автоскроллинг для Sidebar
    local Sidebar = Create("ScrollingFrame", {
        Parent = MainFrame, Size = UDim2.new(0, 150, 1, -40), Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", {Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder})
    
    local ContentContainer = Create("Frame", { Parent = MainFrame, Size = UDim2.new(1, -160, 1, -50), Position = UDim2.new(0, 160, 0, 40), BackgroundTransparency = 1 })

    -- Tooltip System
    local TooltipGui = Create("Frame", { Parent = XenoGui, Size = UDim2.new(0, 200, 0, 30), BackgroundColor3 = Colors.Background, Visible = false, ZIndex = 100, AutomaticSize = Enum.AutomaticSize.XY })
    Create("UICorner", {Parent = TooltipGui, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = TooltipGui, Color = Colors.Accent, Thickness = 1}); Create("UIPadding", {Parent = TooltipGui, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})
    local TooltipLabel = Create("TextLabel", { Parent = TooltipGui, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true })

    local hoverStart, isHovering, currentDesc, lastMousePos = 0, false, "", Vector2.new()
    RunService.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        if isHovering then
            if (mousePos - lastMousePos).Magnitude > 2 then TooltipGui.Visible = false
            elseif tick() - hoverStart >= 1.5 then
                TooltipGui.Visible = true; TooltipGui.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y + 15); TooltipLabel.Text = currentDesc
            end
        else TooltipGui.Visible = false end
    end)
    local function ApplyTooltip(element, desc)
        if not desc or desc == "" then return end
        element.MouseEnter:Connect(function() isHovering = true; hoverStart = tick(); currentDesc = desc; lastMousePos = UserInputService:GetMouseLocation() end)
        element.MouseLeave:Connect(function() isHovering = false; TooltipGui.Visible = false end)
    end

    local PromptOverlay = Create("Frame", { Parent = XenoGui, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, Visible = false, ZIndex = 50 })
    local PromptBox = Create("Frame", { Parent = PromptOverlay, Size = UDim2.new(0, 300, 0, 150), Position = UDim2.new(0.5, -150, 0.5, -50), BackgroundColor3 = Colors.Background, ZIndex = 51, BackgroundTransparency = 1 })
    Create("UICorner", {Parent = PromptBox, CornerRadius = UDim.new(0, 8)}); Create("UIStroke", {Parent = PromptBox, Color = Colors.Accent, Thickness = 1})
    local PromptText = Create("TextLabel", { Parent = PromptBox, Size = UDim2.new(1, -20, 1, -60), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextWrapped = true, ZIndex = 52, TextTransparency = 1 })
    local BtnYes = Create("TextButton", { Parent = PromptBox, Size = UDim2.new(0.4, 0, 0, 35), Position = UDim2.new(0.05, 0, 1, -45), BackgroundColor3 = Colors.Accent, Text = "Да", TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, ZIndex = 52, BackgroundTransparency = 1, TextTransparency = 1 })
    Create("UICorner", {Parent = BtnYes, CornerRadius = UDim.new(0, 4)}); local BtnNo = Create("TextButton", { Parent = PromptBox, Size = UDim2.new(0.4, 0, 0, 35), Position = UDim2.new(0.55, 0, 1, -45), BackgroundColor3 = Colors.Section, Text = "Нет", TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, ZIndex = 52, BackgroundTransparency = 1, TextTransparency = 1 })
    Create("UICorner", {Parent = BtnNo, CornerRadius = UDim.new(0, 4)})

    local windowObj = {}
    function windowObj:Prompt(text, callback)
        PromptText.Text = text; PromptOverlay.Visible = true; PromptBox.Position = UDim2.new(0.5, -150, 0.5, -50)
        Tween(PromptOverlay, {BackgroundTransparency = 0.6}); Tween(PromptBox, {BackgroundTransparency = 0, Position = UDim2.new(0.5, -150, 0.5, -75)})
        Tween(PromptText, {TextTransparency = 0}); Tween(BtnYes, {BackgroundTransparency = 0, TextTransparency = 0}); Tween(BtnNo, {BackgroundTransparency = 0, TextTransparency = 0})
        local yesConn, noConn
        local function closePrompt(res)
            yesConn:Disconnect(); noConn:Disconnect()
            Tween(PromptOverlay, {BackgroundTransparency = 1}); Tween(PromptBox, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -150, 0.5, -50)})
            Tween(PromptText, {TextTransparency = 1}); Tween(BtnYes, {BackgroundTransparency = 1, TextTransparency = 1}); Tween(BtnNo, {BackgroundTransparency = 1, TextTransparency = 1})
            task.wait(0.3); PromptOverlay.Visible = false
            if callback then callback(res) end
        end
        yesConn = BtnYes.MouseButton1Click:Connect(function() closePrompt(true) end)
        noConn = BtnNo.MouseButton1Click:Connect(function() closePrompt(false) end)
    end

    CloseBtn.MouseButton1Click:Connect(function()
        windowObj:Prompt("Вы уверены, что хотите закрыть интерфейс?", function(res) if res then XenoGui:Destroy() end end)
    end)

    local minimized = false
    local function ToggleUI() minimized = not minimized; MainFrame.Visible = not minimized end
    MinBtn.MouseButton1Click:Connect(ToggleUI)
    UserInputService.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.RightControl then ToggleUI() end end)

    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Tabs = {}
    local firstTab = true

    function windowObj:CreateTab(name, iconId)
        local TabBtn = Create("TextButton", { Parent = Sidebar, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = "  " .. name, TextColor3 = Colors.TextDark, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
        local Indicator = Create("Frame", { Parent = TabBtn, Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(1, -3, 0.2, 0), BackgroundColor3 = Colors.Accent, BackgroundTransparency = 1 })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1,0)})
        if iconId then
            Create("ImageLabel", { Parent = TabBtn, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 10, 0.5, -8), BackgroundTransparency = 1, Image = "rbxassetid://" .. tostring(iconId), ImageColor3 = Colors.TextDark })
            TabBtn.Text = "        " .. name
        end

        -- Автоскроллинг для контента вкладок
        local TabContent = Create("ScrollingFrame", {
            Parent = ContentContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = TabContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        Create("UIPadding", {Parent = TabContent, PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})

        table.insert(Tabs, {Btn = TabBtn, Content = TabContent, Indicator = Indicator})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Content.Visible = false; Tween(t.Btn, {TextColor3 = Colors.TextDark})
                if t.Btn:FindFirstChild("ImageLabel") then Tween(t.Btn.ImageLabel, {ImageColor3 = Colors.TextDark}) end
                Tween(t.Indicator, {BackgroundTransparency = 1})
            end
            TabContent.Visible = true; Tween(TabBtn, {TextColor3 = Colors.Text})
            if TabBtn:FindFirstChild("ImageLabel") then Tween(TabBtn.ImageLabel, {ImageColor3 = Colors.Accent}) end
            Tween(Indicator, {BackgroundTransparency = 0})
        end)

        if firstTab then
            TabContent.Visible = true; TabBtn.TextColor3 = Colors.Text
            if TabBtn:FindFirstChild("ImageLabel") then TabBtn.ImageLabel.ImageColor3 = Colors.Accent end
            Indicator.BackgroundTransparency = 0; firstTab = false
        end

        local tabObj = {}
        function tabObj:CreateSection(secName)
            Create("TextLabel", { Parent = TabContent, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = secName, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
        end

        function tabObj:CreateButton(opts)
            local BtnFrame = Create("TextButton", { Parent = TabContent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Section, Text = "", AutoButtonColor = false })
            Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 6)})
            Create("TextLabel", { Parent = BtnFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "  " .. opts.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
            ApplyTooltip(BtnFrame, opts.Description)
            BtnFrame.MouseEnter:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Colors.Hover}) end)
            BtnFrame.MouseLeave:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Colors.Section}) end)
            BtnFrame.MouseButton1Down:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Colors.Click}, 0.1) end)
            BtnFrame.MouseButton1Up:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Colors.Hover}, 0.1) end)
            BtnFrame.MouseButton1Click:Connect(function() pcall(opts.Callback) end)
        end

        function tabObj:CreateToggle(opts)
            local state = opts.CurrentValue or false
            local TogFrame = Create("TextButton", { Parent = TabContent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Section, Text = "", AutoButtonColor = false })
            Create("UICorner", {Parent = TogFrame, CornerRadius = UDim.new(0, 6)})
            Create("TextLabel", { Parent = TogFrame, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = opts.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
            ApplyTooltip(TogFrame, opts.Description)
            local CheckBox = Create("Frame", { Parent = TogFrame, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0.5, -10), BackgroundColor3 = state and Colors.Accent or Colors.Background })
            Create("UICorner", {Parent = CheckBox, CornerRadius = UDim.new(0, 4)}); local Stroke = Create("UIStroke", {Parent = CheckBox, Color = state and Colors.Accent or Colors.TextDark, Thickness = 1})
            local CheckIcon = Create("ImageLabel", { Parent = CheckBox, Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2), BackgroundTransparency = 1, Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(312, 4), ImageRectSize = Vector2.new(24, 24), ImageTransparency = state and 0 or 1, ImageColor3 = Colors.Background })

            TogFrame.MouseEnter:Connect(function() Tween(TogFrame, {BackgroundColor3 = Colors.Hover}) end)
            TogFrame.MouseLeave:Connect(function() Tween(TogFrame, {BackgroundColor3 = Colors.Section}) end)
            TogFrame.MouseButton1Click:Connect(function()
                state = not state
                Tween(CheckBox, {BackgroundColor3 = state and Colors.Accent or Colors.Background}, 0.15)
                Tween(Stroke, {Color = state and Colors.Accent or Colors.TextDark}, 0.15)
                Tween(CheckIcon, {ImageTransparency = state and 0 or 1}, 0.15)
                pcall(opts.Callback, state)
            end)
        end

        function tabObj:CreateSlider(opts)
            local val = opts.CurrentValue or opts.Range[1]
            local SldFrame = Create("Frame", { Parent = TabContent, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Colors.Section })
            Create("UICorner", {Parent = SldFrame, CornerRadius = UDim.new(0, 6)})
            Create("TextLabel", { Parent = SldFrame, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = opts.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
            ApplyTooltip(SldFrame, opts.Description)
            local ValueLabel = Create("TextLabel", { Parent = SldFrame, Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -60, 0, 5), BackgroundTransparency = 1, Text = tostring(val) .. (opts.Suffix or ""), TextColor3 = Colors.Accent, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right })

            local SliderBG = Create("TextButton", { Parent = SldFrame, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 35), BackgroundColor3 = Colors.Background, Text = "", AutoButtonColor = false })
            Create("UICorner", {Parent = SliderBG, CornerRadius = UDim.new(1, 0)})
            local initPos = math.clamp((val - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1)
            local SliderFill = Create("Frame", { Parent = SliderBG, Size = UDim2.new(initPos, 0, 1, 0), BackgroundColor3 = Colors.Accent })
            Create("UICorner", {Parent = SliderFill, CornerRadius = UDim.new(1, 0)})

            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local newVal = opts.Range[1] + ((opts.Range[2] - opts.Range[1]) * pos)
                if opts.Increment then newVal = math.floor((newVal / opts.Increment) + 0.5) * opts.Increment end
                Tween(SliderFill, {Size = UDim2.new((newVal - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1, 0)}, 0.1)
                ValueLabel.Text = tostring(newVal) .. (opts.Suffix or "")
                pcall(opts.Callback, newVal)
            end

            local sliding = false
            SliderBG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; UpdateSlider(input) end end)
            SliderBG.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
            UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end end)
        end

        function tabObj:CreateDropdown(opts)
            local expanded = false
            local DropFrame = Create("Frame", {Parent = TabContent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Section, ClipsDescendants = true})
            Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 6)})
            local Btn = Create("TextButton", { Parent = DropFrame, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = "  " .. opts.Name .. " : " .. (opts.Options[1] or ""), TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
            local Arrow = Create("TextLabel", { Parent = DropFrame, Size = UDim2.new(0, 35, 0, 35), Position = UDim2.new(1, -35, 0, 0), BackgroundTransparency = 1, Text = "▼", TextColor3 = Colors.TextDark, Font = Enum.Font.GothamMedium, TextSize = 12 })
            ApplyTooltip(Btn, opts.Description)
            local Scroll = Create("ScrollingFrame", { Parent = DropFrame, Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0, #opts.Options * 25) })
            Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder})

            local function toggleDrop()
                expanded = not expanded
                local targetHeight = expanded and (35 + math.min(#opts.Options * 25, 100)) or 35
                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2); Tween(Arrow, {Rotation = expanded and 180 or 0}, 0.2)
            end
            Btn.MouseButton1Click:Connect(toggleDrop)

            for _, opt in pairs(opts.Options) do
                local OptBtn = Create("TextButton", { Parent = Scroll, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = "  " .. opt, TextColor3 = Colors.TextDark, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
                OptBtn.MouseEnter:Connect(function() Tween(OptBtn, {TextColor3 = Colors.Accent, PaddingLeft = UDim.new(0, 5)}, 0.1) end)
                OptBtn.MouseLeave:Connect(function() Tween(OptBtn, {TextColor3 = Colors.TextDark, PaddingLeft = UDim.new(0, 0)}, 0.1) end)
                OptBtn.MouseButton1Click:Connect(function() Btn.Text = "  " .. opts.Name .. " : " .. opt; toggleDrop(); pcall(opts.Callback, opt) end)
            end
        end

        function tabObj:CreateKeybind(opts)
            local currentKey = opts.CurrentKey or Enum.KeyCode.Unknown
            local binding = false
            local BindFrame = Create("Frame", { Parent = TabContent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Section })
            Create("UICorner", {Parent = BindFrame, CornerRadius = UDim.new(0, 6)})
            Create("TextLabel", { Parent = BindFrame, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = opts.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
            ApplyTooltip(BindFrame, opts.Description)

            local BindBtn = Create("TextButton", { Parent = BindFrame, Size = UDim2.new(0, 80, 0, 25), Position = UDim2.new(1, -90, 0.5, -12.5), BackgroundColor3 = Colors.Background, Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 12 })
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})

            BindBtn.MouseButton1Click:Connect(function() binding = true; BindBtn.Text = "..."; Tween(BindBtn, {BackgroundColor3 = Colors.Click}, 0.1) end)
            UserInputService.InputBegan:Connect(function(input, gp)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false; currentKey = input.KeyCode; BindBtn.Text = currentKey.Name; Tween(BindBtn, {BackgroundColor3 = Colors.Background}, 0.1)
                elseif not binding and not gp and input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                    pcall(opts.Callback, currentKey)
                end
            end)
        end

        function tabObj:CreateColorPicker(opts)
            local color = opts.CurrentColor or Color3.fromRGB(255, 255, 255)
            local expanded = false
            local PickerFrame = Create("Frame", { Parent = TabContent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Section, ClipsDescendants = true })
            Create("UICorner", {Parent = PickerFrame, CornerRadius = UDim.new(0, 6)})
            local MainBtn = Create("TextButton", { Parent = PickerFrame, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = "  " .. opts.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
            ApplyTooltip(MainBtn, opts.Description)
            local ColorPreview = Create("Frame", { Parent = PickerFrame, Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -40, 0, 7.5), BackgroundColor3 = color })
            Create("UICorner", {Parent = ColorPreview, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = ColorPreview, Color = Colors.TextDark, Thickness = 1})

            local RGBContainer = Create("Frame", { Parent = PickerFrame, Size = UDim2.new(1, 0, 0, 90), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1 })
            local function CreateRGBRow(name, yPos, colorRGB, initVal)
                local Row = Create("Frame", { Parent = RGBContainer, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, yPos), BackgroundTransparency = 1 })
                Create("TextLabel", { Parent = Row, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = colorRGB, Font = Enum.Font.GothamBold, TextSize = 14 })
                local SliderBG = Create("TextButton", { Parent = Row, Size = UDim2.new(1, -50, 0, 6), Position = UDim2.new(0, 40, 0.5, -3), BackgroundColor3 = Colors.Background, Text = "" })
                Create("UICorner", {Parent = SliderBG, CornerRadius = UDim.new(1,0)})
                local SliderFill = Create("Frame", { Parent = SliderBG, Size = UDim2.new(initVal/255, 0, 1, 0), BackgroundColor3 = colorRGB })
                Create("UICorner", {Parent = SliderFill, CornerRadius = UDim.new(1,0)})
                return SliderBG, SliderFill
            end

            local rBg, rFill = CreateRGBRow("R", 10, Color3.fromRGB(255, 80, 80), math.floor(color.R*255))
            local gBg, gFill = CreateRGBRow("G", 40, Color3.fromRGB(80, 255, 80), math.floor(color.G*255))
            local bBg, bFill = CreateRGBRow("B", 70, Color3.fromRGB(80, 150, 255), math.floor(color.B*255))

            local function UpdateColors()
                color = Color3.new(rFill.Size.X.Scale, gFill.Size.X.Scale, bFill.Size.X.Scale)
                Tween(ColorPreview, {BackgroundColor3 = color}, 0.1); pcall(opts.Callback, color)
            end

            local function SetupSlider(bg, fill)
                local sliding = false
                bg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true; local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                        Tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1); UpdateColors()
                    end
                end)
                bg.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                        Tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1); UpdateColors()
                    end
                end)
            end

            SetupSlider(rBg, rFill); SetupSlider(gBg, gFill); SetupSlider(bBg, bFill)
            MainBtn.MouseButton1Click:Connect(function()
                expanded = not expanded; Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, expanded and 130 or 35)}, 0.25)
            end)
        end
        return tabObj
    end
    return windowObj
end


-- ==========================================
-- ОКНО HUB (Без вкладок, с поиском и автоскроллингом)
-- ==========================================
function Xeno:CreateHub(config)
    config = config or {}
    local TitleText = config.Name or "Xeno Hub"
    
    local XenoGui = Create("ScreenGui", {Name = "XenoHub", ResetOnSpawn = false})
    local parent = (getgenv and gethui) and gethui() or game:GetService("CoreGui")
    pcall(function() XenoGui.Parent = parent end)
    if not XenoGui.Parent then XenoGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    SetupNotifications(XenoGui)

    local MainFrame = Create("Frame", {
        Parent = XenoGui, Size = UDim2.new(0, 450, 0, 450), Position = UDim2.new(0.5, -225, 0.5, -225),
        BackgroundColor3 = Colors.Background, ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = MainFrame, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})
    
    local Topbar = Create("Frame", { Parent = MainFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 })
    local Title = Create("TextLabel", { Parent = Topbar, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = TitleText, TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left })
    
    local CloseBtn = Create("TextButton", { Parent = Topbar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5), BackgroundTransparency = 1, Text = "✕", TextColor3 = Colors.TextDark, TextSize = 16, Font = Enum.Font.GothamMedium })
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {TextColor3 = Color3.fromRGB(255, 80, 80)}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {TextColor3 = Colors.TextDark}) end)
    CloseBtn.MouseButton1Click:Connect(function() XenoGui:Destroy() end)

    local MinBtn = Create("TextButton", { Parent = Topbar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -70, 0, 5), BackgroundTransparency = 1, Text = "−", TextColor3 = Colors.TextDark, TextSize = 22, Font = Enum.Font.GothamMedium })
    MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {TextColor3 = Colors.Text}) end)
    MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {TextColor3 = Colors.TextDark}) end)

    local minimized = false
    local function ToggleUI() minimized = not minimized; MainFrame.Visible = not minimized end
    MinBtn.MouseButton1Click:Connect(ToggleUI)
    UserInputService.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.RightControl then ToggleUI() end end)

    -- Перемещение окна
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Строка поиска
    local SearchContainer = Create("Frame", { Parent = MainFrame, Size = UDim2.new(1, -20, 0, 35), Position = UDim2.new(0, 10, 0, 45), BackgroundColor3 = Colors.Section })
    Create("UICorner", {Parent = SearchContainer, CornerRadius = UDim.new(0, 6)})
    local SearchBox = Create("TextBox", {
        Parent = SearchContainer, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Text = "", PlaceholderText = "Поиск скриптов...",
        TextColor3 = Colors.Text, PlaceholderColor3 = Colors.TextDark,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false
    })

    -- Контент хаба (С автоскроллингом)
    local HubContent = Create("ScrollingFrame", {
        Parent = MainFrame, Size = UDim2.new(1, -20, 1, -100), Position = UDim2.new(0, 10, 0, 90), BackgroundTransparency = 1, ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", {Parent = HubContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
    Create("UIPadding", {Parent = HubContent, PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})

    -- Логика фильтрации поиска
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = SearchBox.Text:lower()
        for _, child in ipairs(HubContent:GetChildren()) do
            if child:IsA("TextButton") then
                if searchText == "" or child.Name:lower():find(searchText) then
                    child.Visible = true
                else
                    child.Visible = false
                end
            end
        end
    end)

    local hubObj = {}
    function hubObj:CreateButton(opts)
        local BtnFrame = Create("TextButton", { Parent = HubContent, Name = opts.Name, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Section, Text = "", AutoButtonColor = false })
        Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 6)})
        Create("TextLabel", { Parent = BtnFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "  " .. opts.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
        
        BtnFrame.MouseEnter:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Colors.Hover}) end)
        BtnFrame.MouseLeave:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Colors.Section}) end)
        BtnFrame.MouseButton1Down:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Colors.Click}, 0.1) end)
        BtnFrame.MouseButton1Up:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Colors.Hover}, 0.1) end)
        
        BtnFrame.MouseButton1Click:Connect(function()
            Xeno:Notify({Title = "Hub", Content = "Загрузка: " .. opts.Name, Duration = 2})
            pcall(opts.Callback)
        end)
    end

    return hubObj
end

return Xeno
