
CopClickerManager = CopClickerManager or class()

function CopClickerManager:init()

	self._weapons = {}
	self._money = self:get_weapon_cost( tweak_data.cop_clicker.starting_weapon )
	
	self._max_health = 100
	self._health = self._max_health
	self._max_armor = 10
	self._armor = self._max_armor

	self._current_enemy = nil
	self._enemies = {
		"cop",
		"cop",
		"cop",
		"cop",
		"cop",
		"cop",
		"cop",
		"cop",
		"cop",
		"cop",
	}
	self._wave = 1
	self._waves_remaining = 4

end

function CopClickerManager:enemies()
	return self._enemies
end

function CopClickerManager:enemies_remaining()
	return #self._enemies
end

function CopClickerManager:wave()
	return self._wave
end

function CopClickerManager:waves_remaining()
	return self._waves_remaining
end

function CopClickerManager:current_enemy()
	return self._current_enemy
end

function CopClickerManager:player_money()
	return self._money
end

function CopClickerManager:player_weapons()
	return self._weapons
end

function CopClickerManager:player_weapon( wep_id )
	for id, weapon in pairs( self:player_weapons() ) do
		if wep_id == id then
			return weapon
		end
	end
end

function CopClickerManager:player_armor()
	return self._armor, self._max_armor
end

function CopClickerManager:player_health()
	return self._health, self._max_health
end

--------------------------------------------------------------------------------

function CopClickerManager:register_gui( gui )
	self._gui = gui
end

function CopClickerManager:gui()
	return self._gui
end

function CopClickerManager:perform_click()

	-- Give income
	local weapon_count = 0
	for id, weapon in pairs( self:player_weapons() ) do
		local weapon_data = tweak_data.cop_clicker.weapons[ id ]
		if weapon_data then
			self._money = self._money + weapon_data.income( weapon.level )
			weapon_count = weapon_count + 1
		end
	end

	-- Progress challenges
	managers.custom_safehouse:award_progress( "trophy_washington", weapon_count )

	-- Refresh
	if self:gui() then
		self:gui():refresh()
	end

end

function CopClickerManager:get_weapon_cost( id )

	local weapon_data = tweak_data.cop_clicker.weapons[ id ]
	if not weapon_data then
		return -1
	end

	local player_weapon = self:player_weapon( id )
	if player_weapon then
		return weapon_data.cost( player_weapon.level or 0 )
	else
		return weapon_data.cost( 0 )
	end

end

function CopClickerManager:can_afford_weapon( id )
	return self._money >= self:get_weapon_cost( id )
end

function CopClickerManager:purchase_weapon( id )

	-- Check weapon exists and player can afford to purchase it
	local weapon_data = tweak_data.cop_clicker.weapons[ id ]
	if not weapon_data then
		managers.menu_component:post_event( "menu_error" )
		return false
	end
	if not self:can_afford_weapon( id ) then
		managers.menu_component:post_event( "menu_error" )
		return false
	end

	-- Ensure weapon exists and get weapon data
	self._weapons[id] = self._weapons[id] or {
		level = 0
	}
	local player_weapon = self:player_weapon( id )

	-- Decrement cost
	self._money = self._money - self:get_weapon_cost( id )

	-- Increment weapon level
	player_weapon.level = player_weapon.level + 1

	-- Gui and sounds
	managers.menu_component:post_event( "item_sell" )
	if self:gui() then
		self:gui():refresh( true )
	end

	return true

end
