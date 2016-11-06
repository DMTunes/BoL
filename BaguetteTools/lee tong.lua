if myHero.charName ~= "LeeSin" then return end

function OnLoad()

	LeeSin();
end

class "LeeSin";

function LeeSin:__init()
	self:Alerte("Lee Tong - by spyk, loading..")
	self:Update();
end

function LeeSin:Alerte(msg)
	PrintChat("<b><font color=\"#27ae60\">></font></b> <font color=\"#ffffff\"> " .. msg .. "</font>");
end

function LeeSin:AutoLvlSpell()
	if self.Time - self.Last_LevelSpell > 0.5 then
		if self.Param.Extra.LVL.Enable then
			autoLevelSetSequence(levelSequence);
			self.Last_LevelSpell = self.Time;
		elseif not self.Param.Extra.LVL.Enable then
			autoLevelSetSequence(nil);
			self.Last_LevelSpell = self.Time + 10;
		end
	end
end

function LeeSin:AutoLVLSpellCombo()
	AddTickCallback(function()
		self:AutoLvlSpell();
	end);
	if self.Param.Extra.LVL.Enable then
		if self.Param.Extra.LVL.Combo == 1 then
			levelSequence =  {1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2} -- Max R/Q/E/W | Q > W > E
		end
	end
end

function LeeSin:AutoLVLSpellCombo2()
	if self.Param.Extra.LVL.Enable then
		if self.Param.Extra.LVL.Combo == 1 then
			levelSequence =  {1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2} -- Max R/Q/E/W | Q > W > E
		end
	end
end

function LeeSin:AutoSmite()
	if self.Param.JungleClear.Smite and self.S then
		jungleMinions:update();
		for i, unit in pairs(jungleMinions.objects) do
			if GetDistanceSqr(unit) < 250000 then
				if unit.health < self:SD() then
					if self.JungleSmite[self.Param.JungleClear.Mod][unit.name] or unit.charName:lower():find("dragon") then
						CastSpell(self.Smite, unit);
					end
				end
			end
		end
	end
end

function LeeSin:AutoWard() -- Credit to Ralphlol
	self.LastPos = {};
	self.LastTime = {};
	self.Next_WardTime = 0;
	self.BuffNames = {"rengarr", "monkeykingdecoystealth", "talonshadowassaultbuff", "vaynetumblefade", "twitchhideinshadows", "khazixrstealth", "akaliwstealth"};
	for _, c in pairs(GetEnemyHeroes()) do
		self.LastPos[c.networkID] = Vector(c);
	end
	AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance)
		self:AutoWardPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance);
	end)
	AddTickCallback(function()
		self:AutoWardTick();
	end)
	AddProcessSpellCallback(function(unit, spell)
		self:AutoWardProcessSpell(unit, spell);
	end)
	AddUpdateBuffCallback(function(unit, buff, stacks) 
		self:AutoWardUpdateBuff(unit, buff, stacks);
	end)
end

function LeeSin:AutoWardPath(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance)
	if unit.team ~= myHero.team and isDash then
		self.LastPos[unit.networkID] = Vector(endPos);
	end
end

function LeeSin:AutoWardItem(bush)
	local WardSlot = nil
	if bush then
		if self:GetSlotItem(2045) and myHero:CanUseSpell(self:GetSlotItem(2045)) == READY then
			WardSlot = self:GetSlotItem(2045);
		elseif self:GetSlotItem(2049) and myHero:CanUseSpell(self:GetSlotItem(2049)) == READY then
			WardSlot = self:GetSlotItem(2049);
		elseif self:GetSlotItem(3340) and myHero:CanUseSpell(self:GetSlotItem(3340)) == READY or self:GetSlotItem(3350) and myHero:CanUseSpell(self:GetSlotItem(3350)) == READY or self:GetSlotItem(3361) and myHero:CanUseSpell(self:GetSlotItem(3361)) == READY or self:GetSlotItem(3363) and myHero:CanUseSpell(self:GetSlotItem(3363)) == READY or self:GetSlotItem(3411) and myHero:CanUseSpell(self:GetSlotItem(3411)) == READY or self:GetSlotItem(3342) and myHero:CanUseSpell(self:GetSlotItem(3342)) == READY or self:GetSlotItem(3362) and myHero:CanUseSpell(self:GetSlotItem(3362)) == READY then
			WardSlot = 12;
		elseif self:GetSlotItem(2044) and myHero:CanUseSpell(self:GetSlotItem(2044)) == READY then
			WardSlot = self:GetSlotItem(2044);
		elseif self:GetSlotItem(2043) and myHero:CanUseSpell(self:GetSlotItem(2043)) == READY then
			WardSlot = self:GetSlotItem(2043);
		end
	else
		if self:GetSlotItem(3362) and myHero:CanUseSpell(self:GetSlotItem(3362)) == READY then
			WardSlot = 12;
		elseif  self:GetSlotItem(2043) and myHero:CanUseSpell(self:GetSlotItem(2043)) == READY then
			WardSlot = self:GetSlotItem(2043);
		end
	end
	return WardSlot
end

function LeeSin:AutoWardTick()
	if not self.Param.Extra.Items.WARD then return end
	for _, c in pairs(GetEnemyHeroes()) do  
		if c.visible then
			self.LastPos[c.networkID] = Vector(c);
			self.LastTime[c.networkID] = os.clock();
		elseif not c.dead and not c.visible then
			self:AutoWardCheck(c, true);
		end
	end
end

function LeeSin:AutoWardProcessSpell(unit, spell)
	if unit.team ~= myHero.team then
		if spell.name:lower():find("deceive") then
			local f = spell.endPos;
			if GetDistance(unit, spell.endPos) > 400 then
				f = Vector(unit) + (Vector(spell.endPos) - Vector(unit)):normalized() * (400);
			end
			if checkWall(f) then
				f = NearestNonWall(f.x, f.y, f.z, 400, 60);
			end
			self:AutoWardCheck(unit, false, f);
		end
	end
end

function LeeSin:AutoWardUpdateBuff(unit, buff, stacks)
	if not unit or not buff then return end
	if unit.team ~= myHero.team then
		if (self.Param.Extra.Items.WARDCombo and self.Mode == "Combo") or not self.Param.Extra.Items.WARD then
			for _, buffN in pairs(self.BuffNames) do    
				if buff.name:lower():find(buffN) then
					self:AutoWardCheck(unit, false)
				end
			end
		end
	end
end

