Процедура ВыполнитьКоманду(ПарсерАргументов, ЗначенияПараметров) Экспорт

	ПарсерАргументов = Неопределено;

	Хост = ЗначенияПараметров.Получить("-host");
	БазаДанных = ЗначенияПараметров.Получить("-db");
	Пользователь = ЗначенияПараметров.Получить("-user");
	Пароль = ЗначенияПараметров.Получить("-password");
	Таймаут = ЗначенияПараметров.Получить("-timeout");

	ПараметрыКоманды = Новый Структура;
	ПараметрыКоманды.Вставить("Хост", Хост);
	ПараметрыКоманды.Вставить("База", БазаДанных);
	ПараметрыКоманды.Вставить("Пользователь", Пользователь);
	ПараметрыКоманды.Вставить("Пароль", Пароль);
	ПараметрыКоманды.Вставить("Таймаут", ?(ЗначениеЗаполнено(Таймаут), Таймаут, 30));

	Попытка
		ВыполнитьКомандуПинг(ПараметрыКоманды);
	Исключение
		Сообщить(ОбщегоНазначения.СформироватьТексОшибкиJSON(ОписаниеОшибки()));
	КонецПопытки;

КонецПроцедуры

Процедура ОписаниеКоманды(ПарсерКоманднойСтроки) Экспорт
	
	ИмяКоманды = "ping";

	Команда = ПарсерКоманднойСтроки.ОписаниеКоманды(ИмяКоманды, "Вызов удаленной процедуры по HTTP");

	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-host", "адрес http сервиса");
	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-db", "база данных 1С");
	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-user", "имя пользователя");
	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-password", "пароль пользователя");
	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-timeout", "таймаут http запросов. 30 сек по умолчанию");

	ПарсерКоманднойСтроки.ДобавитьКоманду(Команда);
	
КонецПроцедуры

Процедура ВыполнитьКомандуПинг(Параметры)
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-type", "Text/plain");

	АдресРесурса = СтрШаблон("%1/hs/zabbix/ping", Параметры.База);
	Запрос = Новый HTTPЗапрос(АдресРесурса, Заголовки);

	Хост = Параметры.Хост;
	ПротоколHTTP = ВРег(Лев(Хост, 7)) = "HTTP://";
	ПротоколHTTPS = ВРег(Лев(Хост, 8)) = "HTTPS://";
	ПротоколУказан = ПротоколHTTP ИЛИ ПротоколHTTPS;
	Если НЕ ПротоколУказан Тогда
		Хост = СтрШаблон("https://%1", Хост);
	КонецЕсли;

	Соединение = Новый HTTPСоединение(Хост, , Параметры.Пользователь, Параметры.Пароль, , Параметры.Таймаут);

	Ответ = Соединение.Получить(Запрос);
	Если Ответ.КодСостояния <> 200 Тогда
		ВызватьИсключение СтрШаблон("код состояния %1: %2", Ответ.КодСостояния, Ответ.ПолучитьТелоКакСтроку());
	КонецЕсли;

	Сообщить(Ответ.ПолучитьТелоКакСтроку());	
	
КонецПроцедуры