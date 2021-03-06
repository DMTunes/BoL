-- Done this for @Kuzuky <3 <3

function OnLoad()
  
  print("Loaded Skin Changer")
  
	Menu()

	if Param.Draw.Skin.Enable then
		SetSkin(myHero, Param.Draw.Skin.skins -1)
	end
end

function OnUnload()

	if Param.Draw.Skin.Enable then
		SetSkin(myHero, -1)
	end

end

function Menu()

	Param = scriptConfig("SkinChanger", "SkinChanger")

	Param:addSubMenu("Drawing Settings", "Draw")

		--
		if VIP_USER then Param.Draw:addSubMenu("Skin Changer", "Skin") end
			if VIP_USER then Param.Draw.Skin:addParam("Enable", "Enable Skin Changer : ", SCRIPT_PARAM_ONOFF, false)
				Param.Draw.Skin:setCallback("Enable", function (nV)
					if nV then
						SetSkin(myHero, Param.Draw.Skin.skins -1)
					else
						SetSkin(myHero, -1)
					end
				end)
			end				
			if VIP_USER then Param.Draw.Skin:addParam("skins", 'Which Skin :', SCRIPT_PARAM_LIST, 1, skinMeta[myHero.charName])
				Param.Draw.Skin:setCallback("skins", function (nV)
					if nV then
						if Param.Draw.Skin.Enable then
							SetSkin(myHero, Param.Draw.Skin.skins -1)
						end
					end
				end)
			end
