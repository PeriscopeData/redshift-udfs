class UdfTimeHelpers
  UDFS = [
      {
          type:        :function,
          name:        :now,
          description: "Returns the current time as a timestamp in UTC",
          params:      nil,
          return_type: "timestamp",
          body:        %~
            from datetime import datetime
            datetime.utcnow()
          ~,
          tests:       [
                           {query: "select ?()", expect: '2015-03-30 21:32:15.553489+00', example: true, skip: true},
                       ]
      },
      {
          type:        :function,
          name:        :posix_timestamp,
          description: "Returns the number of seconds from 1970-01-01 for this timestamp",
          params:      "ts timestamp",
          return_type: "real",
          body:        %~
            from datetime import datetime
            if not ts:
              return None
            return (ts - datetime(1970, 1, 1)).total_seconds()
          ~,
          tests:       [
                           {query: "select ?('2015-03-30 21:32:15'::timestamp)", expect: '1427751521.107629', example: true, skip: true},
                       ]
      },
      {
          type:        :function,
          name:        :from_posix_timestamp,
          description: "Converts a POSIX timestamp into a UTC human-readable timestamp",
          params:      "epoch float",
          return_type: "timestamp",
          body:        %~
            from datetime import datetime
            if not epoch:
              return None
            return datetime.fromtimestamp(epoch)
          ~,
          tests:       [
                           {query: "select ?('1427751521.107629')", expect: '2015-03-30 21:32:15', example: true, skip: true},
                       ]
      },
  ]
end
