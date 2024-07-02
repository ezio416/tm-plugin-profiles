// c 2024-02-22
// m 2024-06-03

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
    if (UI::BeginMenu(title)) {
        if (UI::MenuItem("Show Window", "", S_Show))
            S_Show = !S_Show;

        UI::Separator();

        for (uint i = 0; i < profiles.Length; i++) {
            Profile@ profile = profiles[i];

            if (UI::MenuItem(profile.name))
                profile.Activate();
        }

        UI::EndMenu();
    }
}

void Render() {
    if (
        !S_Show
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
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

    if (UI::Begin(title, S_Show, UI::WindowFlags::None)) {
        UI::BeginTabBar("##tabs");
            Tab_PluginList();
            Tab_ProfileList();

            if (editTabOpen)
                Tab_EditProfile();
            else
                @editingProfile = null;

            Tab_Troubleshooting();
        UI::EndTabBar();
    }

    UI::End();
}
