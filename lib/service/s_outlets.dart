import 'dart:math';

import 'package:elbe/elbe.dart';
import 'package:elbe/util/m_data.dart';

class NewsOutletAudience extends DataModel {
  static const List<double> _incomes = [0, 250, 750, 1250, 1750, 2500, 5000];
  static const List<double> _ages = [25, 50, 70];
  static const List<double> _genders = [0, 1];
  static const List<double> _homeOwnerships = [2, 1, 0];
  static const List<double> _education = [0, 1, 2, 3, 4, 5];
  static const List<double> _citySize = [2500, 1200, 60000, 250000, 1000000];

  final List<double>
      incomes; //0, 0-500, 500-1000, 1000-1500, 1500-2000, 2000-3000, 3000+
  final List<double> ages; // 14-39, 40-59, 60+
  final List<double> genders; // male, female
  final List<double> homeOwnerships; // house, flat, rent

  final List<double>
      educations; // none, hauptschule, lehre, realschule, abitur, studium
  final List<double>
      citySizes; // 0-5000, 5000-20000, 20000-100000, 100000-500000, 500000+

  double get income => _combine(incomes, _incomes);
  double get age => _combine(ages, _ages);
  double get gender => _combine(genders, _genders);
  double get homeOwnership => _combine(homeOwnerships, _homeOwnerships);
  double get education => _combine(educations, _education);
  double get citySize => _combine(citySizes, _citySize);

  double get incomeNorm => _global((a) => a.income);
  double get ageNorm => _global((a) => a.age);
  double get genderNorm => _global((a) => a.gender);
  double get homeOwnershipNorm => _global((a) => a.homeOwnership);
  double get educationNorm => _global((a) => a.education);
  double get citySizeNorm => _global((a) => a.citySize);

  double _global(double Function(NewsOutletAudience) map) {
    final gs = _outlets.map((e) => e.audience).map(map);
    final v = map(this);
    final min = gs.min;

    return (v - min) / (gs.max - min);
  }

  double _combine(List<double> v, List<double> k) =>
      v.foldIndexed(0.0, (i, p, e) => p + e * k[i]);

  const NewsOutletAudience({
    required this.incomes,
    required this.ages,
    required this.genders,
    required this.homeOwnerships,
    required this.educations,
    required this.citySizes,
  });

  @override
  get map => {
        "incomes": incomes,
        "ages": ages,
        "genders": genders,
        "homeOwnerships": homeOwnerships,
        "educations": educations,
        "citySizes": citySizes,
      };
}

class NewsOutletRating extends DataModel {
  final double politicalPerspective; // 0 (left) - 1 (right)
  final double factualAccuracy; // 0 (false) - 1 (true)
  final double credibility; // 0 (low) - 1 (high)
  final String sourceUrl;

  const NewsOutletRating(
      {required this.politicalPerspective,
      required this.factualAccuracy,
      required this.credibility,
      required this.sourceUrl});

  @override
  get map => {
        "politicalPerspective": politicalPerspective,
        "factualAccuracy": factualAccuracy,
        "credibility": credibility,
        "sourceUrl": sourceUrl,
      };
}

class NewsOutlet extends DataModel {
  final String name;
  final String host;
  final String logo;

  final NewsOutletAudience audience;
  final NewsOutletRating? rating;

  const NewsOutlet(
      {required this.name,
      required this.host,
      this.logo = "",
      required this.audience,
      this.rating});

  @override
  get map => {
        "name": name,
        "host": host,
        "logo": logo,
        "audience": audience.map,
        "rating": rating?.map,
      };
}

class OutletService {
  static OutletService i = OutletService._();
  OutletService._();

  final outlets = _outlets;

  NewsOutlet get(String host) => maybe(host)!;

  NewsOutlet? maybe(String host) =>
      outlets.firstWhereOrNull((element) => host.endsWith(element.host));

  double dist(NewsOutlet a, NewsOutlet b) => _dist(a, b, [
        //(e) => e.rating?.politicalPerspective ?? 0,
        //(e) => e.rating?.factualAccuracy ?? 0,
        //(e) => e.rating?.credibility ?? 0,
        (e) => e.audience.income,
        (e) => e.audience.age,
        (e) => e.audience.education,
        (e) => e.audience.citySize
      ]);

  List<(double dist, NewsOutlet value)> opposed(NewsOutlet selected) {
    return outlets
        .where((e) => e.host != selected.host)
        .sorted((a, b) => dist(selected, b).compareTo(dist(selected, a)))
        .map((e) => (dist(selected, e), e))
        .toList();
  }
}

double _dist(
        NewsOutlet a, NewsOutlet b, List<double Function(NewsOutlet e)> ms) =>
    sqrt(ms.fold(0.0, (p, e) => p + pow(e(a) - e(b), 2)));