function LeeSin:AutoWardCheck(c, bush, cPos)
	local time = self.LastTime[c.networkID];
	local pos = cPos and cPos or self.LastPos[c.networkID];
	local clock = self.Time;

	if time and pos and clock - time < 1 and clock > self.Next_WardTime and GetDistanceSqr(pos) < 1000 * 1000 then

		local castPos, WardSlot
		if bush then
			castPos = self:AutoWardFindBush(pos.x, pos.y, pos.z, 100)
			if castPos and GetDistanceSqr(castPos) < 600 * 600 then
				WardSlot = self:AutoWardItem(bush);
			end
		else
			castPos = pos;
			if GetDistanceSqr(castPos) < 600 * 600 then
				WardSlot = self:AutoWardItem(bush);
			elseif GetDistanceSqr(castPos) < 900 * 900 then
				castPos = Vector(myHero) +  Vector(Vector(castPos) - Vector(myHero)):normalized()* 575;
				WardSlot = self:AutoWardItem(bush);
			end
		end
		if WardSlot then
			CastSpell(WardSlot,castPos.x,castPos.z);
			self.Next_WardTime = clock + 10;
			return
		end
	end
end

function LeeSin:AutoWardFindBush(x0, y0, z0, maxRadius, precision) -- Credits to gReY
	local vec = D3DXVECTOR3(x0, y0, z0)
	precision = precision or 50
	maxRadius = maxRadius and math.floor(maxRadius / precision) or math.huge
	x0, z0 = math.round(x0 / precision) * precision, math.round(z0 / precision) * precision
	local radius = 2
	local function checkP(x, y)
		vec.x, vec.z = x0 + x * precision, z0 + y * precision 
		return IsWallOfGrass(vec) 
	end
	while radius <= maxRadius do
		if checkP(0, radius) or checkP(radius, 0) or checkP(0, -radius) or checkP(-radius, 0) then
			return vec 
		end
		local f, x, y = 1 - radius, 0, radius
		while x < y - 1 do
			x = x + 1
			if f < 0 then 
				f = f + 1 + 2 * x
			else 
				y, f = y - 1, f + 1 + 2 * (x - y)
			end
			if checkP(x, y) or checkP(-x, y) or checkP(x, -y) or checkP(-x, -y) or 
			   checkP(y, x) or checkP(-y, x) or checkP(y, -x) or checkP(-y, -x) then
				return vec 
			end
		end
		radius = radius + 1
	end
end

function LeeSin:AutoBuy()
	if self.Param.Extra.AutoBuy.Enable then
		if GetGameTimer() < 200 then
			DelayAction(function()
				if self.Param.Extra.AutoBuy.Machete then
					DelayAction(function()
						BuyItem(1041);
					end, 1);
				end
				if self.Param.Extra.AutoBuy.Potion then
					DelayAction(function()
						BuyItem(2031)
					end, 2);
				end
				if self.Param.Extra.AutoBuy.Trinket then
					DelayAction(function()
						BuyItem(3340);
					end, 3)
				end
			end, 2);
		end
	end
end

function LeeSin:AutoPotion()
	if self.Param.Extra.Items.POT then
		if self.Time - self.LastPotCheck > 1 then
			self.LastPotCheck = self.Time;
			if self.Time - self.lastPotion > self.ActualPotTime then
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
end

function LeeSin:Checks()
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
	if myHero:CanUseSpell(_R) == READY then
		self.R = true;
	else
		self.R = false;
	end
	if myHero:CanUseSpell(self.Smite) == READY then
		self.S = true;
	else
		self.S = false;
	end
	if myHero:CanUseSpell(self.Flash) == READY then
		self.F = true;
	else
		self.F = false;
	end
	self:Items();
end

function LeeSin:Items()
	if self.Time - self.Last_Item_Check > 10 then
		self.Last_Item_Check = self.Time;
		for i = 6, 12 do
			local T = myHero:GetSpellData(i).id;
			local tiamats = {["Frst"] = 3077, ["Sec"] = 3074, ["Third"] = 3748};
			for k, v in pairs(tiamats) do
				if tiamats[i] == T then
					self.TiamatSlot = i;
				end
			end
		end
	end
	if self.Tiamat and myHero:CanUseSpell(self.TiamatSlot) == READY then
		self.T = true;
	else
		self.T = false;
	end
end

function LeeSin:CustomLoad()
	self:Var();
	self:Menu();
	self:Loader();
	if VIP_USER then
		self:VIPLoader();
	end
	if self.Param.Draw.Misc.SKIN then
		SetSkin(myHero, self.Param.Draw.Misc.skins-1);
	end
	self:AutoWard();
	self:Orbwalker();
	AddTickCallback(function()
		self:CurrentMode();
		self:Checks();
		self:KillSteal()
		self.Target = self:GetTarget();
		if self.Target ~= nil then
			if self.Mode == "Combo" then
				if myHero:CanUseSpell(_Q) == READY and self.Param.Combo.Q then 
					if not self:HaveQ(self.Target) then
						self:CastQ1(self.Target);
					elseif self:HaveQ(self.Target) then
						CastSpell(_Q);
					end
				end
				if myHero:CanUseSpell(_E) == READY and self.Param.Combo.E then
					if self:FirstCast(_E) and GetDistanceSqr(self.Target) < 122500 then
						self:CastE1(self.Target);
					elseif GetDistanceSqr(self.Target) < 250000 then
						self:CastE2(self.Target);
					end
				end
			end
		end
		self:AutoPotion();
	end);
	AddProcessAttackCallback(function(unit, spell)
		self:OnProcessAttack(unit, spell);
	end);
	AddProcessSpellCallback(function(unit, spell)
		self:OnProcessSpell(unit, spell);
	end);
	AddRemoveBuffCallback(function(unit, buff)
		if unit and unit.isMe and buff.name:lower():find("passive") then
			self.Passive = 0;
		end
	end);
	AddDrawCallback(function()
		self:OnDraw();
	end);
	AddMsgCallback(function(msg,key) 
		self:OnWndMsg(msg,key);
	end);
	AddCreateObjCallback(function(obj)
		self:OnCreateObj(obj);
	end);
	AddUnloadCallback(function()
    	if self.Param.Draw.Misc.SKIN then
    		SetSkin(myHero, -1);
    	end
		self:Alerte("Unloaded, ciao !");
	end);
end

function LeeSin:OnProcessAttack(unit, spell)
	if unit and unit.isMe then
		if spell.name:lower():find("atta") then
			self:Checks();
			if self.Passive > 0 then
				self.Passive = self.Passive - 1;
			end
			if self.Mode == "Combo" then
				self:Combo();
			elseif self.Mode == "LaneClear" then
				if spell.target.health > myHero:CalcDamage(spell.target, myHero.totalDamage) then
					self:LaneClear();
				end
			end
		end
	end
end

function LeeSin:OnProcessSpell(unit, spell)
	if unit and unit.isMe then
		self.Passive = 2;
		if self.Mode == "LaneClear" then
			if spell.name:lower():find("blindmonkqtwo") then
				-- smite
			end
		end
	end
end

