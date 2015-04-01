class UdfJsonArrays
  UDFS = [
      {
          type:        :function,
          name:        :json_array_first,
          description: "Returns the first element of a JSON array as a string",
          params:      "j varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            import json
            if not j:
              return None
            try:
              arr = json.loads(j)
            except ValueError:
              return None
            if len(arr) == 0:
              return None
            return str(arr[0])
          ~,
          tests:       [
                           {query: "select ?('[\"a\", \"b\"]')", expect: "a", example: true},
                           {query: "select ?('[1, 2, 3]')", expect: "1", example: true},
                           {query: "select ?('[4]')", expect: "4"},
                           {query: "select ?('[]')", expect: nil},
                           {query: "select ?('')", expect: nil},
                           {query: "select ?(null)", expect: nil},
                           {query: "select ?('abc')", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :json_array_last,
          description: "Returns the last element of a JSON array as a string",
          params:      "j varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            import json
            if not j:
              return None
            try:
              arr = json.loads(j)
            except ValueError:
              return None
            if len(arr) == 0:
              return None
            return str(arr[-1])
          ~,
          tests:       [
                           {query: "select ?('[\"a\", \"b\"]')", expect: "b", example: true},
                           {query: "select ?('[1, 2, 3]')", expect: "3", example: true},
                           {query: "select ?('[4]')", expect: "4"},
                           {query: "select ?('[]')", expect: nil},
                           {query: "select ?('')", expect: nil},
                           {query: "select ?(null)", expect: nil},
                           {query: "select ?('abc')", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :json_array_nth,
          description: "Returns the Nth 0-indexed element of a JSON array as a string",
          params:      "j varchar(max), i integer",
          return_type: "varchar(max)",
          body:        %~
            import json
            if not j or (not i and i != 0) or i < 0:
              return None
            try:
              arr = json.loads(j)
            except ValueError:
              return None
            if len(arr) <= i:
              return None
            return str(arr[i])
          ~,
          tests:       [
                           {query: "select ?('[\"a\", \"b\"]', 0)", expect: "a", example: true},
                           {query: "select ?('[\"a\", \"b\"]', 1)", expect: "b"},
                           {query: "select ?('[\"a\", \"b\"]', -1)", expect: nil},
                           {query: "select ?('[1,2,3]', 3)", expect: nil},
                           {query: "select ?('[1, 2, 3]', 1)", expect: "2", example: true},
                           {query: "select ?('[4]', null)", expect: nil},
                           {query: "select ?('[]', 4)", expect: nil},
                           {query: "select ?('', 3)", expect: nil},
                           {query: "select ?(null, null)", expect: nil},
                           {query: "select ?('abc', 1)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :json_array_sort,
          description: "Returns sorts a JSON array and returns it as a string, second param sets direction",
          params:      "j varchar(max), ascending boolean",
          return_type: "varchar(max)",
          body:        %~
            import json
            if not j:
              return None
            try:
              arr = json.loads(j)
            except ValueError:
              return None
            if not ascending:
              arr = sorted(arr, reverse=True)
            else:
              arr = sorted(arr)
            return json.dumps(arr)
          ~,
          tests:       [
                           {query: "select ?('[\"a\",\"c\",\"b\"]', true)", expect: '["a", "b", "c"]', example: true},
                           {query: "select ?('[\"a\",\"c\",\"b\"]', false)", expect: '["c", "b", "a"]'},
                           {query: "select ?('[1, 3, 2]', true)", expect: '[1, 2, 3]', example: true},
                           {query: "select ?('[4]', null)", expect: "[4]"},
                           {query: "select ?('[]', true)", expect: "[]"},
                           {query: "select ?('', true)", expect: nil},
                           {query: "select ?(null, null)", expect: nil},
                           {query: "select ?('abc', 1)", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :json_array_reverse,
          description: "Reverses a JSON array and returns it as a string",
          params:      "j varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            import json
            if not j:
              return None
            try:
              arr = json.loads(j)
            except ValueError:
              return None
            return json.dumps(arr[::-1])
          ~,
          tests:       [
                           {query: "select ?('[\"a\",\"c\",\"b\"]')", expect: '["b", "c", "a"]', example: true},
                           {query: "select ?('[1, 3, 2]')", expect: '[2, 3, 1]', example: true},
                           {query: "select ?('[4]')", expect: "[4]"},
                           {query: "select ?('[]')", expect: "[]"},
                           {query: "select ?('')", expect: nil},
                           {query: "select ?(null)", expect: nil},
                           {query: "select ?('abc')", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :json_array_pop,
          description: "Removes the last element from a JSON array and returns the remaining array as a string",
          params:      "j varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            import json
            if not j:
              return None
            try:
              arr = json.loads(j)
            except ValueError:
              return None
            if len(arr) > 0:
              arr.pop()
            return json.dumps(arr)
          ~,
          tests:       [
                           {query: "select ?('[\"a\",\"c\",\"b\"]')", expect: '["a", "c"]', example: true},
                           {query: "select ?('[1, 3, 2]')", expect: '[1, 3]', example: true},
                           {query: "select ?('[4]')", expect: "[]"},
                           {query: "select ?('[]')", expect: "[]"},
                           {query: "select ?('')", expect: nil},
                           {query: "select ?(null)", expect: nil},
                           {query: "select ?('abc')", expect: nil},
                       ]
      }, {
          type:        :function,
          name:        :json_array_push,
          description: "Adds a new element to a JSON array and returns the new array as a string",
          params:      "j varchar(max), value varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            import json
            if not j:
              arr = []
            else:
              try:
                arr = json.loads(j)
              except ValueError:
                arr = []
            arr.append(value)
            return json.dumps(arr)
          ~,
          tests:       [
                           {query: "select ?('[\"a\",\"c\",\"b\"]', 'd')", expect: '["a", "c", "b", "d"]', example: true},
                           {query: "select ?('[1, 3, 2]', '4')", expect: '[1, 3, 2, "4"]', example: true},
                           {query: "select ?('[4]', 'a')", expect: '[4, "a"]'},
                           {query: "select ?('[]', '3')", expect: '["3"]'},
                           {query: "select ?('', '5')", expect: '["5"]'},
                           {query: "select ?(null, null)", expect: "[null]"},
                           {query: "select ?('abc', 'a')", expect: '["a"]'},
                       ]
      }, {
          type:        :function,
          name:        :json_array_concat,
          description: "Concatenates two JSON arrays and returns the new array as a string",
          params:      "j varchar(max), k varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            import json
            if not j:
              return k
            if not k:
              return j
            try:
              arr_j = json.loads(j)
              arr_k = json.loads(k)
            except ValueError:
              return None
            arr_j.extend(arr_k)
            return json.dumps(arr_j)
          ~,
          tests:       [
                           {query: "select ?('[\"a\",\"c\",\"b\"]', '[\"d\",\"e\"]')", expect: '["a", "c", "b", "d", "e"]', example: true},
                           {query: "select ?('[1, 3, 2]', '[4]')", expect: '[1, 3, 2, 4]', example: true},
                           {query: "select ?('[4]', '[\"a\"]')", expect: '[4, "a"]'},
                           {query: "select ?('[]', '[3]')", expect: '[3]'},
                           {query: "select ?('', '5')", expect: '5'},
                           {query: "select ?('4', null)", expect: "4"},
                           {query: "select ?('abc', 'a')", expect: nil},
                       ]
      }, {
          type:              :aggregate,
          name:              :json_array_agg,
          description:       "Concatenate a column of varchars into a json array",
          params:            "varchar(max)",
          init_function:     :agg_init_blank_varchar,
          agg_function:      :json_array_push,
          finalize_function: :agg_finalize_varchar,
          tests:             [
                                 {rows: ["foo", "bar", "baz"], expect: '["foo", "bar", "baz"]', example: true},
                                 {rows: ["foo"], expect: '["foo"]', example: true},
                             ]
      }
  ]
end
