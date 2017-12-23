extends Node

var dictUtils

func list_files_in_directory(path, extension):
	if dictUtils ==null:
		dictUtils = load("res://scripts/Utils/dictionary_utils.gd").new()
	var files = {}
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if files.empty():
			if "."+file.extension() == extension:
				files = {file.get_file(): load(file)}
		if file == "":
            break
		elif !(file.begins_with(".")) && "."+file.extension() == extension:
			var tempDict = {file.get_file(): load(path+"/"+file)}
			dictUtils.merge_dict(files,tempDict)
	dir.list_dir_end()

	return files

func directory_to_dictionary(path, string, extension):
	if dictUtils ==null:
		dictUtils = load("res://scripts/Utils/dictionary_utils.gd").new()
	var files = {}
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if files.empty():
			if file.get_file().rfind(string) !=-1 && "."+file.extension() == extension:
				files = {file.get_file(): path+"/"+file}
		if file == "":
            break
		elif !(file.begins_with(".")) && "."+file.extension() == extension  && file.get_file().rfind(string) !=-1:
			var tempDict = {file.get_file(): path+"/"+file}
			dictUtils.merge_dict(files,tempDict)
	dir.list_dir_end()

	return files
