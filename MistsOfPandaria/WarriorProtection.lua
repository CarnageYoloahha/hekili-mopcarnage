-- WarriorProtection.lua
-- Updated May 28, 2025 - Modern Structure
-- Mists of Pandaria module for Warrior: Protection spec

if not Hekili or not Hekili.NewSpecialization then return end

-- MoP: Use UnitClass instead of UnitClassBase
local _, playerClass = UnitClass('player')
if playerClass ~= 'WARRIOR' then return end

local addon, ns = ...
local Hekili = _G[ "Hekili" ]
local class, state

local function getReferences()
    if not class then
        class, state = Hekili.Class, Hekili.State
    end
    return class, state
end

local strformat = string.format
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local function UA_GetPlayerAuraBySpellID(spellID)
    for i = 1, 40 do
        local name, _, count, _, duration, expires, caster, _, _, id = UnitBuff("player", i)
        if not name then break end
        if id == spellID then return name, _, count, _, duration, expires, caster end
    end
    for i = 1, 40 do
        local name, _, count, _, duration, expires, caster, _, _, id = UnitDebuff("player", i)
        if not name then break end
        if id == spellID then return name, _, count, _, duration, expires, caster end
    end
    return nil
end

local spec = Hekili:NewSpecialization( 73 ) -- Protection spec ID for MoP

-- Register resources
spec:RegisterResource( 1, { -- Rage = 1 in MoP
    ragePerAuto = function ()
        local mult = 1.75 -- Base rage generation multiplier for Protection
        
        return 4 * mult -- 4 base rage per auto attack, multiplied by specialization rage multiplier
    end,
    
    regenRate = function ()
        return 0
    end,
} )

-- Tier sets and combat log tracking
spec:RegisterGear( "tier14", 85329, 85330, 85331, 85332, 85333 ) -- T14 Battleplate of Resounding Rings
spec:RegisterGear( "tier15", 95571, 95573, 95574, 95575, 95576 ) -- T15 Battleplate of the Last Mogu
spec:RegisterGear( "tier16", 99334, 99335, 99336, 99337, 99338 ) -- T16 Battleplate of the Prehistoric Marauder

-- Additional tier difficulties
spec:RegisterGear( "tier14_lfr", 89087, 89088, 89089, 89090, 89091 ) -- T14 LFR
spec:RegisterGear( "tier14_heroic", 86650, 86651, 86652, 86653, 86654 ) -- T14 Heroic
spec:RegisterGear( "tier15_lfr", 96618, 96619, 96620, 96621, 96622 ) -- T15 LFR  
spec:RegisterGear( "tier15_heroic", 96901, 96902, 96903, 96904, 96905 ) -- T15 Heroic
spec:RegisterGear( "tier16_lfr", 105687, 105688, 105689, 105690, 105691 ) -- T16 LFR
spec:RegisterGear( "tier16_heroic", 104460, 104461, 104462, 104463, 104464 ) -- T16 Heroic

-- Legendary items
spec:RegisterGear( "legendary_cloak", 102246, 102247, 102248, 102249, 102250 ) -- Qian-Ying, Fortitude of Niuzao
spec:RegisterGear( "legendary_meta", 101821, 101822 ) -- Legendary meta gems

-- Notable Protection trinkets
spec:RegisterGear( "vial_of_living_corruption", 102291 ) -- SoO trinket
spec:RegisterGear( "thoks_tail_tip", 102658 ) -- SoO trinket  
spec:RegisterGear( "juggernaut_focuser", 105109 ) -- SoO trinket
spec:RegisterGear( "resolute_barrier", 104909 ) -- SoO trinket

-- Protection weapons
spec:RegisterGear( "bulwark_of_azzinoth", 104400 ) -- Shield from SoO
spec:RegisterGear( "norushen_enigma", 104404 ) -- 1H weapon from SoO
spec:RegisterGear( "korkron_juggernaut_plating", 105672 ) -- Shield from SoO

-- PvP sets
spec:RegisterGear( "gladiator_s14", 91436, 91437, 91438, 91439, 91440 ) -- Season 14 Gladiator
spec:RegisterGear( "grievous_s15", 94713, 94714, 94715, 94716, 94717 ) -- Season 15 Grievous

-- Challenge Mode sets
spec:RegisterGear( "challenge_mode", 90550, 90551, 90552, 90553, 90554 ) -- Challenge Mode Warrior set

