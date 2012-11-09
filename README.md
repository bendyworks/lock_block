# Lock Block

Lock block is a command line (and vim-enabled) tool to help you get
a handle on your changing code.

## What?

You select a couple of lines of code, run the vim shortcut and then
you get special comment blocks above and below your code block. If
anything in that block changes, you'll know.

![Locked Block](lock_block/raw/master/doc/locked_block.png "Locked Block")

## Why?

*Comments lie* - comments tend to drift out of sync with the code
that they are supposed to be describing. But *why* does that happen?
Invariably, it is when we change some code, but because we aren't
*forced* to change the comments, they succumb to bit-rot. A Lock
Block surrounding the code and comments guarantees that you have
to address that whole section of code before you can commit.

*Tricky code* - I know, it is a sure sign that the code should be
refactored, but sometimes you have to leave in some grungy (but
very likely correct) code for a while. You can surround it in a
Lock Block to make sure that if it is touched, the would-be commiter
will know.

*Testing* - make sure that that your [legacy
code](http://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052/)
stays put while you get it under test.

## Usage

Installing this gem provides a command line program to annotate Ruby
code.

`lock_block [options] [filename]`

If a file is not specified, the program will read from STDIN.

<table>
  <caption>Options</caption>
<tbody>
  <tr>
    <td>--lock, -l</td>
    <td>(default) Lock the block. Wraps code in tagged annotation.</td>
  </tr>
  <tr>
    <td>--check, -c</td>
    <td>List all blocks thare are outdated.</td>
  </tr>
  <tr>
    <td>--resolve, -r</td>
    <td>Update tags in annotation to mark blocks as up to date.</td>
  </tr>
  <tr>
    <td>--guard, -g path-to-repo</td>
    <td>Installs pre-commit hook to repo to prevent committing broken locks.</td>
  </tr>
</tbody>
</table>

## Vim Configuration

Lock Block is good on its own but better with Vim. Add the
following to your `~/.vimrc`:

    function! LockBlockCheck(arg)
      let tmp1=&grepprg
      set grepprg=lock_block
      exe "silent! grep -c ".a:arg
      exe "cw"
      let &grepprg=tmp1
    endf
    command! -nargs=1 LBCheck call LockBlockCheck(<f-args>)
    " Check for broken locks in current file
    nmap <leader>lc :LBCheck %<CR>

    " Lock selected block
    vmap <silent> <Leader>ll !lock_block<CR>
    " Resolved selected blocks
    vmap <silent> <Leader>lr !lock_block -r<CR>

This will give you three commands:

<table>
<tbody>
  <tr>
    <td>&lt;leader&gt;lc</td>
    <td>Check the current file, open problems in quicklist.</td>
  </tr>
  <tr>
    <td>&lt;leader&gt;ll</td>
    <td>Replace selection with locked version.</td>
  </tr>
  <tr>
    <td>&lt;leader&gt;lr</td>
    <td>Resolve all blocks in selected region.</td>
  </tr>
</tbody>
</table>
