---
-- @class ENT
-- @section ttt_id_swap_grenade_proj

if SERVER then
    util.AddNetworkString("TTT2IdentitySwapGrenadeTimer")
end
local reset_timer_length_convar = GetConVar("ttt_id_swap_grenade_reset_timer_length")

if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("ttt_basegrenade_proj")

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_smokegrenade_thrown.mdl")

AccessorFunc(ENT, "radius", "Radius", FORCE_NUMBER)

---
-- @ignore
function ENT:Initialize()
    if not self:GetRadius() then
        self:SetRadius(256)
    end

    return BaseClass.Initialize(self)
end

-- turns the input array into a derangement, given each element is a table where the first item is an index
-- might seem a little overkill, but this item is more interesting if all players identities are randomized
--
-- it is also *technically* possible that invalid numbers will be picked for a significant period of time
-- but this is very unlikely with any reasonable number of players. but it does mean in the worst case this
-- algorithm has an infinite runtime. 
local function derangement(l)
    for i = #l, 2, -1 do
        local j = 0
        repeat j = math.random(i)
        until l[j][1] ~= i or i == 2

        l[i], l[j] = l[j], l[i]
    end
    for i = 1, math.min(2, #l - 1) do
        if l[i][1] ~= i then
            continue
        end

        local j = 0
        repeat j = math.random(#l)
        until j ~= i

        l[i], l[j] = l[j], l[i]
    end
end

local function LOSFilter(ent)
    return ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_ragdoll" or ent:IsPlayer()
end

---
-- @ignore
function ENT:Explode(tr)
    self:SetDetonateExact(0)

    if not SERVER then
        return
    end

    self:SetNoDraw(true)
    self:SetSolid(SOLID_NONE)

    -- pull out of the surface
    if tr.Fraction ~= 1.0 then
        self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
    end
    local pos = self:GetPos()

    local all_ents = ents.FindInSphere(pos, self:GetRadius())
    -- store a list of the identities to be exchanged, and the players
    -- who will recieve a new identity
    local identities = {}
    local players = {}
    for _, ent in ipairs(all_ents) do
        if not IsValid(ent) then
            continue
        end

        local idx = #identities + 1
        if ent:IsPlayer() and ent:IsTerror() then
            -- LOS calculation
            if util.TraceLine({start = self:GetPos(), endpos = ent:GetPos(), filter = LOSFilter}) == nil and
                util.TraceLine({start = self:GetPos(), endpos = ent:EyePos(), filter = LOSFilter}) == nil then
                continue
            end

            players[ent] = idx
            -- if the person is already disguised, perform the swap with their disguise
            if ent:HasDisguiserTarget() then
                identities[idx] = table.Pack(idx, ent:GetDisguiserTarget(), ent.disguiserStoredModel, ent.disguiserStoredSkin)
            else
                identities[idx] = table.Pack(idx, ent, ent:GetModel(), ent:GetSkin())
            end
        -- for some extra fun, add dead bodies to the list of disguises :D
        elseif ent:GetClass() == "prop_ragdoll" and CORPSE.IsValidBody(ent) then
            --LOS calculation
            if util.TraceLine({start = self:GetPos(), endpos = ent:GetPos(), filter = LOSFilter}) == nil then
                continue
            end
            identities[idx] = table.Pack(idx, CORPSE.GetPlayer(ent), ent:GetModel(), ent:GetSkin())
        end
    end

    derangement(identities)

    -- finally, we activate the disguises
    local reset_timer_length = reset_timer_length_convar:GetFloat()
    for ply, idx in pairs(players) do
        local item = identities[idx]
        ply:UpdateStoredDisguiserTarget(item[2], item[3], item[4])
        ply:ActivateDisguiserTarget()

        if reset_timer_length ~= 0 then
            ply.id_timer = CurTime() + reset_timer_length
            net.Start("TTT2IdentitySwapGrenadeTimer")
            net.WriteBool(true)
            net.WriteFloat(ply.id_timer)
            net.Send(ply)
        end
    end

    local effect = EffectData()
    effect:SetStart(pos)
    effect:SetOrigin(pos)

    if tr.Fraction ~= 1.0 then
        effect:SetNormal(tr.HitNormal)
    end
    util.Effect("Explosion", effect, true, true)

    self:Remove()
end

net.Receive("TTT2IdentitySwapGrenadeTimer", function()
    if net.ReadBool() then
        LocalPlayer().id_timer = net.ReadFloat()
    else
        LocalPlayer().id_timer = nil
    end
end)

hook.Add("PlayerTick", "ttt_id_swap_grenade_player_tick_timer", function (ply, _)
    if not ply:IsTerror() then
        return
    end

    if ply:HasWeapon("weapon_ttt_identity_disguiser") then
        ply.had_identity_disguiser = true
    end

    if ply.id_timer == nil then
        return
    end

    if not ply:HasDisguiserTarget() or ply:GetDisguiserTarget() ~= ply:GetStoredDisguiserTarget() then
        ply.id_timer = nil
        return
    end

    if CurTime() < ply.id_timer then
        return
    end

    ply.id_timer = nil
    if not SERVER then
        return
    end
    net.Start("TTT2IdentitySwapGrenadeTimer")
    net.WriteBool(false)
    net.Send(ply)

    ply:DeactivateDisguiserTarget()
    if not ply.had_identity_disguiser then
        ply:UpdateStoredDisguiserTarget(nil)
    end
end)

hook.Add("TTTPrepareRound", "ttt2_identity_swap_grenade_reset", function()
    for _, ply in ipairs(player.GetAll()) do
        ply.had_identity_disguiser = false
        ply.id_timer = nil
    end
end)
