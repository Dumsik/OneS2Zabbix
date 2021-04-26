#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать strings
#Использовать 1commands
#Использовать cmdline
#Использовать json

Функция СформироватьОписаниеКоманд() Экспорт

	Парсер = Новый ПарсерАргументовКоманднойСтроки;

	КомандаПолучитьСправку.ОписаниеКоманды(Парсер);
	КомандаВызовУдаленнойПроцедуры.ОписаниеКоманды(Парсер);
	КомандаПинг.ОписаниеКоманды(Парсер);

	Возврат Парсер;
	
КонецФункции

Процедура ВыполнитьКоманду(ПарсерАргументов, ПараметрыКоманднойСтроки) Экспорт

	Команда = ПараметрыКоманднойСтроки.Команда;
	ЗначенияПараметров = ПараметрыКоманднойСтроки.ЗначенияПараметров;

	Если ВРег(Команда) = "HELP" Тогда
		КомандаПолучитьСправку.ВыполнитьКоманду(ПарсерАргументов, ЗначенияПараметров);
	ИначеЕсли ВРег(Команда) = "RPC" Тогда
		КомандаВызовУдаленнойПроцедуры.ВыполнитьКоманду(ПарсерАргументов, ЗначенияПараметров);
	ИначеЕсли ВРег(Команда) = "PING" Тогда
		КомандаПинг.ВыполнитьКоманду(ПарсерАргументов, ЗначенияПараметров);
	Иначе
		ВызватьИсключение "команда не определена";
	КонецЕсли;
	
КонецПроцедуры

Функция СформироватьТексОшибкиJSON(Знач ТекстОшибки) Экспорт

	Ошибка = Новый Структура;
	Ошибка.Вставить("error", ТекстОшибки);

	Парсер = Новый ПарсерJSON();
	ТекстОшибки = Парсер.ЗаписатьJSON(Ошибка);

	Возврат ТекстОшибки;
	
КонецФункции