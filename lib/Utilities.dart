import 'dart:math';

ranStr(int length){
  const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _ran = Random();

  return String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_ran.nextInt(length)))
  );
}

firstUpper(String s){
  if(s.length < 2){
    return s.toUpperCase();
  } else if (s.length < 1){
    return null;
  } else {
    var f = s.substring(0, 1).toUpperCase();
    return f + s.substring(1);
  }
}