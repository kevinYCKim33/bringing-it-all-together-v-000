require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id # shouldn't this be an accessor?

  def initialize(id: nil, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name: name, breed: breed)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(dog_id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    id, name, breed = DB[:conn].execute(sql, dog_id).first
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by(name: name, breed: breed)
    sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    if dog.empty?
      self.create(name: name, breed: breed)
    else
      id, name, breed = dog[0]
      self.new(id: id, name: name, breed: breed)
    end
  end

  def self.find_by_name(dog_name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    id, name, breed = DB[:conn].execute(sql, dog_name).first
    self.new(id: id, name: name, breed: breed)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(row) # [1, "Pat", "poodle"]
    self.new(id:row[0],name:row[1], breed:row[2])
  end

end
