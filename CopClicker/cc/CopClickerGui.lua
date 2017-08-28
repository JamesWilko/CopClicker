
local padding = 10

local make_fine_text = function( text )
	local x, y, w, h = text:text_rect()
	text:set_size( w, h )
	text:set_position( math.round( text:x() ), math.round( text:y() ) )
	return w, h
end

--------------------------------------------------------------------------------

CopClickerShopTab = CopClickerShopTab or class()

function CopClickerShopTab:init( parent, params )

	self._panel = parent:panel({
		x = (parent:w() * 0.25) * ((params.order or 1) - 1),
		w = parent:w() * 0.25,
		h = params.h or 32
	})

	self._name = self._panel:text({
		name = "name",
		text = params.text or "no name",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.button_stage_3,
	})
	make_fine_text( self._name )
	self._name:set_center( self._panel:w() * 0.5, self._panel:h() * 0.5 )

	self._active = false

end

function CopClickerShopTab:inside( x, y )
	return self._panel:inside( x, y )
end

function CopClickerShopTab:set_highlight( visible, no_sound )
	if self._highlighted ~= visible then
		self._highlighted = visible
		self._name:set_color( visible and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3 )
		if not no_sound then
			managers.menu:post_event( "highlight" )
		end
	end
end

function CopClickerShopTab:set_active( active )
	if self._active ~= active then
		self._active = active
	end
end

--------------------------------------------------------------------------------

CopClickerUpgradeButton = CopClickerUpgradeButton or class()
CopClickerUpgradeButton.height = 64

function CopClickerUpgradeButton:init( parent, params )

	-- Get upgrade data
	local upgrade_data
	local item_data
	if params.type == "weapons" then
		upgrade_data = tweak_data.cop_clicker.weapons[ params.upgrade_id ]
		item_data = managers.cop_clicker:player_weapon( params.upgrade_id )
	else
		upgrade_data = tweak_data.cop_clicker[ params.type ][ params.upgrade_id ]
		item_data = upgrade_data
	end

	if not upgrade_data then
		Application:error("No upgrade data for ", params.upgrade_id, inspect( params ))
		return
	end
	self._parameters = params
	self._upgrade_data = upgrade_data

	-- Create panel
	self._panel = parent:panel({
		x = padding,
		y = padding + ((params.order or 1) - 1) * (self.height + 4),
		w = parent:w() - padding * 3,
		h = self.height
	})
	BoxGuiObject:new( self._panel:panel({ layer = 100 }), { sides = { 1, 1, 1, 1 } } )

	local image_size = self._panel:h()
	self._image = self._panel:bitmap({
		w = image_size * 2,
		h = image_size,
		texture = upgrade_data.icon,
	})

	self._lock_image = self._panel:bitmap({
		w = 32,
		h = 32,
		texture = "guis/textures/pd2/lock_incompatible",
		color = Color.red,
		layer = 10
	})
	self._lock_image:set_center( self._image:w() * 0.5, self._image:h() * 0.5 )
	self._lock_image:set_visible( false )

	self._name = self._panel:text({
		name = "name",
		text = "upgrade name",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = Color.white,
		x = padding,
		y = padding
	})
	make_fine_text( self._name )
	self._name:set_left( self._image:right() + padding )

	self._desc = self._panel:text({
		name = "desc",
		text = "upgrade desc",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white,
		x = padding,
		y = padding
	})
	make_fine_text( self._desc )
	self._desc:set_top( self._name:bottom() + 2 )
	self._desc:set_left( self._image:right() + padding )

	self._highlight = self._panel:rect({
		color = tweak_data.screen_colors.button_stage_2,
		alpha = 0.4,
		layer = -1,
		blend_mode = "add"
	})
	self:set_highlight( false, true )

end

function CopClickerUpgradeButton:refresh()

	local item_data
	if self._parameters.type == "weapons" then
		item_data = managers.cop_clicker:player_weapon( self._parameters.upgrade_id )
	else
		item_data = tweak_data.cop_clicker[ self._parameters.type ][ self._parameters.upgrade_id ]
	end
	local level = item_data and item_data.level or 0

	-- Update name
	local level_str
	if level > 0 then
		level_str = " Lvl. " .. managers.experience:cash_string( level, "" )
	else
		level_str = ""
	end
	self._name:set_text( self._upgrade_data.name .. level_str )
	make_fine_text( self._name )

	local cost
	if self._upgrade_data.cost then
		cost = self._upgrade_data.cost( level )
		self._name:set_text( self._name:text() .. " - " .. managers.experience:cash_string( cost ) )
	end
	make_fine_text( self._name )

	-- Update description
	local desc = self._upgrade_data.desc
	if self._upgrade_data.income then
		local next_income = self._upgrade_data.income( level + 1 )
		desc = string.gsub( desc, "$income;", managers.experience:cash_string( next_income ) )
	end
	self._desc:set_text( desc )
	make_fine_text( self._desc )

	-- Update locks
	if cost and managers.cop_clicker:player_money() < cost then
		self._lock_image:set_visible( true )
		self._lock_image:set_image( "guis/textures/pd2/lock_incompatible" )
		self._image:set_blend_mode( "sub" )
	else
		self._lock_image:set_visible( false )
		self._image:set_blend_mode( "normal" )
	end

