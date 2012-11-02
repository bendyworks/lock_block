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

    it 'ignores indentation' do
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
  end
end
