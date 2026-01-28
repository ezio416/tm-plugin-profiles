[Setting category="General" name="Show Window"]
bool S_Show = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

[Setting category="General" name="Autosave" description="Saves profiles on the \"Profiles\" tab whenever it can"]
bool S_Autosave = false;

[Setting category="General" name="Show plugin version numbers"]
bool S_Versions = false;
bool _S_VersionsPre = S_Versions;

[Setting category="General" name="Allow disabling essential plugins"
description="Could cause problems with other plugins! Essentials are re-enabled if this is not set or when Plugin Profiles is disabled or unloaded."]
bool S_DisableEssential = false;
bool _S_DisableEssentialPre = S_DisableEssential;

// [Setting category="General" name="Allow uninstalling unsigned plugins"]
// bool S_AllowUninstallUnsigned = false;
