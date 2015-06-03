require 'sinatra'
require 'pg'
# require 'pry'


def db_connection
  connection_settings = { dbname: ENV["DATABASE_NAME"] || "quotes" }

  if ENV["DATABASE_HOST"]
    connection_settings[:host] = ENV["DATABASE_HOST"]
  end

  if ENV["DATABASE_USER"]
    connection_settings[:user] = ENV["DATABASE_USER"]
  end

  if ENV["DATABASE_PASS"]
    connection_settings[:password] = ENV["DATABASE_PASS"]
  end

  begin
    connection = PG.connect(connection_settings)
    yield(connection)
  ensure
    connection.close
  end
end




get '/' do
  redirect '/splatme'
end

get '/quoteme' do
  title = "Quote me"
  erb :new, locals: {title: title}
end

get '/error' do
  title = "Quote me"
  erb :error, locals: {title: title}
end

post '/quoteme' do
  quoter = params['quoter']
  if /<.+>/.match(quoter)
    redirect '/error'
  elsif (quoter == nil) || (quoter.delete(' ') == '')
    redirect '/error'
  else
    db_connection { |conn| conn.exec_params("INSERT INTO quotes (quote) VALUES ($1)", [params["quoter"]]) }
    redirect '/splatme'
  end
end

get '/alltheinspiration' do
  title = "All the Inspiration"
  quote_list = db_connection { |conn| conn.exec("SELECT quote FROM quotes;") }
  erb :viewall, locals: {quote_list: quote_list, title: title}
end

get '/splatme' do
  title = "Give me a quote"
  quote_list = db_connection { |conn| conn.exec("SELECT quote FROM quotes;") }
  quote_length_hash = db_connection { |conn| conn.exec("SELECT COUNT(*) FROM quotes;")}
  quote_length = quote_length_hash[0]["count"]
  quote = quote_list.to_a.sample["quote"]
  erb :view,  locals: {quote: quote, title: title}

end
