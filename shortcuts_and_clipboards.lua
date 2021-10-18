function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

--General
function getActiveAppName()
    return hs.application.frontmostApplication():title()
end

function getActiveWindowName()
    return hs.window.focusedWindow():title()
end

function printTableContents(input_table)
    local log = hs.logger.new('printTableContents', 'debug')
    final_string = ""
    for k, v in pairs(input_table) do
        final_string = final_string .. k .. "\n"        
    end
    log.i(final_string)
end

--Shortcuts
function activate(target_type, target)
    local log = hs.logger.new('activate', 'debug')
    if target_type == 'app' then
        if getActiveAppName() == target then
            hs.application.frontmostApplication():hide()
        else
            hs.application.launchOrFocus(target)
        end
    elseif target_type == 'path' then
        -- log.i("\n--------\nActivating path:\n" .. target)
        -- log.i("Active window: " .. getActiveWindowName() .. "\nTarget: " .. target)
        if getActiveWindowName() == target then
            -- log.i("Closing window...")
            hs.window.focusedWindow():close()
        else
            -- For folders with spaces in their titles:
            -- The escape character only needs to appear when the shell command is triggered.
            -- If it is added earlier, getActiveWindow() and target will not match when they
            -- should, as the escape character will appear in target, but not getActiveWindow()
            if string.find(target, " ") then
                target = target:gsub(" ", "\\ ")
            end
            -- log.i("Opening window...")
            local shell_command = "open " .. target
            hs.execute(shell_command)
        end
    end
end

-- hs.hotkey.bind({'', ''}, '', function() activate('', '') end)

--Multi-clipboard
function paste(text)
    local log = hs.logger.new('paste', 'debug')

    local tempClip = hs.pasteboard.getContents()
    hs.pasteboard.setContents(text)
    -- log.i('\n---------------\n' .. 'Clipboard contents: ' .. hs.pasteboard.getContents() .. '\n---------------\n')
    hs.eventtap.keyStroke("cmd", "v")
    hs.pasteboard.setContents(tempClip)
end

function copy()
    local tempClip = hs.pasteboard.getContents()
    hs.eventtap.keyStroke("cmd", "c") 
    local selectedText = hs.pasteboard.getContents()
    hs.pasteboard.setContents(tempClip)
    copyAlert(selectedText)
    return selectedText
end

function copyAlert(text)
    local log = hs.logger.new('copyAlert', 'debug')

    local screen = hs.screen.mainScreen()
    local w = screen:fullFrame()['w']
    local h = screen:fullFrame()['h']

    local mouseLocation = hs.mouse.getAbsolutePosition()
    local mx = mouseLocation['x'] + 8
    local my = mouseLocation['y'] + 8

    local displayW = w - mx
    local displayH = h - my

    -- log.i('\nScreen width = ' .. w ..'\nScreen height = ' .. h .. '\nMouse x = ' .. mx .. '\nMouse y = ' .. my)

    local textFrameDimensionsCursor = hs.geometry.rect(mx, my, displayW, displayH)
    local styledStringCursor = hs.styledtext.new(text, {backgroundColor=darkGray, font={name='System Font', size=15}, color=white})
    local copiedTextCursor = hs.drawing.text(textFrameDimensionsCursor, styledStringCursor)

    -- local textFrameDimensionsUpper = hs.geometry.rect(0, 0, w, h)
    -- local styledStringUpper = hs.styledtext.new(text, {background=darkGray, font={name='System Front', size=18}, paragraphStyle={alignment='center'}})
    -- local copiedTextUpper = hs.drawing.text(textFrameDimensionsUpper, styledStringUpper)

    copiedTextCursor:show()
    -- copiedTextUpper:show()

    hide(copiedTextCursor, 0.4, 0.3)
    -- hide(copiedTextUpper, 0.4, 0.2)

end

function hide(textObject, displayTime, fadeTime)
    -- For some reason, if this line is called outside of this function, and the user spams clip storage,
    -- the text displays will appear and not go away
    hs.timer.doAfter(displayTime, function() textObject:hide(fadeTime) end)
end

