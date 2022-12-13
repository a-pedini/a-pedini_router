let propagated_headers = ["x-trace-id", "x-ratelimit-remaining", "cache-control", "x-cache-status", "x-ratelimit-retry-after", "retry-after", "set-cookie", "x-correlation-id", "x-forwarded-for"];

fn supergraph_service(service) {
    let request_callback = |request| {
        print("Context:"+request.headers);
    };
    let response_callback = |response| {
        print("Router Response Context: "+response.context);
        for header in propagated_headers {
            if header in response.context {
                let value = response.context[header];
                if type_of(value) == "array" {
                    value = response.context[header].reduce_rev(|sum, v| sum + v + ",", "");
                    value.pop(); // remove final comma
                }

                print("Router Response Context -> Client Response header: ("+header+":"+value+")");
                response.headers[header] = value;
            }
        }
    };
    service.map_request(request_callback);
    service.map_response(response_callback);
}

fn subgraph_service(service, subgraph) {
    let request_callback = |request| {
        for header in propagated_headers {
            if header in request.headers {
                //request.subgraph.headers[header] = request.headers[header];
            }
        }
        print("Subgraph:"+request.subgraph.headers);
    };
    let response_callback = |response| {
        print("Subgraph response headers:"+response.headers);
        for header in response.headers {
            print("iterator: "+header.name+"="+header.value+" type:"+type_of(header));
        }
        for header in propagated_headers {
            if header in response.headers {
                let newValues = [response.headers[header]];
                print("Subgraph response header "+header+":"+response.headers[header]);
                let existingValues = [];
                if header in response.context {
                    if type_of(response.context[header]) == "array" {
                        existingValues = response.context[header];
                    } else {
                        existingValues = [response.context[header]];
                    }
                }
                response.context[header] = existingValues + newValues;
            }
        }
    };

    service.map_request(request_callback);
    service.map_response(response_callback);
}