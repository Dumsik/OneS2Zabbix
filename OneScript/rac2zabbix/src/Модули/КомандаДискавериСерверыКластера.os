#Использовать 1commands
#Использовать json

Процедура ВыполнитьКоманду(ПарсерАргументов, ЗначенияПараметров) Экспорт
	
	ПарсерАргументов = Неопределено; // чтобы linter не ругался

	Вывод = ЗапроситьRACСписокКластеров(ЗначенияПараметров);

	ТаблицаКластеров = ПодготовитьТаблицуКластеров();
	ОбщегоНазначения.ЗаполнитьТаблицуДаннымиПотока(ТаблицаКластеров, Вывод);
	СписокКластеров = ТаблицаКластеров.ВыполнитьЗапрос("SELECT cluster, name from ###");

	ИтоговыеДанные = Новый Массив;

	Для Каждого ТекущийКластер Из СписокКластеров Цикл
		ТаблицаИнформационныхБаз = ПодготовитьТаблицуСерверовКластера();
		Вывод = ЗапроситьRACСписокСерверовКластера(ТекущийКластер, ЗначенияПараметров);
		ОбщегоНазначения.ЗаполнитьТаблицуДаннымиПотока(ТаблицаИнформационныхБаз, Вывод);
		СписокБаз = ТаблицаИнформационныхБаз.ВыполнитьЗапрос(
			"SELECT '' CLUSTERNAME, '' CLUSTERID, server SERVERID, agent_host AGENTHOST, name SERVERNAME from ###");
		Для Каждого БазаДанных Из СписокБаз Цикл
			БазаДанных.CLUSTERNAME = ТекущийКластер.name;
			БазаДанных.CLUSTERID = ТекущийКластер.cluster;
			ИтоговыеДанные.Добавить(БазаДанных);
		КонецЦикла;
	КонецЦикла;

	ИтоговыеДанныеСтрокой = СериализоватьМассивСтруктур(ИтоговыеДанные);

	Сообщить(ИтоговыеДанныеСтрокой);
	
КонецПроцедуры

Процедура ОписаниеКоманды(ПарсерКоманднойСтроки) Экспорт
	
	ИмяКоманды = "discovery-cluster-servers";

	Команда = ПарсерКоманднойСтроки.ОписаниеКоманды(ИмяКоманды, "Получает список серверов, принадлежащих кластеру");

	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-host", "адрес службы RAS (default: localhost))");
	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-port", "порт службы RAS (default: 1545))");
	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-user", "пользователь администратор кластера серверов");
	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-password", "пароль пользователя администратора кластера серверов");

	ПарсерКоманднойСтроки.ДобавитьКоманду(Команда);
	
КонецПроцедуры

Функция ЗапроситьRACСписокКластеров(ЗначенияПараметров)
	
	ПутьКRAC = ОбщегоНазначения.ПутьКRAC("8.3");
	Хост = ЗначенияПараметров.Получить("-host");
	Порт = ЗначенияПараметров.Получить("-port");
	
	СтрокаЗапуска = СтрШаблон("""%1"" %2:%3 cluster list", ПутьКRAC, Хост, Порт);
	
	Команда = Новый Команда;
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	Команда.УстановитьСтрокуЗапуска(ОбщегоНазначения.UTF8(СтрокаЗапуска));
	Команда.УстановитьКодировкуВывода(КодировкаТекста.UTF8);

	КодВозврата = Команда.Исполнить();
	Вывод = СокрЛП(Команда.ПолучитьВывод());

	Если КодВозврата <> 0 Тогда
		ВызватьИсключение Вывод;
	КонецЕсли;

	Возврат Вывод;

КонецФункции

Функция ЗапроситьRACСписокСерверовКластера(ТекущийКластер, ЗначенияПараметров)

	ПутьКRAC = ОбщегоНазначения.ПутьКRAC("8.3");
	Хост = ЗначенияПараметров.Получить("-host");
	Порт = ЗначенияПараметров.Получить("-port");
	Пользователь = ЗначенияПараметров.Получить("-user");
	Пароль = ЗначенияПараметров.Получить("-password");
	
	СтрокаЗапуска = СтрШаблон("""%1"" %2:%3 server list --cluster=%4 --cluster-user=%5 --cluster-pwd=%6",
		ПутьКRAC, Хост, Порт, ТекущийКластер.cluster, Пользователь, Пароль);
	
	Команда = Новый Команда;
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	Команда.УстановитьСтрокуЗапуска(ОбщегоНазначения.UTF8(СтрокаЗапуска));
	Команда.УстановитьКодировкуВывода(КодировкаТекста.UTF8);
	
	КодВозврата = Команда.Исполнить();
	Вывод = СокрЛП(Команда.ПолучитьВывод());

	Если КодВозврата <> 0 Тогда
		ВызватьИсключение Вывод;
	КонецЕсли;

	Возврат Вывод;
	
