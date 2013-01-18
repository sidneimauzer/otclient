dofile 'neededtranslations'

-- private variables
local defaultLocaleName = 'en'
local installedLocales
local currentLocale

LocaleExtendedId = 1

function sendLocale(localeName)
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(LocaleExtendedId, localeName)
    return true
  end
  return false
end

function createWindow()
  localesWindow = g_ui.displayUI('locales')
  local localesPanel = localesWindow:getChildById('localesPanel')

  for name,locale in pairs(installedLocales) do
    local widget = g_ui.createWidget('LocalesButton', localesPanel)
    widget:setImageSource('/images/flags/' .. name .. '')
    widget:setText(locale.languageName)
    widget.onClick = function() selectFirstLocale(name) end
  end

  addEvent(function() addEvent(function() localesWindow:raise() localesWindow:focus() end) end)
end

function selectFirstLocale(name)
  if localesWindow then
    localesWindow:destroy()
    localesWindow = nil
  end
  if setLocale(name) then
    g_modules.reloadModules()
  end
end

-- hooked functions
function onGameStart()
  sendLocale(currentLocale.name)
end

function onExtendedLocales(protocol, opcode, buffer)
  local locale = installedLocales[buffer]
  if locale and setLocale(locale.name) then
    g_modules.reloadModules()
  end
end

-- public functions
function init()
  installedLocales = {}

  installLocales('/locales')

  local userLocaleName = g_settings.get('locale', 'false')
  if userLocaleName ~= 'false' and setLocale(userLocaleName) then
    pdebug('Using configured locale: ' .. userLocaleName)
  else
    setLocale(defaultLocaleName)
    connect(g_app, {onRun = createWindow})
  end

  ProtocolGame.registerExtendedOpcode(LocaleExtendedId, onExtendedLocales)
  connect(g_game, { onGameStart = onGameStart })
end

function terminate()
  installedLocales = nil
  currentLocale = nil

  ProtocolGame.unregisterExtendedOpcode(LocaleExtendedId)
  disconnect(g_game, { onGameStart = onGameStart })
end

function generateNewTranslationTable(localename)
  local locale = installedLocales[localename]
  for _i,k in pairs(neededTranslations) do
    local trans = locale.translation[k]
    k = k:gsub('\n','\\n')
    k = k:gsub('\t','\\t')
    k = k:gsub('\"','\\\"')
    if trans then
      trans = trans:gsub('\n','\\n')
      trans = trans:gsub('\t','\\t')
      trans = trans:gsub('\"','\\\"')
    end
    if not trans then
      print('    ["' .. k .. '"]' .. ' = false,')
    else
      print('    ["' .. k .. '"]' .. ' = "' .. trans .. '",')
    end
  end
end

function installLocale(locale)
  if not locale or not locale.name then
    error('Unable to install locale.')
  end

  if locale.name ~= defaultLocaleName then
    for _i,k in pairs(neededTranslations) do
      if locale.translation[k] == nil then
        local ktext =  string.gsub(k, "\n", "\\n")
        pwarning('Translation for locale \'' .. locale.name .. '\' not found: \"' .. ktext .. '\"')
      end
    end
  end

  local installedLocale = installedLocales[locale.name]
  if installedLocale then
    for word,translation in pairs(locale.translation) do
      installedLocale.translation[word] = translation
    end
  else
    installedLocales[locale.name] = locale
  end
end

function installLocales(directory)
  dofiles(directory)
end

function setLocale(name)
  local locale = installedLocales[name]
  if not locale then
    pwarning("Locale " .. name .. ' does not exist.')
    return false
  end
  currentLocale = locale
  g_settings.set('locale', name)
  if onLocaleChanged then onLocaleChanged(name) end
  return true
end

function getInstalledLocales()
  return installedLocales
end

function getCurrentLocale()
  return currentLocale
end

-- global function used to translate texts
function _G.tr(text, ...)
  if currentLocale then
    if tonumber(text) then
      -- todo: use locale information to calculate this. also detect floating numbers
      local out = ''
      local number = tostring(text):reverse()
      for i=1,#number do
        out = out .. number:sub(i, i)
        if i % 3 == 0 and i ~= #number then
          out = out .. ','
        end
      end
      return out:reverse()
    elseif tostring(text) then
      local translation = currentLocale.translation[text]
      if not translation then
        if translation == nil then
          if currentLocale.name ~= defaultLocaleName then
            pwarning('Unable to translate: \"' .. text .. '\"')
          end
        end
        translation = text
      end
      return string.format(translation, ...)
    end
  end
  return text
end
