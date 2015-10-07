
      /*
      AGG_INIT_BLANK_VARCHAR
      Aggregate helper: Inits an empty varchar

      Examples:
        select agg_init_blank_varchar() --> ''
      */
      create or replace function agg_init_blank_varchar ()
        returns varchar
        stable as $$
          return ""
        $$ language plpythonu;
    

      /*
      AGG_FINALIZE_VARCHAR
      Aggregate helper: Returns state varchar without modifying it

      Examples:
        select agg_finalize_varchar('str') --> 'str'
      */
      create or replace function agg_finalize_varchar (state varchar(max))
        returns varchar(max)
        stable as $$
          return state
        $$ language plpythonu;
    

      /*
      AGG_AGG_NUMBERS_TO_LIST
      Aggregate helper: Aggregate numbers into a string for use in a later step

      Examples:
        select agg_agg_numbers_to_list('', 3.5) --> '3.5'
        select agg_agg_numbers_to_list('1.0 2.0 3.0', 4) --> '1.0 2.0 3.0 4.0'
      */
      create or replace function agg_agg_numbers_to_list (state varchar(max), a float)
        returns varchar(max)
        stable as $$
          if not state or len(state) == 0:
            if a:
              return str(a)
            return None
          if not a:
            return state
          return state + " " + str(a)
        $$ language plpythonu;
    

      /*
      JSON_ARRAY_FIRST
      Returns the first element of a JSON array as a string

      Examples:
        select json_array_first('["a", "b"]') --> 'a'
        select json_array_first('[1, 2, 3]') --> '1'
      */
      create or replace function json_array_first (j varchar(max))
        returns varchar(max)
        stable as $$
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
        $$ language plpythonu;
    

      /*
      JSON_ARRAY_LAST
      Returns the last element of a JSON array as a string

      Examples:
        select json_array_last('["a", "b"]') --> 'b'
        select json_array_last('[1, 2, 3]') --> '3'
      */
      create or replace function json_array_last (j varchar(max))
        returns varchar(max)
        stable as $$
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
        $$ language plpythonu;
    

      /*
      JSON_ARRAY_NTH
      Returns the Nth 0-indexed element of a JSON array as a string

      Examples:
        select json_array_nth('["a", "b"]', 0) --> 'a'
        select json_array_nth('[1, 2, 3]', 1) --> '2'
      */
      create or replace function json_array_nth (j varchar(max), i integer)
        returns varchar(max)
        stable as $$
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
        $$ language plpythonu;
    

      /*
      JSON_ARRAY_SORT
      Returns sorts a JSON array and returns it as a string, second param sets direction

      Examples:
        select json_array_sort('["a","c","b"]', true) --> '["a", "b", "c"]'
        select json_array_sort('[1, 3, 2]', true) --> '[1, 2, 3]'
      */
      create or replace function json_array_sort (j varchar(max), ascending boolean)
        returns varchar(max)
        stable as $$
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
        $$ language plpythonu;
    

      /*
      JSON_ARRAY_REVERSE
      Reverses a JSON array and returns it as a string

      Examples:
        select json_array_reverse('["a","c","b"]') --> '["b", "c", "a"]'
        select json_array_reverse('[1, 3, 2]') --> '[2, 3, 1]'
      */
      create or replace function json_array_reverse (j varchar(max))
        returns varchar(max)
        stable as $$
          import json
          if not j:
            return None
          try:
            arr = json.loads(j)
          except ValueError:
            return None
          return json.dumps(arr[::-1])
        $$ language plpythonu;
    

      /*
      JSON_ARRAY_POP
      Removes the last element from a JSON array and returns the remaining array as a string

      Examples:
        select json_array_pop('["a","c","b"]') --> '["a", "c"]'
        select json_array_pop('[1, 3, 2]') --> '[1, 3]'
      */
      create or replace function json_array_pop (j varchar(max))
        returns varchar(max)
        stable as $$
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
        $$ language plpythonu;
    

      /*
      JSON_ARRAY_PUSH
      Adds a new element to a JSON array and returns the new array as a string

      Examples:
        select json_array_push('["a","c","b"]', 'd') --> '["a", "c", "b", "d"]'
        select json_array_push('[1, 3, 2]', '4') --> '[1, 3, 2, "4"]'
      */
      create or replace function json_array_push (j varchar(max), value varchar(max))
        returns varchar(max)
        stable as $$
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
        $$ language plpythonu;
    

      /*
      JSON_ARRAY_CONCAT
      Concatenates two JSON arrays and returns the new array as a string

      Examples:
        select json_array_concat('["a","c","b"]', '["d","e"]') --> '["a", "c", "b", "d", "e"]'
        select json_array_concat('[1, 3, 2]', '[4]') --> '[1, 3, 2, 4]'
      */
      create or replace function json_array_concat (j varchar(max), k varchar(max))
        returns varchar(max)
        stable as $$
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
        $$ language plpythonu;
    

      /*
      JSON_ARRAY_AGG
      Concatenate a column of varchars into a json array

      Examples:
        [foo, bar, baz] --> '["foo", "bar", "baz"]'
        [foo] --> '["foo"]'
      */
      create aggregate json_array_agg (varchar(max))
      (
        initfunc = agg_init_blank_varchar,
        aggfunc = json_array_push,
        finalizefunc = agg_finalize_varchar
      );
    

      /*
      MYSQL_YEAR
      Extract the year from a datetime

      Examples:
        select mysql_year('2015-01-03T04:05:06.07'::timestamp) --> 2015
        select mysql_year('2016-02-04T04:05:06.07 -07'::timestamp) --> 2016
        select mysql_year('2017-03-05'::timestamp) --> 2017
      */
      create or replace function mysql_year (ts timestamp)
        returns integer
        stable as $$
          if not ts:
            return None
          return ts.year
        $$ language plpythonu;
    

      /*
      MYSQL_MONTH
      Extract the month from a datetime

      Examples:
        select mysql_month('2015-01-03T04:05:06.07'::timestamp) --> 1
        select mysql_month('2016-02-04T04:05:06.07 -07'::timestamp) --> 2
        select mysql_month('2016-03-05'::timestamp) --> 3
      */
      create or replace function mysql_month (ts timestamp)
        returns integer
        stable as $$
          if not ts:
            return None
          return ts.month
        $$ language plpythonu;
    

      /*
      MYSQL_DAY
      Extract the day from a datetime

      Examples:
        select mysql_day('2015-02-03T04:05:06.07'::timestamp) --> 3
        select mysql_day('2016-02-04T04:05:06.07 -07'::timestamp) --> 4
        select mysql_day('2016-02-05'::timestamp) --> 5
      */
      create or replace function mysql_day (ts timestamp)
        returns integer
        stable as $$
          if not ts:
            return None
          return ts.day
        $$ language plpythonu;
    

      /*
      MYSQL_HOUR
      Extract the hour from a datetime

      Examples:
        select mysql_hour('2015-02-03T04:05:06.07'::timestamp) --> 4
        select mysql_hour('2016-02-03T04:05:06.07 -07'::timestamp) --> 4
        select mysql_hour('2016-02-03'::timestamp) --> 0
      */
      create or replace function mysql_hour (ts timestamp)
        returns integer
        stable as $$
          if not ts:
            return None
          return ts.hour
        $$ language plpythonu;
    

      /*
      MYSQL_MINUTE
      Extract the minute from a datetime

      Examples:
        select mysql_minute('2015-02-03T04:05:06.07'::timestamp) --> 5
        select mysql_minute('2016-02-03T04:15:06.07 -07'::timestamp) --> 15
        select mysql_minute('2016-02-03'::timestamp) --> 0
      */
      create or replace function mysql_minute (ts timestamp)
        returns integer
        stable as $$
          if not ts:
            return None
          return ts.minute
        $$ language plpythonu;
    

      /*
      MYSQL_SECOND
      Extract the second from a datetime

      Examples:
        select mysql_second('2015-02-03T04:05:06.07'::timestamp) --> 6
        select mysql_second('2016-02-03T04:15:16.07 -07'::timestamp) --> 16
        select mysql_second('2016-02-03'::timestamp) --> 0
      */
      create or replace function mysql_second (ts timestamp)
        returns integer
        stable as $$
          if not ts:
            return None
          return ts.second
        $$ language plpythonu;
    

      /*
      MYSQL_YEARWEEK
      Extract the week of the year from a datetime

      Examples:
        select mysql_yearweek('2015-02-03T04:05:06.07'::timestamp) --> '201506'
        select mysql_yearweek('2016-02-03T04:15:16.07 -07'::timestamp) --> '201605'
        select mysql_yearweek('2016-02-03'::timestamp) --> '201605'
      */
      create or replace function mysql_yearweek (ts timestamp)
        returns varchar(max)
        stable as $$
          if not ts:
            return None
          cal = ts.isocalendar()
          return str(cal[0]) + str(cal[1]).zfill(2)
        $$ language plpythonu;
    

      /*
      NOW
      Returns the current time as a timestamp in UTC

      Examples:
        select now() --> '2015-03-30 21:32:15.553489+00'
      */
      create or replace function now ()
        returns timestamp
        stable as $$
          from datetime import datetime
          datetime.utcnow()
        $$ language plpythonu;
    

      /*
      POSIX_TIMESTAMP
      Returns the number of seconds from 1970-01-01 for this timestamp

      Examples:
        select posix_timestamp('2015-03-30 21:32:15'::timestamp) --> '1427751521.107629'
      */
      create or replace function posix_timestamp (ts timestamp)
        returns real
        stable as $$
          from datetime import datetime
          if not ts:
            return None
          return (ts - datetime(1970, 1, 1)).total_seconds()
        $$ language plpythonu;
    

      /*
      EMAIL_NAME
      Gets the part of the email address before the @ sign

      Examples:
        select email_name('sam@company.com') --> 'sam'
        select email_name('alex@othercompany.com') --> 'alex'
      */
      create or replace function email_name (email varchar(max))
        returns varchar(max)
        stable as $$
          if not email:
            return None
          return email.split('@')[0]
        $$ language plpythonu;
    

      /*
      EMAIL_DOMAIN
      Gets the part of the email address after the @ sign

      Examples:
        select email_domain('sam@company.com') --> 'company.com'
        select email_domain('alex@othercompany.com') --> 'othercompany.com'
      */
      create or replace function email_domain (email varchar(max))
        returns varchar(max)
        stable as $$
          if not email:
            return None
          return email.split('@')[-1]
        $$ language plpythonu;
    

      /*
      URL_PROTOCOL
      Gets the protocol of the URL

      Examples:
        select url_protocol('http://www.google.com/a') --> 'http'
        select url_protocol('https://gmail.com/b') --> 'https'
        select url_protocol('sftp://company.com/c') --> 'sftp'
      */
      create or replace function url_protocol (url varchar(max))
        returns varchar(max)
        stable as $$
          from urlparse import urlparse
          if not url:
            return None
          try:
            u = urlparse(url)
            return u.scheme
          except ValueError:
            return None
        $$ language plpythonu;
    

      /*
      URL_DOMAIN
      Gets the domain (and subdomain if present) of the URL

      Examples:
        select url_domain('http://www.google.com/a') --> 'www.google.com'
        select url_domain('https://gmail.com/b') --> 'gmail.com'
      */
      create or replace function url_domain (url varchar(max))
        returns varchar(max)
        stable as $$
          from urlparse import urlparse
          if not url:
            return None
          try:
            u = urlparse(url)
            return u.netloc
          except ValueError:
            return None
        $$ language plpythonu;
    

      /*
      URL_PATH
      Gets the domain (and subdomain if present) of the URL

      Examples:
        select url_path('http://www.google.com/search/images?query=bob') --> '/search/images'
        select url_path('https://gmail.com/mail.php?user=bob') --> '/mail.php'
      */
      create or replace function url_path (url varchar(max))
        returns varchar(max)
        stable as $$
          from urlparse import urlparse
          if not url:
            return None
          try:
            u = urlparse(url)
            return u.path
          except ValueError:
            return None
        $$ language plpythonu;
    

      /*
      URL_PARAM
      Extract a parameter from a URL

      Examples:
        select url_param('http://www.google.com/search/images?query=bob', 'query') --> 'bob'
        select url_param('https://gmail.com/mail.php?user=bob&account=work', 'user') --> 'bob'
      */
      create or replace function url_param (url varchar(max), param varchar(max))
        returns varchar(max)
        stable as $$
          import urlparse
          if not url:
            return None
          try:
            u = urlparse.urlparse(url)
            return urlparse.parse_qs(u.query)[param][0]
          except KeyError:
            return None
        $$ language plpythonu;
    

      /*
      SPLIT_COUNT
      Split a string on another string and count the members

      Examples:
        select split_count('foo,bar,baz', ',') --> 3
        select split_count('foo', 'bar') --> 1
      */
      create or replace function split_count (str varchar(max), delim varchar(max))
        returns int
        stable as $$
          if not str or not delim:
            return None
          return len(str.split(delim))
        $$ language plpythonu;
    

      /*
      TITLECASE
      Format a string as titlecase

      Examples:
        select titlecase('this is a title') --> 'This Is A Title'
        select titlecase('Already A Title') --> 'Already A Title'
      */
      create or replace function titlecase (str varchar(max))
        returns varchar(max)
        stable as $$
          if not str:
            return None
          return str.title()
        $$ language plpythonu;
    

      /*
      STR_MULTIPLY
      Repeat a string N times

      Examples:
        select str_multiply('*', 10) --> '**********'
        select str_multiply('abc ', 3) --> 'abc abc abc '
      */
      create or replace function str_multiply (str varchar(max), times integer)
        returns varchar(max)
        stable as $$
          if not str:
            return None
          return str * times
        $$ language plpythonu;
    

      /*
      STR_INDEX
      Find the index of the first occurrence of a substring, or -1 if not found

      Examples:
        select str_index('Apples Oranges Pears', 'Oranges') --> 7
        select str_index('Apples Oranges Pears', 'Bananas') --> -1
      */
      create or replace function str_index (full_str varchar(max), find_substr varchar(max))
        returns integer
        stable as $$
          if not full_str or not find_substr:
            return None
          return full_str.find(find_substr)
        $$ language plpythonu;
    

      /*
      STR_RINDEX
      Find the index of the last occurrence of a substring, or -1 if not found

      Examples:
        select str_rindex('A B C A B C', 'C') --> 10
        select str_rindex('Apples Oranges Pears Oranges', 'Oranges') --> 21
        select str_rindex('Apples Oranges', 'Bananas') --> -1
      */
      create or replace function str_rindex (full_str varchar(max), find_substr varchar(max))
        returns integer
        stable as $$
          if not full_str or not find_substr:
            return None
          return full_str.rfind(find_substr)
        $$ language plpythonu;
    

      /*
      STR_COUNT
      Counts the number of occurrences of a substring within a string

      Examples:
        select str_count('abbbc', 'b') --> 3
        select str_count('Apples Bananas', 'an') --> 2
        select str_count('aaa', 'A') --> 0
      */
      create or replace function str_count (full_str varchar(max), find_substr varchar(max))
        returns integer
        stable as $$
          if not full_str or not find_substr:
            return None
          return full_str.count(find_substr)
        $$ language plpythonu;
    

      /*
      AGG_AGG_COMMA_CONCAT
      Aggregate helper: Concatenates varchars with commas

      Examples:
        select agg_agg_comma_concat('a', 'b') --> 'a,b'
        select agg_agg_comma_concat('a,b,c', 'd,e') --> 'a,b,c,d,e'
      */
      create or replace function agg_agg_comma_concat (state varchar(max), a varchar(max))
        returns varchar(max)
        stable as $$
          if not state or len(state) == 0:
            return a
          if not a or len(a) == 0:
            return state
          return state + "," + a
        $$ language plpythonu;
    

      /*
      COMMA_CONCAT
      Concatenate a column of varchars with commas

      Examples:
        [foo, bar, baz] --> 'foo,bar,baz'
        [foo] --> 'foo'
      */
      create aggregate comma_concat (varchar(max))
      (
        initfunc = agg_init_blank_varchar,
        aggfunc = agg_agg_comma_concat,
        finalizefunc = agg_finalize_varchar
      );
    

      /*
      FORMAT_NUM
      Format a number with Python's string format notation

      Examples:
        select format_num(2.17189, '.2f') --> '2.17'
        select format_num(2, '0>4d') --> '0002'
        select format_num(1234567.89, ',') --> '1,234,567.89'
        select format_num(0.1234, '.2%') --> '12.34%'
      */
      create or replace function format_num (num float, format varchar)
        returns varchar
        stable as $$
          if not num or not format:
            return None
          try:
            return ("{:" + format + "}").format(num)
          except ValueError:
            try:
              return ("{:" + format + "}").format(int(num))
            except ValueError:
              return None
        $$ language plpythonu;
    

      /*
      AGG_FINALIZE_HARMONIC_MEAN
      Aggregate helper: Convert a list of numbers into a harmonic mean

      Examples:
        select agg_finalize_harmonic_mean('1 2 3') --> 1.63636363636364
        select agg_finalize_harmonic_mean('1.5 2.5 3.5') --> 2.21830985915493
      */
      create or replace function agg_finalize_harmonic_mean (state varchar(max))
        returns float
        stable as $$
          import numpy
          if not state or len(state) == 0:
            return None
          nums = list((float(v) for v in state.split() if float(v) > 0))
          if len(nums) == 0:
            return None
          return len(nums) / sum(1.0 / v for v in nums)
        $$ language plpythonu;
    

      /*
      HARMONIC_MEAN
      Compute the harmonic mean of a set of positive numbers

      Examples:
        [3.5, 4.5, 5.5] --> 4.34937238493724
        [6, 10, 20] --> 9.47368421052632
      */
      create aggregate harmonic_mean (float)
      (
        initfunc = agg_init_blank_varchar,
        aggfunc = agg_agg_numbers_to_list,
        finalizefunc = agg_finalize_harmonic_mean
      );
    

      /*
      AGG_FINALIZE_SECOND_MAX
      Aggregate helper: Get the second highest value from a list of numbers

      Examples:
        select agg_finalize_second_max('1 2 3') --> 2.0
        select agg_finalize_second_max('1.5 5.5 3.5') --> 3.5
        select agg_finalize_second_max('-10 -100') --> -100.0
      */
      create or replace function agg_finalize_second_max (state varchar(max))
        returns float
        stable as $$
          import numpy
          if not state or len(state) == 0:
            return None
          nums = list((float(v) for v in state.split()))
          if len(nums) <= 1:
            return None
          return sorted(nums)[-2]
        $$ language plpythonu;
    

      /*
      SECOND_MAX
      Get the second greatest number from a set of numbers

      Examples:
        [3.5, 4.5, 5.5] --> 4.5
        [6, -10, 20, 50] --> 20
      */
      create aggregate second_max (float)
      (
        initfunc = agg_init_blank_varchar,
        aggfunc = agg_agg_numbers_to_list,
        finalizefunc = agg_finalize_second_max
      );
    

      /*
      EXPERIMENT_RESULT_P_VALUE
      Returns a p-value for a controlled experiment to determine statistical significance

      Examples:
        select round(experiment_result_p_value(5000,486, 5000, 527),3) --> 0.185
        select case when experiment_result_p_value(5000,486, 5000, 527) < 0.05 then 'yes' else 'no' end as signifcant --> 'no'
        select experiment_result_p_value(20000,17998,20000, 17742) --> 3.57722238820663e-05
        select case when experiment_result_p_value(20000,17998,20000, 17742) < 0.05 then 'yes' else 'no' end as significant --> 'yes'
      */
      create or replace function experiment_result_p_value (control_size float, control_conversion float, experiment_size float, experiment_conversion float)
        returns float
        stable as $$
          from scipy.stats import chi2_contingency
          from numpy import array
          observed = array([
            [control_size - control_conversion, control_conversion],
            [experiment_size - experiment_conversion, experiment_conversion]
          ])
          result = chi2_contingency(observed, correction=True)
          chisq, p = result[:2]
          return p
        $$ language plpythonu;
    
