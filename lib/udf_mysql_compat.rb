class UdfMysqlCompat
  UDFS = [
      {
          type:        :function,
          name:        :mysql_year,
          description: "Extract the year from a datetime",
          params:      "ts timestamp",
          return_type: "integer",
          body:        %~
            if not ts:
              return None
            return ts.year
          ~,
          tests:       [
                           {query: "select ?('2015-01-03T04:05:06.07'::timestamp)", expect: 2015, example: true},
                           {query: "select ?('2016-02-04T04:05:06.07 -07'::timestamp)", expect: 2016, example: true},
                           {query: "select ?('2017-03-05'::timestamp)", expect: 2017, example: true},
                       ]
      }, {
          type:        :function,
          name:        :mysql_month,
          description: "Extract the month from a datetime",
          params:      "ts timestamp",
          return_type: "integer",
          body:        %~
            if not ts:
              return None
            return ts.month
          ~,
          tests:       [
                           {query: "select ?('2015-01-03T04:05:06.07'::timestamp)", expect: 1, example: true},
                           {query: "select ?('2016-02-04T04:05:06.07 -07'::timestamp)", expect: 2, example: true},
                           {query: "select ?('2016-03-05'::timestamp)", expect: 3, example: true},
                       ]
      }, {
          type:        :function,
          name:        :mysql_day,
          description: "Extract the day from a datetime",
          params:      "ts timestamp",
          return_type: "integer",
          body:        %~
            if not ts:
              return None
            return ts.day
          ~,
          tests:       [
                           {query: "select ?('2015-02-03T04:05:06.07'::timestamp)", expect: 3, example: true},
                           {query: "select ?('2016-02-04T04:05:06.07 -07'::timestamp)", expect: 4, example: true},
                           {query: "select ?('2016-02-05'::timestamp)", expect: 5, example: true},
                       ]
      }, {
          type:        :function,
          name:        :mysql_hour,
          description: "Extract the hour from a datetime",
          params:      "ts timestamp",
          return_type: "integer",
          body:        %~
            if not ts:
              return None
            return ts.hour
          ~,
          tests:       [
                           {query: "select ?('2015-02-03T04:05:06.07'::timestamp)", expect: 4, example: true},
                           {query: "select ?('2016-02-03T04:05:06.07 -07'::timestamp)", expect: 4, example: true},
                           {query: "select ?('2016-02-03'::timestamp)", expect: 0, example: true},
                       ]
      }, {
          type:        :function,
          name:        :mysql_minute,
          description: "Extract the minute from a datetime",
          params:      "ts timestamp",
          return_type: "integer",
          body:        %~
            if not ts:
              return None
            return ts.minute
          ~,
          tests:       [
                           {query: "select ?('2015-02-03T04:05:06.07'::timestamp)", expect: 5, example: true},
                           {query: "select ?('2016-02-03T04:15:06.07 -07'::timestamp)", expect: 15, example: true},
                           {query: "select ?('2016-02-03'::timestamp)", expect: 0, example: true},
                       ]
      }, {
          type:        :function,
          name:        :mysql_second,
          description: "Extract the second from a datetime",
          params:      "ts timestamp",
          return_type: "integer",
          body:        %~
            if not ts:
              return None
            return ts.second
          ~,
          tests:       [
                           {query: "select ?('2015-02-03T04:05:06.07'::timestamp)", expect: 6, example: true},
                           {query: "select ?('2016-02-03T04:15:16.07 -07'::timestamp)", expect: 16, example: true},
                           {query: "select ?('2016-02-03'::timestamp)", expect: 0, example: true},
                       ]
      }, {
          type:        :function,
          name:        :mysql_yearweek,
          description: "Extract the week of the year from a datetime",
          params:      "ts timestamp",
          return_type: "varchar(max)",
          body:        %~
            if not ts:
              return None
            cal = ts.isocalendar()
            return str(cal[0]) + str(cal[1]).zfill(2)
          ~,
          tests:       [
                           {query: "select ?('2015-02-03T04:05:06.07'::timestamp)", expect: '201506', example: true},
                           {query: "select ?('2016-02-03T04:15:16.07 -07'::timestamp)", expect: '201605', example: true},
                           {query: "select ?('2016-02-03'::timestamp)", expect: '201605', example: true},
                       ]
      },
  ]
end
