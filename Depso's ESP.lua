-- 4/11/23
-- depso

_G.DESPConfig = {
	-------------
	-- Display --
	-------------
	Default_Color = Color3.fromRGB(200,200,200),
	Rainbow = true,
	-------------
	UseTeamColor = true, -- Use the team's color instead of the default
	OtherTeamsOnly = true, -- Hide your team
	ShowDead = true, -- Continue to hilight dead players
	CheckVisibility = true, -- Hide if it's not visible 
	
	-------------
	--  Items  --
	-------------
	Tracers = true,
	TracerThickness = 1,
	TracerOpacity = 0.2,
	-------------
	Boxes = true,
	BoxThickness = 5,
	BoxOpacity = 0.9
}

--Drawing.clear()

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RainbowState

assert(Drawing, 'Your exploit does not support the Drawing library.')

if _G.DESPConfig.Rainbow then
	RunService.RenderStepped:Connect(function()
		local hue = tick()%5/5
		RainbowState = Color3.fromHSV(hue,1,1)
	end)
end

function IsVisible(Part)
	if not Part then
		return
	end
	
	local ObstructingParts = Camera:GetPartsObscuringTarget({Part.Position}, {Part.Parent,LocalPlayer.Character})

	for i,Part in next, ObstructingParts do
		pcall(function()
			if Part.Transparency >= 1 then
				table.remove(ObstructingParts, i)
			end
		end)
	end
	
	return #ObstructingParts <= 0
end

function GetColor(Player)
	local C = _G.DESPConfig
	return  (C.Rainbow and RainbowState) 
		or (C.UseTeamColor and Player.TeamColor and Player.TeamColor.Color) 
		or C.Default_Color
end

function ToScreen(p)
	local _, Visible = Camera:WorldToScreenPoint(p)--Camera:WorldToViewportPoint(p)
	return Vector2.new(_.X, _.Y), Visible
end

function CheckTeam(Player)
	return _G.DESPConfig.OtherTeamsOnly and Player.Team and Player.Team == LocalPlayer.Team
end

function WorkPositions(Character)
	if not Character then
		return
	end

	local Center,Offsets = Character:GetBoundingBox()
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local ScreenCenter,Visible = ToScreen(Center.Position)

	if not _G.DESPConfig.ShowDead and (not Humanoid or Humanoid.Health < 1) or not Visible then
		return
	end

	return {
		ToScreen((Center * CFrame.new(-Offsets.X/2,Offsets.Y/2,0)).Position),
		ToScreen((Center * CFrame.new(Offsets.X/2,Offsets.Y/2,0)).Position),
		ToScreen((Center * CFrame.new(Offsets.X/2,-Offsets.Y/2,0)).Position),
		ToScreen((Center * CFrame.new(-Offsets.X/2,-Offsets.Y/2,0)).Position),
		Vector2.new(ScreenCenter.X,ScreenCenter.Y)
	}
end

function Outline(Player)
	local Box, Tracer
	local Lib = {}

	if _G.DESPConfig.Boxes then
		Box = Drawing.new("Quad")
		Box.Visible = true
		Box.Color = Color3.fromRGB(255, 255, 255)
		Box.Thickness = _G.DESPConfig.BoxThickness
		Box.Transparency = _G.DESPConfig.BoxOpacity
	end
	if _G.DESPConfig.Tracers then
		Tracer = Drawing.new("Line")
		Tracer.Visible = true
		Tracer.Color = Color3.fromRGB(255, 255, 255)
		Tracer.Thickness = _G.DESPConfig.TracerThickness
		Tracer.Transparency = _G.DESPConfig.TracerOpacity
		Tracer.From = Vector2.new(Camera.ViewportSize.X/2,  Camera.ViewportSize.Y-30)
		Tracer.To = Tracer.From
	end

	Lib.SetVisible = function(Visible)
		if Box then
			Box.Visible = Visible 
		end
		if Tracer then
			Tracer.Visible = Visible 
		end
	end

	Lib.Render = RunService.RenderStepped:Connect(function()
		local Character = Player.Character
		if not Character then
			return
		end
		if CheckTeam(Player) then
			return Lib.SetVisible(false)
		end
		if _G.DESPConfig.CheckVisibility and not IsVisible(Character.PrimaryPart or Character:FindFirstChildOfClass("Part")) then
			return Lib.SetVisible(false)
		end
		
		local Points = WorkPositions(Player.Character)
		if not Points then
			return Lib.SetVisible(false)
		end	
		Lib.SetVisible(true)

		local Color = GetColor(Player)
		if Box then
			Box.PointA = Points[1]
			Box.PointB = Points[2]
			Box.PointC = Points[3]
			Box.PointD = Points[4]
			Box.Color = Color
		end
		if Tracer then
			Tracer.To = Points[5]
			Tracer.Color = Color
		end
	end)

	Players.PlayerRemoving:Connect(function(_Player)
		if _Player == Player then
			Lib.Render:Disconnect()
			if Box then
				Box:Remove()
			end
			if Tracer then
				Tracer:Remove()
			end
		end
	end)

	return Lib
end


for _, Player in next, Players:GetChildren() do
	if Player ~= LocalPlayer then
		pcall(spawn, function()
			Outline(Player)
		end)
	end
end
Players.PlayerAdded:Connect(Outline)

--[[
for _, Coin in next, workspace.Coins:GetChildren() do
	pcall(spawn, function()
		Outline({
			Character = Coin
		})
	end)
end
]]
