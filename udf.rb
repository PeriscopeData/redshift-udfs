require_relative 'udf_harness'

class Runner
  ARGS_HELP = """
    Usage:
      ruby #{__FILE__} <action> [udf_name]

    Actions:
      load    Loads UDFs into your database
      drop    Removes UDFs from your database
      test    Runs UDF unit tests on your database
      print   Pretty-print SQL for making the UDFs

    Examples:
      ruby #{__FILE__} load
      ruby #{__FILE__} drop harmonic_mean
      ruby #{__FILE__} test json_array_first
      ruby #{__FILE__} print
  """

  def self.run(args = [])
    if args.nil? or args.empty?
      puts ARGS_HELP
      exit
    end

    u = UdfHarness.new(args[1])
    case args.first.to_sym
      when :load then u.create_udfs
      when :drop then u.drop_udfs
      when :test then u.test_udfs
      when :print then u.print_udfs
      else
        puts "Args not understood, showing help instead."
        puts ARGS_HELP
        exit
    end
  end
end

Runner.run(ARGV) if __FILE__ == $PROGRAM_NAME
