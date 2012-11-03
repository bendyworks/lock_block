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
    h = lock_tag source
    "#{indent}# lock do #{h}\n#{source}#{indent}# lock end #{h}"
  end

  def resolve source
    tags(source).each do |tag|
      resolved_tag = lock_tag innards(source, tag)
      source = update_tag source, tag, resolved_tag
    end
    source
  end

  def broken_locks source
    broken = []
    source.lines.each_with_index do |line, number|
      if tags(line).any?
        got      = tags(line).first
        expected = lock_tag innards(source, got)
        if got != expected
          broken.push({line: number+1, expected: expected, got: got})
        end
      end
    end
    broken
  end

  def tags source
    source.scan(/# lock do ([a-f0-9]{40})/).map &:first
  end

  def update_tag source, old_tag, new_tag
    source.gsub /# lock (do|end) #{old_tag}/, "# lock \\1 #{new_tag}"
  end

  def innards source, tag
    match = source.match /# lock do #{tag}\n(.*?)# lock end #{tag}/m
    match ? match[1] : ''
  end
end
