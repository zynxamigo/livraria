local LucidUI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Themes = {
    Midnight = {
        Background = Color3.fromRGB(7, 7, 9),
        Surface = Color3.fromRGB(11, 11, 14),
        Surface2 = Color3.fromRGB(17, 17, 22),
        Surface3 = Color3.fromRGB(24, 24, 31),
        Accent = Color3.fromRGB(116, 92, 255),
        Accent2 = Color3.fromRGB(146, 105, 255),
        Text = Color3.fromRGB(240, 242, 248),
        MutedText = Color3.fromRGB(155, 162, 178),
        Stroke = Color3.fromRGB(40, 40, 50),
        Success = Color3.fromRGB(76, 201, 138),
        Warning = Color3.fromRGB(255, 190, 92),
        Danger = Color3.fromRGB(255, 100, 115)
    },
    Carbon = {
        Background = Color3.fromRGB(12, 12, 13),
        Surface = Color3.fromRGB(19, 19, 21),
        Surface2 = Color3.fromRGB(26, 26, 29),
        Surface3 = Color3.fromRGB(34, 34, 38),
        Accent = Color3.fromRGB(230, 230, 235),
        Accent2 = Color3.fromRGB(160, 160, 170),
        Text = Color3.fromRGB(245, 245, 247),
        MutedText = Color3.fromRGB(150, 150, 158),
        Stroke = Color3.fromRGB(55, 55, 61),
        Success = Color3.fromRGB(80, 210, 145),
        Warning = Color3.fromRGB(255, 194, 92),
        Danger = Color3.fromRGB(255, 95, 110)
    },
    Aurora = {
        Background = Color3.fromRGB(13, 18, 22),
        Surface = Color3.fromRGB(18, 26, 31),
        Surface2 = Color3.fromRGB(24, 34, 40),
        Surface3 = Color3.fromRGB(31, 43, 50),
        Accent = Color3.fromRGB(66, 220, 172),
        Accent2 = Color3.fromRGB(78, 167, 255),
        Text = Color3.fromRGB(237, 247, 245),
        MutedText = Color3.fromRGB(147, 171, 168),
        Stroke = Color3.fromRGB(47, 67, 73),
        Success = Color3.fromRGB(65, 220, 160),
        Warning = Color3.fromRGB(255, 197, 96),
        Danger = Color3.fromRGB(255, 105, 122)
    }
}

LucidUI.Themes = Themes
LucidUI.Version = "0.1.0"

local function tween(object, info, properties)
    local tw = TweenService:Create(object, info, properties)
    tw:Play()
    return tw
end

local function create(className, properties, children)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    for _, child in ipairs(children or {}) do
        child.Parent = object
    end
    return object
end

local function corner(radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    })
end

local function stroke(color, thickness, transparency)
    return create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    })
end

local function padding(left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0)
    })
end

local function listLayout(direction, paddingValue)
    return create("UIListLayout", {
        FillDirection = direction or Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, paddingValue or 0)
    })
end

local function textLabel(text, size, color, font)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text or "",
        TextSize = size or 14,
        TextColor3 = color or Color3.new(1,1,1),
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BorderSizePixel = 0
    })
end

local function textButton(text, size, color, font)
    return create("TextButton", {
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = text or "",
        TextSize = size or 14,
        TextColor3 = color or Color3.new(1,1,1),
        Font = font or Enum.Font.Gotham,
        BorderSizePixel = 0
    })
end

local function safeParent(gui)
    local ok = pcall(function()
        gui.Parent = CoreGui
    end)
    if not ok then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function bindCanvas(scrollingFrame, layout, extra)
    local function update()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (extra or 0))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

local function makeDraggable(handle, target)
    local dragging = false
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

