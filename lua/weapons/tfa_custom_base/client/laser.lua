if not CLIENT then return end

local function ShouldShowLaser(ply, ir_mode)
    if not IsValid(ply) then return false end
    if ply.vrnvgbroken then return false end
    if not ply.nvgbattery or ply.nvgbattery <= 0 then return false end

    if ir_mode then
        return ply.vrnvgflipped
    else
        return true
    end
end

concommand.Add("cl_tfa_laser_switch", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    -- Toggle mode
    if not wep.IRLaserMode then
        wep.IRLaserMode = "ir"
    else
        wep.IRLaserMode = (wep.IRLaserMode == "ir") and "normal" or "ir"
    end

    -- Play sound
    local snd = nil
    if wep.LaserSoundToggleOn or wep.LaserSoundToggleOff then
        -- If lines in weapon/attachment
        snd = wep.LaserSoundToggleOn or wep.LaserSoundToggleOff
    else
        -- Default sound
        snd = "TFA_GROVEZ.SHARED.LASER_ON" -- замени на свой, если требуется
    end
    if snd then
        wep:EmitSound(snd, 70, 100, 1, CHAN_ITEM)
    end

    net.Start("TFA_LaserModSwitch")
    net.SendToServer()
end)

hook.Add("Think", "ClientLaserDotUpdate", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    local ir_mode = wep.IRLaserMode == "ir"
    if not ShouldShowLaser(ply, ir_mode) then
        if IsValid(ply.TFALaserDot) then
            ply.TFALaserDot:Remove()
            ply.TFALaserDot = nil
        end
        return
    end
end)