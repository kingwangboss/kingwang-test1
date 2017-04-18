import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

var routes = Routes()

routes.add(method: .get, uri: "/", handler: {
    request,response in
    response.setBody(string: "hello!")
    response.completed()
})

func returnJSONMessage(message:String,response:HTTPResponse) {
    do{
        try response.setBody(json: ["message" : message])
            response.setHeader(.contentType, value: "application/json")
            response.completed()
    }catch{
        response.setBody(string: "Error handling request:\(error)")
        response.completed()
    }
}

routes.add(method: .get, uri: "/hello", handler: {
    request,response in
    returnJSONMessage(message: "hello,Json", response: response)
})

routes.add(method: .get, uri: "/hello/ok", handler: {
    request,response in
    returnJSONMessage(message: "hello,ok", response: response)
})

routes.add(method: .get, uri: "/beers/{num_beers}", handler: {
    request,response in
    guard let numBeersString = request.urlVariables["num_beers"],
        let numBeersInt = Int(numBeersString) else {
            response.status = .badRequest
            return
    }
    returnJSONMessage(message: "\(numBeersInt - 1)", response: response)
})

routes.add(method: .post, uri: "post", handler: {
    request,response in
    guard let name = request.param(name: "name") else {
        response.completed()
        response.status = .badRequest
        return
    }
    returnJSONMessage(message: "you name is \(name)", response: response)
})

server.addRoutes(routes)

do{
    try server.start()
} catch PerfectError.networkError(let err, let msg){
    print("network Error thrown:\(err) \(msg)")
}
