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
        }
    ]

end
