local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.colors = {
    foreground = "#f2f2f2",
    background = "#000000",
    cursor_bg = "#9a9a9a",
    cursor_border = "#4d4d4d",
    cursor_fg = "#ffffff",
    selection_bg = "#414141",
    selection_fg = "#000000",
    scrollbar_thumb = "#cccccc",
    ansi = {
        "#000000",  -- Black
        -- "#990000",  -- Red
        "#b30000",  -- Red
        "#00a600",  -- Green
        "#999900",  -- Yellow
        -- "#5455cb",  -- Blue
        "#6868d1",  -- Blue
        "#b200b2",  -- Magenta
        "#00a6b2",  -- Cyan
        "#bfbfbf",  -- White
    },
    brights = {
        "#666666",  -- Bright black
        -- "#e50000",  -- Bright red
        "#ff0000",  -- Bright red
        "#00d900",  -- Bright green
        "#e5e500",  -- Bright yellow
        -- "#5555ff",  -- Bright blue
        "#6f6fff",  -- Bright blue
        "#e500e5",  -- Bright magenta
        "#00e5e5",  -- Bright cyan
        "#e5e5e5",  -- Bright white
    },
}

config.enable_scroll_bar = true
config.font = wezterm.font('Menlo')
config.font_size = 12
config.hide_tab_bar_if_only_one_tab = false
config.initial_cols = 80
config.initial_rows = 24
config.native_macos_fullscreen_mode = true
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
config.ssh_domains = {}
config.switch_to_last_active_tab_when_closing_tab = true
config.use_fancy_tab_bar = false

config.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 1000 }

-- <https://github.com/wezterm/wezterm/issues/3803#issuecomment-1608954312>
config.hyperlink_rules = {
    -- URL in parentheses: (URL)
    { regex = '\\((\\w+://\\S+)\\)', format = '$1', highlight = 1, },
    -- URL in brackets: [URL]
    { regex = '\\[(\\w+://\\S+)\\]', format = '$1', highlight = 1, },
    -- URL in curly braces: {URL}
    { regex = '\\{(\\w+://\\S+)\\}', format = '$1', highlight = 1, },
    -- URL in angle brackets: <URL>
    { regex = '<(\\w+://\\S+)>', format = '$1', highlight = 1, },
    -- URL not wrapped in brackets
    { regex = '[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)', format = '$1', highlight = 1, },
    -- implicit mailto link
    { regex = '\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b', format = 'mailto:$0', },
}

config.keys = {
    { key = 'PageUp', action = act.ScrollByPage(-1) },
    { key = 'PageDown', action = act.ScrollByPage(1) },
    { key = 'Home', action = act.ScrollToTop },
    { key = 'End', action = act.ScrollToBottom },

    { key = 'UpArrow', mods = 'CMD', action = act.ActivatePaneDirection("Up"), },
    { key = 'DownArrow', mods = 'CMD', action = act.ActivatePaneDirection("Down"), },
    { key = 'LeftArrow', mods = 'CMD', action = act.ActivatePaneDirection("Left"), },
    { key = 'RightArrow', mods = 'CMD', action = act.ActivatePaneDirection("Right"), },
    { key = '`', mods = "CMD", action = act.ActivateWindowRelative(1), },
    { key = '[', mods = 'CMD', action = act.ActivateTabRelative(-1), },
    { key = ']', mods = 'CMD', action = act.ActivateTabRelative(1), },
    { key = '[', mods = 'CMD|SHIFT', action = act.MoveTabRelative(-1), },
    { key = ']', mods = 'CMD|SHIFT', action = act.MoveTabRelative(1), },
    { key = 'e', mods = 'CMD', action = act.CharSelect, },
    { key = 'p', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette, },

    {
        key = 't',
        mods = 'CMD',
        action = act.SpawnCommandInNewTab {
            args = { '/usr/local/bin/bash', '-l' },
            cwd = os.getenv("HOME"),
        },
    },

    { key = '?', mods = 'LEADER', action = act.ActivateCommandPalette, },
    { key = 'b', mods = 'LEADER|SHIFT', action = act.ActivateLastTab, },
    { key = 'c', mods = 'LEADER|CTRL', action = act.ActivateCopyMode, },

    {
        key = 'f',
        mods = 'LEADER|SHIFT',
        action = act.SpawnCommandInNewTab {
            args = {
                os.getenv("HOME") .. "/bin/with-tab-title",
                "firefly",
                'ssh',
                'firefly',
            },
        },
    },


    { key = 'g', mods = 'LEADER', action = act.ShowTabNavigator, },
    { key = 'g', mods = 'LEADER|SHIFT', action = act.ShowTabNavigator, },

    {
        key = 'q',
        mods = 'LEADER|CTRL',
        action = act.SendKey { key = 'q', mods = 'CTRL' },
    },

    {
        key = 'r',
        mods = 'LEADER|CTRL',
        action = act.ActivateKeyTable {
            name = 'manage_panes',
            timeout_milliseconds = 500,
        },
    },

    {
        key = 's',
        mods = 'LEADER|SHIFT',
        action = act.SpawnCommandInNewTab {
            args = {
                os.getenv("HOME") .. "/bin/with-tab-title",
                "SDF",
                'ssh',
                'jwodder@meta.freeshell.org',
            },
        },
    },

    {
        key = 't',
        mods = 'LEADER|SHIFT',
        action = act.PromptInputLine {
            description = 'Tab name',
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        }
    },
}

