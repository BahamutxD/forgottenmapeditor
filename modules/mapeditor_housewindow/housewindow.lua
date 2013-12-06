HouseWindow = {}

local houseWindow
local townComboBox
local houseList
local houseWindowButton
local statusLabel

function HouseWindow.init()
  houseWindow = g_ui.displayUI("housewindow.otui")
  houseWindow:hide()

  houseList = houseWindow:getChildById('houseList')
  connect(houseList, { onChildFocusChange = function(self, focusedChild)
                          if focusedChild == nil then return end
                          HouseWindow.updateHouseInfo(focusedChild:getText())
                        end })
  g_keyboard.bindKeyPress('Up',   function() houseList:focusPreviousChild(KeyboardFocusReason) end, houseWindow)
  g_keyboard.bindKeyPress('Down', function() houseList:focusNextChild(KeyboardFocusReason) end,     houseWindow)
  houseWindowButton = modules.mapeditor_topmenu.addLeftButton('houseWindowButton', tr('House Window') .. ' (CTRL+H)', '/images/topbuttons/house', HouseWindow.toggle)
  g_keyboard.bindKeyDown('Ctrl+H', HouseWindow.toggle)

  townComboBox = houseWindow:recursiveGetChildById('townComboBox')
  townComboBox.onOptionChange = function(widget, optText, optData)
    HouseWindow.showHouses(optData)
  end

  HouseWindow.readHouses()
end

function HouseWindow.terminate()
  houseWindow:destroy()
  houseWindow = nil
  houseWindowButton:destroy()
  houseWindowButton = nil
  houseList = nil
  HouseWindow = nil
end

function HouseWindow.hide()
  houseWindow:hide()
end

function HouseWindow.show()
  houseWindow:show()
  houseWindow:raise()
  houseWindow:focus()
end

function HouseWindow.toggle()
  if houseWindow:isVisible() then
    HouseWindow.hide()
  else
    HouseWindow.show()
  end
end

function HouseWindow.gotoHouse()
  local houseName = houseWindow:recursiveGetChildById('houseName'):getText()
  local house = g_houses.getHouseByName(houseName)
  if house then
    mapWidget:setCameraPosition(house:getEntry())
  end
end

function HouseWindow.showHouses(townId)
  houseList:destroyChildren()
  local houses = g_houses.filterHouses(townId)
  for i = 1, #houses do
    local house = houses[i]
    local label = g_ui.createWidget('HouseListLabel', houseList)
    label:setText(house:getName())
    label:setOn(true)
  end
end

function HouseWindow.readHouses()
  townComboBox:clearOptions()

  local towns = g_towns.getTowns()
  for i = 1, #towns do
    townComboBox:addOption(towns[i]:getName(), towns[i]:getId())
  end
  townComboBox:setCurrentIndex(1)

  houseList:focusChild(houseList:getFirstChild(), ActiveFocusReason)
  HouseWindow.showHouses(towns[1]:getId())
end

function HouseWindow.updateHouseInfo(houseName)
  local house = g_houses.getHouseByName(houseName)
  if not house then
    error('could not find house with name ' .. houseName)
  end
  local housePos = house:getEntry()

  houseWindow:recursiveGetChildById('houseName'):setText(houseName)
  houseWindow:recursiveGetChildById('houseID'):setText(tostring(house:getId()))
  houseWindow:recursiveGetChildById('housePosition'):setText(string.format("{ x: %d y: %d z: %d }",
                                                            housePos.x, housePos.y, housePos.z))
  houseWindow:recursiveGetChildById('townID'):setText(tostring(house:getTownId()))
end
