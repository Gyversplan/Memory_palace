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

	# создает таблицу если таблицы еще не существует
	@db.execute 'create table if not exists Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id integer
	)'

end


get '/' do
		# выбираем список постов из БД

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

	# обработчик get-запроса /new
	# (браузер получает страницу с сервера)
get '/new' do
    erb :new
end

	# обработчик post-запроса /new
	# (браузер отправляет данные на сервер)
post '/new' do 
	
		# получаем переменную из post-запроса
	content = params[:content]

		# предусмотрим ошибку когда пользователь публикует пустой пост
	if content.length < 1
			@error = 'Введите текст'
			return erb :new
	end

		# сохраняем в БД публикуемый пост пользователя
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	redirect to '/'
end

	# вывод информации о посте
get '/details/:post_id' do
	
			# получаем переменную из урл-а
	post_id = params[:post_id]


			# получаем список постов
			# (у нас будет только один пост)
	results = @db.execute 'select * from Posts where id= ?', [post_id]
	
			# выбираем этот один пост в переменную @row
	@row = results[0]

			# выбираем комментарии для нашего поста

	@comments = @db.execute 'select * from Comments where post_id= ? order by id', [post_id]

			# возвращаем представление details.erb
	erb :details
end


		# обработчик post-запроса /details/...
		# (браузер отправляет данные на сервер, мы их принимаем)
post '/details/:post_id' do

		# получае переменную из url'а
	post_id = params[:post_id]

 		# получаем переменную из post-запроса
	content = params[:content]


	# сохраняем в БД коммент к посту 
	@db.execute 'insert into Comments 
		(
			content, 
			created_date,
			post_id
		) 
			values 
		(
			?, 
			datetime(),
			?

		)', [content, post_id]

		# перенаправление на страницу поста
	redirect to ('/details/' + post_id)

	# erb "You typed comment '#{content}' for post # #{post_id}"

end