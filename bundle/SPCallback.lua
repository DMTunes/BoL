class "SPCallback";

function SPCallback:__init()
	self:Var();
	AddProcessSpellCallback(function(unit, spell)
		self:OnProcessSpell(unit, spell);
	end);
	AddApplyBuffCallback(function(source, unit, buff)
		self:ApplyBuff(source, unit, buff);
	end);
	AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance) 
		self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) 
	end);
	OnDashCast, InterruptableCast, AntiGapCloserCast, ImmobileCast = nil;
end

function SPCallback:OnNewPath(unit, startPos, endPos, isDash, dashSpeed ,dashGravity, dashDistance)
	if isDash and OnDashCast and unit.team ~= myHero.team then
		local dash = {};
		if unit.type == myHero.type then
			dash.unit = unit;
			dash.startPos = startPos;
			dash.endPos = endPos;
			dash.speed = dashSpeed;
			dash.startT = os.clock() - GetLatency() / 2000;
			dash.endT = dash.startT + (GetDistance(startPos, endPos) / dashSpeed);
		end
		OnDashCast(dash)
	end
end

function SPCallback:ApplyBuff(unit, t, buff)
	if unit and unit.valid and unit.type == myHero.type and unit.team ~= myHero.team and ImmobileCast and GetDistance(unit) < 1500 then
		if buff.type == 5 or buff.type == 11 or buff.type == 24 or buff.type == 29 then
			ImmobileCast(unit, buff);
		end
		if self.ImmobileBuff[buff.name:lower()] then
			ImmobileCast(unit, buff);
		end
	end
end

function SPCallback:OnProcessSpell(unit, spell)
	if unit and unit.valid and unit.type == myHero.type and unit.team ~= myHero.team and spell and spell.name and GetDistance(unit) < 1500 then
		if InterruptableCast then
			for k, v in ipairs(self.InterruptableSpell) do
				if spell.name:lower() == self.InterruptableSpell[k].name then
					InterruptableCast(unit, spell);
				end
			end
		end
		if ImmobileCast then
			for k, v in ipairs(self.ImmobileSpell) do 
				if spell.name:lower() == self.ImmobileSpell[k].name then
					ImmobileCast(unit, spell);
				end
			end
		end
		if AntiGapCloserCast then
			for k, v in ipairs(self.AntiGapCloserSpell) do
				if spell.name:lower() == self.AntiGapCloserSpell[k].name then
					AntiGapCloserCast(unit, spell);
				end
			end
		end
	end
end

function SPCallback:OnDash(func)
	assert(func and type(func) == "function" and OnDashCast == nil, "Invalid OnDashCallback");
	OnDashCast = func;
end

function SPCallback:Interruptable(func)
	assert(func and type(func) == "function" and InterruptableCast == nil, "Invalid InterruptableCallback");
	InterruptableCast = func;
end

function SPCallback:AntiGapCloser(func)
	assert(func and type(func) == "function" and AntiGapCloserCast == nil, "Invalid AntiGapCloserCallback");
	AntiGapCloserCast = func;
end

function SPCallback:Immobile(func)
	assert(func and type(func) == "function" and AntiGapCloserCast == nil, "Invalid ImmobileCallback");
	ImmobileCast = func;
end

function SPCallback:v()
	return "26022017"
end

