local base = "pure_skin_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
    local pad = 14

    local const_defaults = {
        basepos = { x = 0, y = 0 },
        size = { w = 365, h = 32 },
        minsize = { w = 225, h = 32 },
    }

    function HUDELEMENT:PreInitialize()
        BaseClass.PreInitialize(self)
    end

    function HUDELEMENT:Initialize()
        self.scale = 1.0
        self.pad = pad
        self.basecolor = self:GetHUDBasecolor()

        BaseClass.Initialize(self)
    end

    -- parameter overwrites
    function HUDELEMENT:IsResizable()
        return true, true
    end
    -- parameter overwrites end

    function HUDELEMENT:GetDefaults()
        const_defaults["basepos"] = {
            x = 10 * self.scale + 10 * self.scale,
            y = ScrH() - self.size.h - 146 * self.scale - self.pad - 10 * self.scale - 32 * self.scale,
        }

        return const_defaults
    end

    function HUDELEMENT:PreInitialize()
        BaseClass.PreInitialize(self)

        huds.GetStored("pure_skin"):ForceElement(self.id)

        -- set as fallback default, other skins have to be set to true!
        self.disabledUnlessForced = false
    end

    function HUDELEMENT:ShouldDraw()
        local client = LocalPlayer()

        return HUDEditor.IsEditing or client.id_timer ~= nil
    end

    function HUDELEMENT:PerformLayout()
        self.scale = appearance.GetGlobalScale()

        self.basecolor = self:GetHUDBasecolor()
        self.pad = pad * self.scale

        BaseClass.PerformLayout(self)
    end

    function HUDELEMENT:DrawComponent(text)
        local pos = self:GetPos()
        local size = self:GetSize()
        local x, y = pos.x, pos.y
        local w, h = size.w, size.h

        draw.AdvancedText(
            text,
            "PureSkinBar",
            x + w - self.pad,
            y + h,
            util.GetDefaultColor(self.basecolor),
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_BOTTOM,
            true,
            self.scale
        )
    end

    function HUDELEMENT:Draw()
        if HUDEditor.IsEditing then
            local time_remaining = {
                timeremaining = util.NiceFloat(120)
            }
            self:DrawComponent(LANG.GetParamTranslation("identity_disguiser_hud_timer", time_remaining))
            return
        end

        if client.id_timer == nil then
            return
        end

        local time_remaining = {
            timeremaining = util.NiceFloat(math.ceil(client.id_timer - CurTime()))
        }
        self:DrawComponent(LANG.GetParamTranslation("identity_disguiser_hud_timer", time_remaining))
    end
end
