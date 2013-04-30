
function Course:__init()
	
	self.race = nil
	-- Includes finish or start/finish.
	self.name = "unnamed course"
	self.type = "Invalid"
	-- Array of CourseCheckpoints.
	self.checkpoints = {}
	-- map of CourseCheckpoints, useful for mapping PlayerEnterCheckpoint event to a CourseCheckpoint
	-- Key = checkpointId
	-- Value = CourseCheckpoint
	self.weatherSeverity = 0.5
	self.authors = {"dreadmullet"}
	self.numLaps = -1
	self.timeLimitSeconds = -1
	
	self.checkpointMap = {}
	-- Array of CourseSpawns. Determines max player count.
	self.spawns = {}
	self.prizeMoney = settings.prizeMoneyDefault
	
end

function Course:GetMaxPlayers()
	
	return #self.spawns
	
end

function Course:AssignRacers(playerIdToRacer)
	
	local numRacers = table.count(playerIdToRacer)
	if numRacers > #self.spawns then
		error(
			"Too many racers for course! "..self.name..", "..numRacers.."/"..#self.spawns.." racers"
		)
	end
	
	local racers = {}
	for id , racer in pairs(playerIdToRacer) do
		table.insert(racers , racer)
	end
	
	-- Randomly sort the racers table. Otherwise, the starting grid is (consistently) random; we
	-- want it to always be random.
	for n = #racers , 2 , -1 do
		local r = math.random(n)
		racers[n] , racers[r] = racers[r] , racers[n]
	end
	
	local spawnIndex = 1
	for index , racer in ipairs(racers) do
		self.spawns[spawnIndex].racer = racer
		spawnIndex = spawnIndex + 1
	end
	
end

function Course:SpawnVehicles()
	
	if debug.alwaysMaxPlayers then
		self.race.numPlayers = #self.spawns
	end
	
	for n , spawn in ipairs(self.spawns) do
		if n <= self.race.numPlayers then
			spawn:SpawnVehicle()
		end
	end
	
end

function Course:SpawnCheckpoints()
	
	for n, checkpoint in ipairs(self.checkpoints) do
		checkpoint:Spawn()
	end
	
end

function Course:SpawnRacers()
	
	for n , spawn in ipairs(self.spawns) do
		spawn:SpawnRacer()
	end
	
end

function Course.CreateTestCourse()
	
	local course = Course()
	
	course.name = "Cape Carnival Test"
	
	course.type = "Circuit"
	
	local checkpointPositions = {
		Vector(14138.446289, 201.384308, -2213.883057) ,
		Vector(13869.923828, 201.385666, -2625.829102) ,
		Vector(13460.099609, 201.460983, -2366.778320) ,
		Vector(13722.583008, 201.352005, -1958.302124) ,
		Vector(13934.444336, 201.385513, -2070.170410) , -- Start/finish
	}
	
	for n , pos in ipairs(checkpointPositions) do
		local cp = CourseCheckpoint(course)
		cp.index = n
		cp.position = pos
		cp.validVehicles = {}
		table.insert(course.checkpoints , cp)
	end
	
	course.numLaps = 1
	course.timeLimitSeconds = 20 + 70 * course.numLaps * 5
	
	local spawn1 = CourseSpawn(course)
	spawn1.position = Vector(13955.602539 , 201.385193 , -2085.802734)
	spawn1.angle = Angle(-math.tau * 0.18 , 0 , 0)
	table.insert(spawn1.modelIds , 2)
	table.insert(spawn1.modelIds , 21)
	table.insert(spawn1.modelIds , 91)
	table.insert(spawn1.templates , "")
	table.insert(spawn1.templates , "")
	table.insert(spawn1.templates , "Softtop")
	table.insert(course.spawns , spawn1)
	
	local spawn2 = CourseSpawn(course)
	spawn2.position = Vector(13958.250000, 201.385193 , -2080.351074)
	spawn2.angle = Angle(-math.tau * 0.18 , 0 , 0)
	table.insert(spawn2.modelIds , 35)
	table.insert(spawn2.templates , "FullyUpgraded")
	table.insert(course.spawns , spawn2)
	
	return course
	
end
