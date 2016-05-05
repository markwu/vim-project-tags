function! project_tags#add_extension(file_extension)
	if !exists('g:project_tags_extension_ls')
		let g:project_tags_extension_ls= U_ls()
	endif
	call g:project_tags_extension_ls.add(a:file_extension)
endfunction

function! project_tags#find_project_root(dir)
	let proj_conf_file= project_tags#get_immediate_project_file(a:dir)
	if proj_conf_file != Null()
		return a:dir
	endif
	let parent_dir= a:dir.parent()
	if parent_dir == Null()
		return Null()
	endif
	return project_tags#find_project_root(l:parent_dir)
endfunction

function! project_tags#get_immediate_project_file(dir)
	let proj_conf_file= a:dir.get_contained_file('.project_tags.config.vim')
	if proj_conf_file.readable()
		return proj_conf_file
	endif
	return Null()
endfunction!
