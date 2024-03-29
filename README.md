ON SYNTAX CHANGE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin can set up custom User events similar to the InsertEnter and
InsertLeave events that fire when the cursor moves onto / off text that is
matched by a particular syntax group. You can use a custom :autocmd to
perform an action or change a Vim setting depending on the syntax under the
cursor.

### HOW IT WORKS

The plugin checks for changes to the syntax group under the cursor whenever
the cursor changes, and keeps track of the state using the event definition
name. Having many definitions or complex syntaxes may slow down cursor
movement noticeably, but the plugin takes care that only necessary hooks are
installed in the proper scope. So as long as you only have buffer-local
definitions, other buffers won't be affected at all.

### SEE ALSO

- With the SyntaxRange.vim plugin ([vimscript #4168](http://www.vim.org/scripts/script.php?script_id=4168)), you can define regions in
  a buffer that are highlighted with a different syntax (which could then
  trigger this plugin to change buffer options).

### RELATED WORKS

- hookcursormoved ([vimscript #2037](http://www.vim.org/scripts/script.php?script_id=2037)) allows to call a registered function when
  the syntax group under the cursor has changed, or a syntax group of a
  particular name has been left. It also offers other hooks like change of
  line number and movement into parentheses.

USAGE
------------------------------------------------------------------------------

    The following is an overview; you'll find the details directly in the
    implementation file .vim/autoload/OnSyntaxChange.vim.
    To set up User events for a particular syntax group, invoke:

    OnSyntaxChange#Install( name, SyntaxItemPattern, isBufferLocal, mode )

    You need to give your event definition a name; it is used to differentiate
    different setups and is included in the event names that will be generated:
        Syntax{name}Enter{MODE}
        Syntax{name}Leave{MODE}

    The SyntaxItemPattern is a regular expression that matches the syntax group;
    both the actual and effective names are considered (e.g. in Vimscript,
    "vimLineComment" is linked to "Comment").
    Alternatively, you can pass a Funcref that is invoked with an isInsertMode
    flag as the first argument and the syntax check position as the second
    argument (which is equal to the cursor position except when appending at the
    end of a line), and is supposed to return 1 or 0, depending on whether we're
    currently "on" or "off" the syntax. This can be used for advanced checking,
    but should in general be avoided for performance reasons.

    Events can be generated globally for all buffers, or just for a particular
    buffer; use the latter to create events for particular filetypes (via an
    :autocmd FileType or in a ~/.vim/ftplugin/{filetype}.vim script).

    The mode specifies whether the syntax check should only be performed in
    normal, insert, or any of both modes. For example:
        call OnSyntaxChange#Install('Comment', '^Comment$', 0, 'a')

    To handle the generated events, define one or more :autocmd for the User
    event, matching the event name, e.g.
        autocmd User SyntaxCommentEnterA unsilent echo "entered comment"
        autocmd User SyntaxCommentLeaveA unsilent echo "left comment"

### EXAMPLE

Enable 'list' when inside string (e.g. to see the difference between &lt;Tab&gt; and
&lt;Space&gt;).
This should only affect both modes, so mode is "a". Let's do this only for C
files:

    autocmd FileType c call OnSyntaxChange#Install('CString', 'String$', 1, 'a')
    autocmd FileType c autocmd User SyntaxCStringEnterA setlocal list
    autocmd FileType c autocmd User SyntaxCStringLeaveA setlocal nolist

(Better put these, without the :autocmd, into ~/.vim/after/ftplugin/c.vim)
(Note: Proper autocmd hygiene, i.e. use of autocmd-groups is recommended.)

------------------------------------------------------------------------------

Disable the AutoComplPop plugin ([vimscript #1879](http://www.vim.org/scripts/script.php?script_id=1879)) when inside a comment.
(Inspired by http://stackoverflow.com/questions/10723499/)
Let's do this globally. Since the completion only works in insert mode, use
mode "i".

    call OnSyntaxChange#Install('Comment', '^Comment$', 0, 'i')
    autocmd User SyntaxCommentEnterI silent! AcpLock
    autocmd User SyntaxCommentLeaveI silent! AcpUnlock

Same for the Neocomplete plugin (https://github.com/Shougo/neocomplete.vim):

    autocmd User SyntaxCommentEnterI silent! NeoCompleteLock
    autocmd User SyntaxCommentLeaveI silent! NeoCompleteUnlock

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-OnSyntaxChange
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim OnSyntaxChange*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.023 or
  higher.

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-OnSyntaxChange/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 1.10    19-Feb-2023
- ENH: Also support Funcref for a:SyntaxItemPattern to allow advanced syntax
  checking (or skipping syntax queried altogether and instead do a simple
  pattern matching around the cursor position).

##### 1.02    03-Nov-2018
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).

__You need to separately install ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version
  1.023 (or higher)!__

##### 1.01    17-Jan-2013
- Do not trigger modeline processing when triggering.

##### 1.00    25-May-2012
- First published version. Started development.

------------------------------------------------------------------------------
Copyright: (C) 2012-2023 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
