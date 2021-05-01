class_name TEnterCheat extends ColorRect

signal sig_cheat_entered(cheat)

func do_init():
	$text.text = ""
	$text.grab_focus()
	if OS.has_virtual_keyboard():
		OS.show_virtual_keyboard()

func send_cheat():
	if OS.has_virtual_keyboard():
		OS.hide_virtual_keyboard()
	emit_signal("sig_cheat_entered",$text.text.to_upper())

func _on_BT_continue_pressed():
	send_cheat()

func _on_text_text_entered(new_text):
	send_cheat()