const _outlets = [
  NewsOutlet(
      name: "Bild",
      host: "bild.de",
      rating: NewsOutletRating(
          politicalPerspective: 0.75,
          factualAccuracy: 0.5,
          credibility: 0.5,
          sourceUrl: "https://mediabiasfactcheck.com/bild/"),
      audience: NewsOutletAudience(
        genders: [0.66, 0.34],
        ages: [0.28, 0.37, 0.35],
        educations: [0.02, 0.11, 0.37, 0.30, 0.11, 0.10],
        incomes: [0.03, 0.07, 0.14, 0.21, 0.21, 0.23, 0.11],
        citySizes: [0.13, 0.27, 0.28, 0.15, 0.17],
        homeOwnerships: [0.33, 0.07, 0.60],
      )),
  NewsOutlet(
      name: "Frankfurter Allgemeine Zeitung",
      host: "faz.net",
      rating: NewsOutletRating(
          politicalPerspective: 0.75,
          factualAccuracy: 0.8,
          credibility: 0.8,
          sourceUrl:
              "https://mediabiasfactcheck.com/frankfurter-allgemeine-zeitung-faz/"),
      audience: NewsOutletAudience(
        genders: [0.66, 0.34],
        ages: [0.38, 0.37, 0.25],
        educations: [0.02, 0.02, 0.05, 0.15, 0.24, 0.51],
        incomes: [0.03, 0.06, 0.09, 0.09, 0.10, 0.23, 0.41],
        citySizes: [0.07, 0.22, 0.27, 0.20, 0.24],
        homeOwnerships: [0.46, 0.15, 0.39],
      )),
  NewsOutlet(
      name: "Badische Zeitung",
      host: "badische-zeitung.de",
      audience: NewsOutletAudience(
        genders: [0.47, 0.53],
        ages: [0.23, 0.36, 0.42],
        educations: [0.01, 0.05, 0.23, 0.27, 0.19, 0.25],
        incomes: [0.03, 0.09, 0.13, 0.14, 0.16, 0.27, 0.19],
        citySizes: [0.20, 0.34, 0.22, 0.24, 0.00],
        homeOwnerships: [0.52, 0.17, 0.31],
      )),
  NewsOutlet(
      name: "Süddeutsche",
      host: "sueddeutsche.de",
      rating: NewsOutletRating(
          politicalPerspective: 0.25,
          factualAccuracy: 0.8,
          credibility: 0.8,
          sourceUrl:
              "https://mediabiasfactcheck.com/suddeutsche-zeitung-bias/"),
      audience: NewsOutletAudience(
        genders: [0.58, 0.42],
        ages: [0.37, 0.36, 0.27],
        educations: [0.04, 0.02, 0.09, 0.18, 0.18, 0.49],
        incomes: [0.08, 0.10, 0.11, 0.11, 0.25, 0.32, 0.03],
        citySizes: [0.13, 0.25, 0.21, 0.12, 0.29],
        homeOwnerships: [0.39, 0.16, 0.46],
      )),
  NewsOutlet(
      name: "Welt",
      host: "welt.de",
      rating: NewsOutletRating(
          politicalPerspective: 0.75,
          factualAccuracy: 0.8,
          credibility: 0.8,
          sourceUrl: "https://mediabiasfactcheck.com/die-welt/"),
      audience: NewsOutletAudience(
        genders: [0.66, 0.34],
        ages: [0.42, 0.36, 0.22],
        educations: [0.03, 0.03, 0.07, 0.18, 0.22, 0.46],
        incomes: [0.03, 0.08, 0.10, 0.09, 0.08, 0.23, 0.39],
        citySizes: [0.10, 0.21, 0.24, 0.18, 0.26],
        homeOwnerships: [0.39, 0.14, 0.47],
      )),
  NewsOutlet(
      name: "Handelsblatt",
      host: "handelsblatt.com",
      audience: NewsOutletAudience(
        genders: [0.82, 0.18],
        ages: [0.42, 0.43, 0.16],
        educations: [0.02, 0.02, 0.06, 0.19, 0.22, 0.50],
        incomes: [0.01, 0.04, 0.08, 0.06, 0.08, 0.22, 0.52],
        citySizes: [0.11, 0.24, 0.26, 0.17, 0.22],
        homeOwnerships: [0.44, 0.16, 0.41],
      )),
  NewsOutlet(
      name: "taz",
      host: "taz.de",
      audience: NewsOutletAudience(
        genders: [0.59, 0.41],
        ages: [0.46, 0.33, 0.21],
        educations: [0.02, 0.03, 0.06, 0.23, 0.33, 0.33],
        incomes: [0.05, 0.09, 0.13, 0.22, 0.11, 0.21, 0.20],
        citySizes: [0.14, 0.23, 0.24, 0.17, 0.23],
        homeOwnerships: [0.35, 0.11, 0.54],
      )),
  NewsOutlet(
      name: "DER SPIEGEL",
      host: "spiegel.de",
      rating: NewsOutletRating(
          politicalPerspective: 0.25,
          factualAccuracy: 0.8,
          credibility: 0.8,
          sourceUrl: "https://mediabiasfactcheck.com/spiegel-online/"),
      audience: NewsOutletAudience(
        genders: [0.67, 0.33],
        ages: [0.14, 0.53, 0.32],
        educations: [0.02, 0.02, 0.13, 0.21, 0.21, 0.41],
        incomes: [0.02, 0.05, 0.06, 0.13, 0.15, 0.28, 0.3],
        citySizes: [0.03, 0.07, 0.19, 0.31, 0.4],
        homeOwnerships: [0.43, 0.12, 0.45],
      )),
  NewsOutlet(
      name: "Focus",
      host: "focus.de",
      audience: NewsOutletAudience(
        genders: [0.71, 0.29],
        ages: [0.11, 0.58, 0.31],
        educations: [0.01, 0.04, 0.18, 0.27, 0.18, 0.31],
        incomes: [0.02, 0.03, 0.06, 0.13, 0.15, 0.28, 0.32],
        citySizes: [0.03, 0.07, 0.2, 0.32, 0.38],
        homeOwnerships: [0.43, 0.12, 0.45],
      )),
  NewsOutlet(
      name: "Stern",
      host: "stern.de",
      audience: NewsOutletAudience(
        genders: [0.62, 0.38],
        ages: [0.12, 0.52, 0.37],
        educations: [0.02, 0.05, 0.21, 0.27, 0.16, 0.29],
        incomes: [0.03, 0.04, 0.08, 0.19, 0.17, 0.27, 0.23],
        citySizes: [0.03, 0.07, 0.21, 0.34, 0.35],
        homeOwnerships: [0.43, 0.11, 0.46],
      )),
  NewsOutlet(
      name: "DIE ZEIT",
      host: "zeit.de",
      rating: NewsOutletRating(
          politicalPerspective: 0.25,
          factualAccuracy: 0.8,
          credibility: 0.8,
          sourceUrl: "https://mediabiasfactcheck.com/die-zeit/"),
      audience: NewsOutletAudience(
        genders: [0.57, 0.43],
        ages: [0.27, 0.46, 0.28],
        educations: [0.04, 0.01, 0.05, 0.14, 0.25, 0.51],
        incomes: [0.03, 0.09, 0.08, 0.12, 0.11, 0.24, 0.33],
        citySizes: [0.02, 0.06, 0.18, 0.26, 0.47],
        homeOwnerships: [0.4, 0.14, 0.46],
      )),
  NewsOutlet(
      name: "Merkur",
      host: "merkur.de",
      rating: NewsOutletRating(
          politicalPerspective: 0.5,
          factualAccuracy: 0.8,
          credibility: 0.8,
          sourceUrl: "https://mediabiasfactcheck.com/munchner-merkur-bias/"),
      audience: NewsOutletAudience(
        genders: [0.51, 0.49],
        ages: [0.17, 0.35, 0.48],
        educations: [0.02, 0.04, 0.36, 0.31, 0.11, 0.18],
        incomes: [0.04, 0.07, 0.15, 0.18, 0.18, 0.23, 0.15],
        citySizes: [0.20, 0.38, 0.22, 0.00, 0.20],
        homeOwnerships: [0.44, 0.16, 0.40],
      )),
  NewsOutlet(
      name: "Morgenpost",
      host: "morgenpost.de",
      audience: NewsOutletAudience(
        genders: [0.59, 0.41],
        ages: [0.30, 0.42, 0.28],
        educations: [0.02, 0.06, 0.23, 0.30, 0.19, 0.19],
        incomes: [0.04, 0.06, 0.12, 0.19, 0.19, 0.21, 0.17],
        citySizes: [0.04, 0.10, 0.09, 0.03, 0.74],
        homeOwnerships: [0.20, 0.15, 0.65],
      )),
  NewsOutlet(
      name: "Rheinische Post",
      host: "rp-online.de",
      audience: NewsOutletAudience(
        genders: [0.51, 0.49],
        ages: [0.18, 0.36, 0.46],
        educations: [0.01, 0.06, 0.26, 0.26, 0.19, 0.22],
        incomes: [0.05, 0.07, 0.14, 0.16, 0.15, 0.22, 0.22],
        citySizes: [0.00, 0.10, 0.52, 0.26, 0.13],
        homeOwnerships: [0.41, 0.07, 0.52],
      )),
  NewsOutlet(
      name: "Südwest Presse",
      host: "swp.de",
      audience: NewsOutletAudience(
        genders: [0.49, 0.51],
        ages: [0.15, 0.34, 0.51],
        educations: [0.01, 0.05, 0.34, 0.29, 0.12, 0.19],
        incomes: [0.02, 0.05, 0.15, 0.20, 0.17, 0.23, 0.18],
        citySizes: [0.18, 0.35, 0.38, 0.10, 0.00],
        homeOwnerships: [0.56, 0.12, 0.32],
      )),
  NewsOutlet(
      name: "Südkurier",
      host: "suedkurier.de",
      audience: NewsOutletAudience(
        genders: [0.51, 0.49],
        ages: [0.21, 0.37, 0.43],
        educations: [0.06, 0.04, 0.29, 0.31, 0.11, 0.20],
        incomes: [0.07, 0.07, 0.09, 0.17, 0.16, 0.26, 0.18],
        citySizes: [0.20, 0.43, 0.37, 0.00, 0.00],
        homeOwnerships: [0.42, 0.14, 0.44],
      ))
];
