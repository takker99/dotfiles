; Script to turn off the IME when leaving insert mode
GoSub,imeOn
return

imeOn:
    GoSub,GetIMEState
    ;Msgbox, %ime_state% `n 0 means OFF `n 1 means ON
    if(ime_state=1)
    {
    Send {vkF4sc029}    ; ZenHan
    }
    else
    {
    }
    return

GetIMEState:
    WinGet, vcurrentwindow, ID, A
    ime_state := DllCall("user32.dll\SendMessageA", "UInt", DllCall("imm32.dll\ImmGetDefaultIMEWnd", "Uint", vcurrentwindow), "UInt", 0x0283, "Int", 0x0005, "Int", 0)
    return
