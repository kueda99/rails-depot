require 'find'

namespace :file do
  desc "Erase garbage files (temp files, .DS_Store, etc.)"
  task :purge do
    regexp = %r{/(.DS_Store|.+~)$}

    c = 0    # count of deleted files
    Find.find('.') do |file|
      if regexp =~ file
        c += File.unlink(file)
      end
    end

    if c == 0
      puts "No file deleted"
    else
      puts "#{c} #{ c > 1 ? "files are" : "file is"} deleted"
    end
  end
end
