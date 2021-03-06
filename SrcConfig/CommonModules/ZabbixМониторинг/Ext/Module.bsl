//Для необходимо наличие БСП

#Область ПрограммныйИнтерфейс

Функция ПолучитьZabbixМониторинг(ЭлементДанных) Экспорт
	
	ОбработкаМониторинга = Обработки.ZabbixМониторинг.Создать();
	ОбработкаМониторинга.Инициализировать(ЭлементДанных);
	
	Возврат ОбработкаМониторинга;
		
КонецФункции

Функция ЭлементДанныхДляОтправкиСостоянияОбменаЧерезКонвертацию(ПрефиксИБ, ИдентификаторУзла, НаправлениеОбмена) Экспорт
	
	ШаблонИмени = ШаблонИмениЭлементаДанныхДляОтравкиСостоянияОбменаЧерезКонвертацию();
	
	Результат = СтрШаблон(ШаблонИмени, ПрефиксИБ, ИдентификаторУзла, НаправлениеОбмена);
	
	Возврат Результат;
	
КонецФункции

Процедура ZabbixTrapОбнаружение() Экспорт
	
	ОбменыДанными = НоваяТаблицаОбменыДанными();
	
	ДанныеДляАвтообнаруженияОбменовДанными(ОбменыДанными);
	
	Если ОбменыДанными.Количество() Тогда
		
		ДанныеDiscoveryData = DiscoveryDataПоТаблицеЗначений(ОбменыДанными);
	
		ЭлементДанныхДляDiscoveryОбменаДаннымиЧерезКонвертацию = ЭлементДанныхДляDiscoveryОбменаДаннымиЧерезКонвертацию();
	
		Мониторинг = ПолучитьZabbixМониторинг(ЭлементДанныхДляDiscoveryОбменаДаннымиЧерезКонвертацию);
	
		Мониторинг.ОтправитьПроизвольныеДанные(ДанныеDiscoveryData);
		
	КонецЕсли; 
	
КонецПроцедуры

#КонецОбласти

#Область Мониторинг

Функция МинимальнаяДатаИтоговРегистровНакопленияИБухгалтерии() Экспорт
	
	КоллекцияМетаданных = Метаданные.РегистрыБухгалтерии;
	
	РегистрыДляПолученияИтогов = Новый Массив;
	
	Для каждого Регистр Из КоллекцияМетаданных Цикл
		РегистрыДляПолученияИтогов.Добавить("РегистрБухгалтерииМенеджер." + Регистр.Имя);
	КонецЦикла; 
	
	КоллекцияМетаданных = Метаданные.РегистрыНакопления;
	
	Для каждого Регистр Из КоллекцияМетаданных Цикл
		Если Регистр.ВидРегистра = Метаданные.СвойстваОбъектов.ВидРегистраНакопления.Остатки Тогда
			РегистрыДляПолученияИтогов.Добавить("РегистрНакопленияМенеджер." + Регистр.Имя);
		КонецЕсли; 
	КонецЦикла;
	
	
	МинимальнаяДата = Неопределено;
	
	Для каждого Регистр Из РегистрыДляПолученияИтогов Цикл
		
		МенеджерРегистра = Новый (Регистр);
		
		Если МинимальнаяДата <> Неопределено Тогда			
			МинимальнаяДата = Мин(МинимальнаяДата, МенеджерРегистра.ПолучитьМаксимальныйПериодРассчитанныхИтогов()); 	
		Иначе
			МинимальнаяДата = МенеджерРегистра.ПолучитьМаксимальныйПериодРассчитанныхИтогов();	
		КонецЕсли; 			
		
	КонецЦикла;
	
	Возврат МинимальнаяДата;
	
КонецФункции
 
#КонецОбласти 


#Область СлужебныеПроцедурыИФункции

//По переданной таблице значений возвращает 
//строку с данными в формате для Zabbix Discovery 
Функция DiscoveryDataПоТаблицеЗначений(Данные)
	
	ШаблонСтроки = """{#%1}"" :""%2""";
	
	ДанныеВсехСтрок = Новый Массив;
	
	Для каждого Строка Из Данные Цикл
		
		ДанныеСтроки = Новый Массив;		
		
		КолонкиТаблицы = Данные.Колонки;
		
		Для каждого Колонка Из КолонкиТаблицы Цикл
			ЗначениеКолонки = СтрШаблон(ШаблонСтроки, ВРЕГ(Колонка.Имя), Строка.Получить(КолонкиТаблицы.Индекс(Колонка)));
			ДанныеСтроки.Добавить(ЗначениеКолонки);
		КонецЦикла;
		
		ЗначениеСтроки = "{ " + СтрСоединить(ДанныеСтроки, ",") + " }";
		
		ДанныеВсехСтрок.Добавить(ЗначениеСтроки);
		
	КонецЦикла; 

	ЗначениеВсехСтрок =  "[ " + СтрСоединить(ДанныеВсехСтрок, ",") + " ]";
	
	ЗначениеВсехСтрок = "{ ""data"": " + ЗначениеВсехСтрок + " }";
	
	Возврат ЗначениеВсехСтрок;
	
КонецФункции

Функция ЭлементДанныхДляDiscoveryОбменаДаннымиЧерезКонвертацию()
	
	Возврат "1c.convertation.autoexchange.discovery";
		
КонецФункции

Функция ШаблонИмениЭлементаДанныхДляОтравкиСостоянияОбменаЧерезКонвертацию()
	
	Возврат "1c.convertation.autoexchange[%1,%2,%3]";
		
КонецФункции

Процедура ДанныеДляАвтообнаруженияОбменовДанными(Данные)
	
	ПрефиксИБ = ОбменДаннымиСервер.ПрефиксИнформационнойБазы();
	
	ПланыОбменаБСП = ОбменДаннымиПовтИсп.ПланыОбменаБСП();
	
	ТаблицаМонитора = ОбменДаннымиСервер.ТаблицаМонитораОбменаДанными(ПланыОбменаБСП);

	Для каждого Строка Из ТаблицаМонитора Цикл
		
		НоваяСтрока = Данные.Добавить();
		НоваяСтрока.IB = СокрЛП(ПрефиксИБ);
		НоваяСтрока.NODEID = Строка(Строка.УзелИнформационнойБазы.УникальныйИдентификатор());
		НоваяСтрока.NODENAME = СокрЛП(Строка(Строка.УзелИнформационнойБазы));
		НоваяСтрока.DIRECTION = "Загрузка";
		
		НоваяСтрока = Данные.Добавить();
		НоваяСтрока.IB = СокрЛП(ПрефиксИБ);
		НоваяСтрока.NODEID = Строка(Строка.УзелИнформационнойБазы.УникальныйИдентификатор());
		НоваяСтрока.NODENAME = СокрЛП(Строка(Строка.УзелИнформационнойБазы));
		НоваяСтрока.DIRECTION = "Выгрузка";

	КонецЦикла;

КонецПроцедуры

Функция НоваяТаблицаОбменыДанными()
	
	ТаблицаДанных = Новый ТаблицаЗначений;
	
	ТаблицаДанных.Колонки.Добавить("IB");
	ТаблицаДанных.Колонки.Добавить("NODEID");
	ТаблицаДанных.Колонки.Добавить("NODENAME");
	ТаблицаДанных.Колонки.Добавить("DIRECTION");
	
	Возврат ТаблицаДанных;
	
КонецФункции

#КонецОбласти
