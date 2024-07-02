// c 2024-02-22
// m 2024-06-03

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

                const bool isEssential = essential.Find(plugin.ID) > -1;

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::BeginDisabled(isEssential);
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
                UI::Text((isEssential ? "\\$888" : "") + plugin.Name);

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

    if (!S_Autosave)
        UI::TextWrapped("Remember to save when you're done editing! Enable autosave in settings.");

    if (UI::Button(Icons::PlusCircle + " Create Profile"))
        CreateProfile();

    if (S_Autosave) {
        if (dirty)
            SaveProfiles();
    } else {
        UI::SameLine();
        if (UI::Button(Icons::FileO + " Load Profiles"))
            LoadProfiles();

        UI::BeginDisabled(!dirty);
        UI::SameLine();
        if (UI::Button(Icons::FloppyO + " Save Profiles" + (dirty ? " *" : "")))
            SaveProfiles();
        UI::EndDisabled();
    }

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
                if (S_Autosave)
                    HoverTooltip("Autosave is enabled - you cannot undo this!");
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

    if (UI::Button("Grab Current")) {
        for (uint i = 0; i < editingProfile.plugins.Length; i++) {
            Plugin@ plugin = editingProfile.plugins[i];

            if (essential.Find(plugin.id) > -1)
                continue;

            Meta::Plugin@ installedPlugin = Meta::GetPluginFromID(plugin.id);
            if (installedPlugin is null)
                continue;

            plugin.action = installedPlugin.Enabled ? Action::Enable : Action::Disable;
        }

        dirty = true;
    }
    HoverTooltip("Sets plugins to their current state");

    UI::SameLine();
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

                const bool isEssential = essential.Find(plugin.id) > -1;

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text((isEssential ? "\\$888" : "") + plugin.name);

                UI::BeginDisabled(isEssential);

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

void Tab_Troubleshooting() {
    if (
        !S_Troubleshooting
        || !UI::BeginTabItem(Icons::Cogs + " Troubleshooting")
    )
        return;

    UI::TextWrapped(
        "Are you having issues with a certain plugin, but can't seem to figure out which one it is? Hopefully this can help you out."
        + " You will probably want to take a picture/screenshot of everything here since you will be restarting the game a few times."
    );

    UI::Separator();

    UI::TextWrapped("""
First, you'll want to make sure the issue is caused by Openplanet at all.

Starting the game without Openplanet:
1. Start holding down the \$0FFPause/Break \$Gkey on your keyboard. Don't release it yet!
2. Click \$0FFPlay \$Gin Ubisoft Connect, the Epic Games Launcher, or Steam.
3. When you see the game itself load (the window opened), release the \$0FFPause/Break \$Gkey now.

(If you don't have that key on your keyboard, you can also rename \$0FFdinput8.dll \$Gto something else in your game directory.)

You can double-check where the used Trackmania instance (game directory) is located:
Once Trackmania is started, open the task manager, right-click \$0FFTrackmania.exe \$Gand select to open its file location.
    """);

    UI::Separator();

    UI::TextWrapped("""
If the game runs normally without Openplanet, then you'll want to see if it's an issue with Openplanet itself instead of a plugin.

1. With the game running with Openplanet, open the Openplanet menu (default key is \$0FFF3\$G)
2. At the top of the screen open the \$0FFDeveloper \$Gmenu
3. Near the bottom of that menu, click \$0FFStop script engine \$G

It may take a few seconds for the engine to stop. Once the game is running normally again, try to recreate your issue.

If it persists, then it's probably with Openplanet itself. You should head to the Openplanet Discord server:
    """);

    if (UI::Button(Icons::Discord + " Discord"))
        OpenBrowserURL("https://discord.com/channels/276076890714800129/449983875586850827");

    UI::Separator();

    UI::TextWrapped("""
If your issue does not persist, then it's probably caused by a certain plugin.

Before starting this process, I highly recommend:
1. Go to the \$0FFProfiles \$Gtab at the top
2. Click \$0FFCreate Profile\$G
3. Select \$0FFGrab Current\$G
4. Name this profile something like \$0FFdefault\$G

This way you can restore the plugins you had enabled once you're done diagnosing your issue.

The buttons below will help you perform what's called a \$0FFbinary search \$Gwhich should help you quickly narrow down which plugin is causing your issue.


    """);

    UI::EndTabItem();
}
