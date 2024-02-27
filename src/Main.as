// c 2024-02-22
// m 2024-02-22

Meta::Plugin@[]@ allPlugins;
uint             allPluginsCount = 0;
Meta::Plugin@[]  allPluginsSorted;
const string[]   essential       = { "Camera", "NadeoServices", "PluginManager", "VehicleState", "PluginProfiles" };
const float      scale           = UI::GetScale();
const string     title           = "\\$FFF" + Icons::Plug + "\\$G Plugin Profiles";

void Main() {
    RefreshPlugins();
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

    if (allPluginsCount != allPlugins.Length) {
        allPluginsCount = allPlugins.Length;
        SortPlugins();
    }

    UI::Begin(title, S_Show, UI::WindowFlags::None);
        UI::BeginTabBar("##tabs");
            Tab_PluginList();
            Tab_ProfileList();

            if (editTabOpen)
                Tab_EditProfile();
            else
                @editingProfile = null;
        UI::EndTabBar();
    UI::End();
}