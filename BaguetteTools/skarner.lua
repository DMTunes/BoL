if myHero.charName ~= "Skarner" then return end

local max = math.max

function OnLoad()
	Skarner();
end

class 'Skarner';

function Skarner:__init()
	self:Alerte("Foret Skarner - by spyk, loading..")
	self:Lib();
	self:CustomLoad();
end

function Skarner:Alerte(msg)
	PrintChat("<b><font color=\"#26A65B\">></font></b> <font color=\"#FEFEE2\"> " .. msg .. "</font>");
end

function Skarner:CustomLoad()
	self.Target = nil;
	self.antispam = os.clock();
	self.Timer = 0;
	jungle = minionManager(MINION_JUNGLE, 1500, myHero, MINION_SORT_DIST_ASC);
	self.Mode = "None";
	self.UseSmite = true;
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerSmite") then 
		self.SmiteSlot = SUMMONER_1 
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerSmite") then 
		self.SmiteSlot = SUMMONER_2 
	end
	self.ToS = {
		['SRU_RiftHerald17.1.1'] = {true}, -- Blue | Haut
		['SRU_Baron12.1.1'] = {true}, -- Blue | Haut
		['SRU_Red4.1.1'] = {true}, -- Blue | Bas
		['SRU_Blue1.1.1'] = {true}, -- Blue | Haut
		['SRU_Blue7.1.1'] = {true}, -- Red | Bas
		['SRU_Red10.1.1'] = {true} -- Red | Haut
	}
	AddDrawCallback(function()
		self:OnDraw();
	end);
	AddMsgCallback(function(msg, key)
		if key == 84 and self.antispam < os.clock() then
			self.antispam = os.clock() + .1;
			if self.UseSmite then
				self.UseSmite = false;
			else
				self.UseSmite = true;
			end
		end
	end);
	AddTickCallback(function()
		self.Target = self:GetTarget();
		self:Smite();
		self:CurrentMode();
		self:Modes();
	end);
	AddProcessSpellCallback(function(unit, spell)
		self:OnProcessSpell(unit, spell);
	end);
end

function Skarner:OnProcessSpell(unit, spell)
	if unit and unit.isMe then
		if spell.name == "SkarnerImpale" then
			self.Timer = os.clock() + 1.75;
		end
	end
end

function Skarner:OnDraw()
	if self.UseSmite then
		DrawText3D("USE SMITE", myHero.x + 125, myHero.y + 85, myHero.z + 155, 30, ARGB(255,250,250,250), 0);
	end
	if self.Timer > os.clock() then
		DrawText(""..math.round(self.Timer - os.clock(), 2).."", 150, WINDOW_W/2.3, WINDOW_H/4, 0xFFFFFFFF);
	end
end

function Skarner:Smite()
	if not self.UseSmite then return end
	if self.SmiteSlot == nil then return end
	if myHero:CanUseSpell(self.SmiteSlot) == READY then
		jungle:update();
		for i, unit in pairs(jungle.objects) do
			if unit ~= nil and ValidTarget(unit) and GetDistanceSqr(unit) < 250000 then
				if unit.health <= self:SmiteDmg() then
					if self.ToS[unit.name] or unit.charName:lower():find("dragon") then
						CastSpell(self.SmiteSlot, unit);
					end
				end
			end
		end
	end
end

function Skarner:SmiteDmg()
	return max(20 * myHero.level + 370, 30 * myHero.level + 330, 40 * myHero.level + 240, 50 * myHero.level + 100)
end

function Skarner:Modes()
	if self.Mode == "Combo" then
		self:Combo();
	elseif self.Mode == "Harass" then
		return
	elseif self.Mode == "LaneClear" then
		self:Clear();
	elseif self.Mode == "LastHit" then
		return
	else
		return
	end
end

function Skarner:Combo()
	if self.Target ~= nil then
		if GetDistanceSqr(self.Target) < 1000000 then
			if myHero:CanUseSpell(_E) == READY then
				local Position, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayLine", delay = .25, range = 1000, speed = 1500, width = 70}), self.Target, myHero);
				if HitChance > 0 then
					CastSpell(_E, Position.x, Position.z);
				end
			end
			if myHero:CanUseSpell(_Q) == READY then 
				for _, unit in pairs(GetEnemyHeroes()) do
					if unit.visible and not unit.dead and GetDistanceSqr(unit) < 122500 then
						CastSpell(_Q);
					end
				end
			end
			if myHero:CanUseSpell(_W) == READY then
				if math.min(GetDistance(mousePos), GetDistance(self.Target)) < 400 then
					CastSpell(_W);
				end
			end
		end
	end
