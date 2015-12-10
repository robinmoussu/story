#! /usr/bin/env ruby

# get all the filenames
def get_all_filename(filename)
    files = [filename]
    File.open(filename, "r") do |f|
        while (line = f.gets)

            # search the beginning of the document first
            found_begin = true if /\\begin\{document\}/ =~ line

            if ( found_begin ) then
                new_file = /\\input\{(.+)\}/.match(line)
                if new_file then
                    if /\.tex$/.match(new_file[1]) then
                        files += [new_file[1]]
                    else
                        $stderr.puts "invalid input ignored: #{new_file}"
                    end
                end
            end

        end
    end

    return files
end

def remove_prefix(filename)
    filename.sub(/.*\//,'')
end

def generate_header(main_document)
    name = remove_prefix(main_document.sub(".tex",""))
    $stdout.puts "digraph graph_#{name} {"
    $stdout.puts "    compound = true;"
end

def generate_footer(main_document)
    $stdout.puts "}"
end

def generate_subgraph(filename, section)
    name = remove_prefix(filename.sub(".tex",""))
    $stdout.puts "    subgraph cluster_#{name} {"
    $stdout.puts "        label = \"#{remove_prefix(filename)}\";"

    section.each do |s|
        $stdout.puts "        #{s};"
    end

    $stdout.puts "    }"
end

def generate_relations(graph)
    $stdout.puts
    graph.each do |g|
        $stdout.puts "    #{g[0]} -> #{g[1]};"
    end
end

def get_graph(main_document, filenames)
    graph = Array.new
    if tmp = /.*\//.match(main_document) then
        prefix = tmp[0]
    else
        prefix = ""
    end

    generate_header(main_document)

    filenames.each do |file|
        file = prefix + file unless File.file?(file)
        $stderr.puts "read #{file}" if $verbose

        current_sections = Array.new
        File.open(file,"r") do |f|
            while (line = f.gets)

                #search section
                if new_section = /\\section\{(\w+)\}/.match(line) then
                    current_section = new_section[1]
                    current_sections += [new_section[1]]
                end

                #... and search references
                if new_ref = /\\ref\{(\w+)\}/.match(line) then
                    graph += [[current_section, new_ref[1]]]
                end
            end
        end

        $stderr.puts "section found in #{file}: #{current_sections}" if $verbose
        generate_subgraph(file, current_sections) if current_sections != []
    end

    #add extra input
    $stdout.puts $stdin.read

    generate_relations(graph)
    generate_footer(main_document)
end

def usage()
    $stdout.puts "usage: ./autograph.rb main_document.tex output.dot <extra_input"
    $stdout.puts "-v --verbose: add debug informations"
    $stdout.puts "-h --help: display that help"
    $stdout.puts
    $stdout.puts "Short options must be separated"
    $stdout.puts "Tex file must be in the current folder, or in the same folder as"
    $stdout.puts "main_document.tex"
    $stdout.puts "The content of stdin will be copied after the digraph declaration, so you can"
    $stdout.puts "add extra informations"
    $stdout.puts
    $stdout.puts "Ex: $ echo 'start [shape = Mdiamond];'"
    $stdout.puts "        | ./autograph.rb source/main_document.tex"
    $stdout.puts "        | dot -Tpng"
    $stdout.puts "        | feh -"
    exit 1
end

def main()
    nb_arguments = ARGV.size

    ARGV.each do |arg|
        if arg =~ /-?-h(elp)?/ then
            nb_arguments -= 1
            usage()
        end

        if arg =~ /-?-v(erbose)?/ then
            nb_arguments -= 1
            $verbose = true
        end
    end

    if nb_arguments != 1 then
        $stdout.puts "wrong number of arguments: #{ARGV.size} instead of 1"
        usage()
    end

    main_document = ARGV[0]

    # get the filename of all tex file
    files = get_all_filename(main_document)
    $stderr.puts "tex files found: #{files}" if $verbose

    # generate the graph from sections and references
    get_graph(main_document, files)

    exit 0
end

main
