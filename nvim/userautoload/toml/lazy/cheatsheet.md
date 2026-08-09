# Cheat Sheet

## vim

### note

`<Leader>` is set to `<Space>`.

### move

#### cursor

- `h` : Right
- `j` : Down
- `k` : Up
- `l` : Left

#### word

- `w`   : Word, symbol-delimited, to the next start
- `b`   : Word, symbol-delimited, to the previous start
- `e`   : Word, symbol-delimited, to the next end
- `ge`  : Word, symbol-delimited, to the previous end
- `W`   : Word, whitespace-delimited, to the next start
- `B`   : Word, whitespace-delimited, to the previous start
- `E`   : Word, whitespace-delimited, to the next end
- `gE`  : Word, whitespace-delimited, to the previous end

#### line

- `0`    : To the beginning of the line
- `^`, `H` : To the beginning of the line (first non-whitespace)
- `$`, `L` : To the end of the line

- `<Leader>w`   : Jump to marker (word, symbol-delimited, next start after cursor)
- `<Leader>b`   : Jump to marker (word, symbol-delimited, previous start before cursor)
- `<Leader>e`   : Jump to marker (word, symbol-delimited, next end after cursor)
- `<Leader>ge`  : Jump to marker (word, symbol-delimited, previous end before cursor)
- `<Leader>W`   : Jump to marker (word, whitespace-delimited, next start after cursor)
- `<Leader>B`   : Jump to marker (word, whitespace-delimited, previous start before cursor)
- `<Leader>E`   : Jump to marker (word, whitespace-delimited, next end after cursor)
- `<Leader>gE`  : Jump to marker (word, whitespace-delimited, previous end before cursor)

- `<Leader>h{char}` : Jump to marker (directly above {char}, left of cursor)
- `<Leader>l{char}` : Jump to marker (directly above {char}, right of cursor)
- `<Leader>H{char}` : Jump to marker (before {char}, left of cursor)
- `<Leader>L{char}` : Jump to marker (before {char}, right of cursor)

- `f{char}` : Jump to marker (directly above {char})
- `t{char}` : Jump to marker (before {char})

#### column

- `<Leader>j` : Jump to marker (down)
- `<Leader>k` : Jump to marker (up)

#### object

- `(`  : Up by sentence
- `)`  : Down by sentence
- `{`  : Up by paragraph
- `}`  : Down by paragraph
- `[[` : Up by section
- `]]` : Down by section

#### scroll

- `<C-u>`             : Scroll up half a screen
- `<C-d>`             : Scroll down half a screen
- `<C-b>`, `<PageUp>`   : Scroll up one screen
- `<C-f>`, `<PageDown>` : Scroll down one screen

#### mark

integrated with  `kshenoy\vim-signature`
cf. https://github.com/kshenoy/vim-signature/blob/master/README.md

- `mx`           : Toggle mark 'x' and display it in the leftmost column
- `dmx`          : Remove mark 'x' where x is a-zA-Z

