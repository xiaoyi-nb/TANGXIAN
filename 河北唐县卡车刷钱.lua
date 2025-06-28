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
loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoyi-boop/-/refs/heads/main/%E4%BE%9D%E4%BE%9D.lua",true))()