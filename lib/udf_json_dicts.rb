class UdfJsonDicts
  UDFS = [
      {
          type:        :function,
          name:        :json_extract_path_keys,
          description: "Return the list of keys in a json dict as a json string",
          params:      "jsonstr varchar(10000)",
          return_type: "varchar(10000)",
          body:        %~
            import json
            if not jsonstr:
              return '[]'
            else:
              return json.dumps(sorted(json.loads(str(jsonstr)).keys()))
          ~,
          tests:       [
                           {query: "select ?('{\"a\": \"A\", \"b\": \"B\"}')", expect: '["a", "b"]', example: true},
                           {query: "select ?('{\"a\": \"A\"}')", expect: '["a"]', example: true},
                           {query: "select ?('{}')", expect: '[]', example: true}
                       ]
      }, {
          type:        :function,
          name:        :json_extract_path_key,
          description: "Return a specific key of a json dict",
          params:      "jsonstr varchar(10000), pos integer, reverse boolean",
          return_type: "varchar(10000)",
          body:        %~
            import json
            if not jsonstr:
              return ''
            else:
              keys = sorted(json.loads(str(jsonstr)).keys(), reverse=reverse)
              if len(keys) <= pos:
                return ''
              else:
                return keys[pos]
          ~,
          tests:       [
                           {query: "select ?('{\"a\": \"A\", \"b\": \"B\"}', 0)", expect: 'a', example: true},
                           {query: "select ?('{\"a\": \"A\", \"b\": \"B\"}', 0, True)", expect: 'b', example: true},
                           {query: "select ?('{\"a\": \"A\", \"b\": \"B\"}', 1)", expect: 'b', example: true},
                           {query: "select ?('{\"a\": \"A\", \"b\": \"B\"}', 1, True)", expect: 'a', example: true}
                       ]
      }
  ]
end
