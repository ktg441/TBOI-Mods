GTA_CJ_SFX_MOD = RegisterMod("GTA San Andreas: Here We Go Again", 1)
GTA_CJ_SFX_MOD.SFX = SFXManager()
GTA_CJ_SFX_MOD.CJ_SOUND = Isaac.GetSoundIdByName('CJ_GTA_HERE_WE_GO_AGAIN_SOUND')

function GTA_CJ_SFX_MOD:playSound()
	GTA_CJ_SFX_MOD.SFX:Play(GTA_CJ_SFX_MOD.CJ_SOUND, 4)
end

GTA_CJ_SFX_MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, GTA_CJ_SFX_MOD.playSound);