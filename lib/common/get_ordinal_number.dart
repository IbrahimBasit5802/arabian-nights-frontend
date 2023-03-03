String getOrdinalNumber({required int number, bool short = false}) {
  if (!(number >= 0 && number <= 100)) {
    //here you change the range
    throw Exception('Invalid number');
  }

  if (number >= 11 && number <= 13) {
    return short == true ? '$number' : '${number}th';
  }

  switch (number % 10) {
    case 0:
      return short == true ? 'G' : 'Ground';
    case 1:
      return short == true ? '1' : '${number}st';
    case 2:
      return short == true ? '2' : '${number}nd';
    case 3:
      return short == true ? '3' : '${number}rd';
    default:
      return short == true ? '$number' : '${number}th';
  }
}
