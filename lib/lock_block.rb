require 'lock_block/version'
require 'ripper'
require 'digest/sha1'

module LockBlock
  def lock_tag source
    tokens = Ripper.tokenize(source).select do |t|
      t.gsub(/\s+/, "") != ''
    end
    Digest::SHA1.hexdigest tokens.to_s
  end

  def decorate source
    indent = source.match(/^(\s+)/) ? $1 : ''
    h = lock_tag(source)
    "#{indent}# lock do #{h}\n#{source}#{indent}# lock end #{h}"
  end
end
