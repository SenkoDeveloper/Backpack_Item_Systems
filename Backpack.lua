-- Sylvern

-- Variables

--[[
Must fix bugs located in trello.
]]--

local MainModule = require(script.Parent:WaitForChild("ItemsShop").Sub)
local Players = game:GetService("Players")

local Events = game:GetService("ReplicatedStorage"):WaitForChild('Events')
local BackpackEvent = Events.Backpack

local Backpacks = MainModule.backpacks

local ItemsFolder = game:GetService("ReplicatedStorage"):WaitForChild('Assets').Items

-- Functions

BackpackEvent.OnServerEvent:Connect(function(plr, action, itemName, slot)
	if action == 'EquipItem' then
		
		local PlrBackpack = Backpacks[plr.Name]
		if not PlrBackpack then warn'Could not get players backpack.' return end
		
		local EquippedItems = PlrBackpack['EquippedItems']
		
		local toNum = tonumber(slot)
		local toStr = tostring(itemName)
		
		if EquippedItems[toNum] then 
			warn'You already have an item equipped in this slot. Replacing item.'
			
			EquippedItems[toNum] = nil
			EquippedItems[toNum] = toStr
		end
		
		
		EquippedItems[toNum] = toStr
		
		warn("Successfully equipped item: ".. toStr.. ' to: '.. toNum)
	end
	
	if action == 'UseItem' then
		local Humanoid = plr.Character:WaitForChild('Humanoid')
		local getItem = ItemsFolder:FindFirstChild(itemName)
		
		if not getItem then warn'Could not get item.' return end
		
		local toNum = tonumber(slot)
		
		if Backpacks[plr.Name]['EquippedItems'][toNum] == tostring(itemName) then
		
			Humanoid:UnequipTools() -- Unequipping all tools first.
			
			Humanoid:EquipTool(getItem)
		else
			warn'Could not get item from players backpack.'
			return
		end
		
		
	end
end)

Players.PlayerAdded:Connect(function(plr)
	-- Add data saving later.
	
	
	Backpacks[plr.Name] = {
		EquippedItems = {
			[1] = nil,
			[2] = nil,
			[3] = nil,
			[4] = nil,
			[5] = nil,
		};
	};
	
	
	
	warn('Successfully created backpack for: '.. plr.Name)
end)

Players.PlayerRemoving:Connect(function(plr)
	-- Save data.
	
end)
