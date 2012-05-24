" OnSyntaxChange.vim: summary
"
" DEPENDENCIES:
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	25-May-2012	file creation

function! s:GetState( pattern )
    return ingointegration#IsOnSyntaxItem(getpos('.'), a:pattern)
endfunction

function! OnSyntaxChange#Trigger( isInputMode, patterns, states )
    for l:name in keys(a:patterns)
	let l:previousState = a:states[l:name]
	let l:currentState  = s:GetState(a:patterns[l:name])
	if l:previousState != l:currentState
	    let a:states[l:name] = l:currentState
	    let l:event =  'Syntax' . l:name . (l:currentState ? 'Enter' : 'Leave') . (a:isInputMode ? 'I' : '')
	    echomsg 'doautocmd User' l:event
	endif
    endfor
endfunction

function! OnSyntaxChange#Install( name, syntaxItemPattern, isBuffer )
"******************************************************************************
"* PURPOSE:
"   Set up User events for a:pat that fire when the cursor moves onto / away
"   from a syntax group matching a:syntaxItemPattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Events of the name "Syntax{name}Enter[I]" and "Syntax{name}Leave[I]" are
"   generated whenever the cursor moves onto / off the syntax group.
"* INPUTS:
"   a:name  Description of the syntax element, to be used in the generated
"	    event, e.g. "Comment".
"   a:syntaxItemPattern Regular expression that specifies the syntax groups,
"			e.g. "^Comment$". For matching, the translated,
"			effective syntax name is used.
"   a:isBuffer  Flag whether the event should be generated just for the current
"		buffer, or globally for all buffers.
"* RETURN VALUES:
"   None.
"******************************************************************************
    if a:isBuffer
	if ! exists('b:OnSyntaxChange_Patterns')
	    let b:OnSyntaxChange_Patterns = {}
	    let b:OnSyntaxChange_States = {}
	endif
	let b:OnSyntaxChange_Patterns[a:name] = a:syntaxItemPattern
	let b:OnSyntaxChange_States[a:name] = s:GetState(a:syntaxItemPattern)

	augroup OnSyntaxChangeBuffer
	    autocmd! CursorMoved,BufEnter <buffer> call OnSyntaxChange#Trigger(0, b:OnSyntaxChange_Patterns, b:OnSyntaxChange_States)
	    autocmd! CursorMovedI         <buffer> call OnSyntaxChange#Trigger(1, b:OnSyntaxChange_Patterns, b:OnSyntaxChange_States)
	augroup END
    else
	if ! exists('g:OnSyntaxChange_Patterns')
	    let g:OnSyntaxChange_Patterns = {}
	    let g:OnSyntaxChange_States = {}
	endif
	let g:OnSyntaxChange_Patterns[a:name] = a:syntaxItemPattern
	let g:OnSyntaxChange_States[a:name] = s:GetState(a:syntaxItemPattern)

	augroup OnSyntaxChangeGlobal
	    autocmd! CursorMoved,BufEnter * call OnSyntaxChange#Trigger(0, g:OnSyntaxChange_Patterns, g:OnSyntaxChange_States)
	    autocmd! CursorMovedI         * call OnSyntaxChange#Trigger(1, g:OnSyntaxChange_Patterns, g:OnSyntaxChange_States)
	augroup END
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
