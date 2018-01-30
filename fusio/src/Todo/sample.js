
var connection = connector.get("Default-Connection");

var count = connection.fetchColumn("SELECT COUNT(*) FROM app_todo");
var entries = connection.fetchAll("SELECT * FROM app_todo WHERE status = 1 ORDER BY insertDate DESC LIMIT 16");

response.setStatusCode(200);
response.setBody({
  totalResults: count,
  entry: entries
});
