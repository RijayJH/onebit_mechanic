local inv = {}
local ox_inventory = exports.ox_inventory
function inv.CreateStash()
	ox_inventory:RegisterStash('mechanic_ticket', 'Give Mechanic Ticket', 1, 0, true)
	ox_inventory:registerHook('swapItems', function(payload) return payload.fromSlot.name == 'mechanic_ticket' end, { inventoryFilter = {'mechanic_ticket'}})
	ox_inventory:RegisterStash('mechanic_products', 'Get Customization Parts', 50, 500000, true)
	ox_inventory:registerHook('swapItems', function(payload) return type(payload.toInventory) == 'number' end, { inventoryFilter = {'mechanic_products'}})
	ox_inventory:RegisterStash('mechanic_storage', 'Mechanic Stash', 100, 1000000, true)
end

function inv.CreateCrafting()
    local craftingloc = {}
    for i, v in pairs(Config.Locations) do
        if not v.crafting then goto continue end
        craftingloc[i] = v.crafting.zone
        ::continue::
    end
    ox_inventory:RegisterCraftStation('mechanic-bench', {
        items = {
			{
				name = 'engineparts',
				ingredients = {
					iron = 5,
					aluminum = 2,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'D', label = 'Engine Parts (D)', image = 'engine_parts_d'}
			},
			{
				name = 'engineparts',
				ingredients = {
					iron = 10,
					aluminum = 5,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'C', label = 'Engine Parts (C)', image = 'engine_parts_c'}
			},
			{
				name = 'engineparts',
				ingredients = {
					iron = 20,
					aluminum = 10,
					toolbox = 0.10
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'B', label = 'Engine Parts (B)', image = 'engine_parts_b'}
			},
			{
				name = 'engineparts',
				ingredients = {
					iron = 30,
					aluminum = 20,
					toolbox = 0.15
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'A', label = 'Engine Parts (A)',  image = 'engine_parts_a'}
			},
			{
				name = 'engineparts',
				ingredients = {
					iron = 40,
					aluminum = 25,
					toolbox = 0.20
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'S', label = 'Engine Parts (S)', image = 'engine_parts_s'}
			},
			{
				name = 'bodypanels',
				ingredients = {
					plastic = 5,
					metalscrap = 2,
					glass = 2,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'D', label = 'Body Panels (D)',  image = 'body_panels_d'}
			},
			{
				name = 'bodypanels',
				ingredients = {
					plastic = 10,
					metalscrap = 5,
					glass = 5,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'C', label = 'Body Panels (C)',  image = 'body_panels_c'}
			},
			{
				name = 'bodypanels',
				ingredients = {
					plastic = 10,
					metalscrap = 10,
					glass = 10,
					toolbox = 0.10
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'B', label = 'Body Panels (B)',  image = 'body_panels_b'}
			},
			{
				name = 'bodypanels',
				ingredients = {
					plastic = 20,
					metalscrap = 10,
					glass = 10,
					toolbox = 0.15
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'A', label = 'Body Panels (A)',  image = 'body_panels_a'}
			},
			{
				name = 'bodypanels',
				ingredients = {
					plastic = 30,
					metalscrap = 20,
					glass = 20,
					toolbox = 0.20
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'S', label = 'Body Panels (S)',  image = 'body_panels_s'}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 5,
					aluminum = 5,
					metalscrap = 5,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'D', repairtype = 'transmission', label = 'Transmission Part (D)',  image = 'transmission_parts_d', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 5,
					aluminum = 5,
					metalscrap = 10,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'C', repairtype = 'transmission', label = 'Transmission Part (C)',  image = 'transmission_parts_c', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 10,
					aluminum = 5,
					metalscrap = 10,
					toolbox = 0.10
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'B', repairtype = 'transmission', label = 'Transmission Part (B)',  image = 'transmission_parts_b', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 20,
					aluminum = 10,
					metalscrap = 10,
					toolbox = 0.15
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'A', repairtype = 'transmission', label = 'Transmission Part (A)',  image = 'transmission_parts_a', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 20,
					aluminum = 10,
					metalscrap = 20,
					toolbox = 0.20
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'S', repairtype = 'transmission', label = 'Transmission Part (S)',  image = 'transmission_parts_s', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					rubber = 10,
					metalscrap = 5,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'D', repairtype = 'brakes', label = 'Brakes Part (D)',  image = 'brake_parts_d', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					rubber = 10,
					metalscrap = 10,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'C', repairtype = 'brakes', label = 'Brakes Part (C)',  image = 'brake_parts_c', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					rubber = 15,
					metalscrap = 10,
					toolbox = 0.10
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'B', repairtype = 'brakes', label = 'Brakes Part (B)',  image = 'brake_parts_b', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					rubber = 25,
					metalscrap = 15,
					toolbox = 0.15
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'A', repairtype = 'brakes', label = 'Brakes Part (A)',  image = 'brake_parts_a', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					rubber = 30,
					metalscrap = 20,
					toolbox = 0.20
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'S', repairtype = 'brakes', label = 'Brakes Part (S)',  image = 'brake_parts_s', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 5,
					rubber = 5,
					aluminum = 5,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'D', repairtype = 'suspension', label = 'Suspension Part (D)',  image = 'coiloversD', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 5,
					rubber = 5,
					aluminum = 10,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'C', repairtype = 'suspension', label = 'Suspension Part (C)',  image = 'coiloversC', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 10,
					rubber = 5,
					aluminum = 10,
					toolbox = 0.10
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'B', repairtype = 'suspension', label = 'Suspension Part (B)',  image = 'coiloversB', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 15,
					rubber = 10,
					aluminum = 10,
					toolbox = 0.15
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'A', repairtype = 'suspension', label = 'Suspension Part (A)',  image = 'coiloversA', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'mechanic_otherrepair',
				ingredients = {
					steel = 25,
					rubber = 20,
					aluminum = 20,
					toolbox = 0.20
				},
				duration = 1500,
				count = 1,
				metadata = {vehclass = 'S', repairtype = 'suspension', label = 'Suspension Part (S)',  image = 'coiloversS', weight = 500}
			},--mechanic_otherrepair
			{
				name = 'fueltank',
				ingredients = {
					copper = 5,
					metalscrap = 5,
					iron = 10,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
			},
			{
				name = 'repairkit',
				ingredients = {
					copper = 5,
					metalscrap = 5,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
			},
			{
				name = 'advancedrepairkit',
				ingredients = {
					refinedaluminum = 5,
					refinedscrap = 5,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
			},
			{
				name = 'cleaningkit',
				ingredients = {
					polyester = 15,
					wax = 1,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
			},
			{
				name = 'mechanic_tools',
				ingredients = {
					metalscrap = 5,
					toolbox = 0.05
				},
				duration = 1500,
				count = 1,
			},
			{
				name = 'lockpick',
				ingredients = {
					metalscrap = 1,
					toolbox = 0.05
				},
				duration = 1500,
				count = 3,
			},
			{
				name = 'advancedlockpick',
				ingredients = {
					metalscrap = 10,
					toolbox = 0.05
				},
				duration = 1500,
				count = 3,
			},

		},
        zones = craftingloc,
    })
end

function inv.GetTicketItemSlot(i)
	return ox_inventory:GetSlot('mechanic_ticket:'..i, 1)
end

function inv.RemoveItem(inventory, itemname, count, slot)
	return ox_inventory:RemoveItem(inventory, itemname, count, nil, slot)
end

function inv.AddItem(inventory, itemname, count, metadata)
	return ox_inventory:AddItem(inventory, itemname, count, metadata)
end

function inv.GetinvItems(inv, owner)
	return ox_inventory:GetInventoryItems(inv, owner)
end

function inv.ClearItemsfromTempStash()
	for i, _ in pairs(Config.Locations) do
		ox_inventory:ClearInventory('mechanic_products:'..i)
	end
end


return inv
