class Document
  include DataMapper::Resource
  property :id,         Serial
  property :user_id,    Integer
  property :path,       String
  property :slug,       String
  property :type,       String
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user

  attr_accessor :user_name

  def path= new_path
    @path = new_path.sub /^\//, ''

    user_name, *middle, filename = @path.split '/'

    filename ||= user_name
    self.type = File.extname(filename)[1 .. -1] || 'html'
    @path.sub! /\.html$/, ''

    self.user = User.first(name: user_name.downcase)
    self.user_name = user_name if user.nil?

    self.slug = filename.sub(/\.#{ type }$/, '')
    self[:path] = @path

    path
  end

  def title
    @title ||= @path.split('/').last
  end

  def filename
    @filename ||= "#{ slug }.#{ type }"
  end

  def self.write path, contents
    ::PutHTML::Bucket.objects[path].write contents, acl: :authenticated_read
    zadd_params = [Time.now.to_i, path.sub(/\.html$/, '')]
    ::PutHTML::REDIS.zadd 'documents', zadd_params
    ::PutHTML::REDIS.zadd "documents.#{ path.split('/').first }", zadd_params
  end
end
