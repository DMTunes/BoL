if myHero.charName ~= "Ryze" then return end

local Mode = nil;

function OnLoad()

	Ryze();
end

class 'Ryze';

function Ryze:__init()
	self:Lib();
	self:Update();
	self:Alerte("[Beta] Korean Top Ryze- by spyk, loading.");
end

function Ryze:Alerte(msg)

	PrintChat("<b><font color=\"#2c3e50\">></font></b> </font><font color=\"#c5eff7\"> " .. msg .. "</font>");
end

function Ryze:AutoLVLCombo()
	if Param.Misc.LVL.Combo == 1 then
		levelSequence = {3,1,2,1,1,4,1,3,1,3,4,3,1,3,2,2,2,2}; -- EQW (max QE)
	elseif Param.Misc.LVL.Combo == 2 then
		levelSequence = {3,2,1,1,1,4,1,3,1,3,4,3,1,3,2,2,2,2}; -- EWQ (max QE)
	else
		levelSequence = nil;
	end
end

function Ryze:AutoLVLSpell()
	if VIP_USER and os.clock() - self.Last_LevelSpell > .5 then
		if Param.Misc.LVL.Enable then
			autoLevelSetSequence(levelSequence);
			self.Last_LevelSpell = os.clock();
		else
			autoLevelSetSequence(nil);
			self.Last_LevelSpell = os.clock()+10;
		end
	end
end

function Ryze:AutoPotions()
	if Param.Misc.Pots.Enable then
		if os.clock() - self.lastPotion > self.ActualPotTime then
			for SLOT = ITEM_1, ITEM_6 do
				if myHero:GetSpellData(SLOT).name == "RegenerationPotion" then
					self.ActualPotName = "Health Potion";
					self.ActualPotTime = 15;
					self.ActualPotData = "RegenerationPotion";
					self:Usepot();
				elseif myHero:GetSpellData(SLOT).name == "ItemMiniRegenPotion" then
					self.ActualPotName = "Cookie";
					self.ActualPotTime = 15;
					self.ActualPotData = "ItemMiniRegenPotion";
					self:Usepot();
				elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlaskJungle" then
					self.ActualPotName = "Hunter's Potion";
					self.ActualPotTime = 8;
					self.ActualPotData = "ItemCrystalFlaskJungle";
					self:Usepot();
				elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlask" then
					self.ActualPotName = "Refillable Potion";
					self.ActualPotTime = 12;
					self.ActualPotData = "ItemCrystalFlask";
					self:Usepot();
				elseif myHero:GetSpellData(SLOT).name == "ItemDarkCrystalFlask" then
					self.ActualPotName = "Corrupting Potion";
					self.ActualPotTime = 12;
					self.ActualPotData = "ItemDarkCrystalFlask";
					self:Usepot();
				end
			end
		end
	end
end

function Ryze:Usepot()
	if Param.Misc.Pots.Combo and Mode == "Combo" or not Param.Misc.Pots.Combo then
		for SLOT = ITEM_1, ITEM_6 do
			if myHero:GetSpellData(SLOT).name == self.ActualPotData and not InFountain() then
				if myHero:CanUseSpell(SLOT) == READY and (myHero.health*100)/myHero.maxHealth < Param.Misc.Pots.HP and not InFountain() then
					CastSpell(SLOT);
					self.lastPotion = os.clock();
					self:Alerte("1x "..self.ActualPotName.." => Used.");
				end
			end
		end
	end
end

function Ryze:AutoBuy()
	if Param.Misc.Buy.Enable then
		if VIP_USER and GetGameTimer() < 200 then
			DelayAction(function()
				if Param.Misc.Buy.Trinket then
					BuyItem(3340);
				end
				DelayAction(function()
					if Param.Misc.Buy.Cristal then 
						BuyItem(1027);
					end
				end, 1);
				DelayAction(function()
					for i = 1, 3 do
						if Param.Misc.Buy.Pots then
							BuyItem(2003);
						end
					end
				end, 2);
			end, 2);
		end
	end
