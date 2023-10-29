local FileUrl = "https://cdn.discordapp.com/attachments/1154539009238896801/1167912043983147119/If_they_dont_fix_their_servers_then_I_am_gonna_break_my_monitor_I_swear.mp4"
local FileName = "dvideo.mp4"

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local VideoFrame = Instance.new("VideoFrame", ScreenGui)
VideoFrame.Size = UDim2.new(0, 150*2,0, 80*2)
VideoFrame.Position = UDim2.new(0, 0,1, -VideoFrame.Size.Y.Offset)

if not isfile(FileName) then
	local content = request({
		Url = FileUrl,
		Method = "GET"
	})
	
	writefile(FileName, content.Body)
	repeat wait() until isfile(FileName)
end

VideoFrame.Video = getcustomasset(FileName)
VideoFrame.Volume = 0
VideoFrame.Looped = true
VideoFrame:Play()
