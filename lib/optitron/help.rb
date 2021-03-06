class Optitron
  class Help
    def initialize(parser)
      @parser = parser
    end

    def help_line_for_opt_value(opt)
      if opt.inclusion_test
        case opt.inclusion_test
        when Array
          opt.inclusion_test.join(', ')
        else
          opt.inclusion_test.inspect
        end
      else
        opt.type.to_s.upcase
      end
    end

    def help_line_for_opt(opt)
      opt_line = ''
      opt_line << [opt.short_name ? "-#{opt.short_name}" : nil, opt.boolean? && opt.use_no ? "--(no-)#{opt.name}" : "--#{opt.name}"].compact.join('/')
      opt_line << "=[#{help_line_for_opt_value(opt)}]" unless opt.boolean?
      [opt_line, opt.desc]
    end

    def help_line_for_arg(arg)
      arg_line = ''
      arg_line << (arg.required? ? '[' : '<')
      if arg.type == :greedy
        arg_line << arg.name << '1 ' << arg.name << '2 ...' 
      else
        arg_line << arg.name
      end
      if arg.default
        arg_line << "=#{arg.default.inspect}"
      end
      if arg.type and !arg.greedy? and !arg.string?
        arg_line << "(#{arg.type.to_s.upcase})"
      end
      arg_line << (arg.required? ? ']' : '>')
      arg_line
    end

    def generate
      cmds = []
      @parser.commands.each do |(cmd_name, cmd)|
        cmd_line = "#{cmd_name}"
        cmd.args.each do |arg|
          cmd_line << " " << help_line_for_arg(arg)
        end
        cmds << [cmd_line, cmd]
        cmd.options.each do |opt|
          cmds.assoc(cmd_line) << help_line_for_opt(opt)
        end
      end
      cmds.sort!{ |cmd1, cmd2| (cmd1[1].group || '') <=> (cmd2[1].group || '') }
      opts_lines = @parser.options.map { |opt| help_line_for_opt(opt) }
      args_lines = @parser.args.empty? ? nil : [@parser.args.map{|arg| help_line_for_arg(arg)}.join(' '), @parser.args.map{|arg| arg.desc}.join(', ')]

      longest_line = 0
      longest_line = [longest_line, cmds.map{|cmd| cmd.first.size}.max].max unless cmds.empty?
      opt_lines = cmds.map{|k,v| k.size + 2}.flatten
      longest_line = [longest_line, args_lines.first.size].max if args_lines
      longest_line = [longest_line, opt_lines.max].max unless opt_lines.empty?
      longest_line = [opts_lines.map{|o| o.first.size}.max, longest_line].max unless opts_lines.empty?
      help_output = []

      last_group = nil

      unless cmds.empty?
        help_output << "Commands\n\n" + cmds.map do |(cmd, *opts)|
          cmd_text = ""
          cmd_obj = opts.shift
          if last_group != cmd_obj.group
            cmd_text << "#{cmd_obj.group}:\n"
            last_group = cmd_obj.group
          end
          cmd_text << "%-#{longest_line}s     " % cmd
          cmd_text << "# #{cmd_obj.desc}" if cmd_obj.desc
          cmd_obj.args.each do |arg|
            if arg.desc
              cmd_text << "\n%-#{longest_line}s     " % ""
              cmd_text << "#   #{arg.name} -- #{arg.desc}"
            end
          end
          opts.each do |opt|
            cmd_text << "\n  %-#{longest_line}s   " % opt.first
            cmd_text << "# #{opt.last}" if opt.last
          end
          cmd_text
        end.join("\n")
      end
      if args_lines
        arg_help = "Arguments\n\n"
        arg_help << "%-#{longest_line}s     " % args_lines.first
        arg_help << "# #{args_lines.last}" if args_lines.first
        help_output << arg_help
      end
      unless opts_lines.empty?
        help_output << "Global options\n\n" + opts_lines.map do |opt|
          opt_text = ''
          opt_text << "%-#{longest_line}s     " % opt.first
          opt_text << "# #{opt.last}" if opt.last
          opt_text
        end.join("\n")
      end
      help_output.join("\n\n")
    end
  end
end
