
CopClickerTweakData = CopClickerTweakData or class()

function CopClickerTweakData:init( tweak_data )

	self.gui_tabs = {}
	self.gui_cash_multiplier = 100

	self:init_enemies()
	self:init_enemy_prefixes()

	self:init_weapons()
	self:init_crew()
	self:init_masks()

end

function CopClickerTweakData:init_enemies()

	self.enemies = {}
	self.enemy_limits = {}

	self.enemies.security = {
		name = "Security Guard",
		health = 2,
		reward = 1,
		damage = 1
	}

	self.enemies.cop = {
		name = "Beat Cop",
		health = 2,
		reward = 1,
		damage = 1
	}

	self.enemies.swat = {
		name = "Police SWAT",
		health = 5,
		reward = 2,
		damage = 2
	}

	self.enemies.heavy_swat = {
		name = "Police Heavy SWAT",
		health = 8,
		reward = 3,
		damage = 2
	}

	self.enemies.hrt = {
		name = "Hostage Rescue Unit",
		health = 6,
		reward = 2,
		damage = 5
	}

	self:init_specials()

end

function CopClickerTweakData:init_specials()

	self.enemies.bulldozer = {
		name = "Bulldozer",
		health = 40,
		reward = 20,
		damage = 8,
		special = true
	}
	self.enemy_limits.bulldozer = 4

	self.enemies.shield = {
		name = "Shield",
		health = 4,
		armor = 10,
		reward = 5,
		damage = 1,
		special = true
	}
	self.enemy_limits.shield = 4

	self.enemies.taser = {
		name = "Taser",
		health = 8,
		reward = 8,
		damage = 2,
		special = true
	}
	self.enemy_limits.taser = 2

	self.enemies.cloaker = {
		name = "Cloaker",
		health = 6,
		reward = 5,
		damage = 1,
		special = true
	}
	self.enemy_limits.cloaker = 2

end

function CopClickerTweakData:init_enemy_prefixes()

	self.prefixes = {}

	self.prefixes.none = {
		weight = 1000
	}

	self.prefixes.weak = {
		weight = 10,
		prefix = "Weak ",
		health = function( val ) return math.max(math.ceil(val * 0.66), 1) end,
		reward = function( val ) return math.ceil(val * 1.1) end
	}

	self.prefixes.buff = {
		weight = 10,
		prefix = "Buff ",
		health = function( val ) return math.ceil(val * 1.5) end,
		reward = function( val ) return math.ceil(val * 1.1) end
	}

	self.prefixes.trained = {
		weight = 10,
		prefix = "Well-Trained ",
		damage = function( val ) return math.ceil(val * 1.5) end,
		reward = function( val ) return math.ceil(val * 1.1) end
	}

	self.prefixes.armored_light = {
		weight = 10,
		prefix = "Lightly-Armored ",
		armor = function( val ) return (val or 0) + 5 end,
		reward = function( val ) return math.ceil(val * 1.1) end
	}

	self.prefixes.armored_heavy = {
		weight = 5,
		prefix = "Heavily-Armored ",
		armor = function( val ) return (val or 0) + 20 end,
		reward = function( val ) return math.ceil(val * 1.3) end
	}

	self.prefixes.wealthy = {
		weight = 1,
		prefix = "Wealthy ",
		reward = function( val ) return math.round(val * 4) end
	}

end

