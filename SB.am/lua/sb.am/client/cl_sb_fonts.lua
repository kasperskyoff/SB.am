SB_AM = SB_AM or {}
SB_AM.Fonts = SB_AM.Fonts or {}

local function CreateFonts()
    if not surface.CreateFont then
        ErrorNoHalt("SB.AM: surface.CreateFont is not available\n")
        return
    end

    surface.CreateFont("SB_AM_ButtonFont", {
        font = "Roboto",
        size = 17,
        weight = 820,
        antialias = true,
        extended = true
    })
    SB_AM.Fonts.ButtonFont = "SB_AM_ButtonFont"

    surface.CreateFont("SB_AM_DescriptionFont", {
        font = "Roboto",
        size = 17,
        weight = 820,
        antialias = true,
        extended = true
    })
    SB_AM.Fonts.DescriptionFont = "SB_AM_DescriptionFont"
end

CreateFonts()

hook.Add("Initialize", "SB_AM_CreateFonts", CreateFonts)

hook.Add("OnGamemodeLoaded", "SB_AM_CreateFonts", CreateFonts)
hook.Add("OnScreenSizeChanged", "SB_AM_CreateFonts", CreateFonts)