КонецФункции

Функция ПодготовитьТаблицуКластеров()
	
	ОписаниеТаблицы = ОписаниеТаблицыКластеров();

	ТаблицаКластеров = Новый ХранилищеЗначений(ОписаниеТаблицы);

	Возврат ТаблицаКластеров;

КонецФункции

Функция ПодготовитьТаблицуСерверовКластера()

	ОписаниеТаблицы = ОписаниеТаблицыСерверовКластера();

	ТаблицаСерверов = Новый ХранилищеЗначений(ОписаниеТаблицы);

	Возврат ТаблицаСерверов;
	
КонецФункции

Функция ОписаниеТаблицыКластеров()
	
	ОписаниеТаблицы = Новый Массив;

	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "cluster", "TEXT DEFAULT('')"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "host", "TEXT DEFAULT('')"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "port", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "name", "TEXT DEFAULT('')"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "expiration_timeout", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "lifetime_limit", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "max_memory_size", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "max_memory_time_limit", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "security_level", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "session_fault_tolerance_level", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "load_balancing_mode", "TEXT DEFAULT('')"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "errors_count_threshold", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "kill_problem_processes", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "kill_by_memory_with_dump", "INTEGER DEFAULT(0)"));

	Возврат ОписаниеТаблицы;

КонецФункции

Функция ОписаниеТаблицыСерверовКластера()

	ОписаниеТаблицы = Новый Массив;

	// в описангии не хватает поля using, Sqlite падает при создании таблицы 
	// с полем using, т.к. это зарезервированное слово. Пришлось его исключить
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "server", "TEXT DEFAULT('')"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "agent_host", "TEXT DEFAULT('')"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "agent_port", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "port_range", "TEXT DEFAULT('')"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "name", "TEXT DEFAULT('')"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "dedicate_managers", "TEXT DEFAULT('')"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "infobases_limit", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "memory_limit", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "connections_limit", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "safe_working_processes_memory_limit", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "safe_call_memory_limit", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "cluster_port", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "critical_total_memory", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "temporary_allowed_total_memory", "INTEGER DEFAULT(0)"));
	ОписаниеТаблицы.Добавить(Новый Структура("Имя, Тип", "temporary_allowed_total_memory_time_limit", "INTEGER DEFAULT(0)"));
	Возврат ОписаниеТаблицы;
	
КонецФункции

Функция СериализоватьМассивСтруктур(КоллекцияДанных)

	СтруктурыСтрокой = Новый Массив;

	Для каждого ТекущаяСтрока Из КоллекцияДанных Цикл

		МассивЭлементов = Новый Массив;

		Для Каждого КлючЗначение Из ТекущаяСтрока Цикл
			МассивЭлементов.Добавить(СтрШаблон("""{#%1}"" :""%2""", КлючЗначение.Ключ, КлючЗначение.Значение));
		КонецЦикла;

		СтруктурыСтрокой.Добавить(СтрШаблон("{ %1 }", СтрСоединить(МассивЭлементов, ",")));
		
	КонецЦикла;

	РезультатСтрокой = СтрШаблон("{ ""data"": [ %1 ] }", СтрСоединить(СтруктурыСтрокой, ","));

	Возврат РезультатСтрокой;
	
КонецФункции