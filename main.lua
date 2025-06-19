local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Reference to the coaster model
local ptcTrain = workspace:WaitForChild("Wooden Roller Coaster V2")
	:WaitForChild("Operation")
	:WaitForChild("PTC_Train")

-- Grab all 3 car models named "Car"
local carModels = {}
for _, child in pairs(ptcTrain:GetChildren()) do
	if child.Name == "Car" and child:IsA("Model") then
		table.insert(carModels, child)
	end
end

local g = 9.81

-- GUI Labels
local gui = script.Parent
local velocityLabel = gui:WaitForChild("VelocityLabel")
local momentumLabel = gui:WaitForChild("MomentumLabel")
local keLabel = gui:WaitForChild("KELabel")
local peLabel = gui:WaitForChild("PELabel")
local heightLabel = gui:WaitForChild("HeightLabel")
local cartMassLabel = gui:WaitForChild("MassLabel")
local playerMassLabel = gui:WaitForChild("PlayerMassLabel")
local totalMassLabel = gui:WaitForChild("TotalMassLabel")

-- Function to get only the cart mass (no players)
local function getCartMass(model)
	local mass = 0
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			mass += part:GetMass()
		end
	end
	return mass
end

-- Average velocity and height for all 3 cars
local function getAverageVelocityAndHeight(models)
	local totalVelocity = 0
	local totalHeight = 0
	local totalParts = 0

	for _, model in pairs(models) do
		for _, part in pairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				totalVelocity += part.Velocity.Magnitude
				totalHeight += part.Position.Y
				totalParts += 1
			end
		end
	end

	if totalParts == 0 then return 0, 0 end
	return totalVelocity / totalParts, totalHeight / totalParts
end

-- Update GUI each frame
RunService.RenderStepped:Connect(function()
	local cartMass = 0
	for _, car in pairs(carModels) do
		cartMass += getCartMass(car)
	end

	local playerMass = 75 -- manually set player mass
	local totalMass = cartMass + playerMass

	local avgVelocity, avgHeight = getAverageVelocityAndHeight(carModels)

	local momentum = totalMass * avgVelocity
	local ke = 0.5 * totalMass * avgVelocity^2
	local pe = totalMass * g * avgHeight

	-- Smooth flickers when idle
	if avgVelocity < 0.1 then
		avgVelocity = 0
		momentum = 0
		ke = 0
	end

	if math.abs(pe) < 1 then
		pe = 0
	end

	-- Update GUI
	velocityLabel.Text = string.format("Velocity: %.2f m/s", avgVelocity)
	momentumLabel.Text = string.format("Momentum: %.2f kg·m/s", momentum)
	keLabel.Text = string.format("Kinetic Energy: %.2f J", ke)
	peLabel.Text = string.format("Potential Energy: %.2f J", pe)
	heightLabel.Text = string.format("Height: %.2f m", avgHeight)
	cartMassLabel.Text = string.format("Cart Mass: %.2f kg", cartMass)
	playerMassLabel.Text = string.format("Player Mass: %.2f kg", playerMass)
	totalMassLabel.Text = string.format("Total Mass: %.2f kg", totalMass)
end)