- `m,`           : Place the next available mark
- `m.`           : If no mark on line, place the next available mark. Otherwise, remove (first) existing mark.
- `m-`           : Delete all marks from the current line
- `m<Space>`     : Delete all marks from the current buffer
- ``]` ``          : Jump to next mark
- ``[` ``          : Jump to prev mark
- `]'`           : Jump to start of next line containing a mark
- `['`           : Jump to start of prev line containing a mark
- `` `]``          : Jump by alphabetical order to next mark
- `` `[``          : Jump by alphabetical order to prev mark
- `']`           : Jump by alphabetical order to start of next line having a mark
- `'[`           : Jump by alphabetical order to start of prev line having a mark
- `m/`           : Open location list and display marks from current buffer

- `m[0-9]`       : Toggle the corresponding marker `!@#$%^&*()`
- `m<S-[0-9]>`   : Remove all markers of the same type
- `]-`           : Jump to next line having a marker of the same type
- `[-`           : Jump to prev line having a marker of the same type
- `]=`           : Jump to next line having a marker of any type
- `[=`           : Jump to prev line having a marker of any type
- `m?`           : Open location list and display markers from current buffer
- `m<BS>`        : Remove all markers

#### other

- `gg` : To the beginning of the file
- `G`  : To the end of the file
- `I`  : Insert mode at the beginning of the line
- `A`  : Insert mode at the end of the line
- `S`  : Delete the line and enter insert mode
- `J`  : Join lines separated by a space (prefix a number to repeat)
- `gJ` : Join lines (prefix a number to repeat)
- `<F12>` : Toggle line number display (relative to absolute)

### I/O

- `:w` : Save
- `:wa` : Save all buffers
- `:q` : Close the window
- `:qa` : Quit vim
- `:wq` : Save and close the window
- `:x` : Save (only if modified) and close the window
- `:wqa`, `:xa` : Save all buffers and quit vim

- `:e {filename}` : Open {filename} (relative or absolute path)

### yank

- `"0p` : Paste the contents of register `"0` (`"0` is not used when deleting with `dd` etc.)

### fold

- ~`zf` : Create new~ not available
- `zo` : Open
- `zc` : Close
- `za` : Toggle fold state
- `zr` : Open one level of the whole file
- `zR` : Open all folds of the whole file
- `zm` : Close one level of the whole file
- `zM` : Close all folds of the whole file
- `zj` : Move to the next fold
- `zk` : Move to the previous fold
- `[z` : Move to the start of the current fold
- `]z` : Move to the end of the current fold

### pane

- `sv`: Split vertically
- `ss`: Split horizontally
- `sh`: To the left pane
- `sj`: To the lower pane
- `sk`: To the upper pane
- `sl`: To the right pane
- `sw`: To the next pane
- `sH`: Move pane to the left
- `sJ`: Move pane down
- `sK`: Move pane up
- `sL`: Move pane to the right
- `sr`: Rotate panes

### buffer

- `sn`       : Next
- `sp`       : Previous
- `sd`       : Delete
- `:b {name}` : Switch to the specified buffer (completable)

### tab

- `st`    : Create a new empty tab
- `<M-l>` : Next
- `<M-h>` : Previous
- `sx`    : Delete

### macro

- `q(a-z)`       : Start recording
- `q`            : Stop recording
- `[number]@(a-z)` : Run the macro that many times

### coc.nvim

- `<tab>` : Start completion
- `<C-j>` : (when a snippet can be expanded) expand the snippet
- `<C-j>` : (while expanding a snippet) jump to the next placeholder
- `<C-k>` : (while expanding a snippet) jump to the previous placeholder
- `=G`    : Format code using LSP
- `[c` : Jump to the previous warning
- `]c` : Jump to the next warning

### location list

- `:lop[en]`     : Open the location list
- `:lcl[ose]`    : Close the location list
- `:lne[xt]`     : Next
- `:lp[revious]` : Previous

### help

- `:h[elp] ${name}`        : Show help in a split window
- `:h[elp] ${name} | only` : Show help fullscreen
- `<C-]>`                  : Jump to the item
- `<C-o>`                  : Go back to the previous location
- `K`                      : Look up the keyword under the cursor
- `<F1>`                   : Toggle this cheat sheet

### EasyMotion

- `;{char}{char}{label}` : Jump to the position of the two characters typed after `;`. If there are multiple positions, jump labels are shown
- `f{char}{label}` : Jump to {char} to the right of the cursor on the current line. If there are multiple positions, labels are shown
- `F{char}{label}` : Jump to {char} to the left of the cursor on the current line. If there are multiple positions, labels are shown
- `<leader>k{label}` : Jump to the line where {label} is shown, above the cursor
- `<leader>j{label}` : Jump to the line where {label} is shown, below the cursor

### Denite

- `:Dgrep`   : Denite grep
- `:Dresume` : Reopen the closed search results
- `:Dprev`   : To the previous search result
- `:Dnext`   : To the next search result
- `<C-n>`    : (search result dialog) next
- `<C-p>`    : (search result dialog) previous

### Defx

- `<C-u>` : Open defx

The following are only valid inside the defx buffer

- `h`       : Go back to the parent directory
- `j`       : Move down
- `k`       : Move up
- `l`, `<CR>` : Open the file/directory on the cursor line
- `E`      : Open the file in the left pane with a vertical split
- `~`       : Jump to the root directory
- `o`       : Toggle file tree expansion
- `N`       : Create a new file
- `M`       : Create new files (multiple)
- `K`       : Create a new directory
- `r`       : Rename
- `d`       : Delete file/directory
- `c`       : Copy file/directory
- `m`       : Cut file/directory
- `p`       : Paste the copied/cut file/directory
- `C`       : Toggle detailed information display
- `S`        : Sort by modification time
- `cd`      : Make the current location vim's current directory
- `!{command}<CR>`: Run a shell command
- `yy`           : Yank the path of the file/directory on the cursor line
- `<Space>`        : Select the file/directory on the cursor line and move the cursor down

- `q` : Close defx

### git

- `<Leader>gs`      : Show status
- `<Leader>gb`      : Show branches
- `<Leader>gl`      : Show log
- `<Leader>gc`      : Show the commit edit window
- `<Leader>gm`      : Show the commit message for the cursor position

### vim-go

- `:GoImport ${name}` : Add to imports, tab completion available
- `:GoDrop ${name}`   : Remove from imports, tab completion available
- `:GoImports`        : Add missing packages to imports
- `dif`               : Delete the function body
- `vif`               : Select the function body
- `yif`               : Yank the function body
- `daf`               : Delete the whole function
- `vaf`               : Select the whole function
- `yaf`               : Yank the whole function
- `:GoAlternate`      : Switch between foo.go and foo_test.go
- `:GoDef`            : Jump to definition
- `:GoDoc`            : Open documentation
- `:GoDocBrowser`     : Open documentation in a browser
- `<Leader>i`         : GoInfo = show info under the cursor
- `:GoRename`         : Rename the element under the cursor

## c.f

source:[VIM Cheatsheet](https://gist.github.com/0xadada/1ea7f96d108dcfbe75c9)

_Motion, keyboard commands and shortcuts for VI Improved_

* [Legend](#legend)
  * [Motion / Normal mode](#motion---normal-mode)
  * [Insert mode](#insert-mode)
  * [Changes](#changes)
  * [Yank/Put or Copy/Paste](#yankput-or-copypaste)
  * [Visual/Visual Block Mode](#visual--visual-block-mode)
  * [Commands](#commands)
  * [Files](#files)
  * [Windows](#windows)
  * [Tabs](#tabs)
  * [coc.nvim](#cocnvim)
  * [Denite](#denite)
  * [Help](#help)
  * [Search/Replace](#search--replace)
  * [Find Files](#find-files)

    ![Graphic](http://i.imgur.com/HkCjM63.png)

## Legend

    |  Command      | Keyboard Character           |
    |  :---         | :---:                        |
    |  command      | <kbd>⌘</kbd>                 |
    |  control      | <kbd>⌃</kbd>                 |
    |  alt          | <kbd>⎇</kbd>                 |
    |  delete       | <kbd>⌫</kbd>                 |
    |  option       | <kbd>⌥</kbd>                 |
    |  shift        | <kbd>⇧</kbd>                 |
    |  caps lock    | <kbd>⇪</kbd>                 |
    |  tab          | <kbd>⇥</kbd>                 |
    |  arrow up     | <kbd>↑</kbd>                 |
    |  arrow down   | <kbd>↓</kbd>                 |
    |  arrow left   | <kbd>←</kbd>                 |
    |  arrow right  | <kbd>→</kbd>                 |
    |  escape       | <kbd>⎋</kbd> or <kbd>␛</kbd> |
    |  return/enter | <kbd>⏎</kbd> or <kbd>⌤</kbd> |
    |  home         | <kbd>↖</kbd>                 |
    |  end          | <kbd>↘</kbd>                 |
    |  page up      | <kbd>⇞</kbd>                 |
    |  page down    | <kbd>⇟</kbd>                 |

## Motion - Normal Mode

    * <kbd>j</kbd>          - Down
    * <kbd>k</kbd>          - Up
    * <kbd>h</kbd>          - Left
    * <kbd>l</kbd>          - Right
    * <kbd>0</kbd>, <kbd>⇧6</kbd>    - Line beginning
    * <kbd>$</kbd>          - Line ending
    * <kbd>e</kbd>, <kbd>w</kbd>     - Forward (Small word)
    * <kbd>⇧e</kbd>, <kbd>⇧w</kbd>     - Forward (big word forward (whitespace only))
    * <kbd>b</kbd>          - Backwards (small word)
    * <kbd>⇧b</kbd>          - Backwards (big word)
    * <kbd>f&lt;char&gt;</kbd>    - Jump to first occurrence of &lt;char&gt;
    * <kbd>;</kbd>          - Repeat previous jump
    * <kbd>⇧f&lt;char&gt;</kbd>    - Jump to previous first occurrence of &lt;char&gt;
    * <kbd>t&lt;char&gt;</kbd>    - Jump to position before first occurrence of &lt;char&gt;
    * <kbd>⇧t&lt;char&gt;</kbd>    - Jump to position before first previous occurrence of &lt;char&gt; in the direction youre searching
    * <kbd>&lt;n&gt; &lt;motion&gt;</kbd> - Prefix `motion` command with a number `n` to have it jump that `n` away. e.g. <kbd>4li</kbd> jumps to the 4th 'i' forward.
    * <kbd>⌃f</kbd>         - Forward (page)
    * <kbd>⌃b</kbd>         - Backward (page)
    * <kbd>⌃u</kbd>         - Upward (half page)
    * <kbd>⌃d</kbd>         - Downward (half page)
    * <kbd>⇧h</kbd>         - Head (of current page)
    * <kbd>⇧m</kbd>         - Middle (of current page)
    * <kbd>⇧l</kbd>         - Lowest (of current page)
    * <kbd>gg</kbd>         - Go to top of file
    * <kbd>⇧gg</kbd>        - Go to bottom of file
    * <kbd>&lt;n&gt;⇧g</kbd>      - Go to line `n`
    * <kbd>][</kbd>         - Jump to next matching brace
    * <kbd>[]</kbd>         - Jump to previous matching brace
    * <kbd>%</kbd>          - Jump between matching braces
    * <kbd>za</kbd>         - Toggle code fold
    * <kbd>zo</kbd>         - Open code fold
    * <kbd>zc</kbd>         - Close code fold
    * <kbd>zr</kbd>         - Open one layer of code folds
    * <kbd>z⇧r</kbd>        - Open all code folks

## Insert Mode

    These commands are entered while in Normal or visual mode.

    * <kbd>i</kbd>                - Insert at cursor
    * <kbd>⇧i</kbd>               - Insert at line beginning
    * <kbd>a</kbd>                - Append after cursor
    * <kbd>ea</kbd>               - Append after word at cursor
    * <kbd>⇧a</kbd>               - Append at end of line
    * <kbd>o</kbd>                - Insert line below cursor
    * <kbd>⇧o</kbd>               - Insert line above cursor
    * <kbd>x</kbd>                - Delete character under cursor
    * <kbd>⇧x</kbd>               - Delete character before cursor
    * <kbd>dd</kbd>               - Delete line at cursor position
    * <kbd>d &lt;motion&gt;</kbd> - Delete amount by motion command e.g. <kbd>dw</kbd> delete small word
    * <kbd>c &lt;motion&gt;</kbd> - Change by motion e.g. <kbd>cw</kbd> overwrite small word
    * <kbd>r</kbd>                - Replace character at cursor
    * <kbd>⇧r</kbd>               - Replace overwriting text
    * <kbd>^v u &lt;codepoint&gt;</kbd> - Insert unicode character at `codepoint`
    * <kbd>␛</kbd>                - Exit insert mode

## Changes

    * <kbd>⇧j</kbd>            - Join line with line below
    * <kbd>c(f|t)&lt;char&gt;</kbd>  - Change characters (inclusive with f or exclusive with t) to `char`

## Yank/Put or Copy/Paste

    * <kbd>yw</kbd>         - Yank word into buffer
    * <kbd>yy</kbd>         - Yank line into buffer
    * <kbd>&lt;n&gt;yy</kbd>- Yank `n` lines into buffer
    * <kbd>y &lt;motion&gt;</kbd> - Yank into buffer by `motion`
    * <kbd>x</kbd>          - Yank character at cursor
    * <kbd>p</kbd>          - Put buffer after cursor
    * <kbd>⇧p</kbd>         - Put buffer before cursor

## Visual / Visual Block Mode

    Visual mode is used for marking text.

    * <kbd>v</kbd>          - Visual mode
    * <kbd>V</kbd>          - Visual line-based mode
    * <kbd>⌃v</kbd>         - Visual block mode
    * <kbd>gv</kbd>         - Re-select previous Visual block buffer
    * <kbd>o</kbd>          - Jump to other end of block
    * <kbd>⇧o</kbd>         - Jump to other corner of block
    * <kbd>vaw</kbd>        - Visual select a word (includes whitespace)
    * <kbd>viw</kbd>        - Vissual select inner word (no whitespace)
    * <kbd>vap</kbd>        - Visual select a paragraph
    * <kbd>vip</kbd>        - Visual select inner paragraph
    * <kbd>va[</kbd>        - Visual select [] block and contents
    * <kbd>vi[</kbd>        - Visual select [] contents only
    * <kbd>va{</kbd>        - Visual select {} block and contents
    * <kbd>vi{</kbd>        - Visual select {} contents only
    * <kbd>va(</kbd>        - Visual select () block and contents
    * <kbd>vi(</kbd>        - Visual select () contents only
    * <kbd>va<</kbd>        - Visual select <> block and contents
    * <kbd>vi<</kbd>        - Visual select <> contents only
    * <kbd>va"</kbd>        - Visual select all double quote and contents
    * <kbd>vi"</kbd>        - Visual select inner quoted contents
    * <kbd>vit</kbd>        - Visual select inner XML/HTML tag contents
    * <kbd>vat</kbd>        - Visual select all XML/HTML tag contents
    * <kbd>v&lt;motion&gt;</kbd> - Visually mark text by `motion` command
    * <kbd>␛</kbd>          - Exit visual mode

    The following commands can be used while text is marked.

    * <kbd>c</kbd>          - Delete and begin inserting (To replace currently marked text)
    * <kbd>d</kbd>          - Delete
    * <kbd>y</kbd>          - Yank
    * <kbd>&gt;</kbd>       - Indent right
    * <kbd>&lt;</kbd>       - Indent left

## Commands

    * <kbd>.</kbd>           - Repeat previous command
    * <kbd>u</kbd>           - Undo previous command
    * <kbd>⇧u</kbd>          - Undo all changes to current line
    * <kbd>⌃r</kbd>          - Redo
    * <kbd>:q</kbd>           - Quit
    * <kbd>:q!</kbd>          - Quit (without saving changes)

## Files

    * <kbd>:e &lt;path&gt;</kbd>           - OpEn file into buffer
    * <kbd>:w</kbd>                  - Write buffer to file
    * <kbd>:ls</kbd>                 - List open buffers
    * <kbd>:(b|buf|buffer) &lt;n&gt;</kbd> - Switch to buff `n`
    * <kbd>:(bd|bdelete) &lt;n&gt;</kbd>   - Delete buffer `n` (close file)
    * <kbd>:bp</kbd>                 - Switch to previous buffer
    * <kbd>:bn</kbd>                 - Switch to next buffer

## Windows

    * <kbd>⌃wo</kbd> - make current window the Only window
    * <kbd>:(sp|spl|split) &lt;path&gt;</kbd> - SPlit window horizontally, optionally loading file at `path`
    * <kbd>:vsp &lt;path&gt;</kbd>            - Vertically SPlit window, optionally loading file at `path`
    * <kbd>ss</kbd> - Window split (horizontally)
    * <kbd>sv</kbd> - Window split (vertically)
    * <kbd>⌃wx</kbd> - Windows eXchange, swap their position
    * <kbd>⌃wk</kbd> - Move window up
    * <kbd>⌃wj</kbd> - Move window down
    * <kbd>⌃wh</kbd> - Move window left
    * <kbd>⌃wl</kbd> - Move window right
    * <kbd>⌃wp</kbd> - Move window previous
    * <kbd>⌃wc</kbd> - Window close
    * <kbd>⌃w=</kbd> - Balance windows
    * <kbd>⌃w+</kbd> - Grow horizontal window split by 1
    * <kbd>⌃w-</kbd> - Shrink horizontal window split by 1
    * <kbd>⌃w></kbd> - Grow vertical window split by 1
    * <kbd>⌃w<</kbd> - Shrink vertical window split by 1
    * <kbd>:(resize|res) (+|-)&lt;n&gt;</kbd> - Horizontal resize to `n` or increase/decrease by `n`
    * <kbd>:vertical resize (+|-)&lt;n&gt;</kbd> - Vertical resize to `n` or increase/decrease by `n`

## Tabs

    * <kbd>sN</kbd>          - GoTo next tab
    * <kbd>sP</kbd>         - Goto previous tab
    * <kbd>&lt;n&gt;gt</kbd> - Goto tab `n`
    * <kbd>:tabedit &lt;file&gt;</kbd> - Edit specified file in a new tab
    * <kbd>:tabfind &lt;file&gt;</kbd> - Open a new tab with filename given
    * <kbd>sx</kbd>  - Close tab
    * <kbd>:tabclose &lt;n&gt;</kbd>  - Close tab `n`
    * <kbd>:tabonly</kbd>   - Close all other tabs

## Help

    * <kbd>:h</kbd> - Open Help
    * <kbd>⌃]</kbd> - Activate link at cursor
    * <kbd>⌃T</kbd> - Back

## Search / Replace

    * <kbd>/&lt;pattern&gt;</kbd>  - Search forward for `pattern`
    * <kbd>?&lt;pattern&gt;</kbd>  - Search backward for `pattern`
    * <kbd>n</kbd>                 - Jump to next match in searching direction
    * <kbd>⇧n</kbd>                - Jump to next match in opposite direction
    * <kbd>:&lt;range&gt;s/&lt;foo&gt;/&lt;bar&gt;/[g,i,I,c]</kbd> - Replace `old`
      with `new`.
        `range` is either empty, `%` for whole file, or a line number.
          `g` flag replaces all occurrances on the line.
            `i` ignores case. `I` doesn't ignore case. `c` asks for confirmation.
    * <kbd>* &lt;n|⇧n&gt;</kbd>    - Search forward for word at cursor, `n` jumps to Next result, `N` jumps to previous
    * <kbd># &lt;n|⇧n&gt;</kbd>    - Search backward for word at cursor, `n` jumps to Next result, `N` jumps to previous

## Find Files

    For finding patterns in files. Use <kbd>:vimgrep</kbd> if unsure if the `grep`
    command-line utility is available, but <kbd>:grep</kbd> is generally
    faster. All searches fill a buffer that is accessible by the
    <kbd>:cw</kbd> command.

    * <kbd>:vimgrep /&lt;pattern&gt;/[g][j] &lt;path/**/*&gt;</kbd> - Search for regex `pattern` located in `path`.
      The `g` option specifies that all matches for a search will be returned instead of just one per line,
            and the `j` option specifies that Vim will not jump to the first match automatically.
    * <kbd>:grep &lt;pattern&gt; &lt;path&gt;</kbd> - Search for regex `pattern` located in `path`.

