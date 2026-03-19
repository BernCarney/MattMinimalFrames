function MMF_BuildUnitFramesLayoutSection(ctx)
    local unitFramesCol = ctx.parent
    local popup = ctx.popup
    local ACCENT_COLOR = ctx.accentColor
    local CreateMinimalCheckbox = ctx.createMinimalCheckbox or MMF_CreateMinimalCheckbox
    local CreateMinimalSlider = ctx.createMinimalSlider
    local dropdownLists = ctx.dropdownLists

    local LEFT_COL_X = ctx.leftColX
    local LEFT_COL_WIDTH = ctx.leftColWidth
    local LEFT_LABEL_WIDTH = ctx.leftLabelWidth
    local LEFT_BUTTON_OFFSET = ctx.leftButtonOffset
    local LEFT_BUTTON_WIDTH = ctx.leftButtonWidth

    local function GetPopupUnitPrefix(unit)
        if unit == "targettarget" then return "tot" end
        if unit == "boss" then return "boss" end
        if unit == "playerCastBar" then return "playerCastBar" end
        if unit == "targetCastBar" then return "targetCastBar" end
        if unit == "focusCastBar" then return "focusCastBar" end
        return unit
    end

    local scaleUnitOptions = {
        { value = "player", label = "Player" },
        { value = "target", label = "Target" },
        { value = "targettarget", label = "Target of Target" },
        { value = "pet", label = "Pet" },
        { value = "focus", label = "Focus" },
        { value = "boss", label = "Boss" },
        { value = "playerCastBar", label = "Player Cast Bar" },
        { value = "targetCastBar", label = "Target Cast Bar" },
        { value = "focusCastBar", label = "Focus Cast Bar" },
    }
    MattMinimalFramesDB.frameScaleUnit = MattMinimalFramesDB.frameScaleUnit or "player"

    local function EnsureScaleUnitSelection()
        local valid = false
        for _, opt in ipairs(scaleUnitOptions) do
            if opt.value == MattMinimalFramesDB.frameScaleUnit then
                valid = true
                break
            end
        end
        if not valid then
            MattMinimalFramesDB.frameScaleUnit = "player"
        end
    end
    EnsureScaleUnitSelection()

    local frameScaleTitle = unitFramesCol:CreateFontString(nil, "OVERLAY")
    frameScaleTitle:SetFont("Interface\\AddOns\\MattMinimalFrames\\Fonts\\Naowh.ttf", 12, "")
    frameScaleTitle:SetPoint("TOPLEFT", LEFT_COL_X, -12)
    frameScaleTitle:SetTextColor(MMF_GetPopupSectionTitleColor())
    frameScaleTitle:SetText("FRAME SCALE")

    local FRAME_SCALE_X_MIN = 0.1
    local FRAME_SCALE_X_MAX = 6.0
    local FRAME_SCALE_Y_MIN = 0.1
    local FRAME_SCALE_Y_MAX = 10.0

    local scaleXSliders = {}
    local scaleYSliders = {}
    for _, opt in ipairs(scaleUnitOptions) do
        local prefix = GetPopupUnitPrefix(opt.value)
        scaleXSliders[opt.value] = CreateMinimalSlider(
            unitFramesCol,
            "Scale X",
            LEFT_COL_X,
            -64,
            LEFT_COL_WIDTH,
            prefix .. "FrameScaleX",
            FRAME_SCALE_X_MIN,
            FRAME_SCALE_X_MAX,
            0.05,
            1.0,
            function()
                if MMF_UpdateFrameScale then
                    MMF_UpdateFrameScale(opt.value)
                end
            end,
            false
        )
        scaleYSliders[opt.value] = CreateMinimalSlider(
            unitFramesCol,
            "Scale Y",
            LEFT_COL_X,
            -88,
            LEFT_COL_WIDTH,
            prefix .. "FrameScaleY",
            FRAME_SCALE_Y_MIN,
            FRAME_SCALE_Y_MAX,
            0.05,
            1.0,
            function()
                if MMF_UpdateFrameScale then
                    MMF_UpdateFrameScale(opt.value)
                end
            end,
            false
        )
        scaleXSliders[opt.value]:Hide()
        scaleYSliders[opt.value]:Hide()
    end

    local function UpdateVisibleScaleSliders()
        local current = MattMinimalFramesDB.frameScaleUnit
        for _, opt in ipairs(scaleUnitOptions) do
            local show = (opt.value == current)
            scaleXSliders[opt.value]:SetShown(show)
            scaleYSliders[opt.value]:SetShown(show)
        end
    end

    local scaleUnitDropdown = MMF_CreateMinimalDropdown(unitFramesCol, popup, {
        accentColor = ACCENT_COLOR,
        settingKey = "frameScaleUnit",
        x = LEFT_COL_X,
        y = -40,
        width = LEFT_COL_WIDTH,
        labelWidth = LEFT_LABEL_WIDTH,
        buttonOffset = LEFT_BUTTON_OFFSET,
        buttonWidth = LEFT_BUTTON_WIDTH,
        visibleRows = #scaleUnitOptions,
        label = "Scale Unit",
        options = scaleUnitOptions,
        getValue = function()
            return MattMinimalFramesDB.frameScaleUnit
        end,
        onSelect = function(value)
            MattMinimalFramesDB.frameScaleUnit = value
            UpdateVisibleScaleSliders()
        end,
    })
    dropdownLists.scaleUnitList = scaleUnitDropdown.list
    UpdateVisibleScaleSliders()

    local fillDivider = unitFramesCol:CreateTexture(nil, "ARTWORK")
    fillDivider:SetSize(LEFT_COL_WIDTH, 1)
    fillDivider:SetPoint("TOPLEFT", LEFT_COL_X, -120)
    fillDivider:SetColorTexture(0.42, 0.42, 0.46, 1)

    CreateMinimalCheckbox(
        unitFramesCol,
        "Health Fill Top to Bottom",
        LEFT_COL_X,
        -136,
        "healthFillTopToBottom",
        false,
        function()
            if MMF_ApplyHealthFillDirections then
                MMF_ApplyHealthFillDirections()
            end
            if MMF_RequestAllFramesUpdate then
                MMF_RequestAllFramesUpdate()
            end
        end
    )

end

