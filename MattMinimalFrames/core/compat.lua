local _, MMF = ...
MMF = MMF or {}

--------------------------------------------------
-- VERSION DETECTION
--------------------------------------------------

local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE or 1
local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5
local WOW_PROJECT_CLASSIC = WOW_PROJECT_CLASSIC or 2

MMF.IsRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
MMF.IsTBC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
MMF.IsClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
MMF.IsClassicEra = MMF.IsClassic or MMF.IsTBC
MMF_IsRetail = MMF.IsRetail
MMF_IsTBC = MMF.IsTBC
MMF_IsClassic = MMF.IsClassic
MMF_IsClassicEra = MMF.IsClassicEra

--------------------------------------------------
-- API COMPATIBILITY
--------------------------------------------------

function MMF.GetSpellName(spellID)
    if _G.GetSpellInfo then
        local name = _G.GetSpellInfo(spellID)
        if name then return name end
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info and info.name then return info.name end
    end
    return nil
end

MMF.IsSpellInRange = _G.IsSpellInRange
if MMF.IsRetail and C_Spell and C_Spell.IsSpellInRange then
    MMF.IsSpellInRange = C_Spell.IsSpellInRange
end

function MMF.GetSpecialization()
    if MMF.IsRetail and _G.GetSpecialization then
        return _G.GetSpecialization()
    end
    return nil
end

--------------------------------------------------
-- RANGE CHECK SPELL TABLES
--------------------------------------------------

MMF.FriendSpells_Retail = {
    DEATHKNIGHT = 47541,
    DRUID       = 8936,
    EVOKER      = 355913,
    MAGE        = 1459,
    MONK        = 116670,
    PALADIN     = 19750,
    PRIEST      = 2061,
    SHAMAN      = 8004,
    WARLOCK     = 5697,
}

MMF.HarmSpells_Retail = {
    DEATHKNIGHT = 49998,
    DEMONHUNTER = 185123,
    DRUID       = 5176,
    EVOKER      = 362969,
    HUNTER      = 75,
    MAGE        = 116,
    MONK        = 117952,
    PALADIN     = 20271,
    PRIEST      = 589,
    ROGUE       = 1752,
    SHAMAN      = 188196,
    WARLOCK     = 234153,
    WARRIOR     = 355,
}

MMF.FriendSpells_TBC = {
    DRUID   = 8936,
    MAGE    = 1459,
    PALADIN = 19750,
    PRIEST  = 2061,
    SHAMAN  = 331,
    WARLOCK = 5697,
}

MMF.HarmSpells_TBC = {
    DRUID   = 5176,
    HUNTER  = 75,
    MAGE    = 116,
    PALADIN = 20271,
    PRIEST  = 589,
    ROGUE   = 1752,
    SHAMAN  = 403,
    WARLOCK = 686,
    WARRIOR = 355,
}

MMF.FriendSpells = MMF.IsClassicEra and MMF.FriendSpells_TBC or MMF.FriendSpells_Retail
MMF.HarmSpells = MMF.IsClassicEra and MMF.HarmSpells_TBC or MMF.HarmSpells_Retail

--------------------------------------------------
-- AURA API COMPATIBILITY
--------------------------------------------------

MMF.HasRetailAuraAPI = (C_UnitAuras ~= nil) and not MMF.IsTBC

local issecretvalue = issecretvalue

local function NotSecretValue(value)
    return not issecretvalue or not issecretvalue(value)
end

local function CloneAuraData(aura, index)
    if type(aura) ~= "table" then
        return nil
    end

    -- C_UnitAuras aura tables can be pooled/reused internally.
    -- Copy fields we rely on so each entry remains stable for the current update pass.
    return {
        name = aura.name,
        icon = aura.icon,
        count = aura.count,
        applications = aura.applications,
        debuffType = aura.debuffType,
        dispelName = aura.dispelName,
        duration = aura.duration,
        expirationTime = aura.expirationTime,
        sourceUnit = aura.sourceUnit,
        source = aura.source,
        caster = aura.caster,
        isFromPlayerOrPlayerPet = aura.isFromPlayerOrPlayerPet,
        isFromPlayerOrPet = aura.isFromPlayerOrPet,
        castByPlayer = aura.castByPlayer,
        isPlayerAura = aura.isPlayerAura,
        isStealable = aura.isStealable,
        canApplyAura = aura.canApplyAura,
        isBossAura = aura.isBossAura,
        isHelpful = aura.isHelpful,
        isHarmful = aura.isHarmful,
        isNameplateOnly = aura.isNameplateOnly,
        spellId = aura.spellId,
        auraInstanceID = aura.auraInstanceID,
        _index = index or aura._index,
    }
