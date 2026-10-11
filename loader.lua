-- PS99 Auto-Persist Loader
-- Tự detect executor, ghi vào autoexec đúng path

local RAW_URL = "https://raw.githubusercontent.com/ryo199u/PS99/refs/heads/main/loadstring"

local function getExecutorName()
    if syn then return "synapse"
    elseif KRNL_LOADED then return "krnl"
    elseif fluxus then return "fluxus"
    elseif Delta then return "delta"
    elseif identifyexecutor then
        local name = string.lower(identifyexecutor())
        if string.find(name, "xeno") then return "xeno"
        elseif string.find(name, "wave") then return "wave"
        elseif string.find(name, "swift") then return "swift"
        elseif string.find(name, "cryptic") then return "cryptic"
        elseif string.find(name, "delta") then return "delta"
        elseif string.find(name, "hydrogen") then return "hydrogen"
        else return name end
    end
    return "unknown"
end

local autoexecPaths = {
    synapse  = "autoexec/",
    krnl     = "KRNL/autoexec/",
    fluxus   = "fluxus/autoexec/",
    delta    = "autoexec/",
    xeno     = "autoexec/",
    wave     = "autoexec/",
    swift    = "autoexec/",
    cryptic  = "autoexec/",
    hydrogen = "autoexec/",
    unknown  = "autoexec/",
}

local function persist()
    if not (writefile and isfile) then
        warn("[ps99] Executor không support writefile — bỏ qua auto-persist")
        return
    end

    local execName = getExecutorName()
    local folder = autoexecPaths[execName] or "autoexec/"
    local path = folder .. "ps99.lua"

    -- Tạo folder nếu chưa có
    if makefolder and not isfolder(folder) then
        pcall(makefolder, folder)
    end

    if isfile(path) then
        print("[ps99] Đã có file autoexec: " .. path)
        return
    end

    local ok, src = pcall(function()
        return game:HttpGet(RAW_URL)
    end)

    if not ok or not src or src == "" then
        warn("[ps99] HttpGet thất bại: " .. tostring(src))
        return
    end

    -- Ghi loader vào autoexec
    local loaderLine = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/ryo199u/PS99/refs/heads/main/loadstring"))()'
    local writeOk, writeErr = pcall(writefile, path, loaderLine)

    if writeOk then
        print("[ps99] Đã ghi vào autoexec: " .. path .. " (" .. execName .. ")")
    else
        warn("[ps99] Ghi file thất bại: " .. tostring(writeErr))
    end
end

-- Chạy script chính
local function runMain()
    local ok, err = pcall(function()
        loadstring(game:HttpGet(RAW_URL))()
    end)
    if not ok then
        warn("[ps99] Script lỗi: " .. tostring(err))
    end
end

persist()
runMain()
