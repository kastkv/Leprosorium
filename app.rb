# encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' # чтобы не перезапускать sinatra каждый раз
require 'sqlite3'

def init_db #сделаем специлаьную процедуру для инициализации глобальной переменной, почему специальной, потому что будем использовать в конфигурациии приложения
	@db = SQLite3::Database.new 'leprosorium.db' #SQLite3 обращается к пространству имен из модуля require 'sqlite3', в этом модуле сеществует класс Database, в котором есть метод .new и он принимает 1 параметр - имя нашей БД 'leprosorium.db'. Инициализация БД
	@db.results_as_hash = true # задаим свойство, чтобы наши результаты возвращались в виде хеша, а не в виде массива, потому что так будет удобней к ним обращаться (не обязательно). Проверем что это раьботает перейдя куда-нибудь по закладкам, что не выдает ошибок.
end	

#before вызывается каждый раз при перезагрузке любой страницы (чтобы не писать в каждом виде - удобно)
before do # выполняется каждый раз перед выполнением запроса
	init_db #Инициализация БД
end

#метод configure вызывается каждый раз при инициализации приложения. Инициализации происходит тогда, когда мы сохраняем файл, появляются каккие то изменения и когда мы обновляем страницу
configure do 
	#инициализация БД
	init_db #затем что метод before не исполняется при конфигурации
	# создаем нашу таблицу(через SQLiteManager), если таблица не существует и причесываем. Добавляем еще параметр IF NOT EXISTS чтобы БД каждый раз не пересоздавалась
	# ошибка была internal server error invalid byte sequence in US-ASCII из-за db.execute(не была глобальной)
	@db.execute 'CREATE TABLE if not exists Posts 
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		create_date DATE,
		content TEXT
	)'  # ; не обязательно, т.к. execute подразумевает, что будет выполнена 1 команда

	# создаем нашу таблицу Comments
	@db.execute 'CREATE TABLE if not exists Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		create_date DATE,
		content TEXT
		post_id Integer
	)'  # добавим еще одно поле, которое будет содержать идентификатор поста
	# Проблема в том что таблица Comments есть и post_id не добавится. Для этого есть миграция в Rails(она бы автоматически исполнилась, но это позже. Из консоли удалим таблицу drop table Comments; и сейчас она будет создана заново и будет наш post_id
end	

get '/' do
	# выбираем список постов из БД (в обратном порядке)
	@results = @db.execute 'select * from Posts order by id desc'

	erb  :index			
end

# get '/New' do   #добавляем обработчик
#  erb "Hello World" # чтобы выводился с нашим шаблоном пишем erb
# end

# обрабботчик get- запроса new
# (браузер получает страницу с сервера)

get '/New' do   
 erb :new
end

# обработчик post-запроса new
# (браузер отправляет данные на сервер)

post '/new' do #отправляем post запрос
	# получаем переменную из post-запроса
	content = params[:content] # переменной content присваем значение textarea(отправляем ее), обращаемся к переменно по имени name="content"

	if content.length <= 0         #проверка на ошибки         
		@error = 'Type post text'  #если ничего не ввели выдаст ошибку
 		return erb :new      	   # и вернет наше представление	
	end	

	 #cохранение данных в БД со страницы (ошибка с кодировкой!)
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]
	 #обращаемся к БД (функция execute может принимать 2 параметра), затем добавление в табилцу (datetime()- вставит текущее время)
	

	#erb "You typed: #{content}" #выводим, что мы ввели(т.е. мы обращаемся к конкретной переменной)
	# переменной content не нужно глобального вида - @content, так как мы не обращаемся из нашего вида

	# перенаправление на главную страницу(после введеннго поста)
	redirect to '/'
end	
 
# вывод информации о посте

get '/details/:post_id' do  # универсальный обработчик для всех постов с любым значением, которое мы омжем задать
	
	# получаем переменную из url`a
	post_id = params[:post_id] # просто получаем параметр из url

	# получаем список постов
	# (у нас будет только один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id] # мы вибираем все посты с id, который будем передовать(т.к. id у нас уникальный будет выбираться 1 пост)
	
	# выбираем комментарии для нашего поста
	@comments = @db.execute 'select * from Posts where id = ? order by id', [post_id]

	# выбираем этот один пост в переменную @row
	@row = results[0] # у нас будет 1 строка с индексом 0

	# возвращаем представление datails.erb
	erb :details

end	

# добавим post-обработчик для нашего url (/details/...)
# (браузер отправляет данные на сервер, мы их принимаем)
post '/details/:post_id' do 
	# получаем переменную из url`a
	post_id = params[:post_id] # просто получаем параметр из url

	# получаем переменную из post-запроса
	content = params[:content] # переменной content присваем значение textarea(отправляем ее), обращаемся к переменно по имени name="content"

	#cохранение данных в БД со страницы (ошибка с кодировкой!)
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
	)', [content, post_id] # в created_date вставляется datetime(), остальное берется из массива(сколько знаков вопросов столько и элементов в нашем массиве)

	#erb "You typed comment #{content} for post #{post_id}"

	# перенаправляем на страницу поста
	redirect to('/details/' + post_id)

end	