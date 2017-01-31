class UdfIpUtils
  UDFS = [
      {
          type:        :function,
          name:        :ip_to_int,
          description: "Transform string readable IP address to its int value",
          params:      "ip_address varchar(max)",
          return_type: "bigint",
          body:        %~

            import struct
            import socket
            try:
                res = struct.unpack("!I", socket.inet_aton(ip_address))[0]
            except:
                res = 0
            return res

          ~,
          tests: [
              {query: "select ?('192.168.1.1')", expect: '3232235777', example: true},
              {query: "select ?('0.0.0.0')", expect: '0', example: true},
              {query: "select ?('a')", expect: '0'},
              {query: "select ?('')", expect: '0'},
          ]
      },
      {
          type:        :function,
          name:        :int_to_ip,
          description: "Transform integer IP address to its string readable format",
          params:      "ip_int bigint",
          return_type: "varchar(max)",
          body:        %~

            import struct
            import socket
            try:
                res =  socket.inet_ntoa(struct.pack("!I", ip_int))
            except:
                res = 0
            return res

          ~,
          tests: [
              {query: "select ?(3232235777)", expect: '192.168.1.1', example: true},
              {query: "select ?(0)", expect: '0.0.0.0', example: true},
          ]
      }
  ]
end
