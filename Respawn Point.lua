_G.DRespawn = true

local ToSave = {
	"CFrame",
	"Velocity"
}

local LocalPlayer = game:GetService("Players").LocalPlayer
local LastProps = {}

repeat wait() until game:IsLoaded() and LocalPlayer.Character

local function DeathConnect(Character)
	if not _G.DRespawn then
		return
	end
	
	local Humanoid = Character:WaitForChild("Humanoid")
	-- wait(.1)
	
	for name,hello in next, LastProps do
		Humanoid.RootPart[name] = hello
	end

	Humanoid.Died:Connect(function()
		for _,name in next, ToSave do
			LastProps[name] = Humanoid.RootPart[name]
		end
	end)
end

DeathConnect(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(DeathConnect)
