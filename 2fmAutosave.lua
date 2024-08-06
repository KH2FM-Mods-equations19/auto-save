local prevContinue = 0
local blacklist = {"es01", "bb05", "eh20", "eh22", "eh23", "eh24", "eh25", "eh26", "eh27", "eh28", "eh29"}
local blacklisted = false

function _OnInit()
    kh2libstatus, kh2lib = pcall(require, "kh2lib")
    if not kh2libstatus then
        print("ERROR (Auto Save): KH2-Lua-Library mod is not installed")
        CanExecute = false
        return
    end

    Log("KH2 Auto Save 3.0.0")
    RequireKH2LibraryVersion(1)
    RequirePCGameVersion()

    CanExecute = kh2lib.CanExecute
    if not CanExecute then
        return
    end

    save = kh2lib.Save
    continue = kh2lib.Continue
    saveSelect = kh2lib.SaveSelect
    autoSaveAddress = kh2lib.SveAddr
    inputAddress = kh2lib.Input
    loadingIndicator = kh2lib.LoadingIndicator
    loadMenu = kh2lib.CurrentOpenMenu
    writeLogic = kh2lib.WriteLogic
end

function _OnFrame()
    if not CanExecute then
        return
    end

    SVE = ReadString(autoSaveAddress, 4)
    for i = 1, 11 do
        if SVE ~= blacklist[i] then
        blacklisted = false
        end
    end
    for i = 1, 11 do
        if SVE == blacklist[i] then
        blacklisted = true
        end
    end

    local input = ReadInt(inputAddress)

    if input & 8192 == 8192 and ReadByte(loadMenu) == 0x03 then
        WriteFloat(loadingIndicator, 90)
    end

    if (input & 8192 == 8192 and ReadInt(saveSelect) == 0 and ReadInt(save + 0xC) ~= prevSave) then
        local f = io.open("KH2autosave.dat", "rb")
        if f ~= nil then
            WriteString(save, f:read("*a"))
            f:close()
            Log("Loaded autosave")
        end
    end

    if ReadInt(continue + 0xC) ~= prevContinue and ReadByte(writeLogic) == 0 and blacklisted == false then
        local f = io.open("KH2autosave.dat", "wb")
        f:write(ReadString(continue, 0x10FC0))
        f:close()
        Log("Wrote autosave")
    end

    prevInput = input
    prevSave = ReadInt(save + 0xC)
    prevContinue = ReadInt(continue + 0xC)
end