-- Combat log tracking for Protection-specific events
local function RegisterProtectionCombatLog()
    spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        
        if sourceGUID == state.GUID then
            -- Shield Block casts
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 2565 then
                state.shield_block_cast_time = GetTime()
            end
            
            -- Shield Slam casts  
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 23922 then
                state.shield_slam_cast_time = GetTime()
            end
            
            -- Devastate casts
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 20243 then
                state.devastate_cast_time = GetTime()
            end
            
            -- Revenge casts
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 6572 then
                state.revenge_cast_time = GetTime()
            end
            
            -- Thunder Clap casts
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 6343 then
                state.thunder_clap_cast_time = GetTime()
            end
            
            -- Shield Barrier casts
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 112048 then
                state.shield_barrier_cast_time = GetTime()
            end
            
            -- Shield Wall casts
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 871 then
                state.shield_wall_cast_time = GetTime()
            end
            
            -- Last Stand casts
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 12975 then
                state.last_stand_cast_time = GetTime()
            end
            
            -- Berserker Rage casts
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 18499 then
                state.berserker_rage_cast_time = GetTime()
            end
            
            -- Spell Reflection casts
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 23920 then
                state.spell_reflection_cast_time = GetTime()
            end
            
            -- Vengeance procs
            if subtype == "SPELL_AURA_APPLIED" and spellID == 76691 then
                state.vengeance_proc_time = GetTime()
            end
            
            -- Shield Block procs
            if subtype == "SPELL_AURA_APPLIED" and spellID == 132404 then
                state.shield_block_proc_time = GetTime()
            end
            
        end
    end )
end

RegisterProtectionCombatLog()

-- Tier set bonus tracking with generate functions
spec:RegisterGear( "tier14_2pc", function() return set_bonus.tier14_2pc end )
spec:RegisterGear( "tier14_4pc", function() return set_bonus.tier14_4pc end )
spec:RegisterGear( "tier15_2pc", function() return set_bonus.tier15_2pc end )
spec:RegisterGear( "tier15_4pc", function() return set_bonus.tier15_4pc end )
spec:RegisterGear( "tier16_2pc", function() return set_bonus.tier16_2pc end )
spec:RegisterGear( "tier16_4pc", function() return set_bonus.tier16_4pc end )

-- Talents (MoP talent system - ID, enabled, spell_id)
spec:RegisterTalents( {
    -- Tier 1 (Level 15) - Mobility
    juggernaut                 = { 2047, 1, 103156 }, -- Your Charge ability has 2 charges, shares charges with Intervene, and generates 15 Rage.
    double_time                = { 2048, 1, 103827 }, -- Your Charge ability has 2 charges, shares charges with Intervene, and no longer generates Rage.
    warbringer                 = { 2049, 1, 103828 }, -- Charge also roots the target for 4 sec, and Hamstring generates more Rage.

    -- Tier 2 (Level 30) - Healing/Survival
    second_wind                = { 2050, 1, 29838  }, -- While below 35% health, you regenerate 3% of your maximum health every 1 sec. Cannot be triggered if you were reduced below 35% by a creature that rewards experience or honor.
    enraged_regeneration       = { 2051, 1, 55694  }, -- Instantly heals you for 10% of your total health and regenerates an additional 10% over 5 sec. Usable whilst stunned, frozen, incapacitated, feared, or asleep. 1 min cooldown.
    impending_victory          = { 2052, 1, 103840 }, -- Instantly attack the target causing damage and healing you for 10% of your maximum health. Replaces Victory Rush. 30 sec cooldown.

    -- Tier 3 (Level 45) - Utility
    staggering_shout           = { 2053, 1, 107566 }, -- Causes all enemies within 10 yards to have their movement speed reduced by 50% for 15 sec. 40 sec cooldown.
    piercing_howl              = { 2054, 1, 12323  }, -- Causes all enemies within 10 yards to have their movement speed reduced by 50% for 15 sec. 30 sec cooldown.
    disrupting_shout           = { 2055, 1, 102060 }, -- Interrupts all enemy spell casts and prevents any spell in that school from being cast for 4 sec. 40 sec cooldown.

    -- Tier 4 (Level 60) - Burst DPS
    bladestorm                 = { 2056, 1, 46924  }, -- You become a whirlwind of steel, attacking all enemies within 8 yards for 6 sec, but you cannot use Auto Attack, Slam, or Execute during this time. Increases your chance to dodge by 30% for the duration. 1.5 min cooldown.
    shockwave                  = { 2057, 1, 46968  }, -- Sends a wave of force in a frontal cone, causing damage and stunning enemies for 4 sec. This ability is usable in all stances. 40 sec cooldown. Cooldown reduced by 20 sec if it strikes at least 3 targets.
    dragon_roar                = { 2058, 1, 118000 }, -- Roar powerfully, dealing damage to all enemies within 8 yards, knockback and disarming all enemies for 4 sec. The damage is always a critical hit. 1 min cooldown.

    -- Tier 5 (Level 75) - Survivability
    mass_spell_reflection      = { 2059, 1, 114028 }, -- Reflects the next spell cast on you and all allies within 20 yards back at the caster. 1 min cooldown.
    safeguard                  = { 2060, 1, 114029 }, -- Intervene also reduces all damage taken by the target by 20% for 6 sec.
    vigilance                  = { 2061, 1, 114030 }, -- Focus your protective gaze on a group member, transferring 30% of damage taken to you. In addition, each time the target takes damage, cooldown on your next Taunt is reduced by 3 sec. Lasts 12 sec.

    -- Tier 6 (Level 90) - Damage
    avatar                     = { 2062, 1, 107574 }, -- You transform into an unstoppable avatar, increasing damage done by 20% and removing and granting immunity to movement imparing effects for 24 sec. 3 min cooldown.
    bloodbath                  = { 2063, 1, 12292  }, -- Increases damage by 30% and causes your auto attacks and damaging abilities to cause the target to bleed for an additional 30% of the damage you initially dealt over 6 sec. Lasts 12 sec. 1 min cooldown.
    storm_bolt                 = { 2064, 1, 107570 }, -- Throws your weapon at the target, causing damage and stunning for 3 sec. This ability is usable in all stances. 30 sec cooldown.
} )

