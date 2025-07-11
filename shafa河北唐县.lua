local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))() 
 local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))() 

local flags = {
    speed = 0,
    espdoors = false,
    Door = false,
    espkeys = false,
    espitems = false,
    espbooks = false,
    esprush = false,
    espchest = false,
    esplocker = false,
    esphumans = false,
    espgold = false,
    goldespvalue = 0,
    hintrush = false,
    light = false,
    instapp = false,
    noseek = false,
    nogates = false,
    nopuzzle = false,
    noa90 = false,
    noskeledoors = false,
    noscreech = false,
    getcode = false,
    roomsnolock = false,
    draweraura = false,
    autorooms = false,
}

local DELFLAGS = {table.unpack(flags)}
local esptable = {Door={},keys={},items={},books={},entity={},chests={},lockers={},people={},gold={}}
           
local LBLG = Instance.new("ScreenGui", game.CoreGui)
LBLG.Name = "LBLG"
LBLG.Enabled = true

local player = game.Players.LocalPlayer

local LBL = Instance.new("TextLabel", LBLG)
LBL.Name = "LBL"
LBL.Parent = LBLG
LBL.BackgroundColor3 = Color3.new(1, 1, 1)
LBL.BackgroundTransparency = 1
LBL.BorderColor3 = Color3.new(0, 0, 0)
LBL.Position = UDim2.new(0.75, 0, 0.010, 0)
LBL.Size = UDim2.new(0, 133, 0, 30)
LBL.Font = Enum.Font.GothamSemibold
LBL.Text = "依脚本"
LBL.TextColor3 = Color3.new(0, 85, 255)
LBL.TextScaled = true
LBL.TextSize = 14
LBL.TextWrapped = true
LBL.Visible = true

local Heartbeat = game:GetService("RunService").Heartbeat
local LastIteration, Start = 0, tick()
local FrameUpdateTable = { }

local function HeartbeatUpdate()
    LastIteration = tick()
    table.insert(FrameUpdateTable, LastIteration)
    if #FrameUpdateTable > 60 then 
        table.remove(FrameUpdateTable, 1)
    end

    local CurrentFPS = #FrameUpdateTable / (LastIteration - Start)
    CurrentFPS = math.floor(CurrentFPS + 0.5)
    
   
    local formattedTime = string.format("%02d:%02d:%02d", os.date("%H"), os.date("%M"), os.date("%S"))
    LBL.Text = ("依依时间" .. formattedTime)

    -- 彩虹颜色周期
    local rainbowColors = {
        Color3.new(1, 0, 0), -- 红色
        Color3.new(1, 1, 0), -- 黄色
        Color3.new(0, 1, 0), -- 绿色
        Color3.new(0, 0, 1), -- 蓝色
        Color3.new(1, 0, 1), -- 紫色
        Color3.new(1, 1, 1), -- 白色
        Color3.new(0, 0, 0), -- 黑色
    }
    local rainbowIndex = math.floor((LastIteration % 6) + 1)
    LBL.TextColor3 = rainbowColors[rainbowIndex]
end

Start = tick()

Heartbeat:Connect(HeartbeatUpdate)

 -- Gui to Lua 
 -- Version: 3.2 
  
 -- Instances:
 local ScreenGui = Instance.new("ScreenGui") 
 local FpsLabel = Instance.new("TextLabel")
 
 --Properties:

local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/JY6812/UI/refs/heads/main/81.lua"))()
local win = ui:new("唐县脚本")

local UITab1 = win:Tab("『公告』",'7734068321')

local about = UITab1:section("作者发话",true)

about:Label("唐县脚本")
about:Label("欢迎使用")
about:Label("你好"..game.Players.LocalPlayer.Character.Name)

local about = UITab1:section("『玩家信息』",false)

about:Label("你的账号年龄:"..player.AccountAge.."天")
about:Label("你的注入器:"..identifyexecutor())
about:Label("你的用户名:"..game.Players.LocalPlayer.Character.Name)
about:Label("你现在的服务器名称:"..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
about:Label("你现在的服务器id:"..game.GameId)
about:Label("你的用户ID:"..game.Players.LocalPlayer.UserId)
about:Label("获取客户端ID:"..game:GetService("RbxAnalyticsService"):GetClientId())

local UITab1 = win:Tab("『人物调整』",'7734068321')

local about = UITab1:section("",true)

about:Slider("步行速度!", "WalkSpeed", game.Players.LocalPlayer.Character.Humanoid.WalkSpeed, 16, 400, false, function(Speed)
  spawn(function() while task.wait() do game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed end end)
end)

about:Slider("跳跃高度!", "JumpPower", game.Players.LocalPlayer.Character.Humanoid.JumpPower, 50, 400, false, function(Jump)
  spawn(function() while task.wait() do game.Players.LocalPlayer.Character.Humanoid.JumpPower = Jump end end)
end)
about:Slider('设置重力', 'Sliderflag', 196.2, 196.2, 1000,false, function(Value)
        game.Workspace.Gravity = Value
    end)


local UITab1 = win:Tab("『刷💰』",'7734068321')

local about = UITab1:section("",true)

about:Button("卡车",function()
fuckyou = "泷"
create = "moon star"
loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoyi-boop/tangxian/refs/heads/main/%E6%B2%B3%E5%8C%97%E5%94%90%E5%8E%BF%E5%8D%A1%E8%BD%A6%E5%88%B7%E9%92%B1%E8%84%9A%E6%9C%AC.lua",true))()
end)