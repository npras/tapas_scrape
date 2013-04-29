arr = %W|abc def ghi jkl mno pqr stu vwx yz|
i = 1
res = arr.map do |e|
  break if i > 2
  i += 1
  "#{e}: 1"
end

p "arr"
p arr
p
p "res"
p res
