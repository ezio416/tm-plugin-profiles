// c 2024-02-22
// m 2024-02-22

void Tab_PluginList() {
    if (!UI::BeginTabItem(Icons::List + " Plugins"))
        return;

    float maxNameWidth = 0.0f;
    float maxAuthorWidth = 0.0f;
    for (uint i = 0; i < plugins.Length; i++) {
        maxNameWidth = Math::Max(maxNameWidth, Draw::MeasureString(plugins[i].Name).x);
        maxAuthorWidth = Math::Max(maxAuthorWidth, Draw::MeasureString(plugins[i].Author).x);
    }

    if (UI::BeginTable("##table", 4, UI::TableFlags::ScrollY)) {
        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("siteid", UI::TableColumnFlags::WidthFixed, 50.0f);
        // UI::TableSetupColumn("id");
        UI::TableSetupColumn("enabled", UI::TableColumnFlags::WidthFixed, 70.0f);
        UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed, maxNameWidth);
        UI::TableSetupColumn("author", UI::TableColumnFlags::WidthFixed, maxAuthorWidth);
        UI::TableHeadersRow();

        UI::ListClipper clipper(plugins.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Meta::Plugin@ plugin = plugins[i];

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

void Tab_PresetList() {
    if (!UI::BeginTabItem(Icons::ThLarge + " Presets"))
        return;

    ;

    UI::EndTabItem();
}