#pragma once

#include <drogon/drogon.h>

namespace api
{
    namespace v1 {
        class User : public drogon::HttpController<User> {
            public:
                METHOD_LIST_BEGIN
                METHOD_ADD(User::getInfo, "/{id}", drogon::Get);
                METHOD_ADD(User::newUser, "/{name}", drogon::Post);
                METHOD_ADD(User::updateUser, "/{id}", drogon::Put);
                METHOD_ADD(User::deleteUser, "/{id}", drogon::Delete);
                METHOD_LIST_END

                void getInfo(const drogon::HttpRequestPtr& req, std::function<void(const drogon::HttpResponsePtr&)>&& callback, int userId) const;

                void newUser(const drogon::HttpRequestPtr& req, std::function<void(const drogon::HttpResponsePtr&)> && callback, std::string&& userName);

                void updateUser(const drogon::HttpRequestPtr& req, std::function<void(const drogon::HttpResponsePtr&)>&& callback, int userId);

                void deleteUser(const drogon::HttpRequestPtr& req, std::function<void(const drogon::HttpResponsePtr&)>&& callback, int userId);

                User();

            private:
                static std::unordered_map<int, std::string> users;
                static std::mutex userMutex;
                static int nextId;
        };
    }
}
