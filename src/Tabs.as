// c 2024-02-22
// m 2024-02-22

bool editTabOpen     = false;
bool switchToEditTab = false;

void Tab_PluginList() {
    if (!UI::BeginTabItem(Icons::List + " Plugins"))
        return;

    float maxNameWidth = 0.0f;
    float maxAuthorWidth = 0.0f;
    for (uint i = 0; i < allPluginsSorted.Length; i++) {
        maxNameWidth = Math::Max(maxNameWidth, Draw::MeasureString(allPluginsSorted[i].Name).x);
        maxAuthorWidth = Math::Max(maxAuthorWidth, Draw::MeasureString(allPluginsSorted[i].Author).x);
    }

    if (UI::BeginTable("##plugin-table", 4, UI::TableFlags::ScrollY)) {
        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("siteid", UI::TableColumnFlags::WidthFixed, 50.0f);
        // UI::TableSetupColumn("id");
        UI::TableSetupColumn("enabled", UI::TableColumnFlags::WidthFixed, 70.0f);
        UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed, maxNameWidth);
        UI::TableSetupColumn("author", UI::TableColumnFlags::WidthFixed, maxAuthorWidth);
        UI::TableHeadersRow();

        UI::ListClipper clipper(allPluginsSorted.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Meta::Plugin@ plugin = allPluginsSorted[i];

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text(tostring(plugin.SiteID));

                // UI::TableNextColumn();
                // UI::Text(plugin.ID);

                UI::TableNextColumn();
                UI::BeginDisabled(essential.Find(plugin.ID) > -1);
                if (UI::Checkbox("##checkbox" + plugin.ID, plugin.Enabled) != plugin.Enabled)
                    TogglePlugin(plugin);
                UI::EndDisabled();

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
    if (!UI::BeginTabItem(Icons::ThLarge + " Profiles"))
        return;

    if (UI::Button(Icons::PlusCircle + " Create Profile"))
        CreateProfile();

    UI::SameLine();
    if (UI::Button(Icons::FloppyO + " Save Profiles"))
        SaveProfiles();

    if (UI::BeginTable("##profile-table", 4, UI::TableFlags::ScrollY)) {
        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("name");
        UI::TableSetupColumn("id", UI::TableColumnFlags::WidthFixed, scale * 260.0f);
        UI::TableSetupColumn("",   UI::TableColumnFlags::WidthFixed, scale * 30.0f);
        UI::TableSetupColumn("",   UI::TableColumnFlags::WidthFixed, scale * 30.0f);
        UI::TableHeadersRow();

        for (uint i = 0; i < profiles.Length; i++) {
            Profile@ profile = profiles[i];

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(profile.name);

            UI::TableNextColumn();
            UI::Text(profile.id);

            UI::TableNextColumn();
            if (UI::Button(Icons::Pencil + "##" + profile.id)) {
                @editingProfile = profile;
                editTabOpen     = true;
                switchToEditTab = true;
            }

            UI::TableNextColumn();
            if (UI::Button(Icons::TrashO + "##" + profile.id)) {
                if (editingProfile is profiles[i])
                    @editingProfile = null;

                profiles.RemoveAt(i);
                break;
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

    if (!UI::BeginTabItem(Icons::Pencil + " Edit Profile", editTabOpen, tabFlags))
        return;

    editingProfile.name = UI::InputText("Profile Name", editingProfile.name, false);

    ;

    UI::Text("Profile ID: " + editingProfile.id);

    UI::EndTabItem();
}