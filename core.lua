local ADDON_NAME = ...
local BUTTON_WIDTH = 150
local BUTTON_HEIGHT = 22
local BUTTON_GAP = 6
local BUTTON_COUNT = 4

local state = {
    initialized = false,
    holder = nil,
    essentialButton = nil,
    utilityButton = nil,
    trackedBuffsButton = nil,
    trackedBarsButton = nil,
}

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff82c5ff" .. ADDON_NAME .. ":|r " .. tostring(message))
end

local function GetSettingsFrame()
    return _G.CooldownViewerSettings
end

local function GetCategoryObject(category)
    local settings = GetSettingsFrame()
    if not settings or not settings.categoryObjects then return nil end
    return settings.categoryObjects[category]
end

local function GetCategoryTitle(category)
    local categoryObject = GetCategoryObject(category)
    if categoryObject and categoryObject.GetTitle then
        return categoryObject:GetTitle()
    end

    return tostring(category)
end

local function GetHiddenCategoryFor(category)
    if category == Enum.CooldownViewerCategory.TrackedBuff or category == Enum.CooldownViewerCategory.TrackedBar then
        return GetCategoryObject(Enum.CooldownViewerCategory.HiddenAura)
    end

    return GetCategoryObject(Enum.CooldownViewerCategory.HiddenSpell)
end

local function GetCooldownIDsForCategory(category)
    local provider = GetSettingsFrame() and GetSettingsFrame():GetDataProvider()
    if not provider or not provider.GetOrderedCooldownIDs or not provider.GetCooldownInfoForID then
        return nil
    end

    local result = {}
    for _, cooldownID in ipairs(provider:GetOrderedCooldownIDs()) do
        local info = provider:GetCooldownInfoForID(cooldownID)
        if info and info.category == category then
            result[#result + 1] = cooldownID
        end
    end

    return result
end

local function RefreshSettings()
    local settings = GetSettingsFrame()
    if not settings then return end

    if settings.RefreshLayout then
        settings:RefreshLayout()
    end
end

local function SaveCurrentLayout()
    local settings = GetSettingsFrame()
    if not settings then return false end

    if settings.SaveCurrentLayout then
        settings:SaveCurrentLayout()
        return true
    elseif settings.CheckSaveCurrentLayout then
        settings:CheckSaveCurrentLayout()
        return true
    end

    return false
end

StaticPopupDialogs.RVR_COOLDOWN_CLEANUP_RELOAD = {
    text = "%s",
    button1 = RELOADUI or "Reload",
    button2 = "Later",
    OnAccept = function()
        SaveCurrentLayout()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

local function ClearCategory(category)
    if InCombatLockdown and InCombatLockdown() then
        Print("Leave combat before clearing cooldowns.")
        return
    end

    local settings = GetSettingsFrame()
    local provider = settings and settings:GetDataProvider()
    local hiddenCategory = GetHiddenCategoryFor(category)
    if not settings or not provider or not provider.SetCooldownToCategory or not hiddenCategory then
        Print("Cooldown Viewer settings are not ready yet.")
        return
    end

    local cooldownIDs = GetCooldownIDsForCategory(category)
    if not cooldownIDs then
        Print("Could not read cooldown list.")
        return
    end

    local moved = 0
    local hiddenCategoryID = hiddenCategory:GetCategory()
    for _, cooldownID in ipairs(cooldownIDs) do
        local status = provider:SetCooldownToCategory(cooldownID, hiddenCategoryID)
        if status == nil or status == Enum.CooldownLayoutStatus.Success then
            moved = moved + 1
        elseif settings.CheckDisplayActionStatus then
            settings:CheckDisplayActionStatus(Enum.CooldownLayoutAction.ChangeCategory, status)
        end
    end

    RefreshSettings()
    local categoryTitle = GetCategoryTitle(category)
    local noun = moved == 1 and "item" or "items"
    Print(("Cleared %d %s from %s."):format(moved, noun, categoryTitle))

    if moved > 0 then
        local message = ("RVR - Cooldown Cleanup\n\n%d %s cleaned from %s.\n\nReloading the UI via the reload button will save the Cooldown layout. A reload is necessary to avoid UI taint behavior."):format(moved, noun, categoryTitle)
        StaticPopup_Show("RVR_COOLDOWN_CLEANUP_RELOAD", message)
    end
end

local function SyncButtonVisibility()
    if not state.holder then return end

    local settings = GetSettingsFrame()
    local shouldShow = settings and settings:IsShown() and not (InCombatLockdown and InCombatLockdown())
    state.holder:SetShown(shouldShow)

    if shouldShow then
        state.essentialButton:Enable()
        state.utilityButton:Enable()
        state.trackedBuffsButton:Enable()
        state.trackedBarsButton:Enable()
    else
        state.essentialButton:Disable()
        state.utilityButton:Disable()
        state.trackedBuffsButton:Disable()
        state.trackedBarsButton:Disable()
    end
end

local function CreateButton(parent, name, text, point, relativeTo, relativePoint, xOffset, yOffset, onClick)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    button:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateButtons()
    local settings = GetSettingsFrame()
    if state.initialized or not settings then return end

    local holder = CreateFrame("Frame", "RVRCooldownCleanupButtonHolder", settings)
    holder:SetSize(BUTTON_WIDTH, (BUTTON_HEIGHT * BUTTON_COUNT) + (BUTTON_GAP * (BUTTON_COUNT - 1)))
    holder:SetPoint("BOTTOMLEFT", settings, "BOTTOMRIGHT", 8, 0)
    holder:SetFrameStrata(settings:GetFrameStrata())
    holder:SetFrameLevel(settings:GetFrameLevel() + 20)

    state.essentialButton = CreateButton(
        holder,
        "RVRCooldownCleanupEssentialButton",
        "Clear Essential",
        "TOPRIGHT",
        holder,
        "TOPRIGHT",
        0,
        0,
        function()
            ClearCategory(Enum.CooldownViewerCategory.Essential)
        end
    )

    state.utilityButton = CreateButton(
        holder,
        "RVRCooldownCleanupUtilityButton",
        "Clear Utility",
        "TOPRIGHT",
        state.essentialButton,
        "BOTTOMRIGHT",
        0,
        -BUTTON_GAP,
        function()
            ClearCategory(Enum.CooldownViewerCategory.Utility)
        end
    )

    state.trackedBuffsButton = CreateButton(
        holder,
        "RVRCooldownCleanupTrackedBuffsButton",
        "Clear Tracked Buffs",
        "TOPRIGHT",
        state.utilityButton,
        "BOTTOMRIGHT",
        0,
        -BUTTON_GAP,
        function()
            ClearCategory(Enum.CooldownViewerCategory.TrackedBuff)
        end
    )

    state.trackedBarsButton = CreateButton(
        holder,
        "RVRCooldownCleanupTrackedBarsButton",
        "Clear Tracked Bars",
        "TOPRIGHT",
        state.trackedBuffsButton,
        "BOTTOMRIGHT",
        0,
        -BUTTON_GAP,
        function()
            ClearCategory(Enum.CooldownViewerCategory.TrackedBar)
        end
    )

    state.holder = holder
    state.initialized = true

    settings:HookScript("OnShow", SyncButtonVisibility)
    settings:HookScript("OnHide", SyncButtonVisibility)

    SyncButtonVisibility()
end

local function TryInitialize()
    if state.initialized then return end
    if not GetSettingsFrame() then return end
    CreateButtons()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName ~= "Blizzard_CooldownViewer" then
        return
    end

    C_Timer.After(0, TryInitialize)
    C_Timer.After(0.25, SyncButtonVisibility)
end)
