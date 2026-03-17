-- Xeno Executor UI Library v2
local Xeno = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

-- Цветовая палитра
local Colors = {
    Background = Color3.fromRGB(20, 20, 20),
    Section = Color3.fromRGB(28, 28, 28),
    Accent = Color3.fromRGB(45, 120, 190), -- Красивый темный голубой
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150)
}

-- Утилита для создания UI
local function Create(class, properties)
    local inst = Instance.new(class)
    for k, v in pairs(properties or {}) do inst[k] = v end
    return inst
end

function Xeno:CreateWindow(config)
    config = config or {}
    local TitleText = config.Name or "Xeno Executor"
    
    local XenoGui = Create("ScreenGui", {Name = "XenoLib", ResetOnSpawn = false})
    -- Для защиты в эксплойтах обычно используют gethui() или CoreGui
    local parent = (getgenv and gethui) and gethui() or game:GetService("CoreGui")
    pcall(function() XenoGui.Parent = parent end)
    if not XenoGui.Parent then XenoGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Main Frame (ИСПРАВЛЕНО: ClipsDescendants вместо ClipseDescendants)
    local MainFrame = Create("Frame", {
        Parent = XenoGui, Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Colors.Background, BackgroundTransparency = 0.05, ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    
    -- Topbar
    local Topbar = Create("Frame", {
        Parent = MainFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1
    })
    local Title = Create("TextLabel", {
        Parent = Topbar, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1, Text = TitleText, TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Кнопки управления окном
    local CloseBtn = Create("TextButton", {
        Parent = Topbar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5),
        BackgroundTransparency = 1, Text = "✕", TextColor3 = Colors.Text, TextSize = 18, Font = Enum.Font.GothamMedium
    })
    local MinBtn = Create("TextButton", {
        Parent = Topbar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -70, 0, 5),
        BackgroundTransparency = 1, Text = "−", TextColor3 = Colors.Text, TextSize = 22, Font = Enum.Font.GothamMedium
    })

    -- Layouts
    local Sidebar = Create("ScrollingFrame", {
        Parent = MainFrame, Size = UDim2.new(0, 150, 1, -40), Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1, ScrollBarThickness = 0
    })
    local SidebarLayout = Create("UIListLayout", {Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder})
    
    local ContentContainer = Create("Frame", {
        Parent = MainFrame, Size = UDim2.new(1, -160, 1, -50), Position = UDim2.new(0, 160, 0, 40), BackgroundTransparency = 1
    })

    -- Tooltip System
    local TooltipGui = Create("Frame", {
        Parent = XenoGui, Size = UDim2.new(0, 200, 0, 30), BackgroundColor3 = Colors.Section,
        Visible = false, ZIndex = 100, AutomaticSize = Enum.AutomaticSize.XY
    })
    Create("UICorner", {Parent = TooltipGui, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = TooltipGui, Color = Colors.Accent, Thickness = 1})
    Create("UIPadding", {Parent = TooltipGui, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})
    local TooltipLabel = Create("TextLabel", {
        Parent = TooltipGui, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true
    })

    local hoverStart = 0
    local isHovering = false
    local currentDesc = ""
    local lastMousePos = Vector2.new()

    RunService.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        if isHovering then
            if (mousePos - lastMousePos).Magnitude > 2 then
                TooltipGui.Visible = false -- Пропадает при движении
            elseif tick() - hoverStart >= 2 then
                TooltipGui.Visible = true
                TooltipGui.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y + 15)
                TooltipLabel.Text = currentDesc
            end
        else
            TooltipGui.Visible = false
        end
    end)

    local function ApplyTooltip(element, desc)
        if not desc or desc == "" then return end
        element.MouseEnter:Connect(function()
            isHovering = true
            hoverStart = tick()
            currentDesc = desc
            lastMousePos = UserInputService:GetMouseLocation()
        end)
        element.MouseLeave:Connect(function()
            isHovering = false
            TooltipGui.Visible = false
        end)
    end

    -- Prompt System (Диалоговые окна)
    local PromptOverlay = Create("Frame", {
        Parent = XenoGui, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 1, Visible = false, ZIndex = 50
    })
    local PromptBox = Create("Frame", {
        Parent = PromptOverlay, Size = UDim2.new(0, 300, 0, 150), Position = UDim2.new(0.5, -150, 0.5, -75),
        BackgroundColor3 = Colors.Background, ZIndex = 51
    })
    Create("UICorner", {Parent = PromptBox, CornerRadius = UDim.new(0, 8)})
    local PromptText = Create("TextLabel", {
        Parent = PromptBox, Size = UDim2.new(1, -20, 1, -60), Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14,
        TextWrapped = true, ZIndex = 52
    })
    local BtnYes = Create("TextButton", {
        Parent = PromptBox, Size = UDim2.new(0.4, 0, 0, 30), Position = UDim2.new(0.05, 0, 1, -40),
        BackgroundColor3 = Colors.Accent, Text = "Да", TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, ZIndex = 52
    })
    Create("UICorner", {Parent = BtnYes, CornerRadius = UDim.new(0, 4)})
    local BtnNo = Create("TextButton", {
        Parent = PromptBox, Size = UDim2.new(0.4, 0, 0, 30), Position = UDim2.new(0.55, 0, 1, -40),
        BackgroundColor3 = Colors.Section, Text = "Нет", TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, ZIndex = 52
    })
    Create("UICorner", {Parent = BtnNo, CornerRadius = UDim.new(0, 4)})

    local windowObj = {}

    function windowObj:Prompt(text, callback)
        PromptText.Text = text
        PromptOverlay.Visible = true
        TweenService:Create(PromptOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
        
        local yesConn, noConn
        yesConn = BtnYes.MouseButton1Click:Connect(function()
            yesConn:Disconnect(); noConn:Disconnect()
            TweenService:Create(PromptOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.3); PromptOverlay.Visible = false
            if callback then callback(true) end
        end)
        noConn = BtnNo.MouseButton1Click:Connect(function()
            yesConn:Disconnect(); noConn:Disconnect()
            TweenService:Create(PromptOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.3); PromptOverlay.Visible = false
            if callback then callback(false) end
        end)
    end

    CloseBtn.MouseButton1Click:Connect(function()
        windowObj:Prompt("Вы уверены, что хотите закрыть интерфейс?", function(res)
            if res then XenoGui:Destroy() end
        end)
    end)

    -- Скрытие на правый CTRL и кнопку Минус
    local minimized = false
    local function ToggleUI()
        minimized = not minimized
        MainFrame.Visible = not minimized
    end
    MinBtn.MouseButton1Click:Connect(ToggleUI)
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightControl then ToggleUI() end
    end)

    -- Перемещение окна (Drag)
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Логика Вкладок (Tabs)
    local Tabs = {}
    local firstTab = true

    function windowObj:CreateTab(name, iconId)
        local TabBtn = Create("TextButton", {
            Parent = Sidebar, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1,
            Text = "  " .. name, TextColor3 = Colors.TextDark, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
        })
        -- Акцентная полоска справа
        local Indicator = Create("Frame", {
            Parent = TabBtn, Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(1, -3, 0.2, 0),
            BackgroundColor3 = Colors.Accent, BackgroundTransparency = 1
        })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1,0)})

        if iconId then
            Create("ImageLabel", {
                Parent = TabBtn, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 5, 0.5, -8),
                BackgroundTransparency = 1, Image = "rbxassetid://" .. tostring(iconId), ImageColor3 = Colors.TextDark
            })
            TabBtn.Text = "      " .. name
        end

        local TabContent = Create("ScrollingFrame", {
            Parent = ContentContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            ScrollBarThickness = 2, Visible = false
        })
        Create("UIListLayout", {Parent = TabContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        Create("UIPadding", {Parent = TabContent, PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 10)})

        table.insert(Tabs, {Btn = TabBtn, Content = TabContent, Indicator = Indicator})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Content.Visible = false
                t.Btn.TextColor3 = Colors.TextDark
                t.Indicator.BackgroundTransparency = 1
            end
            TabContent.Visible = true
            TabBtn.TextColor3 = Colors.Text
            Indicator.BackgroundTransparency = 0
        end)

        if firstTab then
            TabContent.Visible = true
            TabBtn.TextColor3 = Colors.Text
            Indicator.BackgroundTransparency = 0
            firstTab = false
        end

        -- Элементы внутри вкладки
        local tabObj = {}

        function tabObj:CreateSection(secName)
            Create("TextLabel", {
                Parent = TabContent, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1,
                Text = secName, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function tabObj:CreateButton(opts)
            local BtnFrame = Create("Frame", {
                Parent = TabContent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Section
            })
            Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 6)})
            local Btn = Create("TextButton", {
                Parent = BtnFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Text = "  " .. opts.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
            ApplyTooltip(Btn, opts.Description)
            if opts.Icon then
                Create("ImageLabel", {
                    Parent = BtnFrame, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -25, 0.5, -9),
                    BackgroundTransparency = 1, Image = "rbxassetid://" .. tostring(opts.Icon)
                })
            end
            Btn.MouseButton1Click:Connect(function() pcall(opts.Callback) end)
        end

        function tabObj:CreateToggle(opts)
            local state = opts.CurrentValue or false
            local TogFrame = Create("Frame", {
                Parent = TabContent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Section
            })
            Create("UICorner", {Parent = TogFrame, CornerRadius = UDim.new(0, 6)})
            local Label = Create("TextLabel", {
                Parent = TogFrame, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, Text = opts.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
            ApplyTooltip(Label, opts.Description)
            
            -- Чекбокс, нажимается ТОЛЬКО он
            local CheckBox = Create("TextButton", {
                Parent = TogFrame, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundColor3 = Colors.Background, Text = ""
            })
            Create("UICorner", {Parent = CheckBox, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = CheckBox, Color = Colors.TextDark, Thickness = 1})
            
            local CheckIcon = Create("ImageLabel", {
                Parent = CheckBox, Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2),
                BackgroundTransparency = 1, Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(312, 4), ImageRectSize = Vector2.new(24, 24),
                Visible = state, ImageColor3 = Colors.Accent
            })

            CheckBox.MouseButton1Click:Connect(function()
                state = not state
                CheckIcon.Visible = state
                pcall(opts.Callback, state)
            end)
        end

        function tabObj:CreateSlider(opts)
            local val = opts.CurrentValue or opts.Range[1]
            local SldFrame = Create("Frame", {
                Parent = TabContent, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Colors.Section
            })
            Create("UICorner", {Parent = SldFrame, CornerRadius = UDim.new(0, 6)})
            local Label = Create("TextLabel", {
                Parent = SldFrame, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1, Text = opts.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
            ApplyTooltip(Label, opts.Description)
            
            local ValueLabel = Create("TextLabel", {
                Parent = SldFrame, Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -60, 0, 5),
                BackgroundTransparency = 1, Text = tostring(val) .. (opts.Suffix or ""), TextColor3 = Colors.Accent, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderBG = Create("TextButton", {
                Parent = SldFrame, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 35),
                BackgroundColor3 = Colors.Background, Text = ""
            })
            Create("UICorner", {Parent = SliderBG, CornerRadius = UDim.new(1, 0)})
            local SliderFill = Create("Frame", {
                Parent = SliderBG, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Colors.Accent
            })
            Create("UICorner", {Parent = SliderFill, CornerRadius = UDim.new(1, 0)})

            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local newVal = opts.Range[1] + ((opts.Range[2] - opts.Range[1]) * pos)
                if opts.Increment then newVal = math.floor((newVal / opts.Increment) + 0.5) * opts.Increment end
                TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(newVal) .. (opts.Suffix or "")
                pcall(opts.Callback, newVal)
            end

            local sliding = false
            SliderBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; UpdateSlider(input) end
            end)
            SliderBG.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end
            end)
        end

        function tabObj:CreateDropdown(opts)
            local expanded = false
            local DropFrame = Create("Frame", {Parent = TabContent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Section})
            Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 6)})
            local Btn = Create("TextButton", {
                Parent = DropFrame, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1,
                Text = "  " .. opts.Name .. " : " .. (opts.Options[1] or ""), TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
            })
            ApplyTooltip(Btn, opts.Description)
            
            local Scroll = Create("ScrollingFrame", {
                Parent = DropFrame, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 35),
                BackgroundTransparency = 1, ScrollBarThickness = 2, Visible = false
            })
            Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder})

            local function toggleDrop()
                expanded = not expanded
                Scroll.Visible = expanded
                DropFrame.Size = expanded and UDim2.new(1, 0, 0, 35 + math.min(#opts.Options * 25, 100)) or UDim2.new(1, 0, 0, 35)
                Scroll.Size = UDim2.new(1, 0, 1, -35)
            end
            Btn.MouseButton1Click:Connect(toggleDrop)

            for _, opt in pairs(opts.Options) do
                local OptBtn = Create("TextButton", {
                    Parent = Scroll, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1,
                    Text = "  " .. opt, TextColor3 = Colors.TextDark, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                OptBtn.MouseButton1Click:Connect(function()
                    Btn.Text = "  " .. opts.Name .. " : " .. opt
                    toggleDrop()
                    pcall(opts.Callback, opt)
                end)
            end
        end

        return tabObj
    end

    return windowObj
end

return Xeno
