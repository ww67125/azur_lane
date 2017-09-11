local mapBase = require 'BaseOperate__maps__map'
local img1_2 = require 'BaseOperate__maps__img1_2'
local map1_2 = {}

-- 获取地图采样位置。由于地图可能超出一屏，所以这里可以定义多个采样位置。每次扫描都会对每个采样位置进行扫描
-- 标志位为地图四个角。每个采样位置只需定义一个角的坐标即可。
-- 还需要定义每个采样位置的地图矩阵与屏幕坐标的映射关系
map1_2.getCheckpositionList = function()
  return {
    {
      leftTop = nil,
      rightTop = nil,
      leftBotton = { 389, 837 },
      rightBotton = nil,
      -- 地图棋盘映射到屏幕，后面的颜色没有用，只是取点的时候自动加上的
      positionMap = {
        { { 462, 409, 0x31393a }, { 645, 409, 0x42494a }, { 828, 409, 0x313931 }, { 1012, 409, 0x293529 }, { 1196, 409, 0x212821 }, { 1380, 409, 0x424942 }, },
        { { 440, 537, 0x000000 }, { 631, 537, 0x318e94 }, { 823, 537, 0x21868c }, { 1014, 537, 0x106184 }, { 1206, 537, 0x196984 }, { 1398, 537, 0x000000 }, },
        { { 416, 679, 0x000000 }, { 613, 679, 0x316994 }, { 814, 679, 0x00517b }, { 1014, 679, 0x084173 }, { 1214, 679, 0x214d73 }, { 1419, 679, 0x000000 }, },
        { { 389, 837, 0x000000 }, { 599, 837, 0x000000 }, { 809, 837, 0x000000 }, { 1020, 837, 0x000000 }, { 1230, 837, 0x000000 }, { 1441, 837, 0x000000 }, },
      },
    },
  }
end

-- 获取地图棋盘和相关数据
map1_2.getMapChessboard = function()
  return {
    width = 4,
    height = 3,
    obstacle = {},
    waitForBossPosition = {},
    bossPosition = {},
    myFleetList = {},
    enemyPositionList = {},
  }
end

map1_2.getMapPosition = function()
  return mapBase.getMapPosition(img1_2)
end

map1_2.moveMapToCheckPosition = function(currentPosition, targetPosition)
  return mapBase.moveMapToCheckPosition(img1_2, currentPosition, targetPosition)
end

map1_2.scanMap = function(targetPosition, mapChessboard)
  return mapBase.scanMap(img1_2, targetPosition, mapChessboard)
end

map1_2.moveToPoint = function(targetPosition, point)
  return mapBase.moveToPoint(img1_2, targetPosition, point)
end

map1_2.findClosestEnemy = function(mapChessboard)
  return mapBase.findClosestEnemy(img1_2, mapChessboard)
end

return map1_2