function LeeSin:CurrentMode()
	if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
		if _G.AutoCarry.Keys.AutoCarry then 
			if self.Mode ~= "Combo" then
				self.Mode = "Combo";
			end
		elseif _G.AutoCarry.Keys.MixedMode then 
			if self.Mode ~= "Harass" then
				self.Mode = "Harass";
			end
		elseif _G.AutoCarry.Keys.LaneClear then 
			if self.Mode ~= "Harass" then
				self.Mode = "LaneClear";
			end
		elseif _G.AutoCarry.Keys.LastHit then
			if self.Mode ~= "LastHit" then
				self.Mode = "LastHit";
			end
		else
			if self.Mode ~= "None" then
				self.Mode = "None";
			end
		end

	elseif _G.MMA_IsLoaded then

		if _G.MMA_IsOrbwalking then 
			if self.Mode ~= "Combo" then
				self.Mode = "Combo";
			end
		elseif _G.MMA_IsDualCarrying then 
			if self.Mode ~= "Harass" then
				self.Mode = "Harass";
			end
		elseif _G.MMA_IsLaneClearing then 
			if self.Mode ~= "LaneClear" then
				self.Mode = "LaneClear";
			end
		elseif _G.MMA_IsLastHitting then
			if self.Mode ~= "LastHit" then
				self.Mode = "LastHit";
			end
		else
			if self.Mode ~= "None" then
				self.Mode = "None";
			end
		end

	elseif _Pewalk then

		if _G._Pewalk.GetActiveMode().Carry then 
			if self.Mode ~= "Combo" then
				self.Mode = "Combo";
			end
		elseif _G._Pewalk.GetActiveMode().Mixed then 
			if self.Mode ~= "Harass" then
				self.Mode = "Harass";
			end
		elseif _G._Pewalk.GetActiveMode().LaneClear then
			if self.Mode ~= "LaneClear" then
				self.Mode = "LaneClear";
			end
		elseif _G._Pewalk.GetActiveMode().Farm then 
			if self.Mode ~= "LastHit" then
				self.Mode = "LastHit";
			end
		else
			if self.Mode ~= "None" then
				self.Mode = "None";
			end
		end

	elseif _G.NebelwolfisOrbWalkerLoaded then

		if _G.NebelwolfisOrbWalker.Config.k.Combo then
			if self.Mode ~= "Combo" then
				self.Mode = "Combo";
			end
		elseif _G.NebelwolfisOrbWalker.Config.k.Harass then
			if self.Mode ~= "Harass" then
				self.Mode = "Harass";
			end
		elseif _G.NebelwolfisOrbWalker.Config.k.LastHit then
			if self.Mode ~= "LastHit" then
				self.Mode = "LastHit";
			end
		elseif _G.NebelwolfisOrbWalker.Config.k.LaneClear then
			if self.Mode ~= "LaneClear" then
				self.Mode = "LaneClear";
			end
		else
			if self.Mode ~= "None" then
				self.Mode = "None";
			end
		end
	end
end