end

function Ryze:Bleu(unit, buff)
	if unit and unit.isMe and buff.name == "recall" then    
		if Param.Misc.Buy.Enable and InFountain() then
			if Param.Misc.Buy.BlueTrinket then
				BuyItem(3363);
			end
		end
	end
end

function Ryze:EIR(t, r)
    local z = t or myHero;
    local x = r or 2500;
    local n = 0;
    for _, unit in pairs(GetEnemyHeroes()) do
        if ValidTarget(unit) and not unit.dead and unit.visible and GetDistanceSqr(z, unit) < x*x then
            n = n + 1;
        end
    end
    return n
end

function Ryze:EnemyInRange(t, r)
    if self:EIR(t, r) > 0 then
        return true
    else
        return false
    end
end

function Ryze:Bonus(u, x)
	local u = u or myHero;
	local t = x or myHero;
	return t.boundingRadius + u.boundingRadius
end

function Ryze:CastQ(t, y)
	if GetDistance(t) < 950 then
		if y ~= "Combo" and y ~= nil then
			if not self:Mana(y, "Q") then
				return
			end
		end
		if Param.Pred == 1 then
			local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, .25, 50, 1000, 1700, myHero, false);
			if HitChance > 1 then
				CastSpell(_Q, CastPosition.x, CastPosition.z);
			end
		elseif Param.Pred == 2 then
			local Position, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayLine", delay = .25, range = 1000, speed = 1700, collisionH = false, collisionM = true, width = 100}), unit, myHero);
			if HitChance > 0 then
				CastSpell(_Q, Position.x, Position.z);
			end
		elseif Param.Pred == 3 then
			local pos, hc, info = FHPrediction.GetPrediction({range = 1000, speed = 1700, delay = .25, radius = 50, collison = true}, unit);
			if hc > 0 then
				CastSpell(_Q, pos.x, pos.z);
			end
		end
	end
end

function Ryze:CastQ2(unit)
	if unit ~= nil then
		if Param.Pred == 1 then
			local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, .25, 55, 1000, 1700, myHero, false);
			if HitChance > 1 then
				CastSpell(_Q, CastPosition.x, CastPosition.z);
			end
		elseif Param.Pred == 2 then
			local Position, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayLine", delay = .25, range = 1000, speed = 1700, collisionH = false, collisionM = true, width = 110}), unit, myHero);
			if HitChance > 0 then
				CastSpell(_Q, Position.x, Position.z);
			end
		elseif Param.Pred == 3 then
			local pos, hc, info = FHPrediction.GetPrediction({range = 1000, speed = 1700, delay = .25, radius = 55, collison = true}, unit);
			if hc > 0 then
				CastSpell(_Q, pos.x, pos.z);
			end
		end
	end
end

function Ryze:CastW(t, y)
	if GetDistance(t) < 615 then
		if y ~= "Combo" and y ~= nil then
			if not self:Mana(y, "W") then
				return
			end
		end
		CastSpell(_W, t);
	end
end

function Ryze:CastW2(unit)
	CastSpell(_W, unit);
end

function Ryze:CastE(t, y)
	if GetDistance(t) < 615 then
		if y ~= "Combo" and y ~= nil then
			if not self:Mana(y, "E") then
				return
			end
		end
		CastSpell(_E, t);
	end
end

function Ryze:CastE2(unit)
	CastSpell(_E, unit);
end

