// c 2024-02-22
// m 2024-02-26

Meta::Plugin@[]@ allPlugins;
uint             allPluginsCount = 0;
Meta::Plugin@[]  allPluginsSorted;
bool             dirty           = false;
const string[]   essential       = { "Camera", "NadeoServices", "PluginManager", "VehicleState", "PluginProfiles" };
const float      scale           = UI::GetScale();
const string     title           = "\\$FFF" + Icons::Plug + "\\$G Plugin Profiles";

void Main() {
    RefreshAllPlugins();
    LoadProfiles();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Show))
        S_Show = !S_Show;
}

void Render() {
    if (!S_Show)
        return;

    RefreshAllPlugins();

    if (allPluginsCount != allPlugins.Length) {
        SortAllPlugins();

        if (allPluginsCount > 0) {
            for (uint i = 0; i < profiles.Length; i++)
                profiles[i].RefreshPlugins();
        }

        allPluginsCount = allPlugins.Length;
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