end

function CopClickerUpgradeButton:inside( x, y )
	return self._panel:visible() and self._panel:inside( x, y )
end

function CopClickerUpgradeButton:set_highlight( visible, no_sound )
	if self._highlighted ~= visible then
		self._highlighted = visible
		self._highlight:set_visible( visible )
		if not no_sound then
			managers.menu:post_event( "highlight" )
		end
	end
end

function CopClickerUpgradeButton:on_click( x, y )

	if not self._upgrade_data then
		return false
	end

	if self._parameters.type == "weapons" then
		return managers.cop_clicker:purchase_weapon( self._parameters.upgrade_id )
	end

end

--------------------------------------------------------------------------------

CopClickerGui = CopClickerGui or class()

CopClickerGui.battle_panel_w = 0.5
CopClickerGui.info_panel_h = 0.2

function CopClickerGui:init( ws, fullscreen_ws, node )

	-- Ensure this shit exists
	tweak_data.cop_clicker = tweak_data.cop_clicker or CopClickerTweakData:new( tweak_data )
	managers.cop_clicker = managers.cop_clicker or CopClickerManager:new()

	-- Create main panel
	self._ws = ws
	self._panel = ws:panel():panel({})
	self._panel:rect({
		layer = -100,
		color = Color.black,
		alpha = 0.6
	})

	self._tabs = {}
	self._buttons = {}

	-- Create sub-panels
	self:init_battle_panel()
	self:init_info_panel()
	self:init_shop_panel()

	self:refresh( true )
	managers.cop_clicker:register_gui( self )

	-- Sounds
	managers.menu_component:post_event( "crime_net_startup" )

end

function CopClickerGui:close()
	if alive(self._panel) then
		self._ws:panel():remove( self._panel )
	end
end

function CopClickerGui:init_battle_panel()

	local battle_panel_w = self._panel:w() * CopClickerGui.battle_panel_w
	local info_panel_h = self._panel:h() * CopClickerGui.info_panel_h

	self._battle_panel = self._panel:panel({
		w = battle_panel_w
	})
	BoxGuiObject:new( self._battle_panel:panel({ layer = 100 }), { sides = { 1, 1, 1, 1 } } )

	-- Next enemies panel
	self._wave_panel = self._battle_panel:panel({
		x = padding,
		y = padding,
		w = self._battle_panel:w() - padding * 2,
		h = 96,
		layer = 50
	})
	BoxGuiObject:new( self._wave_panel:panel({ layer = 100 }), { sides = { 1, 1, 2, 2 } } )

	-- News panel
	self._news_panel = self._battle_panel:panel({
		x = padding,
		w = self._battle_panel:w() - padding * 2,
		h = 32,
		layer = 50
	})
	BoxGuiObject:new( self._news_panel:panel({ layer = 100 }), { sides = { 2, 2, 1, 1 } } )
	self._news_panel:set_bottom( self._battle_panel:h() - padding )

	-- Current enemy panel
	local enemy_image = self._battle_panel:rect({
		w = 128,
		h = 128,
		color = Color.green,
		layer = 10
	})
	enemy_image:set_center( self._battle_panel:w() * 0.5, self._battle_panel:h() * 0.5 )

	-- Current weapon panel
	self._weapons_panel = self._battle_panel:panel({
		w = 512,
		h = 512,
		layer = 5
	})
	self._weapons_panel:set_center( self._battle_panel:w() * 0.5, self._battle_panel:h() * 0.5 )
	self._weapon_images = {}

end

