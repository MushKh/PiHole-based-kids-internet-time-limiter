<?lua
indexpage = false
mg.include('../scripts/lua/header_authenticated.lp','r')

local fname = "/var/www/html/admin/myserver/Parameters.txt"
local file, err = io.open(fname, "w")
if not file then
    mg.write("Cannot open file: " .. (err or "unknown"))
else
    file:write("Hello www-data!")
    file:close()
    mg.write("File written successfully!")
end

mg.include('../scripts/lua/footer.lp','r')
?>