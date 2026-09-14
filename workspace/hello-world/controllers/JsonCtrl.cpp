/// The source file
#include "JsonCtrl.h"

void JsonCtrl::asyncHandleHttpRequest(const HttpRequestPtr &req,
                                      std::function<void(const HttpResponsePtr &)> &&callback)
{
    Json::Value ret;
    ret["message"] = "Hello, World!";
    HttpResponsePtr resp = HttpResponse::newHttpJsonResponse(ret);
    callback(resp);
}
