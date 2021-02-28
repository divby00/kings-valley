extends Node

const JewelTypes = ["", "rosa", "azul_clara", "azul_oscura", "naranja", "amarilla", "blanca", "verde"]
const DoorTypes = ["", "entrada-salida", "entrada", "salida"]

var scenes = {
	"joya": {
		"offset": Vector2(0, 16),
		"scene": load("res://scenes/Jewel/Jewel.tscn"),
		"sprites": {
			"blanca": load("res://resources/sprites/jewel00.png"),
			"azul_clara": load("res://resources/sprites/jewel01.png"),
			"verde": load("res://resources/sprites/jewel02.png"),
			"rosa": load("res://resources/sprites/jewel03.png"),
			"naranja": load("res://resources/sprites/jewel04.png"),
			"amarilla": load("res://resources/sprites/jewel05.png"),
			"azul_oscura": load("res://resources/sprites/jewel06.png"),
		}
	},
	"puerta": {
		"offset": Vector2(16, 48),
		"scene": load("res://scenes/Door/Door.tscn")
	},
	"pico": {
		"offset": Vector2(8, 8),
		"scene": load("res://scenes/Pickaxe/Pickaxe.tscn")
	},
	"daga": {
		"offset": Vector2(8, 8),
		"scene": load("res://scenes/Dagger/Dagger.tscn")
	}
}

# Traverse the node tree and replace Tiled objects
func post_import(scene):
	
	# The scene variable contains the nodes as you see them in the editor.
	# scene itself points to the top node. Its children are the tile and object layers.
	for node in scene.get_children():
		# To know the type of a node, check if it is an instance of a base class
		# The addon imports tile layers as TileMap nodes and object layers as Node2D
		if node is TileMap:
			# Process tile layers. E.g. read the ID of the individual tiles and
			# replace them with random variations, or instantiate scenes on top of them
			pass
		elif node is Node2D:
			for object in node.get_children():
				# Assume all objects have a custom property named "type" and get its value
				var objtype = object.get_meta("type")
				var objname = object.get_meta("name")
				print("Object found: name: " + objname + ", type: " + objtype)
				
				var node_to_clone = null
				var node_offset = Vector2(0, 0)
				if objname in scenes:
					node_to_clone = scenes[objname].scene
					node_offset = scenes[objname].offset
				if node_to_clone:
					var new_instance = node_to_clone.instance()
					new_instance.position = object.position + node_offset
					scene.add_child(new_instance)
					new_instance.set_owner(scene)
					set_jewel_details(new_instance, objname, objtype)
					set_door_details(new_instance, objname, objtype)
			
			# After you processed all the objects, remove objetos and dinamico layers
			node.queue_free()
			var objetos = scene.get_node("objetos")
			scene.remove_child(objetos)
			#var dinamico = scene.get_node("dinamico")
			#scene.remove_child(dinamico)
	# You must return the modified scene
	return scene


func set_jewel_details(new_instance, objname, objtype):
	if objname == "joya":
		if JewelTypes.has(objtype):
			new_instance.sprite_texture = scenes[objname].sprites[objtype]
		else:
			print('Error: Unknown jewel type detected!: ' + objtype)

func set_door_details(new_instance, objname, objtype):
	if objname == "puerta":
		if DoorTypes.has(objtype):
			new_instance.door_type = objtype
		else:
			print('Error: Unknown door type detected!: ' + objtype)