end

function Skarner:Clear()
	jungle:update();
	for i, unit in pairs(jungle.objects) do
		if unit ~= nil and ValidTarget(unit) and GetDistanceSqr(unit) < 122500 then
			if myHero:CanUseSpell(_Q) == READY then
				CastSpell(_Q);
			end
			if 100 * myHero.health / myHero.maxHealth < 90 then
				CastSpell(_W);
			end
		end
	end
end

function Skarner:GetTarget()
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

function Skarner:CurrentMode()
    if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
        if _G.AutoCarry.Keys.AutoCarry then 
            if self.Mode ~= "Combo" then
                self.Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G.AutoCarry.Keys.MixedMode then 
            if self.Mode ~= "Harass" then
                self.Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G.AutoCarry.Keys.LaneClear then 
            if self.Mode ~= "Harass" then
                self.Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        elseif _G.AutoCarry.Keys.LastHit then
            if self.Mode ~= "LastHit" then
                self.Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        else
            if self.Mode ~= "None" then
                self.Mode = "None";
                self:PermaShow("None");
            end
        end

    elseif _G.MMA_IsLoaded then

        if _G.MMA_IsOrbwalking then 
            if self.Mode ~= "Combo" then
                self.Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G.MMA_IsDualCarrying then 
            if self.Mode ~= "Harass" then
                self.Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G.MMA_IsLaneClearing then 
            if self.Mode ~= "LaneClear" then
                self.Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        elseif _G.MMA_IsLastHitting then
            if self.Mode ~= "LastHit" then
                self.Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        else
            if self.Mode ~= "None" then
                self.Mode = "None";
                self:PermaShow("None");
            end
        end

    elseif _Pewalk then

        if _G._Pewalk.GetActiveMode().Carry then 
            if self.Mode ~= "Combo" then
                self.Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G._Pewalk.GetActiveMode().Mixed then 
            if self.Mode ~= "Harass" then
                self.Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G._Pewalk.GetActiveMode().LaneClear then
            if self.Mode ~= "LaneClear" then
                self.Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        elseif _G._Pewalk.GetActiveMode().Farm then 
            if self.Mode ~= "LastHit" then
                self.Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        else
            if self.Mode ~= "None" then
                self.Mode = "None";
                self:PermaShow("None");
            end
        end

    elseif _G.NebelwolfisOrbWalkerLoaded then

        if _G.NebelwolfisOrbWalker.Config.k.Combo then
            if self.Mode ~= "Combo" then
                self.Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G.NebelwolfisOrbWalker.Config.k.Harass then
            if self.Mode ~= "Harass" then
                self.Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G.NebelwolfisOrbWalker.Config.k.LastHit then
            if self.Mode ~= "LastHit" then
                self.Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        elseif _G.NebelwolfisOrbWalker.Config.k.LaneClear then
            if self.Mode ~= "LaneClear" then
                self.Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        else
            if self.Mode ~= "None" then
                self.Mode = "None";
                self:PermaShow("None");
            end
        end
    end
end

function Skarner:Lib()
	local LibPath = LIB_PATH.."SpikeLib.lua"
	if not FileExist(LibPath) then
		local Host = "raw.githubusercontent.com";
		local Path = "/spyk1/BoL/master/bundle/SpikeLib.lua".."?rand="..math.random(1,10000);
		self:Alerte("Libs not found!");
		DownloadFile("https://"..Host..Path, LibPath, function()  end);
		DelayAction(function() 
			require("SpikeLib") 
		end, 5);
	else
		require("SpikeLib");
	end
	if FileExist(LIB_PATH .. "/HPrediction.lua") then
		require("HPrediction");
		HPred = HPrediction();
		UseHP = true;
	else
		local Host = "raw.githubusercontent.com";
		local Path = "/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua".."?rand="..random(1,10000);
		EloSpikes:Alerte("HPred not found, downloading..");
		DownloadFile("https://"..Host..Path, LibPath, function ()  end);
		DelayAction(function () require("HPrediction") end, 5);
	end
end

function Skarner:PermaShow(p)
    CustomPermaShow("                         - Foret | Skarner - ", nil, true, nil, nil, nil, 0);
    CustomPermaShow("Current Mode :", ""..p, true, nil, nil, nil, 1);
    CustomPermaShow("", "", true, nil, nil, nil, 2);
    CustomPermaShow("By spyk ", " - 0.1", true, nil, nil, nil, 180);
end
