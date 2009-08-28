require 'java'
require 'webrick'
require 'log4j-1.2.15.jar'


class Simple < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
        # Sample parameter test
        param1 = request.query["response"]
        if param1.to_s.length > 0 then
            msg = "Parameter passed: #{param1}"
            @logger.info "Parameter passed by #{request.addr} (#{param1})"
        else
            msg = "Missing parameter: response"
        end
        # Pass to HTTP Client
        response.status = "200"
        response['Content-Type'] = "text/plain"
        response.body = msg
    end
    # Accept POST the same way as GET
    alias :do_POST :do_GET

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
    logger = Logger.getLogger(log4j_rootlogger)
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

