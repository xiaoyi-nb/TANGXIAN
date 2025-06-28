game:GetService("ReplicatedStorage").Feature_RemoteEvent.TeamSwitch:FireServer("Trucker")
game:GetService("ReplicatedStorage").Packages.Shared.Network.RemoteFunctions.ClientRequestCoalTrucks:InvokeServer()
game:GetService("ReplicatedStorage").Packages.Shared.Network.RemoteFunctions.ClientRequestCoalJob:InvokeServer(workspace.TruckingJob.Coal.routeA, "2018 FAW J6P Facelift")
local car
repeat
    for i, v in ipairs(workspace.SpawnedCars:GetChildren()) do
        if v.Name == game.Players.LocalPlayer.Name .. "'s Car" then
            car = v
            break
        end
    end
    task.wait()
until car
repeat
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = car.DriveSeat.CFrame
    car.DriveSeat:Sit(game.Players.LocalPlayer.Character.Humanoid)
    task.wait()
until game.Players.LocalPlayer.Character.Humanoid.SeatPart == car.DriveSeat
car:PivotTo(workspace.TruckingJob.Coal.routeA.Pickup.CFrame * CFrame.Angles(0, -math.pi / 2, 0))
task.wait(0.7)
game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
task.wait(0.7)
car:PivotTo(workspace.TruckingJob.Coal.routeA.Dropoff.CFrame * CFrame.Angles(0, -math.pi / 2, 0))
task.wait(0.7)
game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
task.wait(1)
car = nil
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-3312.3349609375, 10.28740119934082, 3724.0439453125)
game:GetService("ReplicatedStorage").Feature_RemoteEvent.TeamSwitch:FireServer("Civilian")
loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoyi-nb/TANGXIAN/refs/heads/main/%E6%B2%B3%E5%8C%97%E5%94%90%E5%8E%BF%E5%8D%A1%E8%BD%A6%E5%88%B7%E9%92%B1.lua",true))()