; Simple Auto Clicker by Beatso rev by carlosmachina
#NoEnv
;remove question when running the script twice (force substitution)
#SingleInstance force
SendMode Input
SetWorkingDir %A_ScriptDir%

;Options Object, making possible to change the DropDown options here without updating if clauses. Its OK to edit, add and remove items from list
Global optListStr := "|"
Global timer := 40000
Global appTitle := "IanXO4's raid farm macro"

Global macroRunning := False
Global guiInitialized := False
Global mcStatus := ""
Global winid := ""
Global winname := ""


Menu, Tray, Add, Start Clicking, ToggleMacro
Menu, Tray, Add, Reset Minecraft Window, ResetMc
Menu, Tray, Add ;separator
Menu, Tray, Add, Exit, CloseScript

Menu, Tray, Disable, Start Clicking
Menu, Tray, Disable, Reset Minecraft Window
menu, Tray, Tip, %appTitle%
Menu, Tray, NoStandard

MsgBox,,, IanXO4's raid farm macro. Go to Minecraft window and press Ctrl+J to start.

^j::

    WinGet, currentWinId, , A
    WinClose, ahk_class #32770

    UpdateMcStatus(currentWinId)

    if (mcStatus = "inactive")
    {
        return
    }

    if (mcStatus = "closed")
    {
        McStatusHandler() 
    }

    if (mcStatus = "detached")
    {
        AttachMc()
        UpdateMcStatus(currentWinId)
    }

    ;Avoid setting variables to GUI controls twice, enabling reopening of GUI and change settings by just invoking CTRL+J at any time
    if (not guiInitialized)
    {
        Gui Add, Text, x14 y8 w402 h50, Minecraft window set to %winname%.`nPress Ctrl+Shift+J to pause/unpause macro`, Ctrl+Alt+J to quit the program`nand Ctrl+J to edit these settings at any time.
        Gui Add, CheckBox, x16 y66 w120 h23 vCustomKillingPeriod, Custom Killing Period
        Gui Add, Slider, x144 y66 w201 h32 +Tooltip Range30-80  vCdSliderValue, 40
        Gui Add, Button, x16 y98 w80 h23, &OK

        guiInitialized := True
    }

    if (mcStatus = "ok")
    {
        if(macroRunning)
        {
            Gosub, ^+j 
        }
        Gui Show, w370 h130, %appTitle%
    }
return

ButtonOK:
    Gui, Submit

    ;Overrides the DropDown choice if Custom Cooldown is selected and assigns the slider value to it
    if (CustomKillingPeriod)
    {
        timer := CdSliderValue * 1000
    }

    displayTimer := ValueDisplayFormat(timer)

    MsgBox,,, Raid farm macro killing period set to %displayTimer%. Press Ctrl+Shift+J in Minecraft to start.`nPress Ctrl+J at any time to change settings. Use Ctrl+Shift+J to pause and Ctrl+Alt+J to quit.
        Menu, Tray, UseErrorLevel
    Menu, Tray, Enable, Start Clicking
    Menu, Tray, UseErrorLevel, Off

    ;Option set so that the user is able to trigger CTRL+SHIFT+J while looping
    #MaxThreadsPerHotkey 3
return

^+j::
    DetectHiddenWindows, On
    WinGet, currentWinId, , A

    UpdateMcStatus(currentWinId)

    ;Check if HotKey was triggered in Minecraft avoiding messing with any other application the user may be using (Alt Tabbed)
    if (mcStatus = "inactive")
    {
        return
    }

    ;Stop the Clicking, to avoid being "stuck" right clicking (as it would happen with the old ::Pause function) and
    ;returns to original state (waiting for CTRL+SHIFT+J)
    if (macroRunning)
    {
        macroRunning := False
        TrayTip, %appTitle%, Raid macro stopped
        ToggleClickMenu()
        ControlClick,, ahk_id %winid%,, Right,, NA U
        ControlClick,, ahk_id %winid%,,Left,,NA U
        ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

        McStatusHandler()
        return
    }

    macroRunning := True
    ToggleClickMenu()
    TrayTip, %appTitle%, Macro Activated

    Loop 
    {
        UpdateMcStatus(currentWinId)
        ;If the window becomes unavailable, stop clicking
        if(mcStatus = "closed" || mcStatus = "detached")
        {
            Gosub, ^+j
            break
        }
        
        ;Check every loop if it should continue, otherwise break the loop and unpress used keys
        if not macroRunning
        {
            ControlClick,, ahk_id %winid%,, Right,, NA U
            ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

            break
        }
        ;;ControlClick,, ahk_id %winid%,, Right,, NA D

        ;Macro starts here
        ;Move back to lever and flick it
        ControlSend,, {s Down} {a Down},  ahk_id %winid%
        Sleep 1000
        ControlSend,, {s Up} {a Up},  ahk_id %winid%
        ControlClick,, ahk_id %winid%,,Right,,NA
        Sleep 500

        ;Check if should exit loop
        UpdateMcStatus(currentWinId)
        if(mcStatus = "closed" || mcStatus = "detached")
        {
            Gosub, ^+j
            break
        }
        if not macroRunning
        {
            ControlClick,, ahk_id %winid%,, Right,, NA U
            ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

            break
        }

        ;Move forward and drop down
        ControlSend,, {w Down},  ahk_id %winid%
        Sleep 700
        ControlSend,, {w Up},  ahk_id %winid%
        ControlSend,, {d Down},  ahk_id %winid%
        Sleep 200
        ControlSend,, {d Up},  ahk_id %winid%
        Sleep 1000

        ;Check if should exit loop
        UpdateMcStatus(currentWinId)
        if(mcStatus = "closed" || mcStatus = "detached")
        {
            Gosub, ^+j
            break
        }
        if not macroRunning
        {
            ControlClick,, ahk_id %winid%,, Right,, NA U
            ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

            break
        }

        ;Start moving back and prepare to enter bubble column
        ControlSend,, {d Down} {s Down},  ahk_id %winid%
        Sleep 7000

        ;Check if should exit loop
        UpdateMcStatus(currentWinId)
        if(mcStatus = "closed" || mcStatus = "detached")
        {
            Gosub, ^+j
            break
        }
        if not macroRunning
        {
            ControlClick,, ahk_id %winid%,, Right,, NA U
            ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

            break
        }

        ;Eat
        ControlClick,, ahk_id %winid%,, Right,, NA D
        sleep 5000
        ControlClick,, ahk_id %winid%,, Right,, NA U
        ControlSend,, {d Up} {s Up},  ahk_id %winid%

        ;Check if should exit loop
        UpdateMcStatus(currentWinId)
        if(mcStatus = "closed" || mcStatus = "detached")
        {
            Gosub, ^+j
            break
        }
        if not macroRunning
        {
            ControlClick,, ahk_id %winid%,, Right,, NA U
            ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

            break
        }
        ;Check Inventory   
        ControlSend,, {e},  ahk_id %winid%
        sleep 2500
        ControlSend,, {e},  ahk_id %winid%


        ;Check if should exit loop
        UpdateMcStatus(currentWinId)
        if(mcStatus = "closed" || mcStatus = "detached")
        {
            Gosub, ^+j
            break
        }
        if not macroRunning
        {
            ControlClick,, ahk_id %winid%,, Right,, NA U
            ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

            break
        }
        ;Move back to lever
        ControlSend,, {s Down}{a Down},  ahk_id %winid%
        sleep 2200
        ControlSend,, {s Up}{a Up},  ahk_id %winid%

        ;Check if should exit loop
        UpdateMcStatus(currentWinId)
        if(mcStatus = "closed" || mcStatus = "detached")
        {
            Gosub, ^+j
            break
        }
        if not macroRunning
        {
            ControlClick,, ahk_id %winid%,, Right,, NA U
            ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

            break
        }

        ;Wait for horns to blair
        Sleep 12000
        ControlClick,, ahk_id %winid%,,Right,,NA
        Sleep 100

        ;Check if should exit loop
        UpdateMcStatus(currentWinId)
        if(mcStatus = "closed" || mcStatus = "detached")
        {
            Gosub, ^+j
            break
        }
        if not macroRunning
        {
            ControlClick,, ahk_id %winid%,, Right,, NA U
            ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

            break
        }
        ;Move to Killing Area
        ControlSend,, {d Down},  ahk_id %winid%
        Sleep 200
        ControlSend,, {w Down},  ahk_id %winid%
        Sleep 500
        ControlSend,, {d Up}{w Up},  ahk_id %winid%

        ;Killing loop
        start := A_TickCount
        while (A_TickCount-start <= timer)
        {
            ;Check if should exit loop
            UpdateMcStatus(currentWinId)
            if(mcStatus = "closed" || mcStatus = "detached")
            {
                Gosub, ^+j
                break
            }
            if not macroRunning
            {
                ControlClick,, ahk_id %winid%,, Right,, NA U
                ControlSend,, {w Up} {a Up} {s Up} {d Up},  ahk_id %winid%

                break
            }
            ControlClick,, ahk_id %winid%,,Left,,NA
            Sleep 1000
        }
        
        
        ;;ControlClick,, ahk_id %winid%,,Left,,NA
        ;;Sleep, %timer%
    }

return
#MaxThreadsPerHotkey 1

^!j::
    MsgBox, , %appTitle%, Raid macro closed
ExitApp

ValueDisplayFormat(value)
{
    formattedValue := 0
    valueMeasurement := "ms"
    if (value < 1000)
    {
        formattedValue := value
    }
    else if (value >= 2000)
    {
        formattedValue := value/1000
        formattedValue := Format("{:d}", formattedValue)
        valueMeasurement := "s"
    }
    else
    {
        formattedValue := value/1000
        formattedValue := Format("{:.2f}" , formattedValue)
        valueMeasurement := "s"
    }

return formattedValue valueMeasurement
}

ToggleClickMenu()
{
    if (macroRunning)
    {
        Menu, Tray, Rename, Start Clicking, Stop Clicking
    }
    Else
    {
        Menu, Tray, Rename, Stop Clicking, Start Clicking
    }
}

UpdateMcStatus(currentWindowId)
{
    isAttached := winid != ""
    isAlive := WinExist("ahk_id" winid)
    isActive := currentWindowId = winid

    if (!isAttached)
    {
        mcStatus := "detached"
        return
    }

    if (!isAlive)
    {
        mcStatus := "closed"
        return
    }

    if (!isActive)
    {
        mcStatus := "inactive"
        return
    }

    mcStatus := "ok"
return
}

McStatusHandler()
{
    switch mcStatus
    {
        case "detached": {
            MsgBox, , %appTitle%, Minecraft Window not set, please switch to it and press Ctrl+J to set it up.
        }
        case "closed": {
            DetachMc()
            MsgBox, , %appTitle%, Minecraft Window not found (maybe it was closed).`nSwitch to new window and press CTRL+J to set it up.
        }
    }

return
}

AttachMc()
{
    WinGet, winid, , A
    WinGetTitle, winname, A
    Menu, Tray, Enable, Reset Minecraft Window
}

DetachMc()
{
    winid := ""
    winname := ""
    Menu, Tray, UseErrorLevel
    Menu, Tray, Disable, Start Clicking
    Menu, Tray, UseErrorLevel, Off
    Menu, Tray, Disable, Reset Minecraft Window
}

ToggleMacro:
    {
        if WinExist("ahk_id" winid)
            WinActivate

        Gosub, ^+j
        return
    }

ResetMc:
    {
        if (macroRunning)
        {
            WinActivate, "ahk_id" winid
            Gosub, ^+j
        }
        Reload
        return
    }

CloseScript:
    {
        Gosub, ^!j
        return
    }