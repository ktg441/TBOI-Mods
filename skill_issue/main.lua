-----------------------------------
--Global Variables/Helper Classes--
-----------------------------------
local modName = "Skill Issue"
local json = require("json")

SKILL_ISSUE_MOD = RegisterMod(modName, 1)
SKILL_ISSUE_MOD.SFX = SFXManager()
SKILL_ISSUE_MOD.WHISPER_SOUND = Isaac.GetSoundIdByName('LOSER_WHISPER')
SKILL_ISSUE_MOD.RNG = RNG()
SKILL_ISSUE_MOD.FONT = Font()
SKILL_ISSUE_MOD.LOADED = false

----------------------------------

----------------------
--Settings & Configs--
----------------------

-- Memory for encoding in JSON
SKILL_ISSUE_MOD.SAVE_STATE = {}

-- Default % chances for various EntityTypes in the game
SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS = {
	["Player"] = 0,
	["Tears"] = 5,
	["Familiars"] = 5,
	["Bomb Drops"] = 5,
	["Pickups"] = 5,
	["Slot Machines"] = 0,
	["Lasers"] = 5,
	["Blood Projectiles"] = 5,
	["Enemies"] = 5,
}

-- Sound settings
SKILL_ISSUE_MOD.SOUND_SETTINGS = {
	["LoserSound"] = true, -- Enable or disable the loser sound on death
}

--Various text that shows up as sub text to 'Skill Issue'
SKILL_ISSUE_MOD.SUB_TEXT = {
	"Have you tried getting good?",
	"Are you become back your money?",
	"Edmund guaranteed all damage in this game is fair",
	"Uninstall",
	"Just dodge",
	"You have how many hours in this game?",
	"Garbage",
	"Boo, you suck!",
	"Gentlemen, it is with great pleasure to inform you that you suck",
	"It's just sad at this point",
	"Bruh",
	"I'm not mad, I'm just disappointed",
	"That was productive damage...right?",
	"You might still be able to get a refund",
	"Just hold R bro",
	"A sloth has better reflexes than you",
	"Dang, that was super avoidable",
	"You should really feel ashamed",
	"I could do better with a blindfold on",
	"Mad?",
	"That was hilarious",
}

---------------------

----------------------
--Core Functionality--
----------------------

--Will determine if the Skill Issue text needs to display on screen
function SKILL_ISSUE_MOD:OnDamage(entity, damageAmt, damageFlags, damageSource)
	if entity.Type == 1 then --Checks if entity taking damage is the player
		local entityTypeMapKey = SKILL_ISSUE_MOD:ConvertEntityTypeToHumanReadableKey(damageSource.Type) -- Check if the Entity doing damage is one that we care about
		
		if entityTypeMapKey ~= "" -- Empty string means we don't check for damage from that entity
		and SKILL_ISSUE_MOD.RNG:RandomInt(100) < SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS[entityTypeMapKey] then -- Check settings map for the percentage chance. If user has mod config menu, they can change this
			SKILL_ISSUE_MOD:ShowBanner()
		end
	end
end

--Plays the sound calling Jerry a loser
function SKILL_ISSUE_MOD:PlaySound(isGameOver)
	if isGameOver == true and SKILL_ISSUE_MOD.SOUND_SETTINGS["LoserSound"] == true then -- isGameOver flag is true when player dies
		SKILL_ISSUE_MOD.SFX:Play(SKILL_ISSUE_MOD.WHISPER_SOUND, 6)
	end
end

