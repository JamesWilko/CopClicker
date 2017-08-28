
dofile( ModPath .. "cc/CopClickerGui.lua" )

Hooks:Add("CoreMenuData.LoadDataMenu", "CopClicker.CoreMenuData.LoadDataMenu", function( menu_id, menu )

	if menu_id ~= "start_menu" then
		return
	end

	-- Create the menu node
	local new_node = {
		_meta = "node",
		name = "cop_clicker",
		back_callback = "save_progress",
		menu_components = "cop_clicker",
		scene_state = "crew_management",
		[1] = {
			["_meta"] = "default_item",
			["name"] = "back"
		}
	}
	table.insert( menu, new_node )

end)

Hooks:Add("BLTOnBuildOptions", "CopClicker.BLTOnBuildOptions", function( node )

	table.insert( node, {
		_meta = "item",
		name = "cop_clicker",
		text_id = "Cop Clicker",
		localize = false,
		next_node = "cop_clicker"
	} )

end)

--------------------------------------------------------------------------------
-- Patch MenuComponentManager to add CopClicker component

Hooks:Add("MenuComponentManagerInitialize", "CopClicker.MenuComponentManagerInitialize", function(menu)
	menu._active_components["cop_clicker"] = { create = callback(menu, menu, "create_cop_clicker_gui"), close = callback(menu, menu, "close_cop_clicker_gui") }
end)

function MenuComponentManager:cop_clicker_gui()
	return self._cop_clicker_gui
end

function MenuComponentManager:create_cop_clicker_gui( node )
	if not node then
		return
	end
	self._cop_clicker_gui = self._cop_clicker_gui or CopClickerGui:new( self._ws, self._fullscreen_ws, node )
	self:register_component( "cop_clicker", self._cop_clicker_gui )
end

function MenuComponentManager:close_cop_clicker_gui()
	if self._cop_clicker_gui then
		self._cop_clicker_gui:close()
		self._cop_clicker_gui = nil
		self:unregister_component( "cop_clicker" )
	end
end
