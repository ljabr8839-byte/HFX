--==================================================
-- HFX DEVIL FRUIT ESP
-- GitHub-ready Lua file
--==================================================

-- IMPORTANT:
-- After uploading this file to GitHub, copy its RAW URL
-- and replace the placeholder below, then commit the change.
local RAW_URL = "PASTE_YOUR_GITHUB_RAW_URL_HERE"

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
if not Player then
    warn("[HFX] LocalPlayer not available.")
    return
end

-- Avoid duplicate copies if the script is executed again.
if _G.HFX_CLEANUP then
    pcall(_G.HFX_CLEANUP)
end

_G.HFX_RUNNING = true

-- Remove leftovers from an earlier execution.
pcall(function()
    local oldGui = CoreGui:FindFirstChild("HFX_TopTextUI")
    if oldGui then oldGui:Destroy() end

    local oldFolder = CoreGui:FindFirstChild("DevilFruitESP_Folder")
    if oldFolder then oldFolder:Destroy() end
end)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "DevilFruitESP_Folder"
ESPFolder.Parent = CoreGui

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HFX_TopTextUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local TopText = Instance.new("TextLabel")
TopText.Name = "TopText"
TopText.Size = UDim2.new(0, 150, 0, 40)
TopText.Position = UDim2.new(0.5, -75, 0, 15)
TopText.BackgroundTransparency = 1
TopText.Text = "HFX"
TopText.Font = Enum.Font.GothamBold
TopText.TextSize = 28
TopText.TextStrokeTransparency = 0.1
TopText.TextStrokeColor3 = Color3.new(0, 0, 0)
TopText.Parent = ScreenGui

local Connections = {}
local Tracked = {}

_G.HFX_CLEANUP = function()
    _G.HFX_RUNNING = false

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    for fruit, _ in pairs(Tracked) do
        Tracked[fruit] = nil
    end

    pcall(function()
        if ESPFolder then ESPFolder:Destroy() end
        if ScreenGui then ScreenGui:Destroy() end
    end)
end

-- Queue this same GitHub-hosted script for the next server,
-- if the executor exposes a supported teleport queue function.
local queueFunction =
    queue_on_teleport
    or (syn and syn.queue_on_teleport)
    or (fluxus and fluxus.queue_on_teleport)

if type(queueFunction) == "function" then
    if RAW_URL ~= "PASTE_YOUR_GITHUB_RAW_URL_HERE"
        and string.match(RAW_URL, "^https://") then

        local queuedCode =
            'loadstring(game:HttpGet("' .. RAW_URL .. '"))()'

        local queued, queueError = pcall(queueFunction, queuedCode)
        if not queued then
            warn("[HFX] Could not queue re-execution: " .. tostring(queueError))
        end
    else
        warn("[HFX] Add your GitHub RAW URL to enable teleport re-execution.")
    end
else
    warn("[HFX] This executor does not expose a teleport queue function.")
end

-- Animated HFX title.
task.spawn(function()
    local hue = 0

    while _G.HFX_RUNNING and TopText.Parent do
        hue = (hue + 1.5) % 360
        TopText.TextColor3 = Color3.fromHSV(hue / 360, 1, 1)
        task.wait(0.03)
    end
end)

local function CreateESP(fruit)
    if not _G.HFX_RUNNING then return end
    if not fruit or not fruit.Parent then return end
    if not (fruit:IsA("Tool") or fruit:IsA("Model")) then return end
    if Tracked[fruit] then return end

    local lowerName = string.lower(fruit.Name)
    if not string.find(lowerName, "fruit", 1, true)
        or string.find(lowerName, "dealer", 1, true) then
        return
    end

    local handle = fruit:FindFirstChild("Handle")
        or fruit:FindFirstChildWhichIsA("BasePart", true)

    if not handle then return end
    Tracked[fruit] = true

    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "FruitESP"
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
    BillboardGui.Adornee = handle
    BillboardGui.ExtentsOffset = Vector3.new(0, 2.5, 0)
    BillboardGui.Parent = handle

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 15
    TextLabel.TextStrokeTransparency = 0.2
    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    TextLabel.Parent = BillboardGui

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "HFX_FruitHighlight"
    Highlight.Adornee = fruit
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.OutlineTransparency = 0
    Highlight.FillTransparency = 0.75
    Highlight.Parent = ESPFolder

    task.spawn(function()
        local hue = 0

        while _G.HFX_RUNNING
            and fruit:IsDescendantOf(Workspace)
            and handle:IsDescendantOf(Workspace)
            and BillboardGui.Parent do

            hue = (hue + 1.5) % 360
            local color = Color3.fromHSV(hue / 360, 1, 1)

            Highlight.OutlineColor = color
            Highlight.FillColor = color
            TextLabel.TextColor3 = color

            local character = Player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if root then
                local distance = math.floor((root.Position - handle.Position).Magnitude)
                TextLabel.Text = "🍇 " .. fruit.Name .. "\n[" .. distance .. "m]"
            else
                TextLabel.Text = "🍇 " .. fruit.Name
            end

            task.wait(0.03)
        end

        pcall(function() Highlight:Destroy() end)
        pcall(function() BillboardGui:Destroy() end)
        Tracked[fruit] = nil
    end)
end

-- Scan objects already present.
for _, object in ipairs(Workspace:GetChildren()) do
    CreateESP(object)
end

-- Watch for newly spawned top-level objects.
table.insert(Connections, Workspace.ChildAdded:Connect(function(child)
    task.wait(0.5)
    if _G.HFX_RUNNING then
        CreateESP(child)
    end
end))

print("[HFX] Loaded. Fruit ESP is active.")
