Meta::Plugin@[]@ allPlugins;
uint             allPluginsCount = 0;
Meta::Plugin@[]  allPluginsSorted;
bool             dirty           = false;
const string     title           = "\\$FFF" + Icons::Plug + "\\$G Plugin Profiles";

const string[] essential = {
    "Camera",
    "Controls",
    "NadeoServices",
    "PluginManager",
    "VehicleState",
    "PluginProfiles"
};

void Main() {
    RefreshAllPlugins();
    LoadProfiles();
}

void OnDestroyed() {
    EnableEssentials();
}

void OnDisabled() {
    EnableEssentials();
}

void OnSettingsChanged() {
    if (_S_VersionsPre != S_Versions) {
        _S_VersionsPre = S_Versions;
        SetColumnWidths();
    }

    if (_S_DisableEssentialPre != S_DisableEssential) {
        _S_DisableEssentialPre = S_DisableEssential;

        if (!S_DisableEssential) {
            EnableEssentials();
        }
    }
}

void RenderMenu() {
    if (UI::BeginMenu(title)) {
        if (UI::MenuItem("Show Window", "", S_Show)) {
            S_Show = !S_Show;
        }

        UI::Separator();

        for (uint i = 0; i < profiles.Length; i++) {
            Profile@ profile = profiles[i];

            UI::BeginDisabled(true
                and !S_DisableEssential
                and profile.unsafe
            );
            if (UI::MenuItem((profile.unsafe ? "\\$FA0" : "") + profile.name)) {
                profile.Activate();
            }
            HoverTooltip("Activate");
            UI::EndDisabled();
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

    if (UI::Begin(title, S_Show)) {
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
