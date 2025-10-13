extends Node


signal Tick(tick: int)

var tick: int = 0

func emit_tick() -> void:
	PowerManager.pre_tick()
	tick += 1
	Tick.emit(tick)
