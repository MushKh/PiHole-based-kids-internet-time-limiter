<?lua
indexpage = false
mg.include('../scripts/lua/header_authenticated.lp','r')

local directory = "/var/www/html/admin/myserver"

mg.write('<div class="container-fluid">')
mg.write('<h1>Allowed time logs list</h1>')
mg.write('</div>')

-- List files safely
local handle = io.popen('ls -1 "' .. directory .. '" 2>/dev/null')

if handle then
    for file in handle:lines() do
        if file:match("%.html?$") then
            mg.write('<a href="' .. file .. '">' .. directory .. '/' .. file .. '</a><br>')
        end
    end
    handle:close()
end
mg.include('../scripts/lua/footer.lp','r')
?>

