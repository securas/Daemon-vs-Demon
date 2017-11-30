extends ResourcePreloader

onready var fileLoaderUtils = preload("res://scripts/Utils/fileloader.gd").new()
onready var en_sounds = fileLoaderUtils.directory_to_dictionary("res://assets/Sound/Sfx", "en_", ".smp")
onready var env_sounds = fileLoaderUtils.directory_to_dictionary("res://assets/Sound/Sfx", "env_", ".smp")
onready var inter_sounds = fileLoaderUtils.directory_to_dictionary("res://assets/Sound/Sfx", "inter_", ".smp")
onready var p_sounds = fileLoaderUtils.directory_to_dictionary("res://assets/Sound/Sfx", "p_", ".smp")

onready var soundtypes = {"en":0,"env":1,"inter":2, "p": 3}
onready var sounds = [en_sounds, env_sounds, inter_sounds, p_sounds]

onready var audiostreams = fileLoaderUtils.list_files_in_directory("res://assets/Sound/AudioStreams", ".ogg")

onready var p_Library = load("res://scenes/sound_manager/p_SoundLibrary.tres")
onready var inter_Library = load("res://scenes/sound_manager/inter_SoundLibrary.tres")
onready var en_Library = load("res://scenes/sound_manager/en_SoundLibrary.tres")
onready var env_Library = load("res://scenes/sound_manager/env_SoundLibrary.tres")

onready var libraries = [en_Library, env_Library, inter_Library, p_Library]

func _ready():
	for i in range(0, sounds.size()):
		for key in sounds[i].keys():
			if !(libraries[i].has_sample(key)):
				libraries[i].add_sample(key, load(sounds[i][key]))
	for i in range(0, libraries.size()):
		ResourceSaver.save(libraries[i].get_path(), libraries[i])
	fileLoaderUtils.free()
