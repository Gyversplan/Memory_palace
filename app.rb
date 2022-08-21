#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def init_db
	@db = SQLite3::Database.new 'memory_palace.db'
	@db.results_as_hash = true
end
	
	# один из главных методов в Синатре\Рельсах
	# вызывается каждый раз при перезагрузке любой
	# страницы
before do
		# Инициализация БД
	init_db	
end

	
	# второй из главных методов в Синтаре/Рельсах
	# Вызывается каждый раз при конфигурации приложения:
	# когда изменился код программы И перезагрузилась страница
configure do 

		# Инициализация БД
	init_db

		# создает таблицу если таблицы еще не существует
	@db.execute 'create table if not exists Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT
	)'

end


get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end


get '/new' do
    erb :new
end

post '/new' do 
	
		# получаем переменную из post-запроса
	content = params[:content]

	erb "You typed: #{content}"
end