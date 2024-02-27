// c 2024-02-22
// m 2024-02-26

const string[] uuidChars = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" };
const int[]    uuidDash  = { 2, 3, 4, 5 };

string GenerateUUID() {
    string uuid;

    for (uint i = 0; i < 8; i++) {
        if (uuidDash.Find(i) > -1)
            uuid += "-";

        for (uint j = 0; j < 4; j++)
            uuid += uuidChars[Math::Rand(0, 16)];
    }

    return uuid;
}

Meta::Plugin@[]@ QuickSort(Meta::Plugin@[]@ arr, int left = 0, int right = -1) {
    if (right < 0)
        right = arr.Length - 1;

    if (arr.Length == 0)
        return arr;

    int i = left;
    int j = right;
    Meta::Plugin@ pivot = arr[(left + right) / 2];

    while (i <= j) {
        while (arr[i].Name.ToLower() < pivot.Name.ToLower())
            i++;

        while (arr[j].Name.ToLower() > pivot.Name.ToLower())
            j--;

        if (i <= j) {
            Meta::Plugin@ temp = arr[i];
            @arr[i] = arr[j];
            @arr[j] = temp;
            i++;
            j--;
        }
    }

    if (left < j)
        arr = QuickSort(arr, left, j);

    if (i < right)
        arr = QuickSort(arr, i, right);

    return arr;
}

void RefreshPlugins() {
    @allPlugins = Meta::AllPlugins();
}

void SortPlugins() {
    trace("sorting plugins...");
    allPluginsSorted = QuickSort(allPlugins);
}

void TogglePlugin(Meta::Plugin@ plugin) {
    if (plugin.Enabled)
        plugin.Disable();
    else
        plugin.Enable();
}