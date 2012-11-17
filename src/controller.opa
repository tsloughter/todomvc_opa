module Controller {

  // URL dispatcher of your application; add URL handling as needed
  dispatcher = {
    parser {
    case (.*) : View.default_page()
    }
  }

}

resources = @static_resource_directory("resources")

Server.start(Server.http, [
  { register:
    [ { doctype: { html5 } },
      { js: [ "/resources/js/app.js", "/resources/js/base.js" ] },
      { css: [ "/resources/css/app.css", "/resources/css/base.css" ] }
    ]
  },
  { ~resources },
  { custom: Controller.dispatcher }
])
