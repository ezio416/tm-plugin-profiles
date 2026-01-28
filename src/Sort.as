Meta::Plugin@[]@ QuickSort(Meta::Plugin@[]@ arr, int left = 0, int right = -1) {
    if (right < 0) {
        right = arr.Length - 1;
    }

    if (arr.Length == 0) {
        return arr;
    }

    int i = left;
    int j = right;
    Meta::Plugin@ pivot = arr[(left + right) / 2];

    while (i <= j) {
        while (arr[i].Name.ToLower() < pivot.Name.ToLower()) {
            i++;
        }

        while (arr[j].Name.ToLower() > pivot.Name.ToLower()) {
            j--;
        }

        if (i <= j) {
            Meta::Plugin@ temp = arr[i];
            @arr[i] = arr[j];
            @arr[j] = temp;
            i++;
            j--;
        }
    }

    if (left < j) {
        arr = QuickSort(arr, left, j);
    }

    if (i < right) {
        arr = QuickSort(arr, i, right);
    }

    return arr;
}

Plugin@[]@ QuickSort(Plugin@[]@ arr, int left = 0, int right = -1) {
    if (right < 0) {
        right = arr.Length - 1;
    }

    if (arr.Length == 0) {
        return arr;
    }

    int i = left;
    int j = right;
    Plugin@ pivot = arr[(left + right) / 2];

    while (i <= j) {
        while (arr[i].name.ToLower() < pivot.name.ToLower()) {
            i++;
        }

        while (arr[j].name.ToLower() > pivot.name.ToLower()) {
            j--;
        }

        if (i <= j) {
            Plugin@ temp = arr[i];
            @arr[i] = arr[j];
            @arr[j] = temp;
            i++;
            j--;
        }
    }

    if (left < j) {
        arr = QuickSort(arr, left, j);
    }

    if (i < right) {
        arr = QuickSort(arr, i, right);
    }

    return arr;
}

void SortAllPlugins() {
    trace("sorting all plugins");
    allPluginsSorted = QuickSort(allPlugins);
}
