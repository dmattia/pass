import Vapor

let drop = Droplet()

do {
    drop.middleware.insert(try CORSMiddleware(configuration: drop.config), at: 0)
} catch {
    fatalError("Error creating CORSMiddleware, please check that you've setup cors.json correctly.")
}
drop.post("register") { request in
    print(request.json)
    guard let username = request.json?["username"]?.string else {
        throw Abort.badRequest
    }
    guard let email = request.json?["email"]?.string else {
        throw Abort.badRequest
    }
    guard let password = request.json?["password"]?.string else {
        throw Abort.badRequest
    }
    return try JSON(node: [
        "message": "Registered \(username) with email \(email) and password \(password)"
    ])
}

drop.resource("posts", PostController())

drop.run()
