function ManaManager(Mode, Spell)
	local String = "Param."..""..Mode..".Mana"..Spell..""
	if myHero.mana < (myHero.maxMana * (self:Mv(String) / 100)) then
		return true
	else
		return false
	end
end

-- Exemple


-- Param.Harass:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 80, 0, 100);
-- if not ManaManager("Harass", "E") then.... end
