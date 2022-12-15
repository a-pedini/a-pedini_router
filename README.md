# a-pedini_router

Trying to configure a router to propagate multiple-value response headers from subgraphs to client.

I'm executing the router with:
```
APOLLO_KEY="{apollokey}" APOLLO_GRAPH_REF="{apolloGraphRef}" ./router --config router.yaml
```

One of the subgraph is setting 3 cookies (as logged by the rhai response handler): 
```
Subgraph response headers:x-powered-by: Express
set-cookie: test_cookie_method_1=1; Path=/
set-cookie: test_cookie_method_2=2; Path=/
set-cookie: test_cookie_method_3=3; Path=/
x-correlation-id: test_alex_propagation_and_cookie2
access-control-allow-origin: *
content-type: application/json; charset=utf-8
content-length: 306
etag: W/"132-xilK2xBK9cdncPb1kUdPKzRpR4E"
date: Tue, 13 Dec 2022 00:05:40 GMT
```

but when I iterate over the headers in the handler script I get:
```
apollo_router::plugins::rhai: iterator:x-powered-by: Express
apollo_router::plugins::rhai: iterator:set-cookie: test_cookie_method_1=1; Path=/
apollo_router::plugins::rhai: iterator:None: test_cookie_method_2=2; Path=/
apollo_router::plugins::rhai: iterator:None: test_cookie_method_3=3; Path=/
apollo_router::plugins::rhai: iterator:x-correlation-id: test_alex_propagation_and_cookie2
apollo_router::plugins::rhai: iterator:access-control-allow-origin: *
apollo_router::plugins::rhai: iterator:content-type: application/json; charset=utf-8
apollo_router::plugins::rhai: iterator:content-length: 306
apollo_router::plugins::rhai: iterator:etag: W/"132-xilK2xBK9cdncPb1kUdPKzRpR4E"
apollo_router::plugins::rhai: iterator:date: Tue, 13 Dec 2022 00:05:40 GMT
apollo_router::plugins::rhai: iterator:connection: keep-alive
apollo_router::plugins::rhai: iterator:keep-alive: timeout=5
```
the values of the cookie is there, test_cookie_method_2=2 but it lost the key, as the iterator key now says None and 
the result is that when in the script I get the header by value set-cookie I only get the first one and not all three
