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
      }, {
          type:        :function,
          name:        :agg_finalize_harmonic_mean,
          description: "Convert a list of numbers into a harmonic mean",
          params:      "state varchar(max)",
          return_type: "float",
          body:        %~
            import numpy
            if not state or len(state) == 0:
              return None
            nums = list((float(v) for v in state.split() if float(v) > 0))
            if len(nums) == 0:
              return None
            return len(nums) / sum(1.0 / v for v in nums)
          ~,
          tests:       [
                           {query: "select ?('1 2 3')", expect: 1.63636363636364, example: true},
                           {query: "select ?('1.5 2.5 3.5')", expect: 2.21830985915493, example: true},
                           {query: "select ?('5')", expect: 5},
                           {query: "select ?('-5')", expect: nil},
                           {query: "select ?('')", expect: nil},
                           {query: "select ?(null)", expect: nil},
                       ]
      }, {
          type:              :aggregate,
          name:              :harmonic_mean,
          description:       "Compute the harmonic mean of a set of positive numbers",
          params:            "float",
          init_function:     :agg_init_blank_varchar,
          agg_function:      :agg_agg_numbers_to_list,
          finalize_function: :agg_finalize_harmonic_mean,
          tests:             [
                                 {rows: [3.5, 4.5, 5.5], expect: 4.34937238493724, example: true},
                                 {rows: [6, 10, 20], expect: 9.47368421052632, example: true},
                             ]
      }, {
          type:        :function,
          name:        :agg_finalize_second_max,
          description: "Get the second highest value from a list of numbers",
          params:      "state varchar(max)",
          return_type: "float",
          body:        %~
            import numpy
            if not state or len(state) == 0:
              return None
            nums = list((float(v) for v in state.split()))
            if len(nums) <= 1:
              return None
            return sorted(nums)[-2]
          ~,
          tests:       [
                           {query: "select ?('1 2 3')", expect: 2.0, example: true},
                           {query: "select ?('1.5 5.5 3.5')", expect: 3.5, example: true},
                           {query: "select ?('-10 -100')", expect: -100.0, example: true},
                           {query: "select ?('5')", expect: nil},
                           {query: "select ?('')", expect: nil},
                           {query: "select ?(null)", expect: nil},
                       ]
      }, {
          type:              :aggregate,
          name:              :second_max,
          description:       "Get the second greatest number from a set of numbers",
          params:            "float",
          init_function:     :agg_init_blank_varchar,
          agg_function:      :agg_agg_numbers_to_list,
          finalize_function: :agg_finalize_second_max,
          tests:             [
                                 {rows: [3.5, 4.5, 5.5], expect: 4.5, example: true},
                                 {rows: [6, -10, 20, 50], expect: 20, example: true},
                             ]
      }
  ]
end
