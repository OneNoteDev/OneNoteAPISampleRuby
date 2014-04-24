module RestClient
  module Payload

    Multipart.class_eval do
      EOL = "\r\n"

      def create_regular_field(s, k, v)
        s.write("Content-Disposition: form-data; name=\"#{k}\"")
        s.write(EOL)
        s.write("Content-Type: text/html")
        s.write(EOL)
        s.write(EOL)
        s.write(v)
      end

    end
  end
end
