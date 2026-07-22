--[[----------------------------------------------------------------------------
	LoseControlCoA
	Displays the duration of crowd-control effects on unit portraits.
	Adapted for Ascension WoW: Conquest of Azeroth (adds support for the new
	classes and abilities introduced by CoA).

	Copyright (C) 2026  MaxQuest / Naijaro          -- Conquest of Azeroth adaptation
	Copyright (C) millanzarreta and contributors    -- GPLv3 LoseControl fork this work builds on
	Original LoseControl addon by Kouri (Kouri86)

	This file was modified in 2026 by MaxQuest/Naijaro to adapt LoseControl for
	Ascension WoW: Conquest of Azeroth.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation, version 3 of the License (see LICENSE.txt).

	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
	FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
	details: <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

--[[ Code Credits - to the people whose code I borrowed and learned from:
Wowwiki
Kollektiv
Tuller
ckknight
The authors of Nao!!
And of course, Blizzard

Thanks! :)
]]

local L = "LoseControlCoA"
local UIParent = UIParent -- it's faster to keep local references to frequently used global vars

local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience

-------------------------------------------------------------------------------
local spellIds = {
	-- Death Knight
	[47481] = "CC",		-- Gnaw (Ghoul)
	[51209] = "CC",		-- Hungering Cold
	[47476] = "Silence",	-- Strangulate
	[45524] = "Snare",	-- Chains of Ice
	[55666] = "Snare",	-- Desecration (no duration, lasts as long as you stand in it)
	[58617] = "Snare",	-- Glyph of Heart Strike
	[50436] = "Snare",	-- Icy Clutch (Chilblains)
	-- Druid
	[5211]  = "CC",		-- Bash (also Shaman Spirit Wolf ability)
	[33786] = "CC",		-- Cyclone
	[2637]  = "CC",		-- Hibernate (works against Druids in most forms and Shamans using Ghost Wolf)
	[22570] = "CC",		-- Maim
	[9005]  = "CC",		-- Pounce
	[339]   = "Root",	-- Entangling Roots
	[19675] = "Root",	-- Feral Charge Effect (immobilize with interrupt [spell lockout, not silence])
	[58179] = "Snare",	-- Infected Wounds
	[61391] = "Snare",	-- Typhoon
	-- Hunter
	[60210] = "CC",		-- Freezing Arrow Effect
	[3355]  = "CC",		-- Freezing Trap Effect
	[24394] = "CC",		-- Intimidation
	[1513]  = "CC",		-- Scare Beast (works against Druids in most forms and Shamans using Ghost Wolf)
	[19503] = "CC",		-- Scatter Shot
	[19386] = "CC",		-- Wyvern Sting
	[34490] = "Silence",	-- Silencing Shot
	[53359] = "Disarm",	-- Chimera Shot - Scorpid
	[19306] = "Root",	-- Counterattack
	[19185] = "Root",	-- Entrapment
	[35101] = "Snare",	-- Concussive Barrage
	[5116]  = "Snare",	-- Concussive Shot
	[13810] = "Snare",	-- Frost Trap Aura (no duration, lasts as long as you stand in it)
	[61394] = "Snare",	-- Glyph of Freezing Trap
	[2974]  = "Snare",	-- Wing Clip
	-- Hunter Pets
	[50519] = "CC",		-- Sonic Blast (Bat)
	[50541] = "Disarm",	-- Snatch (Bird of Prey)
	[54644] = "Snare",	-- Froststorm Breath (Chimera)
	[50245] = "Root",	-- Pin (Crab)
	[50271] = "Snare",	-- Tendon Rip (Hyena)
	[50518] = "CC",		-- Ravage (Ravager)
	[54706] = "Root",	-- Venom Web Spray (Silithid)
	[4167]  = "Root",	-- Web (Spider)
	-- Mage
	[44572] = "CC",		-- Deep Freeze
	[31661] = "CC",		-- Dragon's Breath
	[12355] = "CC",		-- Impact
	[118]   = "CC",		-- Polymorph
	[18469] = "Silence",	-- Silenced - Improved Counterspell
	[64346] = "Disarm",	-- Fiery Payback
	[33395] = "Root",	-- Freeze (Water Elemental)
	[122]   = "Root",	-- Frost Nova
	[11071] = "Root",	-- Frostbite
	[55080] = "Root",	-- Shattered Barrier
	[11113] = "Snare",	-- Blast Wave
	[6136]  = "Snare",	-- Chilled (generic effect, used by lots of spells [looks weird on Improved Blizzard, might want to comment out])
	[120]   = "Snare",	-- Cone of Cold
	[116]   = "Snare",	-- Frostbolt
	[47610] = "Snare",	-- Frostfire Bolt
	[31589] = "Snare",	-- Slow
	-- Paladin
	[853]   = "CC",		-- Hammer of Justice
	[2812]  = "CC",		-- Holy Wrath (works against Warlocks using Metamorphasis and Death Knights using Lichborne)
	[20066] = "CC",		-- Repentance
	[20170] = "CC",		-- Stun (Seal of Justice proc)
	[10326] = "CC",		-- Turn Evil (works against Warlocks using Metamorphasis and Death Knights using Lichborne)
	[63529] = "Silence",	-- Shield of the Templar
	[20184] = "Snare",	-- Judgement of Justice (100% movement snare; druids and shamans might want this though)
	-- Priest
	[605]   = "CC",		-- Mind Control
	[64044] = "CC",		-- Psychic Horror
	[8122]  = "CC",		-- Psychic Scream
	[9484]  = "CC",		-- Shackle Undead (works against Death Knights using Lichborne)
	[15487] = "Silence",	-- Silence
	--[64058] = "Disarm",	-- Psychic Horror (duplicate debuff names not allowed atm, need to figure out how to support this later)
	[15407] = "Snare",	-- Mind Flay
	-- Rogue
	[2094]  = "CC",		-- Blind
	[1833]  = "CC",		-- Cheap Shot
	[1776]  = "CC",		-- Gouge
	[408]   = "CC",		-- Kidney Shot
	[6770]  = "CC",		-- Sap
	[1330]  = "Silence",	-- Garrote - Silence
	[18425] = "Silence",	-- Silenced - Improved Kick
	[51722] = "Disarm",	-- Dismantle
	[31125] = "Snare",	-- Blade Twisting
	[3409]  = "Snare",	-- Crippling Poison
	[26679] = "Snare",	-- Deadly Throw
	-- Shaman
	[39796] = "CC",		-- Stoneclaw Stun
	[51514] = "CC",		-- Hex (although effectively a silence+disarm effect, it is conventionally thought of as a "CC", plus you can trinket out of it)
	[64695] = "Root",	-- Earthgrab (Storm, Earth and Fire)
	[63685] = "Root",	-- Freeze (Frozen Power)
	[3600]  = "Snare",	-- Earthbind (5 second duration per pulse, but will keep re-applying the debuff as long as you stand within the pulse radius)
	[8056]  = "Snare",	-- Frost Shock
	[8034]  = "Snare",	-- Frostbrand Attack
	-- Warlock
	[710]   = "CC",		-- Banish (works against Warlocks using Metamorphasis and Druids using Tree Form)
	[6789]  = "CC",		-- Death Coil
	[5782]  = "CC",		-- Fear
	[5484]  = "CC",		-- Howl of Terror
	[6358]  = "CC",		-- Seduction (Succubus)
	[30283] = "CC",		-- Shadowfury
	[24259] = "Silence",	-- Spell Lock (Felhunter)
	[18118] = "Snare",	-- Aftermath
	[18223] = "Snare",	-- Curse of Exhaustion
	-- Warrior
	[7922]  = "CC",		-- Charge Stun
	[12809] = "CC",		-- Concussion Blow
	[20253] = "CC",		-- Intercept (also Warlock Felguard ability)
	[5246]  = "CC",		-- Intimidating Shout
	[12798] = "CC",		-- Revenge Stun
	[46968] = "CC",		-- Shockwave
	[18498] = "Silence",	-- Silenced - Gag Order
	[676]   = "Disarm",	-- Disarm
	[58373] = "Root",	-- Glyph of Hamstring
	[23694] = "Root",	-- Improved Hamstring
	[1715]  = "Snare",	-- Hamstring
	[12323] = "Snare",	-- Piercing Howl
	-- Other
	[30217] = "CC",		-- Adamantite Grenade
	[67769] = "CC",		-- Cobalt Frag Bomb
	[30216] = "CC",		-- Fel Iron Bomb
	[20549] = "CC",		-- War Stomp
	[25046] = "Silence",	-- Arcane Torrent
	[39965] = "Root",	-- Frost Grenade
	[55536] = "Root",	-- Frostweave Net
	[13099] = "Root",	-- Net-o-Matic
	[29703] = "Snare",	-- Dazed
	-- Immunities
	[46924] = "Immune",	-- Bladestorm (Warrior)
	[642]   = "Immune",	-- Divine Shield (Paladin)
	[45438] = "Immune",	-- Ice Block (Mage)
	[34692] = "Immune",	-- The Beast Within (Hunter)
	-- PvE
	[28169] = "PvE",	-- Mutating Injection (Grobbulus)
	[28059] = "PvE",	-- Positive Charge (Thaddius)
	[28084] = "PvE",	-- Negative Charge (Thaddius)
	[27819] = "PvE",	-- Detonate Mana (Kel'Thuzad)
	[63024] = "PvE",	-- Gravity Bomb (XT-002 Deconstructor)
	[63018] = "PvE",	-- Light Bomb (XT-002 Deconstructor)
	[62589] = "PvE",	-- Nature's Fury (Freya, via Ancient Conservator)
	[63276] = "PvE",	-- Mark of the Faceless (General Vezax)
	[66770] = "PvE",	-- Ferocious Butt (Icehowl)
}
-- ---------------------------------------------------------------------------
-- Conquest of Azeroth crowd-control abilities (21 custom CoA classes).
-- Generated from db.ascension.gg. Each CoA mechanic is folded into this
-- addon's existing categories: ROOT->Root, SILENCE->Silence, DISARM->Disarm,
-- and every "cannot act" mechanic (stun, fear, incap, disorient, poly, horror,
-- charm, banish, sleep, freeze) -> CC, matching how the base list already
-- classifies fears, polymorphs, banishes and the like.
-- These IDs only exist on the CoA realm; on WotLK/Bronzebeard GetSpellInfo
-- returns nil for them and they are skipped silently (see the loop below).
local spellIdsForCoA = {
	-- Barbarian
	[520523] = "CC",	      -- Headbutt (STUN)  -- 4s stun on 40s cd
	[560532] = "CC",	      -- Skull Smash (DISORIENT)  -- 8s disorient on 2 min cd

	-- Bloodmage
	[281190] = "CC",        -- Hemostasis (HORROR)
	[681304] = "CC",        -- Hemostasis (HORROR)
	[801074] = "CC",	      -- Scarlet Delirium (FEAR)
	[804198] = "CC",	      -- Terrify (HORROR) -- horror on 2 min cd -- OBSOLETE?

	-- Chronomancer
	[280795] = "Disarm",    -- Desynchronization (DISARM)
	[561310] = "Disarm",    -- Desynchronization (DISARM)
	[706056] = "CC",        -- Slipstream (BANISH)
	[801280] = "CC",        -- Buy Time (STUN) -- 10s aoe stun on 2 min cd -- OBSOLETE!
	[804461] = "CC",	      -- Babify (POLY)
	[805162] = "CC",        -- Breath of Time (INCAP) -- 3s incapacitate on 30s cd -- OBSOLETE?
	[805847] = "Root",      -- Clasp of Infinity (ROOT)

	-- Cultist
	[560109] = "CC",        -- Corrupt Mind (FEAR)
	[560110] = "CC",        -- Madness (FEAR)
	[560963] = "CC",        -- Shackle The Unrepentant (BANISH)
	[805114] = "CC",	      -- Mass Nightmare (HORROR)  -- 5s aoe horror, on 3 min cd

	-- Felsworn
	[503142] = "Root",      -- Hellhaul (ROOT)
	[503143] = "Root",      -- Hellhaul (ROOT)
	[503144] = "Root",      -- Hellhaul (ROOT)
	[503145] = "Root",      -- Hellhaul (ROOT)
	[503146] = "Root",      -- Hellhaul (ROOT)
	[503147] = "Root",      -- Hellhaul (ROOT)
	[503148] = "Root",      -- Hellhaul (ROOT)
	[804168] = "CC",        -- Hellbound Leash (CHARM)

	[560284] = "CC",        -- Infernal (HORROR) -- 3-4s aoe horror, on 45s cd
	[704371] = 'Slow',      -- Cripple (SLOW) -- slow ms and casting speed by 60%, decaying over 12 sec, no cd
	[805235] = "CC",        -- Whispers of the Pit (FEAR) -- 8s aoe fear, on 1 min cd

	-- Guardian
	[501546] = "CC",        -- Battle Rush (STUN)  -- charge with 1s stun on 30s cd
	[501547] = "CC",        -- Battle Rush (STUN)
	[501548] = "CC",        -- Battle Rush (STUN)
	[802197] = "CC",        -- Battle Rush (STUN)
	[704418] = "Silence",   -- Hammer of the Law (SILENCE) -- 3s cone silence on 40s cd
	[801828] = "CC",	      -- Vanguard X-173: Onslaught (STUN) -- 3s cone stun on 20s cd
	[802304] = "Root",	    -- Net Throw (ROOT) -- 4s root on 20s cd

	-- Knight of Xoroth
	[503361] = "Silence",   -- Chainwhip (SILENCE)
	[503362] = "Silence",   -- Chainwhip (SILENCE)
	[503363] = "Silence",   -- Chainwhip (SILENCE)
	[503364] = "Silence",   -- Chainwhip (SILENCE)
	[503365] = "Silence",   -- Chainwhip (SILENCE)
	[503366] = "Silence",   -- Chainwhip (SILENCE)
	[503367] = "Silence",   -- Chainwhip (SILENCE)
	[800081] = "Silence",   -- Chainwhip (SILENCE)
	[803185] = "CC",        -- Chains of Malice (STUN)  -- 5s stun on 1 min cd

	-- Necromancer
	[500326] = "Root",      -- Bonefreeze (ROOT) (Freeze in place)
	[500341] = "CC",	      -- Entomb (DISORIENT)
	[800706] = "CC",        -- Ghoulify (FEAR)
	[803741] = "CC",        -- Mass Grave (FEAR)
	[280475] = "CC",        -- Mass Grave (FEAR)

	[501983] = "Root",	    -- Black Ice (ROOT) -- was it removed from Necromancer? -- OBSOLETE?
	[501984] = "Root",	    -- Black Ice (ROOT)
	[501985] = "Root",	    -- Black Ice (ROOT)
	[501986] = "Root",	    -- Black Ice (ROOT)
	[501987] = "Root",	    -- Black Ice (ROOT)
	[501988] = "Root",	    -- Black Ice (ROOT)
	[501989] = "Root",	    -- Black Ice (ROOT)
	[501990] = "Root",	    -- Black Ice (ROOT)
	[501991] = "Root",	    -- Black Ice (ROOT)
	[801746] = "Root",	    -- Black Ice (ROOT) -- effect

	-- Primalist	
	[800145] = "CC",	      -- Grip (INCAP) -- 8s incapacitate, 1.5s cast

	-- Pyromancer
	[535505] = "Root",	    -- Cindergrip (ROOT)  -- 1.5s cast root
	[535506] = "Root",	    -- Cindergrip (ROOT)
	[535507] = "Root",	    -- Cindergrip (ROOT)
	[535508] = "Root",	    -- Cindergrip (ROOT)
	[805476] = "Root",	    -- Cindergrip (ROOT)  -- effect?

	[806148] = "CC",        -- Gaze of Ysera (SLEEP)
	[502088] = "CC",        -- Petrifying Visage (HORROR)  -- 3s stunning horror on 2 min cd
	[502089] = "CC",        -- Petrifying Visage (HORROR)
	[502090] = "CC",        -- Petrifying Visage (HORROR)
	[801908] = "CC",        -- Petrifying Visage (HORROR)
	

	-- Ranger
	[804936] = "CC",	      -- Ambuscade (STUN)  -- death grip the target and stun for 3s, on 1 min cd

	-- Reaper
	[500355] = "CC",	      -- Mark of Terror (FEAR)     -- 5s fear on 30s cd
	[504014] = "CC",        -- Soulslam (HORROR)         -- 3s horror on 45s cd
	[803989] = 'CC',        -- Soul Shock (INCAP)        -- 8s sap
	[802086] = 'CC',        -- Mind Screech (SILENCE)    -- 3.5s silence, applied by Shrieking Scythe (with talent)
	[806146] = 'CC',        -- Ghastly Screech (SILENCE) -- 4s aoe silence on 1 min cd

	-- Runemaster
	[503423] = "CC",        -- Inscription: Permafrost (INCAP) -- incapacitate for 8s on 1 min cd; cd reduced to 0 during stealth/runeshroud
	[503424] = "CC",        -- Inscription: Permafrost (INCAP)
	[503425] = "CC",        -- Inscription: Permafrost (INCAP)
	[503426] = "CC",        -- Inscription: Permafrost (INCAP)
	[503427] = "CC",        -- Inscription: Permafrost (INCAP)
	[503428] = "CC",        -- Inscription: Permafrost (INCAP)
	[503429] = "CC",        -- Inscription: Permafrost (INCAP)
	[503430] = "CC",        -- Inscription: Permafrost (INCAP)
	[503431] = "CC",        -- Inscription: Permafrost (INCAP)
	[804060] = "CC",        -- Permafrost Rune (INCAP) -- incapacitate for 10s on 1 min cd; cd reduced by 80% during stealth/runeshroud
  [502634] = "CC",	      -- Everfrost Scroll (STUN) -- stun for 3.5s on 1 min cd
	[502635] = "CC",	      -- Everfrost Scroll (STUN)
	[502636] = "CC",	      -- Everfrost Scroll (STUN)
	[502637] = "CC",	      -- Everfrost Scroll (STUN)
	[502638] = "CC",	      -- Everfrost Scroll (STUN)
	[502639] = "CC",	      -- Everfrost Scroll (STUN)
	[502640] = "CC",	      -- Everfrost Scroll (STUN)
	[502641] = "CC",	      -- Everfrost Scroll (STUN)
	[502642] = "CC",	      -- Everfrost Scroll (STUN)

	-- Starcaller
	[804738] = "CC",        -- Siren's Song (CHARM)
	[503012] = "Silence",   -- Slipstream (SILENCE)    -- self silence for 5s + aoe heal, on 15s cd
	[503013] = "Silence",   -- Slipstream (SILENCE)
	[503014] = "Silence",   -- Slipstream (SILENCE)
	[503015] = "Silence",   -- Slipstream (SILENCE)
	[503016] = "Silence",   -- Slipstream (SILENCE)
	[503017] = "Silence",   -- Slipstream (SILENCE)
	[503018] = "Silence",   -- Slipstream (SILENCE)
	[800366] = "Silence",   -- Slipstream (SILENCE)
	[801135] = "CC",	      -- Starshatter (STUN)      -- inline 5s stun, on 1 min cd
	[805546] = "CC",	      -- Moonlit Slumber (SLEEP) -- 6s sleep, on 1 min cd
	[806156] = "Silence",	  -- Astral Armor (SILENCE)  -- 3s silence

	-- Stormbringer
	[707044] = "CC",	      -- Storm Alert (FEAR) -- 8s fear with 2.0s cast
	[707905] = "CC",	      -- Storm Alert (FEAR) -- 8s fear with 1.8s cast
	[707906] = "CC",	      -- Storm Alert (FEAR) -- 8s fear with 1.7s cast
	[801871] = "Root",	    -- Thunder Prison Unused (ROOT)

	-- Sun Cleric
	[805583] = "CC",        -- Glare (STUN)   -- 5s aoe stun on 2 min cd
	[560764] = "CC",	      -- Celestial Impact (INCAP)  -- OBSOLETE?

	-- Templar
	[560116] = "Silence",	  -- Interdict (SILENCE)   -- 6s silence on 2 min cd -- undead and demons also cannot be healed
	[806121] = "CC",        -- Judgement Day (INCAP)

	-- Tinker
	[804861] = "Silence",	  -- Anti-Magic Grenades (SILENCE) -- aoe silence for 4s, on 2 min cd, also dispells 3 beneficial magic effects
	[806173] = "CC",	      -- Drill Smash (STUN) -- 4s stun, on 30s cd

	-- Venomancer
	[504335] = "CC",	      -- Web Wrap (STUN)    -- 5s stun, on 1 min cd
	[800876] = "Snare",	    -- Web Wrap (SLOW)    -- 4s channeled ms slow on 20s cd (plus 30% dmg increase), rank1
	[502881] = "Snare",	    -- Web Wrap (SLOW)    -- 4s channeled ms slow on 20s cd (plus 30% dmg increase), rank2
	[502882] = "Snare",	    -- Web Wrap (SLOW)    -- 4s channeled ms slow on 20s cd (plus 30% dmg increase), rank3
	[502883] = "Snare",	    -- Web Wrap (SLOW)    -- 4s channeled ms slow on 20s cd (plus 30% dmg increase), rank4
	[502884] = "Snare",	    -- Web Wrap (SLOW)    -- 4s channeled ms slow on 20s cd (plus 30% dmg increase), rank5
	[502885] = "Snare",	    -- Web Wrap (SLOW)    -- 4s channeled ms slow on 20s cd (plus 30% dmg increase), rank6
	[502886] = "Snare",	    -- Web Wrap (SLOW)    -- 4s channeled ms slow on 20s cd (plus 30% dmg increase), rank7
	[502887] = "Snare",	    -- Web Wrap (SLOW)    -- 4s channeled ms slow on 20s cd (plus 30% dmg increase), rank8
	[502888] = "Snare",	    -- Web Wrap (SLOW)    -- 4s channeled ms slow on 20s cd (plus 30% dmg increase), rank9

	[504362] = "CC",	      -- Fungify (CHARM)    -- mix of Mind Control and succubus' Seduction, but 1.5s cast instead of channel -- OBSOLETE?
	[502890] = "Root",      -- Spindlebind (ROOT) -- 4s root on 16s cd
	[502891] = "Root",      -- Spindlebind (ROOT)
	[502892] = "Root",      -- Spindlebind (ROOT)
	[502893] = "Root",      -- Spindlebind (ROOT)
	[502894] = "Root",      -- Spindlebind (ROOT)
	[502895] = "Root",      -- Spindlebind (ROOT)
	[800887] = "Root",      -- Spindlebind (ROOT)
	[800877] = "CC",        -- Shadra's Binding (STUN)
	
	[704235] = "Disarm",	  -- Pinch (DISARM) -- disarm for 5s on 1 min cd
	[804967] = "Root",	    -- Venocannon (ROOT) -- self root on 1 min cd -- OBSOLETE?

	-- Witch Doctor
	[803678] = "Silence",   -- Malignant Jinx (SILENCE)
	[803732] = "Silence",   -- Malignant Jinx (SILENCE)
	[280056] = "Silence",   -- Malignant Jinx (SILENCE)
	[500952] = "CC",        -- Amphibimorph (POLY)
	[801665] = "Root",      -- Big Bad Voodoo (ROOT)

	-- Witch Hunter
  [500089] = "Silence",   -- Subjugate (SILENCE) -- 4s silence and 40% ms slow, on 1 min cd
	[802139] = "CC",	      -- Darkslayer's Lantern (STUN) -- 5s aoe stun, on 2 min cd
	[805756] = "CC",	      -- Smoke Grenade (SNARE) -- 8s snare and inability to target in and out of cloud, on 2 min cd

  -- Other
	[800013] = "CC",	      -- Facehug (STUN) -- 3s stun on 1 min cd -- MINDBENDER?
	[800354] = "CC",	      -- Enslave (POLY) -- 8s poly with 1.7s cast -- MINDBENDER?

	[800950] = "Silence",	  -- Deathmatch (SILENCE) -- banish self and target for 6s on 1 min cd
	[803531] = "Silence",	  -- Deathmatch (SILENCE) -- banish self and target for 6s on 1 min cd
}

local interruptIdsForCoA = {
	-- Bloodmage
	[806099] = "Interrupt", -- Aneurysm -- cs for 4s, on 24s cd

  -- Cultist
	[804056] = "Interrupt", -- Crushing Dissonance -- aoe cs for 2s, on 30s cd

  -- Felsworn
	[800203] = "Interrupt", -- Fel Break -- cs for 3s, on 18s cd, has 0.5s cast time

	-- Guardian
	[500268] = "Interrupt", -- Bastion Slam -- cs for 0s?, on 25s cd
	[704159] = "Interrupt", -- Shield of Denial -- cs for 3s, on 30s cd

	-- Necromancer
  [801739] = "Interrupt", -- Heartchill -- cs for 0s, but lower enemy ms and haste for 3s, on 30s cd

  -- Pyromancer
	[800808] = "Interrupt", -- Spellburn -- cs for 5s, on 25s cd

  -- Reaper
	[806125] = "Interrupt", -- Siphon Essence -- cs for 3s, on 20s cd
	[807737] = "Interrupt", -- Siphon Essence -- cs for 3s, on 20s cd
	[807738] = "Interrupt", -- Siphon Essence -- cs for 3s, on 20s cd
	[807739] = "Interrupt", -- Siphon Essence -- cs for 3s, on 20s cd
	[807740] = "Interrupt", -- Siphon Essence -- cs for 3s, on 20s cd

  -- Runemaster
	[800995] = "Interrupt", -- Ley Lock -- cs for 2.5s, on 6s cd, has 0.5s cast time

	-- Starcaller
	[805432] = "Interrupt", -- Halt -- cs for 3s, on 15s cd -- OBSOLETE?

	-- Stormbringer
	[500932] = "Interrupt", -- Gust of Wind -- cs for 5s, on 35s cd

	-- Venomancer
	[805096] = "Interrupt", -- Nullifying Toxin -- cs for 3s, on 16s cd

	-- Witch Doctor
	-- [806294] = "Interrupt", -- Spirit Shock -- cs until cancelled, on 24s cd -- OBSOLETE -- DEPRECATED
	-- Spirit Shock is now a 4s SILENCE vs players, and 4s cs interrupt vs NPCs

	-- Witch Hunter
	[804432] = "Interrupt", -- Guard Strike -- cs for 3s, on 18s cd
}

-- Merge the CoA abilities into the main spellIds table so a single lookup
-- table covers both WotLK and Conquest of Azeroth. (CoA IDs are 500000+ and
-- never collide with the original sub-70000 IDs, so nothing is overwritten.)
for k, v in pairs(spellIdsForCoA) do
	spellIds[k] = v
end

local abilities = {} -- localized names are saved here
for k, v in pairs(spellIds) do
	local name = GetSpellInfo(k)
	if name then
		abilities[name] = v
	else -- Thanks to inph for this idea. Keeps things from breaking when Blizzard changes things.
		-- log(L .. " unknown spellId: " .. k)
	end
	-- If GetSpellInfo returns nil, this spellId does not exist on the current
	-- client (e.g. a Conquest of Azeroth spell on a WotLK/Bronzebeard realm, or
	-- vice versa). Skip it silently so the same addon runs clean -- no errors,
	-- no chat spam -- on all three supported realms.
end

-------------------------------------------------------------------------------
-- Anchor resolution helpers (hardened: they never raise, always return a
-- frame/region or nil, and callers fall back to UIParent on nil).
--
-- An anchor entry may be either:
--   * a string   -> the name of a global frame/region, resolved via _G
--   * a function -> called at resolve time (wrapped in pcall) returning a
--                   frame/region or nil. Used for addons that need runtime
--                   logic (PitBull4 localized names, sArena's varied naming).

-- Returns a closure that resolves _G[frameName] and, if present, its sub-element
-- (e.g. a "portrait"/"Portrait" child); otherwise the frame itself; else nil.
local function PortraitOrFrame(frameName, subKey)
	return function()
		local base = _G[frameName]
		if type(base) ~= "table" then return nil end
		if subKey then
			local sub = base[subKey]
			if type(sub) == "table" then return sub end
		end
		return base
	end
end

-- PitBull4 names its unit frames "PitBull4_Frames_<LocalizedUnitName>", where the
-- localized name comes from AceLocale. Every step is guarded, so a missing lib,
-- missing locale, or missing entry can never raise (no nil concatenation).
-- Look up a PitBull4 AceLocale string (e.g. localized "Player"/"Party"), fully
-- guarded so a missing lib/locale/entry can never raise (no nil concatenation).
local function pb4Locale(key)
	if type(LibStub) ~= "table" then return nil end -- LibStub is a callable table
	local AceLocale = LibStub("AceLocale-3.0", true)
	if type(AceLocale) ~= "table" then return nil end
	local ok, L = pcall(AceLocale.GetLocale, AceLocale, "PitBull4", true)
	if not ok or type(L) ~= "table" then return nil end
	local ok2, s = pcall(function() return L[key] end)
	if ok2 and type(s) == "string" then return s end
	return nil
end

-- Return a frame's portrait sub-element if wanted and present, else the frame.
local function pb4pick(f, wantPortrait)
	if type(f) ~= "table" then return nil end
	if wantPortrait and type(f.Portrait) == "table" then return f.Portrait end
	return f
end

-- Resolve a PitBull4 singleton frame (player/target/focus). Builds differ: some
-- name frames by the lowercase unit token (Pitbull4_Frames_player, as on this
-- client), others by the capitalized localized label (PitBull4_Frames_Player).
-- Probe both prefixes and both forms; first existing frame wins.
local function PitBull4Frame(localeKey, token, wantPortrait)
	return function()
		local names = { "Pitbull4_Frames_" .. token, "PitBull4_Frames_" .. token }
		local label = pb4Locale(localeKey)
		if label then
			names[#names + 1] = "PitBull4_Frames_" .. label
			names[#names + 1] = "Pitbull4_Frames_" .. label
		end
		for _, n in ipairs(names) do
			local hit = pb4pick(_G[n], wantPortrait)
			if hit then return hit end
		end
		return nil
	end
end

-- Resolve a PitBull4 party group frame (Pitbull4_Groups_PartyUnitButtonN on this
-- client). Probe both prefixes plus the localized group-label variant.
local function PitBull4GroupFrame(index, wantPortrait)
	return function()
		local names = {
			"Pitbull4_Groups_PartyUnitButton" .. index,
			"PitBull4_Groups_PartyUnitButton" .. index,
		}
		local party = pb4Locale("Party")
		if party then
			names[#names + 1] = "PitBull4_Groups_" .. party .. "UnitButton" .. index
			names[#names + 1] = "Pitbull4_Groups_" .. party .. "UnitButton" .. index
		end
		for _, n in ipairs(names) do
			local hit = pb4pick(_G[n], wantPortrait)
			if hit then return hit end
		end
		return nil
	end
end

-- sArena forks are inconsistent: some expose global frames, newer (WoD-based)
-- builds keep them only in an internal table. Probe both, fully guarded. If your
-- build uses a different global name, add it to the `candidates` list below.
local function sArenaFrame(i)
	local function pick(f)
		if type(f) ~= "table" then return nil end
		if type(f.classPortrait) == "table" then return f.classPortrait end
		if type(f.Portrait) == "table" then return f.Portrait end
		if type(f.portrait) == "table" then return f.portrait end
		return f
	end
	return function()
		local core = _G["sArena"]
		if type(core) == "table" and type(core.unitFrames) == "table" then
			local hit = pick(core.unitFrames[i])
			if hit then return hit end
		end
		local candidates = {
			"sArenaEnemyFrame" .. i,
			"sArenaFrame" .. i,
			"sArenaUnitFrame" .. i,
			"sArena_UnitFrame" .. i,
		}
		for _, name in ipairs(candidates) do
			local hit = pick(_G[name])
			if hit then return hit end
		end
		return nil
	end
end

-------------------------------------------------------------------------------
-- Global references for attaching icons to various unit frames
local anchors = {
	None = {}, -- empty but necessary
	Blizzard = {
		player = "PlayerPortrait",
		target = "TargetFramePortrait",
		focus  = "FocusFramePortrait",
		party1 = "PartyMemberFrame1Portrait",
		party2 = "PartyMemberFrame2Portrait",
		party3 = "PartyMemberFrame3Portrait",
		party4 = "PartyMemberFrame4Portrait",
		arena1 = "ArenaEnemyFrame1ClassPortrait",
		arena2 = "ArenaEnemyFrame2ClassPortrait",
		arena3 = "ArenaEnemyFrame3ClassPortrait",
		arena4 = "ArenaEnemyFrame4ClassPortrait",
		arena5 = "ArenaEnemyFrame5ClassPortrait",
	},
	Perl = {
		player = "Perl_Player_Portrait",
		target = "Perl_Target_Portrait",
		focus  = "Perl_Focus_Portrait",
		party1 = "Perl_Party_MemberFrame1_Portrait",
		party2 = "Perl_Party_MemberFrame2_Portrait",
		party3 = "Perl_Party_MemberFrame3_Portrait",
		party4 = "Perl_Party_MemberFrame4_Portrait",
	},
	XPerl = {
		player = "XPerl_PlayerportraitFrameportrait",
		target = "XPerl_TargetportraitFrameportrait",
		focus  = "XPerl_FocusportraitFrameportrait",
		party1 = "XPerl_party1portraitFrameportrait",
		party2 = "XPerl_party2portraitFrameportrait",
		party3 = "XPerl_party3portraitFrameportrait",
		party4 = "XPerl_party4portraitFrameportrait",
	},
	-- ----------------------------------------------------------------------
	-- Added for LoseControlCoA. Party frames are intentionally limited to
	-- what the 3.3.5 API exposes; any unsupported unit simply resolves to
	-- nil and the icon falls back to the screen centre (never an error).
	-- PitBull4 has three profiles:
	--   _Auto      : resolves the frame via AceLocale at runtime (portrait).
	--                Works across locales/versions but depends on PitBull4 naming.
	--   _Hardcoded : fixed global frame names verified in-game on this build
	--                (note the lowercase "Pitbull4" prefix on this client).
	--   _Portraits : the 3D portrait models. Numbering (_1.._7) follows PitBull4
	--                frame creation order (player, target, focus, party1-4); if you
	--                reconfigure PitBull4 frames these indices may shift.
	PitBull4_Auto = {
		player = PitBull4Frame("Player", "player", true),
		target = PitBull4Frame("Target", "target", true),
		focus  = PitBull4Frame("Focus",  "focus",  true),
		party1 = PitBull4GroupFrame(1, true),
		party2 = PitBull4GroupFrame(2, true),
		party3 = PitBull4GroupFrame(3, true),
		party4 = PitBull4GroupFrame(4, true),
	},
	PitBull4_Hardcoded = {
		player = "Pitbull4_Frames_player",
		target = "Pitbull4_Frames_target",
		focus  = "Pitbull4_Frames_focus",
		party1 = "Pitbull4_Groups_PartyUnitButton1",
		party2 = "Pitbull4_Groups_PartyUnitButton2",
		party3 = "Pitbull4_Groups_PartyUnitButton3",
		party4 = "Pitbull4_Groups_PartyUnitButton4",
	},
	PitBull4_Portraits = {
		player = "Pitbull4_PlayerModel_1",
		target = "Pitbull4_PlayerModel_2",
		focus  = "Pitbull4_PlayerModel_3",
		party1 = "Pitbull4_PlayerModel_4",
		party2 = "Pitbull4_PlayerModel_5",
		party3 = "Pitbull4_PlayerModel_6",
		party4 = "Pitbull4_PlayerModel_7",
	},
	ElvUI = {
		player = PortraitOrFrame("ElvUF_Player", "Portrait"),
		target = PortraitOrFrame("ElvUF_Target", "Portrait"),
		focus  = PortraitOrFrame("ElvUF_Focus",  "Portrait"),
		arena1 = PortraitOrFrame("ElvUF_Arena1", "Portrait"),
		arena2 = PortraitOrFrame("ElvUF_Arena2", "Portrait"),
		arena3 = PortraitOrFrame("ElvUF_Arena3", "Portrait"),
		arena4 = PortraitOrFrame("ElvUF_Arena4", "Portrait"),
		arena5 = PortraitOrFrame("ElvUF_Arena5", "Portrait"),
	},
	SUF = {	-- ShadowedUnitFrames
		player = PortraitOrFrame("SUFUnitplayer", "portrait"),
		target = PortraitOrFrame("SUFUnittarget", "portrait"),
		focus  = PortraitOrFrame("SUFUnitfocus",  "portrait"),
		arena1 = PortraitOrFrame("SUFHeaderarenaUnitButton1", "portrait"),
		arena2 = PortraitOrFrame("SUFHeaderarenaUnitButton2", "portrait"),
		arena3 = PortraitOrFrame("SUFHeaderarenaUnitButton3", "portrait"),
		arena4 = PortraitOrFrame("SUFHeaderarenaUnitButton4", "portrait"),
		arena5 = PortraitOrFrame("SUFHeaderarenaUnitButton5", "portrait"),
	},
	Gladius = {
		arena1 = "GladiusClassIconFramearena1",
		arena2 = "GladiusClassIconFramearena2",
		arena3 = "GladiusClassIconFramearena3",
		arena4 = "GladiusClassIconFramearena4",
		arena5 = "GladiusClassIconFramearena5",
	},
	GladiusEx = {
		party1 = "GladiusExClassIconFrameparty1",
		party2 = "GladiusExClassIconFrameparty2",
		party3 = "GladiusExClassIconFrameparty3",
		party4 = "GladiusExClassIconFrameparty4",
		arena1 = "GladiusExClassIconFramearena1",
		arena2 = "GladiusExClassIconFramearena2",
		arena3 = "GladiusExClassIconFramearena3",
		arena4 = "GladiusExClassIconFramearena4",
		arena5 = "GladiusExClassIconFramearena5",
	},
	sArena = {
		arena1 = sArenaFrame(1),
		arena2 = sArenaFrame(2),
		arena3 = sArenaFrame(3),
		arena4 = sArenaFrame(4),
		arena5 = sArenaFrame(5),
	},
	-- more to come here?
}

-- Resolve an anchor entry (string global name or function) to a frame/region.
-- Always returns a frame/region or nil; never raises.
local function GetAnchorFrame(profileName, unitId)
	local profile = anchors[profileName]
	if type(profile) ~= "table" then return nil end
	local entry = profile[unitId]
	local t = type(entry)
	if t == "string" then
		local f = _G[entry]
		if type(f) == "table" then return f end
		return nil
	elseif t == "function" then
		local ok, result = pcall(entry, unitId)
		if ok and type(result) == "table" then return result end
		return nil
	end
	return nil
end

-- Order the anchor profiles appear in the options dropdown.
local anchorOrder = { "Blizzard", "Perl", "XPerl", "PitBull4_Auto", "PitBull4_Hardcoded", "PitBull4_Portraits", "ElvUI", "SUF", "Gladius", "GladiusEx", "sArena" }

-------------------------------------------------------------------------------
-- Default settings
local DBdefaults = {
	version = 3.32, -- This is the settings version, not necessarily the same as the LoseControl version
	noCooldownCount = false,
	tracking = { -- To Do: Priority
		Immune  = false, --100
		CC      = true,  -- 90
		PvE     = true,  -- 80
		Silence = true,  -- 70
		Disarm  = true,  -- 60
		Root    = false, -- 50
		Snare   = false, -- 40
	},
	frames = {
		player = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "None",
		},
		target = {
			enabled = true,
			size = 56,
			alpha = 1,
			anchor = "Blizzard",
		},
		focus = {
			enabled = true,
			size = 44,
			alpha = 1,
			anchor = "Blizzard",
		},
		party1 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		party2 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		party3 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		party4 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena1 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena2 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena3 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena4 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena5 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
	},
}
local LoseControlDB -- local reference to the addon settings. this gets initialized when the ADDON_LOADED event fires

-------------------------------------------------------------------------------
-- Create the main class
local LoseControl = CreateFrame("Cooldown", nil, UIParent) -- Exposes the SetCooldown method

function LoseControl:OnEvent(event, ...) -- functions created in "object:method"-style have an implicit first parameter of "self", which points to object
	self[event](self, ...) -- route event parameters to LoseControl:event methods
end
LoseControl:SetScript("OnEvent", LoseControl.OnEvent)

-- Handle default settings
function LoseControl:ADDON_LOADED(arg1)
	if arg1 == L then
		if _G.LoseControlDB and _G.LoseControlDB.version then
			if _G.LoseControlDB.version < DBdefaults.version then
				if _G.LoseControlDB.version >= 3.22 then -- minor changes, so try to update without losing settings
					_G.LoseControlDB.tracking = {
						Immune  = false, --100
						CC      = true,  -- 90
						PvE     = true,  -- 80
						Silence = true,  -- 70
						Disarm  = true,  -- 60
						Root    = false, -- 50
						Snare   = false, -- 40
					}
					_G.LoseControlDB.version = 3.32
				else -- major changes, must reset settings
					_G.LoseControlDB = CopyTable(DBdefaults)
					log(LOSECONTROL["LoseControl reset."])
				end
			end
		else -- never installed before
			_G.LoseControlDB = CopyTable(DBdefaults)
			log(LOSECONTROL["LoseControl reset."])
		end
		LoseControlDB = _G.LoseControlDB
		LoseControl.noCooldownCount = LoseControlDB.noCooldownCount
	end
end
LoseControl:RegisterEvent("ADDON_LOADED")

-- Initialize a frame's position
function LoseControl:PLAYER_ENTERING_WORLD() -- this correctly anchors enemy arena frames that aren't created until you zone into an arena
	self.frame = LoseControlDB.frames[self.unitId] -- store a local reference to the frame's settings
	local frame = self.frame
	self.anchor = GetAnchorFrame(frame.anchor, self.unitId) or UIParent

	self:SetParent(self.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
	--self:SetFrameStrata(frame.strata or "LOW")
	self:ClearAllPoints() -- if we don't do this then the frame won't always move
	self:SetWidth(frame.size)
	self:SetHeight(frame.size)
	self:SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	--self:SetAlpha(frame.alpha) -- doesn't seem to work; must manually set alpha after the cooldown is displayed, otherwise it doesn't apply.
end

local WYVERN_STING = GetSpellInfo(19386)
local PSYCHIC_HORROR = GetSpellInfo(64058)
local UnitDebuff = UnitDebuff
local UnitBuff = UnitBuff
-- This is the main event
function LoseControl:UNIT_AURA(unitId) -- fired when a (de)buff is gained/lost
	if unitId ~= self.unitId or not self.frame.enabled or not self.anchor:IsVisible() then return end

	local maxExpirationTime = 0
	local _, name, icon, Icon, duration, Duration, expirationTime, wyvernsting

	for i = 1, 40 do
		name, _, icon, _, _, duration, expirationTime = UnitDebuff(unitId, i)

		if not name then
			--log("UnitDebuff " .. unitId .. " " .. i)
			break
		end -- no more debuffs, terminate the loop
		--log(i .. ") " .. name .. " | " .. rank .. " | " .. icon .. " | " .. count .. " | " .. debuffType .. " | " .. duration .. " | " .. expirationTime )

		-- exceptions
		if name == WYVERN_STING then
			wyvernsting = 1
			if not self.wyvernsting then
				self.wyvernsting = 1 -- this is the first time the debuff has been applied
			elseif expirationTime > self.wyvernsting_expirationTime then
				self.wyvernsting = 2 -- this is the second time the debuff has been applied
			end
			self.wyvernsting_expirationTime = expirationTime
			if self.wyvernsting == 2 then
				name = nil -- hack to skip the next if condition since LUA doesn't have a "continue" statement
			end
		elseif name == PSYCHIC_HORROR and icon == "Interface\\Icons\\Ability_Warrior_Disarm" then -- hack to remove Psychic Horror disarm effect
			name = nil
		end

		if LoseControlDB.tracking[abilities[name]] and expirationTime > maxExpirationTime then
			maxExpirationTime = expirationTime
			Duration = duration
			Icon = icon
		end
	end

	-- continue hack for Wyvern Sting
	if self.wyvernsting == 2 and not wyvernsting then -- dot either removed or expired
		self.wyvernsting = nil
	end

	-- Track Immunities
	if LoseControlDB.tracking.Immune and not Icon and unitId ~= "player" then -- only bother checking for immunities if there were no debuffs found
		for i = 1, 40 do
			name, _, icon, _, _, duration, expirationTime = UnitBuff(unitId, i)
			if not name then
				--log("UnitBuff " .. unitId .. " " .. i)
				break
			elseif abilities[name] == "Immune" and expirationTime > maxExpirationTime then
				maxExpirationTime = expirationTime
				Duration = duration
				Icon = icon
			end
		end
	end

	if maxExpirationTime == 0 then -- no (de)buffs found
		self.maxExpirationTime = 0
		if self.anchor ~= UIParent and self.drawlayer and self.anchor.SetDrawLayer then
			self.anchor:SetDrawLayer(self.drawlayer) -- restore the original draw layer (textures only)
		end
		self:Hide()
	elseif maxExpirationTime ~= self.maxExpirationTime then -- this is a different (de)buff, so initialize the cooldown
		self.maxExpirationTime = maxExpirationTime
		if self.anchor ~= UIParent then
			local parent = self.anchor:GetParent()
			if parent then
				self:SetFrameLevel(parent:GetFrameLevel()) -- must be dynamic, frame level changes all the time
			end
			-- The draw-layer swap only applies to textures/regions that support
			-- it. Frames (e.g. Gladius icons) and 3D portrait models do not, so
			-- guard against calling nil methods.
			if self.anchor.GetDrawLayer and self.anchor.SetDrawLayer then
				if not self.drawlayer then
					self.drawlayer = self.anchor:GetDrawLayer() -- back up the current draw layer
				end
				self.anchor:SetDrawLayer("BACKGROUND") -- put the portrait texture below the debuff texture so the cooldown spiral stays visible on top
			end
		end
		if self.frame.anchor == "Blizzard" then
			SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits. TO DO: mask the cooldown frame somehow so the corners don't stick out of the portrait frame. Maybe apply a circular alpha mask in the OVERLAY draw layer.
		else
			self.texture:SetTexture(Icon)
		end
		self:Show()
		self:SetCooldown( maxExpirationTime - Duration, Duration )
		self:SetAlpha(self.frame.alpha) -- hack to apply transparency to the cooldown timer
	end
end

function LoseControl:PLAYER_FOCUS_CHANGED()
	self:UNIT_AURA("focus")
end

function LoseControl:PLAYER_TARGET_CHANGED()
	self:UNIT_AURA("target")
end

local UnitDropDown -- declared here, initialized below in the options panel code
local AnchorDropDown
-- Handle mouse dragging
function LoseControl:StopMoving()
	local frame = self.frame --LoseControlDB.frames[self.unitId]
	frame.point, frame.anchor, frame.relativePoint, frame.x, frame.y = self:GetPoint()
	if not frame.anchor then
		frame.anchor = "None"
		if UIDropDownMenu_GetSelectedValue(UnitDropDown) == self.unitId then
			UIDropDownMenu_SetSelectedValue(AnchorDropDown, "None") -- update the drop down to show that the frame has been detached from the anchor
		end
	end
	self.anchor = GetAnchorFrame(frame.anchor, self.unitId) or UIParent
	self:StopMovingOrSizing()
end

-- Constructor method
function LoseControl:new(unitId)
	local o = CreateFrame("Cooldown", L .. unitId) --, UIParent)
	setmetatable(o, self)
	self.__index = self

	-- Init class members
	o.unitId = unitId -- ties the object to a unit
	o.texture = o:CreateTexture(nil, "BORDER") -- displays the debuff; draw layer should equal "BORDER" because cooldown spirals are drawn in the "ARTWORK" layer.
	o.texture:SetAllPoints(o) -- anchor the texture to the frame
	o:SetReverse(true) -- makes the cooldown shade from light to dark instead of dark to light

	--[[ Rufio's code to make the frame border pretty. Maybe use this somehow to mask cooldown corners in Blizzard frames.]]
	o.overlay = o:CreateTexture(nil, "OVERLAY");
	o.overlay:SetTexture("Interface\\AddOns\\LoseControlCoA\\gloss");
	o.overlay:SetPoint("TOPLEFT", -1, 1);
	o.overlay:SetPoint("BOTTOMRIGHT", 1, -1);
	o.overlay:SetVertexColor(0.25, 0.25, 0.25);
	o:Hide()

	-- Handle events
	o:SetScript("OnEvent", self.OnEvent)
	o:SetScript("OnDragStart", self.StartMoving) -- this function is already built into the Frame class
	o:SetScript("OnDragStop", self.StopMoving) -- this is a custom function
	o:RegisterEvent("PLAYER_ENTERING_WORLD")
	o:RegisterEvent("UNIT_AURA")
	if unitId == "focus" then
		o:RegisterEvent("PLAYER_FOCUS_CHANGED")
	elseif unitId == "target" then
		o:RegisterEvent("PLAYER_TARGET_CHANGED")
	end

	return o
end

-- Create new object instance for each frame
local LC = {}
for k in pairs(DBdefaults.frames) do
	LC[k] = LoseControl:new(k)
end

-------------------------------------------------------------------------------
-- Add main Interface Option Panel
local O = L .. "OptionsPanel"

local OptionsPanel = CreateFrame("Frame", O)
OptionsPanel.name = L

local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetText(L)

local subText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
local notes = GetAddOnMetadata(L, "Notes-" .. GetLocale())
if not notes then
	notes = GetAddOnMetadata(L, "Notes")
end
subText:SetText(notes)

-- "Unlock" checkbox - allow the frames to be moved
local Unlock = CreateFrame("CheckButton", O.."Unlock", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."UnlockText"]:SetText(LOSECONTROL["Unlock"])
function Unlock:OnClick()
	if self:GetChecked() then
		_G[O.."UnlockText"]:SetText(LOSECONTROL["Unlock"] .. LOSECONTROL[" (drag an icon to move)"])
		local keys = {} -- for random icon sillyness
		for k in pairs(spellIds) do
			tinsert(keys, k)
		end
		for k, v in pairs(LC) do
			local frame = LoseControlDB.frames[k]
			if frame.enabled and (GetAnchorFrame(frame.anchor, k) or frame.anchor == "None") then -- only unlock frames whose anchor exists
				v:UnregisterEvent("UNIT_AURA")
				v:UnregisterEvent("PLAYER_FOCUS_CHANGED")
				v:UnregisterEvent("PLAYER_TARGET_CHANGED")
				v:SetMovable(true)
				v:RegisterForDrag("LeftButton")
				v:EnableMouse(true)
				v.texture:SetTexture(select(3, GetSpellInfo(keys[random(#keys)])))
				v:SetParent(nil) -- detach the frame from its parent or else it won't show if the parent is hidden
				--v:SetFrameStrata(frame.strata or "MEDIUM")
				if v.anchor:GetParent() then
					v:SetFrameLevel(v.anchor:GetParent():GetFrameLevel())
				end
				v:Show()
				v:SetCooldown( GetTime(), 30 )
				v:SetAlpha(frame.alpha) -- hack to apply the alpha to the cooldown timer
			end
		end
	else
		_G[O.."UnlockText"]:SetText(LOSECONTROL["Unlock"])
		for k, v in pairs(LC) do
			--local frame = LoseControlDB.frames[k]
			v:RegisterEvent("UNIT_AURA")
			if k == "focus" then
				v:RegisterEvent("PLAYER_FOCUS_CHANGED")
			elseif k == "target" then
				v:RegisterEvent("PLAYER_TARGET_CHANGED")
			end
			v:SetMovable(false)
			v:RegisterForDrag()
			v:EnableMouse(false)
			v:SetParent(v.anchor:GetParent()) -- or UIParent)
			--v:SetFrameStrata(frame.strata or "LOW")
			v:Hide()
		end
	end
end
Unlock:SetScript("OnClick", Unlock.OnClick)

local DisableCooldownCount = CreateFrame("CheckButton", O.."DisableCooldownCount", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableCooldownCountText"]:SetText(LOSECONTROL["Disable OmniCC/CooldownCount Support"])
DisableCooldownCount:SetScript("OnClick", function(self)
	LoseControlDB.noCooldownCount = self:GetChecked()
	LoseControl.noCooldownCount = LoseControlDB.noCooldownCount
end)

local Tracking = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
Tracking:SetText(LOSECONTROL["Tracking"])

local TrackCCs = CreateFrame("CheckButton", O.."TrackCCs", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackCCsText"]:SetText(LOSECONTROL["CC"])
TrackCCs:SetScript("OnClick", function(self)
	LoseControlDB.tracking.CC = self:GetChecked()
end)

local TrackSilences = CreateFrame("CheckButton", O.."TrackSilences", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackSilencesText"]:SetText(LOSECONTROL["Silence"])
TrackSilences:SetScript("OnClick", function(self)
	LoseControlDB.tracking.Silence = self:GetChecked()
end)

local TrackDisarms = CreateFrame("CheckButton", O.."TrackDisarms", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackDisarmsText"]:SetText(LOSECONTROL["Disarm"])
TrackDisarms:SetScript("OnClick", function(self)
	LoseControlDB.tracking.Disarm = self:GetChecked()
end)

local TrackRoots = CreateFrame("CheckButton", O.."TrackRoots", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackRootsText"]:SetText(LOSECONTROL["Root"])
TrackRoots:SetScript("OnClick", function(self)
	LoseControlDB.tracking.Root = self:GetChecked()
end)

local TrackSnares = CreateFrame("CheckButton", O.."TrackSnares", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackSnaresText"]:SetText(LOSECONTROL["Snare"])
TrackSnares:SetScript("OnClick", function(self)
	LoseControlDB.tracking.Snare = self:GetChecked()
end)

local TrackImmune = CreateFrame("CheckButton", O.."TrackImmune", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackImmuneText"]:SetText(LOSECONTROL["Immune"])
TrackImmune:SetScript("OnClick", function(self)
	LoseControlDB.tracking.Immune = self:GetChecked()
end)

local TrackPvE = CreateFrame("CheckButton", O.."TrackPvE", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TrackPvEText"]:SetText(LOSECONTROL["PvE"])
TrackPvE:SetScript("OnClick", function(self)
	LoseControlDB.tracking.PvE = self:GetChecked()
end)

-------------------------------------------------------------------------------
-- DropDownMenu helper function
local info = UIDropDownMenu_CreateInfo()
local function AddItem(owner, text, value)
	info.owner = owner
	info.func = owner.OnClick
	info.text = text
	info.value = value
	info.checked = nil -- initially set the menu item to being unchecked
	UIDropDownMenu_AddButton(info)
end

local UnitDropDownLabel = OptionsPanel:CreateFontString(O.."UnitDropDownLabel", "ARTWORK", "GameFontNormal")
UnitDropDownLabel:SetText(LOSECONTROL["Unit Configuration"])
UnitDropDown = CreateFrame("Frame", O.."UnitDropDown", OptionsPanel, "UIDropDownMenuTemplate")
function UnitDropDown:OnClick()
	UIDropDownMenu_SetSelectedValue(UnitDropDown, self.value)
	OptionsPanel.refresh() -- easy way to update all the other controls
end
UIDropDownMenu_Initialize(UnitDropDown, function() -- sets the initialize function and calls it
	for _, v in ipairs({ "player", "target", "focus", "party1", "party2", "party3", "party4", "arena1", "arena2", "arena3", "arena4", "arena5" }) do -- indexed manually so they appear in order
		AddItem(UnitDropDown, LOSECONTROL[v], v)
	end
end)
UIDropDownMenu_SetSelectedValue(UnitDropDown, "player") -- set the initial drop down choice

local AnchorDropDownLabel = OptionsPanel:CreateFontString(O.."AnchorDropDownLabel", "ARTWORK", "GameFontNormal")
AnchorDropDownLabel:SetText(LOSECONTROL["Anchor"])
AnchorDropDown = CreateFrame("Frame", O.."AnchorDropDown", OptionsPanel, "UIDropDownMenuTemplate")
function AnchorDropDown:OnClick()
	local unit = UIDropDownMenu_GetSelectedValue(UnitDropDown)
	local frame = LoseControlDB.frames[unit]
	local icon = LC[unit]

	UIDropDownMenu_SetSelectedValue(AnchorDropDown, self.value)
	frame.anchor = self.value
	if self.value ~= "None" then -- reset the frame position so it centers on the anchor frame
		frame.point = nil
		frame.relativePoint = nil
		frame.x = nil
		frame.y = nil
	end

	icon.anchor = GetAnchorFrame(frame.anchor, unit) or UIParent

	if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
		icon:SetParent(icon.anchor:GetParent())
	end

	icon:ClearAllPoints() -- if we don't do this then the frame won't always move
	icon:SetPoint(
		frame.point or "CENTER",
		icon.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
end
function AnchorDropDown:initialize() -- called from OptionsPanel.refresh() and every time the drop down menu is opened
	local unit = UIDropDownMenu_GetSelectedValue(UnitDropDown)
	AddItem(self, LOSECONTROL["None"], "None")
	-- List every anchor profile that defines a mapping for the selected unit.
	-- (Based on the profile definition, not live frame existence, so arena
	-- addons like Gladius/sArena stay selectable even outside an arena.)
	for _, name in ipairs(anchorOrder) do
		local profile = anchors[name]
		if type(profile) == "table" and profile[unit] ~= nil then
			AddItem(self, name, name)
		end
	end
end

local StrataDropDownLabel = OptionsPanel:CreateFontString(O.."StrataDropDownLabel", "ARTWORK", "GameFontNormal")
StrataDropDownLabel:SetText(LOSECONTROL["Strata"])
local StrataDropDown = CreateFrame("Frame", O.."StrataDropDown", OptionsPanel, "UIDropDownMenuTemplate")
function StrataDropDown:OnClick()
	local unit = UIDropDownMenu_GetSelectedValue(UnitDropDown)
	UIDropDownMenu_SetSelectedValue(StrataDropDown, self.value)
	LoseControlDB.frames[unit].strata = self.value
	LC[unit]:SetFrameStrata(self.value)
end
function StrataDropDown:initialize() -- called from OptionsPanel.refresh() and every time the drop down menu is opened
	for _, v in ipairs({ "HIGH", "MEDIUM", "LOW", "BACKGROUND" }) do -- indexed manually so they appear in order
		AddItem(self, v, v)
	end
end

-------------------------------------------------------------------------------
-- Slider helper function, thanks to Kollektiv
local function CreateSlider(text, parent, low, high, step)
	local name = parent:GetName() .. text
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetWidth(160)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText(low)
	_G[name .. "High"]:SetText(high)
	return slider
end

local SizeSlider = CreateSlider(LOSECONTROL["Icon Size"], OptionsPanel, 16, 512, 4)
SizeSlider:SetScript("OnValueChanged", function(self, value)
	local unit = UIDropDownMenu_GetSelectedValue(UnitDropDown)
	_G[self:GetName() .. "Text"]:SetText(LOSECONTROL["Icon Size"] .. " (" .. value .. "px)")
	LoseControlDB.frames[unit].size = value
	LC[unit]:SetWidth(value)
	LC[unit]:SetHeight(value)
end)

local AlphaSlider = CreateSlider(LOSECONTROL["Opacity"], OptionsPanel, 0, 100, 5) -- I was going to use a range of 0 to 1 but Blizzard's slider chokes on decimal values
AlphaSlider:SetScript("OnValueChanged", function(self, value)
	local unit = UIDropDownMenu_GetSelectedValue(UnitDropDown)
	_G[self:GetName() .. "Text"]:SetText(LOSECONTROL["Opacity"] .. " (" .. value .. "%)")
	LoseControlDB.frames[unit].alpha = value / 100 -- the real alpha value
	LC[unit]:SetAlpha(value / 100)
end)

-------------------------------------------------------------------------------
-- Defined last because it references earlier declared variables
local Enabled = CreateFrame("CheckButton", O.."Enabled", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."EnabledText"]:SetText(LOSECONTROL["Enabled"])
function Enabled:OnClick()
	local enabled = self:GetChecked()
	LoseControlDB.frames[UIDropDownMenu_GetSelectedValue(UnitDropDown)].enabled = enabled
	if enabled then
		UIDropDownMenu_EnableDropDown(AnchorDropDown)
		UIDropDownMenu_EnableDropDown(StrataDropDown)
		BlizzardOptionsPanel_Slider_Enable(SizeSlider)
		BlizzardOptionsPanel_Slider_Enable(AlphaSlider)
	else
		UIDropDownMenu_DisableDropDown(AnchorDropDown)
		UIDropDownMenu_DisableDropDown(StrataDropDown)
		BlizzardOptionsPanel_Slider_Disable(SizeSlider)
		BlizzardOptionsPanel_Slider_Disable(AlphaSlider)
	end
end
Enabled:SetScript("OnClick", Enabled.OnClick)

-------------------------------------------------------------------------------
-- Arrange all the options neatly
title:SetPoint("TOPLEFT", 16, -16)
subText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

Unlock:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 0, -16)
DisableCooldownCount:SetPoint("TOPLEFT", Unlock, "BOTTOMLEFT", 0, -2)

Tracking:SetPoint("TOPLEFT", DisableCooldownCount, "BOTTOMLEFT", 0, -12)
TrackCCs:SetPoint("TOPLEFT", Tracking, "BOTTOMLEFT", 0, -4)
TrackSilences:SetPoint("TOPLEFT", TrackCCs, "TOPRIGHT", 100, 0)
TrackDisarms:SetPoint("TOPLEFT", TrackSilences, "TOPRIGHT", 100, 0)
TrackRoots:SetPoint("TOPLEFT", TrackCCs, "BOTTOMLEFT", 0, -2)
TrackSnares:SetPoint("TOPLEFT", TrackSilences, "BOTTOMLEFT", 0, -2)
TrackImmune:SetPoint("TOPLEFT", TrackDisarms, "BOTTOMLEFT", 0, -2)
TrackPvE:SetPoint("TOPLEFT", TrackRoots, "BOTTOMLEFT", 0, -2)

UnitDropDownLabel:SetPoint("TOPLEFT", TrackPvE, "BOTTOMLEFT", 0, -12)
UnitDropDown:SetPoint("TOPLEFT", UnitDropDownLabel, "BOTTOMLEFT", 0, -8)	Enabled:SetPoint("TOPLEFT", UnitDropDownLabel, "BOTTOMLEFT", 200, -8)

AnchorDropDownLabel:SetPoint("TOPLEFT", UnitDropDown, "BOTTOMLEFT", 0, -12)	--StrataDropDownLabel:SetPoint("TOPLEFT", UnitDropDown, "BOTTOMLEFT", 200, -12)
AnchorDropDown:SetPoint("TOPLEFT", AnchorDropDownLabel, "BOTTOMLEFT", 0, -8)	--StrataDropDown:SetPoint("TOPLEFT", StrataDropDownLabel, "BOTTOMLEFT", 0, -8)

SizeSlider:SetPoint("TOPLEFT", AnchorDropDown, "BOTTOMLEFT", 0, -24)		AlphaSlider:SetPoint("TOPLEFT", AnchorDropDown, "BOTTOMLEFT", 200, -24)

-------------------------------------------------------------------------------
OptionsPanel.default = function() -- This method will run when the player clicks "defaults".
	_G.LoseControlDB = nil
	LoseControl:ADDON_LOADED(L)
	for _, v in pairs(LC) do
		v:PLAYER_ENTERING_WORLD()
	end
end

OptionsPanel.refresh = function() -- This method will run when the Interface Options frame calls its OnShow function and after defaults have been applied via the panel.default method described above, and after the Unit Configuration dropdown is changed.
	local tracking = LoseControlDB.tracking
	local unit = UIDropDownMenu_GetSelectedValue(UnitDropDown)
	local frame = LoseControlDB.frames[unit]
	DisableCooldownCount:SetChecked(LoseControlDB.noCooldownCount)
	TrackCCs:SetChecked(tracking.CC)
	TrackSilences:SetChecked(tracking.Silence)
	TrackDisarms:SetChecked(tracking.Disarm)
	TrackRoots:SetChecked(tracking.Root)
	TrackSnares:SetChecked(tracking.Snare)
	TrackImmune:SetChecked(tracking.Immune)
	TrackPvE:SetChecked(tracking.PvE)
	Enabled:SetChecked(frame.enabled)
	Enabled:OnClick()
	AnchorDropDown:initialize()
	UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
	StrataDropDown:initialize()
	UIDropDownMenu_SetSelectedValue(StrataDropDown, frame.strata or "LOW")
	SizeSlider:SetValue(frame.size)
	AlphaSlider:SetValue(frame.alpha * 100)
end

InterfaceOptions_AddCategory(OptionsPanel)

-------------------------------------------------------------------------------
SLASH_LoseControlCoA1 = "/lc"
SLASH_LoseControlCoA2 = "/losecontrol"
SlashCmdList[L] = function(cmd)
	cmd = cmd:lower()
	if cmd == "reset" then
		OptionsPanel.default()
		OptionsPanel.refresh()
	elseif cmd == "lock" then
		Unlock:SetChecked(false)
		Unlock:OnClick()
		log(L .. " locked.")
	elseif cmd == "unlock" then
		Unlock:SetChecked(true)
		Unlock:OnClick()
		log(L .. " unlocked.")
	elseif cmd:sub(1, 6) == "enable" then
		local unit = cmd:sub(8, 14)
		if LoseControlDB.frames[unit] then
			LoseControlDB.frames[unit].enabled = true
			log(L .. ": " .. unit .. " frame enabled.")
		end
	elseif cmd:sub(1, 7) == "disable" then
		local unit = cmd:sub(9, 15)
		if LoseControlDB.frames[unit] then
			LoseControlDB.frames[unit].enabled = false
			log(L .. ": " .. unit .. " frame disabled.")
		end
	elseif cmd:sub(1, 4) == "help" then
		log(L .. " slash commands:")
		log("    reset")
		log("    lock")
		log("    unlock")
		log("    enable <unit>")
		log("    disable <unit>")
		log("<unit> can be: player, target, focus, party1 ... party4, arena1 ... arena5")
	else
		log(L .. ": Type \"/lc help\" for more options.")
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
	end
end
