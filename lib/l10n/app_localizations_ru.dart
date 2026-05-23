// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Finance Flow';

  @override
  String get cardSaved => 'Карта успешно сохранена';

  @override
  String get cardDeleted => 'Карта удалена';

  @override
  String get cardAlreadyExists => 'Такая карта уже существует';

  @override
  String get deleteAccount => 'Удалить аккаунт?';

  @override
  String confirmDelete(String name) {
    return 'Вы уверены, что хотите удалить $name?';
  }

  @override
  String get myProfile => 'Мой профиль';

  @override
  String get editAccount => 'Редактировать аккаунт';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get language => 'Язык';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get accountSecurity => 'Безопасность аккаунта';

  @override
  String get notifications => 'Уведомления';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get settings => 'Настройки';

  @override
  String get helpCentre => 'Центр помощи';

  @override
  String get privacyPolicy => 'Конфиденциальность';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get makeThisAccountPrimary => 'Сделать этот аккаунт основным';

  @override
  String get create => 'Создать';

  @override
  String get save => 'Сохранить';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get monthlyExpenses => 'Траты за месяц';

  @override
  String get recentExpenses => 'Последние траты';

  @override
  String get spendThisMonth => 'Потрачено в этом месяце';

  @override
  String get nothingToShow => 'Нечего показать(';

  @override
  String get chooseDate => 'Выберите дату';

  @override
  String get chooseTime => 'Выберите время';

  @override
  String get category => 'Категория';

  @override
  String get categories => 'Категории';

  @override
  String get expense => 'Трата';

  @override
  String get expenses => 'Траты';

  @override
  String get incomes => 'Доходы';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get noDataInThisMonth => 'Нет данных в этом месяце';

  @override
  String get byn => 'руб.';

  @override
  String get welcomeBack => 'Привет 👋';

  @override
  String get expenseAnalytics => 'Анализ трат';

  @override
  String get todayExpenses => 'Сегодняшние траты';

  @override
  String get viewAll => 'Посмотреть всё';

  @override
  String get walletBalance => 'Баланс кошелька';

  @override
  String get wallet => 'Кошелек';

  @override
  String get spent => 'Потрачено';

  @override
  String get budget => 'Бюджет';

  @override
  String get income => 'Доход';

  @override
  String get spend => 'Траты';

  @override
  String get allSpends => 'Все траты';

  @override
  String get allIncomes => 'Все доходы';

  @override
  String addItem(String name) {
    return 'Добавить $name';
  }

  @override
  String get actions => 'Опции';

  @override
  String get addTransaction => 'Добавить транзакцию';

  @override
  String get noCardsAddedYet => 'Карты ещё не добавлены';

  @override
  String get addCard => 'Добавить карту';

  @override
  String get needToCreateAccount => 'Нужно создать аккаунт';

  @override
  String get cancel => 'Отмена';

  @override
  String get exit => 'Выйти';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get fieldCanNotBeEmpty => 'Поле не может быть пустым';

  @override
  String get valueInvalid => 'Неверное значение';

  @override
  String get futureDate => 'Дата не может быть позже сегодняшнего дня';

  @override
  String expenseEdited(String name) {
    return 'Трата \"$name\" успешно изменена';
  }

  @override
  String get invalidLength => 'Некорректная длина';

  @override
  String get invalidFormat => 'Некорректный формат';

  @override
  String get invalidCardNumber => 'Некорректный номер карты';

  @override
  String get weeklyExpense => 'Недельные траты';

  @override
  String fromDate(Object date) {
    return 'С $date';
  }

  @override
  String get transactionName => 'Название';

  @override
  String get amount => 'Сумма';

  @override
  String get tripToTurkey => 'Путешествие в Турцию';

  @override
  String get date => 'Дата';

  @override
  String get time => 'Время';

  @override
  String get createTransaction => 'Создать транзакцию';

  @override
  String get editTransaction => 'Изменить транзакцию';

  @override
  String get email => 'Email';

  @override
  String expenseNameCreated(Object expense, String gender, Object type) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'expense': 'создана',
      'income': 'создан',
      'other': 'создано',
    });
    return '$type \"$expense\" успешно $_temp0';
  }
}
