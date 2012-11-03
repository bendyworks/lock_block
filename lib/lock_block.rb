require 'lock_block/version'
require 'ripper'
require 'digest/sha1'

module LockBlock
  def LockBlock.lock source
    indent = source.match(/^(\s+)/) ? $1 : ''
    tag    = tag source
    "#{indent}# lock do #{tag}\n#{source}#{indent}# lock end #{tag}"
  end

  def LockBlock.resolve source
    tags(source).each do |tag|
      resolved_tag = tag innards(source, tag)
      source = update_tag source, tag, resolved_tag
    end
    source
  end

  def LockBlock.broken_locks source
    broken = []
    source.lines.each_with_index do |line, number|
      if tags(line).any?
        got      = tags(line).first
        expected = tag innards(source, got)
        if got != expected
          broken.push({line: number+1, expected: expected, got: got})
        end
      end
    end
    broken
  end

  def LockBlock.tag source
    tokens = Ripper.tokenize(source).select do |t|
      t.gsub(/\s+/, "") != ''
    end
    Digest::SHA1.hexdigest tokens.to_s
  end

  def LockBlock.tags source
    source.scan(/# lock do ([a-f0-9]{40})/).map &:first
  end

  def LockBlock.update_tag source, old_tag, new_tag
    source.gsub /# lock (do|end) #{old_tag}/, "# lock \\1 #{new_tag}"
  end

  def LockBlock.innards source, tag
    match = source.match /# lock do #{tag}\n(.*?)# lock end #{tag}/m
    match ? match[1] : ''
  end
end
