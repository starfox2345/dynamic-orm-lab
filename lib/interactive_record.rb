require_relative "../config/environment.rb"
require 'active_support/inflector'
#DB[:conn].execute(sql)
#DB[:conn].results_as_hash = true

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize # pluralize makes the content plural
  end

  def self.column_names

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    table_info.map { |column_info| column_info['name'] }.compact
    # column_names = []

    # table_info.each do |row|
    #     column_names << row["name"]
    
    # column_names.compact #.compact removes all nil
  end

  def initialize(options={})
    options.each do |key, value|
        self.send("#{key}=", value) if respond_to?("#{key}=")
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ") #.join eliminates the []
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s} = '#{hash.values[0].to_s}'"
    DB[:conn].execute(sql)
  end

end