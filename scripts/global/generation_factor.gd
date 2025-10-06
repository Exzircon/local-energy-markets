extends Node

var factor: float = 1.0
var factor_max: float = 1.0
var factor_min: float = 0.0

var factor_trending_up: bool = false
var change_speed: float = 0.05

func _physics_process(delta: float) -> void:
	if factor_trending_up:
		factor = clampf(factor + delta*change_speed, factor_min, factor_max)
	else:
		factor = clampf(factor - delta*change_speed, factor_min, factor_max)
	if factor == 0.0 or factor == 1.0:
		factor_trending_up = !factor_trending_up
