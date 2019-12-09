local import = require(game.ReplicatedStorage.Lib.Import)

local MovementIds = import "Data/PerformanceIds/MovementIds"
local CombatIds = import "Data/PerformanceIds/CombatIds"
local FistAttackIds = import "Data/PerformanceIds/FistAttackIds"

local CombatStateComponent = import "Shared/EntityComponents/CombatStateComponent"

local PerformanceHelper = import "GameUtils/PerformanceHelper"

local AttackPerformancesMap = import "Data/PerformanceCategoryMaps/AttackPerformancesMap"

local Performances = import "Shared/Performances"

local COMBO_EXPIRE = 1.25
local COMBO_MAX = 4 -- this will probably be deterministic later
-- determine which attach we should be doing, delegate that action

local Attack = {}

Attack.movementPriority = 1
Attack.performanceId = CombatIds.ATTACK

function Attack.validate(entity, initialState)
	local isNotKnockedDown = not PerformanceHelper.hasPerformance(entity, MovementIds.KNOCK_DOWN)
	local isNotStaggered = not PerformanceHelper.hasPerformance(entity, CombatIds.STAGGER)
	local isNotRolling = not PerformanceHelper.hasPerformance(entity, MovementIds.ROLL)
	local isNotAttacking = not PerformanceHelper.hasPerformanceInMap(entity,AttackPerformancesMap)

	if isNotKnockedDown and isNotStaggered and isNotRolling and isNotAttacking then
		return true
	end

	return false
end

function Attack.init(entity, initialState)
	local combatState = CombatStateComponent.getData(entity)
	local lastAttack = combatState.lastAttack or 0
	local timeSinceLastAttack = tick() - lastAttack
	local comboCount = combatState.comboCount or 0
	local desiredAttackId = FistAttackIds.PUNCH

	if timeSinceLastAttack > COMBO_EXPIRE then
		desiredAttackId = FistAttackIds.PUNCH
		comboCount = 0
	end

	comboCount = comboCount + 1

	if comboCount == COMBO_MAX then
		comboCount = 0
		desiredAttackId = FistAttackIds.END_PUNCH
	end

	local isSprinting = PerformanceHelper.hasPerformance(entity, MovementIds.SPRINT)

	if isSprinting then
		comboCount = 0
		desiredAttackId = FistAttackIds.DASH_PUNCH
	end

	combatState.lastAttack = tick()
	combatState.comboCount = comboCount
	CombatStateComponent.setData(entity, combatState)

	local performance = Performances[desiredAttackId]
	performance.init(entity, combatState)
end

return Attack