function LucidUI:CreateWindow(options)
    options = options or {}

    local self = setmetatable({}, Window)

    self.Title = options.Title or "LucidUI"
    self.Subtitle = options.Subtitle or "Interface Library"
    self.ThemeName = options.Theme or "Midnight"
    self.Theme = Themes[self.ThemeName] or Themes.Midnight
    self.Size = options.Size or UDim2.fromOffset(760, 500)
    self.Minimized = false
    self.CurrentTab = nil
    self.Tabs = {}
    self.ThemeBindings = {}
    self.Keybinds = {}
    self.Visible = true

    local old = CoreGui:FindFirstChild("LucidUI_" .. self.Title)
    if old then
        old:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = "LucidUI_" .. self.Title,
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    safeParent(gui)
    self.Gui = gui

    local shadow = create("Frame", {
        Name = "Shadow",
        Size = self.Size + UDim2.fromOffset(20, 20),
        Position = UDim2.new(0.5, -self.Size.X.Offset/2 - 10, 0.5, -self.Size.Y.Offset/2 - 10),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0
    }, {
        corner(18)
    })
    shadow.Parent = gui

    local main = create("Frame", {
        Name = "Main",
        Size = self.Size,
        Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, {
        corner(14),
        stroke(self.Theme.Stroke, 1, 0.15)
    })
    main.Parent = gui

    self.Main = main
    self.Shadow = shadow

    local topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1,0,0,56),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0
    })
    topbar.Parent = main

    local title = textLabel(self.Title, 17, self.Theme.Text, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(18, 8)
    title.Size = UDim2.new(1,-160,0,22)
    title.Parent = topbar

    local subtitle = textLabel(self.Subtitle, 11, self.Theme.MutedText, Enum.Font.Gotham)
    subtitle.Position = UDim2.fromOffset(18, 30)
    subtitle.Size = UDim2.new(1,-160,0,16)
    subtitle.Parent = topbar

    local topActions = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-12,0.5,0),
        Size = UDim2.fromOffset(92,32)
    }, {
        listLayout(Enum.FillDirection.Horizontal, 8)
    })
    topActions.Parent = topbar

    local minimize = textButton("—", 18, self.Theme.MutedText, Enum.Font.GothamBold)
    minimize.Size = UDim2.fromOffset(40,32)
    minimize.BackgroundColor3 = self.Theme.Surface2
    minimize.BackgroundTransparency = 0
    corner(8).Parent = minimize
    minimize.Parent = topActions

    local close = textButton("×", 19, self.Theme.MutedText, Enum.Font.GothamBold)
    close.Size = UDim2.fromOffset(40,32)
    close.BackgroundColor3 = self.Theme.Surface2
    close.BackgroundTransparency = 0
    corner(8).Parent = close
    close.Parent = topActions

    local body = create("Frame", {
        Position = UDim2.fromOffset(0,56),
        Size = UDim2.new(1,0,1,-56),
        BackgroundTransparency = 1
    })
    body.Parent = main

    local sidebar = create("Frame", {
        Size = UDim2.new(0,180,1,0),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0
    })
    sidebar.Parent = body

    local searchBox = create("TextBox", {
        PlaceholderText = "Pesquisar...",
        PlaceholderColor3 = self.Theme.MutedText,
        Text = "",
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        BackgroundColor3 = self.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1,-20,0,34),
        Position = UDim2.fromOffset(10,10),
        TextXAlignment = Enum.TextXAlignment.Left
    }, {
        corner(8),
        padding(10,10,0,0),
        stroke(self.Theme.Stroke,1,0.35)
    })
    searchBox.Parent = sidebar

    local tabList = create("ScrollingFrame", {
        Position = UDim2.fromOffset(8,54),
        Size = UDim2.new(1,-16,1,-62),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Stroke,
        CanvasSize = UDim2.new()
    })
    tabList.Parent = sidebar

    local tabLayout = listLayout(Enum.FillDirection.Vertical, 6)
    tabLayout.Parent = tabList
    bindCanvas(tabList, tabLayout, 8)

    local content = create("Frame", {
        Position = UDim2.fromOffset(180,0),
        Size = UDim2.new(1,-180,1,0),
        BackgroundTransparency = 1
    })
    content.Parent = body

    self.Sidebar = sidebar
    self.TabList = tabList
    self.Content = content
    self.SearchBox = searchBox

    self:_BindTheme(main, "BackgroundColor3", "Background")
    self:_BindTheme(topbar, "BackgroundColor3", "Surface")
    self:_BindTheme(sidebar, "BackgroundColor3", "Surface")
    self:_BindTheme(title, "TextColor3", "Text")
    self:_BindTheme(subtitle, "TextColor3", "MutedText")
    self:_BindTheme(searchBox, "BackgroundColor3", "Surface2")
    self:_BindTheme(searchBox, "TextColor3", "Text")
    self:_BindTheme(searchBox, "PlaceholderColor3", "MutedText")
    self:_BindTheme(minimize, "BackgroundColor3", "Surface2")
    self:_BindTheme(minimize, "TextColor3", "MutedText")
    self:_BindTheme(close, "BackgroundColor3", "Surface2")
    self:_BindTheme(close, "TextColor3", "MutedText")

    minimize.MouseButton1Click:Connect(function()
        self:SetMinimized(not self.Minimized)
    end)

    close.MouseButton1Click:Connect(function()
        self.Visible = false
        self.Main.Visible = false
        self.Shadow.Visible = false
    end)

    minimize.MouseEnter:Connect(function()
        tween(minimize, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Surface3, TextColor3 = self.Theme.Text})
    end)
    minimize.MouseLeave:Connect(function()
        tween(minimize, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Surface2, TextColor3 = self.Theme.MutedText})
    end)

    close.MouseEnter:Connect(function()
        tween(close, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Danger, TextColor3 = Color3.new(1,1,1)})
    end)
    close.MouseLeave:Connect(function()
        tween(close, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Surface2, TextColor3 = self.Theme.MutedText})
    end)

    makeDraggable(topbar, main)

    RunService.RenderStepped:Connect(function()
        if not self.Gui or not self.Gui.Parent then
            return
        end
        shadow.Position = main.Position - UDim2.fromOffset(10,10)
        shadow.Size = main.Size + UDim2.fromOffset(20,20)
        shadow.Visible = main.Visible
    end)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchBox.Text)
        for _, tab in ipairs(self.Tabs) do
            local match = query == "" or string.find(string.lower(tab.Name), query, 1, true)
            tab.Button.Visible = match
        end
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if input.KeyCode == Enum.KeyCode.Tab then
            self:Toggle()
        end
        for _, item in ipairs(self.Keybinds) do
            if input.KeyCode == item.Key and item.Callback then
                task.spawn(item.Callback)
            end
        end
    end)

    return self
end

function Window:_BindTheme(object, property, key)
    table.insert(self.ThemeBindings, {
        Object = object,
        Property = property,
        Key = key
    })
end

function Window:SetTheme(name)
    if not Themes[name] then
        return false
    end

    self.ThemeName = name
    self.Theme = Themes[name]

    for _, binding in ipairs(self.ThemeBindings) do
        if binding.Object and binding.Object.Parent then
            local value = self.Theme[binding.Key]
            if value ~= nil then
                pcall(function()
                    tween(binding.Object, TweenInfo.new(0.18), {[binding.Property] = value})
                end)
            end
        end
    end

    for _, tab in ipairs(self.Tabs) do
        tab:_RefreshState()
    end

    return true
end

function Window:SetMinimized(state)
    self.Minimized = state

    if state then
        tween(self.Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, self.Size.X.Offset, 0, 56)
        })
    else
        tween(self.Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = self.Size
        })
    end
end

function Window:Toggle()
    self.Visible = not self.Visible
    self.Main.Visible = self.Visible
    self.Shadow.Visible = self.Visible
end

function Window:Destroy()
    if self.Gui then
        self.Gui:Destroy()
    end
end

