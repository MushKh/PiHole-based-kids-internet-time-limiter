<?lua
-- IMPORTANT: no whitespace before this tag

local request = mg.request_info
local query = request.query_string or ""
local allowed_hours = query:match("get_minutes=([^&]+)")

if allowed_hours then
    -- URL decode
    allowed_hours = allowed_hours:gsub("%+", " ")
    allowed_hours = allowed_hours:gsub("%%(%x%x)", function(h)
        return string.char(tonumber(h,16))
    end)

    allowed_hours = allowed_hours:gsub("^%s*(.-)%s*$", "%1")

    -- File path
    local path = debug.getinfo(1,'S').source:sub(2)
    local dir = path:match("(.*/)")
    local fname = dir .. "Parameters.txt"

    local file = io.open(fname, "w")
    if file then
        file:write(allowed_hours)
        file:close()
    end

    -- Output minimal HTML with redirect
    mg.write("<!DOCTYPE html>")
    mg.write("<html>")
    mg.write("<head>")
    mg.write('<meta http-equiv="refresh" content="0;url=/admin/index.lp?allowed_hours=' .. allowed_hours .. '">')
    mg.write("</head>")
    mg.write("<body></body>")
    mg.write("</html>")
else
    mg.write("<!DOCTYPE html>")
    mg.write("<html>")
    mg.write("<head>")
    mg.write('<meta http-equiv="refresh" content="0;url=/admin/index.lp">')
    mg.write("</head>")
    mg.write("<body></body>")
    mg.write("</html>")
end
?>
