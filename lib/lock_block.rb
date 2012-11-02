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
    indent = source.match(/^(\s+)/)[0] || ""
    h = indent + lock_tag(source)
    "# lock do #{h}\n#{source}# lock end #{h}"
  end
end
