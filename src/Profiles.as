// c 2024-02-22
// m 2024-02-22

Profile@     editingProfile;
const string profileFile = IO::FromStorageFolder("profiles.json");
Profile@[]   profiles;

class Profile {
    string    id   = GenerateUUID();
    string    name = "unnamed";
    Plugin@[] plugins;

    Profile() { }
    Profile(Json::Value@ json) {
        id   = json["id"];
        name = json["name"];

        for (uint i = 0; i < allPlugins.Length; i++)
            plugins.InsertLast(Plugin(allPlugins[i]));

        for (uint i = 0; i < json["plugins"].Length; i++)
            plugins.InsertLast(Plugin(json["plugins"][i]));
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

    Json::Value@ ToJson() {
        Json::Value@ json = Json::Object();

        json["id"]   = id;
        json["name"] = name;

        Json::Value@ pluginsArray = Json::Array();

        for (uint i = 0; i < plugins.Length; i++)
            pluginsArray.Add(plugins[i].ToJson());

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

    if (loadedProfiles.GetType() == Json::Type::Null) {
        trace("profiles.json is empty");
        return;
    }

    for (uint i = 0; i < loadedProfiles.Length; i++)
        profiles.InsertLast(Profile(loadedProfiles[i]));
}

void SaveProfiles() {
    trace("saving profiles.json...");

    Json::Value savingProfiles = Json::Array();

    for (uint i = 0; i < profiles.Length; i++)
        savingProfiles.Add(profiles[i].ToJson());

    Json::ToFile(profileFile, savingProfiles);
}