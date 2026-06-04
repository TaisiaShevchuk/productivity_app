import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fi'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Productivity App'**
  String get appTitle;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @tasksForToday.
  ///
  /// In en, this message translates to:
  /// **'Tasks for Today'**
  String get tasksForToday;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotes;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasks;

  /// No description provided for @noHabits.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get noHabits;

  /// No description provided for @noGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get noGoals;

  /// No description provided for @noTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get noTrash;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @noGoalsForDay.
  ///
  /// In en, this message translates to:
  /// **'No goals'**
  String get noGoalsForDay;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'If you experience any issues or have questions, please contact us at:'**
  String get supportMessage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get chooseTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteConfirmation;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get deleteItemTitle;

  /// No description provided for @deleteCannotUndo.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteCannotUndo;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @permanentlyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get permanentlyDelete;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteForever;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get taskCompleted;

  /// No description provided for @taskNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task not completed'**
  String get taskNotCompleted;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitle;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Task title...'**
  String get taskTitleHint;

  /// No description provided for @habitStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get habitStreak;

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get goalProgress;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarSelectedDate.
  ///
  /// In en, this message translates to:
  /// **'Selected date'**
  String get calendarSelectedDate;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get settingsAbout;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoal;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal title'**
  String get goalTitle;

  /// No description provided for @noDeadlineSelected.
  ///
  /// In en, this message translates to:
  /// **'No deadline selected'**
  String get noDeadlineSelected;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @newSubtask.
  ///
  /// In en, this message translates to:
  /// **'New subtask'**
  String get newSubtask;

  /// No description provided for @editSubtask.
  ///
  /// In en, this message translates to:
  /// **'Edit subtask'**
  String get editSubtask;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @newHabit.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabit;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabit;

  /// No description provided for @habitName.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitName;

  /// No description provided for @habitStats.
  ///
  /// In en, this message translates to:
  /// **'Habit statistics'**
  String get habitStats;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @writeNote.
  ///
  /// In en, this message translates to:
  /// **'Write your note...'**
  String get writeNote;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'(No title)'**
  String get noTitle;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @taskStatsSoon.
  ///
  /// In en, this message translates to:
  /// **'Task statistics will appear here later.'**
  String get taskStatsSoon;

  /// No description provided for @goalStatsSoon.
  ///
  /// In en, this message translates to:
  /// **'Goal statistics will appear here later.'**
  String get goalStatsSoon;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @habit.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habit;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @noText.
  ///
  /// In en, this message translates to:
  /// **'(no text)'**
  String get noText;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @weekdayMonShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayMonShort;

  /// No description provided for @weekdayTueShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayTueShort;

  /// No description provided for @weekdayWedShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayWedShort;

  /// No description provided for @weekdayThuShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayThuShort;

  /// No description provided for @weekdayFriShort.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayFriShort;

  /// No description provided for @weekdaySatShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySatShort;

  /// No description provided for @weekdaySunShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySunShort;

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get outOf;

  /// No description provided for @scenarios.
  ///
  /// In en, this message translates to:
  /// **'Scenarios'**
  String get scenarios;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistant;

  /// No description provided for @applyScenario.
  ///
  /// In en, this message translates to:
  /// **'Create from template'**
  String get applyScenario;

  /// No description provided for @scenarioApplied.
  ///
  /// In en, this message translates to:
  /// **'Scenario applied'**
  String get scenarioApplied;

  /// No description provided for @scenarioHealthName.
  ///
  /// In en, this message translates to:
  /// **'Health and weight loss'**
  String get scenarioHealthName;

  /// No description provided for @scenarioHealthDescription.
  ///
  /// In en, this message translates to:
  /// **'Creates a simple system for healthier routines, movement, water, and sleep.'**
  String get scenarioHealthDescription;

  /// No description provided for @scenarioHealthGoal.
  ///
  /// In en, this message translates to:
  /// **'Improve health in 2 months'**
  String get scenarioHealthGoal;

  /// No description provided for @scenarioHealthSubtaskMenu.
  ///
  /// In en, this message translates to:
  /// **'Create a weekly meal plan'**
  String get scenarioHealthSubtaskMenu;

  /// No description provided for @scenarioHealthSubtaskWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Choose 3 weekly workouts'**
  String get scenarioHealthSubtaskWorkouts;

  /// No description provided for @scenarioHealthSubtaskSleep.
  ///
  /// In en, this message translates to:
  /// **'Set a stable sleep schedule'**
  String get scenarioHealthSubtaskSleep;

  /// No description provided for @scenarioHealthHabitWater.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get scenarioHealthHabitWater;

  /// No description provided for @scenarioHealthHabitSteps.
  ///
  /// In en, this message translates to:
  /// **'10,000 steps'**
  String get scenarioHealthHabitSteps;

  /// No description provided for @scenarioHealthHabitSleep.
  ///
  /// In en, this message translates to:
  /// **'Go to bed before 23:00'**
  String get scenarioHealthHabitSleep;

  /// No description provided for @scenarioHealthTaskMenu.
  ///
  /// In en, this message translates to:
  /// **'Plan meals for the week'**
  String get scenarioHealthTaskMenu;

  /// No description provided for @scenarioHealthTaskWorkout.
  ///
  /// In en, this message translates to:
  /// **'Find 3 workout options'**
  String get scenarioHealthTaskWorkout;

  /// No description provided for @scenarioStudyName.
  ///
  /// In en, this message translates to:
  /// **'Study and exams'**
  String get scenarioStudyName;

  /// No description provided for @scenarioStudyDescription.
  ///
  /// In en, this message translates to:
  /// **'Builds a study plan with a long-term goal, review habits, and first tasks.'**
  String get scenarioStudyDescription;

  /// No description provided for @scenarioStudyGoal.
  ///
  /// In en, this message translates to:
  /// **'Prepare for the exam'**
  String get scenarioStudyGoal;

  /// No description provided for @scenarioStudySubtaskPlan.
  ///
  /// In en, this message translates to:
  /// **'Break topics into weeks'**
  String get scenarioStudySubtaskPlan;

  /// No description provided for @scenarioStudySubtaskSources.
  ///
  /// In en, this message translates to:
  /// **'Collect learning sources'**
  String get scenarioStudySubtaskSources;

  /// No description provided for @scenarioStudySubtaskDraft.
  ///
  /// In en, this message translates to:
  /// **'Make the first summary draft'**
  String get scenarioStudySubtaskDraft;

  /// No description provided for @scenarioStudyHabitReading.
  ///
  /// In en, this message translates to:
  /// **'Study for 45 minutes'**
  String get scenarioStudyHabitReading;

  /// No description provided for @scenarioStudyHabitReview.
  ///
  /// In en, this message translates to:
  /// **'Review notes'**
  String get scenarioStudyHabitReview;

  /// No description provided for @scenarioStudyTaskSchedule.
  ///
  /// In en, this message translates to:
  /// **'Create a study schedule'**
  String get scenarioStudyTaskSchedule;

  /// No description provided for @scenarioStudyTaskMaterials.
  ///
  /// In en, this message translates to:
  /// **'Prepare study materials'**
  String get scenarioStudyTaskMaterials;

  /// No description provided for @scenarioBudgetName.
  ///
  /// In en, this message translates to:
  /// **'Personal budget'**
  String get scenarioBudgetName;

  /// No description provided for @scenarioBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Starts a budget routine with spending tracking and saving actions.'**
  String get scenarioBudgetDescription;

  /// No description provided for @scenarioBudgetGoal.
  ///
  /// In en, this message translates to:
  /// **'Build a monthly budget'**
  String get scenarioBudgetGoal;

  /// No description provided for @scenarioBudgetSubtaskExpenses.
  ///
  /// In en, this message translates to:
  /// **'Track expenses for 7 days'**
  String get scenarioBudgetSubtaskExpenses;

  /// No description provided for @scenarioBudgetSubtaskLimit.
  ///
  /// In en, this message translates to:
  /// **'Set category limits'**
  String get scenarioBudgetSubtaskLimit;

  /// No description provided for @scenarioBudgetSubtaskSavings.
  ///
  /// In en, this message translates to:
  /// **'Choose a saving target'**
  String get scenarioBudgetSubtaskSavings;

  /// No description provided for @scenarioBudgetHabitExpenses.
  ///
  /// In en, this message translates to:
  /// **'Record expenses'**
  String get scenarioBudgetHabitExpenses;

  /// No description provided for @scenarioBudgetHabitReview.
  ///
  /// In en, this message translates to:
  /// **'Review budget'**
  String get scenarioBudgetHabitReview;

  /// No description provided for @scenarioBudgetTaskCategories.
  ///
  /// In en, this message translates to:
  /// **'Create spending categories'**
  String get scenarioBudgetTaskCategories;

  /// No description provided for @scenarioBudgetTaskSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Check subscriptions'**
  String get scenarioBudgetTaskSubscriptions;

  /// No description provided for @assistantTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get assistantTodayTitle;

  /// No description provided for @assistantGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get assistantGoalsTitle;

  /// No description provided for @assistantHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get assistantHabitsTitle;

  /// No description provided for @assistantForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get assistantForecastTitle;

  /// No description provided for @assistantNoOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'No open tasks. Good moment to plan the next step.'**
  String get assistantNoOpenTasks;

  /// No description provided for @assistantOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'You have {count} open tasks. Start with the smallest one to build momentum.'**
  String assistantOpenTasks(int count);

  /// No description provided for @assistantNoUrgentGoals.
  ///
  /// In en, this message translates to:
  /// **'No urgent goals with deadlines right now.'**
  String get assistantNoUrgentGoals;

  /// No description provided for @assistantGoalWarning.
  ///
  /// In en, this message translates to:
  /// **'Nearest active goal: {goal}. Deadline: {date}. Add one small task for this week.'**
  String assistantGoalWarning(String goal, String date);

  /// No description provided for @assistantNoHabits.
  ///
  /// In en, this message translates to:
  /// **'Add a habit to receive routine recommendations.'**
  String get assistantNoHabits;

  /// No description provided for @assistantHabitAdvice.
  ///
  /// In en, this message translates to:
  /// **'Habit to support today: {habit}. Try attaching it to an existing routine.'**
  String assistantHabitAdvice(String habit);

  /// No description provided for @assistantForecastBody.
  ///
  /// In en, this message translates to:
  /// **'With more completed tasks and habit marks, this module can estimate productive hours and warn about delayed goals.'**
  String get assistantForecastBody;

  /// No description provided for @noCalendarItems.
  ///
  /// In en, this message translates to:
  /// **'No goals or tasks for this day'**
  String get noCalendarItems;

  /// No description provided for @createCustomScenario.
  ///
  /// In en, this message translates to:
  /// **'Create custom scenario'**
  String get createCustomScenario;

  /// No description provided for @customScenario.
  ///
  /// In en, this message translates to:
  /// **'Custom scenario'**
  String get customScenario;

  /// No description provided for @editScenario.
  ///
  /// In en, this message translates to:
  /// **'Edit scenario'**
  String get editScenario;

  /// No description provided for @editAndApply.
  ///
  /// In en, this message translates to:
  /// **'Edit and apply'**
  String get editAndApply;

  /// No description provided for @scenarioName.
  ///
  /// In en, this message translates to:
  /// **'Scenario name'**
  String get scenarioName;

  /// No description provided for @scenarioDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get scenarioDescription;

  /// No description provided for @scenarioEditorHelper.
  ///
  /// In en, this message translates to:
  /// **'One item per line'**
  String get scenarioEditorHelper;

  /// No description provided for @scenarioEditorNote.
  ///
  /// In en, this message translates to:
  /// **'Goals created here use a default deadline of 30 days. You can adjust them later in Goals.'**
  String get scenarioEditorNote;

  /// No description provided for @taskStats.
  ///
  /// In en, this message translates to:
  /// **'Task completion'**
  String get taskStats;

  /// No description provided for @goalStats.
  ///
  /// In en, this message translates to:
  /// **'Goal completion'**
  String get goalStats;

  /// No description provided for @monochromeTheme.
  ///
  /// In en, this message translates to:
  /// **'Black and white'**
  String get monochromeTheme;

  /// No description provided for @linkNote.
  ///
  /// In en, this message translates to:
  /// **'Linked note'**
  String get linkNote;

  /// No description provided for @chooseNote.
  ///
  /// In en, this message translates to:
  /// **'Choose note'**
  String get chooseNote;

  /// No description provided for @createLinkedNote.
  ///
  /// In en, this message translates to:
  /// **'Create note'**
  String get createLinkedNote;

  /// No description provided for @createAndLink.
  ///
  /// In en, this message translates to:
  /// **'Create and link'**
  String get createAndLink;

  /// No description provided for @openNote.
  ///
  /// In en, this message translates to:
  /// **'Open note'**
  String get openNote;

  /// No description provided for @removeNoteLink.
  ///
  /// In en, this message translates to:
  /// **'Remove note link'**
  String get removeNoteLink;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fi', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fi': return AppLocalizationsFi();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