function Window:Notify(options)
    options = options or {}

    local titleText = options.Title or "LucidUI"
    local description = options.Description or ""
    local duration = options.Duration or 3
    local kind = options.Type or "Default"

    local holder = self.Gui:FindFirstChild("LucidNotifications")
    if not holder then
        holder = create("Frame", {
            Name = "LucidNotifications",
            AnchorPoint = Vector2.new(1,1),
            Position = UDim2.new(1,-18,1,-18),
            Size = UDim2.fromOffset(330,400),
            BackgroundTransparency = 1
        }, {
            listLayout(Enum.FillDirection.Vertical,8)
        })
        holder.Parent = self.Gui
    end

    local accent = self.Theme.Accent
    if kind == "Success" then
        accent = self.Theme.Success
    elseif kind == "Warning" then
        accent = self.Theme.Warning
    elseif kind == "Danger" or kind == "Error" then
        accent = self.Theme.Danger
    end

    local card = create("Frame", {
        Size = UDim2.new(1,0,0,0),
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, {
        corner(10),
        stroke(self.Theme.Stroke,1,0.25)
    })
    card.Parent = holder

    local strip = create("Frame", {
        Size = UDim2.fromOffset(4,70),
        BackgroundColor3 = accent,
        BorderSizePixel = 0
    }, {
        corner(10)
    })
    strip.Parent = card

    local t = textLabel(titleText, 14, self.Theme.Text, Enum.Font.GothamBold)
    t.Position = UDim2.fromOffset(14,10)
    t.Size = UDim2.new(1,-28,0,20)
    t.Parent = card

    local d = textLabel(description, 12, self.Theme.MutedText, Enum.Font.Gotham)
    d.Position = UDim2.fromOffset(14,31)
    d.Size = UDim2.new(1,-28,0,28)
    d.TextWrapped = true
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Parent = card

    local progress = create("Frame", {
        AnchorPoint = Vector2.new(0,1),
        Position = UDim2.new(0,0,1,0),
        Size = UDim2.new(1,0,0,2),
        BackgroundColor3 = accent,
        BorderSizePixel = 0
    })
    progress.Parent = card

    tween(card, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,70)})
    tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,0,2)})

    task.delay(duration, function()
        if card and card.Parent then
            tween(card, TweenInfo.new(0.18), {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1})
            task.wait(0.2)
            card:Destroy()
        end
    end)
end

function Window:AddTab(name, icon)
    local selfTab = setmetatable({}, Tab)

    selfTab.Window = self
    selfTab.Name = name or "Tab"
    selfTab.Icon = icon
    selfTab.Sections = {}
    selfTab.Active = false

    local button = textButton("", 13, self.Theme.MutedText, Enum.Font.GothamMedium)
    button.Size = UDim2.new(1,0,0,38)
    button.BackgroundColor3 = self.Theme.Surface2
    button.BackgroundTransparency = 1
    button.Parent = self.TabList
    corner(8).Parent = button

    local indicator = create("Frame", {
        AnchorPoint = Vector2.new(0,0.5),
        Position = UDim2.new(0,0,0.5,0),
        Size = UDim2.fromOffset(3,20),
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, {
        corner(4)
    })
    indicator.Parent = button

    local label = textLabel(name,13,self.Theme.MutedText,Enum.Font.GothamMedium)
    label.Position = UDim2.fromOffset(12,0)
    label.Size = UDim2.new(1,-20,1,0)
    label.Parent = button

    local page = create("ScrollingFrame", {
        Visible = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0,0),
        Size = UDim2.new(1,0,1,0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Stroke,
        CanvasSize = UDim2.new()
    }, {
        padding(16,16,16,16)
    })
    page.Parent = self.Content

    local pageLayout = listLayout(Enum.FillDirection.Vertical,12)
    pageLayout.Parent = page
    bindCanvas(page,pageLayout,32)

    selfTab.Button = button
    selfTab.Label = label
    selfTab.Indicator = indicator
    selfTab.Page = page

    table.insert(self.Tabs, selfTab)

    self:_BindTheme(label,"TextColor3","MutedText")
    self:_BindTheme(indicator,"BackgroundColor3","Accent")

    button.MouseButton1Click:Connect(function()
        self:SelectTab(selfTab)
    end)

    button.MouseEnter:Connect(function()
        if not selfTab.Active then
            tween(button,TweenInfo.new(0.15),{BackgroundTransparency = 0.4})
        end
    end)

    button.MouseLeave:Connect(function()
        if not selfTab.Active then
            tween(button,TweenInfo.new(0.15),{BackgroundTransparency = 1})
        end
    end)

    if not self.CurrentTab then
        self:SelectTab(selfTab)
    end

    return selfTab
end

function Window:SelectTab(tab)
    for _, item in ipairs(self.Tabs) do
        item.Active = item == tab
        item.Page.Visible = item == tab
        item:_RefreshState()
    end
    self.CurrentTab = tab
end

function Tab:_RefreshState()
    if self.Active then
        tween(self.Button,TweenInfo.new(0.16),{
            BackgroundTransparency = 0,
            BackgroundColor3 = self.Window.Theme.Surface2
        })
        tween(self.Label,TweenInfo.new(0.16),{
            TextColor3 = self.Window.Theme.Text
        })
        tween(self.Indicator,TweenInfo.new(0.16),{
            BackgroundTransparency = 0
        })
    else
        tween(self.Button,TweenInfo.new(0.16),{
            BackgroundTransparency = 1,
            BackgroundColor3 = self.Window.Theme.Surface2
        })
        tween(self.Label,TweenInfo.new(0.16),{
            TextColor3 = self.Window.Theme.MutedText
        })
        tween(self.Indicator,TweenInfo.new(0.16),{
            BackgroundTransparency = 1
        })
    end
end

function Tab:AddSection(name)
    local selfSection = setmetatable({}, Section)

    selfSection.Tab = self
    selfSection.Window = self.Window
    selfSection.Name = name or "Section"

    local holder = create("Frame", {
        Size = UDim2.new(1,0,0,52),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Window.Theme.Surface,
        BorderSizePixel = 0
    }, {
        corner(10),
        stroke(self.Window.Theme.Stroke,1,0.25),
        padding(12,12,10,12)
    })
    holder.Parent = self.Page

    local title = textLabel(selfSection.Name,13,self.Window.Theme.Text,Enum.Font.GothamBold)
    title.Size = UDim2.new(1,0,0,22)
    title.Parent = holder

    local content = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0,30),
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    content.Parent = holder

    local layout = listLayout(Enum.FillDirection.Vertical,8)
    layout.Parent = content

    selfSection.Holder = holder
    selfSection.Content = content

    table.insert(self.Sections,selfSection)

    self.Window:_BindTheme(holder,"BackgroundColor3","Surface")
    self.Window:_BindTheme(title,"TextColor3","Text")

    return selfSection
end

