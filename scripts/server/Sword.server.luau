local sword = script.Parent
local hitbox = script.Parent:WaitChild("Mesh")
local usesfx = sword:WaitChild("UseSword")
local equipsfx = sword:WaitChild("EquipSword")
local db = false

sword.Equipped:Connect(function()
	equipsfx.Position = sword.Position
	equipsfx:Play()
end)

sword.Activated:Connect(function()
	if db then
		return
	end
	db = true
	sword:PlayAnimation("slash")
	usesfx.Position = sword.Position
	usesfx:Play()
	wait(1)
	db = false
end)

hitbox.Touched:Connect(function(p)
	if db and (p:IsA("Player") or p:IsA("NPC")) and sword.Holder and p ~= sword.Holder then
		p.Health -= 40
	end
end)
