-- Roblox Exploit Drawing library recreation

-- Originally created by MirayXS
-- Quad support added by depso

-- Docs: https://synapsexdocs.github.io/libraries/drawing/

local Drawing = {}

local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local CoreGui = RunService:IsStudio() and game:GetService("Players").LocalPlayer.PlayerGui or game.CoreGui;

local DrawingUI = Instance.new("ScreenGui", CoreGui)
DrawingUI.ResetOnSpawn = false

local BaseDrawingProperties = setmetatable({
	Visible = true,
	Color = Color3.new(),
	Transparency = 0,
	Remove = function()
	end
}, {
	__add = function(tbl1, tbl2)
		local new = {}
		for i, v in next, tbl1 do
			new[i] = v
		end
		for i, v in next, tbl2 do
			new[i] = v
		end
		return new
	end
})

Drawing.new = function(Type, UI)
	UI = UI and UI:IsA("ScreenGui") and UI or DrawingUI;

	if (Type == "Line") then
		local LineProperties = ({
			To = Vector2.new(),
			From = Vector2.new(),
			Thickness = 1,
		} + BaseDrawingProperties)

		local LineFrame = Instance.new("Frame");
		LineFrame.AnchorPoint = Vector2.new(0.5, 0.5);
		LineFrame.BorderSizePixel = 0

		LineFrame.BackgroundColor3 = LineProperties.Color
		LineFrame.Visible = LineProperties.Visible
		LineFrame.BackgroundTransparency = LineProperties.Transparency


		LineFrame.Parent = UI

		return setmetatable({}, {
			__newindex = (function(self, Property, Value)
				if (Property == "To") then
					local To = Value
					local Direction = (To - LineProperties.From);
					local Center = (To + LineProperties.From) / 2
					local Distance = Direction.Magnitude
					local Theta = math.atan2(Direction.Y, Direction.X);

					LineFrame.Position = UDim2.fromOffset(Center.X, Center.Y);
					LineFrame.Rotation = math.deg(Theta);
					LineFrame.Size = UDim2.fromOffset(Distance, LineProperties.Thickness);

					LineProperties.To = To
				end
				if (Property == "From") then
					local From = Value
					local Direction = (LineProperties.To - From);
					local Center = (LineProperties.To + From) / 2
					local Distance = Direction.Magnitude
					local Theta = math.atan2(Direction.Y, Direction.X);

					LineFrame.Position = UDim2.fromOffset(Center.X, Center.Y);
					LineFrame.Rotation = math.deg(Theta);
					LineFrame.Size = UDim2.fromOffset(Distance, LineProperties.Thickness);


					LineProperties.From = From
				end
				if (Property == "Visible") then
					LineFrame.Visible = Value
					LineProperties.Visible = Value
				end
				if (Property == "Thickness") then
					Value = Value < 1 and 1 or Value

					local Direction = (LineProperties.To - LineProperties.From);
					local Distance = Direction.Magnitude

					LineFrame.Size = UDim2.fromOffset(Distance, Value);

					LineProperties.Thickness = Value
				end
				if (Property == "Transparency") then
					LineFrame.BackgroundTransparency = 1 - Value
					LineProperties.Transparency = Value
				end
				if (Property == "Color") then
					LineFrame.BackgroundColor3 = Value
					LineProperties.Color = Value 
				end
			end),
			__index = (function(self, Property)
				if (Property == "Remove") then
					return (function()
						LineFrame:Destroy();
					end)
				end
				return LineProperties[Property]
			end)
		})
	end

	if (Type == "Circle") then
		local CircleProperties = ({
			Radius = 150,
			Filled = false,
			Position = Vector2.new()
		} + BaseDrawingProperties)

		local CircleFrame = Instance.new("Frame", UI);

		CircleFrame.AnchorPoint = Vector2.new(0.5, 0.5);
		CircleFrame.BorderSizePixel = 0

		CircleFrame.BackgroundColor3 = CircleProperties.Color
		CircleFrame.Visible = CircleProperties.Visible
		CircleFrame.BackgroundTransparency = CircleProperties.Transparency

		CircleFrame.Size = UDim2.new(0, CircleProperties.Radius, 0, CircleProperties.Radius);

		local Corner = Instance.new("UICorner", CircleFrame);
		Corner.CornerRadius = UDim.new(1, 0);

		local UIStroke = Instance.new("UIStroke", CircleFrame);
		UIStroke.Thickness = 1

		return setmetatable({}, {
			__newindex = (function(self, Property, Value)
				if (Property == "Radius") then
					CircleFrame.Size = UDim2.new(0, Value, 0, Value);
					CircleProperties.Radius = Value
				end
				if (Property == "Position") then
					CircleFrame.Position = UDim2.new(0, Value.X, 0, Value.Y);
					CircleProperties.Position = Value
				end
				if (Property == "Filled") then
					CircleFrame.BackgroundTransparency = Value == true and 0 or 1
					CircleProperties.Filled = Value
				end
				if (Property == "Color") then
					CircleFrame.BackgroundColor3 = Value
					CircleProperties.Color = Value
				end
				if (Property == "Thickness") then
					UIStroke.Thickness = Value
					CircleProperties.Thickness = Value
				end
				if (Property == "Visible") then
					CircleFrame.Visible = Value
					CircleProperties.Visible = Value
				end
				if (Property == "Transparency") then
					UIStroke.Transparency = 1 - Value
					if CircleProperties.Filled then
						CircleFrame.BackgroundTransparency = 1 - Value
					end
					CircleProperties.Transparency = Value
				end
			end),
			__index = (function(self, Property)
				if (Property == "Remove") then
					return (function()
						CircleFrame:Destroy();
					end)
				end

				return CircleProperties[Property]
			end)
		})
	end

	if (Type == "Text") then
		local TextProperties = ({
			Text = "",
			Size = 0,
			Center = false,
			Outline = false,
			OutlineColor = Color3.new(),
			Position = Vector2.new(),
		} + BaseDrawingProperties)

		local TextLabel = Instance.new("TextLabel");

		TextLabel.AnchorPoint = Vector2.new(0.5, 0.5);
		TextLabel.BorderSizePixel = 0
		TextLabel.Size = UDim2.new(0, 200, 0, 50);
		TextLabel.Font = Enum.Font.SourceSans
		TextLabel.TextSize = 14

		TextLabel.TextColor3 = TextProperties.Color
		TextLabel.Visible = TextProperties.Visible
		TextLabel.BackgroundTransparency = 1
		
		TextLabel.TextTransparency = 1 - TextProperties.Transparency

		TextLabel.Parent = UI

		return setmetatable({}, {
			__newindex = (function(self, Property, Value)
				if (Property == "Text") then
					TextLabel.Text = Value
					TextProperties.Text = Value
				end
				if (Property == "Position") then
					TextLabel.Position = UDim2.new(0, Value.X, 0, Value.Y);
					TextProperties.Position = Value
				end
				if (Property == "Size") then
					TextLabel.TextSize = Value
					TextProperties.Size = Value
				end
				if (Property == "Color") then
					TextLabel.TextColor3 = Value
					TextProperties.Color = Value
				end
				if (Property == "Outline") then
					TextLabel.TextStrokeTransparency = Value and 0 or 1
					TextProperties.Outline = Value
				end
				if (Property == "OutlineColor") then
					TextLabel.TextStrokeColor3 = Value
					TextProperties.OutlineColor = Value
				end
				if (Property == "Transparency") then
					TextLabel.TextTransparency = 1 - Value
					TextProperties.Transparency = Value
				end
				if (Property == "Visible") then
					TextLabel.Visible = Value
					TextProperties.Visible = Value
				end
				if (Property == "Center") then
					TextLabel.Position = Value == true and UDim2.new(0, Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2, 0)
					TextProperties.Center = Value
				end
			end),
			__index = (function(self, Property)
				if (Property == "Remove") then
					return (function()
						TextLabel:Destroy();
					end)
				end

				return TextProperties[Property]
			end)
		})
	end

	if (Type == "Square") then
		local SquareProperties = ({
			Thickness = 1,
			Size = Vector2.new(),
			Position = Vector2.new(),
			Filled = false,
		} + BaseDrawingProperties);

		local SquareFrame = Instance.new("Frame");

		SquareFrame.AnchorPoint = Vector2.new(0.5, 0.5);
		SquareFrame.BorderSizePixel = 0

		SquareFrame.Visible = false
		SquareFrame.Parent = UI

		return setmetatable({}, {
			__newindex = (function(self, Property, Value)
				if (Property == "Size") then
					SquareFrame.Size = UDim2.new(0, Value.X, 0, Value.Y);
					SquareProperties.Text = Value
				end
				if (Property == "Position") then
					SquareFrame.Position = UDim2.new(0, Value.X, 0, Value.Y);
					SquareProperties.Position = Value
				end
				if (Property == "Size") then
					SquareFrame.Size = UDim2.new(0, Value.X, 0, Value.Y);
					SquareProperties.Size = Value
				end
				if (Property == "Color") then
					SquareFrame.BackgroundColor3 = Value
					SquareProperties.Color = Value
				end
				if (Property == "Transparency") then
					SquareFrame.BackgroundTransparency = 1 - Value
					SquareProperties.Transparency = Value
				end
				if (Property == "Visible") then
					SquareFrame.Visible = Value
					SquareProperties.Visible = Value
				end
				if (Property == "Filed") then -- requires beta

				end
			end),
			__index = (function(self, Property)
				if (Property == "Remove") then
					return (function()
						SquareFrame:Destroy();
					end)
				end

				return SquareProperties[Property]
			end)
		})
	end

	if (Type == "Image") then
		local ImageProperties = ({
			Data = "rbxassetid://848623155", -- roblox assets only rn
			Size = Vector2.new(),
			Position = Vector2.new(),
			Rounding = 0,
		});

		local ImageLabel = Instance.new("ImageLabel");

		ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5);
		ImageLabel.BorderSizePixel = 0
		ImageLabel.ScaleType = Enum.ScaleType.Stretch
		ImageLabel.Transparency = 1

		ImageLabel.Visible = false
		ImageLabel.Parent = UI

		return setmetatable({}, {
			__newindex = (function(self, Property, Value)
				if (Property == "Size") then
					ImageLabel.Size = UDim2.new(0, Value.X, 0, Value.Y);
					ImageProperties.Text = Value
				end
				if (Property == "Position") then
					ImageLabel.Position = UDim2.new(0, Value.X, 0, Value.Y);
					ImageProperties.Position = Value
				end
				if (Property == "Size") then
					ImageLabel.Size = UDim2.new(0, Value.X, 0, Value.Y);
					ImageProperties.Size = Value
				end
				if (Property == "Transparency") then
					ImageLabel.ImageTransparency = 1 - Value
					ImageProperties.Transparency = Value
				end
				if (Property == "Visible") then
					ImageLabel.Visible = Value
					ImageProperties.Visible = Value
				end
				if (Property == "Color") then
					ImageLabel.ImageColor3 = Value
					ImageLabel.Color = Value
				end
				if (Property == "Data") then
					ImageLabel.Image = Value
					ImageProperties.Data = Value
				end
			end),
			__index = (function(self, Property)
				if (Property == "Remove") then
					return (function()
						ImageLabel:Destroy();
					end)
				end

				return ImageLabel[Property]
			end)
		})
	end


	if (Type == "Quad") then
		local QuadProperties = ({
			Thickness = 1,
			PointA = Vector2.new(),
			PointB = Vector2.new(),
			PointC = Vector2.new(),
			PointD = Vector2.new(),
		} + BaseDrawingProperties);

		local Points = {
			Drawing.new("Line"),
			Drawing.new("Line"),
			Drawing.new("Line"),
			Drawing.new("Line")
		}

		local function UpdateLineValue(Name, Value)
			for _, Point in next, Points do
				Point[Name] = Value
			end
		end
		return setmetatable({}, {
			__newindex = (function(self, Property, Value)
				if (Property == "PointA") then
					Points[1].From = Value
					Points[4].To = Value
				end
				if (Property == "PointB") then
					Points[1].To = Value
					Points[2].From = Value
				end
				if (Property == "PointC") then
					Points[2].To = Value
					Points[3].From = Value
				end
				if (Property == "PointD") then
					Points[3].To = Value
					Points[4].From = Value
				end
				if (table.find({"Color", "Transparency", "Thickness", "Visible"}, Property)) then
					UpdateLineValue(Property, Value)
				end
			end),
			__index = (function(self, Property)
				if (Property == "Remove") then
					return function()
						for _, Point in next, Points do
							Point:Remove()
						end
					end
				end

				return QuadProperties[Property]
			end)
		})
	end
end

return Drawing
