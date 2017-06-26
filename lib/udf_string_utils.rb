class UdfStringUtils
  UDFS = [
      {
          type:        :function,
          name:        :email_name,
          description: "Gets the part of the email address before the @ sign",
          params:      "email varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            if not email:
              return None
            return email.split('@')[0]
          ~,
          tests:       [
                           {query: "select ?('sam@company.com')", expect: 'sam', example: true},
                           {query: "select ?('alex@othercompany.com')", expect: 'alex', example: true},
                           {query: "select ?('bonk')", expect: 'bonk'},
                           {query: "select ?(null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :email_domain,
          description: "Gets the part of the email address after the @ sign",
          params:      "email varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            if not email:
              return None
            return email.split('@')[-1]
          ~,
          tests:       [
                           {query: "select ?('sam@company.com')", expect: 'company.com', example: true},
                           {query: "select ?('alex@othercompany.com')", expect: 'othercompany.com', example: true},
                           {query: "select ?('bonk')", expect: 'bonk'},
                           {query: "select ?(null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :url_protocol,
          description: "Gets the protocol of the URL",
          params:      "url varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            from urlparse import urlparse
            if not url:
              return None
            try:
              u = urlparse(url)
              return u.scheme
            except ValueError:
              return None
          ~,
          tests:       [
                           {query: "select ?('http://www.google.com/a')", expect: 'http', example: true},
                           {query: "select ?('https://gmail.com/b')", expect: 'https', example: true},
                           {query: "select ?('sftp://company.com/c')", expect: 'sftp', example: true},
                           {query: "select ?('bonk')", expect: ''},
                           {query: "select ?(null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :url_domain,
          description: "Gets the domain (and subdomain if present) of the URL",
          params:      "url varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            from urlparse import urlparse
            if not url:
              return None
            try:
              u = urlparse(url)
              return u.netloc
            except ValueError:
              return None
          ~,
          tests:       [
                           {query: "select ?('http://www.google.com/a')", expect: 'www.google.com', example: true},
                           {query: "select ?('https://gmail.com/b')", expect: 'gmail.com', example: true},
                           {query: "select ?('bonk')", expect: ''},
                           {query: "select ?(null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :url_path,
          description: "Gets the domain (and subdomain if present) of the URL",
          params:      "url varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            from urlparse import urlparse
            if not url:
              return None
            try:
              u = urlparse(url)
              return u.path
            except ValueError:
              return None
          ~,
          tests:       [
                           {query: "select ?('http://www.google.com/search/images?query=bob')", expect: '/search/images', example: true},
                           {query: "select ?('https://gmail.com/mail.php?user=bob')", expect: '/mail.php', example: true},
                           {query: "select ?('bonk')", expect: 'bonk'},
                           {query: "select ?(null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :url_param,
          description: "Extract a parameter from a URL",
          params:      "url varchar(max), param varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            import urlparse
            if not url:
              return None
            try:
              u = urlparse.urlparse(url)
              return urlparse.parse_qs(u.query)[param][0]
            except KeyError:
              return None
          ~,
          tests:       [
                           {query: "select ?('http://www.google.com/search/images?query=bob', 'query')", expect: 'bob', example: true},
                           {query: "select ?('https://gmail.com/mail.php?user=bob&account=work', 'user')", expect: 'bob', example: true},
                           {query: "select ?('bonk', 'bonk')", expect: nil},
                           {query: "select ?(null, null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :split_count,
          description: "Split a string on another string and count the members",
          params:      "str varchar(max), delim varchar(max)",
          return_type: "int",
          body:        %~
            if not str or not delim:
              return None
            return len(str.split(delim))
          ~,
          tests:       [
                           {query: "select ?('foo,bar,baz', ',')", expect: 3, example: true},
                           {query: "select ?('foo', 'bar')", expect: 1, example: true},
                           {query: "select ?('foo,bar', 'o,b')", expect: 2},
                       ]
      },
      {
          type:        :function,
          name:        :titlecase,
          description: "Format a string as titlecase",
          params:      "str varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            if not str:
              return None
            return str.title()
          ~,
          tests:       [
                           {query: "select ?('this is a title')", expect: 'This Is A Title', example: true},
                           {query: "select ?('Already A Title')", expect: 'Already A Title', example: true},
                           {query: "select ?('')", expect: nil},
                           {query: "select ?(null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :str_multiply,
          description: "Repeat a string N times",
          params:      "str varchar(max), times integer",
          return_type: "varchar(max)",
          body:        %~
            if not str:
              return None
            return str * times
          ~,
          tests:       [
                           {query: "select ?('*', 10)", expect: '**********', example: true},
                           {query: "select ?('abc ', 3)", expect: 'abc abc abc ', example: true},
                           {query: "select ?('abc ', -3)", expect: ''},
                           {query: "select ?('', 0)", expect: nil},
                           {query: "select ?(null, 10)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :str_index,
          description: "Find the index of the first occurrence of a substring, or -1 if not found",
          params:      "full_str varchar(max), find_substr varchar(max)",
          return_type: "integer",
          body:        %~
            if not full_str or not find_substr:
              return None
            return full_str.find(find_substr)
          ~,
          tests:       [
                           {query: "select ?('Apples Oranges Pears', 'Oranges')", expect: 7, example: true},
                           {query: "select ?('Apples Oranges Pears', 'Bananas')", expect: -1, example: true},
                           {query: "select ?('abc', 'd')", expect: -1},
                           {query: "select ?('', '')", expect: nil},
                           {query: "select ?(null, null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :str_rindex,
          description: "Find the index of the last occurrence of a substring, or -1 if not found",
          params:      "full_str varchar(max), find_substr varchar(max)",
          return_type: "integer",
          body:        %~
            if not full_str or not find_substr:
              return None
            return full_str.rfind(find_substr)
          ~,
          tests:       [
                           {query: "select ?('A B C A B C', 'C')", expect: 10, example: true},
                           {query: "select ?('Apples Oranges Pears Oranges', 'Oranges')", expect: 21, example: true},
                           {query: "select ?('Apples Oranges', 'Bananas')", expect: -1, example: true},
                           {query: "select ?('abc', 'd')", expect: -1},
                           {query: "select ?('', '')", expect: nil},
                           {query: "select ?(null, null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :str_count,
          description: "Counts the number of occurrences of a substring within a string",
          params:      "full_str varchar(max), find_substr varchar(max)",
          return_type: "integer",
          body:        %~
            if not full_str or not find_substr:
              return None
            return full_str.count(find_substr)
          ~,
          tests:       [
                           {query: "select ?('abbbc', 'b')", expect: 3, example: true},
                           {query: "select ?('Apples Bananas', 'an')", expect: 2, example: true},
                           {query: "select ?('aaa', 'A')", expect: 0, example: true},
                           {query: "select ?('abc', 'd')", expect: 0},
                           {query: "select ?('', '')", expect: nil},
                           {query: "select ?(null, null)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :str_join_range,
          description: "Joins a numeric range with a given separator",
          params:      "first integer, last integer, step integer, delimiter varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            return delimiter.join(str(x) for x in range(first, last, step))
          ~,
          tests:       [
                           {query: "select ?(1, 3, 1, ',')", expect: "1,2" , example: true},
                           {query: "select ?(1, 5, 2, '|')", expect: "1|3", example: true},
                       ]
      }, {
          type:        :function,
          name:        :str_room_adults,
          description: "Returns total number of adults for a given room configuration",
          params:      "room varchar(max)",
          return_type: "integer",
          body:        %~
            adults = 0
            for r in room.split('|'):
              ch = r.split(':')
              adults += int(ch[0])

            return adults
          ~,
          tests:       [
                           {query: "select ?('1|2')", expect: 3 , example: true},
                           {query: "select ?('2')", expect: 2, example: true},
                           {query: "select ?('2:0,0')", expect: 2, example: true},
                           {query: "select ?('2:0|1:2,6')", expect: 3, example: true},
                       ]
      }, {
          type:        :function,
          name:        :str_room_children,
          description: "Returns total number of children for a given room configuration",
          params:      "room varchar(max)",
          return_type: "integer",
          body:        %~
            children = 0
            for r in room.split('|'):
              ch = r.split(':')
              if len(ch) > 1:
                children += len(ch[-1].split(','))

            return children
          ~,
          tests:       [
                           {query: "select ?('1|2')", expect: 0 , example: true},
                           {query: "select ?('2')", expect: 0, example: true},
                           {query: "select ?('2:0,0')", expect: 2, example: true},
                           {query: "select ?('2:0|1:2,6')", expect: 3, example: true},
                           {query: "select ?('2|1:12')", expect: 1, example: true},
                       ]
      }
    ]
end
