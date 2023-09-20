class NewCommunity {
  final String name;
  final String adress;

  NewCommunity({
    required this.name,
    required this.adress,
  });
}

class Incidencias {
  final String description;
  final bool done;

  Incidencias({
    required this.description,
    required this.done,
  });
}

class Reuniones {
  final String date;
  final String description;

  Reuniones({
    required this.date,
    required this.description,
  });
}