function CopClickerGui:init_info_panel()

	local battle_panel_w = self._panel:w() * CopClickerGui.battle_panel_w
	local info_panel_h = self._panel:h() * CopClickerGui.info_panel_h

	self._info_panel = self._panel:panel({
		x = battle_panel_w + padding,
		w = self._panel:w() - battle_panel_w - padding,
		h = info_panel_h
	})
	BoxGuiObject:new( self._info_panel:panel({ layer = 100 }), { sides = { 1, 1, 1, 1 } } )

	-- Player info
	self._player_info = self._info_panel:panel({
		w = self._info_panel:w() * 0.5,
	})

	local player_name = self._player_info:text({
		name = "name",
		text = tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name()),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = Color.white,
		x = padding,
		y = padding
	})
	make_fine_text( player_name )

	local player_money = self._player_info:text({
		name = "money",
		text = "money",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = Color.yellow,
		x = padding,
		y = padding + tweak_data.menu.pd2_medium_font_size * 2
	})
	make_fine_text( player_money )
	player_money:set_w( self._player_info:w() - padding * 2 )

	local player_armor = self._player_info:text({
		name = "armor",
		text = "armor",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = Color.white,
		x = padding,
		y = padding + tweak_data.menu.pd2_medium_font_size * 3
	})
	make_fine_text( player_armor )
	player_armor:set_w( self._player_info:w() - padding * 2 )

	local player_health = self._player_info:text({
		name = "health",
		text = "health",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = Color.white,
		x = padding,
		y = padding + tweak_data.menu.pd2_medium_font_size * 4
	})
	make_fine_text( player_health )
	player_health:set_w( self._player_info:w() - padding * 2 )

	self._player_info_elements = {
		name = player_name,
		money = player_money,
		health = player_health,
		armor = player_armor
	}

end

function CopClickerGui:init_shop_panel()

	local battle_panel_w = self._panel:w() * CopClickerGui.battle_panel_w
	local info_panel_h = self._panel:h() * CopClickerGui.info_panel_h

	self._shop_panel = self._panel:panel({
		x = battle_panel_w + padding,
		y = info_panel_h + padding,
		w = self._panel:w() - battle_panel_w - padding,
		h = self._panel:h() - info_panel_h - padding
	})
	BoxGuiObject:new( self._shop_panel:panel({ layer = 100 }), { sides = { 1, 1, 1, 1 } } )

	-- Tabulate shop
	self._shop_tabs = self._shop_panel:panel({
		h = 32,
	})

	self._shop_items = self._shop_panel:panel({
		y = 32,
		h = self._shop_panel:h() - 32,
	})

	-- Add shop tabs
	for i, data in ipairs( tweak_data.cop_clicker.gui_tabs ) do

		-- Create tab and scroller
		local tab = CopClickerShopTab:new( self._shop_tabs, {
			order = i,
			text = data.text,
		} )
		local tab_page = self._shop_items:panel({})
		local tab_scroll = ScrollablePanel:new( tab_page, "shop_scroll_" .. data.text, {} )

		-- Populate list
		for idx, id in pairs( tweak_data.cop_clicker[ data.populate[2] ] ) do
			local button = CopClickerUpgradeButton:new( tab_scroll:canvas(), {
				order = idx,
				upgrade_id = id,
				type = data.populate[1]
			} )
			table.insert( self._buttons, button )
		end
		tab_scroll:update_canvas_size()

		-- Add tab
		table.insert( self._tabs, {
			tab = tab,
			page = tab_page,
			scroll = tab_scroll,
			canvas = tab_scroll:canvas(),
		} )

		if i > 1 then
			tab_scroll:canvas():set_visible( false )
		end

	end

	-- Select default tab
	self:select_tab( 1 )

end

function CopClickerGui:close()

	if alive(self._panel) then
		self._ws:panel():remove( self._panel )
		self._panel = nil
	end

end

--------------------------------------------------------------------------------

function CopClickerGui:panel()
	return self._panel
end

function CopClickerGui:battle_panel()
	return self._battle_panel
end

function CopClickerGui:info_panel()
	return self._info_panel
end

function CopClickerGui:shop_panel()
	return self._shop_panel
end

--------------------------------------------------------------------------------

function CopClickerGui:refresh( expensive )

	local sep_string = function( a )
		return managers.experience:cash_string( a, "" )
	end

	-- Money
	self._player_info_elements.money:set_text( "Cash: $" .. sep_string(math.round( managers.cop_clicker:player_money() )) )

	-- Armor
	local armor, max_armor = managers.cop_clicker:player_armor()
	self._player_info_elements.armor:set_text( "Armor: " .. sep_string(math.floor( armor )) .. "/" .. sep_string(math.floor( max_armor )) )

	local armor_percent = armor / max_armor
	if armor_percent < 0.33 then
		self._player_info_elements.health:set_color( Color.red )
	elseif armor_percent == 0 then
		self._player_info_elements.health:set_color( Color.white:with_alpha(0.4) )
	else
		self._player_info_elements.health:set_color( Color.white )
	end

	-- Health
	local health, max_health = managers.cop_clicker:player_health()
	self._player_info_elements.health:set_text( "Health: " .. sep_string(math.floor( health )) .. "/" .. sep_string(math.floor( max_health )) )

	local health_percent = health / max_health
	if health_percent <= 0.25 then
		self._player_info_elements.health:set_color( Color.red )
	elseif health_percent <= 0.5 then
		self._player_info_elements.health:set_color( Color.yellow )
	else
		self._player_info_elements.health:set_color( Color.white )
	end

	-- Collected weapons
	if expensive then

		if self._weapon_images then
			for _, element in ipairs( self._weapon_images ) do
				self._weapons_panel:remove( element )
			end
		end

		self._weapon_images = {}
		for id, data in pairs( managers.cop_clicker:player_weapons() ) do
			local weapon_data = tweak_data.cop_clicker.weapons[ id ]
			if weapon_data then
				for i = 1, math.ceil(data.level / (weapon_data.image_num or 1)) do
					local weapon_image = self._weapons_panel:bitmap({
						w = 256*0.5,
						h = 128*0.5,
						texture = weapon_data.icon,
						visible = false,
					})
					table.insert( self._weapon_images, weapon_image )
				end
			end
		end

	end

	-- Shop buttons
	for _, button in ipairs( self._buttons ) do
		button:refresh()
	end

