// c 2024-02-22
// m 2024-02-22

enum Action {
    Enable,
    Disable,
    Ignore
}

class Plugin {
    Action action = Action::Ignore;
    string id;

    Plugin() { }
    Plugin(Json::Value@ json) {
        action = Action(int(json["action"]));
        id     = json["id"];
    }
    Plugin(Meta::Plugin@ plugin) {
        id = plugin.ID;
    }

    Json::Value@ ToJson() {
        Json::Value@ json = Json::Object();

        json["action"] = int(action);
        json["id"]     = id;

        return json;
    }
}