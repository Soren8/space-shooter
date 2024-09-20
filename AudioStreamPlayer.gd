extends AudioStreamPlayer

func _ready():
	# Ensure music loops
	self.connect("finished", Callable(self, "_on_stream_finished"))

func _on_stream_finished():
	# When the music finishes, play it again
	play()
