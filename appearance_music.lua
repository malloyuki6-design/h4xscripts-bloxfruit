
return function(context)
    assert(type(context) == "table", "Appearance module requires a context table")
    local Window = assert(context.Window, "Missing Window")
    local SettingTab = assert(context.SettingTab, "Missing SettingTab")
    local SoundService = assert(context.SoundService, "Missing SoundService")
    local HttpService = assert(context.HttpService, "Missing HttpService")
    local notify = context.Notify

    local Backgrounds = {
        ["None"] = "",
        ["Elysia hsr"] = "rbxthumb://type=Asset&id=12339305710&w=768&h=432",
        ["Aglaea hsr"] = "rbxthumb://type=Asset&id=118431401259014&w=768&h=432",
        ["Raiden Shogun"] = "rbxthumb://type=Asset&id=9166607927&w=768&h=432",
        ["Evernight Hsr"] = "rbxthumb://type=Asset&id=130111392846041&w=768&h=432",
        ["march 7 hsr"] = "rbxthumb://type=Asset&id=15544292403&w=768&h=432",
        ["Cyrene hsr"] = "rbxthumb://type=Asset&id=114983488511591&w=768&h=432",
        ["Fire Fly"] = "rbxthumb://type=Asset&id=125670440973884&w=768&h=432",
    }

    local animeSettingsPath = Window.StoragePath .. "/anime_ui_settings.json"
    local animeSettings = {}
    if type(readfile) == "function" then
        local ok, saved = pcall(function()
            return HttpService:JSONDecode(readfile(animeSettingsPath))
        end)
        if ok and type(saved) == "table" then animeSettings = saved end
    end
    if type(animeSettings.Background) ~= "string" or Backgrounds[animeSettings.Background] == nil then
        animeSettings.Background = "None"
    end
    animeSettings.BackgroundOpacity = math.clamp(tonumber(animeSettings.BackgroundOpacity) or 42, 10, 80)
    animeSettings.MusicId = tostring(animeSettings.MusicId or "")
    animeSettings.MusicVolume = math.clamp(tonumber(animeSettings.MusicVolume) or 25, 0, 100)
    animeSettings.MusicLooped = animeSettings.MusicLooped == true

    local function SaveAnimeSettings()
        if type(writefile) ~= "function" then return false end
        local ok = pcall(function()
            writefile(animeSettingsPath, HttpService:JSONEncode(animeSettings))
        end)
        return ok
    end

    local backgroundNames = {
        "None",
        "Elysia hsr",
        "Aglaea hsr",
        "Raiden Shogun",
        "Evernight Hsr",
        "march 7 hsr",
        "Cyrene hsr",
        "Fire Fly",
    }

    local appearanceSection = SettingTab:Section({
        Title = "ANIME APPEARANCE",
        Id = "settings-anime-appearance",
        Icon = "palette",
        Box = true,
        Opened = true,
    })
    appearanceSection:Paragraph({
        Title = "Personalize H4xScripts",
        Desc = "Choose an anime color theme and character background. These settings are saved with your interface preferences.",
    })

    local selectedBackground = animeSettings.Background
    if type(selectedBackground) ~= "string" or Backgrounds[selectedBackground] == nil then
        selectedBackground = "None"
    end

    local function ApplyAnimeBackground(name)
        local image = Backgrounds[name]
        if image == nil then
            name, image = "None", ""
        end
        local ok, err = pcall(function()
            Window:SetBackgroundImage(image)
            local opacity = animeSettings.BackgroundOpacity
            opacity = math.clamp(opacity, 10, 80)
            Window:SetBackgroundImageTransparency(image == "" and 1 or 1 - opacity / 100)
        end)
        if not ok then
            if type(notify) == "function" then pcall(notify, "Anime Background", tostring(err), 5) end
            return false
        end
        animeSettings.Background = name
        SaveAnimeSettings()
        return true
    end

    appearanceSection:Dropdown({
        Title = "Anime Background",
        Values = backgroundNames,
        Value = selectedBackground,
        AllowNone = false,
        SearchBarEnabled = false,
        Callback = function(value)
            if type(value) ~= "string" or Backgrounds[value] == nil then return end
            ApplyAnimeBackground(value)
        end,
    })

    appearanceSection:Slider({
        Title = "Background Visibility",
        Desc = "Controls how strongly the selected image appears behind the interface.",
        Step = 5,
        UpdateOnRelease = true,
        Value = {
            Min = 10,
            Max = 80,
            Default = math.clamp(animeSettings.BackgroundOpacity, 10, 80),
        },
        Callback = function(value)
            local opacity = math.clamp(tonumber(value) or 42, 10, 80)
            animeSettings.BackgroundOpacity = opacity
            local image = Backgrounds[animeSettings.Background or "None"] or ""
            pcall(Window.SetBackgroundImageTransparency, Window, image == "" and 1 or 1 - opacity / 100)
            SaveAnimeSettings()
        end,
    })

    ApplyAnimeBackground(selectedBackground)

    local musicSection = SettingTab:Section({
        Title = "MUSIC PLAYER",
        Id = "settings-anime-music",
        Icon = "music-2",
        Box = true,
        Opened = false,
    })
    musicSection:Paragraph({
        Title = "Personal audio",
        Desc = "Enter a Roblox audio asset ID that you are allowed to use. Playback depends on the asset being available to this experience.",
    })

    local existingMusic = SoundService:FindFirstChild("H4xScriptsAnimeMusic")
    if existingMusic and existingMusic:IsA("Sound") then
        pcall(existingMusic.Stop, existingMusic)
        existingMusic:Destroy()
    end

    local animeMusic = Instance.new("Sound")
    animeMusic.Name = "H4xScriptsAnimeMusic"
    animeMusic.Volume = math.clamp(tonumber(animeSettings.MusicVolume) or 25, 0, 100) / 100
    animeMusic.Looped = animeSettings.MusicLooped == true
    animeMusic.Parent = SoundService

    local musicIdInput = musicSection:Input({
        Title = "Roblox Audio ID",
        Placeholder = "Enter numeric audio asset ID",
        Value = tostring(animeSettings.MusicId or ""),
        Callback = function(value)
            animeSettings.MusicId = tostring(value or "")
            SaveAnimeSettings()
        end,
    })

    -- Local MP3 support. This accepts direct HTTPS links to MP3 files, not YouTube watch links.
    -- YouTube does not provide a supported general-purpose MP3 download endpoint.
    local MUSIC_FOLDER = "H4xScripts/Music"
    local localMusicAsset = nil
    local selectedLocalMusicPath = nil
    local musicUrlInput
    local musicFileNameInput
    local savedMusicDropdown

    local function TrimMusicText(value)
        return tostring(value or ""):match("^%s*(.-)%s*$") or ""
    end

    local function EnsureMusicFolder()
        assert(type(writefile) == "function", "This executor does not support writefile.")
        assert(type(readfile) == "function", "This executor does not support readfile verification.")
        assert(type(isfile) == "function", "This executor does not support isfile.")
        assert(type(isfolder) == "function" and type(makefolder) == "function", "This executor does not support folder creation.")

        if not isfolder("H4xScripts") then makefolder("H4xScripts") end
        if not isfolder(MUSIC_FOLDER) then makefolder(MUSIC_FOLDER) end
        assert(isfolder(MUSIC_FOLDER), "Could not create H4xScripts/Music.")
    end

    local function CleanMusicFileName(value)
        local name = TrimMusicText(value)
        name = name:gsub("%.mp3$", "")
        name = name:gsub("[^%w_%- ]", "")
        name = name:gsub("%s+", "_"):gsub("_+", "_")
        name = name:gsub("^[_%-]+", ""):gsub("[_%-]+$", "")
        name = name:sub(1, 48)
        if name == "" or name == "." or name == ".." then
            name = "H4xTrack_" .. tostring(os.time())
        end
        return name
    end

    local function LooksLikeMp3(data)
        if type(data) ~= "string" or #data < 4 then return false end
        if data:sub(1, 3) == "ID3" then return true end

        -- Some valid MP3s begin directly with an MPEG audio frame instead of an ID3 tag.
        local scanLimit = math.min(#data - 1, 4096)
        for index = 1, scanLimit do
            local first, second = string.byte(data, index, index + 1)
            if first == 255 and second and second >= 224 then
                return true
            end
        end
        return false
    end

    local function GetDirectMp3Response(url)
        local transport = request or http_request or (type(syn) == "table" and syn.request)
        if type(transport) == "function" then
            local response = transport({
                Url = url,
                Method = "GET",
                Headers = { Accept = "audio/mpeg, application/octet-stream" },
            })
            assert(type(response) == "table", "The HTTP request returned an invalid response.")
            local status = tonumber(response.StatusCode or response.Status)
            if status and (status < 200 or status >= 300) then
                error("The audio host returned HTTP " .. tostring(status) .. ".", 0)
            end
            local headers = response.Headers or response.headers
            local contentType = type(headers) == "table" and (headers["Content-Type"] or headers["content-type"]) or nil
            if type(contentType) == "string" and contentType:lower():find("text/html", 1, true) then
                error("The link returned a webpage, not an MP3 file.", 0)
            end
            return response.Body
        end

        -- Fallback for executors that expose game:HttpGet but not request().
        return game:HttpGet(url)
    end

    local function ListSavedMp3s()
        local names = {}
        if type(listfiles) ~= "function" or type(isfile) ~= "function" then return names end
        local ok, entries = pcall(listfiles, MUSIC_FOLDER)
        if not ok or type(entries) ~= "table" then return names end

        local seen = {}
        for _, path in ipairs(entries) do
            if type(path) == "string" then
                local name = path:match("([^/\\]+)$")
                if name and name:match("^[%w_%-]+%.mp3$") and not seen[name:lower()] then
                    seen[name:lower()] = true
                    names[#names + 1] = name
                end
            end
        end
        table.sort(names, function(a, b) return a:lower() < b:lower() end)
        return names
    end

    local function LoadLocalMp3(fileName)
        assert(type(getcustomasset) == "function", "Your executor does not support getcustomasset.")
        assert(type(fileName) == "string" and fileName:match("^[%w_%-]+%.mp3$"), "Select a valid saved MP3 file.")
        local path = MUSIC_FOLDER .. "/" .. fileName
        assert(isfile(path), "That MP3 file no longer exists.")
        local ok, asset = pcall(getcustomasset, path)
        assert(ok and type(asset) == "string" and asset ~= "", "getcustomasset could not load this MP3 file.")

        localMusicAsset = asset
        selectedLocalMusicPath = path
        animeSettings.DownloadedMusicPath = path
        SaveAnimeSettings()
        return asset
    end

    local function RefreshSavedMp3Dropdown(preferredName)
        if not savedMusicDropdown then return end
        local names = ListSavedMp3s()
        pcall(function()
            savedMusicDropdown:Refresh(names)
            if preferredName and table.find(names, preferredName) then
                savedMusicDropdown:Select(preferredName)
            end
        end)
    end

    local savedMusicPath = tostring(animeSettings.DownloadedMusicPath or "")
    local savedMusicName = savedMusicPath:match("^H4xScripts/Music/([%w_%-]+%.mp3)$")
    if savedMusicName and type(isfile) == "function" and isfile(savedMusicPath) and type(getcustomasset) == "function" then
        local savedAssetOk, savedAsset = pcall(getcustomasset, savedMusicPath)
        if savedAssetOk and type(savedAsset) == "string" and savedAsset ~= "" then
            localMusicAsset = savedAsset
            selectedLocalMusicPath = savedMusicPath
        end
    end

    musicUrlInput = musicSection:Input({
        Title = "Direct MP3 URL",
        Placeholder = "https://your-site.com/audio/song.mp3",
        Value = tostring(animeSettings.MusicUrl or ""),
        Callback = function(value)
            animeSettings.MusicUrl = tostring(value or "")
            SaveAnimeSettings()
        end,
    })

    musicFileNameInput = musicSection:Input({
        Title = "Save MP3 As",
        Placeholder = "MySong",
        Value = tostring(animeSettings.MusicFileName or ""),
        Callback = function(value)
            animeSettings.MusicFileName = tostring(value or "")
            SaveAnimeSettings()
        end,
    })

    savedMusicDropdown = musicSection:Dropdown({
        Title = "Saved MP3 Files",
        Values = ListSavedMp3s(),
        Value = savedMusicName,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            if type(value) ~= "string" then return end
            local ok, err = pcall(LoadLocalMp3, value)
            if not ok then
                notify("Local Music", tostring(err):match("^[^\r\n]+") or "Could not load the selected MP3.")
                return
            end
            notify("Local Music", value .. " selected. Press Play Saved MP3 to start it.")
        end,
    })

    musicSection:Button({
        Title = "Download & Play MP3",
        Icon = "download",
        Callback = function()
            local url = TrimMusicText(musicUrlInput and musicUrlInput.Value or animeSettings.MusicUrl)
            local fileName = CleanMusicFileName(musicFileNameInput and musicFileNameInput.Value or animeSettings.MusicFileName)
            if url == "" then
                notify("MP3 Download", "Enter a direct HTTPS link to an MP3 file.")
                return
            end
            if url:find("[%c%s]") or not url:match("^https://") then
                notify("MP3 Download", "Only valid HTTPS audio links are accepted.")
                return
            end
            local host = (url:match("^https://([^/%?#]+)") or ""):lower()
            if host == "youtube.com" or host == "www.youtube.com" or host:match("%.youtube%.com$") or host == "youtu.be" or host:match("%.youtu%.be$") or host == "googlevideo.com" or host:match("%.googlevideo%.com$") then
                notify("MP3 Download", "YouTube watch links are not direct MP3 files. Use an MP3 link you own or are permitted to download.")
                return
            end

            notify("MP3 Download", "Downloading and checking the MP3 file...")
            task.spawn(function()
                local ok, result = xpcall(function()
                    EnsureMusicFolder()
                    local body = GetDirectMp3Response(url)
                    assert(type(body) == "string" and #body >= 4, "The audio host returned an empty or invalid file.")
                    assert(#body <= 40 * 1024 * 1024, "The MP3 is larger than the 40 MB download limit.")
                    assert(LooksLikeMp3(body), "The URL did not return valid MP3 audio data.")

                    local candidate = fileName .. ".mp3"
                    local path = MUSIC_FOLDER .. "/" .. candidate
                    local suffix = 2
                    while isfile(path) and suffix <= 999 do
                        candidate = fileName .. "_" .. tostring(suffix) .. ".mp3"
                        path = MUSIC_FOLDER .. "/" .. candidate
                        suffix += 1
                    end
                    assert(not isfile(path), "Could not find an unused filename for this MP3.")

                    writefile(path, body)
                    local saved = readfile(path)
                    assert(type(saved) == "string" and #saved == #body and LooksLikeMp3(saved), "The saved MP3 failed verification.")
                    local assetOk, asset = pcall(getcustomasset, path)
                    assert(assetOk and type(asset) == "string" and asset ~= "", "getcustomasset could not load the downloaded MP3.")
                    return { Name = candidate, Path = path, Asset = asset }
                end, debug.traceback)

                if not ok then
                    notify("MP3 Download Failed", tostring(result):match("^[^\r\n]+") or "The MP3 could not be downloaded.")
                    return
                end

                localMusicAsset = result.Asset
                selectedLocalMusicPath = result.Path
                animeSettings.DownloadedMusicPath = result.Path
                animeSettings.MusicFileName = fileName
                SaveAnimeSettings()

                local playOk, playErr = pcall(function()
                    animeMusic:Stop()
                    animeMusic.SoundId = result.Asset
                    animeMusic.Volume = math.clamp(tonumber(animeSettings.MusicVolume) or 25, 0, 100) / 100
                    animeMusic.Looped = animeSettings.MusicLooped == true
                    animeMusic.TimePosition = 0
                    animeMusic:Play()
                end)
                RefreshSavedMp3Dropdown(result.Name)
                if not playOk then
                    notify("MP3 Saved", result.Name .. " was saved, but playback failed: " .. tostring(playErr))
                    return
                end
                notify("MP3 Ready", result.Name .. " downloaded to H4xScripts Music and playback was requested.")
            end)
        end,
    })

    musicSection:Button({
        Title = "Play Saved MP3",
        Icon = "play",
        Callback = function()
            if not selectedLocalMusicPath or not localMusicAsset then
                notify("Local Music", "Select a saved MP3 file first.")
                return
            end
            local ok, err = pcall(function()
                animeMusic:Stop()
                animeMusic.SoundId = localMusicAsset
                animeMusic.Volume = math.clamp(tonumber(animeSettings.MusicVolume) or 25, 0, 100) / 100
                animeMusic.Looped = animeSettings.MusicLooped == true
                animeMusic.TimePosition = 0
                animeMusic:Play()
            end)
            if not ok then
                notify("Local Music", "Could not play the saved MP3: " .. tostring(err))
                return
            end
            notify("Local Music", "Playback requested.")
        end,
    })

    local musicPresets = {
        ["初音ミク・重音テトSV】あっはっは笑【巡巡】"] = "89908320392687",
        ["Hatsune Miku - Ievan Polkka"] = "108878711230593",
        ["Never Ending Dance feat. 重音テトSV"] = "95337761686237",
        ["Satsuki FT Hatsune Miku & Kasane Teto Mesmerizer(Audio)"] = "72889719050307",
        ["bg music 1"] = "101903165712455",
        ["lord verity"] = "104941993076749",
        ["bad apple"] = "123572020022002",
        ["cool music!!!"] = "118759837130012",
        ["devil may cry"] = "112210136966411",
        ["admiring you"] = "136208016606825",
        ["love me love me love me"] = "80227536040311",
    }

    local musicPresetNames = {
        "初音ミク・重音テトSV】あっはっは笑【巡巡】",
        "Hatsune Miku - Ievan Polkka",
        "Never Ending Dance feat. 重音テトSV",
        "Satsuki FT Hatsune Miku & Kasane Teto Mesmerizer(Audio)",
        "bg music 1",
        "lord verity",
        "bad apple",
        "cool music!!!",
        "devil may cry",
        "admiring you",
        "love me love me love me",
    }
    local savedMusicPreset = musicPresets[animeSettings.MusicPreset] and animeSettings.MusicPreset or nil

    musicSection:Dropdown({
        Title = "Music Presets",
        Values = musicPresetNames,
        Value = savedMusicPreset,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            local id = type(value) == "string" and musicPresets[value]
            if not id then return end
            animeSettings.MusicPreset = value
            animeSettings.MusicId = id
            if musicIdInput and type(musicIdInput.Set) == "function" then
                pcall(musicIdInput.Set, musicIdInput, id)
            end
            SaveAnimeSettings()
            notify("Music Preset", value .. " selected. Press Play / Restart to start it.")
        end,
    })

    local function GetMusicAssetId()
        local raw = tostring(musicIdInput and musicIdInput.Value or animeSettings.MusicId or "")
        raw = raw:match("^%s*(.-)%s*$") or ""
        local id = raw:match("^(%d+)$") or raw:match("^rbxassetid://(%d+)$")
        if not id or #id > 20 or tonumber(id) == 0 then return nil end
        animeSettings.MusicId = id
        SaveAnimeSettings()
        return id
    end

    musicSection:Slider({
        Title = "Music Volume",
        Step = 5,
        UpdateOnRelease = true,
        Value = {
            Min = 0,
            Max = 100,
            Default = math.clamp(tonumber(animeSettings.MusicVolume) or 25, 0, 100),
        },
        Callback = function(value)
            local volume = math.clamp(tonumber(value) or 25, 0, 100)
            animeSettings.MusicVolume = volume
            animeMusic.Volume = volume / 100
            SaveAnimeSettings()
        end,
    })

    musicSection:Toggle({
        Title = "Loop Music",
        Value = animeSettings.MusicLooped == true,
        Callback = function(value)
            animeSettings.MusicLooped = value == true
            animeMusic.Looped = value == true
            SaveAnimeSettings()
        end,
    })

    musicSection:Button({
        Title = "Play / Restart",
        Icon = "play",
        Callback = function()
            local id = GetMusicAssetId()
            if not id then
                notify("Music Player", "Enter a valid audio asset ID first.")
                return
            end
            local ok, err = pcall(function()
                animeMusic:Stop()
                animeMusic.SoundId = "rbxassetid://" .. id
                animeMusic.Volume = math.clamp(tonumber(animeSettings.MusicVolume) or 25, 0, 100) / 100
                animeMusic.Looped = animeSettings.MusicLooped == true
                animeMusic.TimePosition = 0
                animeMusic:Play()
            end)
            if not ok then
                notify("Music Player", "Could not start this audio " .. tostring(err))
                return
            end
            notify("Music Player", "Playback requested. Some audio assets may be private or unavailable.")
        end,
    })

    musicSection:Button({
        Title = "Pause",
        Icon = "pause",
        Callback = function()
            if animeMusic.IsPlaying then
                pcall(animeMusic.Pause, animeMusic)
            end
        end,
    })

    musicSection:Button({
        Title = "Resume",
        Icon = "play",
        Callback = function()
            if animeMusic.SoundId ~= "" and not animeMusic.IsPlaying then
                pcall(animeMusic.Resume, animeMusic)
            end
        end,
    })

    musicSection:Button({
        Title = "Stop",
        Icon = "square",
        Callback = function()
            pcall(animeMusic.Stop, animeMusic)
        end,
    })

    Window:OnDestroy(function()
        if animeMusic then
            pcall(animeMusic.Stop, animeMusic)
            pcall(animeMusic.Destroy, animeMusic)
        end
    end)
end