function LeeSin:GetSlotItem(id)
	local tab = {[3144] = "BilgewaterCutlass", [3153] = "ItemSwordOfFeastAndFamine", 
	[3405] = "TrinketSweeperLvl1", [3411] = "TrinketOrbLvl1", [3166] = "TrinketTotemLvl1", 
	[3450] = "OdinTrinketRevive", [2041] = "ItemCrystalFlask", [2054] = "ItemKingPoroSnack", 
	[2138] = "ElixirOfIron", [2137] = "ElixirOfRuin", [2139] = "ElixirOfSorcery", 
	[2140] = "ElixirOfWrath", [3184] = "OdinEntropicClaymore", [2050] = "ItemMiniWard", 
	[3401] = "HealthBomb", [3363] = "TrinketOrbLvl3", [3092] = "ItemGlacialSpikeCast", 
	[3460] = "AscWarp", [3361] = "TrinketTotemLvl3", [3362] = "TrinketTotemLvl4", 
	[3159] = "HextechSweeper", [2051] = "ItemHorn", [3146] = "HextechGunblade", 
	[3187] = "HextechSweeper", [3190] = "IronStylus", [2004] = "FlaskOfCrystalWater", 
	[3139] = "ItemMercurial", [3222] = "ItemMorellosBane", [3180] = "OdynsVeil", 
	[3056] = "ItemFaithShaker", [2047] = "OracleExtractSight", [3364] = "TrinketSweeperLvl3", 
	[3140] = "QuicksilverSash", [3143] = "RanduinsOmen", [3074] = "ItemTiamatCleave", 
	[3800] = "ItemRighteousGlory", [2045] = "ItemGhostWard", [3342] = "TrinketOrbLvl1", 
	[3040] = "ItemSeraphsEmbrace", [3048] = "ItemSeraphsEmbrace", [2049] = "ItemGhostWard", 
	[3345] = "OdinTrinketRevive", [2044] = "SightWard", [3341] = "TrinketSweeperLvl1", 
	[3069] = "shurelyascrest", [3599] = "KalistaPSpellCast", [3185] = "HextechSweeper", 
	[3077] = "ItemTiamatCleave", [2009] = "ItemMiniRegenPotion", [2010] = "ItemMiniRegenPotion", 
	[3023] = "ItemWraithCollar", [3290] = "ItemWraithCollar", [2043] = "VisionWard", 
	[3340] = "TrinketTotemLvl1", [3142] = "YoumusBlade", [3512] = "ItemVoidGate", 
	[3131] = "ItemSoTD", [3137] = "ItemDervishBlade", [3352] = "RelicSpotter", 
	[3350] = "TrinketTotemLvl2", [3085] = "AtmasImpalerDummySpell"};
	local name = tab[id];
	for i = 6, 12 do
		local item = myHero:GetSpellData(i).name;
		if ((#item > 0) and (item:lower() == name:lower())) then
			return i
		end
	end
end

function LeeSin:GetTarget()
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

function LeeSin:Loader()
	if self.Param.Pred == 1 then
		self:LoadVPred();
	elseif self.Param.Pred == 2 then
		self:LoadHPred();
	elseif self.Param.Pred == 3 then
		self:LoadFHPred();
	end
end

function LeeSin:CastQ1(unit)
	if GetDistanceSqr(unit) < 1000000 and self:FirstCast(_Q) then
		if self.Ward[unit.name] then
			return
		end
		if self.Param.Pred == 1 then
			local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, self.Skills["Q"].delay, self.Skills["Q"].width, self.Skills["Q"].range, self.Skills["Q"].speed, myHero, false);
			if HitChance > 1 then
				CastSpell(_Q, CastPosition.x, CastPosition.z);
			end
		elseif self.Param.Pred == 2 then
			local Position, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayLine", delay = self.Skills["Q"].delay, range = self.Skills["Q"].range, speed = self.Skills["Q"].speed, collisionH = true, collisionM = true, width = self.Skills["Q"].width}), unit, myHero);
			if HitChance > 0 then
				CastSpell(_Q, Position.x, Position.z);
			end
		elseif self.Param.Pred == 3 then
			local pos, hc, info = FHPrediction.GetPrediction("Q", unit);
			if hc > 0 then
				if not info.collision then
					CastSpell(_Q, pos.x, pos.z);
				elseif info.collision and info.collision.amount == 1 and unit.type == myHero.type then
					local collidedObject = info.collision.objects[1]
						if collidedObject.type == "obj_AI_Minion" and
					  GetDistanceSqr(collidedObject, myHero) < 600*600 and
					  collidedObject.health <= math.max(20*myHero.level+370, 30*myHero.level+330, 40*myHero.level+240, 50*myHero.level+100) then
						CastSpell(_Q, pos.x, pos.z)
						DelayAction(CastSpell, 0.25, {self.Smite, info.collision.objects[1]})
					end
				end
			end
		end
	end
end

function LeeSin:CastQ2(unit)
	if self:HaveQ(unit) and GetDistanceSqr(unit) < 1690000 and not self:FirstCast(_Q) then
		CastSpell(_Q);
	end
end

function LeeSin:CastW1(unit)
	if unit == nil then unit = myHero end
	if unit.valid and GetDistanceSqr(unit) < 490000 and self:FirstCast(_W) then
		local unit = unit and unit.team == myHero.team or myHero;
		CastSpell(_W, unit);
	end
end

function LeeSin:CastW2(unit)
	CastSpell(_W);
end

function LeeSin:CastE1(unit)
	if self:FirstCast(_E) then
		if self.Ward[unit.name] then
			return
		end
		CastSpell(_E);
	end
end

function LeeSin:CastE2(unit)
	if not self:FirstCast(_E) then
		if self.Ward[unit.name] then
			return
		end
		CastSpell(_E);
	end
end

function LeeSin:CastR(unit)
	CastSpell(_R, unit);
end

function LeeSin:KillSteal()
	if self.Param.KillSteal.Use then
		for _, unit in pairs(GetEnemyHeroes()) do
			if GetDistanceSqr(unit) < 1440000 and not self:Immune(unit) and not unit.dead and unit.visible then
				local HP = unit.health + unit.shield;
				if self.Q and self.Param.KillSteal.Q then
					local Q1 = self:qDmg(unit);
					local Q2 = self:q2Dmg(unit);
					local Q3 = self:q3Dmg(unit);
					if HP < Q3 then
						if self:FirstCast(_Q) then
							if (self.Param.KillSteal.Q1 and HP < Q1) or self.Param.KillSteal.Q3 then
								self:CastQ1(unit);
							end
						else
							if HP < Q2 and self:HaveQ(unit) then
								CastSpell(_Q);
							end
						end
					end
				end
				if self.E and self.Param.KillSteal.E and GetDistanceSqr(unit) < 122500 then
					local dmg = self:eDmg(unit);
					if HP < dmg then
						if self:FirstCast(_E) then
							CastSpell(_E);
						end
					end
				end
				if self.R and self.Param.KillSteal.R and GetDistanceSqr(unit) < 1000000 then
					local dmg = self:rDmg(unit);
					if HP < dmg and GetDistanceSqr(unit) < 140625 then
						CastSpell(_R, unit);
					else
						for _, k in pairs(GetEnemyHeroes()) do
							if k ~= nil and GetDistanceSqr(k) < 140625 and HP < dmg then
								local Segment = Vector(k) + (Vector(myHero) - Vector(k)):normalized()*1000;
								local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(Vector(k), Segment, unit);
								if isOnSegment and GetDistanceSqr(pointSegment, unit) < k.boundingRadius * k.boundingRadius then
									CastSpell(_R, k);
								end
							end
						end
					end
				end
			end
		end
	end
end

function LeeSin:LaneClear()
	jungleMinions:update();
	for i, unit in pairs(jungleMinions.objects) do
		if unit.team == 300 and not unit.dead and GetDistanceSqr(unit) < 1690000 then
			if self.Ward[unit.name] then return end
			if self.T then CastSpell(self.TiamatSlot) end
			if self.Param.JungleClear.Q and self.Q and not self:FirstCast(_Q) and self:HaveQ(unit) and (self:ShouldQ(unit) or unit.health < self:q2Mob(unit)) then
				CastSpell(_Q);
			end
			if self.Passive == 0 then
				if self.Param.JungleClear.Q and self.Q and self:FirstCast(_Q) then
					CastSpell(_Q, unit.x, unit.z);
				elseif self.Param.JungleClear.W and self.W then
					if self:FirstCast(_W) then
						self:CastW1(unit);
					else
						self:CastW2(unit);
					end
				elseif self.Param.JungleClear.E and self.E then
					if self:FirstCast(_E) then
						self:CastE1(unit);
					else
						self:CastE2(unit);
					end
				end
			end
		end
	end
	enemyMinions:update();
	for i, unit in pairs(enemyMinions.objects) do
		if unit.type == "obj_AI_Minion" and not unit.dead and GetDistanceSqr(unit) < 1690000 then
			if self.Ward[unit.name] then return end
			if self.Param.Extra.Items.Tiamat and self.T then CastSpell(self.TiamatSlot) end
			if self.Passive == 0 then
				if self.Param.WaveClear.E and self.E then
					if self:FirstCast(_E) then
						self:CastE1(unit);
					else
						self:CastE2(unit);
					end
				elseif self.Param.WaveClear.Q and self.Q and self:FirstCast(_Q) then
					self:CastQ1(unit);
				elseif self.Param.WaveClear.Q and self.Q and not self:FirstCast(_Q) and self:HaveQ(unit) and (self:ShouldQ(unit) or unit.health < self:q2Mob(unit)) then
					self:CastQ2(unit);
				elseif self.Param.WaveClear.W and self.W then
					if self:FirstCast(_W) then
						self:CastW1(unit);
					else
						self:CastW2(unit);
					end
				end
			end
		end
	end
end

function LeeSin:Combo()
	if self.Q and self:FirstCast(_Q) then
		self:CastQ1(self.Target);
	elseif self.Q and not self:FirstCast(_Q) and self:HaveQ(self.Target) and (self:ShouldQ(self.Target) or self.Target.health < self:q2Dmg(self.Target)) then
		self:CastQ2(self.Target);
	elseif self.W then
		if self:FirstCast(_W) then
			self:CastW1(self.Target);
		else
			self:CastW2(self.Target);
		end
	elseif self.E then
		if self:FirstCast(_E) then
			self:CastE1(self.Target);
		else
			self:CastE2(self.Target);
		end
	end
end

function LeeSin:Menu()
	self.Param = scriptConfig("Lee Sin - The play maker", "LeeSin");

	self.Param:addSubMenu("Combo Settings", "Combo");
		self.Param.Combo:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Combo:addParam("W", "Use W :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Combo:addParam("E", "Use E :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Combo:addParam("R", "Use R :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addSubMenu("KillSteal Settings", "KillSteal");
		self.Param.KillSteal:addParam("Use", "Enable KillSteal :", SCRIPT_PARAM_ONOFF, true);
		self.Param.KillSteal:addParam("n1", "", SCRIPT_PARAM_INFO, "");
		self.Param.KillSteal:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, true);
		self.Param.KillSteal:addParam("Q1", "Use Q1 :", SCRIPT_PARAM_ONOFF, true);
		self.Param.KillSteal:addParam("Q2", "Use Q2 :", SCRIPT_PARAM_ONOFF, false);
		self.Param.KillSteal:addParam("Q3", "Use Q3 (Q1 + Q2) :", SCRIPT_PARAM_ONOFF, true);
		self.Param.KillSteal:addParam("E", "Use E :", SCRIPT_PARAM_ONOFF, true);
		self.Param.KillSteal:addParam("R", "Use R :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addSubMenu("JungleClear Settings", "JungleClear");
		self.Param.JungleClear:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, true);
		self.Param.JungleClear:addParam("W", "Use W :", SCRIPT_PARAM_ONOFF, true);
		self.Param.JungleClear:addParam("E", "Use E :", SCRIPT_PARAM_ONOFF, true);
		self.Param.JungleClear:addParam("n1", "", SCRIPT_PARAM_INFO, "");
		self.Param.JungleClear:addParam("Smite", "Use auto smite :", SCRIPT_PARAM_ONOFF, true);
		self.Param.JungleClear:addParam("Mod", "Auto Smite Mode :", SCRIPT_PARAM_LIST, 1, {"Everything", "Epic Only", "Buff Only", "Epic + Buffs", "None"});

	self.Param:addSubMenu("LaneClear Settings", "WaveClear");
		self.Param.WaveClear:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, false);
		self.Param.WaveClear:addParam("W", "Use W :", SCRIPT_PARAM_ONOFF, true);
		self.Param.WaveClear:addParam("E", "Use E :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addSubMenu("Extra Settings", "Extra");
		self.Param.Extra:addSubMenu("Specials Key Settings", "K");
			self.Param.Extra.K:addParam("WardJump", "WardJump Key :", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"));
			self.Param.Extra.K:addParam("Insec", "Insec Key :", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"));
			self.Param.Extra.K:addParam("RFlash", "RFlash Key :", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Y"));
			self.Param.Extra.K:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.K:addParam("Flash", "Use Flash in Insec :", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("P"))
		self.Param.Extra:addSubMenu("", "n1");
		self.Param.Extra:addSubMenu("Auto Buy Settings", "AutoBuy");
			self.Param.Extra.AutoBuy:addParam("Enable", "Enable auto buy :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.AutoBuy:addParam("n0", "", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.AutoBuy:addParam("Machete", "Buy a Machete :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.AutoBuy:addParam("Potion", "Buy a potion :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.AutoBuy:addParam("Trinket", "Buy a Yellow Trinket :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Extra:addSubMenu("Auto Level Spell Settings", "LVL");
			self.Param.Extra.LVL:addParam("Enable", "Use auto LVL spell :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.LVL:addParam("Combo", "Combo :", SCRIPT_PARAM_LIST, 1, {"Q / W / E (Max R/Q/E/W)"});
			self.Param.Extra.LVL:setCallback("Combo", function(SpellCombo) if VIP_USER then if SpellCombo then self:AutoLVLSpellCombo2(); else self:AutoLVLSpellCombo(); end end end);
		self.Param.Extra:addSubMenu("Item Settings", "Items");
			self.Param.Extra.Items:addParam("POT", "Enable auto Potions :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.Items:addParam("POTCombo", "Use only on combo mode :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.Items:addParam("POTHP", "Set an %HP value :", SCRIPT_PARAM_SLICE, 60, 0, 100, 5);
			self.Param.Extra.Items:addParam("n2", "", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.Items:addParam("WARD", "Enable auto ward :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.Items:addParam("WARDCombo", "Use only on combo mode :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.Items:addParam("n3", "", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.Items:addParam("Tiamat", "Use Tiamat :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addSubMenu("Drawings Settings", "Draw");
		self.Param.Draw:addSubMenu("Spells Settings", "Spell");
			self.Param.Draw.Spell:addParam("Q", "Display Q :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Spell:addParam("W", "Display W :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Spell:addParam("E", "Display E :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Spell:addParam("R", "Display R :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Spell:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			self.Param.Draw.Spell:addParam("AA", "Display Auto Attack :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Spell:addParam("Rdmg", "Use R damage percent :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Draw:addSubMenu("General Settings", "General");
			self.Param.Draw.General:addParam("Hitbox", "Display Hitbox :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Draw.General:addParam("Target", "Display Target :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Draw:addSubMenu("Misc Settings", "Misc");
			self.Param.Draw.Misc:addParam("SKIN", "Enable Skin Changer :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Misc:setCallback("SKIN", function(skin) if skin then SetSkin(myHero, self.Param.Draw.Misc.skins-1); else SetSkin(myHero, -1); end end);
			self.Param.Draw.Misc:addParam("skins", "Set a skin :", SCRIPT_PARAM_LIST, 1, {"Classic", "Traditional", "Acolyte", "Dragon Fist", "Muay Thai", "Pool Party", "SKT T1", "Chroma Pack: Black", "Chroma Pack: Blue", "Chroma Pack: Yellow", "Knockout"});
			self.Param.Draw.Misc:setCallback("skins", function(skin) if skin then if self.Param.Draw.Misc.SKIN then SetSkin(myHero, self.Param.Draw.Misc.skins-1); end end end);
		self.Param.Draw:addParam("Enable", "Enable Drawings :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addParam("n1", "", SCRIPT_PARAM_INFO, "");
	self.Param:addParam("Pred", "Prediction :", SCRIPT_PARAM_LIST, 3, {"VPred", "HPred", "FHPred"});
	self.Param:setCallback("Pred", function(Pred)
		if Pred then
			self:Loader();
		else
			self:Loader();
		end
	end);

	enemyMinions = minionManager(MINION_ENEMY, 1300, myHero, MINION_SORT_HEALTH_ASC);
	jungleMinions = minionManager(MINION_JUNGLE, 1300, myHero, MINION_SORT_MAXHEALTH_DEC);
end

function LeeSin:DrawR(unit)
	if unit.dead or not unit.visible then return end
	local Center = GetUnitHPBarPos(unit);
	if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 and unit.visible then
		local rdmg = self:rDmg(unit);
		local off = GetUnitHPBarOffset(unit);
		local y = Center.y + (off.y * 53) + 2;
		local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[unit.charName];
		local x = Center.x + ((xOff or 0) * 140) - 66;
		local dmg = unit.health - rdmg;
		DrawLine(x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 101), y-15, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104), y-15, 50, ARGB(255, 245, 215, 110));
		DrawLine(x + ((unit.health / unit.maxHealth) * 150), y-40, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104), y-40, 2, ARGB(255, 245, 215, 110));
		local rPerc = math.floor(rdmg / unit.health * 100)
		if rPerc < 100 then
			DrawText(""..rPerc.."%", 40, x + ((unit.health / unit.maxHealth) * 155), y-52, 0xFFFFFFFF);
		else
			DrawText("Killable", 40, x + ((unit.health / unit.maxHealth) * 155), y-52, 0xFFFFFFFF);
		end
	end
end

function LeeSin:OnDraw()
	if self.Param.Draw.Enable then
		if self.Param.Draw.Spell.Rdmg and myHero:GetSpellData(_R).level > 0 then
			for _, unit in pairs(GetEnemyHeroes()) do
				self:DrawR(unit);
			end
		end
		if self.Q and self.Param.Draw.Spell.Q then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 1100, 1, 0xFFFFFFFF);
		end
		if self.W and self.Param.Draw.Spell.W then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 700, 1, 0xFFFFFFFF);
		end
		if self.E and self.Param.Draw.Spell.E then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 350, 1, 0xFFFFFFFF);
		end
		if self.R and self.Param.Draw.Spell.R then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 375, 1, 0xFFFFFFFF);
		end
		if self.Param.Draw.Spell.AA then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 1, 0xFFFFFFFF)
		end
		if self.Param.Draw.General.Hitbox then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF);
		end
		if self.Param.Draw.General.Target then
			if self.Target then
				DrawText3D(">> TARGET <<", self.Target.x-100, self.Target.y-50, self.Target.z, 20, 0xFFFFFFFF);
				DrawText(""..self.Target.charName.."", 50, 50, 200, 0xFFFFFFFF);
			end
		end
		if not _G.EloSpikesLoading then
			DrawText(os.date("%A, %B %d %Y - %X - "..GetLatency().." ms"), 15, WINDOW_W/1.5, WINDOW_W/180, 0xFFFFFFFF);
		end
	end
end

function LeeSin:SD()
	local dmgSmite = 0;
	if myHero.level <= 4 then
		dmgSmite = 370 + (myHero.level*20);
	end
	if myHero.level > 4 and myHero.level <= 9 then
		dmgSmite = 330 + (myHero.level*30);
	end
	if myHero.level > 9 and myHero.level <= 14 then
		dmgSmite = 240 + (myHero.level*40);
	end
	if myHero.level > 14 then
		dmgSmite = 100 + (myHero.level*50);
	end
	return dmgSmite
end

function LeeSin:OnWndMsg(msg, key)
	if key == self.Param.Extra.K._param[1].key then
		local ward = self:WardSlot();
		if ward == nil or not self.W or not self:FirstCast(_W) then myHero:MoveTo(mousePos.x, mousePos.z) return end
		local Pos = mousePos;
		if GetDistanceSqr(mousePos) > 360000 then
			Pos = Vector(myHero) + (600 / GetDistance(mousePos)) * (Vector(mousePos) - Vector(myHero));
		end
		if os.clock() < self.Next then myHero:MoveTo(mousePos.x, mousePos.z) return end
		self.Next = os.clock() + 2;
		CastSpell(ward, Pos.x, Pos.z);
		myHero:MoveTo(mousePos.x, mousePos.z);
	end
	if key == self.Param.Extra.K._param[2].key then
		if self.Target ~= nil then
			if not self:FirstCast(_W) and not self.Q and GetDistance(self.Target) < 375 then
				CastSpell(_R)
			end
			if not self:HaveQ(self.Target) and self:FirstCast(_Q) and self.Q then
				self:CastQ1(self.Target);
			elseif self.Q and self:HaveQ(self.Target) and not self:FirstCast(_Q) then 
					self:CastQ2(self.Target);
			end
			if self.Param.Extra.K.Flash and GetDistance(self.Target) < 375 and self.F and self.R then
				self.FirstPos = Vector(myHero) + (Vector(self.Target) - Vector(myHero)):normalized()*(GetDistance(self.Target)+150);
				CastSpell(_R, self.Target);
				DelayAction(function() CastSpell(self.Flash, self.FirstPos.x, self.FirstPos.z); end, .25);
			else
				if GetDistance(self.Target) < 250 and self.W and self:FirstCast(_W) then
					if self.F and self.R and self.Param.Extra.K.Flash then return end
					self.FirstPos = Vector(myHero) + (Vector(self.Target) - Vector(myHero)):normalized()*(GetDistance(self.Target)+150);
					local ward = self:WardSlot();
					if ward == nil then myHero:MoveTo(mousePos.x, mousePos.z) return end
					if os.clock() < self.Next then myHero:MoveTo(mousePos.x, mousePos.z) return end
					self.Next = os.clock() + 2;
					CastSpell(ward, self.FirstPos.x, self.FirstPos.z);
				end
			end
		end
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
	if key == self.Param.Extra.K._param[3].key then
		if self.R and self.F then 
			if self.Target ~= nil and GetDistance(self.Target) < 375 then
				local Pos = Vector(myHero) + (Vector(self.Target) - Vector(myHero)):normalized()*(GetDistance(self.Target)+100);
				CastSpell(_R, self.Target);
				CastSpell(self.Flash, Pos.x, Pos.z);
			end
			myHero:MoveTo(mousePos.x, mousePos.z)
		end
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function LeeSin:OnCreateObj(obj)
	if obj ~= nil and obj.valid and obj.name ~= nil and obj.team == myHero.team then
		if not obj.name:lower():find("ward") then return end
		if (self.Param.Extra.K.WardJump or self.Param.Extra.K.Insec) and self.W and self:FirstCast(_W) then
			local unit = obj;
			CastSpell(_W, unit);
		end
	end
end

function LeeSin:KeyConversion(v)

	local K = {};
	K[8] = 'Back';
	K[9] = 'Tab';
	K[13] = 'Enter';
	K[16] = 'Shift';
	K[17] = 'Ctrl';
	K[18] = 'Alt';
	K[19] = 'Pause';
	K[20] = 'Capslock';
	K[21] ='KanaMode';
	K[23] = 'JunjaMode';
	K[24] = 'FinalMode';
	K[25] = 'HanjaMode';
	K[27] = 'Esc';
	K[28] = 'IMEConvert';
	K[29] = 'IMENonconvert';
	K[30] = 'IMEAceept';
	K[31] = 'IMEModeChange';
	K[32] = 'Space';
	K[33] = 'PageUp';
	K[34] = 'PageDown';
	K[35] = 'End';
	K[36] = 'Home';
	K[37] = 'Left';
	K[38] = 'Up';
	K[39] = 'Right';
	K[40] = 'Down';
	K[44] = 'PrintScreen';
	K[45] = 'Insert';
	K[46] = 'Delete';
	K[48] = '0';
	K[49] = '1';
	K[50] = '2';
	K[51] = '3';
	K[52] = '4';
	K[53] = '5';
	K[54] = '6';
	K[55] = '7';
	K[56] = '8';
	K[57] = '9';
	K[65] = 'A';
	K[66] = 'B';
	K[67] = 'C';
	K[68] = 'D';
	K[69] = 'E';
	K[70] = 'F';
	K[71] = 'G';
	K[72] = 'H';
	K[73] = 'I';
	K[74] = 'J';
	K[75] = 'K';
	K[76] = 'L';
	K[77] = 'M';
	K[78] = 'N';
	K[79] = 'O';
	K[80] = 'P';
	K[81] = 'Q';
	K[82] = 'R';
	K[83] = 'S';
	K[84] = 'T';
	K[85] = 'U';
	K[86] = 'V';
	K[87] = 'W';
	K[88] = 'X';
	K[89] = 'Y';
	K[90] = 'Z';
	K[91] = 'LWin';
	K[92] = 'RWin';
	K[93] = 'Apps';
	K[96] = 'NumPad0';
	K[97] = 'NumPad1';
	K[98] = 'NumPad2';
	K[99] = 'NumPad3';
	K[100] = 'NumPad4';
	K[101] = 'NumPad5';
	K[102] = 'NumPad6';
	K[103] = 'NumPad7';
	K[104] = 'NumPad8';
	K[105] = 'NumPad9';
	K[106] = 'Multiply';
	K[107] = 'Add';
	K[108] = 'Separator';
	K[109] = 'Subtract';
	K[110] = 'Decimal';
	K[111] = 'Divide';
	K[112] = 'F1';
	K[113] = 'F2';
	K[114] = 'F3';
	K[115] = 'F4';
	K[116] = 'F5';
	K[117] = 'F6';
	K[118] = 'F7';
	K[119] = 'F8';
	K[120] = 'F9';
	K[121] = 'F10';
	K[122] = 'F11';
	K[123] = 'F12';
	K[144] = 'NumLock';
	K[145] = 'ScrollLock';
	K[186] = ';';
	K[187] = '=';
	K[188] = ',';
	K[189] = '-';
	K[190] = '.';
	K[191] = '/';
	K[192] = 'Oemtilde';
	K[219] = 'OemOpenBrackets';
	K[220] = 'Oem5';
	K[221] = 'Oem6';
	K[222] = "'";

	return K[v]
end

function LeeSin:FirstCast(x)
	if x == _Q then
		if myHero:GetSpellData(_Q).name:find("One") == 1113 then
			return false
		else
			return true
		end
	end
	return myHero:GetSpellData(x).name:find("One")
end

function LeeSin:ShouldQ(unit)
	local Should = false
	for i = 1, unit.buffCount do
		local buff = unit:getBuff(i)
		if buff.valid and (buff.name:lower() == "blindmonkqone" or buff.name:lower() == "blindmonkqonechaos") and (buff.endT - GetGameTimer()) >= 0.5 then
			Should = true
			break
		end
	end
	return Should
end

function LeeSin:WardSlot()
	local Item = {[2045] = "ItemGhostWard", [2049] = "ItemGhostWard", [3340] = "TrinketTotemLvl1", [2033] = "VisionWard", [3362] = "TrinketTotemLvl4", [3361] = "TrinketTotemLvl3"};
	for k, v in pairs(Item) do
		for SLOT = ITEM_1, ITEM_7 do
			local item = myHero:GetSpellData(SLOT).name;
			if item and item:lower() == Item[k]:lower() and myHero:CanUseSpell(SLOT) == READY then
				return SLOT
			end
		end
	end
end

function LeeSin:HaveQ(unit)
	return TargetHaveBuff("BlindMonkQOne", unit);
end

function LeeSin:Immune(unit)
	for i = 1, unit.buffCount do
		local tBuff = unit:getBuff(i)
		if BuffIsValid(tBuff) then
			if self.buffs[tBuff.name] then
				return true
			end
		end
	end
	return false
end

function LeeSin:Usepot()
	if self.Param.Extra.Items.POTCombo and (self.Mode == "Combo" or self.Mode == "LaneClear") or not self.Param.Extra.Items.POTCombo then
		for SLOT = ITEM_1, ITEM_6 do
			if myHero:GetSpellData(SLOT).name == self.ActualPotData and not InFountain() then
				if myHero:CanUseSpell(SLOT) == READY and (myHero.health * 100) / myHero.maxHealth < self.Param.Extra.Items.POTHP and not InFountain() then
					CastSpell(SLOT);
					self.lastPotion = self.Time;
					self:Alerte("1x "..self.ActualPotName.." => Used.");
				end
			end
		end
	end
end

function LeeSin:Var()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerSmite") then 
		self.Smite = SUMMONER_1;
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerSmite") then 
		self.Smite = SUMMONER_2;
	end
	if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerflash") then 
		self.Flash = SUMMONER_1;
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerflash") then 
		self.Flash = SUMMONER_2;
	end
	if self.Smite then
		AddTickCallback(function()
			self:AutoSmite();
		end);
	end
	self.Skills = {
		Q = {range = 1100, delay = .25, speed = 1750, width = 65, radius = 30};
		Q2 = {range = 1300};
		W = {range = 700};
		E = {range = 350, delay = .25};
		E2 = {range = 500};
		R = {range = 375, distance = 1200};
	};
	self.Ward = {
		["YellowTrinket"] = true,
		["BlueTrinket"] = true,
		["SightWard"] = true,
		["VisionWard"] = true,
		["Poo"] = true,
	};
	self.buffs = {
		["JudicatorIntervention"] = true,
		["UndyingRage"] = true,
		["ZacRebirthReady"] = true,
		["AatroxPassiveDeath"] = true,
		["FerociousHowl"] = true,
		["VladimirSanguinePool"] = true,
		["ChronoRevive"] = true,
		["ChronoShift"] = true,
		["KarthusDeathDefiedBuff"] = true,
		["zhonyasringshield"] = true,
		["lissandrarself"] = true,
		["bansheesveil"] = true,
		["SivirE"] = true,
		["NocturneW"] = true,
		["kindredrnodeathbuff"] = true,
		["meditate"] = true,
	};
	self.JungleSmite = {
		{
			['SRU_RiftHerald17.1.1'] = {true}, ['SRU_Baron12.1.1'] = {true}, ['SRU_Red4.1.1'] = {true}, ['SRU_Blue1.1.1'] = {true}, ['SRU_Blue7.1.1'] = {true}, ['SRU_Red10.1.1'] = {true}, ['SRU_Krug5.1.2'] = {true}, ['SRU_Razorbeak3.1.1'] = {true}, ['Sru_Crab15.1.1'] = {true},  ['SRU_Murkwolf2.1.1'] = {true}, ['SRU_Gromp13.1.1'] = {true}, ['Sru_Crab16.1.1'] = {true}, ['SRU_Gromp14.1.1'] = {true}, ['SRU_Murkwolf8.1.1'] = {true}, ['SRU_Razorbeak9.1.1'] = {true}, ['SRU_Krug11.1.2'] = {true},
		},
		{
			['SRU_RiftHerald17.1.1'] = {true}, ['SRU_Baron12.1.1'] = {true}
		},
		{
			['SRU_Red4.1.1'] = {true}, ['SRU_Blue1.1.1'] = {true}, ['SRU_Blue7.1.1'] = {true}, ['SRU_Red10.1.1'] = {true},
		},
		{
			['SRU_RiftHerald17.1.1'] = {true}, ['SRU_Baron12.1.1'] = {true}, ['SRU_Red4.1.1'] = {true}, ['SRU_Blue1.1.1'] = {true}, ['SRU_Blue7.1.1'] = {true}, ['SRU_Red10.1.1'] = {true},
		},
		{},
	};
	self.Q = false;
	self.W = false;
	self.E = false;
	self.R = false;
	self.T = false;
	self.F = false;
	self.S = false;
	self.Next = 0;
	self.Tiamat = false;
	self.TiamatSlot = ITEM_1;
	self.Last_Item_Check = 0;
	self.Passive = 0;
	self.UnderExhaust = false;
	self.Time = os.clock();
	self.Last_LevelSpell = 0;
	self.lastPotion = 0;
	self.lastQSS = 0;
	self.LastPotCheck = 0;
	self.ActualPotTime = 0;
	self.ActualPotName = nil;
	self.ActualPotData = nil;
	self.Mode = nil;
	self.Target = nil;
end

function LeeSin:qDmg(unit)
	local multi = {50, 80, 110, 140, 170};
	return math.floor(myHero:CalcDamage(unit, multi[myHero:GetSpellData(_Q).level] + myHero.addDamage * .9))
end

function LeeSin:q2Dmg(unit, predlife)
	local predlife = predlife or unit.health;
	local multi = {50, 80, 110, 140, 170};
	return math.floor(myHero:CalcDamage(unit, multi[myHero:GetSpellData(_Q).level] + myHero.addDamage * .9 + ((unit.maxHealth - predlife) * 8 / 100)))
end

function LeeSin:q2Mob(unit)
	local predlife = predlife or unit.health;
	local multi = {50, 80, 110, 140, 170};
	local td = {450, 480, 510, 540, 570};
	local dmg = math.floor(myHero:CalcDamage(unit, multi[myHero:GetSpellData(_Q).level] + myHero.addDamage * .9 + ((unit.maxHealth - predlife) * 8 / 100)));
	if dmg > td[myHero:GetSpellData(_Q).level] then
		dmg = td[myHero:GetSpellData(_Q).level];
	end
	return dmg
end

function LeeSin:q3Dmg(unit)
	local q1 = self:qDmg(unit)
	local q2 = self:q2Dmg(unit, unit.health - q1)
	return q1 + q2
end

function LeeSin:eDmg(unit)
	local multi = {60, 95, 130, 165, 200};
	return math.floor(myHero:CalcMagicDamage(unit, multi[myHero:GetSpellData(_E).level] + myHero.addDamage))
end

function LeeSin:rDmg(unit)
	local multi = {200, 400, 600};
	return math.floor(myHero:CalcDamage(unit, multi[myHero:GetSpellData(_R).level] + myHero.addDamage * 2))
end

function LeeSin:VIPLoader()
	self:AutoLVLSpellCombo();
	self:AutoBuy();
end

function LeeSin:LoadVPred()
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

function LeeSin:LoadHPred()
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

function LeeSin:LoadFHPred()
	if FileExist(LIB_PATH.."FHPrediction.lua") then
		require("FHPrediction");
	else
		self:Alerte("You don't have FHPred!");
		self.Param.Pred = 2;
		self:Loader();
	end
end

function LeeSin:Orbwalker()
	if _G.Reborn_Loaded ~= nil then
	elseif _Pewalk then
	elseif _G.MMA_IsLoaded then
	else
		self:NebelOrb()
	end
end

function LeeSin:NebelOrb()
	local function LoadOrb()
		if not _G.NebelwolfisOrbWalkerLoaded then
			require "Nebelwolfi's Orb Walker"
			NebelwolfisOrbWalkerClass()
		end
	end
	if not FileExist(LIB_PATH.."Nebelwolfi's Orb Walker.lua") then
		DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
			LoadOrb()
		end)
	else
		local f = io.open(LIB_PATH.."Nebelwolfi's Orb Walker.lua")
		f = f:read("*all")
		if f:sub(1,4) == "func" then
			DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
				LoadOrb()
			end)
		else
			LoadOrb()
		end
	end
end

function LeeSin:Update()
	self.version = "0.01";
	self.SCRIPT_NAME = "LeeSin";
	self.UPDATE_HOST = "raw.githubusercontent.com";
	self.UPDATE_PATH = "/IAmPandaBoL/BoL/master/LeeSin%20-%20The%20Play%20Maker.lua".."?rand="..math.random(1,10000);
	self.UPDATE_FILE_PATH = SCRIPT_PATH.._ENV.FILE_NAME;
	self.UPDATE_URL = "https://"..self.UPDATE_HOST..self.UPDATE_PATH;
	self.ServerData = GetWebResult(self.UPDATE_HOST, "/IAmPandaBoL/BoL/master/LeeSin.version");
	if self.ServerData then
		self.ServerVersion = type(tonumber(self.ServerData)) == "number" and tonumber(self.ServerData) or nil;
		if self.ServerVersion then
			if tonumber(self.version) < self.ServerVersion then
				self:Alerte("New version available "..self.ServerVersion);
				self:Alerte(">>Updating, please don't press F9<<");
				DelayAction(function() DownloadFile(self.UPDATE_URL, self.UPDATE_FILE_PATH, function () EloSpikes:Alerte("Successfully updated. ("..self.version.." => "..self.ServerVersion.."), press F9 twice to load the updated version.") end) end, 3);
			else
				self:CustomLoad();
			end
		else
			self:Alerte("Error while downloading version info");
		end
	end
end
