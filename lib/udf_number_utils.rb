class UdfNumberUtils
  UDFS = [
      {
          type:        :function,
          name:        :format_num,
          description: "Format a number with Python's string format notation",
          params:      "num float, format varchar",
          return_type: "varchar",
          body:        %~
            if not num or not format:
              return None
            try:
              return ("{:" + format + "}").format(num)
            except ValueError:
              try:
                return ("{:" + format + "}").format(int(num))
              except ValueError:
                return None
          ~,
          tests:       [
                           {query: "select ?(2.17189, '.2f')", expect: '2.17', example: true},
                           {query: "select ?(2, '0>4d')", expect: '0002', example: true},
                           {query: "select ?(1234567.89, ',')", expect: '1,234,567.89', example: true},
                           {query: "select ?(0.1234, '.2%')", expect: '12.34%', example: true},
                           {query: "select ?(1, 'bonk')", expect: nil},
                           {query: "select ?(null, null)", expect: nil},
                       ]
      },
      {
          type:        :function,
          name:        :str_to_int,
          description: "Safe conversion of a string to an integer",
          params:      "num varchar(max)",
          return_type: "integer",
          body:        %~
            if not num:
              return None
            try:
              return int(num)
            except ValueError:
              return None
          ~,
          tests:       [
                           {query: "select ?('2.17189')", expect: nil, example: true},
                           {query: "select ?('2')", expect: 2, example: true},
                           {query: "select ?('notanum')", expect: nil, example: true},
                           {query: "select ?(null)", expect: nil},
                       ]
      }
  ]
end
