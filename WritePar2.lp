<?lua
indexpage = false
mg.include('../scripts/lua/header_authenticated.lp','r')

-- Save to file
local path = debug.getinfo(1,'S').source:sub(2)  -- gets current file
local dir = path:match("(.*/)")	
local fname = dir .. "Parameters.txt"



-- Get POST data
local post_data = mg.request_info.post_data or ""
local allowed_hours = post_data:match("get_minutes=([^&]+)")



if allowed_hours then
    -- URL decode (+ and %xx)
    allowed_hours = allowed_hours:gsub("+", " ")
    allowed_hours = allowed_hours:gsub("%%(%x%x)", function(h)
        return string.char(tonumber(h,16))
    end)

	-- Attempt to open the file for reading
	local f, err = io.open(fname, "r")
	if f then
		mg.write("<div>")
		mg.write(f:read("*a"))  -- read entire file
		mg.write("</div>")
		mg.write("<div>")
		mg.write(allowed_hours or "NON") -- show submitted value if any
		mg.write("</div>")
		f:close()
	else
		mg.write("<div class='alert alert-danger'>Cannot open Parameters.txt: " .. (err or "unknown error") .. "</div>")
	end

    local file = io.open(fname, "w")
    if file then
        file:write(allowed_hours)
        file:close()
    end

    -- Prepare message
    local message = allowed_hours .. " minutes saved to memory"

    -- Get referer URL
    local referer = mg.request_info.http_headers["Referer"] or ""
    local base_url = referer:match("^[^?]+")

    if base_url then
        mg.write("Status: 302 Found\r\n")
        mg.write("Location: " .. base_url .. "?message=" .. mg.url_encode(message) .. "\r\n\r\n")
    end

    return
end
mg.include('../scripts/lua/footer.lp','r')
?>
