class 'MetaBuild';

function MetaBuild:__init()
	self:Alerte("MetaBuild loading..");
	self.Items = {};
	self.Sprite = {};
	self.UseMetabuild = false;
	self:GetData();
	self:GetSprite();
	self.MetaBuild = scriptConfig("  > MetaBuild", "MetaBuild");
	self.MetaBuild:addParam("Enable", "Enable MetaBuild :", SCRIPT_PARAM_ONOFF, true);
	self.MetaBuild:addParam("n0", "", SCRIPT_PARAM_INFO, "");
	self.MetaBuild:addParam("X", "Set X value :", SCRIPT_PARAM_SLICE, 3.2, 0, 5, 0.100);
	self.MetaBuild:addParam("X2", "Set + X(i) value :", SCRIPT_PARAM_SLICE, 125, 0, 250, 10);
	self.MetaBuild:addParam("n1", "", SCRIPT_PARAM_INFO, "");
	self.MetaBuild:addParam("Y", "Set Y value :", SCRIPT_PARAM_SLICE, 30, 2, 160, 2);
	self.MetaBuild:addParam("n2", "", SCRIPT_PARAM_INFO, "");
	self.MetaBuild:addParam("n3", "By spyk & ThisIsDna (<3)", SCRIPT_PARAM_INFO, "");
	AddDrawCallback(function()
		self:OnDraw();
	end);
	AddRemoveBuffCallback(function(unit, buff)
		self:OnRemoveBuff(unit, buff);
	end);
	AddTickCallback(function()
		self:OnTick();
	end);
	if self.Items ~= nil then
		self:Alerte("MetaBuild loaded! ("..myHero.charName..")");
	else
		self:Alerte("Error during loading..? ("..myHero.charName..")");
	end
end

function MetaBuild:Alerte(msg)
	PrintChat("<b><font color=\"#F62459\">></font></b> <font color=\"#FEFEE2\"> "..msg.."</font>");
end

function MetaBuild:Socket(path)
	self.Socket = require("socket").tcp();
	self.Socket:settimeout(5);
	self.Socket:connect("champion.gg", 80);
	self.Socket:send("GET "..path.." HTTP/1.0\r\n"..[[Host: champion.gg
	User-Agent: hDownload
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
	Accept-Language: pl,en-US;q=0.7,en;q=0.3
	Cookie: 720plan=R1726442047; path=/;
	Connection: close
	Cache-Control: max-age=0

	]]);
	local received_data = self.Socket:receive("*a");
	repeat until received_data ~= nil
		self.Socket:close();
		return received_data
end

function MetaBuild:GetSprite()
	if not DirectoryExist(SPRITE_PATH.."MetaBuild") then
		CreateDirectory(SPRITE_PATH.."MetaBuild//");
	end
	local Items = {"1400", "1401", "1402", "1408", "1409", "1410", "1412", "1413", "1414", "1416", "1418", "1419", "2045", "2049", "2301", "2302", "2303", "3001", "3003", "3004", "3006", "3009", "3020", "3022", "3025", "3026", "3027", "3030", "3031", "3033", "3036", "3040", "3041", "3042", "3043", "3046", "3047", "3048", "3050", "3053", "3056", "3060", "3065", "3068", "3069", "3071", "3072", "3074", "3075", "3078", "3083", "3085", "3087", "3089", "3091", "3092", "3094", "3100", "3102", "3110", "3111", "3115", "3116", "3117", "3124", "3135", "3139", "3142", "3143", "3146", "3147", "3151", "3152", "3153", "3157", "3158", "3165", "3174", "3190", "3198", "3222", "3285", "3401", "3504", "3508", "3512", "3742", "3748", "3800", "3812"};
	for _, v in pairs(Items) do
		local l = "MetaBuild\\"..v..".png";
		if FileExist(SPRITE_PATH..l) then
			self.Sprite[v] = createSprite(l);
		else
			DownloadFile("https://raw.githubusercontent.com\\spyk1\\BoL\\master\\MetaBuild\\item\\"..v..".png", SPRITE_PATH.."MetaBuild\\"..v..".png", function() 
				self:Alerte("Downloaded Sprite : "..v..".png");
				self.Sprite[v] = createSprite(l);
			end);
		end
	end
end

function MetaBuild:GetData()
	local data = self:Socket("/champion/"..myHero.charName);
	local data2 = data:find("Most Frequent Core Build")+58
	local real_data = data:sub(data2)
	local i = 0;
	local EveryItems = string.gsub(real_data, '/img/item/[0-9][0-9][0-9][0-9].png', function(x)
		if i == 6 then return end
		i = i + 1;
		self.Items[i] = x:match("[0-9][0-9][0-9][0-9]");
	end);
end

function MetaBuild:OnDraw()
	if self.MetaBuild.Enable and self.UseMetabuild then
		if self.Items == nil then return end
		for i = 1, 6 do
			self.Sprite[self.Items[i]]:Draw(WINDOW_W/self.MetaBuild.X+(i*self.MetaBuild.X2), WINDOW_W/self.MetaBuild.Y, 255);
		end
	end
end

function MetaBuild:OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff.name == "recall" and InFountain() and self.MetaBuild.Enable then
		self.UseMetabuild = true;
	end
end

function MetaBuild:OnTick()
	if self.UseMetabuild == true and not InFountain() then
		self.UseMetabuild = false;
	end
end

function Update()
	local version = "0.01";
	local author = "spyk";
	local SCRIPT_NAME = "EloSpikes";
	local UPDATE_HOST = "raw.githubusercontent.com";
	local UPDATE_PATH = "/spyk1/BoL/master/MetaBuild/MetaBuild.lua".."?rand="..math.random(1,10000);
	local UPDATE_FILE_PATH = SCRIPT_PATH.._ENV.FILE_NAME;
	local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH;
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/MetaBuild/MetaBuild.version");
	if ServerData then
		local ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil;
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				MetaBuild:Alerte("New version available "..ServerVersion);
				MetaBuild:Alerte(">>Updating, please don't press F9<<");
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () MetaBuild:Alerte("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3);
			else
			   MetaBuild();
			end
		else
			MetaBuild:Alerte("Error while downloading version info");
		end
	end
end

Update();
