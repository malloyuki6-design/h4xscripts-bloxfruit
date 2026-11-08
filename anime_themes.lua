

return function(H4xUI)
    local function AddAnimeTheme(name, colors)
        local function color(value)
            return Color3.fromHex(value)
        end
        H4xUI:AddTheme({
            Name = name,
            Accent = color(colors.Accent),
            Dialog = color(colors.Dialog),
            Outline = color(colors.Outline),
            Text = color(colors.Text),
            Placeholder = color(colors.Placeholder),
            Background = color(colors.Background),
            Button = color(colors.Button),
            Icon = color(colors.Icon),
            Toggle = color(colors.Accent),
            Slider = color(colors.Accent),
            Checkbox = color(colors.Accent),
            HeaderBackground = H4xUI:Gradient({
                ["0"] = { Color = color(colors.HeaderStart), Transparency = 0 },
                ["100"] = { Color = color(colors.HeaderEnd), Transparency = 0 },
            }, { Rotation = 315 }),
            HeaderOutline = color(colors.Outline),
            HeaderAccent = color(colors.Accent),
            HeaderTag = color(colors.Tag),
            HeaderDesc = color(colors.Placeholder),
            HeaderButton = H4xUI:Gradient({
                ["0"] = { Color = color(colors.Button), Transparency = 0 },
                ["100"] = { Color = color(colors.Accent), Transparency = 0 },
            }, { Rotation = 315 }),
            HeaderButtonText = color(colors.Text),
            ShortcutBackground = color(colors.Dialog),
            ShortcutHover = color(colors.HeaderStart),
            ShortcutTitle = color(colors.Text),
            ShortcutDesc = color(colors.Placeholder),
        })
    end

    AddAnimeTheme("Anime - Elysia", {
        Accent = "#F08FB8", Dialog = "#2A1627", Outline = "#F7BDD4", Text = "#FFF4F8",
        Placeholder = "#CFA9BA", Background = "#180D17", Button = "#D65B91", Icon = "#F7A8C7",
        HeaderStart = "#51243F", HeaderEnd = "#21101E", Tag = "#FFE5B7",
    })
    AddAnimeTheme("Anime - Aglaea", {
        Accent = "#D6AD63", Dialog = "#2D2418", Outline = "#E8D6B0", Text = "#FFF8E9",
        Placeholder = "#B7A47B", Background = "#16120C", Button = "#A9823C", Icon = "#F2D18D",
        HeaderStart = "#4B351D", HeaderEnd = "#21190F", Tag = "#FFE9BD",
    })
    AddAnimeTheme("Anime - Raiden Shogun", {
        Accent = "#B09BFF", Dialog = "#241B40", Outline = "#D2C7FF", Text = "#F7F3FF",
        Placeholder = "#B3A6CF", Background = "#100C1D", Button = "#7256CA", Icon = "#D7C8FF",
        HeaderStart = "#46316F", HeaderEnd = "#191127", Tag = "#F5DFFF",
    })
    AddAnimeTheme("Anime - Evernight", {
        Accent = "#8196F8", Dialog = "#18213B", Outline = "#A8B9FF", Text = "#EEF2FF",
        Placeholder = "#8998C3", Background = "#090D1C", Button = "#5267B1", Icon = "#B8C7FF",
        HeaderStart = "#22305A", HeaderEnd = "#0C1228", Tag = "#DAE2FF",
    })
    AddAnimeTheme("Anime - March 7th", {
        Accent = "#7CCBFF", Dialog = "#18314A", Outline = "#B4E5FF", Text = "#F1FAFF",
        Placeholder = "#8CB7D1", Background = "#0C1724", Button = "#328BC9", Icon = "#BCEAFF",
        HeaderStart = "#174C74", HeaderEnd = "#10283C", Tag = "#FFE1EF",
    })
    AddAnimeTheme("Anime - Cyrene", {
        Accent = "#79E2E4", Dialog = "#10363A", Outline = "#B1F4F2", Text = "#F1FFFF",
        Placeholder = "#8FC6C8", Background = "#07191C", Button = "#268E95", Icon = "#A9F0EB",
        HeaderStart = "#19595D", HeaderEnd = "#09262C", Tag = "#D7FFFA",
    })
    AddAnimeTheme("Anime - Firefly", {
        Accent = "#6FE1AD", Dialog = "#12342B", Outline = "#A4F0D0", Text = "#F1FFF8",
        Placeholder = "#8ECBB1", Background = "#081A17", Button = "#268A66", Icon = "#9CF2C4",
        HeaderStart = "#195A43", HeaderEnd = "#0A261F", Tag = "#D7FFE9",
    })
end
