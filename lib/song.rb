class Song

  attr_accessor :name, :album, :id

  @@all = []

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
    @@all << self
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  #CReate a method that will convert the databse output into a Ruby object
  def self.new_from_db(row)

    #self.new is the equivalent to song.new This is not for records creation but reading data from SQLite and representing that temporarily in Ruby
    self.new(id: row[0], name: row[1], album: row[2])
  end

  def self.all

    sql=<<-SQL

    SELECT * FROM  songs
    SQL

    #This will retrun an array of rows from the db that matches our query. All we have to do is iterate over each row and then use the self.map method to create a new ruby object for each row.
    DB[:conn].execute(sql).map do |row|


      self.new_from_db(row)
    end
  end

  # Essentially we can also find the song by name
  def self.find_by_name(name)
    sql = <<-SQL

    SELECT * FROM songs WHERE name = ? LIMIT 1

    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
    # The end.first method simply grabs the first element of the returned array

    #This will return a single row from the db that matches our query.
  end

end

# We don't store ruby objects in the database and we do not get ruby objects from the database.
# we store raw data describing a given ruby object in a table row 
# When querying a database we write code that takes the data and turns it back into an instance of the appropriate class. It is the work of the programmer to translate the raw data that the database sends into a ruby object that has instances of that particular class. 