function Tab:AddButton(options, callback)
    if type(options) == "string" then
        options = {Name = options, Callback = callback}
    end
    local section = self:AddSection("")
    section.Holder.BackgroundTransparency = 1
    section.Holder:FindFirstChildOfClass("UIStroke").Transparency = 1
    section.Holder:FindFirstChildOfClass("UIPadding").PaddingTop = UDim.new()
    for _, child in ipairs(section.Holder:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    section.Content.Position = UDim2.new()
    return section:AddButton(options)
end

function Tab:AddToggle(options)
    local section = self:AddSection("")
    section.Holder.BackgroundTransparency = 1
    section.Holder:FindFirstChildOfClass("UIStroke").Transparency = 1
    for _, child in ipairs(section.Holder:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    section.Content.Position = UDim2.new()
    return section:AddToggle(options)
end

function Section:_Card(height)
    local card = create("Frame", {
        Size = UDim2.new(1,0,0,height or 44),
        BackgroundColor3 = self.Window.Theme.Surface2,
        BorderSizePixel = 0
    }, {
        corner(8),
        stroke(self.Window.Theme.Stroke,1,0.45)
    })
    card.Parent = self.Content

    self.Window:_BindTheme(card,"BackgroundColor3","Surface2")

    return card
end

function Section:AddButton(options)
    options = options or {}

    local name = options.Name or "Button"
    local description = options.Description
    local callback = options.Callback or function() end
    local height = description and 54 or 44

    local card = self:_Card(height)

    local title = textLabel(name,13,self.Window.Theme.Text,Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(12, description and 8 or 0)
    title.Size = UDim2.new(1,-90, description and 0 or 1, description and 18 or 0)
    title.Parent = card

    if description then
        local desc = textLabel(description,11,self.Window.Theme.MutedText,Enum.Font.Gotham)
        desc.Position = UDim2.fromOffset(12,28)
        desc.Size = UDim2.new(1,-100,0,16)
        desc.Parent = card
        self.Window:_BindTheme(desc,"TextColor3","MutedText")
    end

    local action = textButton(options.ActionText or "Executar",11,self.Window.Theme.Text,Enum.Font.GothamBold)
    action.AnchorPoint = Vector2.new(1,0.5)
    action.Position = UDim2.new(1,-8,0.5,0)
    action.Size = UDim2.fromOffset(70,28)
    action.BackgroundColor3 = self.Window.Theme.Surface3
    action.BackgroundTransparency = 0
    action.Parent = card
    corner(7).Parent = action

    self.Window:_BindTheme(title,"TextColor3","Text")
    self.Window:_BindTheme(action,"TextColor3","Text")
    self.Window:_BindTheme(action,"BackgroundColor3","Surface3")

    action.MouseEnter:Connect(function()
        tween(action,TweenInfo.new(0.12),{BackgroundColor3 = self.Window.Theme.Accent})
    end)
    action.MouseLeave:Connect(function()
        tween(action,TweenInfo.new(0.12),{BackgroundColor3 = self.Window.Theme.Surface3})
    end)
    action.MouseButton1Click:Connect(function()
        tween(action,TweenInfo.new(0.08),{Size = UDim2.fromOffset(66,26)})
        task.delay(0.08,function()
            if action and action.Parent then
                tween(action,TweenInfo.new(0.08),{Size = UDim2.fromOffset(70,28)})
            end
        end)
        task.spawn(callback)
    end)

    return {
        SetText = function(_,text)
            title.Text = text
        end,
        Fire = function()
            task.spawn(callback)
        end
    }
end

function Section:AddToggle(options)
    options = options or {}

    local value = options.Default == true
    local callback = options.Callback or function() end
    local card = self:_Card(46)

    local title = textLabel(options.Name or "Toggle",13,self.Window.Theme.Text,Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(12,0)
    title.Size = UDim2.new(1,-70,1,0)
    title.Parent = card

    local track = create("Frame", {
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-10,0.5,0),
        Size = UDim2.fromOffset(42,24),
        BackgroundColor3 = value and self.Window.Theme.Accent or self.Window.Theme.Surface3,
        BorderSizePixel = 0
    }, {
        corner(20)
    })
    track.Parent = card

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0,0.5),
        Position = value and UDim2.new(0,20,0.5,0) or UDim2.new(0,3,0.5,0),
        Size = UDim2.fromOffset(18,18),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0
    }, {
        corner(20)
    })
    knob.Parent = track

    local click = textButton("",1,Color3.new(1,1,1),Enum.Font.Gotham)
    click.Size = UDim2.fromScale(1,1)
    click.Parent = card

    self.Window:_BindTheme(title,"TextColor3","Text")

    local function render(skipCallback)
        tween(track,TweenInfo.new(0.16),{
            BackgroundColor3 = value and self.Window.Theme.Accent or self.Window.Theme.Surface3
        })
        tween(knob,TweenInfo.new(0.16,Enum.EasingStyle.Quint),{
            Position = value and UDim2.new(0,20,0.5,0) or UDim2.new(0,3,0.5,0)
        })
        if not skipCallback then
            task.spawn(callback,value)
        end
    end

    click.MouseButton1Click:Connect(function()
        value = not value
        render(false)
    end)

    return {
        Set = function(_,newValue)
            value = not not newValue
            render(false)
        end,
        Get = function()
            return value
        end
    }
end

function Section:AddSlider(options)
    options = options or {}

    local min = options.Min or 0
    local max = options.Max or 100
    local value = math.clamp(options.Default or min,min,max)
    local callback = options.Callback or function() end
    local suffix = options.Suffix or ""

    local card = self:_Card(64)

    local title = textLabel(options.Name or "Slider",13,self.Window.Theme.Text,Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(12,5)
    title.Size = UDim2.new(1,-80,0,20)
    title.Parent = card

    local valueLabel = textLabel(tostring(value) .. suffix,12,self.Window.Theme.MutedText,Enum.Font.GothamBold)
    valueLabel.AnchorPoint = Vector2.new(1,0)
    valueLabel.Position = UDim2.new(1,-12,0,5)
    valueLabel.Size = UDim2.fromOffset(70,20)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = card

    local bar = create("Frame", {
        Position = UDim2.new(0,12,0,40),
        Size = UDim2.new(1,-24,0,8),
        BackgroundColor3 = self.Window.Theme.Surface3,
        BorderSizePixel = 0
    }, {
        corner(8)
    })
    bar.Parent = card

    local fill = create("Frame", {
        Size = UDim2.new((value-min)/(max-min),0,1,0),
        BackgroundColor3 = self.Window.Theme.Accent,
        BorderSizePixel = 0
    }, {
        corner(8)
    })
    fill.Parent = bar

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new((value-min)/(max-min),0,0.5,0),
        Size = UDim2.fromOffset(14,14),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0
    }, {
        corner(10)
    })
    knob.Parent = bar

    self.Window:_BindTheme(title,"TextColor3","Text")
    self.Window:_BindTheme(valueLabel,"TextColor3","MutedText")
    self.Window:_BindTheme(bar,"BackgroundColor3","Surface3")
    self.Window:_BindTheme(fill,"BackgroundColor3","Accent")

    local dragging = false

    local function setFromX(x, fire)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,0,1)
        local newValue = min + (max-min)*rel
        if options.Rounding == false then
            value = newValue
        else
            local step = options.Step or 1
            value = math.floor((newValue/step)+0.5)*step
            value = math.clamp(value,min,max)
        end
        local alpha = (value-min)/(max-min)
        fill.Size = UDim2.new(alpha,0,1,0)
        knob.Position = UDim2.new(alpha,0,0.5,0)
        valueLabel.Text = tostring(value) .. suffix
        if fire then
            task.spawn(callback,value)
        end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X,true)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X,true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Set = function(_,newValue)
            value = math.clamp(newValue,min,max)
            local alpha = (value-min)/(max-min)
            fill.Size = UDim2.new(alpha,0,1,0)
            knob.Position = UDim2.new(alpha,0,0.5,0)
            valueLabel.Text = tostring(value) .. suffix
            task.spawn(callback,value)
        end,
        Get = function()
            return value
        end
    }
