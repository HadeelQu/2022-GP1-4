
 findAge(DateTime bdate)
{
  // days of every month
  var months  = [31, 28, 31, 30, 31, 30,
    31, 31, 30, 31, 30, 31] ;

  DateTime now=DateTime.now();
  var current_date=now.day;
  var current_month=now.month;
  var current_year=now.year;

  // if birth date is greater than current date
  // then do not count this month and add 30
  // to the date so as to subtract the date and
  // get the remaining days
  if (bdate.day > current_date) {
    current_date
    = current_date + months[bdate.month - 1];
    current_month = current_month - 1;
  }

  // if birth month exceeds current month, then do
  // not count this year and add 12 to the month so
  // that we can subtract and find out the difference
  if (bdate.month > current_month) {
    current_year = current_year - 1;
    current_month = current_month + 12;
  }

  // calculate date, month, year
  int calculated_date = current_date - bdate.day;
  int calculated_month = current_month - bdate.month;
  int calculated_year = current_year - bdate.year;

   return calculated_year;
}