--Shows text at the top of the screen using item text
function SKILL_ISSUE_MOD:ShowBanner()
	local nextSubText = SKILL_ISSUE_MOD.RNG:RandomInt(#SKILL_ISSUE_MOD.SUB_TEXT) + 1 -- I hate that lua starts arrays at index 1
	Game():GetHUD():ShowItemText("Skill Issue", SKILL_ISSUE_MOD.SUB_TEXT[nextSubText]) --Displays "Skill Issue" and then a random subtext
end

----------------------

-----------------------------------------
--Mod Config Menu functions & save data--
-----------------------------------------

--Sets up Mod Config menu options if mod is installed
function SKILL_ISSUE_MOD:ModConfigInit()
	if not SKILL_ISSUE_MOD.LOADED == true then -- This function calls on update so we need a flag to make sure this only happens once
		if ModConfigMenu then
			ModConfigMenu.RemoveCategory(modName) -- Recompiles list, prevents extra weirdness if loading mod via console
			ModConfigMenu.UpdateCategory(modName, {
				Info = {"Skill Issue settings.",}
			})
			
			local infoSettingsSection = "Info"
			local percentSettingsSection = "Percentages"
			local soundSettingsSection = "Sounds"
			
			-- These are the sections that appear at the top
			ModConfigMenu.AddSpace(modName, infoSettingsSection)
			ModConfigMenu.AddSpace(modName, percentSettingsSection)
			ModConfigMenu.AddSpace(modName, soundSettingsSection)
			
			ModConfigMenu.AddText(modName, infoSettingsSection, function() return "Author: stubby441" end) -- Hey that's me :)
			ModConfigMenu.AddText(modName, infoSettingsSection, function() return "Version 1.1" end)
			ModConfigMenu.AddText(modName, infoSettingsSection, function() return "Special Thanks: pasta, r/bindingofisaac" end)
			
			ModConfigMenu.AddSetting(modName, soundSettingsSection, 
				{
					Type = ModConfigMenu.OptionType.BOOLEAN,
					CurrentSetting = function()
						return SKILL_ISSUE_MOD.SOUND_SETTINGS["LoserSound"]
					end,
					Display = function()
						local val = "False"
						if SKILL_ISSUE_MOD.SOUND_SETTINGS["LoserSound"] then
							val = "True"
						end
						return 'Play \'Loser\' sound on death: ' .. val
					end,
					OnChange = function(newVal)
						SKILL_ISSUE_MOD.SOUND_SETTINGS["LoserSound"] = newVal
					end,
					Info = {"You will hear a whisper in your ear when you die"},
				}
			)
			
			--Because pairs doesn't run through arrays in order, need to create a sorted list
			local orderedPercentageSettings = {}
			
			--Add our settings to an index-based array
			for key, val in pairs(SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS) do
				table.insert(orderedPercentageSettings, {key = key, value = val})
			end
			table.sort(orderedPercentageSettings, function(o1, o2) return o1.key < o2.key end) -- Sort based on alphabet
			
			-- Because we're epic programmers, just loop through all our sorted keys for the various percentages settings
			for _, percentSettingPair in ipairs(orderedPercentageSettings) do -- Throw out key, value will contain key/value pair with our setting name/saved value
				ModConfigMenu.AddSetting(modName, percentSettingsSection,
					{
						Type = ModConfigMenu.OptionType.NUMBER,
						CurrentSetting = function ()
							return SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS[tostring(percentSettingPair.key)]
						end,
						Minimum = 0,
						Maximum = 100,
						Display = function()
							return tostring(percentSettingPair.key) .. " % : " .. SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS[tostring(percentSettingPair.key)]
						end,
						OnChange = function(newVal)
							SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS[tostring(percentSettingPair.key)] = newVal
						end,
						Info = {"Chance that the Skill Issue text will show up when hit by an item in the " .. tostring(percentSettingPair.key) .. " category."},
					}
				)
			end
		end
	
		SKILL_ISSUE_MOD.LOADED = true
	end
end

--Saves all option data in JSON format
function SKILL_ISSUE_MOD:SaveGame()
	SKILL_ISSUE_MOD.SAVE_STATE.ChanceSettings = {}
	SKILL_ISSUE_MOD.SAVE_STATE.SoundSettings = {}
	
	for key, _ in pairs(SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS) do
		SKILL_ISSUE_MOD.SAVE_STATE.ChanceSettings[tostring(key)] = SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS[key]
	end
	for key, _ in pairs(SKILL_ISSUE_MOD.SOUND_SETTINGS) do
		SKILL_ISSUE_MOD.SAVE_STATE.SoundSettings[tostring(key)] = SKILL_ISSUE_MOD.SOUND_SETTINGS[key]
	end
    SKILL_ISSUE_MOD:SaveData(json.encode(SKILL_ISSUE_MOD.SAVE_STATE))
end

--Loads all option data from JSON format
function SKILL_ISSUE_MOD:OnGameStart(isSave)	
    if SKILL_ISSUE_MOD:HasData() then	
		SKILL_ISSUE_MOD.SAVE_STATE = json.decode(SKILL_ISSUE_MOD:LoadData())	
		
		for key, _ in pairs(SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS) do
			SKILL_ISSUE_MOD.PERCENTAGE_INFO_SETTINGS[tostring(key)] = SKILL_ISSUE_MOD.SAVE_STATE.ChanceSettings[key]
		end
		for key, _ in pairs(SKILL_ISSUE_MOD.SOUND_SETTINGS) do
			SKILL_ISSUE_MOD.SOUND_SETTINGS[tostring(key)] = SKILL_ISSUE_MOD.SAVE_STATE.SoundSettings[key]
		end
    end
end

-----------------------------------------

--------------------
--Helper Functions--
--------------------

--Some of the entity types in the lua docs are not human readable, so create a map of text that makes sense to humans based on the entity type passed in
function SKILL_ISSUE_MOD:ConvertEntityTypeToHumanReadableKey(entityType)
	local key = ""
	
	-- Some numbers are skipped because I don't want to track damage against them/not sure what the category even is
	if entityType == 1 then
		key = "Player"
	elseif entityType == 2 then
		key = "Tears"
	elseif entityType == 3 then
		key = "Familiars"
	elseif entityType == 4 then
		key = "Bomb Drops"
	elseif entityType == 5 then
		key = "Pickups"
	elseif entityType == 6 then
		key = "Slot Machines"
	elseif entityType == 7 then
		key = "Lasers"
	elseif entityType == 9 then
		key = "Blood Projectiles"
	elseif entityType >= 10 and entityType <= 970 then -- 970 is latest known enemy entity type as of update 1.7.5
		key = "Enemies"
	end
		
	return key
end

--------------------

--------------
--Main Setup--
--------------

SKILL_ISSUE_MOD.FONT:Load("font/teammeatfont12.fnt")
SKILL_ISSUE_MOD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SKILL_ISSUE_MOD.SaveGame)
SKILL_ISSUE_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SKILL_ISSUE_MOD.OnGameStart)
SKILL_ISSUE_MOD:AddCallback(ModCallbacks.MC_POST_UPDATE,SKILL_ISSUE_MOD.ModConfigInit)
SKILL_ISSUE_MOD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SKILL_ISSUE_MOD.OnDamage);
SKILL_ISSUE_MOD:AddCallback(ModCallbacks.MC_POST_GAME_END, SKILL_ISSUE_MOD.PlaySound);

--------------