function loadClipLib(clipboardNumber)
    local log = hs.logger.new('loadClipLib', 'debug')

    local clipboard = clipboardPath .. clipboardNumber .. '.txt'

    local clipboards = {}
    local clipboardFile = io.open(clipboard, 'r')
    local clipboardFull = clipboardFile:read('a')
    counter = 1
    for clipboard in clipboardFull:gmatch("%d%-> (.-)\n\r-----------------------------------------|-----------------------------------------") do 
        table.insert(clipboards, clipboard)
        -- log.i(clipboards[counter])
        counter = counter + 1
    end
    for lastClip in clipboardFull:gmatch("10%-> (.+)") do
        table.insert(clipboards, lastClip)
        -- log.i(clipboards[10])
    end

    activeClipGroup = clipboardNumber
    return clipboards
end

function receiveEvent(table)
    local log = hs.logger.new('rcvEvent', 'debug')
    -- log.i(initialWindow)
    -- for key,item in pairs(table) do
    --     log.i(key, item)
    -- end
    clipboards = loadClipLib(table["body"])
    hs.alert.show('Group ' .. table["body"] .. ' loaded')
    hs.window.focusedWindow():close()
    initialWindow:focus()
end

function showClipGroupSelector()
    selectorWindowExists = hs.window.get('Clipboard Group Selection')

    if selectorWindowExists then
        selectorWindowExists:focus()
    else
        local log = hs.logger.new('ClipGUI', 'debug')
        initialWindow = hs.window.focusedWindow()

        local windowSize = hs.geometry.rect(400, 100, 390, 222)

        local messageMiddleman = hs.webview.usercontent.new('ClipboardGroupSelector'):setCallback(receiveEvent)

        local selectorWindowObject = hs.webview.new(windowSize, messageMiddleman):allowTextEntry(true)

        local selectorFile = io.open(selectorPath, 'r')
        local html = selectorFile:read('a')

        selectorWindowObject:windowStyle(0 + 2 + 1) --borderless + closable + titled
        local selectorWindowTitle = 'Clipboard Group Selection'
        selectorWindowObject:windowTitle(selectorWindowTitle)
        log.i(selectorWindowObject)
        selectorWindowObject:html(html)
        selectorWindowObject:show()
        local selectorWindowInstance = hs.window.get(selectorWindowTitle)
        selectorWindowInstance:focus()
        -- hs.alert.show(selectorWindowInstance:title())

        log.i(hs.webview.windowMasks)
    end
end

function toggleClipboardDisplays()
    local log = hs.logger.new('showClips', 'debug')

--Get screen resolution and prepare display increments
    screen = hs.screen.mainScreen()
    screenWidth = screen:fullFrame()['w']
    screenHeight = screen:fullFrame()['h']

    yIncrement = screenHeight / 5
    xIncrement = screenWidth / 2

    log.i('Screen width = ' .. screenWidth)
    log.i('Width increment = ' .. xIncrement)
    log.i('Screen height = ' .. screenHeight)
    log.i('Height increment = ' .. yIncrement)

--Display
    if displaysToggled == false then
        log.i('Displaying popups')

        local frameDimensions = hs.geometry.rect(0, 0, xIncrement, yIncrement)
        local textFrameDimensions = hs.geometry.rect(0, 0, xIncrement - 15, yIncrement - 10)

        frameDimensions.y = -yIncrement
        frameDimensions.x = 0
        textFrameDimensions.y = -yIncrement + 5
        textFrameDimensions.x = 7
        
        for num, clipboard in pairs(clipboards) do
            frameDimensions.y = frameDimensions.y + yIncrement
            textFrameDimensions.y = textFrameDimensions.y + yIncrement

            if num == 6 then
                frameDimensions.x = frameDimensions.x + xIncrement
                frameDimensions.y = 0
                textFrameDimensions.x = textFrameDimensions.x + xIncrement
                textFrameDimensions.y = 5
            end

            -- if clipboard == nil then
            --     clipboard = ''
            -- end

            local displayTextString = num .. '-> ' .. clipboard
            displayText[num] = hs.drawing.text(textFrameDimensions, displayTextString)
            displayText[num]:setTextSize(18)

            displayFrame[num] = hs.drawing.rectangle(frameDimensions)
            displayFrame[num]:setFillColor(darkGray)
            displayFrame[num]:setRoundedRectRadii(15, 15)
            displayFrame[num]:setStroke(true)
            displayFrame[num]:setStrokeColor(white)
            displayFrame[num]:setStrokeWidth(2)

            displayFrame[num]:show()
            displayText[num]:show()
            log.i('Displaying ' .. displayText[num]:getStyledText():getString())
        end
        displaysToggled = true
    else
        log.i('Hiding popups')
        for num, textObj in pairs(displayText) do
            displayFrame[num]:hide()
            displayText[num]:hide()
            log.i('Hiding ' .. displayText[num]:getStyledText():getString())
        end
        displaysToggled = false
    end
