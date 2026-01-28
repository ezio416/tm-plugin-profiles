// Profile@     activeProfile;
Profile@     editingProfile;
const string profileFile = IO::FromStorageFolder("profiles.json");
Profile@[]   profiles;

class Profile {
    string     id        = GenerateUUID();
    string     name      = "unnamed";
    dictionary pluginIds = dictionary();
    Plugin@[]  plugins;

    Profile() { }
    Profile(Json::Value@ json) {
        id   = json["id"];
        name = json["name"];

        for (uint i = 0; i < allPlugins.Length; i++) {
            auto plugin = Plugin(allPlugins[i]);

            pluginIds.Set(plugin.id, @plugin);
            plugins.InsertLast(plugin);
        }

        for (uint i = 0; i < json["plugins"].Length; i++) {
            auto plugin = Plugin(json["plugins"][i]);

            if (pluginIds.Exists(plugin.id)) {
                cast<Plugin>(pluginIds[plugin.id]).action = plugin.action;
            }
        }
    }

    void Activate() {
        trace("activating profile (" + name + ")");

        for (uint i = 0; i < plugins.Length; i++) {
            Plugin@ plugin = plugins[i];

            Meta::Plugin@ installedPlugin = Meta::GetPluginFromID(plugin.id);
            if (installedPlugin is null) {
                continue;
            }

            if (true
                and plugin.action == Action::Enable
                and !installedPlugin.Enabled
            ) {
                installedPlugin.Enable();

            } else if (true
                and plugin.action == Action::Disable
                and installedPlugin.Enabled
            ) {
                installedPlugin.Disable();
            }
        }

        // @activeProfile = this;

        Meta::SaveSettings();
    }

    void RefreshPlugins() {
        auto installedPlugins = dictionary();

        for (uint i = 0; i < allPlugins.Length; i++) {
            Meta::Plugin@ installedPlugin = allPlugins[i];

            if (pluginIds.Exists(installedPlugin.ID)) {
                auto checked = cast<Plugin>(pluginIds[installedPlugin.ID]);
                installedPlugins.Set(checked.id, 0);

                continue;
            }

            auto plugin = Plugin(installedPlugin);
            pluginIds.Set(plugin.id, @plugin);
            plugins.InsertLast(plugin);
            installedPlugins.Set(plugin.id, 0);
        }

        for (int i = plugins.Length - 1; i >= 0; i--) {
            if (!installedPlugins.Exists(plugins[i].id)) {
                pluginIds.Delete(plugins[i].id);
                plugins.RemoveAt(i);
            }
        }

        SortPlugins();
    }

    void SortPlugins() {
        trace("sorting plugins in profile (" + name + ")");
        plugins = QuickSort(plugins);
    }

    Json::Value@ ToJson() {
        Json::Value@ json = Json::Object();

        json["id"]   = id;
        json["name"] = name;

        Json::Value@ pluginsArray = Json::Array();

        for (uint i = 0; i < plugins.Length; i++) {
            Plugin@ plugin = plugins[i];

            if (plugin.action != Action::Ignore) {
                pluginsArray.Add(plugin.ToJson());
            }
        }

        json["plugins"] = pluginsArray;

        return json;
    }
}

void CreateProfile() {
    Profile@ profile = Profile();

    profile.RefreshPlugins();

    profiles.InsertLast(profile);
    @editingProfile = profile;

    editTabOpen = true;
    switchToEditTab = true;

    dirty = true;
}

void LoadProfiles() {
    trace("loading profiles.json");

    if (!IO::FileExists(profileFile)) {
        trace("profiles.json not found");
        return;
    }

    profiles.RemoveRange(0, profiles.Length);
    @editingProfile = null;
    editTabOpen = false;

    Json::Value@ loadedProfiles = Json::FromFile(profileFile);

    if (loadedProfiles.GetType() != Json::Type::Array) {
        warn("profiles.json is empty or invalid");
        return;
    }

    for (uint i = 0; i < loadedProfiles.Length; i++) {
        auto profile = Profile(loadedProfiles[i]);
        profile.RefreshPlugins();
        profiles.InsertLast(profile);
    }

    dirty = false;
}

void SaveProfiles() {
    trace("saving profiles.json");

    Json::Value@ savingProfiles = Json::Array();

    for (uint i = 0; i < profiles.Length; i++) {
        savingProfiles.Add(profiles[i].ToJson());
    }

    Json::ToFile(profileFile, savingProfiles);

    dirty = false;
}
