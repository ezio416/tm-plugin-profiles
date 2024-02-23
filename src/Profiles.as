// c 2024-02-22
// m 2024-02-22

Profile@     editingProfile;
const string profileFile    = IO::FromStorageFolder("profiles.json");
Profile@[]   profiles;

class Profile {
    string name = "unnamed";

    Profile() { }
    Profile(Json::Value@ j) {
        name = j["name"];
    }

    Json::Value@ ToJson() {
        Json::Value@ j = Json::Object();

        j["name"] = name;

        return j;
    }
}

void CreateProfile() {
    Profile@ profile = Profile();

    profiles.InsertLast(profile);
    @editingProfile = profile;
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