function Ryze:CustomLoad()
	self:Menu();
	self:Loader();
	self:AutoBuy();
	self.Q = false;
	self.W = false;
	self.E = false;
	self.Target = nil;
	self.Last_LevelSpell = 0;
	self.CurrentMode = "";
	self.lastPotion = 0;
	self.ActualPotTime = 15;
	self.ActualPotName = "None";
	self.ActualPotData = "None";
	self.Skills = {
		Q = {range = 1000, delay = .25, radius = 55, speed = 1700},
		W = {range = 615, delay = .25},
		E = {range = 615, delay = .25},
		R = {range = 1500, range2 = 3000},
	};
	AddUnloadCallback(function()
		self:Unload();
	end);
	AddTickCallback(function()
		self:Mode();
		self.Target = self:GetTarget();
		self:Modes();
		self:AutoPotions();
		if VIP_USER then
			self:AutoLVLSpell();
		end
	end);
	AddDrawCallback(function()
		self:OnDraw();
	end);
end

function Ryze:Checks()
	if myHero:CanUseSpell(_Q) == READY then
		self.Q = true;
	else
		self.Q = false;
	end
	if myHero:CanUseSpell(_W) == READY then
		self.W = true;
	else
		self.W = false;
	end
	if myHero:CanUseSpell(_E) == READY then
		self.E = true;
	else
		self.E = false;
	end
end

function Ryze:Combo()
	if self.Target ~= nil then
		local Dist = GetDistanceSqr(self.Target);
		local Bonus = self:Bonus(self.Target);
		Bonus = Bonus * Bonus;
		if self.Q and Param.Combo.Q and Dist < 810000 then
			self:CastQ2(self.Target);
		elseif self.E and Param.Combo.E and Dist < 378225 + Bonus then
			if self.W and Param.Combo.W and Dist > 250000 + Bonus then
				self:CastW2(self.Target);
				DelayAction(function()
					self:CastQ2(self.Target);
				end, .25 + GetLatency() / 1000);
			else
				self:CastE2(self.Target);
				DelayAction(function()
					self:CastQ2(self.Target);
				end, .25 + GetLatency() / 1000);
			end
		elseif self.W and Param.Combo.W and Dist < 378225 + Bonus then
			self:CastW2(self.Target);
			DelayAction(function()
				self:CastQ2(self.Target);
			end, .25 + GetLatency() / 1000);
		end
	end
end

function Ryze:Harass()
	if self.Target ~= nil then
		local Dist = GetDistanceSqr(self.Target);
		local Bonus = self:Bonus(self.Target);
		Bonus = Bonus * Bonus;
		if self.Q and Param.Harass.Q and Dist < 810000 then
			self:CastQ(self.Target, "Harass");
		elseif self.E and Param.Harass.E and Dist < 378225 + Bonus then
			self:CastE(self.Target, "Harass");
		elseif self.W and Param.Harass.W and Dist < 378225 + Bonus then
			self:CastW(self.Target, "Harass");
		end
	end
end

function Ryze:WaveClear()
	enemyMinions:update()
	for i, unit in pairs(enemyMinions.objects) do
		if unit.type == "obj_AI_Minion" then
			if not self:EnemyInRange(myHero, 2500) then
				if self.E and Param.WaveClear.E then
					self:CastE(unit, "WaveClear");
				elseif self.Q and Param.WaveClear.Q then
					self:CastQ(unit, "WaveClear");
				elseif self.W and Param.WaveClear.W then
					self:CastW(unit, "WaveClear");
				end
			else
				if self.E and Param.WaveClear2.E then
					self:CastE(unit, "WaveClear2");
				elseif self.Q and Param.WaveClear2.Q then
					self:CastQ(unit, "WaveClear2");
				elseif self.W and Param.WaveClear2.W then
					self:CastW(unit, "WaveClear2");
				end
			end
		end
	end
end

function Ryze:JungleClear()
    jungleMinions:update()
    for i, unit in pairs(jungleMinions.objects) do
        if unit.type == "obj_AI_Minion" then
            if self.Q and Param.JungleClear.Q then
                self:CastQ(unit, "JungleClear");
            elseif self.E and Param.JungleClear.E then
                self:CastE(unit, "JungleClear");
            elseif self.W and Param.JungleClear.W  then
                self:CastW(unit, "JungleClear");
            end
        end
    end
end

