-- Sylvern

-- Variables

local Shop = workspace:WaitForChild("Shop")
local Items = Shop.Items

local Modules = game:GetService("ReplicatedStorage"):WaitForChild('Modules')
local itemInfo = require(Modules.ItemsInfo)

local Players = game:GetService("Players")

local Cooldowns = {};
local Inventories = {};

local Clicks = {};

local ShopEvent = game:GetService("ReplicatedStorage").Events.ShopEvent

local Datastore = game:GetService("DataStoreService")
local Save = Datastore:GetDataStore('PlayerDataStudioTesting10')

local InvEvent = game:GetService("ReplicatedStorage").Events.Inv

local CanSave = false;

-- Functions

InvEvent.OnServerInvoke = function(plr, action)
	if action == 'GetInventory' then
		
		return Inventories[plr.Name]
		
	end
end


Players.PlayerAdded:Connect(function(plr)
	
	local Data;

	
	Data = Save:GetAsync( tostring(plr.UserId)..'InventorySave')
	
	if not Data then
				
		Inventories[plr.Name] = {
			Items = {};
		};
		
	end
	
	if Data then
				
		Inventories[plr.Name] = {
			Items = Data;
		};
	end
	
	-- Add datastore later.
	
end)

game:BindToClose(function()
	if not CanSave then return end
	
	for i,v in next, game.Players:GetPlayers() do
		
		local toSave = Inventories[v.Name].Items
		
		local s,e = pcall(function()
			Save:SetAsync( tostring(v.UserId)..'InventorySave', toSave )
		end)
		
		if s then
			warn'Successfully saved inventory data.'
		else
			warn(e)
		end
		
	end
	
end)

ShopEvent.OnServerEvent:Connect(function(plr)
	local v = plr.Valis
	
	v.Value = v.Value + 10
end)



for _,v in pairs(Items:GetChildren()) do
	if v:FindFirstChild('Click') then
		
		local Success, Item = itemInfo:Get('Item', v.ItemName.Value)
		
		if not Success then return end
		if not Item then return end
		
		local Price = Item['Price']
		local ItemName = Item['Name']
		local Type = Item['Type']
		local CanStack = Item['Stackable']
		
		
		v.Click.MouseClick:Connect(function(plr)
			if Clicks[plr.Name] then return end
			
			if Cooldowns[plr.Name..'-'.. ItemName] then 
			ShopEvent:FireClient(plr, 'Shop', 'Please wait 2 seconds before buying this item again.')
			-- Fire client here for cooldown.
			return end
			
			local ValisAmount = plr:WaitForChild('Valis')
			
			coroutine.wrap(function()
				Clicks[plr.Name] = true
				wait(3)
				Clicks[plr.Name] = nil
			end)()
			
			if ValisAmount then
				
				if ValisAmount.Value < Price then
					ShopEvent:FireClient(plr, 'Shop', 'You do not have enough money to buy this item.')
					
					
					return
				end
				
				if ValisAmount.Value >= Price then
					
					if CanStack == false then -- Non stackable.
						
						if Inventories[plr.Name].Items[ItemName] then
							ShopEvent:FireClient(plr, 'Shop', 'You have already bought this item. Make sure that you have either sold, or disposed of this item before buying it again.')
							
							
							coroutine.wrap(function()
								Cooldowns[plr.Name..'-'.. ItemName] = true
								wait(2)
								Cooldowns[plr.Name..'-'.. ItemName] = nil
							
							end)()
							
							return
						else
							Inventories[plr.Name].Items[ItemName] = {
							Stackable = false;
							ItemType = Type,
							Amount = 1,
						};
						end
						
					end
					
					ValisAmount.Value = ValisAmount.Value - Price
					
					if CanStack == true then -- Stackable.
						
						if Inventories[plr.Name].Items[ItemName] then -- already has item
							local CurrentAmount = Inventories[plr.Name].Items[ItemName].Amount
							local NewAmount = CurrentAmount + 1
							
							Inventories[plr.Name].Items[ItemName].Amount = NewAmount
							
							print(Inventories[plr.Name].Items[ItemName].Amount)
						else
							
							Inventories[plr.Name].Items[ItemName] = {
								Stackable = true;
								Amount = 1,
								ItemType = Type,
								
							};
							
						end
						
					end
					
					ShopEvent:FireClient(plr, 'Shop', 'Successfully bought: '.. ItemName)
					ShopEvent:FireClient(plr, 'Update')
					
					coroutine.wrap(function()
						Cooldowns[plr.Name..'-'.. ItemName] = true
						wait(2)
						Cooldowns[plr.Name..'-'.. ItemName] = nil
						
					end)()
					
				end
			end
			
		end)
		
		
	end
end


