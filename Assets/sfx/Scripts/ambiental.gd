extends AudioStreamPlayer

var track = "A"

func _ready() -> void:
	pass



func _process(delta: float) -> void:
	var _delta = delta

	if $ambientalLoop.is_stopped():
		
		if track == "A":
			track = "B"
			$"ambiental_loop".set("volume_db", "-8.0")
			$"ambiental_loop".play()
			$".".set("volume_db", "-80.0")
			$".".stop()
		
		if track == "B":
			track = "A"
			$".".set("volume_db", "-8.0")
			$".".play()
			$"ambiental_loop".set("volume_db", "-80.0")
			$"ambiental_loop".stop()
		$ambientalLoop.start()
