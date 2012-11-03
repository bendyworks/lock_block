require 'minitest/autorun'
require 'lock_block'

code_block = <<EOT
def foo x
  x + 1
end
EOT

code_block_dedent = <<EOT
def foo x
x + 1
end
EOT

code_block_outdated = <<EOT
# stuff
# lock do 0000000000000000000000000000000000000000
1+1
# lock end 0000000000000000000000000000000000000000
# bother
# lock do 0000000000000000000000000000000000000000
1+2
# lock end 0000000000000000000000000000000000000000
EOT

code_block_resolved = <<EOT
# stuff
# lock do 921fbda07b9630c541f486c666238d1c0d6384c8
1+1
# lock end 921fbda07b9630c541f486c666238d1c0d6384c8
# bother
# lock do 921fbda07b9630c541f486c666238d1c0d6384c8
1+2
# lock end 921fbda07b9630c541f486c666238d1c0d6384c8
EOT

describe LockBlock do
  describe '#tag' do
    it 'ignores spacing differences' do
      LockBlock.tag('1+1').must_equal LockBlock.tag('1 + 1')
    end

    it 'respects constant differences' do
      LockBlock.tag('1+1').wont_be_same_as LockBlock.tag('1+2')
    end

    it 'respects differing comments' do
      LockBlock.tag('#hi').wont_be_same_as LockBlock.tag('#bye')
    end

    it 'ignores Ruby indentation' do
      LockBlock.tag(code_block).must_equal LockBlock.tag(code_block_dedent)
    end
  end

  describe '#lock' do
    it 'wraps a block of code' do
      code = "1+1\n"
      h = LockBlock.tag code
      wrapped_code = "# lock do #{h}\n1+1\n# lock end #{h}"
      LockBlock.lock(code).must_equal wrapped_code
    end
    it 'matches indentation' do
      code = "\t1+1\n"
      h = LockBlock.tag code
      wrapped_code = "\t# lock do #{h}\n\t1+1\n\t# lock end #{h}"
      LockBlock.lock(code).must_equal wrapped_code
    end
    it 'leaves non-Ruby untouched' do
      code         = "It isn't Ruby, is it?\n"
      expected_tag = LockBlock.tag code
      wrapped_code = "# lock do #{expected_tag}\n#{code}# lock end #{expected_tag}"
      LockBlock.lock(code).must_equal wrapped_code
    end
  end

  describe '#resolve' do
    it 'updates the hash on a block and leaves other lines untouched' do
      LockBlock.resolve(code_block_outdated).must_equal code_block_resolved
    end
  end

  describe '#broken_locks' do
    it 'finds line numbers of lock blocks that are outdated' do
      errs = LockBlock.broken_locks code_block_outdated
      errs.length.must_equal 2
      errs[0][:line].must_equal 2
      errs[1][:line].must_equal 6
    end
  end
end
