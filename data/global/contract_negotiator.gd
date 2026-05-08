extends Node


## Function for requesting power from other buildings in the local energy market.
## 	AHGiuhas
func request_contract(consumer: Building, amount: float) -> bool:
	var buildings = get_tree().get_nodes_in_group("buildings")
	var best_provider: Building
	var best_efficiency: float = 0.0
	
	for building in buildings:
		if building == consumer: continue
		var efficiency: float = calculate_efficiency(consumer, building)
		if building.power <= amount/efficiency: continue
		if efficiency > best_efficiency:
			best_efficiency = efficiency
			best_provider = building
	if not best_provider: return false
	var contract: Contract = create_contract(consumer, best_provider, amount, best_efficiency)
	contract.trade_power() # Transfers the power as soon as the contract has been made
	#print("Traded with: ", best_provider)
	return true


func calculate_efficiency(a: Building, b: Building) -> float:
	## TEMP: efficiency calculation
	var dist = a.global_position.distance_to(b.global_position)
	var efficiency = (1000 - dist)/1000
	efficiency -= randf_range(0.0, 0.3)
	#print(efficiency)
	return efficiency


func create_contract(
	consumer: Building, 
	provider: Building, 
	amount: float, 
	efficiency: float
	) -> Contract:
	var contract : Contract = Contract.new()
	
	contract.consumer = consumer
	contract.provider = provider
	contract.amount = amount
	#contract.efficiency = efficiency
	contract.duration = 1
	
	consumer.contracts.append(contract)
	provider.contracts.append(contract)
	return contract
	