function Ryze:Menu()
	Param = scriptConfig("[KoreanTop] - Ryze", "KoreanTopRyze");

	Param:addSubMenu("Combo Setttings", "Combo");
		Param.Combo:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, true);
		Param.Combo:addParam("W", "Use W :", SCRIPT_PARAM_ONOFF, true);
		Param.Combo:addParam("E", "Use E :", SCRIPT_PARAM_ONOFF, true);

	Param:addSubMenu("Harass Setttings", "Harass");

		Param.Harass:addParam("Q", "Use Q :" , SCRIPT_PARAM_ONOFF, true);
		Param.Harass:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
		Param.Harass:addParam("W", "Use W :" , SCRIPT_PARAM_ONOFF, true);
		Param.Harass:addParam("ManaW", "Set a value for (W) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
		Param.Harass:addParam("E", "Use E :" , SCRIPT_PARAM_ONOFF, true);
		Param.Harass:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);

	Param:addSubMenu("LaneClear Settings", "WaveClear");

		Param.WaveClear:addParam("Q", "Use Q :" , SCRIPT_PARAM_ONOFF, true);
		Param.WaveClear:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
		Param.WaveClear:addParam("W", "Use W :" , SCRIPT_PARAM_ONOFF, false);
		Param.WaveClear:addParam("ManaW", "Set a value for (W) in Mana :", SCRIPT_PARAM_SLICE, 80, 0, 100);
		Param.WaveClear:addParam("E", "Use E :" , SCRIPT_PARAM_ONOFF, true);
		Param.WaveClear:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);

	Param:addSubMenu("LaneClear Settings (Against Champion)", "WaveClear2");

		Param.WaveClear2:addParam("Q", "Use Q :" , SCRIPT_PARAM_ONOFF, true);
		Param.WaveClear2:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
		Param.WaveClear2:addParam("W", "Use W :" , SCRIPT_PARAM_ONOFF, false);
		Param.WaveClear2:addParam("ManaW", "Set a value for (W) in Mana :", SCRIPT_PARAM_SLICE, 100, 0, 100);
		Param.WaveClear2:addParam("E", "Use E :" , SCRIPT_PARAM_ONOFF, false);
		Param.WaveClear2:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 100, 0, 100);

	Param:addSubMenu("JungleClear Settings", "JungleClear");

		Param.JungleClear:addParam("Q", "Use Q :" , SCRIPT_PARAM_ONOFF, true);
		Param.JungleClear:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);
		Param.JungleClear:addParam("W", "Use W :" , SCRIPT_PARAM_ONOFF, true);
		Param.JungleClear:addParam("ManaW", "Set a value for (W) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
		Param.JungleClear:addParam("E", "Use E :" , SCRIPT_PARAM_ONOFF, true);
		Param.JungleClear:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);

	Param:addSubMenu("Drawing Setttings", "Draw");
		Param.Draw:addSubMenu("Spell Settings", "Spell");
			Param.Draw.Spell:addParam("Q", "Display (Q) Range :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Spell:addParam("W", "Display (W) Range :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Spell:addParam("E", "Display (E) Range :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Spell:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			Param.Draw.Spell:addParam("AA", "Display Auto Attack Range :", SCRIPT_PARAM_ONOFF, false);

		Param.Draw:addSubMenu("Skin Changer", "Skin");
			Param.Draw.Skin:addParam("Enable", "Enable Skin Changer :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Skin:setCallback("Enable", function(SkinC)
				if SkinC then
					SetSkin(myHero, Param.Draw.Skin.skins-1);
				else
					SetSkin(myHero, -1);
				end
			end)
			Param.Draw.Skin:addParam("skins", "Set Skin :", SCRIPT_PARAM_LIST, 1, {"Classic", "Human", "Tribal", "Uncle", "Triumphant", "Professor", "Zombie", "Dark Crystal", "Pirate", "Whitebeard"});
			Param.Draw.Skin:setCallback("skins", function(ChangeSkinC)
				if ChangeSkinC then
					if Param.Draw.Skin.Enable then
						SetSkin(myHero, Param.Draw.Skin.skins-1);
					end
				end
			end)

		Param.Draw:addSubMenu("PermaShow Settings", "PermaShow");
			Param.Draw.PermaShow:addParam("Enable", "Use PermaShow :", SCRIPT_PARAM_ONOFF, true);
		Param.Draw:addSubMenu("Misc Settings", "Misc");
			Param.Draw.Misc:addParam("Hour", "Draw hour :", SCRIPT_PARAM_ONOFF, true);
			Param.Draw.Misc:addParam("HitBox", "Draw HitBox :", SCRIPT_PARAM_ONOFF, true);
			Param.Draw.Misc:addParam("Target", "Draw Target :", SCRIPT_PARAM_ONOFF, true);

		Param.Draw:addParam("n1", "", SCRIPT_PARAM_INFO, "");
		Param.Draw:addParam("Enable", "Enable Drawing :", SCRIPT_PARAM_ONOFF, true);

	Param:addSubMenu("Miscellaneous", "Misc");

		Param.Misc:addSubMenu("AutoBuy", "Buy");
			Param.Misc.Buy:addParam("Enable", "Enable AutoBuy :", SCRIPT_PARAM_ONOFF, true);
			Param.Misc.Buy:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			Param.Misc.Buy:addParam("Crist", "Buy Mana Cristal :", SCRIPT_PARAM_ONOFF, true);
			Param.Misc.Buy:addParam("Pots", "Buy Potions :", SCRIPT_PARAM_ONOFF, true);
			Param.Misc.Buy:addParam("Trinket", "Buy Yellow Trinket :", SCRIPT_PARAM_ONOFF, true);
			Param.Misc.Buy:addParam("n2", "", SCRIPT_PARAM_INFO, "");
			Param.Misc.Buy:addParam("BlueTrinket", "Auto Upgrade Trinket (lvl.9) :", SCRIPT_PARAM_ONOFF, true);

		if VIP_USER then Param.Misc:addSubMenu("Auto LVL Spell", "LVL");
			Param.Misc.LVL:addParam("Enable", "Enable Auto Level Spell?", SCRIPT_PARAM_ONOFF, true);
			Param.Misc.LVL:addParam("Combo", "LVL Spell Order :", SCRIPT_PARAM_LIST, 2, {"E > Q > W (Max Q>E)", "E > W > Q (Max Q>E)"});
			Param.Misc.LVL:setCallback("Combo", function (nV)
				if nV then
					self:AutoLVLCombo();
				else 
					self:AutoLVLCombo();
				end
			end)
		end

		Param.Misc:addSubMenu("Potions Settings", "Pots");
				Param.Misc.Pots:addParam("Enable", "Use Auto Potions :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Pots:addParam("Combo", "Use only on Combo mode :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Pots:addParam("HP", "Set an %HP value :", SCRIPT_PARAM_SLICE, 60, 0, 100);

	Param:addParam("n1", "", SCRIPT_PARAM_INFO, "");
	Param:addParam("Pred", "Prediction :", SCRIPT_PARAM_LIST, 2, {"VPred", "HPred", "FHPred"});
	Param:setCallback("n1", function(Pred)
		if Pred then
			self:Loader();
		else
			self:Loader();
		end
	end);

	enemyMinions = minionManager(MINION_ENEMY, 615, myHero, MINION_SORT_HEALTH_ASC);
	jungleMinions = minionManager(MINION_JUNGLE, 615, myHero, MINION_SORT_MAXHEALTH_DEC);
end

function Ryze:OnDraw()
	if Param.Draw.Enable then
		if Param.Draw.Misc.Hour then
			DrawText(os.date("%A, %B %d %Y - %X - "..GetLatency().." ms"), 15, WINDOW_W/1.45, WINDOW_W/180, 0xFFFFFFFF);
		end
		if self.Q and Param.Draw.Spell.Q then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 1000, 1, 0xFFFFFFFF);
		end
		if self.W and Param.Draw.Spell.W then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 615, 1, 0xFFFFFFFF);
		end
		if self.E and Param.Draw.Spell.E then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 615, 1, 0xFFFFFFFF);
		end
		if Param.Draw.Spell.AA then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 1, 0xFFFFFFFF)
		end
		if Param.Draw.Misc.HitBox then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF);
		end
		if self.Target ~= nil then
			if Param.Draw.Misc.Target then
				DrawText3D(">> TARGET <<", self.Target.x-100, self.Target.y-50, self.Target.z, 20, 0xFFFFFFFF);
				DrawText(""..self.Target.charName.."", 50, 50, 200, 0xFFFFFFFF);
			end
		end
	end
