require 'digest'

key = 'ckczppom'

md5 = Digest::MD5.new

hashed = ''
i = 0
while !hashed.start_with?('000000')
  i += 1
  md5.reset
  md5 << key
  md5 << i.to_s
  hashed = md5.hexdigest
end
puts hashed
puts i
