extends SubViewport



@onready var ai_player = $"../../ai_player"



var ROOT = null
var SCENE = null

func _ready():
	init_scene()
	



func _process(delta: float) -> void:
	var _delta = delta
	if not $Camera3D == null and not ai_player == null:
		$Camera3D.global_position.x = ai_player.global_position.x
		$Camera3D.global_position.z = ai_player.global_position.z
		
func init_scene():
	var array = get_tree().root.get_children()
	for row in array:
		if row.name == 'main':
			ROOT = row
			break
			
	array = ROOT.get_children()
	
	for row in array:
		
		if row.name.split('_')[0] == 'scene':
			
			SCENE = row
			
			break
