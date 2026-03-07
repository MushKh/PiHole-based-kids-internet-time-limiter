<?lua
indexpage = false
mg.include('../scripts/lua/header_authenticated.lp','r')

local path = debug.getinfo(1,'S').source:sub(2)  -- gets current file
local dir = path:match("(.*/)")
local fname = dir .. "Parameters.txt"
local f = io.open(fname, "r")

if f then
  mg.write("<pre>")
  mg.write(f:read("*a"))
  mg.write("</pre>")
  f:close()
else
  mg.write("<div class='alert alert-danger'>Cannot open Parameters.txt</div>")
end

mg.include('../scripts/lua/footer.lp','r')
?>