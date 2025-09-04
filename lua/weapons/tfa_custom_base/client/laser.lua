if not CLIENT then return end

-- Determines whether the IR (infrared) laser should be displayed.
-- This function does not control the normal laser; it only checks IR visibility conditions.
-- The logic here leaves actual laser rendering and parameters to the TFA base.
-- Parameters:
--   ply: the local player
--   ir_mode: boolean, true if the laser is in IR mode, false for normal
-- Returns:
--   boolean: true if the laser should be visible, false otherwise
local function ShouldShowLaser(ply, ir_mode)
    if not IsValid(ply) then return false end            -- Ensure the player is valid
    if ply.vrnvgbroken then return false end            -- Laser disabled if NVG is broken
    if not ply.nvgbattery or ply.nvgbattery <= 0 then return false end -- Laser disabled if NVG battery is empty

    if ir_mode then
        return ply.vrnvgflipped -- IR mode is only visible when NVG is flipped
    else
        return true -- Normal laser is always visible regardless of NVG state
    end
end

-- Console command to switch the laser mode (IR <-> Normal)
-- This allows users to toggle the laser mode manually via a bind or console command.
-- This does not turn off the laser; it only switches the mode.
concommand.Add("switch_tfa_laser", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    -- Initialize the laser mode to "IR" if it does not exist
    -- Otherwise, toggle between "IR" and "Normal"
    if not wep.IRLaserMode then
        wep.IRLaserMode = "ir" -- Start in IR mode
    else
        wep.IRLaserMode = (wep.IRLaserMode == "ir") and "normal" or "ir"
    end
end)

-- Hook to update the laser every frame using Think
-- This ensures the laser visibility state is evaluated continuously.
-- The actual creation, positioning, and parameters of the laser dot remain managed by TFA base.
hook.Add("Think", "ClientLaserDotUpdate", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    local ir_mode = wep.IRLaserMode == "ir"
    
    -- If the laser should not be visible, remove the dot if it exists
    if not ShouldShowLaser(ply, ir_mode) then
        if IsValid(ply.TFALaserDot) then
            ply.TFALaserDot:Remove()
            ply.TFALaserDot = nil
        end
        return
    end
end)
