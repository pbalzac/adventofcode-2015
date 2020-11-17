a = [1, 1, 1, 3, 2, 2, 2, 1, 1, 3]

(1..50).each do
  b = []
  i = 0
  n = a[i]
  c = 1
  i += 1
  while i < a.size
    if a[i] != n
      b << c
      b << n
      n = a[i]
      c = 1
    else
      c += 1
    end
    i += 1
  end
  b << c
  b << n
  a = b
end

puts a.size