end

function CopClickerGui:update( t, dt )

	-- Update guns that rotate around enemy
	self._t = ((self._t or 0) + dt * 20) % 360
	self._t2 = ((self._t2 or 0) + dt * 200) % 360

	local center_x, center_y = 256, 256
	local radius = 150
	local extra_radius = 50
	local pulse_radius = 10
	local num_per_layer = 30
	local num_images = #self._weapon_images
	local layers = math.ceil( num_images / num_per_layer )

	for idx, element in ipairs( self._weapon_images ) do
		local layer = math.floor( idx / num_per_layer )
		local direction = (layer % 2 == 1) and 1 or -1
		local num_current = math.max(num_images - layer * num_per_layer, 1)
		local offset = 360 * (idx / num_current)
		local x = center_x + math.cos((self._t + offset) * direction) * (radius + (extra_radius * layer)) + math.sin(self._t2 + offset) * pulse_radius
		local y = center_y + math.sin((self._t + offset) * direction) * (radius + (extra_radius * layer)) + math.sin(self._t2 + offset) * pulse_radius
		element:set_center( x, y )
		element:set_rotation( (self._t + offset) * direction )
		element:set_visible( true )
	end

end

--------------------------------------------------------------------------------

function CopClickerGui:select_tab( idx )

	if self._selected_tab then
		local data = self._tabs[ self._selected_tab ]
		data.tab:set_active( false )
		data.page:set_visible( false )
	end

	self._selected_tab = idx
	local data = self._tabs[ self._selected_tab ]
	data.tab:set_active( true )
	data.page:set_visible( true )

end

--------------------------------------------------------------------------------

function CopClickerGui:mouse_moved( o, x, y )

	local used, pointer

	for i, tab_data in pairs( self._tabs ) do
		if tab_data.tab then
			if not used and tab_data.tab:inside( x, y ) then
				tab_data.tab:set_highlight( true )
				used = true
				pointer = "link"
			else
				tab_data.tab:set_highlight( false )
			end
		end
	end

	for _, button in ipairs( self._buttons ) do
		if not used and button:inside( x, y ) then
			button:set_highlight( true )
			used = true
			pointer = "link"
		else
			button:set_highlight( false )
		end
	end

	if not used and alive(self._battle_panel) and self._battle_panel:inside( x, y ) then
		used = true
		pointer = "link"
	end

	if used then
		return used, pointer
	end

end

function CopClickerGui:mouse_pressed( o, button, x, y )
	
end

function CopClickerGui:mouse_released( o, button, x, y )

end

function CopClickerGui:mouse_wheel_up( x, y )
	self:_scroll( x, y, 1 )
end

function CopClickerGui:mouse_wheel_down( x, y )
	self:_scroll( x, y, -1 )
end

function CopClickerGui:_scroll( x, y, dir )

	for i, tab_data in pairs( self._tabs ) do
		if tab_data.scroll then
			local values = { tab_data.scroll:scroll( x, y, dir ) }
			if values[1] ~= nil then
				return unpack( values )
			end
		end
	end

end

function CopClickerGui:mouse_clicked( o, button, x, y )

	for i, tab_data in pairs( self._tabs ) do
		if tab_data.tab then
			if tab_data.tab:inside( x, y ) then
				self:select_tab( i )
				return
			end
		end
	end

	for _, button in ipairs( self._buttons ) do
		if button:inside( x, y ) then
			button:on_click( x, y )
			return true
		end
	end

	if alive(self._battle_panel) and self._battle_panel:inside( x, y ) then
		managers.cop_clicker:perform_click( self )
		return true
	end

end

--------------------------------------------------------------------------------
