require 'sinatra'
require 'pg'
# require 'pry'


def db_connection
  begin
    connection = PG.connect(dbname: "quotes")
    yield(connection)
  ensure
    connection.close
  end
end

db_connection { |conn| conn.exec("INSERT INTO quotes (quote) VALUES ($1)", ["It's not THAT bad"]) }


get '/' do
  redirect '/splatme'
end

get '/quoteme' do

  erb :new
end

post '/quoteme' do
  quoter = params['quoter']
  if quoter != ''
    db_connection { |conn| conn.exec_params("INSERT INTO quotes (quote) VALUES ($1)", [params["quoter"]]) }
  end
  redirect '/splatme'

end


get '/splatme' do
  quote_list = db_connection { |conn| conn.exec("SELECT quote FROM quotes;") }
  quote_length_hash = db_connection { |conn| conn.exec("SELECT COUNT(*) FROM quotes;")}
  quote_length = quote_length_hash[0]["count"]
  quote = quote_list.to_a.sample["quote"]
  erb :view,  locals: {quote: quote}

end