-- Protection-specific Glyphs (Enhanced System)
spec:RegisterGlyphs( {
    -- Major Glyphs - DPS/Combat
    [58095] = "bladestorm",             -- Reduces the cooldown of your Bladestorm ability by 15 sec.
    [58372] = "shield_wall",            -- Reduces the cooldown of your Shield Wall ability by 2 min, but also reduces its effect by 20%.
    [58375] = "shield_block",           -- Your Shield Block ability now increases block value by an additional 10% but no longer grants a chance to critically block.
    [58101] = "spell_reflection",       -- Reduces the cooldown of your Spell Reflection ability by 5 sec, but reduces its duration by 1 sec.
    [58387] = "hold_the_line",          -- Your Shield Wall ability now increases your critical block chance by 10% for 12 sec.
    [58357] = "cleaving",               -- Your Cleave ability now strikes up to 3 targets.
    [58358] = "resonating_power",       -- The periodic damage of your Thunder Clap ability now also causes enemies to resonate with energy, dealing 5% of the Thunder Clap damage to nearby enemies within 10 yards.
    [58369] = "incite",                 -- Increases the critical strike chance of your Heroic Strike by 20%, but it costs 10 more rage.
    [58367] = "burning_anger",          -- Increases the critical strike chance of your Thunder Clap and Shock Wave by 20%, but they cost 20 rage.
    [58370] = "sunder_armor",           -- Your Sunder Armor ability now applies a full Sunder Armor effect with a single application.
    [58368] = "thunder_strike",         -- Increases the number of targets your Thunder Clap ability hits by 50%, but reduces its damage by 20%.
    [58373] = "devastate",              -- Your Devastate ability now applies 2 stacks of Sunder Armor.
    [58374] = "revenge",                -- Your Revenge ability now has a 30% chance to reset its own cooldown.
    
    -- Major Glyphs - Mobility/Utility
    [58099] = "bull_rush",              -- Your Charge ability roots the target for 1 sec.
    [58103] = "death_from_above",       -- When you use Charge, you leap into the air on a course to the target.
    [58098] = "hamstring",              -- Reduces the global cooldown triggered by your Hamstring to 0.5 sec.
    [58386] = "long_charge",            -- Increases the range of your Charge and Intervene abilities by 5 yards.
    [58385] = "blitz",                  -- When you use Charge, you charge up to 3 enemies near the target.
    [63324] = "victory_rush",           -- Your Victory Rush ability is usable for an additional 5 sec after the duration expires, but heals you for 50% less.
    [58096] = "bloody_healing",         -- Your Victory Rush and Impending Victory abilities heal you for an additional 10% of your max health.
    
    -- Major Glyphs - Defensive/Survivability
    [58097] = "die_by_the_sword",       -- Increases the chance to parry of your Die by the Sword ability by 20%, but reduces its duration by 4 sec.
    [58356] = "unending_rage",          -- Your Enrage effects and Berserker Rage ability last an additional 2 sec.
    [58371] = "shield_slam",            -- Your Shield Slam ability reduces the target's damage done by 10% for 10 sec.
    [58378] = "taunt",                  -- Your Taunt ability now increases your damage done to the target by 10% for 3 sec.
    [58379] = "shield_bash",            -- Your Shield Bash ability now silences the target for 3 sec.
    [58380] = "defensive_stance",       -- Your Defensive Stance now provides 10% magic damage reduction.
    [58381] = "intercept",              -- Your Intercept ability now stuns the target for 1 sec.
    [58382] = "mocking_blow",           -- Your Mocking Blow ability now taunts all enemies within 8 yards.
    
    -- Major Glyphs - Control/CC
    [58377] = "intimidating_shout",     -- Your Intimidating Shout now only causes the targeted enemy to flee.
    [58383] = "rend",                   -- Your Rend ability now spreads to nearby enemies when the target dies.
    [58384] = "commanding_shout",       -- Your Commanding Shout now also provides 10% damage reduction for 10 sec.
    
    -- Minor Glyphs - Visual/Convenience
    [58355] = "battle",                 -- Your Battle Shout now also increases your maximum health by 3% for 1 hour.
    [58376] = "berserker_rage",         -- Your Berserker Rage no longer causes you to become immune to Fear, Sap, or Incapacitate effects.
    [58388] = "bloodrage",              -- Your Bloodrage ability no longer causes you to take damage.
    [58389] = "endurance",              -- Reduces the cooldown of your Second Wind by 30 sec.
    [58390] = "furious_sundering",      -- Your Sunder Armor now reduces the target's movement speed by 10% per stack.
} )

