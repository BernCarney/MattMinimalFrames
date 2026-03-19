function MMF_BuildAurasPowerPowerSection(ctx)
    local root = ctx.parent
    local CreateMinimalCheckbox = ctx.createMinimalCheckbox
    local CreateMinimalSlider = ctx.createMinimalSlider
    local RESOURCE_COL_X = ctx.resourceColX
    local isPlayerDruid = ctx.isPlayerDruid
    local RefreshPowerFrames = ctx.refreshPowerFrames or function() end
    local accent = (MMF_GetPopupAccentColor and MMF_GetPopupAccentColor()) or { 0.6, 0.4, 0.9 }

    local generalTitle = root:CreateFontString(nil, "OVERLAY")
    generalTitle:SetFont("Interface\\AddOns\\MattMinimalFrames\\Fonts\\Naowh.ttf", 12, "")
    generalTitle:SetPoint("TOPLEFT", RESOURCE_COL_X, -12)
    generalTitle:SetTextColor(MMF_GetPopupSectionTitleColor())
    generalTitle:SetText("RESOURCES")

    local playerTitle = root:CreateFontString(nil, "OVERLAY")
    playerTitle:SetFont("Interface\\AddOns\\MattMinimalFrames\\Fonts\\Naowh.ttf", 11, "")
    playerTitle:SetPoint("TOPLEFT", RESOURCE_COL_X, -52)
    playerTitle:SetTextColor(MMF_GetPopupSectionTitleColor())
    playerTitle:SetText("PLAYER")

    local playerColorPowerTextCheck = nil
    local targetColorPowerTextCheck = nil
    local playerPercentPowerTextCheck = nil
    local playerDruidManaPowerTextCheck = nil
    local targetPercentPowerTextCheck = nil
    local playerPowerBarCheck = nil
    local targetPowerBarCheck = nil
    local playerPowerWidthSlider = nil
    local playerPowerHeightSlider = nil
    local targetPowerWidthSlider = nil
    local targetPowerHeightSlider = nil

    local function ResetPowerTextPosition(unit)
        if unit ~= "player" and unit ~= "target" then
            return
        end
        if not MattMinimalFramesDB then
            MattMinimalFramesDB = {}
        end
        if MattMinimalFramesDB.powerTextPositions then
            MattMinimalFramesDB.powerTextPositions[unit] = nil
        end
        if MMF_ApplyPowerTextPositions then
            MMF_ApplyPowerTextPositions()
        end
        RefreshPowerFrames()
    end

    local function CreatePowerTextResetButton(x, y, onClick)
        local button = CreateFrame("Button", nil, root, "BackdropTemplate")
        button:SetSize(200, 22)
        button:SetPoint("TOPLEFT", x, y)
        button:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        button:SetBackdropColor(0.08, 0.08, 0.1, 1)
        button:SetBackdropBorderColor(0.15, 0.15, 0.18, 1)

        local text = button:CreateFontString(nil, "OVERLAY")
        text:SetFont("Interface\\AddOns\\MattMinimalFrames\\Fonts\\Naowh.ttf", 10, "")
        text:SetPoint("CENTER")
        text:SetTextColor(0.82, 0.82, 0.86)
        text:SetText("RESET POWER POSITION")

        button:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.11, 0.11, 0.14, 1)
            self:SetBackdropBorderColor(accent[1], accent[2], accent[3], 0.8)
            text:SetTextColor(1, 1, 1)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetText("Reset Power Text Position", 1, 1, 1)
            GameTooltip:AddLine("Resets dragged power text to default for this unit.", 0.75, 0.75, 0.75)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.08, 0.08, 0.1, 1)
            self:SetBackdropBorderColor(0.15, 0.15, 0.18, 1)
            text:SetTextColor(0.82, 0.82, 0.86)
            GameTooltip:Hide()
        end)
        button:SetScript("OnClick", function()
            if type(onClick) == "function" then
                onClick()
            end
        end)

        return button
    end

    if MattMinimalFramesDB.showPlayerPowerPercentText == nil then
        MattMinimalFramesDB.showPlayerPowerPercentText = (MattMinimalFramesDB.showPowerPercentText == true)
    end
    if MattMinimalFramesDB.showTargetPowerPercentText == nil then
        MattMinimalFramesDB.showTargetPowerPercentText = (MattMinimalFramesDB.showPowerPercentText == true)
    end

    local function SetDependentCheckboxState(container, enabled)
        if not container then return end
        local checkbox = container.checkbox
        if checkbox then
            checkbox:EnableMouse(enabled)
            checkbox:SetAlpha(enabled and 1 or 0.45)
            if checkbox.check then
                checkbox.check:SetAlpha(enabled and 1 or 0.35)
            end
        end
        container:SetAlpha(enabled and 1 or 0.55)
    end

    local function SetDependentSliderState(container, enabled)
        if not container then return end
        container:SetAlpha(enabled and 1 or 0.45)
        if container.slider then
            container.slider:SetEnabled(enabled)
            container.slider:EnableMouse(enabled)
        end
        if container.valueText then
            container.valueText:SetEnabled(enabled)
            container.valueText:EnableMouse(enabled)
        end
    end

    local function UpdatePowerTextDependencies()
        local playerTextEnabled = (MattMinimalFramesDB.showPlayerPowerText == true or MattMinimalFramesDB.showPlayerPowerText == 1)
        local targetTextEnabled = (MattMinimalFramesDB.showTargetPowerText == true or MattMinimalFramesDB.showTargetPowerText == 1)
        SetDependentCheckboxState(playerColorPowerTextCheck, playerTextEnabled)
        SetDependentCheckboxState(playerPercentPowerTextCheck, playerTextEnabled)
        SetDependentCheckboxState(playerDruidManaPowerTextCheck, playerTextEnabled and isPlayerDruid)
        SetDependentCheckboxState(targetColorPowerTextCheck, targetTextEnabled)
        SetDependentCheckboxState(targetPercentPowerTextCheck, targetTextEnabled)
    end
    MMF_RefreshPowerTextOptionStates = UpdatePowerTextDependencies

    local function UpdatePowerBarSizeDependencies()
        local playerBarEnabled = (MattMinimalFramesDB.showPlayerPowerBar == true or MattMinimalFramesDB.showPlayerPowerBar == 1)
        local targetBarEnabled = (MattMinimalFramesDB.showTargetPowerBar == true or MattMinimalFramesDB.showTargetPowerBar == 1)
        SetDependentSliderState(playerPowerWidthSlider, playerBarEnabled)
        SetDependentSliderState(playerPowerHeightSlider, playerBarEnabled)
        SetDependentSliderState(targetPowerWidthSlider, targetBarEnabled)
        SetDependentSliderState(targetPowerHeightSlider, targetBarEnabled)
    end

    playerPowerBarCheck = CreateMinimalCheckbox(root, "Power Bar", RESOURCE_COL_X, -72, "showPlayerPowerBar", true, function()
        RefreshPowerFrames()
        UpdatePowerBarSizeDependencies()
    end)

    CreateMinimalCheckbox(root, "Power Text", RESOURCE_COL_X, -96, "showPlayerPowerText", false, function()
        RefreshPowerFrames()
        UpdatePowerTextDependencies()
    end)

    playerColorPowerTextCheck = CreateMinimalCheckbox(root, "Color Text by Resource", RESOURCE_COL_X, -120, "colorPlayerPowerTextByResource", false, function()
        RefreshPowerFrames()
    end)

    playerPercentPowerTextCheck = CreateMinimalCheckbox(root, "Power Text: Percent", RESOURCE_COL_X, -144, "showPlayerPowerPercentText", false, function()
        RefreshPowerFrames()
    end)

    local playerResetY = -168
    local playerTextScaleY = -196
    local playerWidthY = -220
    local playerHeightY = -244
    local targetDividerY = -272
    local targetTitleY = -284
    local targetPowerBarY = -304
    local targetPowerTextY = -328
    local targetColorTextY = -352
    local targetPercentTextY = -376
    local targetResetY = -400
    local targetTextScaleY = -428
    local targetWidthY = -452
    local targetHeightY = -476

    if isPlayerDruid then
        playerDruidManaPowerTextCheck = CreateMinimalCheckbox(root, "Mana Resource Only", RESOURCE_COL_X, -168, "showDruidManaPowerText", false, function()
            RefreshPowerFrames()
        end)
        playerResetY = -192
        playerTextScaleY = -220
        playerWidthY = -244
        playerHeightY = -268
        targetDividerY = -296
        targetTitleY = -308
        targetPowerBarY = -328
        targetPowerTextY = -352
        targetColorTextY = -376
        targetPercentTextY = -400
        targetResetY = -424
        targetTextScaleY = -452
        targetWidthY = -476
        targetHeightY = -500
    end

    CreatePowerTextResetButton(RESOURCE_COL_X, playerResetY, function()
        ResetPowerTextPosition("player")
    end)

    CreatePowerTextResetButton(RESOURCE_COL_X, targetResetY, function()
        ResetPowerTextPosition("target")
    end)

    CreateMinimalSlider(root, "Text Scale", RESOURCE_COL_X, playerTextScaleY, 200, "playerPowerTextScale", 0.5, 2.0, 0.05, 1.0, function()
        RefreshPowerFrames()
    end, false)

    playerPowerWidthSlider = CreateMinimalSlider(root, "Power Bar Width", RESOURCE_COL_X, playerWidthY, 200, "playerPowerBarWidth", 30, 250, 1, 73, function(value)
        if MMF_SetPowerBarSize then
            MMF_SetPowerBarSize(value, MattMinimalFramesDB.playerPowerBarHeight or MattMinimalFramesDB.powerBarHeight or 5, "player")
        end
    end, true)

    playerPowerHeightSlider = CreateMinimalSlider(root, "Power Bar Height", RESOURCE_COL_X, playerHeightY, 200, "playerPowerBarHeight", 3, 15, 1, 5, function(value)
        if MMF_SetPowerBarSize then
            MMF_SetPowerBarSize(MattMinimalFramesDB.playerPowerBarWidth or MattMinimalFramesDB.powerBarWidth or 73, value, "player")
        end
    end, true)

    local targetDivider = root:CreateTexture(nil, "ARTWORK")
    targetDivider:SetSize(200, 1)
    targetDivider:SetPoint("TOPLEFT", RESOURCE_COL_X, targetDividerY)
    targetDivider:SetColorTexture(0.12, 0.12, 0.15, 1)

    local targetTitle = root:CreateFontString(nil, "OVERLAY")
    targetTitle:SetFont("Interface\\AddOns\\MattMinimalFrames\\Fonts\\Naowh.ttf", 11, "")
    targetTitle:SetPoint("TOPLEFT", RESOURCE_COL_X, targetTitleY)
    targetTitle:SetTextColor(MMF_GetPopupSectionTitleColor())
    targetTitle:SetText("TARGET")

    targetPowerBarCheck = CreateMinimalCheckbox(root, "Power Bar", RESOURCE_COL_X, targetPowerBarY, "showTargetPowerBar", false, function()
        RefreshPowerFrames()
        UpdatePowerBarSizeDependencies()
    end)

    CreateMinimalCheckbox(root, "Power Text", RESOURCE_COL_X, targetPowerTextY, "showTargetPowerText", false, function()
        RefreshPowerFrames()
        UpdatePowerTextDependencies()
    end)

    targetColorPowerTextCheck = CreateMinimalCheckbox(root, "Color Text by Resource", RESOURCE_COL_X, targetColorTextY, "colorTargetPowerTextByResource", false, function()
        RefreshPowerFrames()
    end)
    targetPercentPowerTextCheck = CreateMinimalCheckbox(root, "Power Text: Percent", RESOURCE_COL_X, targetPercentTextY, "showTargetPowerPercentText", false, function()
        RefreshPowerFrames()
    end)

    UpdatePowerTextDependencies()

    CreateMinimalSlider(root, "Text Scale", RESOURCE_COL_X, targetTextScaleY, 200, "targetPowerTextScale", 0.5, 2.0, 0.05, 1.0, function()
        RefreshPowerFrames()
    end, false)

    targetPowerWidthSlider = CreateMinimalSlider(root, "Power Bar Width", RESOURCE_COL_X, targetWidthY, 200, "targetPowerBarWidth", 30, 250, 1, 73, function(value)
        if MMF_SetPowerBarSize then
            MMF_SetPowerBarSize(value, MattMinimalFramesDB.targetPowerBarHeight or MattMinimalFramesDB.powerBarHeight or 5, "target")
        end
    end, true)

    targetPowerHeightSlider = CreateMinimalSlider(root, "Power Bar Height", RESOURCE_COL_X, targetHeightY, 200, "targetPowerBarHeight", 3, 15, 1, 5, function(value)
        if MMF_SetPowerBarSize then
            MMF_SetPowerBarSize(MattMinimalFramesDB.targetPowerBarWidth or MattMinimalFramesDB.powerBarWidth or 73, value, "target")
        end
    end, true)

    UpdatePowerBarSizeDependencies()
end
