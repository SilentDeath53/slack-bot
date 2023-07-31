import ballerina/http;
import ballerina/log;
import ballerina/net.uri;

const string SLACK_TOKEN = "<YOUR_SLACK_API_TOKEN>";

listener http:Listener slackListener = new(9090);

@http:ServiceConfig { basePath: "/slack" }
service slackBot on slackListener {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/events",
        consumes: ["application/json"]
    }
    resource function onSlackEvent(http:Request request, http:Response response) {
        if (request.getHeader("Authorization") != SLACK_TOKEN) {
            response.statusCode = 401;
            return;
        }

        var payloadJson = request.getJsonPayload();

        if (payloadJson.type == "message") {
            var message = payloadJson.message;

            if (message.startsWith("hello")) {
                respondToMessage(payloadJson.channel, "Hello, I'm your Slack bot!");
            } else if (message.startsWith("ping")) {
                respondToMessage(payloadJson.channel, "Pong!");
            }
        }

        response.statusCode = 200;
    }
}

function respondToMessage(string channel, string message) {
    var payload = { "channel": channel, "text": message };

    var slackUrl = "https://slack.com/api/chat.postMessage";
    var client = new http:Client();
    var response = client->post(slackUrl, payload, { "Authorization": SLACK_TOKEN });

    if (response.statusCode != 200) {
        log:printError("Failed to send Slack message: " + response);
    }
}
