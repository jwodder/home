local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.color_scheme = 'jwodder'
config.enable_scroll_bar = true
config.font = wezterm.font('Menlo')
config.font_size = 12
config.hide_tab_bar_if_only_one_tab = false
config.initial_cols = 80
config.initial_rows = 24
config.ssh_domains = {}
config.switch_to_last_active_tab_when_closing_tab = true
config.use_fancy_tab_bar = false

config.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 500 }

config.keys = {
    { key = '?', mods = 'LEADER', action = act.ActivateCommandPalette, },
    { key = '`', mods = "CMD", action = act.ActivateWindowRelative(1), },
    { key = 'b', mods = 'LEADER|SHIFT', action = act.ActivateLastTab, },

    {
        key = 'c',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab {
            args = { '/usr/local/bin/bash', '-l' },
            cwd = os.getenv("HOME"),
        },
    },

    { key = 'c', mods = 'LEADER|CTRL', action = act.ActivateCopyMode, },
    { key = 'g', mods = 'LEADER', action = act.ShowTabNavigator, },
    { key = 'g', mods = 'LEADER|SHIFT', action = act.ShowTabNavigator, },
    { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1), },
    { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1), },

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

    { key = 'LeftArrow', mods = 'CMD', action = act.ActivateTabRelative(-1), },
    { key = 'RightArrow', mods = 'CMD', action = act.ActivateTabRelative(1), },
    { key = 'PageUp', action = act.ScrollByPage(-1) },
    { key = 'PageDown', action = act.ScrollByPage(1) },
    { key = 'Home', action = act.ScrollToTop },
    { key = 'End', action = act.ScrollToBottom },
}

copy_mode = wezterm.gui.default_key_tables().copy_mode
table.insert(
    copy_mode,
    { key = 'Space', action = act.CopyMode { SetSelectionMode = 'Block' }, }
)
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
            action = act.SplitVertical { domain = 'CurrentPaneDomain' },
        },
        {
            key = 's',
            action = act.SplitVertical { domain = 'CurrentPaneDomain' },
        },
        { key = 'j', action = act.ActivatePaneDirection 'Down', },
        { key = 'k', action = act.ActivatePaneDirection 'Up', },
        { key = '^', action = act.ActivatePaneByIndex(0), },
        { key = '0', action = act.ActivatePaneByIndex(0), },
        -- TODO: Doesn't work as of 20240203-110809-5046fc22:
        -- { key = '$', action = act.ActivatePaneByIndex(-1), },
        { key = 'Tab', action = act.ActivatePaneDirection 'Next', },
        { key = 'n', action = act.ActivatePaneDirection 'Next', },
        { key = 'p', action = act.ActivatePaneDirection 'Prev', },
        { key = 'x', action = act.CloseCurrentPane { confirm = false }, },
        { key = 'z', mods = 'NONE', action = act.TogglePaneZoomState, },
    }
}

config.launch_menu = {
    {
        label = 'work',
        args = { '/usr/local/bin/bash', '-l' },
        cwd = os.getenv("HOME") .. "/work",
    },
    {
        label = 'Screen',
        args = { 'bash', '-l', '-c', 'screen' },
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

wezterm.on('bell', function(window, pane)
    if window:is_focused() and window:active_pane():pane_id() == pane:pane_id() then
        return
    end

    title = ""
    t = pane:tab()
    if t then
        title = t:get_title()
    end
    if title == "" then
        title = pane:get_title()
    end

    window:toast_notification('wezterm', 'Bell in ' .. title)
end)

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    return string.format('WezTerm — %d×%d', pane.width, pane.height)
end)

return config
