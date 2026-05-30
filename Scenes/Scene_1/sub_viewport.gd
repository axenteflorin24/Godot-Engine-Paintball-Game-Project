extends SubViewport

var ai_player = null





var ROOT = null
var SCENE = null

func _ready():
	init_scene()
	ai_player = ROOT.get_node_by_name(SCENE.get_children(), '', 'AIPlayer')



func _process(delta: float) -> void:
	
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
