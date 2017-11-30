extends Node

var soundLibraries 
var audiostreams

onready var audioserver
onready var p_sound_player = get_node("p_SamplePlayer")
onready var en_sound_player = get_node("en_SamplePlayer")
onready var env_sound_player = get_node("env_SamplePlayer")
onready var inter_sound_player = get_node("inter_SamplePlayer")
onready var stream_player = get_node("StreamPlayer")
onready var ambience_player = get_node("AmbiencePlayer")
onready var other_stream_player = get_node("OtherStreamPlayer")
var stream  
var start_volume
onready var sound_players = [en_sound_player, env_sound_player, inter_sound_player, p_sound_player]

func _ready():
	start_volume = stream_player.get_volume()
	
	print(ambience_player)
	soundLibraries = get_node("Sounds")
	audiostreams = soundLibraries.get("audiostreams")
	
	
func Play(event):
	var libs = soundLibraries.get("libraries")
	var soundtypes = soundLibraries.get("soundtypes")
#		var lib = libs[soundtypes["env"]]
#		sound_player.set_sample_library(lib)
#		print(lib.get_sample(event+".smp"))
#		sound_player.play(event+".smp")
	if(event == "mus_gameoff"):
		if !(stream_player.is_playing()):
			UpdateStream(1,stream_player.get_volume())
			stream_player.set_volume_db(15)
			stream_player.set_stream(audiostreams[event+".ogg"])
			stream_player.play()
	if(event == "electric_click"):
		var lib = libs[soundtypes["env"]]
		var sound_player = sound_players[soundtypes["env"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		sound_player.play("env_"+event +".smp")
	if(event == "electric_buzz"):
		var lib = libs[soundtypes["env"]]
		var sound_player = sound_players[soundtypes["env"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.9,1.2))
		sound_player.play("env_"+event +".smp")
	if(event == "mus_intro"):
		UpdateStream(1,start_volume)
		stream_player.set_stream(audiostreams[event+".ogg"])
		stream_player.play()
		stream_player.set_loop(true)
	if(event == "mus_gameplay"):
		UpdateStream(1,start_volume)
		stream_player.set_stream(audiostreams[event+".ogg"])
		stream_player.play()
		stream_player.set_loop(true)
	if(event == "amb_Rain"):
		ambience_player.set_stream(audiostreams[event+".ogg"])
		ambience_player.play()
		ambience_player.set_loop(true)
	if(event == "amb_hell_noise"):
		ambience_player.set_stream(audiostreams[event+".ogg"])
		ambience_player.set_volume(0.7)
		ambience_player.play()
		ambience_player.set_loop(true)
	if(event == "p_teleport_in" || event == "p_teleport_out"):
		var lib = libs[soundtypes["p"]]
		var sound_player = sound_players[soundtypes["p"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		sound_player.play(event +".smp")
	if(event == "en_gore"):
		var sound_player = sound_players[soundtypes["en"]]
		if !(sound_player.is_voice_active(0)):
			var lib = libs[soundtypes["en"]]
			if sound_player.get_sample_library() != lib:
				sound_player.set_sample_library(lib)
			sound_player.set_default_pan(rand_range(-0.3,0.3),0,0)
			sound_player.set_default_volume(rand_range(1.5,2))
			sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
			var index = String(floor(rand_range(1,5)))
			sound_player.play(event+index +".smp")
	if(event == "en_gore_drip"):
		var sound_player = sound_players[soundtypes["en"]]
		if !(sound_player.is_voice_active(0)):
			var lib = libs[soundtypes["en"]]
			if sound_player.get_sample_library() != lib:
				sound_player.set_sample_library(lib)
			sound_player.set_default_pan(rand_range(-0.5,0.5),0,0)
			sound_player.set_default_volume(rand_range(0.2,0.4))
			sound_player.set_default_pitch_scale(rand_range(0.5,0.8))
			var index = String(floor(rand_range(1,4)))
			sound_player.play(event+index +".smp")
	if(event == "en_orb_atk"):
		var sound_player = sound_players[soundtypes["en"]]
		if !(sound_player.is_voice_active(0)):
			var lib = libs[soundtypes["en"]]
			if sound_player.get_sample_library() != lib:
				sound_player.set_sample_library(lib)
			sound_player.set_default_volume(rand_range(0.9,1.3))
			sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
			sound_player.play(event+".smp")
	if(event == "en_orb_atk_grow"):
		var sound_player = sound_players[soundtypes["en"]]
		var lib = libs[soundtypes["en"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		sound_player.play(event+".smp")
	if(event == "en_orb_explode"):
		var sound_player = sound_players[soundtypes["en"]]
		var lib = libs[soundtypes["en"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(1,1.4))
		sound_player.set_default_pitch_scale(rand_range(1,1.3))
		sound_player.play(event+".smp")
	if(event == "p_sword_hit"):
		var sound_player = sound_players[soundtypes["p"]]
		if !(sound_player.is_voice_active(0)):
			var lib = libs[soundtypes["p"]]
			if sound_player.get_sample_library() != lib:
				sound_player.set_sample_library(lib)
			sound_player.set_default_volume(rand_range(0.6,0.8))
			sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
			var index = String(floor(rand_range(1,4)))
			sound_player.play(event+index +".smp")
	if(event == "p_sword_sweep"):
		var sound_player = sound_players[soundtypes["p"]]
		if !(sound_player.is_voice_active(0)):
			var lib = libs[soundtypes["p"]]
			if sound_player.get_sample_library() != lib:
				sound_player.set_sample_library(lib)
			sound_player.set_default_volume(rand_range(0.8,1.2))
			sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
			var index = String(3)
			sound_player.play(event+index +".smp")
	if(event == "b_sword_sweep"):
		var sound_player = sound_players[soundtypes["p"]]
		if !(sound_player.is_voice_active(0)):
			var lib = libs[soundtypes["p"]]
			if sound_player.get_sample_library() != lib:
				sound_player.set_sample_library(lib)
			sound_player.set_default_volume(rand_range(0.8,1.2))
			sound_player.set_default_pitch_scale(rand_range(0.3,0.6))
			var index = String(3)
			sound_player.play("p_sword_sweep"+index +".smp")
	if(event == "b_sword_hit"):
		var sound_player = sound_players[soundtypes["p"]]
		if !(sound_player.is_voice_active(0)):
			var lib = libs[soundtypes["p"]]
			if sound_player.get_sample_library() != lib:
				sound_player.set_sample_library(lib)
			sound_player.set_default_volume(rand_range(0.6,0.8))
			sound_player.set_default_pitch_scale(rand_range(0.3,0.6))
			var index = String(floor(rand_range(1,4)))
			sound_player.play("p_sword_hit"+index +".smp")
	if(event == "p_beheading"):
		var sound_player = sound_players[soundtypes["p"]]
		if !(sound_player.is_voice_active(0)):
			var lib = libs[soundtypes["p"]]
			if sound_player.get_sample_library() != lib:
				sound_player.set_sample_library(lib)
			sound_player.set_default_volume(rand_range(0.8,1.2))
			sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
			sound_player.play(event +".smp")
	if(event == "inter_rockbox_hit"):
		var sound_player = sound_players[soundtypes["inter"]]
		var lib = libs[soundtypes["inter"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		var index = String(floor(rand_range(1,3)))
		sound_player.play(event+index +".smp")
	if(event == "inter_confirm"):
		var sound_player = sound_players[soundtypes["inter"]]
		var lib = libs[soundtypes["inter"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		sound_player.play(event +".smp")
	if(event == "inter_wall_slide"):
		other_stream_player.set_stream(audiostreams[event+".ogg"])
		other_stream_player.play()
		other_stream_player.set_loop(false)
	if(event == "inter_wall_before_slide"):
		var sound_player = sound_players[soundtypes["inter"]]
		var lib = libs[soundtypes["inter"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		var index = String(floor(rand_range(1,3)))
		sound_player.play(event+index +".smp")
	if(event == "inter_coin"):
		var sound_player = sound_players[soundtypes["inter"]]
		var lib = libs[soundtypes["inter"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		sound_player.play(event +".smp")
	if(event == "inter_lever"):
		var sound_player = sound_players[soundtypes["inter"]]
		var lib = libs[soundtypes["inter"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		sound_player.play(event +".smp")
	if(event == "env_hit_rock_wall"):
		var sound_player = sound_players[soundtypes["env"]]
		var lib = libs[soundtypes["env"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		var index = String(floor(rand_range(1,3)))
		sound_player.play(event+index +".smp")
	if(event == "env_bridge_appear"):
		var sound_player = sound_players[soundtypes["env"]]
		var lib = libs[soundtypes["env"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		sound_player.play(event +".smp")
	if(event == "env_bridge_disappear"):
		var sound_player = sound_players[soundtypes["env"]]
		var lib = libs[soundtypes["env"]]
		if sound_player.get_sample_library() != lib:
			sound_player.set_sample_library(lib)
		sound_player.set_default_volume(rand_range(0.8,1.2))
		sound_player.set_default_pitch_scale(rand_range(0.8,1.2))
		sound_player.play(event +".smp")
func StopStream():
	stream_player.stop()
	ambience_player.stop()
func UpdateStream(pitch,volume):
	if pitch != 1:
		pass
	if volume != 1:
		stream_player.set_volume(volume)
