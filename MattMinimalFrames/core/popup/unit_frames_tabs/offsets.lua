function MMF_BuildUnitFramesOffsetsSection(ctx)
    local unitFramesCol = ctx.parent
    local popup = ctx.popup
    local ACCENT_COLOR = ctx.accentColor
    local CreateMinimalSlider = ctx.createMinimalSlider
    local dropdownLists = ctx.dropdownLists

    local LEFT_COL_X = ctx.leftColX
    local LEFT_COL_WIDTH = ctx.leftColWidth
    local LEFT_LABEL_WIDTH = ctx.leftLabelWidth
    local LEFT_BUTTON_OFFSET = ctx.leftButtonOffset
    local LEFT_BUTTON_WIDTH = ctx.leftButtonWidth
    local LEFT_LOWER_Y_OFFSET = ctx.leftLowerYOffset

    local textOffsetsTitle = unitFramesCol:CreateFontString(nil, "OVERLAY")
    textOffsetsTitle:SetFont("Interface\\AddOns\\MattMinimalFrames\\Fonts\\Naowh.ttf", 12, "")
    textOffsetsTitle:SetPoint("TOPLEFT", LEFT_COL_X, -416 + LEFT_LOWER_Y_OFFSET)
    textOffsetsTitle:SetTextColor(MMF_GetPopupSectionTitleColor())
    textOffsetsTitle:SetText("TEXT OFFSETS")

    local nameUnitOptions = {
        { value = "player", label = "Player" },
        { value = "target", label = "Target" },
        { value = "targettarget", label = "Target of Target" },
        { value = "pet", label = "Pet" },
        { value = "focus", label = "Focus" },
        { value = "boss", label = "Boss" },
    }
    local hpUnitOptions = {
        { value = "player", label = "Player" },
        { value = "target", label = "Target" },
        { value = "targettarget", label = "Target of Target" },
        { value = "pet", label = "Pet" },
        { value = "focus", label = "Focus" },
        { value = "boss", label = "Boss" },
    }
    MattMinimalFramesDB.textOffsetNameUnit = MattMinimalFramesDB.textOffsetNameUnit or "player"
    MattMinimalFramesDB.textOffsetHPUnit = MattMinimalFramesDB.textOffsetHPUnit or "player"

    local function EnsureTextOffsetDropdownSelections()
        local nameValid, hpValid = false, false
        for _, opt in ipairs(nameUnitOptions) do
            if opt.value == MattMinimalFramesDB.textOffsetNameUnit then nameValid = true break end
        end
        for _, opt in ipairs(hpUnitOptions) do
            if opt.value == MattMinimalFramesDB.textOffsetHPUnit then hpValid = true break end
        end
        if not nameValid then MattMinimalFramesDB.textOffsetNameUnit = "player" end
        if not hpValid then MattMinimalFramesDB.textOffsetHPUnit = "player" end
    end
    EnsureTextOffsetDropdownSelections()

    local UpdateVisibleNameOffsetSliders = function() end
    local UpdateVisibleHPOffsetSliders = function() end
    local UpdateHPResetButtonLabel = function() end

    local function GetPopupUnitPrefix(unit)
        if unit == "targettarget" then return "tot" end
        if unit == "boss" then return "boss" end
        if unit == "playerCastBar" then return "playerCastBar" end
        if unit == "targetCastBar" then return "targetCastBar" end
        if unit == "focusCastBar" then return "focusCastBar" end
        return unit
    end

    local nameUnitDropdown = MMF_CreateMinimalDropdown(unitFramesCol, popup, {
        accentColor = ACCENT_COLOR,
        settingKey = "textOffsetNameUnit",
        x = LEFT_COL_X,
        y = -434 + LEFT_LOWER_Y_OFFSET,
        width = LEFT_COL_WIDTH,
        labelWidth = LEFT_LABEL_WIDTH,
        buttonOffset = LEFT_BUTTON_OFFSET,
        buttonWidth = LEFT_BUTTON_WIDTH,
        visibleRows = #nameUnitOptions,
        label = "Name Unit",
        options = nameUnitOptions,
        getValue = function()
            return MattMinimalFramesDB.textOffsetNameUnit
        end,
        onSelect = function(value)
            MattMinimalFramesDB.textOffsetNameUnit = value
            UpdateVisibleNameOffsetSliders()
        end,
    })

    local nameXSliders = {}
    local nameYSliders = {}
    for _, opt in ipairs(nameUnitOptions) do
        local prefix = GetPopupUnitPrefix(opt.value)
        nameXSliders[opt.value] = CreateMinimalSlider(unitFramesCol, "Name X Offset", LEFT_COL_X, -458 + LEFT_LOWER_Y_OFFSET, LEFT_COL_WIDTH, prefix .. "NameTextXOffset", -60, 60, 1, 0, function()
            if MMF_UpdateFrameTextOffsets then MMF_UpdateFrameTextOffsets() end
        end, true)
        nameYSliders[opt.value] = CreateMinimalSlider(unitFramesCol, "Name Y Offset", LEFT_COL_X, -482 + LEFT_LOWER_Y_OFFSET, LEFT_COL_WIDTH, prefix .. "NameTextYOffset", -60, 60, 1, 0, function()
            if MMF_UpdateFrameTextOffsets then MMF_UpdateFrameTextOffsets() end
        end, true)
        nameXSliders[opt.value]:Hide()
        nameYSliders[opt.value]:Hide()
    end

    local function UpdateNameUnitButtonText()
        nameUnitDropdown.SetSelectedValue(MattMinimalFramesDB.textOffsetNameUnit)
    end

    UpdateVisibleNameOffsetSliders = function()
        local current = MattMinimalFramesDB.textOffsetNameUnit
        for _, opt in ipairs(nameUnitOptions) do
            local show = (opt.value == current)
            nameXSliders[opt.value]:SetShown(show)
            nameYSliders[opt.value]:SetShown(show)
        end
    end

    dropdownLists.nameTextUnitList = nameUnitDropdown.list

    local hpUnitDropdown = MMF_CreateMinimalDropdown(unitFramesCol, popup, {
        accentColor = ACCENT_COLOR,
        settingKey = "textOffsetHPUnit",
        x = LEFT_COL_X,
        y = -514 + LEFT_LOWER_Y_OFFSET,
        width = LEFT_COL_WIDTH,
        labelWidth = LEFT_LABEL_WIDTH,
        buttonOffset = LEFT_BUTTON_OFFSET,
        buttonWidth = LEFT_BUTTON_WIDTH,
        visibleRows = #hpUnitOptions,
        label = "HP Unit",
        options = hpUnitOptions,
        getValue = function()
            return MattMinimalFramesDB.textOffsetHPUnit
        end,
        onSelect = function(value)
            MattMinimalFramesDB.textOffsetHPUnit = value
            UpdateVisibleHPOffsetSliders()
            UpdateHPResetButtonLabel()
        end,
    })

    local function ResetSelectedHPPosition()
        if not MattMinimalFramesDB then
            MattMinimalFramesDB = {}
        end

        local selectedUnit = MattMinimalFramesDB.textOffsetHPUnit or "player"
        local prefix = GetPopupUnitPrefix(selectedUnit)
        local defaults = MattMinimalFrames_Defaults or {}

        MattMinimalFramesDB[prefix .. "HPTextXOffset"] = defaults[prefix .. "HPTextXOffset"] or defaults.hpTextXOffset or 0
        MattMinimalFramesDB[prefix .. "HPTextYOffset"] = defaults[prefix .. "HPTextYOffset"] or defaults.hpTextYOffset or 0

        if MattMinimalFramesDB.hpTextPositions then
            if selectedUnit == "boss" then
                for i = 1, 5 do
                    MattMinimalFramesDB.hpTextPositions["boss" .. i] = nil
                end
            else
                MattMinimalFramesDB.hpTextPositions[selectedUnit] = nil
            end
        end
    end

    local hpResetPositionButton = CreateFrame("Button", nil, unitFramesCol, "BackdropTemplate")
    hpResetPositionButton:SetSize(LEFT_COL_WIDTH, 20)
    hpResetPositionButton:SetPoint("TOPLEFT", LEFT_COL_X, -542 + LEFT_LOWER_Y_OFFSET)
    hpResetPositionButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    hpResetPositionButton:SetBackdropColor(0.06, 0.06, 0.08, 1)
    hpResetPositionButton:SetBackdropBorderColor(0.25, 0.25, 0.3, 1)

    local hpResetPositionButtonText = hpResetPositionButton:CreateFontString(nil, "OVERLAY")
    hpResetPositionButtonText:SetFont("Interface\\AddOns\\MattMinimalFrames\\Fonts\\Naowh.ttf", 10, "")
    hpResetPositionButtonText:SetPoint("CENTER")
    hpResetPositionButtonText:SetTextColor(0.85, 0.85, 0.85)
    hpResetPositionButtonText:SetText("Reset HP Position")

    local function GetUnitLabel(options, value)
        for _, opt in ipairs(options) do
            if opt.value == value then
                return opt.label
            end
        end
        return "Selected"
    end

    UpdateHPResetButtonLabel = function()
        local selectedUnit = MattMinimalFramesDB.textOffsetHPUnit or "player"
        local label = GetUnitLabel(hpUnitOptions, selectedUnit)
        hpResetPositionButtonText:SetText("Reset " .. label .. " HP Position")
    end

    hpResetPositionButton:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.6)
        hpResetPositionButtonText:SetTextColor(1, 1, 1)
    end)
    hpResetPositionButton:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.25, 0.25, 0.3, 1)
        hpResetPositionButtonText:SetTextColor(0.85, 0.85, 0.85)
    end)

    local hpXSliders = {}
    local hpYSliders = {}
    for _, opt in ipairs(hpUnitOptions) do
        local prefix = GetPopupUnitPrefix(opt.value)
        hpXSliders[opt.value] = CreateMinimalSlider(unitFramesCol, "HP X Offset", LEFT_COL_X, -572 + LEFT_LOWER_Y_OFFSET, LEFT_COL_WIDTH, prefix .. "HPTextXOffset", -60, 60, 1, 0, function()
            if MMF_UpdateFrameTextOffsets then MMF_UpdateFrameTextOffsets() end
        end, true)
        hpYSliders[opt.value] = CreateMinimalSlider(unitFramesCol, "HP Y Offset", LEFT_COL_X, -598 + LEFT_LOWER_Y_OFFSET, LEFT_COL_WIDTH, prefix .. "HPTextYOffset", -60, 60, 1, 0, function()
            if MMF_UpdateFrameTextOffsets then MMF_UpdateFrameTextOffsets() end
        end, true)
        hpXSliders[opt.value]:Hide()
        hpYSliders[opt.value]:Hide()
    end

    hpResetPositionButton:SetScript("OnClick", function()
        ResetSelectedHPPosition()

        local selectedUnit = MattMinimalFramesDB.textOffsetHPUnit or "player"
        local prefix = GetPopupUnitPrefix(selectedUnit)
        local xVal = tonumber(MattMinimalFramesDB[prefix .. "HPTextXOffset"]) or 0
        local yVal = tonumber(MattMinimalFramesDB[prefix .. "HPTextYOffset"]) or 0

        if hpXSliders[selectedUnit] and hpXSliders[selectedUnit].slider then
            hpXSliders[selectedUnit].slider:SetValue(xVal)
        end
        if hpYSliders[selectedUnit] and hpYSliders[selectedUnit].slider then
            hpYSliders[selectedUnit].slider:SetValue(yVal)
        end

        if MMF_UpdateFrameTextOffsets then
            MMF_UpdateFrameTextOffsets()
        end
        if MMF_ApplyHPTextPositions then
            MMF_ApplyHPTextPositions()
        end
        if MMF_RequestAllFramesUpdate then
            MMF_RequestAllFramesUpdate()
        end
    end)

    local function UpdateHPUnitButtonText()
        hpUnitDropdown.SetSelectedValue(MattMinimalFramesDB.textOffsetHPUnit)
    end

    UpdateVisibleHPOffsetSliders = function()
        local current = MattMinimalFramesDB.textOffsetHPUnit
        for _, opt in ipairs(hpUnitOptions) do
            local show = (opt.value == current)
            hpXSliders[opt.value]:SetShown(show)
            hpYSliders[opt.value]:SetShown(show)
        end
    end

    dropdownLists.hpTextUnitList = hpUnitDropdown.list

    UpdateNameUnitButtonText()
    UpdateVisibleNameOffsetSliders()
    UpdateHPUnitButtonText()
    UpdateHPResetButtonLabel()
    UpdateVisibleHPOffsetSliders()

    local offsetsDivider = unitFramesCol:CreateTexture(nil, "ARTWORK")
    offsetsDivider:SetSize(LEFT_COL_WIDTH, 1)
    offsetsDivider:SetPoint("TOPLEFT", LEFT_COL_X, -404 + LEFT_LOWER_Y_OFFSET)
    offsetsDivider:SetColorTexture(0.42, 0.42, 0.46, 1)
end

