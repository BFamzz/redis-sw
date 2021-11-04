#include <chrono>
#include <thread>
#include <iostream>
#include <csignal>
#include <mutex>

#include <sw/redis++/redis++.h>
#include <uWebSockets/App.h>

using namespace sw::redis;
std::mutex redisSubscriberMutex;

void consumeSubscriber(Subscriber &subscriber) {
    std::cout << "Consuming subscriber...\n";
    while (true)
    {
        try 
        {
            subscriber.consume();
        } 
        catch (const TimeoutError &error) 
        {
            continue;
        }
        catch (const Error &error)
        {

        }
    }    
}

void subscribeToChannel(Subscriber &subscriber, const StringView &channel) {
    std::cout << "Locking mutex...\n";
    std::scoped_lock<std::mutex> guard(redisSubscriberMutex);
    subscriber.subscribe(channel);
}

struct us_listen_socket_t *globalListenSocket = nullptr;

void signalHandler (int signal)
{
	std::cout << "The signal number is: " << signal << "\n";
	us_listen_socket_close(0, globalListenSocket);
}

int main()
{
    std::signal(SIGTERM, signalHandler);
    std::signal(SIGINT, signalHandler);

    ConnectionOptions connectionOptions;
    connectionOptions.host = "redis";
    connectionOptions.socket_timeout = std::chrono::milliseconds{ 10 };

    auto redis = Redis(connectionOptions);

    auto subscriber = redis.subscriber();
    subscriber.on_message([] (std::string channel, std::string message) {
        std::cout << "Channel is: " << channel << "...message is: " << message << '\n';
    });

    subscriber.on_pmessage([] (std::string pattern, std::string channel, std::string message) {

    });

    subscriber.on_meta([] (Subscriber::MsgType type, OptionalString channel, long long num) {

    });

    uWS::App app;
    app.get("/redisTest", [&subscriber, &redis](uWS::HttpResponse<false> *res, uWS::HttpRequest *req) {
        subscribeToChannel(subscriber, req->getQuery("channel"));
        std::cout << "Query is: " << req->getQuery("channel") << '\n';
        res->cork([res]() {
            res->writeStatus("200 OK")->writeHeader("content-type", "text/plain")->end("Redis Test is working");
        });
        redis.publish(req->getQuery("channel"), "This is a test message");
        return;
    });

    std::thread subscriberThread([&subscriber]() {
        std::cout << "Spawning another thread...\n";
        consumeSubscriber(std::ref(subscriber));
    });

    subscriberThread.detach();
    
    app.listen(8080, [](auto *listenSocket){
        if (listenSocket)
        {
            globalListenSocket = listenSocket;
        }            
    });

    app.run();

    return 0;
}