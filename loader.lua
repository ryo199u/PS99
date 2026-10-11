pcall(function()
    if writefile and isfile then
        local path = "autoexec/ps99.lua"
        if not isfile(path) then
            writefile(path, [[
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/ryo199u/PS99/refs/heads/main/loadstring"))()
            ]])
            print("[ps99] Written to autoexec.")
        end
    end
end)
