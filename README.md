![Logo](lock_block/raw/master/doc/header.png "Logo")

Lock block is a command line (and vim-enabled) tool to help you get
a handle on your changing code.

## What?

You select a couple of lines of code and tell Lock Block to tag those
lines. Lock Block inserts special comment blocks above and below your selection.

By LockBlocking the lines, you are flagging that code as requiring special attention.
You are saying, “Don’t commit this without making sure it’s OK.”

The magic is that each pair of tags has a hashcode generated from all of the characters
in the lines between the tags. <strong>Except.</strong> And this is important: the hash
is not generated until logically non-significant whitespace has been removed
from that content. Blank lines, indentation (of non-line-oriented code), and sequences of
multiple spaces can all be edited without changing the generated hashcode.

Lock Block can detect when content has been edited by simply recomputing its hashcode and
comparing that with the hashcode recorded in the tags.

Lock Block can be used deliberately to search for, and fix, out-of-rev hashcodes. Much more
seriously, Lock Block can be configured as an interceptor to prevent git commits from
completing when an out-of-rev hashcode is detected.

What does a commit tag look like?
![Locked Block](lock_block/raw/master/doc/locked_block.png "Locked Block")

Things to know about Lock Blocks:
<ul>
<li>They are <em>pairwise independent</em>. No set of tags has any logical
  relationship to any other set of tags.</li>
<li> They can be nested, overlapped, or separated by intervening lines.
  This is not like HTML's nested structure.</li>
<li>Tags can be deleted by ordinary editing. However, it's important to remember that
  orphaned start or end tags are treated as a serious problem, and Lock Block will
  pester you without mercy until you fix that.</li>
</ul>


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

## Credits

Thank you, [contributors](lock_block/graphs/contributors)!

![Bendyworks](http://bendyworks.com/assets/bendyworks_logo.png)

Lock Block is maintained by [Bendyworks, Inc](http://bendyworks.com).

## License

Lock Block is Copyright © 2012 Joe Nelson and Bendyworks, Inc. It
is free software, and may be redistributed under the terms specified
in the LICENSE file.

![Footer](lock_block/raw/master/doc/bendyworks_github_footer.png "Footer")
