
log("LOAD:", tostring(ModPath .. "cc/CopClickerManager.lua"))
dofile( ModPath .. "cc/CopClickerManager.lua" )

local MenuSetup_init_managers = MenuSetup.init_managers

function MenuSetup:init_managers( ... )

	MenuSetup_init_managers( self, ... )

	managers.cop_clicker = CopClickerManager:new()

end