end

function openActiveClipGroup()
    appleScriptCommand = 'tell application "Finder" to open POSIX file "' .. clipboardPath .. activeClipGroup .. '.txt"'
    hs.osascript.applescript(appleScriptCommand)
end

function pasteDate()
    date = os.date("%x")
    date = string.gsub(date, '0(%d)', '%1')
    date = string.gsub(date, '(%d+%/%d+%/)(%d%d)', '%120%2')
    paste(date)
end

function toggleSystemClipboardDisplay()
    local log = hs.logger.new('showClip', 'debug')

    if clipboardDisplayToggled == false then
        local screen = hs.screen.mainScreen()
        local w = screen:fullFrame()['w']
        local h = screen:fullFrame()['h']

        local textFrameDimensions = hs.geometry.rect(0, 0, w, h)
        local clipboardTextString = hs.pasteboard.getContents()
        local styledString = hs.styledtext.new(clipboardTextString, {backgroundColor=darkGray, color=white, font={size=36}})
        clipboardText = hs.drawing.text(textFrameDimensions, styledString)

        clipboardText:show()
        clipboardDisplayToggled = true
    else
        clipboardText:hide()
        clipboardDisplayToggled = false
    end    
end

selectorPath = '/Users/lucmarion/Documents/Scripts/Hammerspoon/MultiClip/selector.html'
clipboardPath = '/Users/lucmarion/Documents/Scripts/Hammerspoon/MultiClip/ClipGroup'
clipboards = loadClipLib(1)
activeClipGroup = 1
initialWindow = nil
displayText = {}
displayFrame = {}
displaysToggled = false
clipboardText = nil
clipboardDisplayToggled = false
darkGray = {red=0.1, green=0.1, blue=0.1, alpha=0.8}
darkGrayOpaque = {red=0.1, green=0.1, blue=0.1, alpha=1.0}
white = {red=1, green=1, blue=1, alpha=0.8}

hs.hotkey.bind({'ctrl', 'alt'}, '1', function() clipboards[1] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '2', function() clipboards[2] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '3', function() clipboards[3] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '4', function() clipboards[4] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '5', function() clipboards[5] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '6', function() clipboards[6] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '7', function() clipboards[7] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '8', function() clipboards[8] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '9', function() clipboards[9] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '0', function() clipboards[10] = copy() end)
hs.hotkey.bind({'ctrl', 'alt'}, '-', openActiveClipGroup)

hs.hotkey.bind({'alt'}, '1', function() paste(clipboards[1]) end)
hs.hotkey.bind({'alt'}, '2', function() paste(clipboards[2]) end)
hs.hotkey.bind({'alt'}, '3', function() paste(clipboards[3]) end)
hs.hotkey.bind({'alt'}, '4', function() paste(clipboards[4]) end)
hs.hotkey.bind({'alt'}, '5', function() paste(clipboards[5]) end)
hs.hotkey.bind({'alt'}, '6', function() paste(clipboards[6]) end)
hs.hotkey.bind({'alt'}, '7', function() paste(clipboards[7]) end)
hs.hotkey.bind({'alt'}, '8', function() paste(clipboards[8]) end)
hs.hotkey.bind({'alt'}, '9', function() paste(clipboards[9]) end)
hs.hotkey.bind({'alt'}, '0', function() paste(clipboards[10]) end)
hs.hotkey.bind({'alt'}, '-', pasteDate)

hs.hotkey.bind({'ctrl', 'alt'}, '`', showClipGroupSelector)
hs.hotkey.bind({'ctrl', 'alt'}, 'w', toggleClipboardDisplays)
hs.hotkey.bind({'ctrl', 'alt'}, 'c', toggleSystemClipboardDisplay)



hs.hotkey.bind({'alt'}, 'e', function() hs.alert.show(getActiveAppName()) end)
-- hs.hotkey.bind({'alt'}, 'w', function() hs.alert.show(getActiveWindowName()) end)
-- hs.hotkey.bind({'alt'}, 'c', function() printTableContents(hs.drawing.color) end)



