void main() {
  String? id;
  var map = {
    ?'a': id,
    'b': ?id,
  };
  print(map);
}
