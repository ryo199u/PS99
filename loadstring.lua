local ids = {
    [8737899170] = "PETSIM99",
    [16498369169] = "PETSIM99",
    [17503543197] = "PETSIM99",
    [140403681187145] = "PETSIM99",
    [15502339080] = "TRADINGPLAZA",
    [15588442388] = "TRADINGPLAZA"
}

local currentgame = ids[game.PlaceId] or nil
local executorlevel = getthreadidentity() or getthreadcontext() or 0

if executorlevel < 4 then
    warn("EXECUTOR NOT SUPPORTED")
    return
end

if currentgame then
    if currentgame == "PETSIM99" then

        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://gist.githubusercontent.com/Eden-Xander/19647851e056442ecb3327e77e4e9ff3/raw/gistfile1.txt"))()
            end)
            if not ok then warn("[Script 1] Lỗi: " .. tostring(err)) end
        end)

        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ryo199u/PS99/refs/heads/main/event.lua"))()
            end)
            if not ok then warn("[Script 2] Lỗi: " .. tostring(err)) end
        end)

    end
else
    warn("GAME/PLACE NOT SUPPORTED")
end
