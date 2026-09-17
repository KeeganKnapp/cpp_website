#include "User.h"
#include <trantor/utils/Logger.h>
#include <string>
#include <unordered_map>
#include <mutex>


namespace api {
    namespace v1 {
        std::unordered_map<int, std::string> User::users;
        std::mutex User::userMutex;
        int User::nextId = 1;

        User::User() {
            LOG_DEBUG << "User controller initialized";
        }

        void User::getInfo(const drogon::HttpRequestPtr& req, std::function<void(const drogon::HttpResponsePtr&)>&& callback, int userId) const {
            std::lock_guard<std::mutex> lock(userMutex);
            auto it = users.find(userId);
            Json::Value result;
            if(it != users.end()) {
                result["userId"] = userId;
                result["name"] = it->second;
            }
            else {
                result["error"] = "User not found";
            }
            
            callback(drogon::HttpResponse::newHttpJsonResponse(result));
        }

        void User::newUser(const drogon::HttpRequestPtr& req, std::function<void(const drogon::HttpResponsePtr&)>&& callback, std::string&& userName) {
            std::lock_guard<std::mutex> lock(userMutex);
            LOG_DEBUG << "entering newUser function";
            int id = nextId++;
            users[id] = userName; 
            Json::Value result;
            result["userId"] = id;
            result["name"] = userName;
            result["message"] = "User created succesfully!"; 
            auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
            resp->setStatusCode(drogon::k201Created);
            callback(resp); 
        }

        void User::updateUser(const drogon::HttpRequestPtr& req, std::function<void(const drogon::HttpResponsePtr&)>&& callback, int userId) {
            std::lock_guard<std::mutex> lock(userMutex);
            auto it = users.find(userId);
            Json::Value result;
            if(it != users.end()) {
                auto json = req->getJsonObject();
                if(json && (*json).isMember("name")) {
                    it->second = (*json)["name"].asString();
                    result["userId"] = userId;
                    result["name"] = it->second;
                    result["message"] = "User updated successfully";
                } else {
                    result["error"] = "Missing 'name' field in request";
                }
            }
            else {
                result["error"] = "User not found";
            }
            callback(drogon::HttpResponse::newHttpJsonResponse(result));
        }

        void User::deleteUser(const drogon::HttpRequestPtr& req, std::function<void(const drogon::HttpResponsePtr&)>&& callback, int userId) {
            std::lock_guard<std::mutex> lock(userMutex);
            Json::Value result;
            
            if(users.erase(userId)) {
                result["message"] = "User deleted succesfully";
            } else {
                result["error"] = "User not found";
            }

            callback(drogon::HttpResponse::newHttpJsonResponse(result));
        }
    }
}