function CopClickerTweakData:init_weapons()

	table.insert( self.gui_tabs, {
		text = "Weapons",
		populate = { "weapons", "weapons_list" }
	} )

	self.starting_weapon = "glock17"

	self.weapons = {}
	self.weapons_list = {}

	self.weapons.glock17 = {
		name = "Chimano 88",
		desc = "Awards $income; per cop clicked.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/glock_17",
		image_num = 10,
		income = function( level ) return level * 1 end,
		cost = function( level ) return 15 * math.pow(1.15, level) end,
		sounds = {
			fire = "g17_fire",
			dryfire = "secondary_dryfire"
		}
	}
	table.insert( self.weapons_list, "glock17" )

	self.weapons.b92 = {
		name = "Bernetti 9",
		desc = "Awards $income; per cop clicked.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/b92fs",
		image_num = 10,
		income = function( level ) return level * 5 end,
		cost = function( level ) return 100 * math.pow(1.15, level) end,
		sounds = {
			fire = "beretta_fire",
			dryfire = "secondary_dryfire"
		}
	}
	table.insert( self.weapons_list, "b92" )

	self.weapons.m1911 = {
		name = "Croskill",
		desc = "Awards $income; per cop clicked.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/colt_1911",
		image_num = 10,
		income = function( level ) return level * 10 end,
		cost = function( level ) return 500 * math.pow(1.07, level) end,
		sounds = {
			fire = "c45_fire",
			dryfire = "secondary_dryfire"
		}
	}
	table.insert( self.weapons_list, "m1911" )

	self.weapons.deagle = {
		name = "Deagle",
		desc = "Awards $income; per cop clicked.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/deagle",
		image_num = 10,
		income = function( level ) return level * 60 end,
		cost = function( level ) return 3000 * math.pow(1.15, level) end,
		sounds = {
			fire = "deagle_fire",
			dryfire = "secondary_dryfire"
		}
	}
	table.insert( self.weapons_list, "deagle" )

	self.weapons.p90 = {
		name = "Kobus 90",
		desc = "Awards $income; per cop clicked.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/p90",
		image_num = 10,
		income = function( level ) return level * 180 end,
		cost = function( level ) return 50000 * math.pow(1.12, level) end,
		sounds = {
			fire = "p90_fire_single",
			dryfire = "secondary_dryfire"
		}
	}
	table.insert( self.weapons_list, "p90" )

	self.weapons.vector = {
		name = "Kross Vertex",
		desc = "Awards $income; per cop clicked.",
		icon = "guis/dlcs/turtles/textures/pd2/blackmarket/icons/weapons/polymer",
		image_num = 10,
		income = function( level ) return level * 900 end,
		cost = function( level ) return 300000 * math.pow(1.1, level) end,
		sounds = {
			fire = "polymer_fire_single",
			dryfire = "secondary_dryfire"
		}
	}
	table.insert( self.weapons_list, "vector" )

	self.weapons.locomotive = {
		name = "Locomotive",
		desc = "Awards $income; per cop clicked.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/serbu",
		image_num = 10,
		income = function( level ) return level * 3000 end,
		cost = function( level ) return 1000000 * math.pow(1.3, level) end,
		sounds = {
			fire = "serbu_fire",
			dryfire = "shotgun_dryfire"
		}
	}
	table.insert( self.weapons_list, "locomotive" )

end

function CopClickerTweakData:init_crew()

	table.insert( self.gui_tabs, {
		text = "Crew",
		populate = { "crew", "crew_list" }
	} )

	self.crew = {}
	self.crew_list = {}

	self.crew.henchman = {
		name = "Henchmen",
		desc = "Automatically clicks a cop every few seconds.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/deagle",
		income = function( level ) return 1 * level end,
		cost = function( level ) return 5000 * math.pow(4, level) end,
		max_level = 4,
	}
	table.insert( self.crew_list, "henchman" )

	self.crew.henchman_weapon = {
		name = "Better Henchmen Weapons",
		desc = "Henchmen earn $income; more per cop clicked.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/deagle",
		income = function( level ) return 1 * level end,
		cost = function( level ) return 1000 * math.pow(1.2, level) end,
		requires = "henchman",
	}
	table.insert( self.crew_list, "henchman_weapon" )

	self.crew.henchman_speed = {
		name = "Henchmen Training",
		desc = "Henchmen click another cop $speed; faster.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/deagle",
		speed = function( level ) return math.pow( math.log(level) * 2, 2 ) end,
		cost = function( level ) return 5000 * math.pow(4, level) end,
		requires = "henchman",
	}
	table.insert( self.crew_list, "henchman_speed" )

	self.crew.infamy = {
		name = "Infamy",
		desc = "Reset your cash and weapons, but earn $income;% more income.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/deagle",
		income = function( level ) return 25 * level end,
		cost = function( level ) return 200000000 * math.pow(2, level) end,
		callback = "clbk_upgrade_infamy",
	}
	table.insert( self.crew_list, "infamy" )

end

function CopClickerTweakData:init_masks()

	table.insert( self.gui_tabs, {
		text = "Masks",
		populate = { "masks", "masks_list" }
	} )

	self.masks = {}
	self.masks_list = {}

	self.masks.infamy_1 = {
		name = "The Heat",
		desc = "Awarded for reaching Infamy I.",
		icon = "guis/textures/pd2/blackmarket/icons/weapons/deagle",
	}
	table.insert( self.masks_list, "infamy_1" )

end