end

function Ryze:Mode()
    if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
        if _G.AutoCarry.Keys.AutoCarry then 
            if Mode ~= "Combo" then
                Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G.AutoCarry.Keys.MixedMode then 
            if Mode ~= "Harass" then
                Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G.AutoCarry.Keys.LaneClear then 
            if Mode ~= "Harass" then
                Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        elseif _G.AutoCarry.Keys.LastHit then
            if Mode ~= "LastHit" then
                Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        else
            if Mode ~= "None" then
                Mode = "None";
                self:PermaShow("None");
            end
        end

    elseif _G.MMA_IsLoaded then

        if _G.MMA_IsOrbwalking then 
            if Mode ~= "Combo" then
                Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G.MMA_IsDualCarrying then 
            if Mode ~= "Harass" then
                Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G.MMA_IsLaneClearing then 
            if Mode ~= "Harass" then
                Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        elseif _G.MMA_IsLastHitting then
            if Mode ~= "LastHit" then
                Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        else
            if Mode ~= "None" then
                Mode = "None";
                self:PermaShow("None");
            end
        end

    elseif _Pewalk then

        if _G._Pewalk.GetActiveMode().Carry then 
            if Mode ~= "Combo" then
                Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G._Pewalk.GetActiveMode().Mixed then 
            if Mode ~= "Harass" then
                Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G._Pewalk.GetActiveMode().LaneClear then
            if Mode ~= "LaneClear" then
                Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        elseif _G._Pewalk.GetActiveMode().Farm then 
            if Mode ~= "LastHit" then
                Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        else
            if Mode ~= "None" then
                Mode = "None";
                self:PermaShow("None");
            end
        end

    elseif _G.NebelwolfisOrbWalkerLoaded then

        if _G.NebelwolfisOrbWalker.Config.k.Combo then
            if Mode ~= "Combo" then
                Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G.NebelwolfisOrbWalker.Config.k.Harass then
            if Mode ~= "Harass" then
                Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G.NebelwolfisOrbWalker.Config.k.LastHit then
            if Mode ~= "LastHit" then
                Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        elseif _G.NebelwolfisOrbWalker.Config.k.LaneClear then
            if Mode ~= "LaneClear" then
                Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        else
            if Mode ~= "None" then
                Mode = "None";
                self:PermaShow("None");
            end
        end
    end
