extends Node


func connect_signal(source, signal_name, target, method_name):
	if not source.is_connected(signal_name, target, method_name):
		source.connect(signal_name, target, method_name)
