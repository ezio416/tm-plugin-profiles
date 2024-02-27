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
}

void TogglePlugin(Meta::Plugin@ plugin) {
    if (plugin.Enabled)
        plugin.Disable();
    else
        plugin.Enable();
}