end

function Ryze:Modes()
	self:Checks();
	if Mode == "Combo" then
		self:Combo();
	elseif Mode == "Harass" then
		self:Harass();
	elseif Mode == "LaneClear" then
		self:WaveClear();
		self:JungleClear();
	elseif Mode == "LastHit" then
		self:LastHit();
	end
end

function Ryze:PermaShow(p)
    if Param.Draw.PermaShow.Enable then
        CustomPermaShow("                         - Korean Top | "..myHero.charName.." - ", nil, true, nil, nil, nil, 0);
        CustomPermaShow("Current Mode :", ""..p, true, nil, nil, nil, 1);
        CustomPermaShow("", "", true, nil, nil, nil, 2);
        CustomPermaShow("By spyk ", " - Beta", true, nil, nil, nil, 180);
    else
        CustomPermaShow("                         - Korean Top | "..myHero.charName.." - ", nil, false, nil, nil, nil, 0);
        CustomPermaShow("Current Mode :", ""..p, false, nil, nil, nil, 1);
        CustomPermaShow("", "", false, nil, nil, nil, 2);
        CustomPermaShow("By spyk ", " - Beta", false, nil, nil, nil, 180);
    end
end

function Ryze:GetTarget()
	if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
		t = _G.AutoCarry.Crosshair:GetTarget();
	elseif _G.MMA_IsLoaded then
		t = _G.MMA_Target();
	elseif _Pewalk then
		t = _Pewalk.GetTarget();
	elseif _G.NebelwolfisOrbWalkerLoaded then
		t = _G.NebelwolfisOrbWalker:GetTarget();
	end
	if ValidTarget(t) and t.type == myHero.type then
		return t
	else
		return nil
	end
