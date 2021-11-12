SKILL_ISSUE_MOD = RegisterMod("Skill Issue", 1)
SKILL_ISSUE_MOD.SFX = SFXManager()
SKILL_ISSUE_MOD.WHISPER_SOUND = Isaac.GetSoundIdByName('LOSER_WHISPER')
SKILL_ISSUE_MOD.RNG = RNG()
SKILL_ISSUE_MOD.FONT = Font()

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
}

--Will determine if the Skill Issue text needs to display on screen
function SKILL_ISSUE_MOD:OnDamage(entity, damageAmt, damageFlags, damageSource)
	if (entity.Type == 1 --Checks if entity taking damage is the player
	and damageSource.Type ~= 0 and damageSource.Type ~= 6 --Ignore damage from null sources or slot machines (blood bank, etc.)
	and SKILL_ISSUE_MOD.RNG:RandomInt(100) < 5) then --5% chance
		SKILL_ISSUE_MOD:ShowBanner()
	end
end

--Plays the sound calling Jerry a loser
function SKILL_ISSUE_MOD:PlaySound(isGameOver)
	if isGameOver == true then -- isGameOver flag is true when player dies
		SKILL_ISSUE_MOD.SFX:Play(SKILL_ISSUE_MOD.WHISPER_SOUND, 6)
	end
end

--Shows text at the top of the screen using item text
--Displays "Skill Issue" and then a random subtext
function SKILL_ISSUE_MOD:ShowBanner()
	local nextSubText = SKILL_ISSUE_MOD.RNG:RandomInt(#SKILL_ISSUE_MOD.SUB_TEXT) + 1
	Game():GetHUD():ShowItemText("Skill Issue", SKILL_ISSUE_MOD.SUB_TEXT[nextSubText])
end

SKILL_ISSUE_MOD.FONT:Load("font/teammeatfont12.fnt")
SKILL_ISSUE_MOD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SKILL_ISSUE_MOD.OnDamage);
SKILL_ISSUE_MOD:AddCallback(ModCallbacks.MC_POST_GAME_END, SKILL_ISSUE_MOD.PlaySound);