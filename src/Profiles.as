// c 2024-02-22
// m 2024-02-22

const string profileFile = IO::FromStorageFolder("profiles.json");
Json::Value@ profiles    = Json::Array();

void CreateProfile() {
    Json::Value@ profile = Json::Object();

    profile["name"] = "unnamed";

    profiles.Add(profile);
}

void LoadProfiles() {
    if (!IO::FileExists(profileFile)) {
        trace("profiles.json not found");
        return;
    }

    @profiles = Json::FromFile(profileFile);
}

void SaveProfiles() {
    Json::ToFile(profileFile, profiles);
}