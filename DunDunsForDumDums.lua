-- Author: I_AM_T3X
-- Addon: DunDuns for DumDums
-- Tracks Shard of Dundun (3376) and Unalloyed Abundance (3377)

local addonName = "DunDunsForDumDums"
local addon = {}

-- Database setup
DunDunsForDumDumsDB = DunDunsForDumDumsDB or {}
local db = DunDunsForDumDumsDB

-- Main Frame
local frame = CreateFrame("Frame", "DunDunsFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(220, 210)
frame:SetPoint(db.point or "CENTER", UIParent, db.relativePoint or "CENTER", db.x or 0, db.y or 0)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, x, y = self:GetPoint()
    db.point = point
    db.relativePoint = relativePoint
    db.x = x
    db.y = y
end)
frame:SetFrameStrata("HIGH")

-- Title - Centered vertically in title bar
frame.TitleBg:SetHeight(30)
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 4)
frame.title:SetText("DunDuns for DumDums")

-- Close button
frame.CloseButton:SetScript("OnClick", function() frame:Hide() end)

-- Event locations - Midnight Zone Map IDs with Coordinates
local eventLocations = {
    ["Eversong"] = { mapID = 2395, x = 0.5676, y = 0.6579 },
    ["Zul'Aman"] = { mapID = 2437, x = 0.3167, y = 0.2621 },
    ["Harandar"] = { mapID = 2413, x = 0.6613, y = 0.6166 },
    ["Voidstorm"] = { mapID = 2405, x = 0.3880, y = 0.5326 },
}

-- Button creator
local function CreateLocationButton(name, parent, point, x, y)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(85, 25)
    btn:SetPoint(point, parent, point, x, y)
    btn:SetText(name)
    btn:SetNormalFontObject("GameFontNormalSmall")
    
    btn:SetScript("OnClick", function()
        local loc = eventLocations[name]
        if loc then
            local uiMapPoint = UiMapPoint.CreateFromCoordinates(loc.mapID, loc.x, loc.y)
            C_Map.SetUserWaypoint(uiMapPoint)
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            print("|cFF00FF00DunDuns for DumDums:|r Pin set to |cFFFFFF00" .. name .. "|r!")
        else
            print("|cFFFF0000DunDuns for DumDums:|r No coordinates for " .. name)
        end
    end)
    
    return btn
end

-- Create 4 buttons (2x2 grid)
CreateLocationButton("Eversong", frame, "TOPLEFT", 20, -35)
CreateLocationButton("Zul'Aman", frame, "TOPRIGHT", -20, -35)
CreateLocationButton("Harandar", frame, "TOPLEFT", 20, -65)
CreateLocationButton("Voidstorm", frame, "TOPRIGHT", -20, -65)

-- Central Shard of Dundun Tracker (Currency 3376)
local trackerBox = CreateFrame("Frame", nil, frame)
trackerBox:SetSize(54, 54)
trackerBox:SetPoint("TOP", frame, "TOP", 0, -95)

-- Icon Texture (ID: 134569)
trackerBox.icon = trackerBox:CreateTexture(nil, "ARTWORK")
trackerBox.icon:SetSize(50, 50)
trackerBox.icon:SetPoint("CENTER", trackerBox, "CENTER", 0, 0)
trackerBox.icon:SetTexture(134569)
trackerBox.icon:SetTexCoord(0, 1, 0, 1)

-- Amount text (Bottom Right of Icon)
trackerBox.amount = trackerBox:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge")
trackerBox.amount:SetPoint("BOTTOMRIGHT", trackerBox.icon, "BOTTOMRIGHT", -2, 2)
trackerBox.amount:SetText("0")
trackerBox.amount:SetJustifyH("RIGHT")
trackerBox.amount:SetShadowOffset(2, -2)
trackerBox.amount:SetShadowColor(0, 0, 0, 0.9)

-- Unalloyed Abundance Tracker (Currency 3377) - Bottom Left
local abundanceIcon = frame:CreateTexture(nil, "ARTWORK")
abundanceIcon:SetSize(20, 20)
abundanceIcon:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 12)
abundanceIcon:SetTexture(5041790)
abundanceIcon:SetTexCoord(0, 1, 0, 1)

-- Amount text (to the right of icon)
local abundanceText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
abundanceText:SetPoint("LEFT", abundanceIcon, "RIGHT", 5, 0)
abundanceText:SetText("0")
abundanceText:SetTextColor(0.8, 0.6, 1, 1)

-- Clear Pins Button (Bottom Right)
local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
clearBtn:SetSize(90, 25)
clearBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
clearBtn:SetText("Clear Pins")
clearBtn:SetNormalFontObject("GameFontNormalSmall")

clearBtn:SetScript("OnClick", function()
    C_Map.ClearUserWaypoint()
    C_SuperTrack.SetSuperTrackedUserWaypoint(false)
    print("|cFF00FF00DunDuns for DumDums:|r Map pins cleared!")
end)

-- Update function
local function UpdateCurrencies()
    -- Shard of Dundun - 3376
    local dundunInfo = C_CurrencyInfo.GetCurrencyInfo(3376)
    if dundunInfo then
        trackerBox.amount:SetText(dundunInfo.quantity)
    else
        trackerBox.amount:SetText("0")
    end
    
    -- Unalloyed Abundance - 3377
    local abundanceInfo = C_CurrencyInfo.GetCurrencyInfo(3377)
    if abundanceInfo then
        abundanceText:SetText(abundanceInfo.quantity)
    else
        abundanceText:SetText("0")
    end
end

-- Tooltip for abundance icon
abundanceIcon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local abundanceInfo = C_CurrencyInfo.GetCurrencyInfo(3377)
    if abundanceInfo then
        GameTooltip:SetText(abundanceInfo.name .. ": " .. abundanceInfo.quantity, 0.8, 0.6, 1)
        if abundanceInfo.description then
            GameTooltip:AddLine(abundanceInfo.description, 0.8, 0.8, 0.8, true)
        end
    else
        GameTooltip:SetText("Unalloyed Abundance: 0", 0.8, 0.6, 1)
    end
    GameTooltip:Show()
end)
abundanceIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Events
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        UpdateCurrencies()
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        local currencyID = ...
        if currencyID == 3376 or currencyID == 3377 or currencyID == nil then
            UpdateCurrencies()
        end
    end
end)

-- Slash commands
SLASH_DUNDUNS1 = "/dunduns"
SLASH_DUNDUNS2 = "/dd"
SlashCmdList["DUNDUNS"] = function()
    if frame:IsShown() then 
        frame:Hide() 
    else 
        frame:Show() 
        UpdateCurrencies() 
    end
end

-- Hide frame when world map is open to prevent overlap
WorldMapFrame:HookScript("OnShow", function()
    frame.wasVisible = frame:IsShown()
    if frame.wasVisible then
        frame:Hide()
    end
end)

WorldMapFrame:HookScript("OnHide", function()
    if frame.wasVisible then
        frame:Show()
        frame.wasVisible = nil
    end
end)

print("|cFF00FF00DunDuns for DumDums|r loaded. Type /dunduns to toggle.")