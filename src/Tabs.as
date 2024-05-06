// c 2024-02-22
// m 2024-02-27

bool  editTabOpen     = false;
float maxAuthorWidth  = 0.0f;
float maxNameWidth    = 0.0f;
bool  switchToEditTab = false;

void Tab_PluginList() {
    if (!UI::BeginTabItem(Icons::List + " Plugins (" + allPlugins.Length + ")###tab-plugins"))
        return;

    if (UI::BeginTable("##plugin-table", 3, UI::TableFlags::ScrollY)) {
        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("Enabled", UI::TableColumnFlags::WidthFixed, scale * 55.0f);
        UI::TableSetupColumn("Plugin",  UI::TableColumnFlags::WidthFixed, maxNameWidth);
        UI::TableSetupColumn("Author",  UI::TableColumnFlags::WidthFixed, maxAuthorWidth);
        UI::TableHeadersRow();

        UI::ListClipper clipper(allPluginsSorted.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Meta::Plugin@ plugin = allPluginsSorted[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::BeginDisabled(essential.Find(plugin.ID) > -1);
                if (UI::Checkbox("##checkbox" + plugin.ID, plugin.Enabled) != plugin.Enabled)
                    TogglePlugin(plugin);
                UI::EndDisabled();

                UI::SameLine();
                switch (plugin.SignatureLevel) {
                    case -1:    UI::Text(Icons::Code);      break;
                    case 10000: UI::Text(Icons::Heartbeat); break;
                    default:;
                }

                UI::TableNextColumn();
                UI::Text(plugin.Name);

                UI::TableNextColumn();
                UI::Text(plugin.Author);
            }
        }

        UI::EndTable();
    }

    UI::EndTabItem();
}

void Tab_ProfileList() {
    if (!UI::BeginTabItem(Icons::ThLarge + " Profiles (" + profiles.Length + ")###tab-profiles"))
        return;

    UI::TextWrapped("Remember to save when you're done editing! Auto-save will come in a future update.");

    if (UI::Button(Icons::PlusCircle + " Create Profile"))
        CreateProfile();

    UI::SameLine();
    if (UI::Button(Icons::FileO + " Load Profiles"))
        LoadProfiles();

    UI::SameLine();
    if (UI::Button(Icons::FloppyO + " Save Profiles" + (dirty ? " *" : "")))
        SaveProfiles();

    if (UI::BeginTable("##profile-table", 4, UI::TableFlags::ScrollY)) {
        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("Profile");
        for (uint i = 0; i < 3; i++)
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, scale * 30.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(profiles.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                if (i == int(profiles.Length))
                    break;

                Profile@ profile = profiles[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(profile.name);

                UI::TableNextColumn();
                if (UI::Button(Icons::Forward + "##" + profile.id))
                    profile.Activate();

                UI::TableNextColumn();
                if (UI::Button(Icons::Pencil + "##" + profile.id)) {
                    @editingProfile = profile;
                    editTabOpen     = true;
                    switchToEditTab = true;
                }

                UI::TableNextColumn();
                if (UI::Button(Icons::TrashO + "##" + profile.id)) {
                    dirty = true;

                    if (editingProfile is profiles[i]) {
                        @editingProfile = null;
                        editTabOpen = false;
                    }

                    profiles.RemoveAt(i);
                    break;
                }
            }
        }

        UI::EndTable();
    }

    UI::EndTabItem();
}

void Tab_EditProfile() {
    int tabFlags = UI::TabItemFlags::None;

    if (switchToEditTab) {
        switchToEditTab = false;
        tabFlags |= UI::TabItemFlags::SetSelected;
    }

    if (!UI::BeginTabItem(Icons::Pencil + " Edit Profile (" + editingProfile.name + ")###tab-editing", editTabOpen, tabFlags))
        return;

    bool changed = false;
    editingProfile.name = UI::InputText("Profile Name", editingProfile.name, changed);
    if (changed)
        dirty = true;

    if (UI::Button("Enable All")) {
        for (uint i = 0; i < editingProfile.plugins.Length; i++) {
            if (essential.Find(editingProfile.plugins[i].id) == -1)
                editingProfile.plugins[i].action = Action::Enable;
        }

        dirty = true;
    }

    UI::SameLine();
    if (UI::Button("Disable All")) {
        for (uint i = 0; i < editingProfile.plugins.Length; i++) {
            if (essential.Find(editingProfile.plugins[i].id) == -1)
                editingProfile.plugins[i].action = Action::Disable;
        }

        dirty = true;
    }

    UI::SameLine();
    if (UI::Button("Ignore All")) {
        for (uint i = 0; i < editingProfile.plugins.Length; i++)
            editingProfile.plugins[i].action = Action::Ignore;

        dirty = true;
    }

    if (UI::BeginTable("##profile-plugin-table", 4, UI::TableFlags::ScrollY)) {
        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("Plugin");
        UI::TableSetupColumn("Enable" , UI::TableColumnFlags::WidthFixed, scale * 45.0f);
        UI::TableSetupColumn("Disable", UI::TableColumnFlags::WidthFixed, scale * 45.0f);
        UI::TableSetupColumn("Ignore" , UI::TableColumnFlags::WidthFixed, scale * 45.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(editingProfile.plugins.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Plugin@ plugin = editingProfile.plugins[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(plugin.name);

                UI::BeginDisabled(essential.Find(plugin.id) > -1);

                UI::TableNextColumn();
                if (UI::Checkbox("##enable" + plugin.id, plugin.action == Action::Enable) && plugin.action != Action::Enable) {
                    plugin.action = Action::Enable;
                    dirty = true;
                }

                UI::TableNextColumn();
                if (UI::Checkbox("##disable" + plugin.id, plugin.action == Action::Disable) && plugin.action != Action::Disable) {
                    plugin.action = Action::Disable;
                    dirty = true;
                }

                UI::TableNextColumn();
                if (UI::Checkbox("##ignore" + plugin.id, plugin.action == Action::Ignore) && plugin.action != Action::Ignore) {
                    plugin.action = Action::Ignore;
                    dirty = true;
                }

                UI::EndDisabled();
            }
        }

        UI::EndTable();
    }

    UI::EndTabItem();
}