end

function Section:AddTextbox(options)
    options = options or {}
    local callback = options.Callback or function() end

    local card = self:_Card(50)

    local title = textLabel(options.Name or "Textbox",13,self.Window.Theme.Text,Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(12,0)
    title.Size = UDim2.new(0.42,0,1,0)
    title.Parent = card

    local box = create("TextBox", {
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-10,0.5,0),
        Size = UDim2.new(0.52,0,0,30),
        BackgroundColor3 = self.Window.Theme.Surface3,
        BorderSizePixel = 0,
        Text = options.Default or "",
        PlaceholderText = options.Placeholder or "Digite...",
        PlaceholderColor3 = self.Window.Theme.MutedText,
        TextColor3 = self.Window.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left
    }, {
        corner(7),
        padding(9,9,0,0)
    })
    box.Parent = card

    self.Window:_BindTheme(title,"TextColor3","Text")
    self.Window:_BindTheme(box,"BackgroundColor3","Surface3")
    self.Window:_BindTheme(box,"TextColor3","Text")
    self.Window:_BindTheme(box,"PlaceholderColor3","MutedText")

    box.FocusLost:Connect(function(enterPressed)
        if options.EnterOnly and not enterPressed then
            return
        end
        task.spawn(callback,box.Text,enterPressed)
    end)

    return {
        Set = function(_,text)
            box.Text = tostring(text)
        end,
        Get = function()
            return box.Text
        end
    }
end

