$row = 3010
$column = 3019

$start = 20151125
$factor = 252533
$divisor = 33554393

def nth(row, col)
  row_diff = 1
  nth = 1
  (row - 1).times do
    nth += row_diff
    row_diff += 1
  end
  col_diff = row_diff + 1
  (col - 1).times do
    nth += col_diff
    col_diff += 1
  end
  nth
end

def code(nth)
  code = $start
  (nth - 1).times do
    code *= $factor
    code = code % $divisor
  end
  code
end

nth = nth($row, $column)
p code(nth)