end

function Ryze:Update()
	local version = "0.01";
	local author = "spyk";
	local SCRIPT_NAME = "BaguetteRyze";
	local AUTOUPDATE = true;
	local UPDATE_HOST = "raw.githubusercontent.com";
	local UPDATE_PATH = "/spyk1/BoL/master/BaguetteRyze/BaguetteRyze.lua".."?rand="..math.random(1,10000);
	local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME;
	local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH;
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteRyze/BaguetteRyze.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil;
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				self:Alerte("New version available "..ServerVersion);
				self:Alerte(">>Updating, please don't press F9<<");
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () self:Alerte("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3);
			else
				DelayAction(function() self:Alerte("Hello, "..GetUser()..". You got the latest version! ("..ServerVersion..")") end, 3);
				self:CustomLoad();
			end
		end
	else
		self:Alerte("Error downloading version info");
	end
end

function Ryze:Unload()
	if Param.Draw.Skin.Enable then
		SetSkin(myHero, -1);
	end
	self:Alerte("Unloaded, ciao !");
end

function Ryze:Lib()
	local LibPath = LIB_PATH.."SpikeLib.lua"
	if not FileExist(LibPath) then
		local Host = "raw.github.com"
		local Path = "/spyk1/BoL/master/bundle/SpikeLib.lua".."?rand="..math.random(1,10000)
		Alerte("Libs not found!")
		DownloadFile("https://"..Host..Path, LibPath, function ()  end)
		DelayAction(function () require("SpikeLib") end, 5)
	else
		require("SpikeLib")
	end
end

function Ryze:Loader()
    if Param.Pred == 1 then
        self:LoadVPred();
    elseif Param.Pred == 2 then
        self:LoadHPred();
    elseif Param.Pred == 3 then
        self:LoadFHPred();
    end
end

function Ryze:LoadVPred()
    if FileExist(LIB_PATH .. "/VPrediction.lua") then
        require("VPrediction");
        VP = VPrediction();
    else
        local Host = "raw.githubusercontent.com";
        local Path = "/SidaBoL/Scripts/master/Common/VPrediction.lua".."?rand="..math.random(1,10000);
        self:Alerte("VPred not found, downloading...");
        DownloadFile("https://"..Host..Path, LibPath, function ()  end);
        DelayAction(function () require("VPrediction") end, 5);
    end
end

function Ryze:LoadHPred()
    if FileExist(LIB_PATH .. "/HPrediction.lua") then
        require("HPrediction");
        HPred = HPrediction();
        UseHP = true;
    else
        local Host = "raw.githubusercontent.com";
        local Path = "/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua".."?rand="..math.random(1,10000);
        self:Alerte("HPred not found, downloading..");
        DownloadFile("https://"..Host..Path, LibPath, function ()  end);
        DelayAction(function () require("HPrediction") end, 5);
    end
end

function Ryze:LoadFHPred()
    if FileExist(LIB_PATH.."FHPrediction.lua") then
        require("FHPrediction");
    else
        self:Alerte("You don't have FHPred!");
        Param.Pred = 2;
        self:Loader();
    end
end
