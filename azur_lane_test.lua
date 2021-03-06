runCount = 1
isPause = false
luaExisted = false
function beforeUserExit()
  luaExisted = true
  vibrator(500)
  mSleep(500)
  vibrator(500)
end

if (deviceIsLock() ~= 0) then
  unlockDevice()
end

initLog('azur_lane', 1)

require 'TableLib'
require 'StringLib'
require 'MathLib'
require 'console'
require 'KeepScreenHock'
require 'DeviceOrientHock'
local eq = require 'EventQuery'
local co = require 'Co'
local Promise = require 'Promise'
local sz = require 'sz'
local json = sz.json
local socket = require 'szocket.core'
local mapMaker = require 'BaseOperate'
local gomission = require 'GoMission'
local stepLabel = (require 'StepLabel').init('stopbtn')


Promise.setStackTraceback(false)

local lfs = require 'lfs'

Promise.setStackTraceback(false)

-- 删除大于7天并且大于50条的log，避免日志过大
local _ = (function()
  local logPath = userPath() .. '/log'
  local dirs = lfs.dir(logPath)
  local sevenDayBeforeTime = os.time() - (7 * 24 * 60 * 60)
  local theTime = os.time()

  local dirsLen = #dirs

  dirs = table.filter(dirs, function(e, index)
    if (string.startWith(e, 'azur_lane_')) then
      local res = string.match(e, 'azur_lane_(%d+)')
      res = tonumber(res) or theTime
      if ((index < (dirsLen - 50)) and (res < sevenDayBeforeTime)) then
        return true
      end
    end
    return false
  end)

  for k, v in ipairs(dirs) do
    lfs.rm(logPath .. '/' .. v)
  end
end)()

local width, height = getScreenSize()

local c = coroutine


local sleepPromise = function(ms)
  return Promise.new(function(resolve)
    eq.setTimeout(resolve, ms)
  end)
end

stepLabel.setStepLabelContent('开始')

function closeStepLabel()
  fwCloseView('steplabel', 'text1')
end

stepLabel.setStepLabelContent('等待音量面板收起')
mSleep(500)