end

local function IsAuraDisplayable(aura)
    if type(aura) ~= "table" then
        return false
    end
    -- Match Blizzard 12.0.1 guard rails: skip incomplete aura payloads.
    return aura.name ~= nil and aura.icon ~= nil
end

function MMF.GetUnitAuras(unit, filter)
    local auras = {}
    local filterString = type(filter) == "string" and filter or ""
    local filterHasHelpful = filterString:find("HELPFUL", 1, true) ~= nil
    local filterHasHarmful = filterString:find("HARMFUL", 1, true) ~= nil
    local isHelpful = filterHasHelpful and not filterHasHarmful
    local seenAuraInstanceIDs = {}
    local seenSyntheticKeys = {}

    local function InsertAuraUnique(auraCopy)
        if not auraCopy then
            return false
        end

        local auraInstanceID = auraCopy.auraInstanceID
        if type(auraInstanceID) == "number" then
            if seenAuraInstanceIDs[auraInstanceID] then
                return false
            end
            seenAuraInstanceIDs[auraInstanceID] = true
        else
            local syntheticKey = table.concat({
                tostring(auraCopy.spellId or ""),
                tostring(auraCopy.name or ""),
                tostring(auraCopy.icon or ""),
                tostring(auraCopy.debuffType or ""),
                tostring(auraCopy.isHelpful and 1 or 0),
                tostring(auraCopy.isHarmful and 1 or 0),
            }, "|")
            if seenSyntheticKeys[syntheticKey] then
                return false
            end
            seenSyntheticKeys[syntheticKey] = true
        end

        if type(auraCopy._index) ~= "number" then
            auraCopy._index = #auras + 1
        end
        table.insert(auras, auraCopy)
        return true
    end
    
    if MMF.HasRetailAuraAPI then
        -- Prefer legacy indexed APIs for display fidelity (icon order/tooltips).
        -- This path avoids packed-aura edge cases and keeps index-based tooltip fallback accurate.
        if type(UnitBuff) == "function" and type(UnitDebuff) == "function" and (filterHasHelpful or filterHasHarmful) then
            local auraFunc = isHelpful and UnitBuff or UnitDebuff
            local legacyFilter = filterString:find("PLAYER", 1, true) and "PLAYER" or nil
            for i = 1, 40 do
                local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellId = auraFunc(unit, i, legacyFilter)
                if not name then
                    break
                end
                local auraCopy = {
                    name = name,
                    icon = icon,
                    count = count,
                    applications = count,
                    debuffType = debuffType,
                    duration = duration,
                    expirationTime = expirationTime,
                    source = source,
                    sourceUnit = source,
                    spellId = spellId,
                    isHelpful = isHelpful,
                    isHarmful = not isHelpful,
                    _index = i,
                }
                if IsAuraDisplayable(auraCopy) then
                    InsertAuraUnique(auraCopy)
                end
            end
            return auras
        end

        -- Use Blizzard's slot iteration path when available.
        -- This avoids index desync edge cases and keeps aura reads stable on 12.x.
        if AuraUtil and AuraUtil.ForEachAura then
            local usePackedAura = true
            AuraUtil.ForEachAura(unit, filter, 40, function(aura)
                local auraCopy = CloneAuraData(aura, nil)
                if auraCopy and IsAuraDisplayable(auraCopy) then
                    InsertAuraUnique(auraCopy)
                end
                return #auras >= 40
            end, usePackedAura)
        else
            local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
            if GetAuraDataByIndex then
                for i = 1, 40 do
                    local aura = GetAuraDataByIndex(unit, i, filter)
                    if not aura then
                        break
                    end
                    local auraCopy = CloneAuraData(aura, i)
                    if auraCopy and IsAuraDisplayable(auraCopy) then
                        InsertAuraUnique(auraCopy)
                    end
                end
            else
                local GetAuraSlots = C_UnitAuras.GetAuraSlots
                local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
                local token
                repeat
                    local slots = {GetAuraSlots(unit, filter, 40, token)}
                    token = table.remove(slots, 1)
                    for _, slot in ipairs(slots) do
                        local aura = GetAuraDataBySlot(unit, slot)
                        if aura then
                            local auraCopy = CloneAuraData(aura)
                            if auraCopy and IsAuraDisplayable(auraCopy) then
                                InsertAuraUnique(auraCopy)
                            end
                        end
                    end
                until not token
            end
        end
    else
        if AuraUtil and AuraUtil.ForEachAura then
            local legacyAuraFilter = isHelpful and "HELPFUL" or "HARMFUL"
            AuraUtil.ForEachAura(unit, legacyAuraFilter, 40, function(name, icon, count, debuffType, duration, expirationTime, source, isStealable, _, spellId, ...)
                if name then
                    table.insert(auras, {
                        name = name,
                        icon = icon,
                        count = count,
                        debuffType = debuffType,
                        duration = duration,
                        expirationTime = expirationTime,
                        source = source,
                        spellId = spellId,
                    })
                end
                return #auras >= 40
            end)
        else
            local auraFunc = isHelpful and UnitBuff or UnitDebuff
            for i = 1, 40 do
                local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellId = auraFunc(unit, i)
                if not name then break end
                table.insert(auras, {
                    name = name,
                    icon = icon,
                    count = count,
                    debuffType = debuffType,
                    duration = duration,
                    expirationTime = expirationTime,
                    source = source,
                    spellId = spellId,
                })
            end
        end
    end
    
    return auras
