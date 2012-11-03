require 'minitest/autorun'
require 'lock_block'
include LockBlock


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
  describe '#lock_tag' do
    it 'handles empty input' do
      lock_tag('').must_equal "97d170e1550eee4afc0af065b78cda302a97674c"
    end

    it 'ignores spacing differences' do
      lock_tag('1+1').must_equal lock_tag('1 + 1')
    end

    it 'respects constant differences' do
      lock_tag('1+1').wont_be_same_as lock_tag('1+2')
    end

    it 'respects differing comments' do
      lock_tag('#hi').wont_be_same_as lock_tag('#bye')
    end

    it 'ignores Ruby indentation' do
      lock_tag(code_block).must_equal lock_tag(code_block_dedent)
    end
  end

  describe '#decorate' do
    it 'wraps a block of code' do
      code = "1+1\n"
      h = lock_tag code
      wrapped_code = "# lock do #{h}\n1+1\n# lock end #{h}"
      decorate(code).must_equal wrapped_code
    end
    it 'matches indentation' do
      code = "\t1+1\n"
      h = lock_tag code
      wrapped_code = "\t# lock do #{h}\n\t1+1\n\t# lock end #{h}"
      decorate(code).must_equal wrapped_code
    end
    it 'leaves non-Ruby untouched' do
      code         = "It isn't Ruby, is it?\n"
      expected_tag = lock_tag code
      wrapped_code = "# lock do #{expected_tag}\n#{code}# lock end #{expected_tag}"
      decorate(code).must_equal wrapped_code
    end
  end

  describe '#resolve' do
    it 'updates the hash on a block and leaves other lines untouched' do
      resolve(code_block_outdated).must_equal code_block_resolved
    end
  end
end
