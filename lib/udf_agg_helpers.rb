class UdfAggHelpers
  UDFS = [
      {
          type:        :function,
          name:        :agg_init_blank_varchar,
          description: "Inits an empty varchar",
          params:      nil,
          return_type: "varchar",
          body:        %~
            return ""
          ~,
          tests:       [
                           {query: "select ?()", expect: '', example: true},
                       ]
      }, {
          type:        :function,
          name:        :agg_finalize_varchar,
          description: "Returns state varchar without modifying it",
          params:      "state varchar(max)",
          return_type: "varchar(max)",
          body:        %~
            return state
          ~,
          tests:       [
                           {query: "select ?('str')", expect: 'str', example: true},
                       ]
      }, {
          type:        :function,
          name:        :agg_agg_numbers_to_list,
          description: "Aggregate numbers into a string for use in a later step",
          params:      "state varchar(max), a float",
          return_type: "varchar(max)",
          body:        %~
            if not state or len(state) == 0:
              if a:
                return str(a)
              return None
            if not a:
              return state
            return state + " " + str(a)
          ~,
          tests:       [
                           {query: "select ?('', 3.5)", expect: '3.5', example: true},
                           {query: "select ?('1.0 2.0 3.0', 4)", expect: '1.0 2.0 3.0 4.0', example: true},
                           {query: "select ?(null, 5)", expect: '5.0'},
                           {query: "select ?('5', null)", expect: '5'},
                           {query: "select ?('', '')", expect: nil},
                           {query: "select ?(null, null)", expect: nil},
                       ]
      }
  ]
end
