if SERVER then
    AddCSLuaFile()

    -- add any resources here
    -- resource.AddFile("blah blah blah.vmt")
end

SWEP.Base = "weapon_tttbasegrenade"

SWEP.HoldType = "grenade"
SWEP.Slot = 6
SWEP.cvars = {
    reset_timer = CreateConVar("ttt_id_swap_grenade_reset_timer_length", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED},
      "The amount of seconds for someone's identity to be reset after being swapped by an identity swapping grenade. Set to 0 for no reset.", 0)
}

if CLIENT then
    SWEP.ViewModelFOV = 54
    SWEP.ViewModelFlip = false

    SWEP.Icon = "vgui/ttt/icon_smokegrenade"
    SWEP.IconLetter = "Q"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_identity_swap_grenade_name",
        desc = "weapon_identity_swap_grenade_desc"
    }
end

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = {ROLE_TRAITOR}

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_eq_smokegrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_smokegrenade.mdl"

SWEP.AutoSpawnable = false

function SWEP:GetGrenadeName()
    return "ttt_id_swap_grenade_proj"
end

if CLIENT then
    function SWEP:AddToSettingsMenu(parent)
        local form = vgui.CreateTTT2Form(parent, "header_equipment_additional")

        form:MakeHelp({
            label = "label_id_swap_grenate_reset_timer_help"
        })

        form:MakeSlider({
            label = "label_id_swap_grenade_reset_timer_length",
            serverConvar = self.cvars.reset_timer:GetName(),
            min = 0,
            max = 150,
            decimal = 1,
        })
    end
end