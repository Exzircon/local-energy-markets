extends PanelContainer
@onready var ptl_label: RichTextLabel = $StatsVBoxContainer/ptlLabel
@onready var pfpc_label: RichTextLabel = $StatsVBoxContainer/pfpcLabel
@onready var pll_label: RichTextLabel = $StatsVBoxContainer/pllLabel
@onready var pstpc_label: RichTextLabel = $StatsVBoxContainer/pstpcLabel
@onready var m_earned_label: RichTextLabel = $StatsVBoxContainer/mEarnedLabel
@onready var m_saved_label: RichTextLabel = $StatsVBoxContainer/mSavedLabel
@onready var m_spent_label: RichTextLabel = $StatsVBoxContainer/mSpentLabel
@onready var c_spot_p_label: RichTextLabel = $StatsVBoxContainer/cSpotPLabel
@onready var c_sell_p_label: RichTextLabel = $StatsVBoxContainer/cSellPLabel




var low_color: Color = Color.RED
var mid_color: Color = Color.YELLOW
var high_color: Color = Color.GREEN



func _physics_process(_delta: float) -> void:
	ptl_label.text = "Power Traded Locally: " +str("%0.2f" % Stats.power_traded_locally)
	pfpc_label.text = "Power From Power Company: " +str("%0.2f" % Stats.power_from_pc)
	pll_label.text = "Power Lost Locally: " +str("%0.2f" % Stats.power_lost_locally)
	pstpc_label.text = "Power Sold to Power Company: " +str("%0.2f" % Stats.power_sold)
	m_earned_label.text = "Money Earned: " +str("%0.2f" % Stats.money_earned)
	m_saved_label.text = "Money Saved: " +str("%0.2f" % Stats.money_saved)
	m_spent_label.text = "Money Spent: " +str("%0.2f" % -Stats.money_spent)
	c_spot_p_label.text = "Buy Price: " +str("%0.6f" % PowerMarket.buy_price)
	c_sell_p_label.text = "Sell Price: " +str("%0.6f" % PowerMarket.sell_price)
	

	
