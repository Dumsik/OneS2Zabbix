#Использовать 1commands
#Использовать json

Процедура ВыполнитьКоманду(ПарсерАргументов, ЗначенияПараметров) Экспорт
	
	ПарсерАргументов = Неопределено; // чтобы linter не ругался

	Вывод = ЗапроситьRACСписокКластеров(ЗначенияПараметров);

	ТаблицаКластеров = ПодготовитьТаблицуКластеров();
	ОбщегоНазначения.ЗаполнитьТаблицуДаннымиПотока(ТаблицаКластеров, Вывод);
	СписокКластеров = ТаблицаКластеров.ВыполнитьЗапрос("SELECT cluster CLUSTERID, name CLUSTERNAME from ###");

	ИтоговыеДанныеСтрокой = СериализоватьМассивСтруктур(СписокКластеров);

	Сообщить(ИтоговыеДанныеСтрокой);
	
КонецПроцедуры

Процедура ОписаниеКоманды(ПарсерКоманднойСтроки) Экспорт
	
	ИмяКоманды = "discovery-clusters";

	Команда = ПарсерКоманднойСтроки.ОписаниеКоманды(ИмяКоманды, "Получает список кластеров");

	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-host", "адрес службы RAS (default: localhost))");
	ПарсерКоманднойСтроки.ДобавитьИменованныйПараметрКоманды(Команда, 
		"-port", "порт службы RAS (default: 1545))");

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

Функция ПодготовитьТаблицуКластеров()
	
	ОписаниеТаблицы = ОписаниеТаблицыКластеров();

	ТаблицаКластеров = Новый ХранилищеЗначений(ОписаниеТаблицы);

	Возврат ТаблицаКластеров;

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