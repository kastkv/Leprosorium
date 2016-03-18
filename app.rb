require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' # чтобы не перезапускать sinatra каждый раз
require 'sqlite3'

def init_db #сделаем специлаьную процедуру для инициализации глобальной переменной, почему специальной, потому что будем использовать в конфигурациии приложения
	@db = SQLite3::Database.new 'leprosorium.db' #SQLite3 обращается к пространству имен из модуля require 'sqlite3', в этом модуле сеществует класс Database, в котором есть метод .new и он принимает 1 параметр - имя нашей БД 'leprosorium.db'. Инициализация БД
	@db.results_as_hash = true # задаим свойство, чтобы наши результаты возвращались в виде хеша, а не в виде массива, потому что так будет удобней к ним обращаться (не обязательно). Проверем что это раьботает перейдя куда-нибудь по закладкам, что не выдает ошибок.
end	

#before вызывается каждый раз при перезагрузке любой страницы
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

end	

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
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

	erb "You typed: #{content}" #выводим, сто мы ввели(т.е. мы обращаемся к конкретной переменной)
	# переменной content не нужно глобального вида - @content, так как мы не обращаемся из нашего вида
end	