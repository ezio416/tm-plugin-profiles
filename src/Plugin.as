enum Action {
    Enable,
    Disable,
    Ignore
}

class Plugin {
    Action action = Action::Ignore;
    string id;
    string name;

    Plugin() { }
    Plugin(Json::Value@ json) {
        action = Action(int(json["action"]));
        id     = json["id"];

        Meta::Plugin@ plugin = Meta::GetPluginFromID(id);
        if (plugin !is null)
            name = plugin.Name;
    }
    Plugin(Meta::Plugin@ plugin) {
        id   = plugin.ID;
        name = plugin.Name;
    }

    Json::Value@ ToJson() {
        Json::Value@ json = Json::Object();

        json["action"] = int(action);
        json["id"]     = id;

        return json;
    }
}
