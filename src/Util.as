// c 2024-02-22
// m 2024-02-22

void RefreshPlugins() {
    @plugins = Meta::AllPlugins();
}

void TogglePlugin(Meta::Plugin@ plugin) {
    if (plugin.Enabled)
        plugin.Disable();
    else
        plugin.Enable();
}