DataClean(String data, {bool quote = false}) {
  var result = data.toString().replaceAll('&amp;', '&');
  result = result.toString().replaceAll('&#4;', '(tsc4)');
  result = result.toString().replaceAll('&#13;', '(tsc13)');
  result = result.toString().replaceAll('&#10;', '(tsc10)');
  result = result.toString().replaceAll('&apos;', '(tscapos)');
  result = result.toString().replaceAll('&quot;', '(tscquot)');
  result = result.toString().replaceAll('', '(tsc1)');
  if (quote) {
    result = result.toString().replaceAll('\'', '(tsquot)');
    result = result.toString().replaceAll('"', '(tdquot)');
  }
  return result;
}

DataTally(dynamic data, {bool quote = false}) {
  var result = data.toString().replaceAll('&', '&amp;');
  result = result.toString().replaceAll('(tsc4)', '&#4;');
  result = result.toString().replaceAll('(tsc13)', '&#13;');
  result = result.toString().replaceAll('(tsc10)', '&#10;');
  result = result.toString().replaceAll('(tscapos)', '&apos;');
  result = result.toString().replaceAll('(tscquot)', '&quot;');
  result = result.toString().replaceAll('(tsc1)', '');
  if (quote) {
    result = result.toString().replaceAll('(tsquot)', '\'');
    result = result.toString().replaceAll('(tdquot)', '"');
  }
  return result;
}
