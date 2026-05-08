extends Resource

class_name Battery


@export_category("Battery Stats")
@export var 							capacity_wh					: float = 2_000_000.0
@export var 							transfer_rate_w				: float = 1_000_000.0
@export_range(0.0, 1.0) var 			efficiency					: float = 0.95
var 									current_energy_wh			: float
var 									current_average_buy_value	: float = 0.0
@export var 							passive_drain				: float = 0.001

func _init():
	current_energy_wh = capacity_wh * 0.5

func charge(added_power_w: float )-> float:
	if added_power_w < 0.0: 				
		push_error("Charging battery with negative charge:", added_power_w)
		return added_power_w
	if current_energy_wh == capacity_wh: 	return added_power_w
	
	if added_power_w > transfer_rate_w: 
		added_power_w 			= transfer_rate_w
	var old_value				= current_average_buy_value
	var old_energy_w				= current_energy_wh
	var total_energy_w			= old_energy_w + added_power_w
	
	current_average_buy_value = (
		(old_energy_w * current_average_buy_value) 
		+ (added_power_w*PowerMarket.buy_price)
	) / total_energy_w
	
	current_energy_wh += added_power_w
	return current_energy_wh
	
func discharge(draw_power_w: float )-> float:
	if draw_power_w < 0.0: 				
		push_error("Cant request negative power:", draw_power_w)
		return draw_power_w
	if current_energy_wh == 0: 	return 0
	
	if draw_power_w > transfer_rate_w: 
		
		draw_power_w 			= transfer_rate_w
	var old_value				= current_average_buy_value
	var old_energy_w				= current_energy_wh
	var total_energy_w			= old_energy_w - draw_power_w
	
	current_average_buy_value = (
		(old_energy_w * current_average_buy_value) 
		- (draw_power_w*PowerMarket.buy_price)
	) / total_energy_w
	
	current_energy_wh -= draw_power_w
	return current_energy_wh
	
	
