extends AnimationPlayer

func play_event(event):
	SoundManager.Play(event)
func update_volume(volume):
	SoundManager.UpdateStream(1,volume)
