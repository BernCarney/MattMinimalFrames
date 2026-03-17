function MMF_BuildUnitFramesCastBarsSection(ctx)
    local unitFramesCol = ctx.parent
    local ACCENT_COLOR = ctx.accentColor
    local CreateMinimalCheckbox = ctx.createMinimalCheckbox
    local CreateMinimalColorPicker = ctx.createMinimalColorPicker or MMF_CreateMinimalColorPicker

    local MIDDLE_COL_X = ctx.middleColX
    local MIDDLE_COL_WIDTH = ctx.middleColWidth
    local MIDDLE_LABEL_WIDTH = ctx.middleLabelWidth
    local MIDDLE_BUTTON_OFFSET = ctx.middleButtonOffset
    local MIDDLE_BUTTON_WIDTH = ctx.middleButtonWidth
    local RIGHT_COL_Y_OFFSET = ctx.rightColYOffset
    local function RefreshCastBars()
        if MMF_RequestAllFramesUpdate then
            MMF_RequestAllFramesUpdate()
            return
        end
        if MMF_GetAllFrames and MMF_UpdateUnitFrame then
            for _, frame in ipairs(MMF_GetAllFrames()) do
                if frame and (frame.unit == "player" or frame.unit == "target" or frame.unit == "focus") then
                    MMF_UpdateUnitFrame(frame)
                end
            end
        end
    end

    local castBarsTitle = unitFramesCol:CreateFontString(nil, "OVERLAY")
    castBarsTitle:SetFont("Interface\\AddOns\\MattMinimalFrames\\Fonts\\Naowh.ttf", 12, "")
    castBarsTitle:SetPoint("TOPLEFT", MIDDLE_COL_X, -140 + RIGHT_COL_Y_OFFSET)
    castBarsTitle:SetTextColor(MMF_GetPopupSectionTitleColor())
    castBarsTitle:SetText("CAST BARS")

    CreateMinimalCheckbox(unitFramesCol, "Player Cast Bar", MIDDLE_COL_X, -164 + RIGHT_COL_Y_OFFSET, "showPlayerCastBar", true, function()
        StaticPopup_Show("MMF_RELOADUI")
    end)

    CreateMinimalCheckbox(unitFramesCol, "Target Cast Bar", MIDDLE_COL_X, -188 + RIGHT_COL_Y_OFFSET, "showTargetCastBar", true, function()
        StaticPopup_Show("MMF_RELOADUI")
    end)

    CreateMinimalCheckbox(unitFramesCol, "Focus Cast Bar", MIDDLE_COL_X, -212 + RIGHT_COL_Y_OFFSET, "showFocusCastBar", true, function()
        StaticPopup_Show("MMF_RELOADUI")
    end)

    CreateMinimalCheckbox(unitFramesCol, "Hide Blizzard Cast Bar", MIDDLE_COL_X, -236 + RIGHT_COL_Y_OFFSET, "hideBlizzardPlayerCastBar", false, function()
        if MMF_UpdateBlizzardPlayerCastBarVisibility then
            MMF_UpdateBlizzardPlayerCastBarVisibility()
        end
        StaticPopup_Show("MMF_RELOADUI")
    end)

    if CreateMinimalColorPicker then
        CreateMinimalColorPicker(unitFramesCol, {
            accentColor = ACCENT_COLOR,
            x = MIDDLE_COL_X,
            y = -260 + RIGHT_COL_Y_OFFSET,
            width = MIDDLE_COL_WIDTH,
            height = 24,
            labelWidth = MIDDLE_LABEL_WIDTH,
            buttonOffset = MIDDLE_BUTTON_OFFSET,
            buttonWidth = MIDDLE_BUTTON_WIDTH,
            label = "Cast Bar Color",
            resetLabel = "RESET",
            getColor = function()
                local key = (MattMinimalFramesDB and MattMinimalFramesDB.castBarColor)
                    or (MattMinimalFrames_Defaults and MattMinimalFrames_Defaults.castBarColor)
                    or "yellow"
                local r, g, b = MMF_Config.GetCastBarColor(key)
                return r, g, b
            end,
            onColorChanged = function(r, g, b)
                if not MattMinimalFramesDB then MattMinimalFramesDB = {} end
                MattMinimalFramesDB.castBarColor = "custom"
                MattMinimalFramesDB.castBarCustomColorR = r
                MattMinimalFramesDB.castBarCustomColorG = g
                MattMinimalFramesDB.castBarCustomColorB = b
                RefreshCastBars()
            end,
            onReset = function()
                if not MattMinimalFramesDB then MattMinimalFramesDB = {} end
                local d = MattMinimalFrames_Defaults or {}
                MattMinimalFramesDB.castBarColor = d.castBarColor or "yellow"
                MattMinimalFramesDB.castBarCustomColorR = d.castBarCustomColorR or 1.0
                MattMinimalFramesDB.castBarCustomColorG = d.castBarCustomColorG or 1.0
                MattMinimalFramesDB.castBarCustomColorB = d.castBarCustomColorB or 0.0
                RefreshCastBars()
            end,
            isDefault = function()
                local db = MattMinimalFramesDB or {}
                local d = MattMinimalFrames_Defaults or {}
                local function NearlyEqual(a, b)
                    return math.abs((tonumber(a) or 0) - (tonumber(b) or 0)) < 0.0001
                end
                return (db.castBarColor or d.castBarColor or "yellow") == (d.castBarColor or "yellow")
                    and NearlyEqual(db.castBarCustomColorR or d.castBarCustomColorR or 1.0, d.castBarCustomColorR or 1.0)
                    and NearlyEqual(db.castBarCustomColorG or d.castBarCustomColorG or 1.0, d.castBarCustomColorG or 1.0)
                    and NearlyEqual(db.castBarCustomColorB or d.castBarCustomColorB or 0.0, d.castBarCustomColorB or 0.0)
            end,
        })
    end

end

