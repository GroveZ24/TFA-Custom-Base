if not CLIENT then return end

-- Проверка, показывать ли IR-режим (можно убрать, если база сама проверяет)
local function ShouldShowLaser(ply, ir_mode)
    if not IsValid(ply) then return false end
    if not ply.nvgbattery or ply.nvgbattery <= 0 then return false end
    if ir_mode then
        return ply.vrnvgequipped and not ply.vrnvgbroken and ply.vrnvgflipped
    else
        return true
    end
end

-- Переключение режима лазера через модсвич, как у фонарика
hook.Add("PlayerSwitchFlashlight", "TFA_LaserModSwitch", function(ply, toEnable)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return false end
    if not wep.HasLaser then return false end

    if not wep.IRLaserMode then
        wep.IRLaserMode = "ir"
    else
        wep.IRLaserMode = (wep.IRLaserMode == "ir") and "normal" or "ir"
    end

    return false
end)