copy_mode = wezterm.gui.default_key_tables().copy_mode
table.insert(
    copy_mode,
    { key = 's', action = act.CopyMode 'PageDown' }
)
table.insert(
    copy_mode,
    { key = 's', mods = 'SHIFT', action = act.CopyMode 'PageUp' }
)
table.insert(
    copy_mode,
    { key = 'w', mods = 'SHIFT', action = act.CopyMode 'MoveBackwardWord' }
)

config.key_tables = {
    copy_mode = copy_mode,

    manage_panes = {
        { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 1 } },
        { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 1 } },
        {
            key = '|',
            action = act.SplitVertical { cwd = os.getenv("HOME") },
        },
        {
            key = 's',
            action = act.SplitVertical { cwd = os.getenv("HOME") },
        },
        { key = 'j', action = act.ActivatePaneDirection 'Down', },
        { key = 'k', action = act.ActivatePaneDirection 'Up', },
        { key = '^', action = act.ActivatePaneByIndex(0), },
        { key = '0', action = act.ActivatePaneByIndex(0), },
        {
            key = '$',
            -- <https://github.com/wezterm/wezterm/issues/6562>
            action = wezterm.action_callback(function(window, pane)
                local last_pane_index = #window:active_tab():panes() - 1
                window:perform_action(wezterm.action.ActivatePaneByIndex(last_pane_index), pane)
            end)
        },
        { key = 'Tab', action = act.ActivatePaneDirection 'Next', },
        { key = 'n', action = act.ActivatePaneDirection 'Next', },
        { key = 'p', action = act.ActivatePaneDirection 'Prev', },
        { key = 'x', action = act.CloseCurrentPane { confirm = false }, },
        { key = 'z', mods = 'NONE', action = act.TogglePaneZoomState, },
    }
}

config.launch_menu = {
    {
        label = 'Shell',
        args = { '/usr/local/bin/bash', '-l' },
        cwd = os.getenv("HOME") .. "/work",
    },
    {
        label = 'tmux',
        args = { 'bash', '-l', '-c', 'tmux' },
        cwd = os.getenv("HOME") .. "/work",
    },
    {
        label = 'scripta',
        args = {
            os.getenv("HOME") .. "/bin/with-tab-title",
            "scripta",
            "/usr/local/bin/bash",
            "-l",
        },
        cwd = os.getenv("HOME") .. "/work/scripta/scraps/items",
    },
}

config.window_padding = {
    left = '1cell',
    right = '1.5cell',
    top = '0.5cell',
    bottom = '0cell',
}

-- wezterm.on('bell', function(window, pane)
-- TODO: Why isn't this filter working?
--     if window:is_focused() and window:active_pane():pane_id() == pane:pane_id() then
--         return
--     end
--
--     title = ""
--     t = pane:tab()
--     if t then
--         title = t:get_title()
--     end
--     if title == "" then
--         title = pane:get_title()
--     end
--
--     window:toast_notification('wezterm', 'Bell in ' .. title)
-- end)

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    local win_title = tab.window_title
    if win_title and #win_title > 0 then
        return string.format('WezTerm — %d×%d — %s', pane.width, pane.height, win_title)
    else
        return string.format('WezTerm — %d×%d', pane.width, pane.height)
    end
end)

return config
