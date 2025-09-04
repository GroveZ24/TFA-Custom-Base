if not CLIENT then return end

-- Determines whether the IR (infrared) laser should be displayed.
-- Note: This only affects visibility, not the ability to switch modes.
local function ShouldShowLaser(ply, ir_mode)
    if not IsValid(ply) then return false end
    if ply.vrnvgbroken then return false end                -- Laser disabled if NVG is broken
    if not ply.nvgbattery or ply.nvgbattery <= 0 then return false end -- Laser disabled if battery is empty

    if ir_mode then
        return ply.vrnvgflipped -- IR visible only when NVG flipped
    else
        return true -- Normal laser always visible
    end
end

-- Console command to switch laser mode (IR <-> Normal)
-- This **always allows switching**, regardless of NVG state
concommand.Add("cl_tfa_laser_switch", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    -- Toggle mode without any checks
    if not wep.IRLaserMode then
        wep.IRLaserMode = "ir" -- Start in IR mode
    else
        wep.IRLaserMode = (wep.IRLaserMode == "ir") and "normal" or "ir"
    end
end)

-- Think hook updates laser visibility
-- Actual laser rendering handled by TFA base
hook.Add("Think", "ClientLaserDotUpdate", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    local ir_mode = wep.IRLaserMode == "ir"

    -- Remove laser dot if it shouldn't be visible
    if not ShouldShowLaser(ply, ir_mode) then
        if IsValid(ply.TFALaserDot) then
            ply.TFALaserDot:Remove()
            ply.TFALaserDot = nil
        end
        return
    end
end)
