// c 2024-02-22
// m 2024-02-22

const string[]   essential = { "Camera", "NadeoServices", "PluginManager", "VehicleState", "PluginProfiles" };
Meta::Plugin@[]@ plugins;
uint             pluginsCount = 0;
Meta::Plugin@[]  pluginsSorted;
const string     title = "\\$FFF" + Icons::Plug + "\\$G Plugin Profiles";

void Main() {
    LoadProfiles();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Show))
        S_Show = !S_Show;
}

void Render() {
    if (!S_Show)
        return;

    RefreshPlugins();

    if (pluginsCount != plugins.Length) {
        pluginsCount = plugins.Length;
        SortPlugins();
    }

    UI::Begin(title, S_Show, UI::WindowFlags::None);
        UI::BeginTabBar("##tabs");
            Tab_PluginList();
            Tab_ProfileList();
        UI::EndTabBar();
    UI::End();
}