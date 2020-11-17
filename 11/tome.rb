$i = 'i'.ord
$o = 'o'.ord
$l = 'l'.ord
$z = 'z'.ord
$a = 'a'.ord

def disallowed(s)
  s.include?($i) || s.include?($o) || s.include?($l)
end

def triad(s)
  return false if s.length < 3

  (2...s.length).each do |i|
    return true if s[i - 2] == s[i] - 2 && s[i - 1] == s[i] - 1
  end

  false
end

def pairs(s)
  last_pair = -1
  pairs = []
  (1...s.length).each do |i|
    if s[i] == s[i - 1] && i - last_pair >= 2
      last_pair = i
      pairs << i
    end
  end
  pairs.length
end

def check(s)
  !disallowed(s) && triad(s) && pairs(s) >= 2
end

def advance(s)
  i = s.length - 1
  c = false
  loop do
    c = s[i] == $z
    s[i] = (((s[i] - $a) + 1) % 26) + $a
    i -= 1
    break if !c || i < 0
  end
end

def next_password(pass)
  n = pass.bytes
  loop do
    advance(n)
    break if check(n)
  end
  n.pack('c*')
end

nx = next_password('hxbxwxba')
nxx = next_password(nx)
p nxx