-- 设置
local settingTable = {
  ['style'] = 'default',
  ['width'] = height,
  ['height'] = height,
  ['config'] = 'save_warship-girls-r-script.dat',
  ['timer'] = 5,
  ['orient'] = 1,
  ['pagetype'] = 'multi',
  ['title'] = '选项',
  ['cancelname'] = '取消',
  ['okname'] = '开始',
  ['rettype'] = 'table',
  ['pages'] = {
    {
      {
        ['type'] = 'Label',
        ['text'] = '第一次设置建议在竖屏下设置，设置好后再切换到游戏界面',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['type'] = 'Label',
        ['text'] = '向左滑动查看其他选项',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['type'] = 'Label',
        ['text'] = '出击',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['id'] = 'battleEnable',
        ['type'] = 'RadioGroup',
        ['list'] = '开启,关闭',
        ['select'] = '0',
      },
      {
        ['type'] = 'Label',
        ['text'] = '每一轮的间隔时间(秒)',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['id'] = 'missionsInterval',
        ['type'] = 'Edit',
        ['prompt'] = '最短间隔时间(秒)',
        ['text'] = '15',
        ['kbtype'] = 'number',
      },
      {
        ['type'] = 'Label',
        ['text'] = '多长时间画面不变则重启游戏(秒)最少60秒',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['id'] = 'restartInterval',
        ['type'] = 'Edit',
        ['prompt'] = '多长时间画面不变则重启游戏(秒)最少60秒',
        ['text'] = '120',
        ['kbtype'] = 'number',
      },
      {
        ['type'] = 'Label',
        ['text'] = ' \n \n \n \n \n \n \n \n \n \n',
        ['size'] = 50,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
    },
    {
      {
        ['type'] = 'Label',
        ['text'] = '出征设置',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['type'] = 'Label',
        ['text'] = '章节',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['id'] = 'battleChapter',
        ['type'] = 'CheckBoxGroup',
        --        ['list'] = '1-1,1-2,1-3,1-4,2-1,2-2,2-3,2-4,3-1,3-2,3-3,3-4,4-1,4-2,4-3',
        ['list'] = '3-4',
        ['select'] = '0',
      },
      {
        ['type'] = 'Label',
        ['text'] = '舰队',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['id'] = 'battleFleet',
        ['type'] = 'CheckBoxGroup',
        ['list'] = '1队,2队',
        ['select'] = '0@1',
      },
      {
        ['type'] = 'Label',
        ['text'] = '回避',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['id'] = 'battleRoundabout',
        ['type'] = 'RadioGroup',
        ['list'] = '是,否',
        ['select'] = '0',
      },
      {
        ['type'] = 'Label',
        ['text'] = '不能出征则震动提示',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['id'] = 'battleAlertWhenNoHp',
        ['type'] = 'RadioGroup',
        ['list'] = '是,否',
        ['select'] = '0',
      },
      {
        ['type'] = 'Label',
        ['text'] = '阵型',
        ['size'] = 15,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
      {
        ['id'] = 'battleFormation',
        ['type'] = 'RadioGroup',
        ['list'] = '单纵,复纵,轮型,梯形,单横',
        ['select'] = '1',
      },
      {
        ['type'] = 'Label',
        ['text'] = ' \n \n \n \n \n \n \n \n \n \n',
        ['size'] = 50,
        ['align'] = 'left',
        ['color'] = '0,0,0',
      },
    },
  }
}

local settingTableStr = json.encode(settingTable);
closeStepLabel()
local ret, settings = showUI(settingTableStr);
if (ret ~= 1) then
  stepLabel.setStepLabelContent('取消运行')
  mSleep(100000)
  lua_exit()
end
stepLabel.setStepLabelContent('正在载入...')
-- --转换settings结果
local __tmp = (function(settings)
  function transStrToTable(str)
    local list = {}
    local strArr = {}
    if (type(str) == 'string') then
      strArr = strSplit(str, ',')
    elseif (type(str) == 'table') then
      strArr = str
    end
    for i, v in ipairs(strArr) do
      list['' .. (i - 1)] = v
    end
    return list
  end

  -- 出征
  settings.battleEnable = (function(battleEnable)
    local list = transStrToTable({ true, false, })
    return list[battleEnable] or false
  end)(settings.battleEnable)
  -- 总循环间隔时间
  settings.missionsInterval = tonumber(settings.missionsInterval) or 0
  -- 多长时间界面不变则重启，最少60秒
  settings.restartInterval = tonumber(settings.restartInterval) or 120
  settings.restartInterval = math.max(settings.restartInterval, 60)

  -- 选择关卡
  settings.battleChapter = (function(battleChapter)
    local tempArr = strSplit(battleChapter, '@')
    --    local list = transStrToTable({
    --      '1-1', '1-2', '1-3', '1-4',
    --      '2-1', '2-2', '2-3', '2-4',
    --      '3-1', '3-2', '3-3', '3-4',
    --      '4-1', '4-2', '4-3',
    --    })
    local list = transStrToTable({
      '3-4',
    })
    local result = {}
    for _, v in ipairs(tempArr) do
      if (type(list[v]) == 'string') then
        table.insert(result, list[v])
      end
    end
    return result
  end)(settings.battleChapter)
  -- 选择舰队
  settings.battleFleet = (function(battleFleet)
    local tempArr = strSplit(battleFleet, '@')
    local list = transStrToTable({ 1, 2 })
    local result = {}
    for _, v in ipairs(tempArr) do
      if (type(list[v]) == 'number') then
        table.insert(result, list[v])
      end
    end
    return result
  end)(settings.battleFleet)
  -- 迂回战术
  settings.battleRoundabout = (function(battleRoundabout)
    local list = transStrToTable({ true, false, })
    return list[battleRoundabout] or false
  end)(settings.battleRoundabout)
  -- 当无法出征时是否跳过出征
  settings.battleAlertWhenNoHp = (function(battleAlertWhenNoHp)
    local list = transStrToTable({ true, false, })
    return list[battleAlertWhenNoHp] or false
  end)(settings.battleAlertWhenNoHp)
  -- 阵型
  settings.battleFormation = (function(battleFormation)
    local list = transStrToTable({ 1, 2, 3, 4, 5 })
    return list[battleFormation] or 2
  end)(settings.battleFormation)
end)(settings)

-- --转换settings结果

-- 注册按钮事件，目前只有暂停按钮
eq.setButotnListener('stopbtn', function()
  if (isPause) then
    --    stepLabel.setPrefix('')
    --    isPause = false
  else
    stepLabel.setPrefix('即将暂停 ')
    isPause = true
  end
end)

gomission.init(mapMaker(), settings)

local theMissionsQuery = {}

co(c.create(function()
  if (settings.battleEnable) then

    -- 插入一个特殊的任务表示这是队列的开头
    table.insert(theMissionsQuery, { isBase = true, isStart = true })
    -- 是否运行出征
    if (settings.battleEnable) then
      table.insert(theMissionsQuery, { isBase = true, type = 'BATTLE_MAP_PAGE_MOVE_TO_CENTER' })
    end
    -- 插入一个特殊任务表示这是队列的结尾
    table.insert(theMissionsQuery, { isBase = true, isEnd = true })

    runCount = 1
    local runStartTime = socket.gettime() * 1000
    while (true) do
      -- 任务队列里没有任务则停止运行
      local action = theMissionsQuery[1]
      if ((#theMissionsQuery == 0) or (not action)) then
        break
      end

      if (action.isStart) then
        runStartTime = socket.gettime() * 1000
      end

      -- 如果是队列原有任务则将其加入队列末尾，以保证能一直循环
      -- 如果是从原有任务衍生的下一步任务，则不加入队列末尾，会被新的下一步任务替换或者删除
      if (action.isBase) then
        table.insert(theMissionsQuery, action)
      end

      -- 执行一个action
      if (action.type) then
        local newAction = c.yield(gomission.next(action))
        if (type(newAction) == 'table') then
          if (newAction.addToStart) then
            table.insert(theMissionsQuery, 1, newAction)
          else
            theMissionsQuery[1] = newAction
          end
        else
          table.remove(theMissionsQuery, 1)
        end
      else
        table.remove(theMissionsQuery, 1)
      end

      -- 如果点了暂停按钮
      if (isPause) then
        stepLabel.setPrefix('')
        local lasttext = stepLabel.getText()
        stepLabel.setStepLabelContent('暂停')
        c.yield(Promise.new(function(resolve)
          local theEid
          theEid = eq.setButotnListener('stopbtn', function()
            isPause = false
            stepLabel.setPrefix('')
            eq.clearButotnListener(theEid)
            resolve()
          end)
        end))
        stepLabel.setStepLabelContent(lasttext)
      end

      if (action.isEnd) then
        local diffTime = (socket.gettime() * 1000) - runStartTime
        if (diffTime < (settings.missionsInterval * 1000)) then
          local remainTime = (settings.missionsInterval * 1000) - diffTime
          stepLabel.setStepLabelContent('休息剩余时间' .. math.ceil(remainTime / 1000) .. '秒')
          while (remainTime > 0) do
            stepLabel.setStepLabelContent('休息剩余时间' .. math.ceil(remainTime / 1000) .. '秒', true)
            c.yield(sleepPromise(1000))
            remainTime = remainTime - 1000
          end
        end

        if (luaExisted) then
          break
        end

        runCount = runCount + 1
      end

      -- 如果是任务队列结尾标志，则count+1
    end
  end
end)).catch(function(err)
  wLog("warship-girls-r-script", "[DATE] " .. err);
  eq.setImmediate(function() error(err) end)
end)

eq.run()
