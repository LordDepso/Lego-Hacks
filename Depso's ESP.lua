-- 19/10/23

_G.DESPConfig = {
	Default_Color = Color3.fromRGB(200,200,200),
	Opacity = 0.9,
	Thickness = 1,
	-------------
	UseTeamColor = true, -- Use the team's color instead of the default
	OtherTeamsOnly = true, -- Hide your team
	ShowDead = true, -- Continue to hilight dead players
	-------------
	Tracers = true,
	Boxes = true
}

--Drawing.clear()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

function ToScreen(p)
	return Camera:WorldToViewportPoint(p)
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
		ToScreen((Center * CFrame.new(-Offsets.X,Offsets.Y,0)).Position),
		ToScreen((Center * CFrame.new(Offsets.X,Offsets.Y,0)).Position),
		ToScreen((Center * CFrame.new(Offsets.X,-Offsets.Y,0)).Position),
		ToScreen((Center * CFrame.new(-Offsets.X,-Offsets.Y,0)).Position),
		ScreenCenter
	}
end
function Outline(Player)
	local Box, Tracer
	local Lib = {}
	
	if _G.DESPConfig.Boxes then
		Box = Drawing.new("Quad")
		Box.Visible = true
		Box.Color = Color3.fromRGB(255, 255, 255)
		Box.Thickness = _G.DESPConfig.Thickness
		Box.Transparency = _G.DESPConfig.Opacity
	end
	if _G.DESPConfig.Tracers then
		Tracer = Drawing.new("Line")
		Tracer.Visible = true
		Tracer.Color = Color3.fromRGB(255, 255, 255)
		Tracer.Thickness = _G.DESPConfig.Thickness
		Tracer.Transparency = _G.DESPConfig.Opacity
		Tracer.From = Vector2.new(mouse.ViewSizeX/2,  mouse.ViewSizeY)
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
		if _G.DESPConfig.OtherTeamsOnly and Player.Team and Player.Team == LocalPlayer.Team then
			return Lib.SetVisible(false)
		end
		local Points = WorkPositions(Player.Character)
		if not Points then
			return Lib.SetVisible(false)
		end	
		Lib.SetVisible(true)

		local Color = (_G.DESPConfig.UseTeamColor and Player.TeamColor and Player.TeamColor.Color) or _G.DESPConfig.Default_Color
		if Box then
			Box.PointA = Points[1]
			Box.PointB = Points[2]
			Box.PointC = Points[3]
			Box.PointD = Points[4]
			Box.Position = Points[5]
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


for _, Player in next, Players:GetPlayers() do
	if Player ~= LocalPlayer then
		pcall(spawn, function()
			Outline(Player)
		end)
	end
end
Players.PlayerAdded:Connect(Outline)
