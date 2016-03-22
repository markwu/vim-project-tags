" Finding the project root and creating tag files for different
" languages works well enough, but sometimes, more fine grained control is
" wanted. For example I work on a web project where the root project
" directory has a mobile directory inside it. The mobile directory depends on
" code from the rest of the project, but the rest of the project never
" depends on the code from the mobile directory. There needs to be a way to
" define the relationships between directories. In this case, I want
" the mobile directory to be excluded when generating tags in the main
" directory. I want the mobile directory to contain its own tag files that
" only point to stuff inside that directory. When editing files in the mobile
" directory, I want vim to look in the tag files stored there first, and only
" look at the main tag files if not found in the mobile ones. When a file
" from the mobile directory is saved, the tag file in that directory for the
" approriate language should be regenerated. Also, the appropriate tag file in
" the main directory should also be regenerated, following the normal rules of
" excluding the mobile directory.
" The simplest solution I can think of for the file that defines relationships
" is to have a .vim file with a specific name. It will get sourced, and it
" should contain settings stored in expected variable names. It is ok if it
" overwrites previously stored values in this variable because the file is
" sourced just before the variable is used.

function! s:GenerateTags(file_extension)
	let l:project_root_dir_path= s:FindProjectRoot()
	let l:tags_filename= a:file_extension.'tags'
	let l:tags_filepath= l:project_root_dir_path.'/'.l:tags_filename
	let l:rm_out= system('rm -f "'.l:tags_filepath.'"')
	echo 'rm out: '.l:rm_out
	let l:command= "find -wholename '".l:project_root_dir_path."/*".a:file_extension."' -exec ctags --append=yes -f '".l:tags_filepath."' {} +"
	echo 'command: '.l:command
	let l:out= system(l:command)
	echo 'out: '.l:out
endfunction

function! s:FindProjectRoot()
	let l:buffer_dir_path = expand("%:h")
	return s:FindProjectRootRecursive(l:buffer_dir_path)
endfunction

function! s:FindProjectRootRecursive(dir_path)
	echo 'recursive dir path '.a:dir_path
	echo 'recursive dir path length: '.len(a:dir_path)
	let l:git_dir_path = a:dir_path.'/.git'
	if isdirectory(l:git_dir_path)
		echo 'found git dir: '.l:git_dir_path
		return a:dir_path
	endif
	echo 'failed git path: '.l:git_dir_path
	echo 'failed git path lenght: '.len(l:git_dir_path)
	let l:parent_dir_path= s:ParseParentDir(a:dir_path)
	if l:parent_dir_path == '/'
		echo 'no parent dir. parent dir= '.l:parent_dir_path
		return 0
	endif
	return s:FindProjectRootRecursive(l:parent_dir_path)
endfunction

function! s:ParseParentDir(dir_path)
	echo 'original dir '.a:dir_path
	let l:parent_dir= system("dirname '".a:dir_path."'")
	let l:len = len(l:parent_dir)
	if l:parent_dir[l:len - 1] == "\n"
		echo 'found newline in parent dir'
		let l:parent_dir= l:parent_dir[0 : l:len - 2]
	endif
	echo 'parent dir '.l:parent_dir
	echo 'parent dir length: '.len(l:parent_dir)
	return l:parent_dir
endfunction

let s:extension_l= ['php','js']
augroup <SID>mapping_group
	" removes all autocmd in group
	autocmd!
	for s:extension in s:extension_l
		execute 'autocmd bufwritepost *.'.s:extension.' silent call s:GenerateTags("'.s:extension.'")'
	endfor
augroup END