end

function MMF.SetAuraCooldown(cooldownFrame, auraData, unit)
    if not cooldownFrame then return end
    
    local auraInstanceID = auraData and auraData.auraInstanceID or nil
    if MMF.HasRetailAuraAPI and auraInstanceID then
        local GetAuraDuration = C_UnitAuras.GetAuraDuration
        local auraDuration = GetAuraDuration(unit, auraInstanceID)
        if auraDuration and cooldownFrame.SetCooldownFromDurationObject then
            cooldownFrame:SetCooldownFromDurationObject(auraDuration)
            return
        end
    end
    
    -- Check if duration is a secret value to avoid taint
    if type(auraData) == "table"
        and NotSecretValue(auraData.duration)
        and NotSecretValue(auraData.expirationTime) then
        local ok, startTime, duration = pcall(function()
            if auraData.duration and auraData.duration > 0 and auraData.expirationTime then
                return auraData.expirationTime - auraData.duration, auraData.duration
            end
            return nil, nil
        end)
        if ok and startTime and duration then
            CooldownFrame_Set(cooldownFrame, startTime, duration, true)
            return
        end
    end
    cooldownFrame:Clear()
end

function MMF.GetAuraCount(auraData, unit)
    local auraInstanceID = auraData and auraData.auraInstanceID or nil
    if MMF.HasRetailAuraAPI and auraInstanceID then
        local GetAuraApplicationDisplayCount = C_UnitAuras.GetAuraApplicationDisplayCount
        if GetAuraApplicationDisplayCount then
            local count = GetAuraApplicationDisplayCount(unit, auraInstanceID, 2, 999)
            if NotSecretValue(count) and type(count) == "number" then
                return count
            end
        end
        if NotSecretValue(auraData and auraData.applications) and type(auraData.applications) == "number" then
            return auraData.applications
        end
    end
    if NotSecretValue(auraData and auraData.count) and type(auraData.count) == "number" then
        return auraData.count
    end
    return 0
end

--------------------------------------------------
-- FEATURE FLAGS
--------------------------------------------------

MMF.HasDeathKnight = MMF.IsRetail
MMF.HasFocusFrame = true
MMF.HasSpecialization = MMF.IsRetail

--------------------------------------------------
-- DEBUG
--------------------------------------------------

function MMF.PrintVersion()
    local version = "Unknown"
    if MMF.IsRetail then version = "Retail"
    elseif MMF.IsTBC then version = "TBC Anniversary"
    elseif MMF.IsClassic then version = "Classic Era"
    end
    print("MattMinimalFrames running on: " .. version)
end

_G.MMF_Compat = MMF
