// c 2024-02-22
// m 2024-02-26

Profile@     editingProfile;
const string profileFile = IO::FromStorageFolder("profiles.json");
Profile@[]   profiles;

class Profile {
    string      id        = GenerateUUID();
    string      name      = "unnamed";
    dictionary@ pluginIds = dictionary();
    Plugin@[]   plugins;

    Profile() { }
    Profile(Json::Value@ json) {
        id   = json["id"];
        name = json["name"];

        for (uint i = 0; i < allPlugins.Length; i++) {
            Plugin@ plugin = Plugin(allPlugins[i]);

            pluginIds.Set(plugin.id, @plugin);
            plugins.InsertLast(plugin);
        }

        for (uint i = 0; i < json["plugins"].Length; i++) {
            Plugin@ plugin = Plugin(json["plugins"][i]);

            if (pluginIds.Exists(plugin.id))
                cast<Plugin@>(pluginIds[plugin.id]).action = plugin.action;
        }
    }

    void Activate() {
        trace("activating profile (" + name + ")");

        for (uint i = 0; i < plugins.Length; i++) {
            Plugin@ plugin = plugins[i];

            Meta::Plugin@ installedPlugin = Meta::GetPluginFromID(plugin.id);
            if (installedPlugin is null)
                continue;

            if (plugin.action == Action::Enable && !installedPlugin.Enabled)
                installedPlugin.Enable();
            else if (plugin.action == Action::Disable && installedPlugin.Enabled)
                installedPlugin.Disable();
        }
    }

    void RefreshPlugins() {
        dictionary@ installedPlugins = dictionary();

        for (uint i = 0; i < allPlugins.Length; i++) {
            Meta::Plugin@ installedPlugin = allPlugins[i];

            if (pluginIds.Exists(installedPlugin.ID)) {
                Plugin@ checked = cast<Plugin@>(pluginIds[installedPlugin.ID]);
                installedPlugins.Set(checked.id, 0);

                continue;
            }

            Plugin@ plugin = Plugin(installedPlugin);
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
        trace("sorting plugins in profile (" + name + ")...");
        plugins = QuickSort(plugins);
    }

    Json::Value@ ToJson() {
        Json::Value@ json = Json::Object();

        json["id"]   = id;
        json["name"] = name;

        Json::Value@ pluginsArray = Json::Array();

        for (uint i = 0; i < plugins.Length; i++) {
            Plugin@ plugin = plugins[i];

            if (plugin.action != Action::Ignore)
                pluginsArray.Add(plugin.ToJson());
        }

        json["plugins"] = pluginsArray;

        return json;
    }
}

void CreateProfile() {
    Profile@ profile = Profile();

    profiles.InsertLast(profile);
    @editingProfile = profile;

    editTabOpen = true;
    switchToEditTab = true;
}

void LoadProfiles() {
    trace("loading profiles.json...");

    if (!IO::FileExists(profileFile)) {
        trace("profiles.json not found");
        return;
    }

    profiles.RemoveRange(0, profiles.Length);

    Json::Value@ loadedProfiles = Json::FromFile(profileFile);

    if (loadedProfiles.GetType() != Json::Type::Array) {
        trace("profiles.json is empty or invalid");
        return;
    }

    for (uint i = 0; i < loadedProfiles.Length; i++) {
        Profile@ profile = Profile(loadedProfiles[i]);
        profile.RefreshPlugins();
        profiles.InsertLast(profile);
    }
}

void SaveProfiles() {
    trace("saving profiles.json...");

    Json::Value savingProfiles = Json::Array();

    for (uint i = 0; i < profiles.Length; i++)
        savingProfiles.Add(profiles[i].ToJson());

    Json::ToFile(profileFile, savingProfiles);
}