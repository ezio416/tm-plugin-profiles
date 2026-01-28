Meta::Plugin@[]@ allPlugins;
uint             allPluginsCount = 0;
Meta::Plugin@[]  allPluginsSorted;
bool             dirty           = false;
const string[]   essential       = { "Camera", "NadeoServices", "PluginManager", "VehicleState", "PluginProfiles" };
const string     title           = "\\$FFF" + Icons::Plug + "\\$G Plugin Profiles";

void Main() {
    RefreshAllPlugins();
    LoadProfiles();
}

void RenderMenu() {
    if (UI::BeginMenu(title)) {
        if (UI::MenuItem("Show Window", "", S_Show)) {
            S_Show = !S_Show;
        }

        UI::Separator();

        for (uint i = 0; i < profiles.Length; i++) {
            Profile@ profile = profiles[i];

            if (UI::MenuItem(profile.name)) {
                profile.Activate();
            }
        }

        UI::EndMenu();
    }
}

void Render() {
    if (false
        or !S_Show
        or (true
            and S_HideWithGame
            and !UI::IsGameUIVisible()
        )
        or (true
            and S_HideWithOP
            and !UI::IsOverlayShown()
        )
    ) {
        return;
    }

    RefreshAllPlugins();

    if (allPluginsCount != allPlugins.Length) {
        SortAllPlugins();

        if (allPluginsCount > 0) {
            for (uint i = 0; i < profiles.Length; i++) {
                profiles[i].RefreshPlugins();
            }
        }

        allPluginsCount = allPlugins.Length;
    }

    if (UI::Begin(title, S_Show, UI::WindowFlags::None)) {
        UI::BeginTabBar("##tabs");

        Tab_PluginList();
        Tab_ProfileList();

        if (editTabOpen) {
            Tab_EditProfile();
        } else {
            @editingProfile = null;
        }

        UI::EndTabBar();
    }

    UI::End();
}
