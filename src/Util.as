// c 2024-02-22
// m 2024-02-26

const string[] uuidChars  = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" };
const int[]    uuidDashes = { 2, 3, 4, 5 };

string GenerateUUID() {
    string uuid;

    for (int i = 0; i < 8; i++) {
        if (uuidDashes.Find(i) > -1)
            uuid += "-";

        for (uint j = 0; j < 4; j++)
            uuid += uuidChars[Math::Rand(0, 16)];
    }

    return uuid;
}

void RefreshAllPlugins() {
    @allPlugins = Meta::AllPlugins();

    maxNameWidth   = 0.0f;
    maxAuthorWidth = 0.0f;

    for (uint i = 0; i < allPlugins.Length; i++) {
        maxNameWidth = Math::Max(maxNameWidth, Draw::MeasureString(allPlugins[i].Name).x);
        maxAuthorWidth = Math::Max(maxAuthorWidth, Draw::MeasureString(allPlugins[i].Author).x);
    }
}

void TogglePlugin(Meta::Plugin@ plugin) {
    if (plugin.Enabled)
        plugin.Disable();
    else
        plugin.Enable();
}
