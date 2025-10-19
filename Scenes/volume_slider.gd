extends HSlider

const MAX_VOL_DB = 100.0

@export var bus_name: String
var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_volume_changer)

	# @Kawabaud: trans curr db linear 0-1, then scale slider range 0-100 & invert
	value = MAX_VOL_DB * (1.0 - db_to_linear(AudioServer.get_bus_volume_db(bus_index)))

func _volume_changer(slider_value: float) -> void:
	# @Kawabaud: unit slider value->(0-1), inv it, & apply
	var unit = 1.0 - (slider_value / MAX_VOL_DB)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(unit))
