require 'pg'
require 'yaml'

Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each do |file|
  require_relative File.join('lib', File.basename(file))
end

class UdfHarness

  def initialize(only_udf = nil)
    @udfs = [
        UdfAggHelpers::UDFS,
        UdfJsonArrays::UDFS,
        UdfMysqlCompat::UDFS,
        UdfTimeHelpers::UDFS,
        UdfStringUtils::UDFS,
        UdfNumberUtils::UDFS,
    ].flatten.select { |u| only_udf.nil? or u[:name] == only_udf.to_sym }
  end

  def create_udfs
    @udfs.each { |udf| create_udf(udf) }
  end

  def drop_udfs
    @udfs.each { |udf| drop_udf(udf) }
  end

  def test_udfs
    create_udfs
    @udfs.each { |udf| test_udf(udf) }
  end

  def print_udfs
    @udfs.each { |udf| puts make_create_query(udf) }
  end

  private

  # --------------------------- Running Queries --------------------

  def get_env_or_panic!(var)
    val = YAML.load(File.open(File.join(File.dirname(__FILE__), 'config.yaml')))[var]
    val ||= ENV[var].to_s.strip
    if val == ''
      puts "Error: Missing value for #{var}"
      exit
    end
    val
  end

  def connect!
    @conn ||= PG.connect({
                             host:     get_env_or_panic!('UDF_CLUSTER_HOST'),
                             port:     get_env_or_panic!('UDF_CLUSTER_PORT'),
                             dbname:   get_env_or_panic!('UDF_CLUSTER_DB_NAME'),
                             user:     get_env_or_panic!('UDF_CLUSTER_USER'),
                             password: get_env_or_panic!('UDF_CLUSTER_PASSWORD'),
                         })
  end

  def query(str, print_errors = false)
    result = {rows: nil, error: nil}
    begin
      connect!.exec(str) do |r|
        result[:rows] = r.values
      end
    rescue => ex
      puts ex.message if print_errors
      result[:error] = ex.message
    end
    result
  end

  # --------------------------- Query Generation ------------------------------

  def make_drop_query(udf)
    "drop #{udf[:type]} #{udf[:name]}(#{udf[:params]}) cascade"
  end

  def make_create_query(udf)
    if udf[:type] == :function
      make_header(udf) + make_function_create_query(udf)
    elsif udf[:type] == :aggregate
      make_header(udf) + make_aggregate_query(udf)
    end
  end

  def make_header(udf)
    examples = make_examples(udf)
    desc     = udf[:description]
    desc     = "Aggregate helper: #{desc}" if udf[:name].to_s.start_with?('agg_')
    %~
      /*
      #{udf[:name].to_s.upcase}
      #{desc}

      Examples:
      #{examples.map { |e| '  ' + e.sub('?', udf[:name].to_s) }.join("\n#{' ' * 6}")}
      */~
  end

  def make_function_create_query(udf)
    %~
      create or replace function #{udf[:name]} (#{udf[:params]})
        returns #{udf[:return_type]}
        stable as $$
          #{udf[:body].split("\n").map { |r| r.sub(/^\s{2}/, '') }.join("\n").strip}
        $$ language plpythonu;
    ~
  end

  def make_aggregate_query(aggregate_udf)
    %~
      create aggregate #{aggregate_udf[:name]} (#{aggregate_udf[:params]})
      (
        initfunc = #{aggregate_udf[:init_function]},
        aggfunc = #{aggregate_udf[:agg_function]},
        finalizefunc = #{aggregate_udf[:finalize_function]}
      );
    ~
  end

  def make_examples(udf)
    examples = []
    udf[:tests].each do |test|
      next unless test[:example]
      expect = test[:expect]
      expect = "'#{expect}'" if expect.class == String
      if test[:query].present?
        examples << "#{test[:query]} --> #{expect}"
      elsif test[:rows].present?
        examples << "[#{test[:rows].join(", ")}] --> #{expect}"
      end
    end
    examples
  end

  # --------------------------------- Creating UDFs ----------------------------

  def create_udf(udf)
    puts "Making #{udf[:type]} #{udf[:name]}"
    drop_udf(udf, true)
    result = query(make_create_query(udf))
    puts "Error: #{result[:error]}" if result[:error].present?
  end

  def drop_udf(udf, silent = false)
    puts "Dropping #{udf[:type]} #{udf[:name]}" unless silent
    query(make_drop_query(udf))
  end

  # --------------------------------- Testing UDFs ----------------------------

  def test_udf(udf)
    print "Testing #{udf[:type]} #{udf[:name]}"
    if udf[:type] == :aggregate
      test_aggregate(udf)
    else
      test_function(udf)
    end
    print "\n"
  end

  def test_function(udf)
    udf[:tests].each do |test|
      print compare_test_results(test[:query].sub("?", udf[:name].to_s), test)
    end
  end

  def test_aggregate(aggregate_udf)
    aggregate_udf[:tests].each do |test|
      union_rows = test[:rows].map do |r|
        casted_row = r
        casted_row = "'#{r}'::varchar" if r.class == String
        casted_row = "'#{r}'::float" if r.class == Float
        "select #{casted_row} as _test_c\n"
      end
      query = %~
        with _test_t as (#{union_rows.join(' union all ')})
        select #{aggregate_udf[:name]}(_test_c) from _test_t
      ~
      print compare_test_results(query, test)
    end
  end

  def compare_test_results(q, test)
    result = query(q)
    if result[:error].present?
      return "\nError on #{test}: #{result[:error]}\n"
    elsif !test[:skip]
      result_val = result[:rows][0][0]
      result_val = result_val.to_i if test[:expect].class == Fixnum
      result_val = result_val.to_f if test[:expect].class == Float
      if result_val != test[:expect]
        return "\nMismatch on #{test}: #{result_val || 'null'} != #{test[:expect] || 'null'}\n"
      end
    end
    "."
  end
end