function SPCallback:Var()
	self.OnDashSpell = {
		{name = "ahritumble", duration = .25}, -- Ahri's r
		{name = "akalishadowdance", duration = .25}, -- Akali r
		{name = "headbutt", duration = .25}, -- Alistar w
		{name = "caitlynentrapment", duration = .25}, -- Caitlyn e
		{name = "carpetbomb", duration = .25}, -- Corki w
		{name = "dianateleport", duration = .25}, -- Diana r
		{name = "fizzpiercingstrike", duration = .25}, -- Fizz q
		{name = "fizzjump", duration = .25}, -- Fizz e
		{name = "gragasbodyslam", duration = .25}, -- Gragas e
		{name = "gravesmove", duration = .25}, -- Graves e
		{name = "ireliagatotsu", duration = .25}, -- Irelia q
		{name = "jarvanivdragonstrike", duration = .25}, -- Jarvan q
		{name = "jaxleapstrike", duration = .25}, -- Jax q
		{name = "khazixe", duration = .25}, -- Khazix e
		{name = "leblancslide", duration = .25}, -- Leblanc w
		{name = "leblancslidem", duration = .25}, -- Leblanc w (r)
		{name = "blindmonkqtwo", duration = .25}, -- Lee sin q
		{name = "blindmonkwone", duration = .25}, -- Lee sin w
		{name = "luciane", duration = .25}, -- Lucian e
		{name = "maokaiunstablegrowth", duration = .25}, -- Maokai w
		{name = "nocturneparanoia2", duration = .25}, -- Nocturne r
		{name = "pantheon_leapbash", duration = .25}, -- Pantheon e
		{name = "renektonsliceanddice", duration = .25}, -- Renekton e
		{name = "riventricleave", duration = .25}, -- Riven q
		{name = "rivenfeint", duration = .25}, -- Riven e
		{name = "sejuaniarcticassault", duration = .25}, -- Sejuani q
		{name = "shenshadowdash", duration = .25}, -- Shen e
		{name = "shyvanatransformcast", duration = .25}, -- Shyvana r
		{name = "rocketjump", duration = .25}, -- Tristana w
		{name = "slashcast", duration = .25}, -- Tryndamere e
		{name = "vaynetumble", duration = .25}, -- Vayne q
		{name = "viq", duration = .25}, -- Vi q
		{name = "monkeykingnimbus", duration = .25}, -- Wukong q
		{name = "xenzhaosweep", duration = .25}, -- Xin xhao q
		{name = "yasuodashwrapper", duration = .25}, -- Yasuo e
	};
	self.ImmobileSpell = {
		{name = "katarinar", duration = 1}, -- Katarina R
		{name = "drain", duration = 1}, -- Fiddle W
		{name = "crowstorm", duration = 1}, --Fiddle R
		{name = "consume", duration = .5}, -- Nunu Q
		{name = "absolutezero", duration = 1}, -- Nunu R
		--{name = "rocketgrab", duration = .5}, -- Blitzcrank Q
		{name = "staticfield", duration = .5}, -- Blitzcrank R
		{name = "cassiopeiapetrifyinggaze", duration = .5}, -- Cassio's R
		{name = "ezrealtrueshotbarrage", duration = 1}, -- Ezreal's R
		{name = "galioidolofdurand", duration = 1}, -- Ezreal's R
		{name = "luxmalicecannon", duration = 1}, -- Lux R
		{name = "reapthewhirlwind", duration = 1}, -- Jannas R
		{name = "jinxw", duration = .6}, -- JinxW
		{name = "jinxr", duration = .6}, -- JinxR
		{name = "missfortunebullettime", duration = 1}, -- MissFortuneR
		{name = "shenstandunited", duration = 1}, -- ShenR
		{name = "threshe", duration = .4}, -- ThreshE
		--{name = "threshrpenta", duration = .75}, -- ThreshR
		{name = "infiniteduress", duration = 1}, -- Warwick R
		{name = "meditate", duration = 1}, -- Yi W
		{name = "summonerteleport", duration = 4.5}, -- Teleportation
	};
	self.InterruptableSpell = {
		{name = "katarinar", duration = 1}, -- Katarina R
		{name = "galioidolofdurand", duration = 1}, -- Galio R
		{name = "crowstorm", duration = 1}, -- Fiddle R
		{name = "drain", duration = 1}, -- Fiddle W
		{name = "absolutezero", duration = 1}, -- Nunu R
		{name = "shenstandunited", duration = 1}, -- Shen R
		{name = "urgotswap2", duration = 1}, -- Urgot R
		{name = "alzaharnethergrasp", duration = 2.5}, -- Malzahar R
		{name = "fallenone", duration = 1.5}, -- Karthus R
		{name = "pantheon_grandskyfall_jump", duration = 1.8}, -- Pantheon R
		{name = "varusq", duration = 1}, -- Varus Q
		{name = "caitlynaceintthehole", duration = 1}, -- Caitlyn R
		{name = "missfortunebullettime", duration = 2.5}, -- MissFortune R
		{name = "infiniteduress", duration = 2}, -- Warwick R
		{name = "lucianr", duration = 2}, -- Lucian R
		{name = "jhinr", duration = 2.5}, -- Jhin R
	};
	self.AntiGapCloserSpell = {
		{name = "akalidhadowdance"};
		{name = "headbutt"};
		{name = "dianateleport"};
		{name = "ireliagatotsu"};
		{name = "jaxleapstrike"};
		{name = "jaycetotheskies"};
		{name = "maokaiunstablegrowth"};
		{name = "monkeykingnimbus"};
		{name = "pantheon_leapbash"};
		{name = "poppyheroiccharge"};
		{name = "quinne"};
		{name = "xenzhaosweep"};
		{name = "blindmonkqtwo"};
		{name = "fizzpiercingstrike"};
		{name = "rengarleap"};
		{name = "yasuodashwrapper"};
		{name = "aatroxq"};
		{name = "gragase"};
		{name = "gravesmove"};
		{name = "hecarimult"};
		{name = "jarvanivdragonstrike"};
		{name = "jarvanivcataclysm"};
		{name = "khazixe"};
		{name = "khazixelong"};
		{name = "leblancslidem"};
		{name = "leblancslide"};
		{name = "leonazenithblade"};
		{name = "ufslash"};
		{name = "renektonsliceanddice"};
		{name = "sejuaniarcticassault"};
		{name = "shenshadowdash"};
		{name = "rocketjump"};
		{name = "slashcast"};
	};
	self.ImmobileBuff = {
		['aatroxpassivedeath'] = true,
		['rebirth'] = true,
		['bardrstasis'] = true,
		['lissandrarself'] = true,
		['pantheonesound'] = true,
		['pantheonrjump'] = true,
		['summonerteleport'] = true,
		['zhonyasringshield'] = true,
		['galioidolofdurand'] = true,
		['missfortunebulletsound'] = true,
		['alzaharnethergraspsound'] = true,
		['infiniteduresssound'] = true,
		['velkozr'] = true,
		['reapthewhirlwind'] = true,
		['katarinarsound'] = true,
		['fearmonger_marker'] = true,
		['absolutezero'] = true,
		['meditate'] = true,
		['shenstandunited'] = true,
	};
end
