class 'Smiterino';

local max = math.max

function Smiterino:__init()
	jungle = minionManager(MINION_JUNGLE, 600, myHero, MINION_SORT_DIST_ASC);
	self.ToS = {
		['SRU_RiftHerald17.1.1'] = {true}, -- Blue | Haut
		['SRU_Baron12.1.1'] = {true}, -- Blue | Haut
	}
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerSmite") then 
		self.SmiteSlot = SUMMONER_1 
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerSmite") then 
		self.SmiteSlot = SUMMONER_2 
	end
	if self.SmiteSlot == nil then return end
	PrintChat("<b><font color=\"#26A65B\">></font></b> <font color=\"#FEFEE2\"> BaguetteSmite loaded..</font>");
	AddTickCallback(function()
		self:CastSmite();
	end);
end

function Smiterino:CastSmite()
	if myHero:CanUseSpell(self.SmiteSlot) == READY then
		jungle:update();
		for i, unit in pairs(jungle.objects) do
			if unit ~= nil and ValidTarget(unit) then
				if unit.health <= self:SmiteDmg() then
					if self.ToS[unit.name] or unit.charName:lower():find("dragon") then
						CastSpell(self.SmiteSlot, unit);
					end
				end
			end
		end
	end
end

function Smiterino:SmiteDmg()
	return max(20 * myHero.level + 370, 30 * myHero.level + 330, 40 * myHero.level + 240, 50 * myHero.level + 100)
end

AddLoadCallback(function()
	Smiterino();
end)
