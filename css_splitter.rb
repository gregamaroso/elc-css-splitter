class CssSplitter

  def self.split(infile, outdir = File.dirname(infile), max_selectors = 4095)

    raise "infile could not be found" unless File.exists? infile

    # Gather all of the rules
    rules = IO.readlines(infile, "}")
    return if rules.first.nil?

    # @TODO: figure out how to extrac the charset and store it in the charset_statement variable
    # charset_statement, rules[0] = rules.first.partition(/^\@charset[^;]+;/)[1,2]
    # charset_statement = rules.first.partition(/^\@charset[^;]+;/)[1,2]
    charset_statement = nil
    return if rules.nil?

    # The infile remains the first file
    file_id = 1
    selectors_count = 0

    # Store the full file path to all split files
    all_files = Array.new

    # Create the first split file
    # base_filename
    base_filename = create_filename(infile, file_id)
    filename = File.join(outdir, base_filename)
    all_files.push(base_filename)

    output = File.new(filename, "w")
    output.write charset_statement

    rules.each do |rule|
      rule_selectors_count = count_selectors_of_rule rule
      selectors_count += rule_selectors_count

      # Nothing happens until the selectors limit is reached for the first time
      if selectors_count > max_selectors
        # Close current file if there is already one
        output.close if output

        # Prepare next file
        file_id += 1
        base_filename = create_filename(infile, file_id)
        filename = File.join(outdir, base_filename)
        all_files.push(base_filename)

        # Create the new file, and add some content
        output = File.new(filename, "w")
        output.write charset_statement

        # Reset count with current rule count
        selectors_count = rule_selectors_count
      end

      output.write rule if output
    end

    # ------------------------------
    # @TODO: validate css files here
    # all_files.each do |split_file|
    #   <validate code>
    # end
    # ------------------------------
  end

  def self.count_selectors(css_file)
    raise "file could not be found" unless File.exists? css_file

    rules = IO.readlines(css_file, '}')
    return if rules.first.nil?

    charset_statement, rules[0] = rules.first.partition(/^\@charset[^;]+;/)[1,2]
    return if rules.first.nil?

    rules.inject(0) {|count, rule| count + count_selectors_of_rule(rule)}.tap do |result|
      # puts File.basename(css_file) + " contains #{result} selectors."
    end
  end

  def self.count_selectors_of_rule(rule)
    rule.partition(/\{/).first.scan(/,/).count.to_i + 1
  end

  def self.create_filename(infile, index)
    File.basename(infile, File.extname(infile)) + "_#{index.to_s}" + File.extname(infile)
  end

end
