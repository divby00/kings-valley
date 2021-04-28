class_name TStairDetect extends Area2D

enum STAIR_TYPE { UP_LEFT,UP_RIGHT,DOWN_LEFT,DOWN_RIGHT }

export (STAIR_TYPE) var stair_type=STAIR_TYPE.DOWN_LEFT 

func get_class()->String: return "TStairDetect"
