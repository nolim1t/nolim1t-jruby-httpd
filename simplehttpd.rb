require 'java'
require 'webrick'
require 'log4j-1.2.15.jar'


class Simple < WEBrick::HTTPServlet::AbstractServlet

  def do_GET(request, response)
    @logger.info "Hello world page accessed"
    status, content_type, body = do_stuff_with(request)

    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end

  def do_stuff_with(request)
    return 200, "text/plain", "Hello World"
  end

end


if $0 == __FILE__ then
    properties = java.util::Properties.new
    properties.load(java.io.FileInputStream.new("web.properties"))
    server_name=properties.getProperty("com.bt.httpd.servername")
    bind_address=properties.getProperty("com.bt.httpd.bindaddress")
    bind_port=properties.getProperty("com.bt.httpd.bindport")
    log4j_path=properties.getProperty("com.bt.httpd.log4jfile")
    log4j_rootlogger=properties.getProperty("com.bt.httpd.defaultlogger")

    # for XML files
    import org.apache.log4j.xml.DOMConfigurator
    import org.apache.log4j.Logger

    # set up logger
    logger = Log4j.getLogger(log4j_rootlogger)
    # configure logger
    DOMConfigurator.configure(log4j_path)

    server = WEBrick::HTTPServer.new(:ServerName => server_name,
    :BindAddress => bind_address,
    :Port => bind_port.to_i,
    :Logger => logger,
    :ServerSoftware => "SimpleHTTPD")

    # Define servlets
    server.mount "/", Simple
    # Capture INT signal
    trap "INT" do server.shutdown end
    # start the server
    server.start
end

