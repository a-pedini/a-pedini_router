let propagated_response_headers = ["set-cookie", "x-correlation-id"];

fn supergraph_service(service) {
    let response_callback = |response| {
        print("Router Response Context: "+response.context);
        for header in propagated_response_headers {
            if header in response.context {
                response.headers[header] = response.context[header];
            }
        }
    };
    service.map_response(response_callback);
}

fn subgraph_service(service, subgraph) {
    let response_callback = |response| {
        print("Subgraph response headers:"+response.headers);
        for header in propagated_response_headers {
            if header in response.headers {
                print("Subgraph response header "+header+":"+response.headers.values(header));
                let newValues = response.headers.values(header);
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
    service.map_response(response_callback);
}