require 'tty-prompt'
require 'csv'
require 'tty-table'

# Class to manage interaction with the user
class CSVApp
  def initialize(path)
    @path = path
    @prompt = TTY::Prompt.new
    @fetcher = CSVFetcher.new(path)
  end

  def run
    csv_files = @fetcher.fetch_csv_files

    if csv_files.empty?
      puts "No CSV files found in #{@path}"
      return
    end

    selected_file = @prompt.select("Choose a CSV file to display:", csv_files)
    display_csv(selected_file)
  end

  private

  def display_csv(file)
    csv_data = CSVHandler.read_file(File.join(@path, file))
    CSVDisplay.show_table(csv_data)
  end
end

# Class to handle fetching CSV files from the directory
class CSVFetcher
  def initialize(path)
    @path = path
  end

  def fetch_csv_files
    Dir.glob(File.join(@path, '*.csv')).map { |file| File.basename(file) }
  end
end

# Class responsible for handling CSV file reading logic
class CSVHandler
  def self.read_file(file_path)
    # Read the file with binary encoding to detect the original encoding
    file_content = File.read(file_path, mode: 'rb')

    # Convert to UTF-8 (if needed) assuming the file is in Windows-1252
    utf8_content = file_content.encode('UTF-8', 'Windows-1252', invalid: :replace, undef: :replace, replace: '')

  
    data = CSV.parse(utf8_content, headers: true)
    headers = data.headers
    rows = data.map(&:to_hash)
    { headers: headers, rows: rows }
  end
end


class CSVDisplay
  def self.show_table(csv_data)
    # Create a TTY Table
    table = TTY::Table.new(header: csv_data[:headers], rows: csv_data[:rows].map(&:values))

    puts table.render(:unicode, padding: [0, 1])  
  end
end

app = CSVApp.new('C:/Users/Easy Life/Desktop/New folder (11)') 
app.run
