class UdfStats
    UDFS = [
        {
          type:        :function,
          name:        :experiment_result_p_value,
          description: "Returns a p-value for a controlled experiment to determine statistical significance",
          params:      "control_size float, control_conversion float, experiment_size float, experiment_conversion float",
          return_type: "float",
          body:        %~
            from scipy.stats import chi2_contingency
            from numpy import array
            observed = array([
              [control_size - control_conversion, control_conversion],
              [experiment_size - experiment_conversion, experiment_conversion]
            ])
            result = chi2_contingency(observed, correction=True)
            chisq, p = result[:2]
            return p

          ~,
          tests: [
            {query: "select round(?(5000,486, 5000, 527),3)", expect: 0.185, example: true},
            {query: "select case when ?(5000,486, 5000, 527) < 0.05 then 'yes' else 'no' end as signifcant", expect: 'no', example: true},
            {query: "select ?(20000,17998,20000, 17742)", expect: 3.57722238820663e-05, example: true},
            {query: "select case when ?(20000,17998,20000, 17742) < 0.05 then 'yes' else 'no' end as significant", expect: 'yes', example: true}
          ]
        }, {
            type:        :function,
            name:        :binomial_hpdr,
            description: "Compare value against boundaries of Highest Posterior Density Region",
            params:      "value float, successes bigint, samples bigint, pct float, a bigint, b bigint, n_pbins integer",
            return_type: "smallint",
            body:        %~
              # Taken from:
              # http://stackoverflow.com/a/19285227

              # Check input arguments
              if successes is None or samples is None or samples < 1:
                return None

              import numpy
              from scipy.stats import beta
              from scipy.stats import norm
              n = successes
              N = samples
              rv = beta(n+a, N-n+b)
              stdev = rv.stats('v')**0.5
              mode = (n+a-1.)/(N+a+b-2.)
              n_sigma = numpy.ceil(norm.ppf( (1+pct)/2. ))+1
              max_p = mode + n_sigma * stdev
              if max_p > 1:
                max_p = 1.
              min_p = mode - n_sigma * stdev
              if min_p > 1:
                min_p = 1.
              p_range = numpy.linspace(min_p, max_p, n_pbins+1)
              if mode > 0.5:
                sf = rv.sf(p_range)
                pmf = sf[:-1] - sf[1:]
              else:
                cdf = rv.cdf(p_range)
                pmf = cdf[1:] - cdf[:-1]
              # find the upper and lower bounds of the interval 
              sorted_idxs = numpy.argsort( pmf )[::-1]
              cumsum = numpy.cumsum( numpy.sort(pmf)[::-1] )
              j = numpy.argmin( numpy.abs(cumsum - pct) )
              upper = p_range[ (sorted_idxs[:j+1]).max()+1 ]
              lower = p_range[ (sorted_idxs[:j+1]).min() ]
              if (value >= lower and value <= upper):
                return 0
              elif value >= upper:
                return 1
              else:
                return -1

          ~,
          tests: [
            {query: "select ?(0.7, 10, 20, .95, 1, 1, 1000)", expect: 0, example: true},
            {query: "select ?(0.9, 10, 20, .95, 1, 1, 1000)", expect: 1, example: true},
            {query: "select ?(0.3, 10, 20, .95, 1, 1, 1000)", expect: 0, example: true},
            {query: "select ?(0.1, 10, 20, .95, 1, 1, 1000)", expect: -1, example: true}
          ]
        }, {
            type:        :function,
            name:        :binomial_hpdr_upper,
            description: "Returns the upper boundary fo the Highest Posterior Density Region",
            params:      "successes bigint, samples bigint, pct float, a bigint, b bigint, n_pbins integer",
            return_type: "float",
            body:        %~
              # Taken from:
              # http://stackoverflow.com/a/19285227

              # Check input arguments
              if successes is None or samples is None or samples < 1:
                return None

              import numpy
              from scipy.stats import beta
              from scipy.stats import norm
              n = successes
              N = samples
              rv = beta(n+a, N-n+b)
              stdev = rv.stats('v')**0.5
              mode = (n+a-1.)/(N+a+b-2.)
              n_sigma = numpy.ceil(norm.ppf( (1+pct)/2. ))+1
              max_p = mode + n_sigma * stdev
              if max_p > 1:
                max_p = 1.
              min_p = mode - n_sigma * stdev
              if min_p > 1:
                min_p = 1.
              p_range = numpy.linspace(min_p, max_p, n_pbins+1)
              if mode > 0.5:
                  sf = rv.sf(p_range)
                  pmf = sf[:-1] - sf[1:]
              else:
                  cdf = rv.cdf(p_range)
                  pmf = cdf[1:] - cdf[:-1]
              # find the upper and lower bounds of the interval 
              sorted_idxs = numpy.argsort( pmf )[::-1]
              cumsum = numpy.cumsum( numpy.sort(pmf)[::-1] )
              j = numpy.argmin( numpy.abs(cumsum - pct) )
              return p_range[ (sorted_idxs[:j+1]).max()+1 ]

          ~,
          tests: [
            {query: "select round(?(10, 20, .95, 1, 1, 1000), 3)", expect: 0.702, example: true},
            {query: "select round(?(1, 20, .95, 1, 1, 1000), 3)", expect: 0.208, example: true}
          ]
        }, {
            type:        :function,
            name:        :binomial_hpdr_lower,
            description: "Returns the lower boundary of the Highest Posterior Density Region",
            params:      "successes bigint, samples bigint, pct float, a bigint, b bigint, n_pbins integer",
            return_type: "float",
            body:        %~
              # Taken from:
              # http://stackoverflow.com/a/19285227

              # Check input arguments
              if successes is None or samples is None or samples < 1:
                return None

              import numpy
              from scipy.stats import beta
              from scipy.stats import norm
              n = successes
              N = samples
              rv = beta(n+a, N-n+b)
              stdev = rv.stats('v')**0.5
              mode = (n+a-1.)/(N+a+b-2.)
              n_sigma = numpy.ceil(norm.ppf( (1+pct)/2. ))+1
              max_p = mode + n_sigma * stdev
              if max_p > 1:
                max_p = 1.
              min_p = mode - n_sigma * stdev
              if min_p > 1:
                min_p = 1.
              p_range = numpy.linspace(min_p, max_p, n_pbins+1)
              if mode > 0.5:
                  sf = rv.sf(p_range)
                  pmf = sf[:-1] - sf[1:]
              else:
                  cdf = rv.cdf(p_range)
                  pmf = cdf[1:] - cdf[:-1]
              # find the upper and lower bounds of the interval 
              sorted_idxs = numpy.argsort( pmf )[::-1]
              cumsum = numpy.cumsum( numpy.sort(pmf)[::-1] )
              j = numpy.argmin( numpy.abs(cumsum - pct) )
              return p_range[ (sorted_idxs[:j+1]).min() ]

          ~,
          tests: [
            {query: "select round(?(10, 20, .95, 1, 1, 1000), 3)", expect: 0.298, example: true},
            {query: "select round(?(1, 20, .95, 1, 1, 1000), 3)", expect: 0.003, example: true}
          ]
        }
    ]
end