function Section:AddDropdown(options)
    options = options or {}

    local values = options.Values or {}
    local current = options.Default or values[1]
    local callback = options.Callback or function() end
    local open = false

    local wrapper = create("Frame", {
        Size = UDim2.new(1,0,0,46),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })
    wrapper.Parent = self.Content

    local card = create("Frame", {
        Size = UDim2.new(1,0,0,46),
        BackgroundColor3 = self.Window.Theme.Surface2,
        BorderSizePixel = 0
    }, {
        corner(8),
        stroke(self.Window.Theme.Stroke,1,0.45)
    })
    card.Parent = wrapper

    local title = textLabel(options.Name or "Dropdown",13,self.Window.Theme.Text,Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(12,0)
    title.Size = UDim2.new(0.42,0,0,46)
    title.Parent = card

    local selected = textButton(current and tostring(current) or "Selecionar",12,self.Window.Theme.Text,Enum.Font.Gotham)
    selected.AnchorPoint = Vector2.new(1,0.5)
    selected.Position = UDim2.new(1,-10,0.5,0)
    selected.Size = UDim2.new(0.52,0,0,30)
    selected.BackgroundColor3 = self.Window.Theme.Surface3
    selected.BackgroundTransparency = 0
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.Parent = card
    corner(7).Parent = selected
    padding(9,9,0,0).Parent = selected

    local list = create("Frame", {
        Position = UDim2.fromOffset(0,52),
        Size = UDim2.new(1,0,0,0),
        BackgroundColor3 = self.Window.Theme.Surface2,
        BorderSizePixel = 0
    }, {
        corner(8),
        stroke(self.Window.Theme.Stroke,1,0.45),
        padding(6,6,6,6)
    })
    list.Parent = wrapper

    local layout = listLayout(Enum.FillDirection.Vertical,5)
    layout.Parent = list

    self.Window:_BindTheme(card,"BackgroundColor3","Surface2")
    self.Window:_BindTheme(list,"BackgroundColor3","Surface2")
    self.Window:_BindTheme(title,"TextColor3","Text")
    self.Window:_BindTheme(selected,"TextColor3","Text")
    self.Window:_BindTheme(selected,"BackgroundColor3","Surface3")

    local function closeDropdown()
        open = false
        tween(wrapper,TweenInfo.new(0.18),{Size = UDim2.new(1,0,0,46)})
    end

    local function rebuild()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local visibleCount = 0

        for _, item in ipairs(values) do
            visibleCount += 1
            local option = textButton(tostring(item),12,self.Window.Theme.MutedText,Enum.Font.Gotham)
            option.Size = UDim2.new(1,0,0,30)
            option.BackgroundColor3 = self.Window.Theme.Surface3
            option.BackgroundTransparency = 0
            option.TextXAlignment = Enum.TextXAlignment.Left
            option.Parent = list
            corner(6).Parent = option
            padding(9,9,0,0).Parent = option

            option.MouseButton1Click:Connect(function()
                current = item
                selected.Text = tostring(item)
                closeDropdown()
                task.spawn(callback,current)
            end)
        end

        list.Size = UDim2.new(1,0,0,visibleCount*35 + 7)
    end

    rebuild()

    selected.MouseButton1Click:Connect(function()
        open = not open
        if open then
            local h = list.Size.Y.Offset + 58
            tween(wrapper,TweenInfo.new(0.18),{Size = UDim2.new(1,0,0,h)})
        else
            closeDropdown()
        end
    end)

    return {
        Set = function(_,value)
            current = value
            selected.Text = tostring(value)
            task.spawn(callback,current)
        end,
        Get = function()
            return current
        end,
        Refresh = function(_,newValues)
            values = newValues or {}
            rebuild()
            closeDropdown()
        end
    }
end

function Section:AddKeybind(options)
    options = options or {}

    local currentKey = options.Default or Enum.KeyCode.Unknown
    local callback = options.Callback or function() end
    local changedCallback = options.Changed or function() end
    local listening = false

    local card = self:_Card(46)

    local title = textLabel(options.Name or "Keybind",13,self.Window.Theme.Text,Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(12,0)
    title.Size = UDim2.new(1,-110,1,0)
    title.Parent = card

    local keyButton = textButton(currentKey.Name,11,self.Window.Theme.Text,Enum.Font.GothamBold)
    keyButton.AnchorPoint = Vector2.new(1,0.5)
    keyButton.Position = UDim2.new(1,-10,0.5,0)
    keyButton.Size = UDim2.fromOffset(90,28)
    keyButton.BackgroundColor3 = self.Window.Theme.Surface3
    keyButton.BackgroundTransparency = 0
    keyButton.Parent = card
    corner(7).Parent = keyButton

    self.Window:_BindTheme(title,"TextColor3","Text")
    self.Window:_BindTheme(keyButton,"TextColor3","Text")
    self.Window:_BindTheme(keyButton,"BackgroundColor3","Surface3")

    local binding = {
        Key = currentKey,
        Callback = callback
    }

    table.insert(self.Window.Keybinds,binding)

    keyButton.MouseButton1Click:Connect(function()
        listening = true
        keyButton.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        if not listening then
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            currentKey = input.KeyCode
            binding.Key = currentKey
            keyButton.Text = currentKey.Name
            task.spawn(changedCallback,currentKey)
        end
    end)

    return {
        Set = function(_,key)
            currentKey = key
            binding.Key = key
            keyButton.Text = key.Name
        end,
        Get = function()
            return currentKey
        end
    }
end

function Section:AddLabel(text)
    local label = textLabel(text or "",12,self.Window.Theme.MutedText,Enum.Font.Gotham)
    label.Size = UDim2.new(1,0,0,24)
    label.TextWrapped = true
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Parent = self.Content

    self.Window:_BindTheme(label,"TextColor3","MutedText")

    return {
        Set = function(_,newText)
            label.Text = tostring(newText)
        end
    }
end

function Section:AddDivider()
    local divider = create("Frame", {
        Size = UDim2.new(1,0,0,1),
        BackgroundColor3 = self.Window.Theme.Stroke,
        BorderSizePixel = 0
    })
    divider.Parent = self.Content
    self.Window:_BindTheme(divider,"BackgroundColor3","Stroke")
    return divider
end

function Section:AddProgress(options)
    options = options or {}
    local value = math.clamp(options.Default or 0,0,100)

    local card = self:_Card(54)

    local title = textLabel(options.Name or "Progress",12,self.Window.Theme.Text,Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(12,5)
    title.Size = UDim2.new(1,-80,0,18)
    title.Parent = card

    local valueText = textLabel(tostring(value) .. "%",11,self.Window.Theme.MutedText,Enum.Font.GothamBold)
    valueText.AnchorPoint = Vector2.new(1,0)
    valueText.Position = UDim2.new(1,-12,0,5)
    valueText.Size = UDim2.fromOffset(60,18)
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = card

    local bar = create("Frame", {
        Position = UDim2.fromOffset(12,34),
        Size = UDim2.new(1,-24,0,7),
        BackgroundColor3 = self.Window.Theme.Surface3,
        BorderSizePixel = 0
    }, {
        corner(8)
    })
    bar.Parent = card

    local fill = create("Frame", {
        Size = UDim2.new(value/100,0,1,0),
        BackgroundColor3 = self.Window.Theme.Accent,
        BorderSizePixel = 0
    }, {
        corner(8)
    })
    fill.Parent = bar

    self.Window:_BindTheme(title,"TextColor3","Text")
    self.Window:_BindTheme(valueText,"TextColor3","MutedText")
    self.Window:_BindTheme(bar,"BackgroundColor3","Surface3")
    self.Window:_BindTheme(fill,"BackgroundColor3","Accent")

    return {
        Set = function(_,newValue)
            value = math.clamp(newValue,0,100)
            valueText.Text = tostring(math.floor(value+0.5)) .. "%"
            tween(fill,TweenInfo.new(0.18),{Size = UDim2.new(value/100,0,1,0)})
        end,
        Get = function()
            return value
        end
    }
end


local LUCID_STAR = "rbxassetid://393353129"
local LUCID_SEARCH = "rbxassetid://108401203679664"
local LUCID_SETTINGS = "rbxassetid://130679451576739"

LucidUI.Icons = {
    Star = LUCID_STAR,
    Search = LUCID_SEARCH,
    Settings = LUCID_SETTINGS
}

local OriginalCreateWindow = LucidUI.CreateWindow
local OriginalAddTab = Window.AddTab
local OriginalAddSection = Tab.AddSection
local OriginalSectionButton = Section.AddButton
local OriginalSectionToggle = Section.AddToggle
local OriginalSectionSlider = Section.AddSlider
local OriginalSectionDropdown = Section.AddDropdown
local OriginalSectionTextbox = Section.AddTextbox
local OriginalSectionKeybind = Section.AddKeybind
local OriginalSectionLabel = Section.AddLabel
local OriginalSectionProgress = Section.AddProgress

local function normalizeIcon(value)
    if not value then
        return nil
    end
    value = tostring(value)
    if string.find(value, "rbxasset", 1, true) then
        return value
    end
    return "rbxassetid://" .. value
end

local function attachFavorite(window, component)
    if not component or not component.Card or not component.Card.Parent then
        return
    end

    local star = create("ImageButton", {
        Name = "LucidFavorite",
        Visible = window.FavoriteMode == true,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(24, 24),
        BackgroundTransparency = 1,
        Image = LUCID_STAR,
        ImageColor3 = component.Favorited and Color3.fromRGB(255, 197, 66) or window.Theme.MutedText,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 10
    })
    star.Parent = component.Card
    component.FavoriteButton = star

    star.MouseButton1Click:Connect(function()
        component.Favorited = not component.Favorited
        tween(star, TweenInfo.new(0.13), {
            ImageColor3 = component.Favorited and Color3.fromRGB(255, 197, 66) or window.Theme.MutedText
        })
        window:_RefreshFavorites()
    end)
end

local function registerComponent(section, name, description, beforeChildren)
    local window = section.Window
    window.Components = window.Components or {}

    local card
    local children = section.Content:GetChildren()
    for i = #children, 1, -1 do
        local child = children[i]
        if child:IsA("GuiObject") and not beforeChildren[child] then
            card = child
            break
        end
    end

    local component = {
        Name = name or "Component",
        Description = description or "",
        Tab = section.Tab,
        Section = section,
        Card = card,
        Favorited = false
    }

    table.insert(window.Components, component)
    attachFavorite(window, component)
    return component
end

local function snapshotChildren(parent)
    local t = {}
    for _, child in ipairs(parent:GetChildren()) do
        t[child] = true
    end
    return t
end

function LucidUI:CreateWindow(options)
    local window = OriginalCreateWindow(self, options)
    window.Components = {}
    window.FavoriteMode = false
    window.FavoriteRows = {}

    local topbar = window.Main:FindFirstChild("Topbar")
    local actions
    if topbar then
        for _, child in ipairs(topbar:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChildOfClass("UIListLayout") then
                actions = child
                break
            end
        end
    end

    if actions then
        actions.Size = UDim2.fromOffset(132, 32)

        local star = create("ImageButton", {
            Name = "FavoriteMode",
            Size = UDim2.fromOffset(32, 32),
            LayoutOrder = -10,
            BackgroundColor3 = window.Theme.Surface2,
            BackgroundTransparency = 0,
            Image = LUCID_STAR,
            ImageColor3 = window.Theme.MutedText,
            AutoButtonColor = false,
            BorderSizePixel = 0
        }, {
            corner(8)
        })
        star.Parent = actions
        window.FavoriteModeButton = star

        star.MouseButton1Click:Connect(function()
            window.FavoriteMode = not window.FavoriteMode
            tween(star, TweenInfo.new(0.15), {
                ImageColor3 = window.FavoriteMode and Color3.fromRGB(255, 197, 66) or window.Theme.MutedText,
                BackgroundColor3 = window.FavoriteMode and Color3.fromRGB(45, 35, 15) or window.Theme.Surface2
            })

            for _, component in ipairs(window.Components) do
                if component.FavoriteButton then
                    component.FavoriteButton.Visible = window.FavoriteMode
                end
            end

            if not window.FavoriteMode then
                window:_RefreshFavorites()
            end
        end)
    end

    local oldPlaceholder = window.SearchBox.PlaceholderText
    window.SearchBox.PlaceholderText = "Search tabs & options..."

    window.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(window.SearchBox.Text)
        if q == "" then
            for _, tab in ipairs(window.Tabs) do
                if not tab.IsFavoriteTab then
                    tab.Button.Visible = true
                end
            end
            if window.FavoritesTab then
                window.FavoritesTab.Button.Visible = window:_FavoriteCount() > 0
            end
            return
        end

        for _, tab in ipairs(window.Tabs) do
            if tab.IsFavoriteTab then
                tab.Button.Visible = false
            else
                local match = string.find(string.lower(tab.Name), q, 1, true) ~= nil
                if not match then
                    for _, component in ipairs(window.Components) do
                        if component.Tab == tab then
                            local hay = string.lower(component.Name .. " " .. component.Description .. " " .. component.Section.Name)
                            if string.find(hay, q, 1, true) then
                                match = true
                                break
                            end
                        end
                    end
                end
                tab.Button.Visible = match
            end
        end
    end)

    return window
end

function Window:_FavoriteCount()
    local n = 0
    for _, component in ipairs(self.Components or {}) do
        if component.Favorited then
            n += 1
        end
    end
    return n
end

function Window:_EnsureFavoritesTab()
    if self.FavoritesTab then
        return self.FavoritesTab
    end

    local tab = OriginalAddTab(self, "Favorites", LUCID_STAR)
    tab.IsFavoriteTab = true
    tab.Button.LayoutOrder = -100
    tab.Button.Visible = false
    self.FavoritesTab = tab
    return tab
end

function Window:_RefreshFavorites()
    local count = self:_FavoriteCount()
    if count == 0 and not self.FavoritesTab then
        return
    end

    local tab = self:_EnsureFavoritesTab()
    tab.Button.Visible = count > 0

    for _, child in ipairs(tab.Page:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    if count == 0 then
        return
    end

    local section = OriginalAddSection(tab, "Quick access")

    for _, component in ipairs(self.Components) do
        if component.Favorited then
            local row = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = self.Theme.Surface2,
                BackgroundTransparency = 0,
                AutoButtonColor = false,
                Text = "",
                BorderSizePixel = 0
            }, {
                corner(8),
                stroke(self.Theme.Stroke, 1, 0.45)
            })
            row.Parent = section.Content

            local name = textLabel(component.Name, 13, self.Theme.Text, Enum.Font.GothamBold)
            name.Position = UDim2.fromOffset(12, 4)
            name.Size = UDim2.new(1, -24, 0, 21)
            name.Parent = row

            local path = textLabel(component.Tab.Name .. "  ›  " .. component.Section.Name, 10, self.Theme.MutedText, Enum.Font.Gotham)
            path.Position = UDim2.fromOffset(12, 25)
            path.Size = UDim2.new(1, -24, 0, 16)
            path.Parent = row

            row.MouseButton1Click:Connect(function()
                self:SelectTab(component.Tab)
                if component.Card and component.Card.Parent then
                    tween(component.Card, TweenInfo.new(0.12), {BackgroundColor3 = self.Theme.Surface3})
                    task.delay(0.35, function()
                        if component.Card and component.Card.Parent then
                            tween(component.Card, TweenInfo.new(0.18), {BackgroundColor3 = self.Theme.Surface2})
                        end
                    end)
                end
            end)
        end
    end
end

function Window:AddTab(name, icon)
    local tab = OriginalAddTab(self, name, icon)
    if icon then
        local image = create("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, -8),
            Size = UDim2.fromOffset(16, 16),
            Image = normalizeIcon(icon),
            ImageColor3 = self.Theme.MutedText,
            BorderSizePixel = 0
        })
        image.Parent = tab.Button
        tab.Label.Position = UDim2.fromOffset(34, 0)
        tab.Label.Size = UDim2.new(1, -42, 1, 0)
        tab.IconImage = image
    end
    return tab
end

function Tab:AddSection(name)
    local section = OriginalAddSection(self, name)
    section.Tab = self
    return section
end

local function wrapComponent(original, methodName)
    Section[methodName] = function(self, options, ...)
        local before = snapshotChildren(self.Content)
        local result = original(self, options, ...)
        local name = type(options) == "table" and options.Name or tostring(options or methodName)
        local desc = type(options) == "table" and options.Description or ""
        local c = registerComponent(self, name, desc, before)
        if type(result) == "table" then
            result._LucidComponent = c
        end
        return result
    end
end

wrapComponent(OriginalSectionButton, "AddButton")
wrapComponent(OriginalSectionToggle, "AddToggle")
wrapComponent(OriginalSectionSlider, "AddSlider")
wrapComponent(OriginalSectionDropdown, "AddDropdown")
wrapComponent(OriginalSectionTextbox, "AddTextbox")
wrapComponent(OriginalSectionKeybind, "AddKeybind")
wrapComponent(OriginalSectionProgress, "AddProgress")

function Section:AddPlayerDropdown(options)
    options = options or {}
    local selected = options.Default
    local callback = options.Callback or function() end
    local before = snapshotChildren(self.Content)

    local card = self:_Card(52)

    local title = textLabel(options.Name or "Player", 13, self.Window.Theme.Text, Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(12, 0)
    title.Size = UDim2.new(0.38, 0, 1, 0)
    title.Parent = card

    local pick = textButton(selected and selected.DisplayName or "Select player", 11, self.Window.Theme.Text, Enum.Font.Gotham)
    pick.AnchorPoint = Vector2.new(1, 0.5)
    pick.Position = UDim2.new(1, -42, 0.5, 0)
    pick.Size = UDim2.fromOffset(155, 30)
    pick.BackgroundTransparency = 0
    pick.BackgroundColor3 = self.Window.Theme.Surface3
    pick.Parent = card
    corner(7).Parent = pick

    local popup
    local liveConnections = {}

    local function disconnectLive()
        for _, c in ipairs(liveConnections) do
            c:Disconnect()
        end
        table.clear(liveConnections)
    end

    local function closePopup()
        disconnectLive()
        if popup then
            popup:Destroy()
            popup = nil
        end
    end

    local function openPopup()
        if popup then
            closePopup()
            return
        end

        popup = create("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -42, 1, 5),
            Size = UDim2.fromOffset(285, 270),
            BackgroundColor3 = self.Window.Theme.Surface,
            BorderSizePixel = 0,
            ZIndex = 50
        }, {
            corner(10),
            stroke(self.Window.Theme.Stroke, 1, 0.1)
        })
        popup.Parent = card

        local search = create("TextBox", {
            Position = UDim2.fromOffset(8, 8),
            Size = UDim2.new(1, -16, 0, 34),
            BackgroundColor3 = self.Window.Theme.Surface2,
            BorderSizePixel = 0,
            Text = "",
            PlaceholderText = "Search player...",
            PlaceholderColor3 = self.Window.Theme.MutedText,
            TextColor3 = self.Window.Theme.Text,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            ZIndex = 51
        }, {
            corner(7)
        })
        search.Parent = popup

        local list = create("ScrollingFrame", {
            Position = UDim2.fromOffset(8, 50),
            Size = UDim2.new(1, -16, 1, -58),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = self.Window.Theme.Stroke,
            CanvasSize = UDim2.new(),
            ZIndex = 51
        })
        list.Parent = popup

        local layout = listLayout(Enum.FillDirection.Vertical, 5)
        layout.Parent = list

        local function rebuild()
            for _, x in ipairs(list:GetChildren()) do
                if x:IsA("TextButton") then
                    x:Destroy()
                end
            end

            local q = string.lower(search.Text)
            local count = 0

            for _, player in ipairs(Players:GetPlayers()) do
                local hay = string.lower(player.Name .. " " .. player.DisplayName)
                if q == "" or string.find(hay, q, 1, true) then
                    count += 1

                    local row = textButton("", 11, self.Window.Theme.Text, Enum.Font.Gotham)
                    row.Size = UDim2.new(1, 0, 0, 44)
                    row.BackgroundTransparency = 0
                    row.BackgroundColor3 = self.Window.Theme.Surface2
                    row.ZIndex = 52
                    row.Parent = list
                    corner(7).Parent = row

                    local avatar = create("ImageLabel", {
                        Position = UDim2.fromOffset(5, 5),
                        Size = UDim2.fromOffset(34, 34),
                        BackgroundColor3 = self.Window.Theme.Surface3,
                        BorderSizePixel = 0,
                        ZIndex = 53
                    }, {
                        corner(18)
                    })
                    avatar.Parent = row

                    task.spawn(function()
                        local ok, image = pcall(function()
                            return Players:GetUserThumbnailAsync(
                                player.UserId,
                                Enum.ThumbnailType.HeadShot,
                                Enum.ThumbnailSize.Size100x100
                            )
                        end)
                        if ok and avatar.Parent then
                            avatar.Image = image
                        end
                    end)

                    local display = textLabel(player.DisplayName, 11, self.Window.Theme.Text, Enum.Font.GothamBold)
                    display.Position = UDim2.fromOffset(47, 4)
                    display.Size = UDim2.new(1, -52, 0, 19)
                    display.ZIndex = 53
                    display.Parent = row

                    local username = textLabel("@" .. player.Name, 9, self.Window.Theme.MutedText, Enum.Font.Gotham)
                    username.Position = UDim2.fromOffset(47, 22)
                    username.Size = UDim2.new(1, -52, 0, 16)
                    username.ZIndex = 53
                    username.Parent = row

                    row.MouseButton1Click:Connect(function()
                        selected = player
                        pick.Text = player.DisplayName
                        closePopup()
                        task.spawn(callback, player)
                    end)
                end
            end

            list.CanvasSize = UDim2.fromOffset(0, count * 49)
        end

        rebuild()
        table.insert(liveConnections, search:GetPropertyChangedSignal("Text"):Connect(rebuild))
        table.insert(liveConnections, Players.PlayerAdded:Connect(rebuild))
        table.insert(liveConnections, Players.PlayerRemoving:Connect(function(player)
            if selected == player then
                selected = nil
                pick.Text = "Select player"
            end
            rebuild()
        end))
    end

    pick.MouseButton1Click:Connect(openPopup)

    local c = registerComponent(self, options.Name or "PlayerDropdown", options.Description or "", before)

    return {
        Get = function()
            return selected
        end,
        Set = function(_, player)
            selected = player
            pick.Text = player and player.DisplayName or "Select player"
            if player then
                task.spawn(callback, player)
            end
        end,
        _LucidComponent = c
    }
end

return LucidUI