-- Protection Warrior specific auras (Enhanced System with Generate Functions)
spec:RegisterAuras( {
    -- Core Protection Mechanics
    battle_shout = {
        id = 6673,
        duration = 3600,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 6673 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 3600
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    commanding_shout = {
        id = 469,
        duration = 3600,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 469 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 3600
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    shield_block = {
        id = 2565,
        duration = 6,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 2565 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 6
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    shield_barrier = {
        id = 112048,
        duration = 6,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 112048 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 6
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    shield_wall = {
        id = 871,
        duration = 12,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 871 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 12
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    last_stand = {
        id = 12975,
        duration = 20,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 12975 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 20
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    vengeance = {
        id = 76691,
        duration = 20, -- Vengeance lasts 20 seconds in MoP
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 76691 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 20
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    berserker_rage = {
        id = 18499,
        duration = function() return glyph.unending_rage.enabled and 8 or 6 end,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 18499 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - (glyph.unending_rage.enabled and 8 or 6)
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    -- Enhanced Ability Tracking
    revenge = {
        id = 6572,
        duration = 5,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 6572 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 5
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    devastate = {
        id = 20243,
        duration = 1,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 20243 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 1
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    shield_slam = {
        id = 23922,
        duration = 1,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 23922 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 1
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    thunder_clap = {
        id = 6343,
        duration = 30,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = FindUnitDebuffByID( "target", 6343 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 30
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    sunder_armor = {
        id = 7386,
        duration = 30,
        max_stack = 3,
        generate = function( t, auraType )
            local aura = FindUnitDebuffByID( "target", 7386 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 30
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    -- MoP Talent Coordination
    avatar = {
        id = 107574,
        duration = 24,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 107574 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 24
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    bladestorm = {
        id = 46924,
        duration = 6,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 46924 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 6
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    bloodbath = {
        id = 12292,
        duration = 12,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 12292 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 12
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    bloodbath_dot = {
        id = 113344,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = FindUnitDebuffByID( "target", 113344 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 6
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    dragon_roar = {
        id = 118000,
        duration = 4,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = FindUnitDebuffByID( "target", 118000 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 4
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    second_wind = {
        id = 29838,
        duration = 3600,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 29838 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 3600
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    vigilance = {
        id = 114030,
        duration = 12,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 114030 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 12
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    -- Enhanced Defensive/Utility Tracking
    spell_reflection = {
        id = 23920,
        duration = function() return glyph.spell_reflection.enabled and 4 or 5 end,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 23920 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - (glyph.spell_reflection.enabled and 4 or 5)
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    mass_spell_reflection = {
        id = 114028,
        duration = 5,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 114028 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 5
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    -- Tier Set and Legendary Tracking
    tier14_2pc = {
        id = 123456, -- Placeholder for T14 2pc effect
        duration = 15,
        max_stack = 1,
        generate = function( t, auraType )
            if set_bonus.tier14_2pc == 1 then
                local aura = UA_GetPlayerAuraBySpellID( 123456 )
                if aura then
                    t.name = aura.name
                    t.count = aura.applications
                    t.expires = aura.expirationTime
                    t.applied = aura.expirationTime - 15
                    t.caster = "player"
                    return
                end
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    tier14_4pc = {
        id = 123457, -- Placeholder for T14 4pc effect
        duration = 20,
        max_stack = 1,
        generate = function( t, auraType )
            if set_bonus.tier14_4pc == 1 then
                local aura = UA_GetPlayerAuraBySpellID( 123457 )
                if aura then
                    t.name = aura.name
                    t.count = aura.applications
                    t.expires = aura.expirationTime
                    t.applied = aura.expirationTime - 20
                    t.caster = "player"
                    return
                end
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    legendary_cloak = {
        id = 146046, -- Legendary cloak proc effect
        duration = 15,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = UA_GetPlayerAuraBySpellID( 146046 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 15
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    hamstring = {
        id = 6673,
        duration = 3600,
        max_stack = 1,
    },
    commanding_shout = {
        id = 469,
        duration = 3600,
        max_stack = 1,
    },
    shield_block = {
        id = 2565,
        duration = 6,
        max_stack = 1,
    },
    shield_barrier = {
        id = 112048,
        duration = 6,
        max_stack = 1,
    },
    shield_wall = {
        id = 871,
        duration = 12,
        max_stack = 1,
    },
    last_stand = {
        id = 12975,
        duration = 20,
        max_stack = 1,
    },
    vengeance = {
        id = 76691,
        duration = 20, -- Vengeance lasts 20 seconds in MoP
        max_stack = 1,
    },
    berserker_rage = {
        id = 18499,
        duration = function() return glyph.unending_rage.enabled and 8 or 6 end,
        max_stack = 1,
    },
    sunder_armor = {
        id = 7386,
        duration = 30,
        max_stack = 3,
    },
    devastate = {
        id = 20243,
        duration = 1,
        max_stack = 1,
    },
    
    -- Talent-specific buffs/debuffs
    avatar = {
        id = 107574,
        duration = 24,
        max_stack = 1,
    },
    bladestorm = {
        id = 46924,
        duration = 6,
        max_stack = 1,
    },
    bloodbath = {
        id = 12292,
        duration = 12,
        max_stack = 1,
    },
    bloodbath_dot = {
        id = 113344,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
    },
    dragon_roar = {
        id = 118000,
        duration = 4,
        max_stack = 1,
    },
    second_wind = {
        id = 29838,
        duration = 3600,
        max_stack = 1,
    },
    vigilance = {
        id = 114030,
        duration = 12,
        max_stack = 1,
    },
    
    -- Crowd control / utility
    spell_reflection = {
        id = 23920,
        duration = function() return glyph.spell_reflection.enabled and 4 or 5 end,
        max_stack = 1,
    },
    mass_spell_reflection = {
        id = 114028,
        duration = 5,
        max_stack = 1,
    },
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1,
    },
    piercing_howl = {
        id = 12323,
        duration = 15,
        max_stack = 1,
    },
    staggering_shout = {
        id = 107566,
        duration = 15,
        max_stack = 1,
    },
    shockwave = {
        id = 46968,
        duration = 4,
        max_stack = 1,
    },
    storm_bolt = {
        id = 107570,
        duration = 3,
        max_stack = 1,
    },
    war_banner = {
        id = 114207,
        duration = 15,
        max_stack = 1,
    },
    rallying_cry = {
        id = 97462,
        duration = 10,
        max_stack = 1,
    },
    demoralizing_shout = {
        id = 1160,
        duration = 10,
        max_stack = 1,
    },
    disrupting_shout = {
        id = 102060,
        duration = 4,
        max_stack = 1,
    },
    intimidating_shout = {
        id = 5246,
        duration = 8,
        max_stack = 1,
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1,
    },
    enraged_regeneration = {
        id = 55694,
        duration = 5,
        tick_time = 1,
        max_stack = 1,
    },
    charge_root = {
        id = 105771,
        duration = function() 
            if talent.warbringer.enabled then
                return 4
            elseif glyph.bull_rush.enabled then                return 1
            end
            return 0
        end,
        max_stack = 1,
    },
    
    -- Additional Protection-specific tracking with generate functions
    intimidating_shout = {
        id = 5246,
        duration = 8,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = FindUnitDebuffByID( "target", 5246 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 8
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    demoralizing_shout = {
        id = 1160,
        duration = 30,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = FindUnitDebuffByID( "target", 1160 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 30
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    shockwave = {
        id = 46968,
        duration = 4,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = FindUnitDebuffByID( "target", 46968 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 4
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    
    storm_bolt = {
        id = 107570,
        duration = 3,
        max_stack = 1,
        generate = function( t, auraType )
            local aura = FindUnitDebuffByID( "target", 107570 )
            if aura then
                t.name = aura.name
                t.count = aura.applications
                t.expires = aura.expirationTime
                t.applied = aura.expirationTime - 3
                t.caster = "player"
                return
            end
            
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
} )

-- Protection Warrior abilities
spec:RegisterAbilities( {
    -- Core rotational abilities
    devastate = {
        id = 20243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        startsCombat = true,
        texture = 132363,
        
        handler = function()
            -- 20% chance to reset Shield Slam cooldown
            if math.random() < 0.2 then
                setCooldown( "shield_slam", 0 )
            end
            
            applyBuff( "devastate" )
            
            -- Apply Sunder Armor stack
            if debuff.sunder_armor.stack < 3 then
                if glyph.sunder_armor.enabled then
                    applyDebuff( "target", "sunder_armor", nil, 3 )
                else
                    addStack( "sunder_armor", "target", 1 )
                end
            else
                applyDebuff( "target", "sunder_armor" )
            end
        end,
    },
    
    shield_slam = {
        id = 23922,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        
        spend = -15, -- Generates 15 rage
        spendType = "rage",
        
        requires = "shield",
        startsCombat = true,
        texture = 132357,
        
        handler = function()
            -- No specific effect other than rage generation
        end,
    },
    
    thunder_clap = {
        id = 6343,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        
        spend = function() 
            if glyph.burning_anger.enabled then return 20 end
            return 0 
        end,
        spendType = "rage",
        
        startsCombat = true,
        texture = 136105,
        
        handler = function()
            -- Apply Deep Wounds effect (handled by the game)
        end,
    },
    
    revenge = {
        id = 6572,
        cast = 0,
        cooldown = 9,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        requires = "shield",
        startsCombat = true,
        texture = 132353,
        
        handler = function()
            -- Generates 15 rage
            gain( 15, "rage" )
        end,
    },
    
    heroic_strike = {
        id = 78,
        cast = 0,
        cooldown = 0,
        gcd = "off",
        
        spend = function() 
            if glyph.incite.enabled then return 40 end
            return 30 
        end,
        spendType = "rage",
        
        startsCombat = true,
        texture = 132282,
        
        handler = function()
            -- No specific effect other than damage
        end,
    },
    
    cleave = {
        id = 845,
        cast = 0,
        cooldown = 0,
        gcd = "off",
        
        spend = 20,
        spendType = "rage",
        
        startsCombat = true,
        texture = 132338,
        
        handler = function()
            -- No specific effect for Cleave
        end,
    },
    
    -- Defensive abilities
    shield_block = {
        id = 2565,
        cast = 0,
        cooldown = 9,
        charges = 2,
        recharge = 9,
        gcd = "off",
        
        spend = 60,
        spendType = "rage",
        
        toggle = "defensives",
        requires = "shield",
        
        startsCombat = false,
        texture = 132110,
        
        handler = function()
            applyBuff( "shield_block" )
        end,
    },
    
    shield_barrier = {
        id = 112048,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",
        
        spend = function() 
            -- Min 20, can use up to 60 rage for a stronger barrier
            return 20
        end,
        spendType = "rage",
        
        toggle = "defensives",
        requires = "shield",
        
        startsCombat = false,
        texture = 600676,
        
        handler = function()
            applyBuff( "shield_barrier" )
        end,
    },
    
    shield_wall = {
        id = 871,
        cast = 0,
        cooldown = function() return glyph.shield_wall.enabled and 180 or 300 end,
        gcd = "off",
        
        toggle = "defensives",
        
        startsCombat = false,
        texture = 132362,
        
        handler = function()
            applyBuff( "shield_wall" )
            
            if glyph.hold_the_line.enabled then
                -- Increase critical block chance by 10% (handled by the game)
            end
        end,
    },
    
    last_stand = {
        id = 12975,
        cast = 0,
        cooldown = 180,
        gcd = "off",
        
        toggle = "defensives",
        
        startsCombat = false,
        texture = 135871,
        
        handler = function()
            applyBuff( "last_stand" )
            -- Increases max health by 30% and heals for that amount
            local health_increase = health.max * 0.3
            gain( health_increase, "health" )
        end,
    },
    
    -- Utility abilities
    battle_shout = {
        id = 6673,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        startsCombat = false,
        texture = 132333,
        
        handler = function()
            applyBuff( "battle_shout" )
        end,
    },
    
    commanding_shout = {
        id = 469,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        startsCombat = false,
        texture = 132351,
        
        handler = function()
            applyBuff( "commanding_shout" )
        end,
    },
    
    charge = {
        id = 100,
        cast = 0,
        cooldown = function() 
            if talent.juggernaut.enabled or talent.double_time.enabled then
                return 20
            end
            return 20 
        end,
        charges = function()
            if talent.juggernaut.enabled or talent.double_time.enabled then
                return 2
            end
            return 1
        end,
        recharge = 20,
        gcd = "off",
        
        spend = function()
            if talent.juggernaut.enabled then return -15 end
            return 0
        end,
        spendType = "rage",
        
        range = function() 
            if glyph.long_charge.enabled then
                return 30
            end
            return 25 
        end,
        
        startsCombat = true,
        texture = 132337,
        
        handler = function()
            if talent.warbringer.enabled or glyph.bull_rush.enabled then
                applyDebuff( "target", "charge_root" )
            end
        end,
    },
    
    intervene = {
        id = 3411,
        cast = 0,
        cooldown = function() 
            if talent.juggernaut.enabled or talent.double_time.enabled then
                return 20
            end
            return 30 
        end,
        charges = function()
            if talent.juggernaut.enabled or talent.double_time.enabled then
                return 2
            end
            return 1
        end,
        recharge = function() 
            if talent.juggernaut.enabled or talent.double_time.enabled then
                return 20
            end
            return 30 
        end,
        gcd = "off",
        
        spend = 0,
        spendType = "rage",
        
        range = function() 
            if glyph.long_charge.enabled then
                return 30
            end
            return 25 
        end,
        
        startsCombat = false,
        texture = 132365,
        
        handler = function()
            if talent.safeguard.enabled then
                -- Apply damage reduction to the target (handled by the game)
            end
        end,
    },
    
    heroic_leap = {
        id = 6544,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        startsCombat = true,
        texture = 236171,
        
        handler = function()
            -- No specific effect, just the leap
        end,
    },
    
    berserker_rage = {
        id = 18499,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        
        spend = 0,
        spendType = "rage",
        
        startsCombat = false,
        texture = 136009,
        
        handler = function()
            applyBuff( "berserker_rage" )
        end,
    },
    
    taunt = {
        id = 355,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        
        startsCombat = true,
        texture = 136080,
        
        handler = function()
            applyDebuff( "target", "taunt" )
        end,
    },
    
    rallying_cry = {
        id = 97462,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        
        toggle = "defensives",
        
        startsCombat = false,
        texture = 132351,
        
        handler = function()
            applyBuff( "rallying_cry" )
        end,
    },
    
    -- Talent abilities
    avatar = {
        id = 107574,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "cooldowns",
        
        startsCombat = false,
        texture = 613534,
        
        handler = function()
            applyBuff( "avatar" )
        end,
    },
    
    bloodbath = {
        id = 12292,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "cooldowns",
        
        startsCombat = false,
        texture = 236304,
        
        handler = function()
            applyBuff( "bloodbath" )
        end,
    },
    
    bladestorm = {
        id = 46924,
        cast = 0,
        cooldown = function() return glyph.bladestorm.enabled and 75 or 90 end,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "cooldowns",
        
        startsCombat = true,
        texture = 236303,
        
        handler = function()
            applyBuff( "bladestorm" )
        end,
    },
    
    dragon_roar = {
        id = 118000,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "cooldowns",
        
        startsCombat = true,
        texture = 642418,
        
        handler = function()
            applyDebuff( "target", "dragon_roar" )
        end,
    },
    
    shockwave = {
        id = 46968,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        
        spend = function() 
            if glyph.burning_anger.enabled then return 20 end
            return 0 
        end,
        spendType = "rage",
        
        toggle = "cooldowns",
        
        startsCombat = true,
        texture = 236312,
        
        handler = function()
            applyDebuff( "target", "shockwave" )
        end,
    },
    
    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "cooldowns",
        
        startsCombat = true,
        texture = 613535,
        
        handler = function()
            applyDebuff( "target", "storm_bolt" )
        end,
    },
    
    vigilance = {
        id = 114030,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "cooldowns",
        
        startsCombat = false,
        texture = 236331,
        
        handler = function()
            applyBuff( "vigilance" )
        end,
    },
    
    impending_victory = {
        id = 103840,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        
        spend = 10,
        spendType = "rage",
        
        startsCombat = true,
        texture = 589768,
        
        handler = function()
            local heal_amount = health.max * (glyph.bloody_healing.enabled and 0.2 or 0.1)
            gain( heal_amount, "health" )
        end,
    },
    
    staggering_shout = {
        id = 107566,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        startsCombat = true,
        texture = 132346,
        
        handler = function()
            applyDebuff( "target", "staggering_shout" )
        end,
    },
    
    piercing_howl = {
        id = 12323,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        startsCombat = true,
        texture = 132117,
        
        handler = function()
            applyDebuff( "target", "piercing_howl" )
        end,
    },
    
    disrupting_shout = {
        id = 102060,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "interrupts",
        
        startsCombat = true,
        texture = 132117,
        
        handler = function()
            applyDebuff( "target", "disrupting_shout" )
        end,
    },
    
    sunder_armor = {
        id = 7386,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = 15,
        spendType = "rage",
        
        startsCombat = true,
        texture = 132363,
        
        handler = function()
            if debuff.sunder_armor.stack < 3 then
                if glyph.sunder_armor.enabled then
                    applyDebuff( "target", "sunder_armor", nil, 3 )
                else
                    addStack( "sunder_armor", "target", 1 )
                end
            else
                applyDebuff( "target", "sunder_armor" )
            end
            
            if glyph.furious_sundering.enabled then
                -- Apply movement speed reduction (handled by game)
            end
        end,
    },
    
    enraged_regeneration = {
        id = 55694,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "defensives",
        
        startsCombat = false,
        texture = 132345,
        
        handler = function()
            local instant_heal = health.max * 0.1
            gain( instant_heal, "health" )
            applyBuff( "enraged_regeneration" )
        end,
    },
    
    spell_reflection = {
        id = 23920,
        cast = 0,
        cooldown = function() return glyph.spell_reflection.enabled and 20 or 25 end,
        gcd = "off",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "defensives",
        
        startsCombat = false,
        texture = 132361,
        
        handler = function()
            applyBuff( "spell_reflection" )
        end,
    },
    
    mass_spell_reflection = {
        id = 114028,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "defensives",
        
        startsCombat = false,
        texture = 132361,
        
        handler = function()
            applyBuff( "mass_spell_reflection" )
        end,
    },
    
    war_banner = {
        id = 114207,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        toggle = "cooldowns",
        
        startsCombat = false,
        texture = 603532,
        
        handler = function()
            applyBuff( "war_banner" )
        end,
    },
    
    demoralizing_shout = {
        id = 1160,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        startsCombat = true,
        texture = 132366,
        
        handler = function()
            applyDebuff( "target", "demoralizing_shout" )
        end,
    },
    
    intimidating_shout = {
        id = 5246,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        
        spend = 0,
        spendType = "rage",
        
        startsCombat = true,
        texture = 132154,
        
        handler = function()
            applyDebuff( "target", "intimidating_shout" )
        end,
    },
} )

-- Range
spec:RegisterRanges( "devastate", "charge", "heroic_throw" )

-- Options
spec:RegisterOptions( {
    enabled = true,
    
    aoe = 3,
    
    gcd = 1645,
    
    nameplates = true,
    nameplateRange = 8,
    
    damage = true,
    damageExpiration = 8,
    
    potion = "earthen",
    
    package = "Protection",
} )

-- Default pack for MoP Protection Warrior
spec:RegisterPack( "Protection", 20250515, [[Hekili:TznBVTTnu4FlXjHjMjENnWUYJaUcMLf8KvAm7nYjPPQonGwX2jzlkiuQumzkaLRQiQOeH9an1Y0YnpYoWgwlYFltwGtRJ(aiCN9tobHNVH)8TCgF)(5ElyJlFNlcDnPXD5A8j0)(MNZajDa3aNjp2QphnPtoKvyF)GcKKOzjI08QjnOVOCXMj3nE)waT58Pw(aFm0P)MM]] )

-- Register pack selector for Protection
spec:RegisterPackSelector( "protection", "Protection", "|T132341:0|t Protection",
    "Handles all aspects of Protection Warrior tanking with focus on Shield Block/Barrier usage and rage management.",
    nil )