end
skinMeta = {
	["Aatrox"] = {"Classic", "Justicar", "Mecha", "Sea Hunter"},
	["Ahri"] = {"Classic", "Dynasty", "Midnight", "Foxfire", "Popstar", "Challenger", "Academy"},
	["Akali"] = {"Classic", "Stinger", "Crimson", "All-star", "Nurse", "Blood Moon", "Silverfang", "Headhunter"},
	["Alistar"] = {"Classic", "Black", "Golden", "Matador", "Longhorn", "Unchained", "Infernal", "Sweeper", "Marauder"},
	["Amumu"] = {"Classic", "Pharaoh", "Vancouver", "Emumu", "Re-Gifted", "Almost-Prom King", "Little Knight", "Sad Robot", "Surprise Party"},
	["Anivia"] = {"Classic", "Team Spirit", "Bird of Prey", "Noxus Hunter", "Hextech", "Blackfrost", "Prehistoric"},
	["Annie"] = {"Classic", "Goth", "Red Riding", "Annie in Wonderland", "Prom Queen", "Frostfire", "Reverse", "FrankenTibbers", "Panda", "Sweetheart"},
	["Ashe"] = {"Classic", "Freljord", "Sherwood Forest", "Woad", "Queen", "Amethyst", "Heartseeker", "Marauder"},
	["Azir"] = {"Classic", "Galactic", "Gravelord"},
	-- B
	["Bard"] = {"Classic", "Elderwood", "Chroma Pack: Marigold", "Chroma Pack: Ivy", "Chroma Pack: Sage"},
	["Blitzcrank"] = {"Classic", "Rusty", "Goalkeeper", "Boom Boom", "Piltover Customs", "Definitely Not", "iBlitzcrank", "Riot", "Chroma Pack: Molten", "Chroma Pack: Cobalt", "Chroma Pack: Gunmetal", "Battle Boss"},
	["Brand"] = {"Classic", "Apocalyptic", "Vandal", "Cryocore", "Zombie", "Spirit Fire"},
	["Braum"] = {"Classic", "Dragonslayer", "El Tigre", "Lionheart"},
	-- C
	["Caitlyn"] = {"Classic", "Resistance", "Sheriff", "Safari", "Arctic Warfare", "Officer", "Headhunter", "Chroma Pack: Pink", "Chroma Pack: Green", "Chroma Pack: Blue","Lunar"},
	["Cassiopeia"] = {"Classic", "Desperada", "Siren", "Mythic", "Jade Fang", "Chroma Pack: Day", "Chroma Pack: Dusk", "Chroma Pack: Night"},
	["Chogath"] = {"Classic", "Nightmare", "Gentleman", "Loch Ness", "Jurassic", "Battlecast Prime", "Prehistoric"},
	["Corki"] = {"Classic", "UFO", "Ice Toboggan", "Red Baron", "Hot Rod", "Urfrider", "Dragonwing", "Fnatic"},
	-- D
	["Darius"] = {"Classic", "Lord", "Bioforge", "Woad King", "Dunkmaster", "Chroma Pack: Black Iron", "Chroma Pack: Bronze", "Chroma Pack: Copper", "Academy"},
	["Diana"] = {"Classic", "Dark Valkyrie", "Lunar Goddess"},
	["DrMundo"] = {"Classic", "Toxic", "Mr. Mundoverse", "Corporate Mundo", "Mundo Mundo", "Executioner Mundo", "Rageborn Mundo", "TPA Mundo", "Pool Party"},
	["Draven"] = {"Classic", "Soul Reaver", "Gladiator", "Primetime", "Pool Party"},
	-- E
	["Ekko"] = {"Classic", "Sandstorm", "Academy"},
	["Elise"] = {"Classic", "Death Blossom", "Victorious", "Blood Moon"},
	["Evelynn"] = {"Classic", "Shadow", "Masquerade", "Tango", "Safecracker"},
	["Ezreal"] = {"Classic", "Nottingham", "Striker", "Frosted", "Explorer", "Pulsefire", "TPA", "Debonair", "Ace of Spades"},
	-- F
	["FiddleSticks"] = {"Classic", "Spectral", "Union Jack", "Bandito", "Pumpkinhead", "Fiddle Me Timbers", "Surprise Party", "Dark Candy", "Risen"},
	["Fiora"] = {"Classic", "Royal Guard", "Nightraven", "Headmistress", "PROJECT"},
	["Fizz"] = {"Classic", "Atlantean", "Tundra", "Fisherman", "Void", "Chroma Pack: Orange", "Chroma Pack: Black", "Chroma Pack: Red", "Cottontail"},
	-- G
	["Galio"] = {"Classic", "Enchanted", "Hextech", "Commando", "Gatekeeper", "Debonair"},
	["Gangplank"] = {"Classic", "Spooky", "Minuteman", "Sailor", "Toy Soldier", "Special Forces", "Sultan", "Captain"},
	["Garen"] = {"Classic", "Sanguine", "Desert Trooper", "Commando", "Dreadknight", "Rugged", "Steel Legion", "Chroma Pack: Garnet", "Chroma Pack: Plum", "Chroma Pack: Ivory", "Rogue Admiral"},
	["Gnar"] = {"Classic", "Dino", "Gentleman"},
	["Gragas"] = {"Classic", "Scuba", "Hillbilly", "Santa", "Gragas, Esq.", "Vandal", "Oktoberfest", "Superfan", "Fnatic", "Caskbreaker"},
	["Graves"] = {"Classic", "Hired Gun", "Jailbreak", "Mafia", "Riot", "Pool Party", "Cutthroat"},
	-- H
	["Hecarim"] = {"Classic", "Blood Knight", "Reaper", "Headless", "Arcade", "Elderwood"},
	["Heimerdinger"] = {"Classic", "Alien Invader", "Blast Zone", "Piltover Customs", "Snowmerdinger", "Hazmat"},
	-- I
	["Illaoi"] = {"Classic", "Void Bringer"},
	["Irelia"] = {"Classic", "Nightblade", "Aviator", "Infiltrator", "Frostblade", "Order of the Lotus"},
	-- J
	["Janna"] = {"Classic", "Tempest", "Hextech", "Frost Queen", "Victorious", "Forecast", "Fnatic"},
	["JarvanIV"] = {"Classic", "Commando", "Dragonslayer", "Darkforge", "Victorious", "Warring Kingdoms", "Fnatic"},
	["Jax"] = {"Classic", "The Mighty", "Vandal", "Angler", "PAX", "Jaximus", "Temple", "Nemesis", "SKT T1", "Chroma Pack: Cream", "Chroma Pack: Amber", "Chroma Pack: Brick", "Warden"},
	["Jayce"] = {"Classic", "Full Metal", "Debonair", "Forsaken"},
	["Jinx"] = {"Classic", "Mafia", "Firecracker", "Slayer"},
	-- K
	["Kalista"] = {"Classic", "Blood Moon", "Championship"},
	["Karma"] = {"Classic", "Sun Goddess", "Sakura", "Traditional", "Order of the Lotus", "Warden"},
	["Karthus"] = {"Classic", "Phantom", "Statue of", "Grim Reaper", "Pentakill", "Fnatic", "Chroma Pack: Burn", "Chroma Pack: Blight", "Chroma Pack: Frostbite"},
	["Kassadin"] = {"Classic", "Festival", "Deep One", "Pre-Void", "Harbinger", "Cosmic Reaver"},
	["Katarina"] = {"Classic", "Mercenary", "Red Card", "Bilgewater", "Kitty Cat", "High Command", "Sandstorm", "Slay Belle", "Warring Kingdoms"},
	["Kayle"] = {"Classic", "Silver", "Viridian", "Unmasked", "Battleborn", "Judgment", "Aether Wing", "Riot"},
	["Kennen"] = {"Classic", "Deadly", "Swamp Master", "Karate", "Kennen M.D.", "Arctic Ops"},
	["Khazix"] = {"Classic", "Mecha", "Guardian of the Sands"},
	["Kindred"] = {"Classic", "Shadowfire"},
	["KogMaw"] = {"Classic", "Caterpillar", "Sonoran", "Monarch", "Reindeer", "Lion Dance", "Deep Sea", "Jurassic", "Battlecast"},
	-- L
	["Leblanc"] = {"Classic", "Wicked", "Prestigious", "Mistletoe", "Ravenborn"},
	["LeeSin"] = {"Classic", "Traditional", "Acolyte", "Dragon Fist", "Muay Thai", "Pool Party", "SKT T1", "Chroma Pack: Black", "Chroma Pack: Blue", "Chroma Pack: Yellow", "Knockout"},
	["Leona"] = {"Classic", "Valkyrie", "Defender", "Iron Solari", "Pool Party", "Chroma Pack: Pink", "Chroma Pack: Azure", "Chroma Pack: Lemon", "PROJECT"},
	["Lissandra"] = {"Classic", "Bloodstone", "Blade Queen"},
	["Lucian"] = {"Classic", "Hired Gun", "Striker", "Chroma Pack: Yellow", "Chroma Pack: Red", "Chroma Pack: Blue", "PROJECT"},
	["Lulu"] = {"Classic", "Bittersweet", "Wicked", "Dragon Trainer", "Winter Wonder", "Pool Party"},
	["Lux"] = {"Classic", "Sorceress", "Spellthief", "Commando", "Imperial", "Steel Legion", "Star Guardian"},
	-- M
	["Malphite"] = {"Classic", "Shamrock", "Coral Reef", "Marble", "Obsidian", "Glacial", "Mecha", "Ironside"},
	["Malzahar"] = {"Classic", "Vizier", "Shadow Prince", "Djinn", "Overlord", "Snow Day"},
	["Maokai"] = {"Classic", "Charred", "Totemic", "Festive", "Haunted", "Goalkeeper"},
	["MasterYi"] = {"Classic", "Assassin", "Chosen", "Ionia", "Samurai Yi", "Headhunter", "Chroma Pack: Gold", "Chroma Pack: Aqua", "Chroma Pack: Crimson", "PROJECT"},
	["MissFortune"] = {"Classic", "Cowgirl", "Waterloo", "Secret Agent", "Candy Cane", "Road Warrior", "Mafia", "Arcade", "Captain"},
	["Mordekaiser"] = {"Classic", "Dragon Knight", "Infernal", "Pentakill", "Lord", "King of Clubs"},
	["Morgana"] = {"Classic", "Exiled", "Sinful Succulence", "Blade Mistress", "Blackthorn", "Ghost Bride", "Victorious", "Chroma Pack: Toxic", "Chroma Pack: Pale", "Chroma Pack: Ebony","Lunar"},
	-- N
	["Nami"] = {"Classic", "Koi", "River Spirit", "Urf", "Chroma Pack: Sunbeam", "Chroma Pack: Smoke", "Chroma Pack: Twilight"},
	["Nasus"] = {"Classic", "Galactic", "Pharaoh", "Dreadknight", "Riot K-9", "Infernal", "Archduke", "Chroma Pack: Burn", "Chroma Pack: Blight", "Chroma Pack: Frostbite",},
	["Nautilus"] = {"Classic", "Abyssal", "Subterranean", "AstroNautilus", "Warden"},
	["Nidalee"] = {"Classic", "Snow Bunny", "Leopard", "French Maid", "Pharaoh", "Bewitching", "Headhunter", "Warring Kingdoms"},
	["Nocturne"] = {"Classic", "Frozen Terror", "Void", "Ravager", "Haunting", "Eternum"},
	["Nunu"] = {"Classic", "Sasquatch", "Workshop", "Grungy", "Nunu Bot", "Demolisher", "TPA", "Zombie"},
	-- O
	["Olaf"] = {"Classic", "Forsaken", "Glacial", "Brolaf", "Pentakill", "Marauder"},
	["Orianna"] = {"Classic", "Gothic", "Sewn Chaos", "Bladecraft", "TPA", "Winter Wonder"},
	-- P
	["Pantheon"] = {"Classic", "Myrmidon", "Ruthless", "Perseus", "Full Metal", "Glaive Warrior", "Dragonslayer", "Slayer"},
	["Poppy"] = {"Classic", "Noxus", "Lollipoppy", "Blacksmith", "Ragdoll", "Battle Regalia", "Scarlet Hammer"},
	-- Q
	["Quinn"] = {"Classic", "Phoenix", "Woad Scout", "Corsair"},
	-- R
	["Rammus"] = {"Classic", "King", "Chrome", "Molten", "Freljord", "Ninja", "Full Metal", "Guardian of the Sands"},
	["Reksai"] = {"Classic", "Eternum", "Pool Party"},
	["Renekton"] = {"Classic", "Galactic", "Outback", "Bloodfury", "Rune Wars", "Scorched Earth", "Pool Party", "Scorched Earth", "Prehistoric"},
	["Rengar"] = {"Classic", "Headhunter", "Night Hunter", "SSW"},
	["Riven"] = {"Classic", "Redeemed", "Crimson Elite", "Battle Bunny", "Championship", "Dragonblade", "Arcade"},
	["Rumble"] = {"Classic", "Rumble in the Jungle", "Bilgerat", "Super Galaxy"},
	["Ryze"] = {"Classic", "Human", "Tribal", "Uncle", "Triumphant", "Professor", "Zombie", "Dark Crystal", "Pirate", "Whitebeard"},
	-- S
	["Sejuani"] = {"Classic", "Sabretusk", "Darkrider", "Traditional", "Bear Cavalry", "Poro Rider"},
	["Shaco"] = {"Classic", "Mad Hatter", "Royal", "Nutcracko", "Workshop", "Asylum", "Masked", "Wild Card"},
	["Shen"] = {"Classic", "Frozen", "Yellow Jacket", "Surgeon", "Blood Moon", "Warlord", "TPA"},
	["Shyvana"] = {"Classic", "Ironscale", "Boneclaw", "Darkflame", "Ice Drake", "Championship"},
	["Singed"] = {"Classic", "Riot Squad", "Hextech", "Surfer", "Mad Scientist", "Augmented", "Snow Day", "SSW"},
	["Sion"] = {"Classic", "Hextech", "Barbarian", "Lumberjack", "Warmonger"},
	["Sivir"] = {"Classic", "Warrior Princess", "Spectacular", "Huntress", "Bandit", "PAX", "Snowstorm", "Warden", "Victorious"},
	["Skarner"] = {"Classic", "Sandscourge", "Earthrune", "Battlecast Alpha", "Guardian of the Sands"},
	["Sona"] = {"Classic", "Muse", "Pentakill", "Silent Night", "Guqin", "Arcade", "DJ"},
	["Soraka"] = {"Classic", "Dryad", "Divine", "Celestine", "Reaper", "Order of the Banana"},
	["Swain"] = {"Classic", "Northern Front", "Bilgewater", "Tyrant"},
	["Syndra"] = {"Classic", "Justicar", "Atlantean", "Queen of Diamonds"},
	-- T
	["TahmKench"] = {"Classic", "Master Chef"},
	["Talon"] = {"Classic", "Renegade", "Crimson Elite", "Dragonblade", "SSW"},
	["Taric"] = {"Classic", "Emerald", "Armor of the Fifth Age", "Bloodstone"},
	["Teemo"] = {"Classic", "Happy Elf", "Recon", "Badger", "Astronaut", "Cottontail", "Super", "Panda", "Omega Squad"},
	["Thresh"] = {"Classic", "Deep Terror", "Championship", "Blood Moon", "SSW"},
	["Tristana"] = {"Classic", "Riot Girl", "Earnest Elf", "Firefighter", "Guerilla", "Buccaneer", "Rocket Girl", "Chroma Pack: Navy", "Chroma Pack: Purple", "Chroma Pack: Orange", "Dragon Trainer"},
	["Trundle"] = {"Classic", "Lil' Slugger", "Junkyard", "Traditional", "Constable"},
	["Tryndamere"] = {"Classic", "Highland", "King", "Viking", "Demonblade", "Sultan", "Warring Kingdoms", "Nightmare"},
	["TwistedFate"] = {"Classic", "PAX", "Jack of Hearts", "The Magnificent", "Tango", "High Noon", "Musketeer", "Underworld", "Red Card", "Cutpurse"},
	["Twitch"] = {"Classic", "Kingpin", "Whistler Village", "Medieval", "Gangster", "Vandal", "Pickpocket", "SSW"},
	-- U
	["Udyr"] = {"Classic", "Black Belt", "Primal", "Spirit Guard", "Definitely Not"},
	["Urgot"] = {"Classic", "Giant Enemy Crabgot", "Butcher", "Battlecast"},
	-- V
	["Varus"] = {"Classic", "Blight Crystal", "Arclight", "Arctic Ops", "Heartseeker", "Swiftbolt"},
	["Vayne"] = {"Classic", "Vindicator", "Aristocrat", "Dragonslayer", "Heartseeker", "SKT T1", "Arclight", "Chroma Pack: Green", "Chroma Pack: Red", "Chroma Pack: Silver"},
	["Veigar"] = {"Classic", "White Mage", "Curling", "Veigar Greybeard", "Leprechaun", "Baron Von", "Superb Villain", "Bad Santa", "Final Boss"},
	["Velkoz"] = {"Classic", "Battlecast", "Arclight"},
	["Vi"] = {"Classic", "Neon Strike", "Officer", "Debonair", "Demon"},
	["Viktor"] = {"Classic", "Full Machine", "Prototype", "Creator"},
	["Vladimir"] = {"Classic", "Count", "Marquis", "Nosferatu", "Vandal", "Blood Lord", "Soulstealer", "Academy"},
	["Volibear"] = {"Classic", "Thunder Lord", "Northern Storm", "Runeguard", "Captain"},
	-- W
	["Warwick"] = {"Classic", "Grey", "Urf the Manatee", "Big Bad", "Tundra Hunter", "Feral", "Firefang", "Hyena", "Marauder"},
	["MonkeyKing"] = {"Classic", "Volcanic", "General", "Jade Dragon", "Underworld","Radiant"},
	-- X
	["Xerath"] = {"Classic", "Runeborn", "Battlecast", "Scorched Earth", "Guardian of the Sands"},
	["XinZhao"] = {"Classic", "Commando", "Imperial", "Viscero", "Winged Hussar", "Warring Kingdoms", "Secret Agent"},
	-- Y
	["Yasuo"] = {"Classic", "High Noon", "PROJECT"},
	["Yorick"] = {"Classic", "Undertaker", "Pentakill"},
	-- Z
	["Zac"] = {"Classic", "Special Weapon", "Pool Party", "Chroma Pack: Orange", "Chroma Pack: Bubblegum", "Chroma Pack: Honey"},
	["Zed"] = {"Classic", "Shockblade", "SKT T1", "PROJECT"},
	["Ziggs"] = {"Classic", "Mad Scientist", "Major", "Pool Party", "Snow Day", "Master Arcanist"},
	["Zilean"] = {"Classic", "Old Saint", "Groovy", "Shurima Desert", "Time Machine", "Blood Moon"},
	["Zyra"] = {"Classic", "Wildfire", "Haunted", "SKT T1"},
}
